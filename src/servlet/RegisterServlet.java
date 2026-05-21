package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // SECURITY BOUNCER: Only authenticated Admins can register new users!
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 1. Grab the data from the form
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String badge = request.getParameter("role");
        String name = request.getParameter("name");
        String sq = request.getParameter("securityQuestion");
        String sa = request.getParameter("securityAnswer");

        // Validate inputs
        if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty() || badge == null || sq == null || sa == null) {
            response.sendRedirect("manage_users.jsp?error=empty");
            return;
        }

        // Validate password strength
        if (!UserManager.isValidPassword(pass)) {
            response.sendRedirect("manage_users.jsp?error=weakpassword");
            return;
        }

        if (name == null || name.trim().isEmpty()) name = user;

        // 2. Box them up into the right User type
        UserManager manager = new UserManager();

        AbstractUser newUser;
        if ("admin".equals(badge)) {
            newUser = new AdminUser(user, pass, name, sq, sa);
        } else {
            newUser = new CustomerUser(user, pass, name, sq, sa);
        }

        // 3. Save to file
        boolean success = manager.registerUser(newUser);

        if (success) {
            response.sendRedirect("manage_users.jsp?success=created");
        } else {
            response.sendRedirect("manage_users.jsp?error=exists");
        }
    }
}
