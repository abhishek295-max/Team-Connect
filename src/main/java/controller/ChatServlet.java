package controller;

import dao.MessageDAO;
import dao.UserDAO;
import model.Message;
import model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/views/login.jsp");
            return;
        }

        int currentUserId =
                (Integer) session.getAttribute("userId");
        UserDAO userDAO = new UserDAO();
        MessageDAO messageDAO = new MessageDAO();

        List<User> contacts =
                userDAO.findContacts(currentUserId);

        int requestedContactId = parseContactId(request.getParameter("contactId"));

        User activeContact = null;
        if (requestedContactId > 0 && requestedContactId != currentUserId) {
            activeContact = userDAO.findById(requestedContactId);
        }

        if (activeContact == null && !contacts.isEmpty()) {
            activeContact = contacts.get(0);
        }

        List<Message> messages = activeContact == null
                ? Collections.emptyList()
                : messageDAO.getConversation(currentUserId, activeContact.getId());

        request.setAttribute("contacts", contacts);
        request.setAttribute("activeContact", activeContact);
        request.setAttribute("messages", messages);
        request.setAttribute("contactCount", contacts.size());
        request.setAttribute("messageCount", messages.size());

        RequestDispatcher dispatcher =
                request.getRequestDispatcher("/views/chat.jsp");
        dispatcher.forward(request, response);
    }

    private int parseContactId(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch(NumberFormatException ex) {
            return 0;
        }
    }
}
