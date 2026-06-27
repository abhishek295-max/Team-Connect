package controller;

import dao.MessageDAO;
import dao.UserDAO;
import model.User;
import util.AttachmentUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.Collection;

@WebServlet("/sendMessage")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024)
public class SendMessageServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        boolean ajax = isAjax(request);
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            if (ajax) {
                writeJson(response, false, "Please log in again.");
            } else {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            }
            return;
        }

        int sender = (Integer) session.getAttribute("userId");

        String receiverValue;
        String msg;
        Part attachmentPart = null;
        boolean attachmentExpected = false;

        if (isMultipart(request)) {
            try {
                Collection<Part> parts = request.getParts();
                receiverValue = null;
                msg = null;

                for (Part part : parts) {
                    String name = part.getName();
                    if ("receiver".equals(name)) {
                        receiverValue = readPartAsString(part);
                    } else if ("message".equals(name)) {
                        msg = readPartAsString(part);
                    } else if ("attachment".equals(name)) {
                        attachmentPart = part;
                    } else if ("hasAttachment".equals(name)) {
                        attachmentExpected = "1".equals(readPartAsString(part));
                    }
                }
            } catch (ServletException ex) {
                if (ajax) {
                    writeJson(response, false, "Upload could not be processed.");
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Upload could not be processed.");
                }
                return;
            }
        } else {
            request.setCharacterEncoding("UTF-8");
            receiverValue = request.getParameter("receiver");
            msg = request.getParameter("message");
            attachmentExpected = "1".equals(request.getParameter("hasAttachment"));
        }

        int receiver;
        try {
            receiver = Integer.parseInt(receiverValue == null ? "" : receiverValue.trim());
        } catch (Exception ex) {
            if (ajax) {
                writeJson(response, false, "Invalid receiver.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        if (receiver <= 0 || receiver == sender) {
            if (ajax) {
                writeJson(response, false, "Invalid receiver.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        UserDAO userDAO = new UserDAO();
        User receiverUser = userDAO.findById(receiver);
        if (receiverUser == null) {
            if (ajax) {
                writeJson(response, false, "Contact not found.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        if (msg == null) {
            msg = "";
        }

        boolean hasUpload = AttachmentUtil.hasUploadContent(attachmentPart);
        if (attachmentExpected && !hasUpload) {
            if (ajax) {
                writeJson(response, false, "Attachment was not received. Please try again.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Attachment was not received.");
            }
            return;
        }

        AttachmentUtil.StoredAttachment storedAttachment = null;
        if (hasUpload) {
            try {
                storedAttachment = AttachmentUtil.store(attachmentPart);
            } catch (IOException ex) {
                if (ajax) {
                    writeJson(response, false, ex.getMessage());
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
                }
                return;
            }

            if (storedAttachment == null) {
                if (ajax) {
                    writeJson(response, false, "Attachment could not be saved.");
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Attachment could not be saved.");
                }
                return;
            }
        }

        boolean hasText = !msg.trim().isEmpty();
        if (!hasText && storedAttachment == null) {
            if (ajax) {
                writeJson(response, false, "Message or attachment is required.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        MessageDAO dao = new MessageDAO();
        boolean success = dao.sendMessage(sender, receiver, msg, storedAttachment);

        if (ajax) {
            writeJson(response, success, success ? null : "Message could not be saved.");
            return;
        }

        if (!success) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/chat?contactId=" + receiver);
    }

    private String readPartAsString(Part part) throws IOException {
        if (part == null) {
            return null;
        }

        try (InputStream in = part.getInputStream()) {
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    private boolean isMultipart(HttpServletRequest request) {
        String contentType = request.getContentType();
        return contentType != null && contentType.toLowerCase().startsWith("multipart/");
    }

    private boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
    }

    private void writeJson(HttpServletResponse response, boolean success, String error)
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        try (PrintWriter writer = response.getWriter()) {
            if (success) {
                writer.print("{\"success\":true}");
                return;
            }

            writer.print("{\"success\":false,\"error\":\""
                    + escapeJson(error == null ? "Request failed." : error)
                    + "\"}");
        }
    }

    private String escapeJson(String value) {
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
