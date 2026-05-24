<%@ page import="model.BookingManager" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }

    String id = request.getParameter("id");
    BookingManager manager = new BookingManager();

    boolean success = false;
    if (id != null && !id.isEmpty()) {
        success = manager.removeAppointment(id);
    }

    if (success) {
        response.sendRedirect("manage_appointments.jsp?deleteSuccess=true");
    } else {
        response.sendRedirect("manage_appointments.jsp?error=deleteFailed");
    }
%>
