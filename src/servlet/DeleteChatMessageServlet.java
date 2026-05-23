package servlet;

import model.ChatManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteChatMessageServlet")
public class DeleteChatMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String messageId = request.getParameter("messageId");
        String appointmentId = request.getParameter("appointmentId");

        if (messageId != null) {
            ChatManager chatManager = new ChatManager();
            chatManager.deleteMessage(messageId, username);
        }

        if (appointmentId != null) {
            response.sendRedirect("appointment_chat.jsp?appId=" + appointmentId);
        } else {
            String role = (String) session.getAttribute("userRole");
            response.sendRedirect("admin".equals(role) ? "manage_appointments.jsp" : "customer_dashboard.jsp");
        }
    }
}
