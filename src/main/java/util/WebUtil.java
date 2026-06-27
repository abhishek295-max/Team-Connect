package util;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class WebUtil {

    private static final DateTimeFormatter MESSAGE_TIME_FORMAT =
            DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a", Locale.ENGLISH);

    private WebUtil() {
    }

    public static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder(value.length() + 16);

        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);

            switch (ch) {
                case '&' -> builder.append("&amp;");
                case '<' -> builder.append("&lt;");
                case '>' -> builder.append("&gt;");
                case '"' -> builder.append("&quot;");
                case '\'' -> builder.append("&#39;");
                default -> builder.append(ch);
            }
        }

        return builder.toString();
    }

    public static String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder(value.length() + 16);

        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '"' -> builder.append("\\\"");
                case '\\' -> builder.append("\\\\");
                case '\b' -> builder.append("\\b");
                case '\f' -> builder.append("\\f");
                case '\n' -> builder.append("\\n");
                case '\r' -> builder.append("\\r");
                case '\t' -> builder.append("\\t");
                default -> {
                    if (ch < 0x20) {
                        builder.append(String.format("\\u%04x", (int) ch));
                    } else {
                        builder.append(ch);
                    }
                }
            }
        }

        return builder.toString();
    }

    public static String initials(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "?";
        }

        String[] parts = value.trim().split("\\s+");

        if (parts.length == 1) {
            String text = parts[0];
            return text.length() >= 2
                    ? text.substring(0, 2).toUpperCase(Locale.ENGLISH)
                    : text.substring(0, 1).toUpperCase(Locale.ENGLISH);
        }

        return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
                .toUpperCase(Locale.ENGLISH);
    }

    public static String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }

        return timestamp.toLocalDateTime().format(MESSAGE_TIME_FORMAT);
    }

    public static String humanReadableSize(long size) {
        if (size < 1024) {
            return size + " B";
        }

        double kb = size / 1024.0;
        if (kb < 1024) {
            return String.format(Locale.ENGLISH, "%.1f KB", kb);
        }

        double mb = kb / 1024.0;
        return String.format(Locale.ENGLISH, "%.1f MB", mb);
    }
}
