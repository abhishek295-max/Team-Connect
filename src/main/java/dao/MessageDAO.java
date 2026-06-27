package dao;

import model.Message;
import util.AttachmentUtil;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    public boolean sendMessage(
            int sender,
            int receiver,
            String message) {

        return sendMessage(sender, receiver, message, null);
    }

    public boolean sendMessage(
            int sender,
            int receiver,
            String message,
            AttachmentUtil.StoredAttachment attachment) {

        boolean hasText = message != null && !message.trim().isEmpty();
        boolean hasAttachment = attachment != null;

        if (!hasText && !hasAttachment) {
            return false;
        }

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                return false;
            }

            ensureAttachmentTable(con);
            con.setAutoCommit(false);

            String sql =
                    "INSERT INTO messages(sender_id,receiver_id,message) VALUES(?,?,?)";

            try (PreparedStatement ps =
                         con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, sender);
                ps.setInt(2, receiver);
                ps.setString(3, hasText ? message.trim() : "");

                int inserted = ps.executeUpdate();
                if (inserted <= 0) {
                    con.rollback();
                    deleteStoredFile(attachment);
                    return false;
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        con.rollback();
                        deleteStoredFile(attachment);
                        return false;
                    }

                    int messageId = keys.getInt(1);
                    if (hasAttachment) {
                        if (!insertAttachment(con, messageId, attachment)) {
                            con.rollback();
                            deleteStoredFile(attachment);
                            return false;
                        }
                    }
                }

                con.commit();
                return true;
            }

        } catch(Exception e) {
            e.printStackTrace();
            deleteStoredFile(attachment);
            return false;
        }
    }

    public List<Message> getConversation(
            int userA,
            int userB) {

        List<Message> messages = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                return messages;
            }

            ensureAttachmentTable(con);

            String sql =
                    "SELECT m.id, m.sender_id, m.receiver_id, m.message, m.sent_at, " +
                    "a.original_name, a.stored_name, a.content_type, a.file_size, a.file_kind " +
                    "FROM messages " +
                    "m LEFT JOIN message_attachments a ON a.message_id = m.id " +
                    "WHERE (m.sender_id=? AND m.receiver_id=?) " +
                    "OR (m.sender_id=? AND m.receiver_id=?) " +
                    "ORDER BY m.sent_at ASC, m.id ASC";

            try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                ps.setInt(1, userA);
                ps.setInt(2, userB);
                ps.setInt(3, userB);
                ps.setInt(4, userA);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Message message = new Message();
                        message.setId(rs.getInt("id"));
                        message.setSenderId(rs.getInt("sender_id"));
                        message.setReceiverId(rs.getInt("receiver_id"));
                        message.setMessage(rs.getString("message"));
                        message.setSentAt(rs.getTimestamp("sent_at"));
                        message.setAttachmentName(rs.getString("original_name"));
                        message.setAttachmentStoredName(rs.getString("stored_name"));
                        message.setAttachmentType(rs.getString("content_type"));
                        message.setAttachmentSize(rs.getLong("file_size"));
                        message.setAttachmentKind(rs.getString("file_kind"));
                        messages.add(message);
                    }
                }
            }

        } catch(Exception e) {
            e.printStackTrace();
        }

        return messages;
    }

    public boolean updateMessage(
            int messageId,
            int senderId,
            String message) {

        if (message == null || message.trim().isEmpty()) {
            return false;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return false;
            }

            ensureAttachmentTable(con);

            String sql =
                    "UPDATE messages SET message=? WHERE id=? AND sender_id=?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, message.trim());
                ps.setInt(2, messageId);
                ps.setInt(3, senderId);
                return ps.executeUpdate() > 0;
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteMessage(
            int messageId,
            int senderId) {

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return false;
            }

            ensureAttachmentTable(con);

            Message existing = findById(messageId);
            boolean hasAttachment = existing != null && existing.hasAttachment();

            String sql =
                    "DELETE FROM messages WHERE id=? AND sender_id=?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, messageId);
                ps.setInt(2, senderId);
                boolean success = ps.executeUpdate() > 0;
                if (success && hasAttachment) {
                    try {
                        java.nio.file.Files.deleteIfExists(
                                AttachmentUtil.resolveStoredPath(existing.getAttachmentStoredName()));
                    } catch(Exception ignored) {
                    }
                }
                return success;
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Message findById(int messageId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return null;
            }

            ensureAttachmentTable(con);

            String sql =
                    "SELECT m.id, m.sender_id, m.receiver_id, m.message, m.sent_at, " +
                            "a.original_name, a.stored_name, a.content_type, a.file_size, a.file_kind " +
                            "FROM messages m " +
                            "LEFT JOIN message_attachments a ON a.message_id = m.id " +
                            "WHERE m.id=?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, messageId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapMessage(rs);
                    }
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean isParticipant(int messageId, int userId) {
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                return false;
            }

            String sql =
                    "SELECT id FROM messages WHERE id=? AND (sender_id=? OR receiver_id=?)";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, messageId);
                ps.setInt(2, userId);
                ps.setInt(3, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private boolean insertAttachment(Connection con,
                                     int messageId,
                                     AttachmentUtil.StoredAttachment attachment) throws Exception {
        String sql =
                "INSERT INTO message_attachments(message_id, original_name, stored_name, content_type, file_size, file_kind) " +
                "VALUES(?,?,?,?,?,?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            ps.setString(2, attachment.getOriginalName());
            ps.setString(3, attachment.getStoredName());
            ps.setString(4, attachment.getContentType());
            ps.setLong(5, attachment.getFileSize());
            ps.setString(6, attachment.getKind());
            return ps.executeUpdate() > 0;
        }
    }

    private void ensureAttachmentTable(Connection con) throws Exception {
        String sql =
                "CREATE TABLE IF NOT EXISTS message_attachments (" +
                        "message_id INT PRIMARY KEY, " +
                        "original_name VARCHAR(255) NOT NULL, " +
                        "stored_name VARCHAR(255) NOT NULL, " +
                        "content_type VARCHAR(128) NOT NULL, " +
                        "file_size BIGINT NOT NULL, " +
                        "file_kind VARCHAR(32) NOT NULL" +
                        ")";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.execute();
        }

        try (PreparedStatement ps = con.prepareStatement(
                "ALTER TABLE message_attachments " +
                        "ADD CONSTRAINT fk_message_attachment " +
                        "FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE")) {
            ps.execute();
        } catch (Exception ignored) {
            // FK may already exist or be unsupported in this database setup.
        }
    }

    private void deleteStoredFile(AttachmentUtil.StoredAttachment attachment) {
        if (attachment == null) {
            return;
        }

        try {
            java.nio.file.Files.deleteIfExists(
                    AttachmentUtil.resolveStoredPath(attachment.getStoredName()));
        } catch (Exception ignored) {
        }
    }

    private Message mapMessage(ResultSet rs) throws Exception {
        Message message = new Message();
        message.setId(rs.getInt("id"));
        message.setSenderId(rs.getInt("sender_id"));
        message.setReceiverId(rs.getInt("receiver_id"));
        message.setMessage(rs.getString("message"));
        message.setSentAt(rs.getTimestamp("sent_at"));
        message.setAttachmentName(rs.getString("original_name"));
        message.setAttachmentStoredName(rs.getString("stored_name"));
        message.setAttachmentType(rs.getString("content_type"));
        message.setAttachmentSize(rs.getLong("file_size"));
        message.setAttachmentKind(rs.getString("file_kind"));
        return message;
    }
}
