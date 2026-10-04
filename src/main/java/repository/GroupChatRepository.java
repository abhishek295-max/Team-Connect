package repository;

import model.GroupChat;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class GroupChatRepository {

    private final JdbcTemplate jdbc;

    public GroupChatRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
        ensureTables();
    }

    private void ensureTables() {
        jdbc.execute("CREATE TABLE IF NOT EXISTS chat_groups (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "name VARCHAR(120) NOT NULL, " +
                "owner_id INT NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
        jdbc.execute("CREATE TABLE IF NOT EXISTS chat_group_members (" +
                "group_id INT NOT NULL, user_id INT NOT NULL, " +
                "PRIMARY KEY (group_id, user_id))");
        jdbc.execute("CREATE TABLE IF NOT EXISTS group_messages (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, group_id INT NOT NULL, " +
                "sender_id INT NOT NULL, message TEXT NOT NULL, " +
                "sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    }

    public List<GroupChat> findForUser(int userId) {
        String sql = "SELECT g.id, g.name, g.owner_id " +
                "FROM chat_groups g " +
                "JOIN chat_group_members m ON m.group_id = g.id " +
                "WHERE m.user_id = ? " +
                "ORDER BY g.name";

        try {
            return jdbc.query(sql, (resultSet, rowNumber) -> new GroupChat(
                    resultSet.getInt("id"),
                    resultSet.getString("name"),
                    resultSet.getInt("owner_id")
            ), userId);
        } catch (DataAccessException ignored) {
            return List.of();
        }
    }

    public GroupChat create(String name, int ownerId) {
        String trimmedName = name.trim();

        jdbc.update(
                "INSERT INTO chat_groups(name, owner_id) VALUES(?, ?)",
                trimmedName,
                ownerId
        );

        Integer groupId = jdbc.queryForObject(
                "SELECT id FROM chat_groups WHERE owner_id = ? AND name = ? ORDER BY id DESC LIMIT 1",
                Integer.class,
                ownerId,
                trimmedName
        );

        jdbc.update(
                "INSERT INTO chat_group_members(group_id, user_id) VALUES(?, ?)",
                groupId,
                ownerId
        );

        return new GroupChat(groupId, trimmedName, ownerId);
    }

    public void addMember(int groupId, int userId) {
        String sql = "INSERT IGNORE INTO chat_group_members(group_id, user_id) VALUES(?, ?)";
        jdbc.update(sql, groupId, userId);
    }

    public boolean isMember(int groupId, int userId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM chat_group_members WHERE group_id = ? AND user_id = ?",
                Integer.class,
                groupId,
                userId
        );
        return count != null && count > 0;
    }

    public List<Map<String, Object>> messages(int groupId) {
        String sql = "SELECT m.id, m.message, m.sent_at, u.username, m.sender_id " +
                "FROM group_messages m " +
                "JOIN users u ON u.id = m.sender_id " +
                "WHERE m.group_id = ? " +
                "ORDER BY m.sent_at, m.id";

        try {
            return jdbc.queryForList(sql, groupId);
        } catch (DataAccessException ignored) {
            return List.of();
        }
    }

    public List<Map<String, Object>> members(int groupId) {
        String sql = "SELECT u.id, u.username, u.email " +
                "FROM chat_group_members gm JOIN users u ON u.id = gm.user_id " +
                "WHERE gm.group_id = ? ORDER BY u.username";
        return jdbc.queryForList(sql, groupId);
    }

    public void addMessage(int groupId, int senderId, String message) {
        String trimmedMessage = message == null ? "" : message.trim();
        String sql = "INSERT INTO group_messages(group_id, sender_id, message) VALUES(?, ?, ?)";
        jdbc.update(sql, groupId, senderId, trimmedMessage);
    }
}
