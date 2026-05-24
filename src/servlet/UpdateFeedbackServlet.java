package servlet;

import model.Feedback;
import model.FeedbackManager;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateFeedbackServlet")
public class UpdateFeedbackServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUser = (String) session.getAttribute("username");
        String feedbackId = request.getParameter("feedbackId");
        String message = request.getParameter("message");
        int rating = 5;
        try { rating = Integer.parseInt(request.getParameter("rating")); } catch (Exception ignored) {}

        if (feedbackId != null && !feedbackId.isEmpty()) {
            FeedbackManager manager = new FeedbackManager();
            Feedback fb = manager.getFeedbackById(feedbackId);

            if (fb != null && fb.getCustomerUsername().equals(currentUser)) {
                // Update fields
                fb.setMessage(message != null ? message : "");
                fb.setRating(rating);
                fb.setApproved(false); // Reset approval status on edit
                
                manager.updateFeedback(fb);
                
                String referer = request.getHeader("Referer");
                if (referer != null && referer.contains("reviews.jsp")) {
                    response.sendRedirect("reviews.jsp?success=updated");
                } else {
                    response.sendRedirect("customer_dashboard.jsp?feedbackUpdated=true");
                }
            } else {
                response.sendRedirect("customer_dashboard.jsp?error=unauthorized");
            }
        } else {
            response.sendRedirect("customer_dashboard.jsp");
        }
    }
}
