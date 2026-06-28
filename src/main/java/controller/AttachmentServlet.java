package controller;

import dao.MessageDAO;
import model.Message;
import util.AttachmentUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

@WebServlet("/attachment")
public class AttachmentServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int currentUserId = (Integer) session.getAttribute("userId");

        String messageIdValue = request.getParameter("messageId");
        if (messageIdValue == null || messageIdValue.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int messageId;
        try {
            messageId = Integer.parseInt(messageIdValue.trim());
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        if (messageId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        MessageDAO dao = new MessageDAO();
        if (!dao.isParticipant(messageId, currentUserId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Message message = dao.findById(messageId);
        if (message == null || !message.hasAttachment()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path filePath;
        try {
            filePath = AttachmentUtil.resolveStoredPath(message.getAttachmentStoredName());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = resolveContentType(message, filePath);
        boolean inline = shouldDisplayInline(message, contentType);
        byte[] payload = message.getAttachmentData();
        long fileSize;
        boolean fromDatabase = payload != null && payload.length > 0;

        if (fromDatabase) {
            fileSize = payload.length;
        } else {
            if (!AttachmentUtil.isInsideStorage(filePath) || !Files.isRegularFile(filePath)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            fileSize = Files.size(filePath);
        }

        response.resetBuffer();
        response.setContentType(contentType);
        response.setContentLengthLong(fileSize);
        response.setHeader("Cache-Control", "private, max-age=3600");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Content-Disposition",
                buildContentDisposition(inline, message.getAttachmentName()));

        try (OutputStream out = response.getOutputStream()) {
            if (fromDatabase) {
                try (InputStream in = new ByteArrayInputStream(payload)) {
                    in.transferTo(out);
                }
            } else {
                Files.copy(filePath, out);
            }
            out.flush();
        }
    }

    private String resolveContentType(Message message, Path filePath) throws IOException {
        String contentType = message.getAttachmentType();
        if (contentType != null && !contentType.isBlank()) {
            return contentType;
        }

        contentType = Files.probeContentType(filePath);
        if (contentType != null && !contentType.isBlank()) {
            return contentType;
        }

        return "application/octet-stream";
    }

    private boolean shouldDisplayInline(Message message, String contentType) {
        if (AttachmentUtil.isImage(message.getAttachmentKind())) {
            return true;
        }

        return contentType != null && contentType.toLowerCase().startsWith("image/");
    }

    private String buildContentDisposition(boolean inline, String originalName) {
        String safeName = sanitizeFileName(originalName);
        String dispositionType = inline ? "inline" : "attachment";
        return dispositionType + "; filename=\"" + safeName + "\"";
    }

    private String sanitizeFileName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "attachment";
        }

        return name.replace("\"", "")
                .replace("\r", "")
                .replace("\n", "")
                .replace("\\", "_");
    }
}
