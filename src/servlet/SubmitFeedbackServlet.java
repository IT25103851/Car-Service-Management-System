package servlet;

import model.Feedback;
import model.FeedbackManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/SubmitFeedbackServlet")
public class SubmitFeedbackServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String message = request.getParameter("message");
        if (message == null || message.trim().isEmpty()) {
            message = "No comments provided.";
        }
        
        int rating = 5;
        try { if(request.getParameter("rating") != null) rating = Integer.parseInt(request.getParameter("rating")); } catch (Exception ignored) {}
        
        String serviceRef = request.getParameter("serviceRef");
        if (serviceRef == null || serviceRef.trim().isEmpty()) serviceRef = "General Rating";

        String dateSubmitted = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());

        Feedback newFeedback = new Feedback(username, message, dateSubmitted, rating, serviceRef);
        FeedbackManager manager = new FeedbackManager();
        manager.saveFeedback(newFeedback);

        response.sendRedirect("customer_dashboard.jsp?feedbackSuccess=true");
    }
}
