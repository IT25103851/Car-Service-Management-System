package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        UserManager manager = new UserManager();

        AbstractUser loggedInUser = manager.loginUser(user, pass);

        if (loggedInUser != null) {
            HttpSession session = request.getSession();
            session.setAttribute("username", loggedInUser.getUsername());
            session.setAttribute("userRole", loggedInUser.getRole());
            session.setAttribute("userObject", loggedInUser);

            // --- REMEMBER ME LOGIC ---
            String remember = request.getParameter("remember");
            Cookie userCookie = new Cookie("remembered_user", loggedInUser.getUsername());
            if (remember != null && remember.equals("on")) {
                userCookie.setMaxAge(60 * 60 * 24 * 30); // 30 days
            } else {
                userCookie.setMaxAge(0); // Delete cookie
            }
            response.addCookie(userCookie);
            // -------------------------

            if (!loggedInUser.isActive()) {
                response.sendRedirect("login.jsp?error=deactivated");
                return;
            }

            response.sendRedirect(loggedInUser.getDashboardPath());
        } else {
            // FAIL! Wrong password or username
            response.sendRedirect("login.jsp?error=invalid");
        }
    }
}
