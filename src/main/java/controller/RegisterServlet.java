package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;


@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username =
                request.getParameter("username");

        String email =
                request.getParameter("email");

        String password =
                request.getParameter("password");

        UserDAO dao = new UserDAO();
        UserDAO.RegistrationResult result =
                dao.registerUser(username, email, password);

        if(result.isSuccess()) {

            response.sendRedirect(
                    request.getContextPath() +
                            "/views/login.jsp?registered=1");

        } else {

            String reason = result.getReason();
            if (reason == null || reason.isEmpty()) {
                reason = "database_error";
            }

            response.sendRedirect(
                    request.getContextPath() +
                            "/views/register.jsp?error=" + reason);
        }
    }
}
