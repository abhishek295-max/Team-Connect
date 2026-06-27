package controller;

import dao.MessageDAO;
import dao.UserDAO;
import model.Message;
import model.User;
import util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/conversation")
public class ConversationServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int currentUserId =
                (Integer) session.getAttribute("userId");

        int contactId;
        try {
            contactId = Integer.parseInt(request.getParameter("contactId"));
        } catch(Exception ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User contact = userDAO.findById(contactId);

        if (contact == null || contact.getId() == currentUserId) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        MessageDAO messageDAO = new MessageDAO();
        List<Message> messages =
                messageDAO.getConversation(currentUserId, contactId);

        StringBuilder json = new StringBuilder();
        json.append("{\"contact\":")
                .append(JsonUtil.userJson(contact))
                .append(",\"messageCount\":")
                .append(messages.size())
                .append(",\"messages\":[");

        for (int i = 0; i < messages.size(); i++) {
            if (i > 0) {
                json.append(',');
            }
            json.append(JsonUtil.messageJson(messages.get(i)));
        }

        json.append("]}");

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        try (PrintWriter writer = response.getWriter()) {
            writer.print(json);
        }
    }
}
