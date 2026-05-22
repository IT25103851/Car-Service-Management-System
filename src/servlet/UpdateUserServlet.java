package servlet;

import model.UserManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/UpdateUserServlet")
public class UpdateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Admin session check
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String newRole = request.getParameter("role");
        String newPassword = request.getParameter("password");

        if (username != null && !username.trim().isEmpty()) {
            // Guard: prevent demoting the master admin to customer
            if ("Admin".equals(username) && "customer".equals(newRole)) {
                response.sendRedirect("manage_users.jsp?error=protected");
                return;
            }

            if (newPassword != null && !newPassword.trim().isEmpty()) {
                if (!UserManager.isValidPassword(newPassword)) {
                    response.sendRedirect("manage_users.jsp?error=weakpassword");
                    return;
                }
            }

            UserManager manager = new UserManager();
            manager.updateUser(username, name, newRole, newPassword);
        }

        response.sendRedirect("manage_users.jsp?success=updated");
    }
}
