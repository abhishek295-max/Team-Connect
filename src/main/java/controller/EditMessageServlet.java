package controller;

import dao.MessageDAO;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/editMessage")
public class EditMessageServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int senderId = (Integer) session.getAttribute("userId");

        int messageId;
        try {
            messageId = Integer.parseInt(request.getParameter("messageId"));
        } catch(Exception ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String message = request.getParameter("message");

        MessageDAO dao = new MessageDAO();
        boolean success = dao.updateMessage(messageId, senderId, message);

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        try (PrintWriter writer = response.getWriter()) {
            writer.print(success ? "{\"success\":true}" : "{\"success\":false}");
        }
    }
}
