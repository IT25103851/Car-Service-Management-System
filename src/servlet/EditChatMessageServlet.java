package servlet;

import model.ChatManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/EditChatMessageServlet")
public class EditChatMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String messageId = request.getParameter("messageId");
        String message = request.getParameter("message");
        String appointmentId = request.getParameter("appointmentId");

        if (messageId != null && message != null && !message.trim().isEmpty()) {
            ChatManager chatManager = new ChatManager();
            chatManager.updateMessage(messageId, message, username);
        }

        if (appointmentId != null) {
            response.sendRedirect("appointment_chat.jsp?appId=" + appointmentId);
        } else {
            String role = (String) session.getAttribute("userRole");
            response.sendRedirect("admin".equals(role) ? "manage_appointments.jsp" : "customer_dashboard.jsp");
        }
    }
}
