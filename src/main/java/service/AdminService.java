package service;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class AdminService {

    private final JdbcTemplate jdbc;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public AdminService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
        ensureUserControls();
        ensureAdminTable();
    }

    private void ensureUserControls() {
        addColumn("users", "role", "VARCHAR(20) NOT NULL DEFAULT 'USER'");
        addColumn("users", "status", "VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'");
        addColumn("users", "created_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
        addColumn("users", "last_login_at", "TIMESTAMP NULL");
        addColumn("users", "last_login_ip", "VARCHAR(64) NULL");
        jdbc.execute("CREATE TABLE IF NOT EXISTS admin_activity_logs (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, admin_username VARCHAR(80) NOT NULL, " +
                "action VARCHAR(80) NOT NULL, target_id INT NULL, details VARCHAR(500), " +
                "ip_address VARCHAR(64), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
        jdbc.execute("CREATE TABLE IF NOT EXISTS admin_notifications (" +
                "id BIGINT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(160) NOT NULL, " +
                "message TEXT NOT NULL, type VARCHAR(30) NOT NULL DEFAULT 'INFO', " +
                "recipient_id INT NULL, created_by VARCHAR(80) NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, read_at TIMESTAMP NULL, " +
                "INDEX idx_notification_recipient (recipient_id), INDEX idx_notification_read (read_at))");
    }

    private void addColumn(String table, String column, String definition) {
        try {
            jdbc.execute("ALTER TABLE " + table + " ADD COLUMN " + column + " " + definition);
        } catch (DataAccessException ignored) {
            // The column already exists on an upgraded database.
        }
    }

    private void ensureAdminTable() {
        jdbc.execute("CREATE TABLE IF NOT EXISTS admin_accounts (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "username VARCHAR(80) NOT NULL UNIQUE, " +
                "password VARCHAR(255) NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM admin_accounts WHERE username = ?",
                Integer.class,
                "TCadmin"
        );
        if (count == null || count == 0) {
            jdbc.update(
                    "INSERT INTO admin_accounts(username, password) VALUES(?, ?)",
                    "TCadmin",
                    encoder.encode("TCadmin123")
            );
        }
        ensureAdminChatUser();
    }

    private void ensureAdminChatUser() {
        Integer count = jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE username = ?", Integer.class, "TCadmin");
        if (count == null || count == 0) {
            jdbc.update("INSERT INTO users(username, email, password, role, status) VALUES(?,?,?,?,?)",
                    "TCadmin", "admin@teamconnect.local", encoder.encode("TCadmin123"), "ADMIN", "ACTIVE");
        } else {
            jdbc.update("UPDATE users SET role = 'ADMIN', status = 'ACTIVE' WHERE username = ?", "TCadmin");
        }
    }

    public int adminChatUserId() {
        Integer id = jdbc.queryForObject("SELECT id FROM users WHERE username = ?", Integer.class, "TCadmin");
        return id == null ? 0 : id;
    }

    public boolean isAdminUser(int userId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM users WHERE id = ? AND role IN ('ADMIN', 'MODERATOR') AND status = 'ACTIVE'",
                Integer.class,
                userId);
        return count != null && count > 0;
    }

    public boolean authenticate(String username, String password) {
        if (username == null || password == null) return false;
        try {
            String hash = jdbc.queryForObject(
                    "SELECT password FROM admin_accounts WHERE username = ?",
                    String.class,
                    username.trim()
            );
            return hash != null && encoder.matches(password, hash);
        } catch (DataAccessException exception) {
            return false;
        }
    }

    public List<Map<String, Object>> accounts() {
        return jdbc.queryForList(
                "SELECT id, username, email, role, status, created_at, last_login_at, last_login_ip FROM users ORDER BY id DESC"
        );
    }

    public void recordLogin(int userId, String ipAddress) {
        jdbc.update("UPDATE users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?", ipAddress, userId);
    }

    public boolean setAccountState(int id, String status, String role) {
        if (id <= 0) return false;
        return jdbc.update("UPDATE users SET status = ?, role = ? WHERE id = ?", status, role, id) > 0;
    }

    public List<Map<String, Object>> activityLogs() {
        return jdbc.queryForList("SELECT admin_username, action, target_id, details, ip_address, created_at " +
                "FROM admin_activity_logs ORDER BY id DESC LIMIT 100");
    }

    public void log(String adminUsername, String action, Integer targetId, String details, String ipAddress) {
        jdbc.update("INSERT INTO admin_activity_logs(admin_username, action, target_id, details, ip_address) VALUES(?,?,?,?,?)",
                adminUsername, action, targetId, details, ipAddress);
    }

    public int sendNotification(String title, String message, String type, String adminUsername, List<Integer> recipientIds) {
        if (title == null || title.isBlank() || message == null || message.isBlank()) return 0;
        String safeType = type == null || type.isBlank() ? "INFO" : type.trim().toUpperCase();
        String sender = adminUsername == null || adminUsername.isBlank() ? "TCadmin" : adminUsername.trim();
        if (recipientIds == null || recipientIds.isEmpty()) {
            recipientIds = jdbc.queryForList("SELECT id FROM users WHERE status = 'ACTIVE'", Integer.class);
        }
        int sent = 0;
        for (Integer recipientId : recipientIds) {
            if (recipientId != null && jdbc.update(
                    "INSERT INTO admin_notifications(title, message, type, recipient_id, created_by) VALUES(?,?,?,?,?)",
                    title.trim(), message.trim(), safeType, recipientId, sender) > 0) sent++;
        }
        return sent;
    }

    public List<Map<String, Object>> unreadNotifications(int userId) {
        try {
            return jdbc.queryForList("SELECT id, title, message, type, created_by, created_at " +
                    "FROM admin_notifications WHERE recipient_id = ? AND read_at IS NULL " +
                    "ORDER BY created_at DESC LIMIT 10", userId);
        } catch (DataAccessException exception) {
            return List.of();
        }
    }

    public void markNotificationsRead(int userId) {
        try {
            jdbc.update("UPDATE admin_notifications SET read_at = NOW() WHERE recipient_id = ? AND read_at IS NULL", userId);
        } catch (DataAccessException ignored) {
            // Keep existing installations usable if notification storage is unavailable.
        }
    }

    public Map<String, Object> dashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("users", count("SELECT COUNT(*) FROM users"));
        stats.put("messages", count("SELECT COUNT(*) FROM messages"));
        stats.put("groups", count("SELECT COUNT(*) FROM chat_groups"));
        stats.put("attachments", count("SELECT COUNT(*) FROM message_attachments"));
        stats.put("activeUsers", count("SELECT COUNT(DISTINCT sender_id) FROM messages WHERE sent_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"));
        stats.put("groupMessages", count("SELECT COUNT(*) FROM group_messages"));
        return stats;
    }

    public List<Map<String, Object>> messageTrend() {
        try {
            return jdbc.queryForList("SELECT DATE(sent_at) AS day, COUNT(*) AS total " +
                    "FROM messages WHERE sent_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                    "GROUP BY DATE(sent_at) ORDER BY day");
        } catch (DataAccessException exception) {
            return List.of();
        }
    }

    public List<Map<String, Object>> recentAccounts() {
        try {
            return jdbc.queryForList("SELECT id, username, email FROM users ORDER BY id DESC LIMIT 5");
        } catch (DataAccessException exception) {
            return List.of();
        }
    }

    private int count(String sql) {
        try {
            Integer value = jdbc.queryForObject(sql, Integer.class);
            return value == null ? 0 : value;
        } catch (DataAccessException exception) {
            return 0;
        }
    }

    public boolean updateAccount(int id, String username, String email, String password) {
        if (id <= 0 || username == null || username.isBlank() || email == null || email.isBlank()) {
            return false;
        }
        try {
            int changed = jdbc.update(
                    "UPDATE users SET username = ?, email = ? WHERE id = ?",
                    username.trim(), email.trim(), id
            );
            if (password != null && !password.isBlank()) {
                changed = jdbc.update(
                        "UPDATE users SET password = ? WHERE id = ?",
                        encoder.encode(password), id
                );
            }
            return changed > 0;
        } catch (DataAccessException exception) {
            return false;
        }
    }
}
