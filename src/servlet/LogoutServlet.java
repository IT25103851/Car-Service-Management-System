package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        // 1. Find the user's current session (their VIP wristband)
        // We put "false" so it doesn't accidentally create a new session just to delete it!
        HttpSession session = request.getSession(false);

        // 2. If they have a session, destroy it completely!
        if (session != null) {
            session.invalidate();
        }

        // 3. Send them safely back to the login screen
        response.sendRedirect("login.jsp?success=logout");
    }
}
