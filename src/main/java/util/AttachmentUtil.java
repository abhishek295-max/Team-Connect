package util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

public final class AttachmentUtil {

    private static final long MAX_FILE_SIZE = 10L * 1024L * 1024L;
    private static volatile Path configuredStorageDir;
    private static final Set<String> BLOCKED_EXTENSIONS = Set.of(
            "jsp", "jspx", "java", "class", "jar", "war", "exe", "bat", "cmd",
            "sh", "ps1", "vbs", "js", "html", "htm", "php", "cgi", "dll");

    private AttachmentUtil() {
    }

    public static void configureStorage(Path directory) {
        if (directory != null) {
            configuredStorageDir = directory.toAbsolutePath().normalize();
        }
    }

    public static String extractFileName(Part part) {
        if (part == null) {
            return null;
        }

        String submitted = part.getSubmittedFileName();
        if (submitted != null && !submitted.trim().isEmpty()) {
            return submitted.trim();
        }

        String disposition = part.getHeader("content-disposition");
        if (disposition == null || disposition.isEmpty()) {
            return null;
        }

        for (String token : disposition.split(";")) {
            String trimmed = token.trim();
            if (!trimmed.regionMatches(true, 0, "filename=", 0, 9)) {
                continue;
            }

            String value = trimmed.substring(9).trim();
            if (value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) {
                value = value.substring(1, value.length() - 1);
            }

            if (!value.isEmpty()) {
                return value;
            }
        }

        return null;
    }

    public static boolean hasUploadContent(Part part) {
        if (part == null) {
            return false;
        }

        if (extractFileName(part) != null) {
            return true;
        }

        try {
            return part.getSize() > 0;
        } catch (Exception ex) {
            return false;
        }
    }

    public static StoredAttachment store(Part part) throws IOException {
        if (part == null) {
            return null;
        }

        String submittedName = extractFileName(part);
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String originalName = safeFileName(submittedName);
        String extension = extension(originalName);

        if (!extension.isEmpty() && BLOCKED_EXTENSIONS.contains(extension.substring(1))) {
            throw new IOException("Attachment type is not allowed.");
        }

        String contentType = part.getContentType();
        String kind = (contentType != null && contentType.toLowerCase(Locale.ENGLISH).startsWith("image/"))
                ? "image"
                : "file";

        Path storageDir = storageDir();
        Files.createDirectories(storageDir);

        String storedName = UUID.randomUUID().toString().replace("-", "") + extension;
        Path target = storageDir.resolve(storedName).normalize();

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, target);
        }

        long fileSize = part.getSize();
        if (fileSize <= 0) {
            fileSize = Files.size(target);
        }

        if (fileSize > MAX_FILE_SIZE) {
            Files.deleteIfExists(target);
            throw new IOException("Attachment exceeds the maximum size.");
        }

        return new StoredAttachment(
                originalName,
                storedName,
                contentType == null || contentType.trim().isEmpty()
                        ? "application/octet-stream"
                        : contentType,
                fileSize,
                kind);
    }

    public static Path resolveStoredPath(String storedName) {
        if (storedName == null || storedName.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing stored file name.");
        }

        String safeName = Paths.get(storedName.replace('\\', '/')).getFileName().toString();
        if (safeName.isEmpty() || "..".equals(safeName)) {
            throw new IllegalArgumentException("Invalid stored file name.");
        }

        return storageDir().resolve(safeName).normalize();
    }

    public static boolean isInsideStorage(Path filePath) {
        try {
            Path base = storageDir().toAbsolutePath().normalize();
            Path resolved = filePath.toAbsolutePath().normalize();
            return resolved.startsWith(base);
        } catch (Exception ex) {
            return false;
        }
    }

    public static String downloadUrl(int messageId) {
        return "/attachment?messageId=" + messageId;
    }

    public static String previewLabel(String kind, String fileName) {
        String safeName = fileName == null || fileName.trim().isEmpty() ? "attachment" : fileName;
        if ("image".equals(kind)) {
            return "Photo: " + safeName;
        }
        return "File: " + safeName;
    }

    public static String humanSize(long size) {
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

    public static boolean isImage(String kind) {
        return "image".equalsIgnoreCase(kind);
    }

    private static Path storageDir() {
        if (configuredStorageDir != null) {
            return configuredStorageDir;
        }

        return Paths.get(System.getProperty("user.home"), ".online_chat", "attachments");
    }

    private static String safeFileName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "attachment";
        }

        String normalized = name.replace('\\', '/');
        int index = normalized.lastIndexOf('/');
        String fileName = index >= 0 ? normalized.substring(index + 1) : normalized;

        String cleaned = fileName.replaceAll("[\\r\\n\\t]", "_");
        cleaned = cleaned.replace('\0', '_');
        return cleaned;
    }

    private static String extension(String fileName) {
        if (fileName == null) {
            return "";
        }

        int index = fileName.lastIndexOf('.');
        if (index < 0 || index == fileName.length() - 1) {
            return "";
        }

        return fileName.substring(index).toLowerCase(Locale.ENGLISH);
    }

    public static final class StoredAttachment {
        private final String originalName;
        private final String storedName;
        private final String contentType;
        private final long fileSize;
        private final String kind;

        public StoredAttachment(String originalName,
                                String storedName,
                                String contentType,
                                long fileSize,
                                String kind) {
            this.originalName = originalName;
            this.storedName = storedName;
            this.contentType = contentType;
            this.fileSize = fileSize;
            this.kind = kind;
        }

        public String getOriginalName() {
            return originalName;
        }

        public String getStoredName() {
            return storedName;
        }

        public String getContentType() {
            return contentType;
        }

        public long getFileSize() {
            return fileSize;
        }

        public String getKind() {
            return kind;
        }
    }
}
