package servlet;

import model.FeedbackManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AdminReplyFeedbackServlet")
public class AdminReplyFeedbackServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        // Security check
        if (!"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String feedbackId = request.getParameter("feedbackId");
        String replyMessage = request.getParameter("adminReply");

        if (feedbackId != null && replyMessage != null && !replyMessage.trim().isEmpty()) {
            FeedbackManager manager = new FeedbackManager();
            manager.updateReply(feedbackId, replyMessage.trim());
        }

        response.sendRedirect("reviews.jsp?success=replied");
    }
}
