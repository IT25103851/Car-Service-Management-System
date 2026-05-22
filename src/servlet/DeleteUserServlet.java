package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 1. Find out which username the boss clicked "Delete" on
        String targetUsername = request.getParameter("username");

        // 2. If it's not empty, tell the UserManager to erase them!
        if (targetUsername != null && !targetUsername.isEmpty()) {
            UserManager manager = new UserManager();
            manager.deleteUser(targetUsername);
        }

        // 3. Send the boss back to the updated table
        response.sendRedirect("manage_users.jsp?success=deleted");
    }
}
