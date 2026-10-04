package chat;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.Instant;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Controller
public class ChatSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private static final Set<String> onlineUsers = ConcurrentHashMap.newKeySet();
    private static final Map<Integer, String> lastSeenByUser = new ConcurrentHashMap<>();

    public ChatSocketController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/chat.join")
    public void join(@Payload Map<String, Object> payload) {
        Integer userId = payload.get("userId") != null ? Integer.parseInt(payload.get("userId").toString()) : null;
        String username = payload.get("username") != null ? payload.get("username").toString() : "User";
        if (userId != null) {
            onlineUsers.add(userId + ":" + username);
            lastSeenByUser.remove(userId);
            Map<String, Object> event = Map.of(
                    "type", "presence",
                    "status", "online",
                    "userId", userId,
                    "username", username,
                    "time", Instant.now().toString()
            );
            messagingTemplate.convertAndSend("/topic/presence", event);
            return;
        }

        Map<String, Object> event = Map.of(
                "type", "presence",
                "status", "online",
                "userId", -1,
                "username", username,
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/presence", event);
    }

    @MessageMapping("/chat.leave")
    public void leave(@Payload Map<String, Object> payload) {
        Integer userId = payload.get("userId") != null ? Integer.parseInt(payload.get("userId").toString()) : null;
        String username = payload.get("username") != null ? payload.get("username").toString() : "User";
        if (userId != null) {
            onlineUsers.remove(userId + ":" + username);
            lastSeenByUser.put(userId, Instant.now().toString());
            Map<String, Object> event = Map.of(
                    "type", "presence",
                    "status", "offline",
                    "userId", userId,
                    "username", username,
                    "lastSeen", lastSeenByUser.getOrDefault(userId, Instant.now().toString()),
                    "time", Instant.now().toString()
            );
            messagingTemplate.convertAndSend("/topic/presence", event);
            return;
        }

        Map<String, Object> event = Map.of(
                "type", "presence",
                "status", "offline",
                "userId", -1,
                "username", username,
                "lastSeen", Instant.now().toString(),
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/presence", event);
    }

    @MessageMapping("/chat.typing")
    public void typing(@Payload Map<String, Object> payload) {
        String type = String.valueOf(payload.getOrDefault("type", "typing"));
        Integer userId = payload.get("userId") != null ? Integer.parseInt(payload.get("userId").toString()) : null;
        Integer targetId = payload.get("targetId") != null ? Integer.parseInt(payload.get("targetId").toString()) : null;

        if (userId == null || targetId == null) {
            return;
        }

        Map<String, Object> event = Map.of(
                "type", "typing",
                "userId", userId,
                "targetId", targetId,
                "status", type,
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/typing", event);
    }

    @MessageMapping("/chat.reaction")
    public void reaction(@Payload Map<String, Object> payload) {
        Integer userId = payload.get("userId") != null ? Integer.parseInt(payload.get("userId").toString()) : null;
        Integer messageId = payload.get("messageId") != null ? Integer.parseInt(payload.get("messageId").toString()) : null;
        String emoji = payload.get("emoji") != null ? payload.get("emoji").toString() : "👍";

        if (userId == null || messageId == null) {
            return;
        }

        Map<String, Object> event = Map.of(
                "type", "reaction",
                "userId", userId,
                "messageId", messageId,
                "emoji", emoji,
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/reactions", event);
    }

    @MessageMapping("/chat.poll")
    public void poll(@Payload Map<String, Object> payload) {
        Map<String, Object> event = Map.of(
                "type", "poll",
                "pollId", payload.get("pollId"),
                "question", payload.get("question"),
                "options", payload.get("options"),
                "createdBy", payload.get("userId"),
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/polls", event);
    }

    @MessageMapping("/chat.poll.vote")
    public void pollVote(@Payload Map<String, Object> payload) {
        Map<String, Object> event = Map.of(
                "type", "poll_vote",
                "pollId", payload.get("pollId"),
                "optionIndex", payload.get("optionIndex"),
                "userId", payload.get("userId"),
                "time", Instant.now().toString()
        );
        messagingTemplate.convertAndSend("/topic/polls", event);
    }

    @GetMapping("/api/chat/online")
    @ResponseBody
    public Map<String, Object> onlineUsers() {
        return Map.of("online", onlineUsers.stream().map(v -> v.split(":")[0]).distinct().toList());
    }
}
