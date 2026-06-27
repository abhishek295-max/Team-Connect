package util;

import model.Message;
import model.User;

public final class JsonUtil {

    private JsonUtil() {
    }

    public static String userJson(User user) {
        if (user == null) {
            return "null";
        }

        return new StringBuilder()
                .append("{\"id\":")
                .append(user.getId())
                .append(",\"username\":\"")
                .append(WebUtil.escapeJson(user.getUsername()))
                .append("\",\"email\":\"")
                .append(WebUtil.escapeJson(user.getEmail()))
                .append("\"}")
                .toString();
    }

    public static String messageJson(Message message) {
        if (message == null) {
            return "null";
        }

        String attachmentUrl = message.hasAttachment()
                ? AttachmentUtil.downloadUrl(message.getId())
                : "";

        return new StringBuilder()
                .append("{\"id\":")
                .append(message.getId())
                .append(",\"senderId\":")
                .append(message.getSenderId())
                .append(",\"receiverId\":")
                .append(message.getReceiverId())
                .append(",\"message\":\"")
                .append(WebUtil.escapeJson(message.getMessage()))
                .append("\",\"sentAt\":\"")
                .append(WebUtil.escapeJson(WebUtil.formatTimestamp(message.getSentAt())))
                .append("\",\"attachmentName\":\"")
                .append(WebUtil.escapeJson(message.getAttachmentName()))
                .append("\",\"attachmentKind\":\"")
                .append(WebUtil.escapeJson(message.getAttachmentKind()))
                .append("\",\"attachmentType\":\"")
                .append(WebUtil.escapeJson(message.getAttachmentType()))
                .append("\",\"attachmentUrl\":\"")
                .append(WebUtil.escapeJson(attachmentUrl))
                .append("\",\"attachmentSize\":\"")
                .append(message.getAttachmentSize())
                .append("\"}")
                .toString();
    }
}
