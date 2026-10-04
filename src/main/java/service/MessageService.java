package service;

import model.Message;
import org.springframework.stereotype.Service;
import repository.MessageRepository;
import util.AttachmentUtil;

import java.util.List;

@Service
public class MessageService {

    private final MessageRepository repository;

    public MessageService(MessageRepository repository) {
        this.repository = repository;
    }

    public List<Message> conversation(int userId, int contactId) {
        return repository.conversation(userId, contactId);
    }

    public boolean send(
            int sender,
            int receiver,
            String text,
            AttachmentUtil.StoredAttachment attachment) {

        return repository.send(sender, receiver, text, attachment);
    }

    public boolean edit(int messageId, int userId, String message) {
        return repository.edit(messageId, userId, message);
    }

    public boolean delete(int messageId, int userId) {
        return repository.delete(messageId, userId);
    }

    public boolean isParticipant(int messageId, int userId) {
        return repository.participant(messageId, userId);
    }

    public Message findById(int messageId) {
        return repository.findById(messageId);
    }
}
