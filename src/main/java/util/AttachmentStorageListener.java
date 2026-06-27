package util;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;

@WebListener
public class AttachmentStorageListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext context = event.getServletContext();
        String webInfPath = context.getRealPath("/WEB-INF/chat-attachments");

        Path storagePath;
        if (webInfPath != null) {
            storagePath = Paths.get(webInfPath);
        } else {
            storagePath = Paths.get(System.getProperty("java.io.tmpdir"), "online_chat", "attachments");
        }
        // Ensure the directory exists
        try {
            Files.createDirectories(storagePath);
        } catch (IOException e) {
            // Log but continue; AttachmentUtil will attempt to create later
            context.log("Failed to create attachment storage directory: " + e.getMessage());
        }
        AttachmentUtil.configureStorage(storagePath);
        return;
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
    }
}
