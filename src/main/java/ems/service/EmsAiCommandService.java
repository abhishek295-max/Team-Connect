package ems.service;

import ems.model.*; import ems.repository.*; import jakarta.servlet.http.HttpServletRequest; import org.springframework.stereotype.Service; import java.time.LocalDate; import java.util.*;

@Service
public class EmsAiCommandService {
    private final EmsAccessService access; private final AttendanceRepository attendance; private final LeaveRequestRepository leaves; private final SalaryRecordRepository payroll; private final ProjectMemberRepository members; private final ProjectRepository projects;
    public EmsAiCommandService(EmsAccessService a,AttendanceRepository at,LeaveRequestRepository l,SalaryRecordRepository p,ProjectMemberRepository m,ProjectRepository pr){access=a;attendance=at;leaves=l;payroll=p;members=m;projects=pr;}
    public Optional<String> command(String raw,HttpServletRequest request){
        if(raw==null||!raw.trim().startsWith("/"))return Optional.empty(); String c=raw.trim().split("\\s+",2)[0].toLowerCase(Locale.ROOT); Employee e=access.currentEmployee(request);
        return switch(c){
            case "/my-profile" -> Optional.of("Profile: "+e.getName()+" · "+e.getEmail()+" · "+(e.getJobTitle()==null?"":e.getJobTitle())+" · status "+e.getStatus());
            case "/my-attendance" -> Optional.of("You have "+attendance.findByEmployeeIdOrderByDateDesc(e.getId()).size()+" attendance records. The latest record is "+attendance.findByEmployeeIdOrderByDateDesc(e.getId()).stream().findFirst().map(a->a.getDate()+" ("+a.getStatus()+")").orElse("unavailable")+".");
            case "/my-leave" -> Optional.of(leaves.findByEmployeeIdOrderByAppliedOnDesc(e.getId()).stream().limit(10).map(l->l.getLeaveType()+": "+l.getStatus()+" ("+l.getStartDate()+" to "+l.getEndDate()+")").collect(java.util.stream.Collectors.joining("; ","Your leave: ",".")));
            case "/my-payroll" -> Optional.of("Payroll records available: "+payroll.findByEmployeeIdOrderByPaymentDateDesc(e.getId()).size()+". Amounts are shown only in the secure payroll workspace.");
            case "/my-projects" -> Optional.of(members.findByIdEmployeeId(e.getId()).stream().map(x->projects.findById(x.getId().getProjectId()).map(Project::getProjectName).orElse(null)).filter(Objects::nonNull).collect(java.util.stream.Collectors.joining(", ","Your projects: ",".")));
            case "/apply-leave" -> Optional.of("Use the secure Leave form in the Employee workspace to submit dates, type, and reason. Chat commands never accept another employee ID.");
            default -> Optional.of("Available secure commands: /my-profile, /my-attendance, /my-leave, /my-payroll, /my-projects, /apply-leave.");
        };
    }
}
