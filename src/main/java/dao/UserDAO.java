package dao;

import model.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    public static final class RegistrationResult {
        private final boolean success;
        private final String reason;

        private RegistrationResult(boolean success, String reason) {
            this.success = success;
            this.reason = reason;
        }

        public static RegistrationResult success() {
            return new RegistrationResult(true, null);
        }

        public static RegistrationResult failure(String reason) {
            return new RegistrationResult(false, reason);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getReason() {
            return reason;
        }
    }

    public RegistrationResult registerUser(
            String username,
            String email,
            String password) {

        if (isBlank(username) || isBlank(email) || isBlank(password)) {
            return RegistrationResult.failure("invalid_input");
        }

        String cleanUsername = username.trim();
        String cleanEmail = email.trim();

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                return RegistrationResult.failure("database_unavailable");
            }

            if (usernameExists(con, cleanUsername)) {
                return RegistrationResult.failure("username_taken");
            }

            if (emailExists(con, cleanEmail)) {
                return RegistrationResult.failure("email_taken");
            }

            String hashedPassword =
                    passwordEncoder.encode(password);

            String sql =
                    "INSERT INTO users(username,email,password) VALUES(?,?,?)";

            try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                ps.setString(1, cleanUsername);
                ps.setString(2, cleanEmail);
                ps.setString(3, hashedPassword);

                return ps.executeUpdate() > 0
                        ? RegistrationResult.success()
                        : RegistrationResult.failure("database_error");
            }

        } catch(Exception e) {
            e.printStackTrace();
            return RegistrationResult.failure("database_error");
        }
    }

    public boolean register(
            String username,
            String email,
            String password) {

        return registerUser(username, email, password).isSuccess();
    }

    public User authenticate(
            String username,
            String password) {

        if (isBlank(username) || isBlank(password)) {
            return null;
        }

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                return null;
            }

            String sql =
                    "SELECT id, username, email, password FROM users WHERE username=?";

            try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                ps.setString(1, username.trim());

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String storedPassword =
                                rs.getString("password");
                        User user = mapBasicUser(rs);

                        boolean matches =
                                storedPassword != null &&
                                        (storedPassword.equals(password)
                                                || (storedPassword.startsWith("$2")
                                                && passwordEncoder.matches(
                                                password, storedPassword)));

                        if (matches) {
                            if (storedPassword != null &&
                                    !storedPassword.startsWith("$2")) {
                                upgradePassword(con,
                                        user.getId(),
                                        passwordEncoder.encode(password));
                            }

                            return user;
                        }
                    }
                }
            }

        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public User findById(int userId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return null;
            }

            String sql =
                    "SELECT id, username, email FROM users WHERE id=?";

            try (PreparedStatement ps =
                         con.prepareStatement(sql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapBasicUser(rs);
                    }
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<User> findContacts(int currentUserId) {
        List<User> contacts = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return contacts;
            }

            ensureAttachmentTable(con);

            String sql =
                    "SELECT u.id, u.username, u.email, " +
                    "(SELECT CASE WHEN m.message IS NULL OR TRIM(m.message) = '' " +
                    " THEN CONCAT('[', COALESCE(a.file_kind, 'file'), '] ', COALESCE(a.original_name, 'attachment')) " +
                    " ELSE m.message END " +
                    " FROM messages m " +
                    " LEFT JOIN message_attachments a ON a.message_id = m.id " +
                    " WHERE (m.sender_id = u.id AND m.receiver_id = ?) " +
                    "    OR (m.sender_id = ? AND m.receiver_id = u.id) " +
                    " ORDER BY m.sent_at DESC, m.id DESC " +
                    " LIMIT 1) AS last_message, " +
                    "(SELECT m.sent_at " +
                    " FROM messages m " +
                    " WHERE (m.sender_id = u.id AND m.receiver_id = ?) " +
                    "    OR (m.sender_id = ? AND m.receiver_id = u.id) " +
                    " ORDER BY m.sent_at DESC, m.id DESC " +
                    " LIMIT 1) AS last_message_at " +
                    "FROM users u " +
                    "WHERE u.id <> ? " +
                    "ORDER BY COALESCE(last_message_at, '1970-01-01 00:00:00') DESC, u.username ASC";

            try (PreparedStatement ps =
                         con.prepareStatement(sql)) {
                ps.setInt(1, currentUserId);
                ps.setInt(2, currentUserId);
                ps.setInt(3, currentUserId);
                ps.setInt(4, currentUserId);
                ps.setInt(5, currentUserId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        contacts.add(mapContactWithPreview(rs));
                    }
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return contacts;
    }

    public int countUsers() {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return 0;
            }

            String sql = "SELECT COUNT(*) AS total FROM users";

            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    private boolean usernameExists(Connection con,
                                   String username) throws Exception {

        String sql =
                "SELECT id FROM users WHERE username=?";

        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {
            ps.setString(1, username.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean emailExists(Connection con,
                                String email) throws Exception {

        String sql =
                "SELECT id FROM users WHERE email=?";

        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {
            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void upgradePassword(Connection con,
                                 int userId,
                                 String hashedPassword) throws Exception {

        String sql =
                "UPDATE users SET password=? WHERE id=?";

        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private User mapBasicUser(ResultSet rs) throws Exception {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        return user;
    }

    private User mapContactWithPreview(ResultSet rs) throws Exception {
        User user = mapBasicUser(rs);
        user.setLastMessagePreview(rs.getString("last_message"));
        user.setLastMessageAt(rs.getTimestamp("last_message_at"));
        return user;
    }

    private void ensureAttachmentTable(Connection con) throws Exception {
        String sql =
                "CREATE TABLE IF NOT EXISTS message_attachments (" +
                        "message_id INT PRIMARY KEY, " +
                        "original_name VARCHAR(255) NOT NULL, " +
                        "stored_name VARCHAR(255) NOT NULL, " +
                        "content_type VARCHAR(128) NOT NULL, " +
                        "file_size BIGINT NOT NULL, " +
                        "file_kind VARCHAR(32) NOT NULL, " +
                        "file_data LONGBLOB NULL, " +
                        "CONSTRAINT fk_message_attachment " +
                        "FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE" +
                        ")";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.execute();
        } catch (Exception e) {
            if (e.getMessage() == null || !e.getMessage().toLowerCase().contains("foreign")) {
                throw e;
            }
        }

        try (PreparedStatement ps = con.prepareStatement(
                "ALTER TABLE message_attachments ADD COLUMN file_data LONGBLOB NULL")) {
            ps.execute();
        } catch (Exception ignored) {
            // Column may already exist.
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
