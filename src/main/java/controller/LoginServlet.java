package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        UserDAO dao = new UserDAO();

        try {

            User user =
                    dao.authenticate(username, password);

            if(user != null) {

                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session =
                        request.getSession(true);

                session.setAttribute(
                        "userId",
                        user.getId());

                session.setAttribute(
                        "username",
                        user.getUsername());

                session.setAttribute(
                        "email",
                        user.getEmail());

                response.sendRedirect(
                        request.getContextPath() + "/chat");

            } else {

                response.sendRedirect(
                        request.getContextPath() +
                                "/views/login.jsp?error=1");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() +
                            "/views/login.jsp?error=1");
        }
    }
}
