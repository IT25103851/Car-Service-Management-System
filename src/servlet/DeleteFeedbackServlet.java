package servlet;

import model.FeedbackManager;
import model.Feedback;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteFeedbackServlet")
public class DeleteFeedbackServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUser = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("userRole");
        String feedbackId = request.getParameter("feedbackId");
        
        if (feedbackId != null && !feedbackId.isEmpty()) {
            FeedbackManager manager = new FeedbackManager();
            Feedback fb = manager.getFeedbackById(feedbackId);
            
            if (fb == null) {
                response.sendRedirect("index.jsp");
                return;
            }

            // Security check: Only Admin OR the owner can delete
            boolean isAuthorized = "admin".equals(role) || fb.getCustomerUsername().equals(currentUser);
            
            if (isAuthorized) {
                manager.deleteFeedback(feedbackId);
                String redirect = "admin".equals(role) ? "reviews.jsp?success=deleted" : "customer_dashboard.jsp?success=deleted";
                
                String referer = request.getHeader("Referer");
                if (referer != null && referer.contains("reviews.jsp")) {
                    redirect = "reviews.jsp?success=deleted";
                }
                
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect("login.jsp");
            }
        } else {
            response.sendRedirect("index.jsp");
        }
    }
}
