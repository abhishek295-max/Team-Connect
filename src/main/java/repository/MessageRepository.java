package repository;

import dao.MessageDAO;
import model.Message;
import org.springframework.stereotype.Repository;
import util.AttachmentUtil;

import java.util.List;

@Repository
public class MessageRepository {

    private final MessageDAO dao = new MessageDAO();

    public List<Message> conversation(int userId, int contactId) {
        return dao.getConversation(userId, contactId);
    }

    public boolean send(
            int sender,
            int receiver,
            String text,
            AttachmentUtil.StoredAttachment attachment) {

        return dao.sendMessage(sender, receiver, text, attachment);
    }

    public Message findById(int messageId) {
        return dao.findById(messageId);
    }

    public boolean participant(int messageId, int userId) {
        return dao.isParticipant(messageId, userId);
    }

    public boolean edit(int messageId, int userId, String text) {
        return dao.updateMessage(messageId, userId, text);
    }

    public boolean delete(int messageId, int userId) {
        return dao.deleteMessage(messageId, userId);
    }
}
