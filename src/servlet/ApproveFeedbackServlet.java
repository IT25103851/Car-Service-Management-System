package servlet;

import model.FeedbackManager;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/ApproveFeedbackServlet")
public class ApproveFeedbackServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        if (!"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String feedbackId = request.getParameter("feedbackId");
        if (feedbackId != null) {
            FeedbackManager manager = new FeedbackManager();
            manager.approveFeedback(feedbackId);
        }

        response.sendRedirect("reviews.jsp?success=approved");
    }
}
