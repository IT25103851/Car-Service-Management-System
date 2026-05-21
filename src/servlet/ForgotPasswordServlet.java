package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String step = request.getParameter("step");
        String username = request.getParameter("username");
        UserManager manager = new UserManager();

        if ("1".equals(step)) {
            // STEP 1: Find User
            AbstractUser user = manager.getUserByUsername(username);
            if (user != null) {
                request.setAttribute("step", "2");
                request.setAttribute("user", user);
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            } else {
                response.sendRedirect("forgot_password.jsp?error=notfound");
            }
        } else if ("2".equals(step)) {
            // STEP 2: Verify Answer and Reset
            String securityAnswer = request.getParameter("securityAnswer");
            String newPassword = request.getParameter("newPassword");
            
            AbstractUser user = manager.getUserByUsername(username);
            
            if (user != null) {
                // Professional Case-Insensitive verification
                if (user.getSecurityAnswer().equalsIgnoreCase(securityAnswer)) {
                    manager.updateUser(username, null, null, newPassword);
                    response.sendRedirect("login.jsp?success=reset");
                } else {
                    // Back to step 2 with error
                    request.setAttribute("step", "2");
                    request.setAttribute("user", user);
                    request.setAttribute("error", "wronganswer");
                    response.sendRedirect("forgot_password.jsp?error=wronganswer");
                }
            } else {
                response.sendRedirect("forgot_password.jsp?error=notfound");
            }
        }
    }
}
