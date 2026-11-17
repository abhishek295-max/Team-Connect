package ems.service;

import ems.model.Attendance;
import ems.model.Employee;
import ems.model.EmployeeDocument;
import ems.model.LeaveRequest;
import ems.model.Project;
import ems.model.ProjectMember;
import ems.model.SalaryRecord;
import ems.repository.AttendanceRepository;
import ems.repository.EmployeeDocumentRepository;
import ems.repository.EmployeeRepository;
import ems.repository.LeaveRequestRepository;
import ems.repository.PerformanceReviewRepository;
import ems.repository.ProjectMemberRepository;
import ems.repository.ProjectRepository;
import ems.repository.SalaryRecordRepository;
import ems.repository.SystemSettingRepository;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

@Service
public class EmsAgentService {

    private static final int RECENT_LEAVE_DAYS = 90;
    private static final int ONBOARDING_DAYS = 30;
    private static final List<String> REQUIRED_DOCUMENTS = List.of("ID proof", "Contract");

    private final EmployeeRepository employees;
    private final AttendanceRepository attendance;
    private final LeaveRequestRepository leaves;
    private final SalaryRecordRepository payroll;
    private final EmployeeDocumentRepository documents;
    private final ProjectMemberRepository projectMembers;
    private final ProjectRepository projects;
    private final PerformanceReviewRepository reviews;
    private final EmsNotificationService notifications;
    private final SystemSettingRepository settings;
    private final ObjectProvider<PaymentGatewayAgentProvider> paymentProvider;
    private final ChatClient chatClient;

    @Value("${ems.agents.attendance.late-after:09:30}")
    private LocalTime lateAfter;

    @Value("${ems.agents.attendance.late-count:3}")
    private int lateCountThreshold;

    @Value("${ems.agents.payroll.jump-threshold:0.20}")
    private BigDecimal payrollJumpThreshold;

    public EmsAgentService(
            EmployeeRepository employees,
            AttendanceRepository attendance,
            LeaveRequestRepository leaves,
            SalaryRecordRepository payroll,
            EmployeeDocumentRepository documents,
            ProjectMemberRepository projectMembers,
            ProjectRepository projects,
            PerformanceReviewRepository reviews,
            EmsNotificationService notifications,
            SystemSettingRepository settings,
            ObjectProvider<PaymentGatewayAgentProvider> paymentProvider,
            ChatClient.Builder chatClientBuilder) {
        this.employees = employees;
        this.attendance = attendance;
        this.leaves = leaves;
        this.payroll = payroll;
        this.documents = documents;
        this.projectMembers = projectMembers;
        this.projects = projects;
        this.reviews = reviews;
        this.notifications = notifications;
        this.settings = settings;
        this.paymentProvider = paymentProvider;
        this.chatClient = chatClientBuilder
                .defaultSystem("You are a careful HR drafting assistant. Use only supplied facts. Never make decisions, assign ratings, or invent evidence.")
                .build();
    }

    @Scheduled(cron = "${ems.agents.attendance.cron:0 0 10 * * MON-FRI}")
    public void runWeekdayAttendanceCheck() {
        if (!featureEnabled("ATTENDANCE_ENABLED")) {
            return;
        }

        LocalDate today = LocalDate.now();
        List<AttendanceAnomaly> anomalies = attendanceAnomalies(today);
        for (AttendanceAnomaly anomaly : anomalies) {
            Employee employee = employees.findById(anomaly.employeeId()).orElse(null);
            if (employee != null && employee.getTeamConnectUserId() != null) {
                notifications.notifyUser(
                        employee.getTeamConnectUserId(),
                        "Attendance reminder",
                        anomaly.reason());
            }
        }

        if (!anomalies.isEmpty()) {
            String summary = anomalies.stream()
                    .map(item -> item.employeeName() + ": " + item.reason())
                    .reduce((first, second) -> first + "\n" + second)
                    .orElse("Attendance anomalies require review.");
            for (Employee hr : employees.findAllByOrderByNameAsc()) {
                if ("HR".equalsIgnoreCase(hr.getRole())) {
                    if (hr.getTeamConnectUserId() != null) {
                        notifications.notifyUser(hr.getTeamConnectUserId(), "Attendance anomaly report", summary);
                    }
                    notifications.email(hr.getEmail(), "Attendance anomaly report", summary);
                }
            }
        }
    }

    @Scheduled(cron = "${ems.agents.payments.reconciliation-cron:0 0 2 * * *}")
    public void runNightlyPaymentReconciliation() {
        PaymentGatewayAgentProvider provider = paymentProvider.getIfAvailable();
        if (provider == null) {
            return;
        }
        List<PaymentGatewayAgentProvider.PayoutMismatch> mismatches = provider.reconcile();
        if (mismatches.isEmpty()) {
            return;
        }

        String report = mismatches.stream()
                .map(item -> item.employeeName() + ": " + item.explanation()
                        + " (payroll=" + item.payrollStatus()
                        + ", gateway=" + item.gatewayStatus() + ")")
                .reduce((first, second) -> first + "\n" + second)
                .orElse("Payout status mismatches require review.");
        for (Employee hr : employees.findAllByOrderByNameAsc()) {
            if ("HR".equalsIgnoreCase(hr.getRole())) {
                if (hr.getTeamConnectUserId() != null) {
                    notifications.notifyUser(hr.getTeamConnectUserId(), "Payment reconciliation report", report);
                }
                notifications.email(hr.getEmail(), "Payment reconciliation report", report);
            }
        }
    }

    public List<AttendanceAnomaly> attendanceAnomalies(LocalDate date) {
        List<AttendanceAnomaly> result = new ArrayList<>();
        LocalDate historyStart = date.minusDays(29);
        List<LeaveRequest> allLeaves = leaves.findAll();
        for (Employee employee : employees.findAllByOrderByNameAsc()) {
            if (!"ACTIVE".equalsIgnoreCase(employee.getStatus())) {
                continue;
            }

            Attendance today = attendance.findByEmployeeIdAndDate(employee.getId(), date).orElse(null);
            boolean onApprovedLeave = allLeaves.stream().anyMatch(leave ->
                    Objects.equals(leave.getEmployeeId(), employee.getId())
                            && "APPROVED".equalsIgnoreCase(leave.getStatus())
                            && !date.isBefore(leave.getStartDate())
                            && !date.isAfter(leave.getEndDate()));
            List<Attendance> records = attendance.findByEmployeeIdOrderByDateDesc(employee.getId());
            int lateDays = (int) records.stream()
                    .filter(record -> record.getDate() != null
                            && !record.getDate().isBefore(historyStart)
                            && !record.getDate().isAfter(date)
                            && "PRESENT".equalsIgnoreCase(record.getStatus())
                            && record.getCheckIn() != null
                            && record.getCheckIn().isAfter(lateAfter))
                    .count();

            List<String> reasons = new ArrayList<>();
            if (!onApprovedLeave && (today == null || today.getCheckIn() == null)) {
                reasons.add("No check-in is recorded for " + date + " and no approved leave covers today.");
            }
            if (lateDays >= lateCountThreshold) {
                reasons.add(lateDays + " late check-ins after " + lateAfter
                        + " in the last 30 days (reminder threshold: " + lateCountThreshold + ").");
            }
            if (!reasons.isEmpty()) {
                result.add(new AttendanceAnomaly(
                        employee.getId(),
                        employee.getName(),
                        employee.getEmail(),
                        date,
                        lateDays,
                        String.join(" ", reasons)));
            }
        }
        return result;
    }

    public LeaveTriage triageLeave(Long leaveId) {
        LeaveRequest request = leaves.findById(leaveId)
                .orElseThrow(() -> new IllegalArgumentException("Leave request not found."));
        Employee employee = employees.findById(request.getEmployeeId())
                .orElseThrow(() -> new IllegalArgumentException("Employee not found."));
        LocalDate now = LocalDate.now();
        List<String> reasons = new ArrayList<>();

        boolean duplicateApproved = leaves.findByEmployeeIdOrderByAppliedOnDesc(employee.getId()).stream()
                .anyMatch(existing -> !Objects.equals(existing.getId(), request.getId())
                        && "APPROVED".equalsIgnoreCase(existing.getStatus())
                        && overlaps(existing, request));
        if (duplicateApproved) {
            reasons.add("This request overlaps the employee's existing approved leave.");
            return new LeaveTriage(leaveId, "REJECT", reasons, recentLeaveCount(employee.getId(), now));
        }

        List<String> projectConflicts = projectCoverageConflicts(employee.getId(), request);
        if (!projectConflicts.isEmpty()) {
            reasons.add("Check project coverage: approved leave overlaps for project(s) "
                    + String.join(", ", projectConflicts) + ".");
        }
        int recentLeaves = recentLeaveCount(employee.getId(), now);
        if (request.getReason() == null || request.getReason().isBlank()) {
            reasons.add("The request does not include a reason.");
        }
        if (!projectConflicts.isEmpty() || request.getReason() == null || request.getReason().isBlank()) {
            return new LeaveTriage(leaveId, "NEEDS_MORE_INFO", reasons, recentLeaves);
        }

        reasons.add("No overlapping approved leave was found for the employee's active projects.");
        reasons.add(recentLeaves + " leave request(s) were submitted in the last 90 days; this is context only.");
        return new LeaveTriage(leaveId, "APPROVE", reasons, recentLeaves);
    }

    public PayrollPrecheck precheckPayroll(ems.dto.PayrollRequest request) {
        Employee employee = employees.findById(request.employeeId()).orElse(null);
        List<String> warnings = new ArrayList<>();
        if (employee == null) {
            warnings.add("Employee record was not found.");
            return new PayrollPrecheck(request.employeeId(), warnings);
        }
        if (!"ACTIVE".equalsIgnoreCase(employee.getStatus())) {
            warnings.add("Employee is " + employee.getStatus() + ".");
        }

        List<SalaryRecord> history = payroll.findByEmployeeIdOrderByPaymentDateDesc(employee.getId());
        if (request.periodLabel() != null && !request.periodLabel().isBlank()
                && history.stream().anyMatch(record -> request.periodLabel().equalsIgnoreCase(record.getPeriodLabel()))) {
            warnings.add("A payroll record already exists for period " + request.periodLabel() + ".");
        }

        BigDecimal candidate = payrollAmount(request);
        SalaryRecord previous = history.stream()
                .filter(record -> record.getPaymentDate() != null
                        && !record.getPaymentDate().isAfter(request.paymentDate()))
                .max(Comparator.comparing(SalaryRecord::getPaymentDate))
                .orElse(null);
        if (candidate != null && previous != null && previous.getAmount() != null
                && previous.getAmount().signum() == 0 && candidate.signum() != 0) {
            warnings.add("Net pay changes from 0 to " + candidate + " compared with the previous record.");
        } else if (candidate != null && previous != null && previous.getAmount() != null
                && previous.getAmount().signum() != 0) {
            BigDecimal change = candidate.subtract(previous.getAmount()).abs()
                    .divide(previous.getAmount().abs(), 4, RoundingMode.HALF_UP);
            if (change.compareTo(payrollJumpThreshold) > 0) {
                warnings.add("Net pay changes by " + change.multiply(BigDecimal.valueOf(100))
                        .setScale(1, RoundingMode.HALF_UP) + "% from the previous record.");
            }
        }

        PaymentGatewayAgentProvider provider = paymentProvider.getIfAvailable();
        if (provider == null) {
            warnings.add("Payout account status was not checked: no payment integration is configured.");
        } else if (!provider.hasPayoutAccount(employee)) {
            warnings.add("No payout account is configured for this employee.");
        }
        return new PayrollPrecheck(employee.getId(), warnings);
    }

    public List<OnboardingChecklist> onboardingChecklist() {
        LocalDate cutoff = LocalDate.now().minusDays(ONBOARDING_DAYS);
        return employees.findAllByOrderByNameAsc().stream()
                .filter(employee -> employee.getHireDate() == null || !employee.getHireDate().isBefore(cutoff))
                .map(this::onboardingChecklist)
                .toList();
    }

    public void notifyOnboarding(Employee employee) {
        OnboardingChecklist checklist = onboardingChecklist(employee);
        if (checklist.missingDocuments().isEmpty()) {
            return;
        }
        String missing = String.join(", ", checklist.missingDocuments());
        if (employee.getTeamConnectUserId() != null) {
            notifications.notifyUser(employee.getTeamConnectUserId(), "Onboarding documents needed",
                    "Please upload the following onboarding documents: " + missing + ".");
        }
        String hrMessage = employee.getName() + " is missing: " + missing + ".";
        for (Employee hr : employees.findAllByOrderByNameAsc()) {
            if ("HR".equalsIgnoreCase(hr.getRole())) {
                if (hr.getTeamConnectUserId() != null) {
                    notifications.notifyUser(hr.getTeamConnectUserId(), "Onboarding document checklist", hrMessage);
                }
                notifications.email(hr.getEmail(), "Onboarding document checklist", hrMessage);
            }
        }
    }

    public AnnouncementDraft draftAnnouncement(String request) {
        String result = chatClient.prompt()
                .system("Draft an internal workplace announcement only. Return exactly a concise title on the first line and the announcement body after it. Do not publish, claim policy facts, or invent dates.")
                .user(request)
                .call()
                .content();
        if (result == null || result.isBlank()) {
            throw new IllegalStateException("The AI provider returned an empty announcement draft.");
        }
        String[] parts = result.trim().split("\\R", 2);
        String title = parts[0].replaceFirst("^#+\\s*", "").replaceFirst("^Title:\\s*", "").trim();
        String body = parts.length > 1 ? parts[1].replaceFirst("^Body:\\s*", "").trim() : "";
        return new AnnouncementDraft(title, body);
    }

    public String draftPerformanceComments(Long employeeId) {
        Employee employee = employees.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found."));
        List<Attendance> attendanceHistory = attendance.findByEmployeeIdOrderByDateDesc(employeeId).stream()
                .limit(90)
                .toList();
        List<String> projectNames = projectMembers.findByIdEmployeeId(employeeId).stream()
                .map(ProjectMember::getId)
                .filter(Objects::nonNull)
                .map(memberId -> projects.findById(memberId.getProjectId()).orElse(null))
                .filter(Objects::nonNull)
                .map(project -> project.getProjectName() + " (" + project.getStatus() + ")")
                .toList();
        String facts = "Employee: " + employee.getName()
                + "\nJob title: " + Objects.toString(employee.getJobTitle(), "not provided")
                + "\nAttendance records (latest 90): " + attendanceHistory.stream()
                .map(item -> item.getDate() + " " + item.getStatus()
                        + (item.getCheckIn() == null ? "" : " check-in " + item.getCheckIn()))
                .reduce((first, second) -> first + "; " + second).orElse("none")
                + "\nProjects: " + (projectNames.isEmpty() ? "none recorded" : String.join(", ", projectNames));
        String draft = chatClient.prompt()
                .system("Draft editable, evidence-based performance review comments using only the supplied facts. Do not assign or imply any rating, score, promotion, disciplinary action, or unsupported conclusion. Clearly mark any area where a manager should add evidence.")
                .user(facts)
                .call()
                .content();
        if (draft == null || draft.isBlank()) {
            throw new IllegalStateException("The AI provider returned an empty review draft.");
        }
        return draft;
    }

    public ReconciliationStatus reconciliationStatus() {
        return new ReconciliationStatus(
                paymentProvider.getIfAvailable() != null,
                paymentProvider.getIfAvailable() == null
                        ? "No payment gateway provider is configured; reconciliation is inactive."
                        : "Configured provider supplies read-only payout comparisons; this agent never syncs payment status.");
    }

    public List<PaymentGatewayAgentProvider.PayoutMismatch> reconcileNow() {
        PaymentGatewayAgentProvider provider = paymentProvider.getIfAvailable();
        return provider == null ? List.of() : provider.reconcile();
    }

    public String projectStatusBrief(Long projectId) {
        Project project = projects.findById(projectId)
                .orElseThrow(() -> new IllegalArgumentException("Project not found."));
        List<String> members = projectMembers.findByIdProjectId(projectId).stream()
                .map(ProjectMember::getId)
                .filter(Objects::nonNull)
                .map(ProjectMember.Id::getEmployeeId)
                .map(employees::findById)
                .flatMap(java.util.Optional::stream)
                .map(Employee::getName)
                .toList();
        String facts = "Project: " + project.getProjectName()
                + "\nStatus: " + project.getStatus()
                + "\nDescription: " + Objects.toString(project.getDescription(), "not provided")
                + "\nStart date: " + Objects.toString(project.getStartDate(), "not provided")
                + "\nEnd date: " + Objects.toString(project.getEndDate(), "not provided")
                + "\nAssigned employees: " + (members.isEmpty() ? "none" : String.join(", ", members))
                + "\nCurrent project data does not include milestone or task completion records.";
        String brief = chatClient.prompt()
                .system("Write a concise project status brief from supplied project facts. Do not invent progress, milestones, blockers, owners, or deadlines. State when project progress data is unavailable.")
                .user(facts)
                .call()
                .content();
        if (brief == null || brief.isBlank()) {
            throw new IllegalStateException("The AI provider returned an empty project brief.");
        }
        return brief;
    }

    public List<DataQualityFinding> dataQualityFindings() {
        List<DataQualityFinding> findings = new ArrayList<>();
        for (Employee employee : employees.findAllByOrderByNameAsc()) {
            if (employee.getTeamConnectUserId() == null) {
                findings.add(new DataQualityFinding("EMPLOYEE", employee.getId(),
                        "Employee has no linked TeamConnect account."));
            }
            if (employee.getHireDate() == null) {
                findings.add(new DataQualityFinding("EMPLOYEE", employee.getId(),
                        "Hire date is missing."));
            }
            if (employee.getDepartment() == null) {
                findings.add(new DataQualityFinding("EMPLOYEE", employee.getId(),
                        "Department is not assigned."));
            }
            if ("ACTIVE".equalsIgnoreCase(employee.getStatus())
                    && attendance.findByEmployeeIdOrderByDateDesc(employee.getId()).isEmpty()) {
                findings.add(new DataQualityFinding("EMPLOYEE", employee.getId(),
                        "No attendance records are available."));
            }
        }
        LocalDate today = LocalDate.now();
        for (Project project : projects.findAllByOrderByStartDateDesc()) {
            if ("ACTIVE".equalsIgnoreCase(project.getStatus())
                    && project.getEndDate() != null
                    && project.getEndDate().isBefore(today)) {
                findings.add(new DataQualityFinding("PROJECT", project.getId(),
                        "Project is marked ACTIVE but its end date has passed."));
            }
            if ("ACTIVE".equalsIgnoreCase(project.getStatus())
                    && projectMembers.findByIdProjectId(project.getId()).isEmpty()) {
                findings.add(new DataQualityFinding("PROJECT", project.getId(),
                        "Active project has no assigned members."));
            }
        }
        return findings;
    }

    public String selfServiceAnswer(Employee employee, String question) {
        if (question == null || question.isBlank() || question.length() > 2000) {
            throw new IllegalArgumentException("Question must be between 1 and 2,000 characters.");
        }
        List<Attendance> records = attendance.findByEmployeeIdOrderByDateDesc(employee.getId()).stream()
                .limit(10).toList();
        List<LeaveRequest> leaveRecords = leaves.findByEmployeeIdOrderByAppliedOnDesc(employee.getId()).stream()
                .limit(10).toList();
        List<SalaryRecord> salaryRecords = payroll.findByEmployeeIdOrderByPaymentDateDesc(employee.getId()).stream()
                .limit(6).toList();
        List<EmployeeDocument> employeeDocuments =
                documents.findByEmployeeIdOrderByUploadedAtDesc(employee.getId());
        String facts = "Employee: " + employee.getName()
                + "\nAttendance records: " + records.stream()
                .map(record -> record.getDate() + " " + record.getStatus())
                .reduce((first, second) -> first + "; " + second).orElse("none")
                + "\nLeave requests: " + leaveRecords.stream()
                .map(record -> record.getLeaveType() + " " + record.getStatus() + " "
                        + record.getStartDate() + " to " + record.getEndDate())
                .reduce((first, second) -> first + "; " + second).orElse("none")
                + "\nPayroll records: " + salaryRecords.stream()
                .map(record -> Objects.toString(record.getPeriodLabel(), "period not specified")
                        + " " + record.getStatus() + " paid " + record.getPaymentDate())
                .reduce((first, second) -> first + "; " + second).orElse("none")
                + "\nUploaded documents: " + employeeDocuments.stream()
                .map(EmployeeDocument::getOriginalName)
                .reduce((first, second) -> first + ", " + second).orElse("none");
        String answer = chatClient.prompt()
                .system("Answer the employee's self-service question only using the supplied records and general navigation guidance. Do not expose another employee's information, infer a payroll amount, make HR decisions, or claim to submit forms. Explain how to use the secure HR workspace for changes.")
                .user("Question:\n" + question.trim() + "\n\nThis employee's records:\n" + facts)
                .call()
                .content();
        if (answer == null || answer.isBlank()) {
            throw new IllegalStateException("The AI provider returned an empty self-service answer.");
        }
        return answer;
    }

    private OnboardingChecklist onboardingChecklist(Employee employee) {
        List<String> names = documents.findByEmployeeIdOrderByUploadedAtDesc(employee.getId()).stream()
                .map(EmployeeDocument::getOriginalName)
                .filter(Objects::nonNull)
                .map(name -> name.toLowerCase(Locale.ROOT))
                .toList();
        List<String> missing = new ArrayList<>();
        if (names.stream().noneMatch(this::isIdentityDocument)) {
            missing.add(REQUIRED_DOCUMENTS.get(0));
        }
        if (names.stream().noneMatch(this::isContractDocument)) {
            missing.add(REQUIRED_DOCUMENTS.get(1));
        }
        return new OnboardingChecklist(employee.getId(), employee.getName(), missing);
    }

    private boolean isIdentityDocument(String name) {
        return name.matches(".*\\b(id|identity|passport)\\b.*")
                || name.contains("national-id")
                || name.contains("government-id");
    }

    private boolean isContractDocument(String name) {
        return name.contains("contract") || name.contains("agreement");
    }

    private List<String> projectCoverageConflicts(Long employeeId, LeaveRequest request) {
        List<Long> projectIds = projectMembers.findByIdEmployeeId(employeeId).stream()
                .map(ProjectMember::getId)
                .filter(Objects::nonNull)
                .map(ProjectMember.Id::getProjectId)
                .toList();
        List<String> conflicts = new ArrayList<>();
        List<LeaveRequest> allRequests = leaves.findAll();
        for (Long projectId : projectIds) {
            boolean overlap = projectMembers.findByIdProjectId(projectId).stream()
                    .map(ProjectMember::getId)
                    .filter(Objects::nonNull)
                    .map(ProjectMember.Id::getEmployeeId)
                    .filter(otherEmployee -> !Objects.equals(employeeId, otherEmployee))
                    .anyMatch(otherEmployee -> allRequests.stream().anyMatch(existing ->
                            Objects.equals(existing.getEmployeeId(), otherEmployee)
                                    && "APPROVED".equalsIgnoreCase(existing.getStatus())
                                    && overlaps(existing, request)));
            if (overlap) {
                projects.findById(projectId).map(Project::getProjectName).ifPresent(conflicts::add);
            }
        }
        return conflicts;
    }

    private int recentLeaveCount(Long employeeId, LocalDate today) {
        LocalDate cutoff = today.minusDays(RECENT_LEAVE_DAYS);
        return (int) leaves.findByEmployeeIdOrderByAppliedOnDesc(employeeId).stream()
                .filter(request -> request.getStartDate() != null
                        && !request.getStartDate().isBefore(cutoff)
                        && !request.getStartDate().isAfter(today))
                .count();
    }

    private boolean overlaps(LeaveRequest first, LeaveRequest second) {
        return !first.getEndDate().isBefore(second.getStartDate())
                && !second.getEndDate().isBefore(first.getStartDate());
    }

    private BigDecimal payrollAmount(ems.dto.PayrollRequest request) {
        if (request.baseSalary() != null || request.bonus() != null || request.deductions() != null) {
            return Objects.requireNonNullElse(request.baseSalary(), BigDecimal.ZERO)
                    .add(Objects.requireNonNullElse(request.bonus(), BigDecimal.ZERO))
                    .subtract(Objects.requireNonNullElse(request.deductions(), BigDecimal.ZERO));
        }
        return request.amount();
    }

    private boolean featureEnabled(String key) {
        return settings.findById(key)
                .map(setting -> Boolean.parseBoolean(setting.getValue()))
                .orElse(true);
    }

    public record AttendanceAnomaly(
            Long employeeId,
            String employeeName,
            String email,
            LocalDate date,
            int lateCheckIns,
            String reason) {
    }

    public record LeaveTriage(Long leaveId, String recommendation, List<String> reasons, int recentLeaveCount) {
    }

    public record PayrollPrecheck(Long employeeId, List<String> warnings) {
    }

    public record OnboardingChecklist(Long employeeId, String employeeName, List<String> missingDocuments) {
    }

    public record AnnouncementDraft(String title, String body) {
    }

    public record ReconciliationStatus(boolean active, String message) {
    }

    public record DataQualityFinding(String recordType, Long recordId, String issue) {
    }
}
