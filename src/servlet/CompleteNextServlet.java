package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/CompleteNextServlet")
public class CompleteNextServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        BookingManager manager = new BookingManager();

        // This pops the First-In vehicle and formally routes it into the Garage Queue (Under Maintenance)
        manager.moveToGarage();

        // Redirect the admin instantly into the Garage portal to begin working on the car!
        response.sendRedirect("in_garage.jsp");
    }
}
