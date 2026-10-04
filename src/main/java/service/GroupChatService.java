package service;

import model.GroupChat;
import org.springframework.stereotype.Service;
import repository.GroupChatRepository;

import java.util.List;
import java.util.Map;

@Service
public class GroupChatService {

    private final GroupChatRepository repository;

    public GroupChatService(GroupChatRepository repository) {
        this.repository = repository;
    }

    public List<GroupChat> groups(int userId) {
        return repository.findForUser(userId);
    }

    public GroupChat create(String name, int ownerId) {
        return repository.create(name, ownerId);
    }

    public void addMember(int groupId, int userId) {
        repository.addMember(groupId, userId);
    }

    public boolean isMember(int groupId, int userId) {
        return repository.isMember(groupId, userId);
    }

    public List<Map<String, Object>> messages(int groupId) {
        return repository.messages(groupId);
    }

    public List<Map<String, Object>> members(int groupId) {
        return repository.members(groupId);
    }

    public void send(int groupId, int senderId, String message) {
        repository.addMessage(groupId, senderId, message);
    }
}
