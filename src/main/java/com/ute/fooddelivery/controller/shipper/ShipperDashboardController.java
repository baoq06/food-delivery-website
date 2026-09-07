package com.ute.fooddelivery.controller.shipper;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/shipper/dashboard")
public class ShipperDashboardController extends HttpServlet {
    private final DriverDAO driverDAO = new DriverDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.sendRedirect(req.getContextPath() + "/auth");
            return;
        }

        Driver driver = driverDAO.getDriverByUserId(user.getId());
        
        String action = req.getParameter("action");
        if ("toggleStatus".equals(action)) {
            if (driver != null) {
                String newStatus = "AVAILABLE".equals(driver.getStatus()) ? "OFFLINE" : "AVAILABLE";
                driverDAO.updateStatusByUserId(user.getId(), newStatus);
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                return;
            }
        }

        req.setAttribute("driver", driver);
        req.getRequestDispatcher("/WEB-INF/views/shipper/dashboard.jsp").forward(req, resp);
    }
}
