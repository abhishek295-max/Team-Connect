package controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Message;
import model.User;
import model.GroupChat;
import org.springframework.http.MediaType;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import service.GroupChatService;
import service.AdminService;
import service.MessageService;
import service.UserService;
import util.AttachmentUtil;
import ems.service.EmsAiCommandService;
import ems.service.EmsAccessService;
import ems.model.Employee;
import ems.service.EmsEmployeeService;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.HashMap;
import java.util.ArrayList;

@Controller
public class ApplicationController {

    private final UserService users;
    private final MessageService messages;
    private final GroupChatService groups;
    private final AdminService admin;
    private final ChatClient aiChatClient;
    private final EmsAiCommandService emsAiCommands;
    private final EmsAccessService emsAccess;
    private final EmsEmployeeService emsEmployees;

    public ApplicationController(
            UserService users,
            MessageService messages,
            GroupChatService groups,
            AdminService admin,
            ChatClient.Builder chatClientBuilder,
            EmsAiCommandService emsAiCommands,
            EmsAccessService emsAccess,
            EmsEmployeeService emsEmployees) {
        this.users = users;
        this.messages = messages;
        this.groups = groups;
        this.admin = admin;
        this.emsAiCommands = emsAiCommands;
        this.emsAccess = emsAccess;
        this.emsEmployees = emsEmployees;
        this.aiChatClient = chatClientBuilder
                .defaultSystem("You are the helpful TeamConnect workspace assistant. Keep responses clear and concise.")
                .build();
    }

    private Integer currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (Integer) session.getAttribute("userId");
    }

    private String redirectToLogin(Integer userId) {
        return userId == null ? "redirect:/views/register.jsp" : null;
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("adminAuthenticated"));
    }

    @GetMapping("/admin")
    public String admin(HttpServletRequest request, Model model) {
        if (isAdmin(request)) {
            model.addAttribute("accounts", admin.accounts());
            model.addAttribute("stats", admin.dashboardStats());
            model.addAttribute("messageTrend", admin.messageTrend());
            model.addAttribute("recentAccounts", admin.recentAccounts());
            model.addAttribute("activityLogs", admin.activityLogs());
            return "views/admin";
        }
        return "views/admin-login";
    }

    @PostMapping("/admin/login")
    public String adminLogin(
            @RequestParam String username,
            @RequestParam String password,
            HttpServletRequest request) {
        if (!admin.authenticate(username, password)) {
            admin.log(username == null ? "unknown" : username.trim(), "ADMIN_LOGIN_FAILED", null, "Invalid credentials", request.getRemoteAddr());
            return "redirect:/admin?error=1";
        }
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) oldSession.invalidate();
        HttpSession session = request.getSession(true);
        session.setAttribute("adminAuthenticated", true);
        session.setAttribute("adminUsername", username.trim());
        session.setAttribute("userId", admin.adminChatUserId());
        session.setAttribute("username", "TCadmin");
        session.setAttribute("email", "admin@teamconnect.local");
        admin.log(username.trim(), "ADMIN_LOGIN", null, "Successful administrator login", request.getRemoteAddr());
        return "redirect:/admin";
    }

    @GetMapping("/admin/logout")
    public String adminLogout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
        return "redirect:/admin";
    }

    @PostMapping("/admin/accounts/create")
    public String adminCreateAccount(
            @RequestParam String username,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam(defaultValue = "EMPLOYEE") String role,
            HttpServletRequest request) {
        if (!isAdmin(request)) return "redirect:/admin";
        int userId = admin.createAccount(username, email, password, role);
        if (userId > 0 && !"ADMIN".equalsIgnoreCase(role)) {
            emsEmployees.createLinked(userId, username.trim(), email.trim(), role);
        }
        admin.log(String.valueOf(request.getSession(false).getAttribute("adminUsername")), "ACCOUNT_CREATED", userId == 0 ? null : userId, username + "/" + role, request.getRemoteAddr());
        return "redirect:/admin";
    }

    @PostMapping("/admin/accounts/update")
    public String adminUpdateAccount(
            @RequestParam int id,
            @RequestParam String username,
            @RequestParam String email,
            @RequestParam(required = false, defaultValue = "") String password,
            HttpServletRequest request) {
        if (!isAdmin(request)) return "redirect:/admin";
        admin.updateAccount(id, username, email, password);
        admin.log(String.valueOf(request.getSession(false).getAttribute("adminUsername")), "ACCOUNT_UPDATED", id, username, request.getRemoteAddr());
        return "redirect:/admin";
    }

    @PostMapping("/admin/accounts/delete")
    public String adminDeleteAccount(@RequestParam int id, HttpServletRequest request) {
        if (!isAdmin(request)) return "redirect:/admin";
        users.delete(id);
        admin.log(String.valueOf(request.getSession(false).getAttribute("adminUsername")), "ACCOUNT_DELETED", id, "Account removed", request.getRemoteAddr());
        return "redirect:/admin";
    }

    @PostMapping("/admin/accounts/state")
    public String adminAccountState(
            @RequestParam int id,
            @RequestParam String status,
            @RequestParam(defaultValue = "USER") String role,
            HttpServletRequest request) {
        if (!isAdmin(request)) return "redirect:/admin";
        admin.setAccountState(id, status, role);
        emsEmployees.syncAccount(id, role, status);
        admin.log(String.valueOf(request.getSession(false).getAttribute("adminUsername")), "ACCOUNT_ACCESS_CHANGED", id, status + "/" + role, request.getRemoteAddr());
        return "redirect:/admin";
    }

    @PostMapping("/admin/notifications/send")
    public String sendAdminNotification(
            @RequestParam String title,
            @RequestParam String message,
            @RequestParam(defaultValue = "INFO") String type,
            @RequestParam(defaultValue = "all") String audience,
            @RequestParam(required = false) List<Integer> recipients,
            HttpServletRequest request) {
        if (!isAdmin(request)) return "redirect:/admin";
        List<Integer> targetIds = "selected".equalsIgnoreCase(audience) && recipients != null
                ? recipients
                : new ArrayList<>();
        int sent = admin.sendNotification(title, message, type,
                String.valueOf(request.getSession(false).getAttribute("adminUsername")), targetIds);
        admin.log(String.valueOf(request.getSession(false).getAttribute("adminUsername")),
                "NOTIFICATION_SENT", null, type.toUpperCase() + " notification delivered to " + sent + " user(s)", request.getRemoteAddr());
        return "redirect:/admin?notificationSent=" + sent;
    }

    @GetMapping("/admin/export/accounts.csv")
    public void exportAccounts(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=teamconnect-accounts.csv");
        var writer = response.getWriter();
        writer.println("id,username,email,role,status,created_at,last_login_at,last_login_ip");
        for (Map<String, Object> account : admin.accounts()) {
            writer.println(csv(account.get("id")) + "," + csv(account.get("username")) + "," +
                    csv(account.get("email")) + "," + csv(account.get("role")) + "," +
                    csv(account.get("status")) + "," + csv(account.get("created_at")) + "," +
                    csv(account.get("last_login_at")) + "," + csv(account.get("last_login_ip")));
        }
        writer.flush();
    }

    @GetMapping("/admin/export/activity.csv")
    public void exportActivity(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=teamconnect-admin-activity.csv");
        var writer = response.getWriter();
        writer.println("admin_username,action,target_id,details,ip_address,created_at");
        for (Map<String, Object> log : admin.activityLogs()) {
            writer.println(csv(log.get("admin_username")) + "," + csv(log.get("action")) + "," +
                    csv(log.get("target_id")) + "," + csv(log.get("details")) + "," +
                    csv(log.get("ip_address")) + "," + csv(log.get("created_at")));
        }
        writer.flush();
    }

    private String csv(Object value) {
        if (value == null) return "";
        String text = String.valueOf(value).replace("\"", "\"\"");
        return "\"" + text + "\"";
    }

    @PostMapping("/login")
    public String login(
            @RequestParam String username,
            @RequestParam String password,
            @RequestParam(required = false, defaultValue = "employee") String workspace,
            HttpServletRequest request) {

        User user = users.authenticate(username, password);
        if (user == null) {
            return "redirect:/views/register.jsp?error=1";
        }

        if (admin.isAdminUser(user.getId())) {
            return "redirect:/views/register.jsp?error=admin_login_route";
        }
        String requestedRole = workspace == null ? "" : workspace.trim().toLowerCase();
        if (!java.util.Set.of("employee", "hr", "manager").contains(requestedRole)) {
            return "redirect:/views/register.jsp?error=role_required";
        }

        HttpSession previousSession = request.getSession(false);
        if (previousSession != null) {
            previousSession.invalidate();
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("email", user.getEmail());
        admin.recordLogin(user.getId(), request.getRemoteAddr());
        try {
            Employee employee = emsAccess.currentEmployee(request);
            String employeeRole = employee.getRole() == null ? "employee" : employee.getRole().toLowerCase();
            if (!employeeRole.equals(requestedRole)) {
                request.getSession(false).invalidate();
                return "redirect:/views/register.jsp?error=role_mismatch";
            }
            return "redirect:/ems/" + employeeRole;
        } catch (RuntimeException ignored) {
            request.getSession(false).invalidate();
            return "redirect:/views/register.jsp?error=ems_link_missing";
        }
    }

    @PostMapping("/register")
    public String register(
            @RequestParam String username,
            @RequestParam String email,
            @RequestParam String password) {
        return "redirect:/views/register.jsp?error=registration_disabled";
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request, HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/index.jsp";
    }

    @PostMapping("/deleteAccount")
    public String delete(HttpServletRequest request) {
        if (isAdmin(request)) {
            return "redirect:/admin";
        }
        Integer userId = currentUserId(request);
        if (userId == null) {
            return "redirect:/views/register.jsp";
        }

        boolean deleted = users.delete(userId);
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        return deleted
                ? "redirect:/views/register.jsp?deleted=1"
                : "redirect:/views/register.jsp?error=account_delete_failed";
    }

    @GetMapping("/chat")
    public String chat(
            HttpServletRequest request,
            Model model,
            @RequestParam(required = false) Integer contactId) {

        Integer userId = currentUserId(request);
        String loginRedirect = redirectToLogin(userId);
        if (loginRedirect != null) {
            return loginRedirect;
        }

        List<User> contacts = users.contacts(userId);
        User activeContact = contactId == null
                ? (contacts.isEmpty() ? null : contacts.get(0))
                : users.find(contactId);

        List<Message> conversationMessages = activeContact == null
                ? List.of()
                : messages.conversation(userId, activeContact.getId());

        model.addAttribute("contacts", contacts);
        model.addAttribute("activeContact", activeContact);
        model.addAttribute("messages", conversationMessages);
        model.addAttribute("contactCount", contacts.size());
        model.addAttribute("messageCount", conversationMessages.size());
        model.addAttribute("groups", groups.groups(userId));
        List<Map<String, Object>> notifications = admin.unreadNotifications(userId);
        model.addAttribute("notifications", notifications);
        admin.markNotificationsRead(userId);

        return "views/chat";
    }

    @GetMapping(value = "/conversation", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> conversation(
            @RequestParam int contactId,
            HttpServletRequest request) {

        Integer userId = currentUserId(request);
        if (userId == null) {
            throw new ResponseStatusException(
                    org.springframework.http.HttpStatus.UNAUTHORIZED,
                    "Please log in again." );
        }

        User contact = users.find(contactId);
        if (contact == null || contact.getId() == userId) {
            throw new ResponseStatusException(
                    org.springframework.http.HttpStatus.NOT_FOUND,
                    "Contact not found." );
        }

        List<Message> conversation = messages.conversation(userId, contactId);
        return Map.of(
                "contact", contact,
                "messageCount", conversation.size(),
                "messages", conversation
        );
    }

    @PostMapping(
            value = "/sendMessage",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    @ResponseBody
    public Map<String, Object> send(
            @RequestParam int receiver,
            @RequestParam(required = false, defaultValue = "") String message,
            @RequestPart(required = false) MultipartFile attachment,
            HttpServletRequest request) throws IOException {

        Integer userId = currentUserId(request);
        if (userId == null) {
            return Map.of("success", false, "error", "Please log in again.");
        }

        AttachmentUtil.StoredAttachment storedAttachment = null;
        if (attachment != null && !attachment.isEmpty()) {
            String originalName = attachment.getOriginalFilename() == null
                    ? "attachment"
                    : attachment.getOriginalFilename();

            byte[] fileBytes = attachment.getBytes();
            String contentType = attachment.getContentType();
            String kind = (contentType != null && contentType.startsWith("image/"))
                    ? "image"
                    : "file";

            storedAttachment = createStoredAttachment(attachment);
        }

        boolean sent = messages.send(userId, receiver, message, storedAttachment);
        return Map.of("success", sent);
    }

    @PostMapping("/editMessage")
    @ResponseBody
    public Map<String, Object> edit(
            @RequestParam int messageId,
            @RequestParam String message,
            HttpServletRequest request) {

        Integer userId = currentUserId(request);
        boolean success = userId != null && messages.edit(messageId, userId, message);
        return Map.of("success", success);
    }

    @PostMapping("/deleteMessage")
    @ResponseBody
    public Map<String, Object> remove(
            @RequestParam int messageId,
            HttpServletRequest request) {

        Integer userId = currentUserId(request);
        boolean success = userId != null && messages.delete(messageId, userId);
        return Map.of("success", success);
    }

    @GetMapping("/attachment")
    public void attachment(
            @RequestParam int messageId,
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        Integer userId = currentUserId(request);
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Attachment export is disabled.");
    }

    @GetMapping("/groupChat/{id}")
    @ResponseBody
    public Object group(@PathVariable int id, HttpServletRequest request) {
        Integer userId = currentUserId(request);
        if (userId == null || !groups.isMember(id, userId)) {
            return Map.of("error", "unauthorized");
        }
        return groups.messages(id);
    }

    @GetMapping("/groupChat/{id}/members")
    @ResponseBody
    public Object groupMembers(@PathVariable int id, HttpServletRequest request) {
        Integer userId = currentUserId(request);
        if (userId == null || !groups.isMember(id, userId)) {
            return Map.of("error", "unauthorized");
        }
        return groups.members(id);
    }

    @PostMapping("/groupChat/create")
    @ResponseBody
    public Object createGroup(
            @RequestParam String name,
            @RequestParam(required = false) List<Integer> memberIds,
            HttpServletRequest request) {
        Integer userId = currentUserId(request);
        if (userId == null) {
            return Map.of("error", "unauthorized");
        }
        if (name == null || name.trim().isEmpty()) {
            return Map.of("error", "Group name is required");
        }
        GroupChat group = groups.create(name, userId);
        if (memberIds != null) {
            memberIds.stream()
                    .filter(memberId -> memberId != null && memberId > 0 && memberId != userId)
                    .distinct()
                    .forEach(memberId -> groups.addMember(group.getId(), memberId));
        }
        return group;
    }

    @PostMapping("/groupChat/{id}/message")
    @ResponseBody
    public Object groupMessage(
            @PathVariable int id,
            @RequestParam String message,
            HttpServletRequest request) {

        Integer userId = currentUserId(request);
        if (userId == null) {
            return Map.of("error", "unauthorized");
        }

        if (!groups.isMember(id, userId) || message == null || message.trim().isEmpty()) {
            return Map.of("error", "Invalid group message");
        }

        groups.send(id, userId, message);
        return Map.of("success", true);
    }

    @PostMapping(value = "/api/ai/chat", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, String> ai(@RequestParam String message, HttpServletRequest request) {
        if (currentUserId(request) == null) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "Please log in again.");
        }
        if (message == null || message.isBlank()) {
            return Map.of("reply", "Please enter a message.");
        }

        try {
            var commandReply = emsAiCommands.command(message, request);
            if (commandReply.isPresent()) return Map.of("reply", commandReply.get());
        } catch (ResponseStatusException ignored) {
            // Non-EMS TeamConnect users continue to use the existing assistant.
        }

        try {
            String reply = aiChatClient.prompt()
                    .user(message.trim())
                    .call()
                    .content();
            return Map.of("reply", reply);
        } catch (Exception exception) {
            return Map.of("reply", "The AI service could not complete that request. Check the server log and API key configuration.");
        }
    }

    private String attachmentExtension(String fileName) {
        if (fileName == null) {
            return "";
        }

        int index = fileName.lastIndexOf('.');
        if (index < 0 || index == fileName.length() - 1) {
            return "";
        }

        return fileName.substring(index).toLowerCase();
    }

    private String persistAttachmentToStorage(String originalName, byte[] fileBytes) throws IOException {
        String extension = attachmentExtension(originalName);
        String storedName = UUID.randomUUID() + extension;

        Path storageDirectory = Path.of(System.getProperty("user.home"), ".online_chat", "attachments");
        Files.createDirectories(storageDirectory);

        Path target = storageDirectory.resolve(storedName).normalize();
        Files.write(target, fileBytes);

        return storedName;
    }

    private AttachmentUtil.StoredAttachment createStoredAttachment(MultipartFile attachment) throws IOException {
        if (attachment == null || attachment.isEmpty()) {
            return null;
        }

        String originalName = attachment.getOriginalFilename() == null
                ? "attachment"
                : attachment.getOriginalFilename();

        byte[] fileBytes = attachment.getBytes();
        String contentType = attachment.getContentType();
        String kind = contentType != null && contentType.startsWith("image/") ? "image" : "file";
        String storedName = persistAttachmentToStorage(originalName, fileBytes);

        return new AttachmentUtil.StoredAttachment(
                originalName,
                storedName,
                contentType == null ? "application/octet-stream" : contentType,
                fileBytes.length,
                kind,
                fileBytes
        );
    }
}
