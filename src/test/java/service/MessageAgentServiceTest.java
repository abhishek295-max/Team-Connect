package service;

import junit.framework.TestCase;
import model.User;
import util.AttachmentUtil;

import java.util.List;
import java.util.Optional;

public class MessageAgentServiceTest extends TestCase {

    public void testSendsMessageToMatchingContact() {
        User recipient = user(8, "Alex Morgan");
        RecordingMessageService messages = new RecordingMessageService();
        MessageAgentService agent = new MessageAgentService(
                new StubUserService(List.of(recipient)),
                messages);

        Optional<String> reply = agent.command(
                "Send a message to Alex Morgan saying good morning",
                3);

        assertEquals(Optional.of("Sent to Alex Morgan: good morning"), reply);
        assertEquals(3, messages.senderId);
        assertEquals(8, messages.receiverId);
        assertEquals("good morning", messages.text);
    }

    public void testDoesNotSendWhenContactCannotBeMatched() {
        RecordingMessageService messages = new RecordingMessageService();
        MessageAgentService agent = new MessageAgentService(
                new StubUserService(List.of(user(8, "Alex Morgan"))),
                messages);

        Optional<String> reply = agent.command("Tell Jamie good morning", 3);

        assertTrue(reply.get().contains("couldn't find"));
        assertNull(messages.text);
    }

    public void testAsksForMessageWhenBodyIsMissing() {
        RecordingMessageService messages = new RecordingMessageService();
        MessageAgentService agent = new MessageAgentService(
                new StubUserService(List.of(user(8, "Alex"))),
                messages);

        Optional<String> reply = agent.command("Send a message to Alex", 3);

        assertEquals(Optional.of("What message should I send to Alex?"), reply);
        assertNull(messages.text);
    }

    public void testDoesNotGuessBetweenDuplicateUsernames() {
        RecordingMessageService messages = new RecordingMessageService();
        MessageAgentService agent = new MessageAgentService(
                new StubUserService(List.of(user(8, "Alex"), user(9, "Alex"))),
                messages);

        Optional<String> reply = agent.command("Tell Alex good morning", 3);

        assertTrue(reply.get().contains("more than one matching contact"));
        assertNull(messages.text);
    }

    public void testRegularChatIsNotTreatedAsAnAction() {
        MessageAgentService agent = new MessageAgentService(
                new StubUserService(List.of(user(8, "Alex"))),
                new RecordingMessageService());

        assertEquals(Optional.empty(), agent.command("Good morning", 3));
    }

    private User user(int id, String username) {
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        return user;
    }

    private static class StubUserService extends UserService {
        private final List<User> contacts;

        StubUserService(List<User> contacts) {
            super(null, null);
            this.contacts = contacts;
        }

        @Override
        public List<User> contacts(int userId) {
            return contacts;
        }
    }

    private static class RecordingMessageService extends MessageService {
        private int senderId;
        private int receiverId;
        private String text;

        RecordingMessageService() {
            super(null);
        }

        @Override
        public boolean send(
                int sender,
                int receiver,
                String message,
                AttachmentUtil.StoredAttachment attachment) {
            this.senderId = sender;
            this.receiverId = receiver;
            this.text = message;
            return true;
        }
    }
}
