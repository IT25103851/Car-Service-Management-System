package servlet;

import model.ChatMessage;
import model.ChatManager;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/SendChatMessageServlet")
public class SendChatMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("userRole");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String appId = request.getParameter("appointmentId");
        String message = request.getParameter("message");

        if (appId != null && message != null && !message.trim().isEmpty()) {
            model.BookingManager bm = new model.BookingManager();
            model.Appointment app = bm.getAppointmentById(appId);
            
            if (app != null) {
                boolean isChatOpen = ChatManager.isChatWindowOpen(app.getCompletedDate(), 7);
                if (!isChatOpen) {
                    response.sendRedirect("admin".equals(role) ? "manage_appointments.jsp?error=chatExpired" : "customer_dashboard.jsp?error=chatExpired");
                    return;
                }
                
                String timestamp = new SimpleDateFormat("MMM dd, HH:mm").format(new Date());
                ChatMessage chatMsg = new ChatMessage(appId, role, username, message.trim(), timestamp);
                ChatManager chatManager = new ChatManager();
                chatManager.sendMessage(chatMsg);
            }
        }

        response.sendRedirect("appointment_chat.jsp?appId=" + appId);
    }
}
