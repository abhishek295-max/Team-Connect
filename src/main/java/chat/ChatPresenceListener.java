package chat;

import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ChatPresenceListener implements HttpSessionListener {
    public static final Map<Integer, String> lastSeen = new ConcurrentHashMap<>();

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        Object userId = se.getSession().getAttribute("userId");
        if (userId != null) {
            lastSeen.put(Integer.parseInt(userId.toString()), Instant.now().toString());
        }
    }
}

