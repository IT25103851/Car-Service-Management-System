package servlet;

import model.UserManager;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/ReactivateUserServlet")
public class ReactivateUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        if (username != null) {
            UserManager manager = new UserManager();
            manager.setUserActiveStatus(username, true);
        }
        response.sendRedirect("manage_users.jsp?success=reactivated");
    }
}
