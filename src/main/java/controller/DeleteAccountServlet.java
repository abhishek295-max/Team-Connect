package controller;

import dao.UserDAO;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/deleteAccount")
public class DeleteAccountServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        UserDAO dao = new UserDAO();
        boolean deleted = dao.deleteAccount(userId);

        session.invalidate();

        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp?deleted=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp?error=account_delete_failed");
        }
    }
}
