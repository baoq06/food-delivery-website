package com.ute.fooddelivery.controller.shipper;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/shipper/dashboard")
public class ShipperDashboardController extends HttpServlet {
    private final DriverDAO driverDAO = new DriverDAO();
    private final OrderDAO orderDAO = new OrderDAO();

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
        } else if ("updateOrder".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String status = req.getParameter("status");
            orderDAO.updateOrderStatus(orderId, status);
            // Nếu giao xong hoặc bom hàng, đổi tài xế về AVAILABLE
            if ("DELIVERED".equals(status) || "CANCELLED".equals(status)) {
                driverDAO.updateStatusByUserId(user.getId(), "AVAILABLE");
            } else if ("SHIPPING".equals(status)) {
                driverDAO.updateStatusByUserId(user.getId(), "BUSY");
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
            return;
        } else if ("acceptOrder".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            if (driver != null && "AVAILABLE".equals(driver.getStatus())) {
                boolean success = orderDAO.assignDriver(orderId, driver.getId());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                    return;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=accept_failed");
            return;
        }

        // Lấy đơn hàng hiện tại đang SHIPPING của tài xế
        if (driver != null) {
            List<Order> activeOrders = orderDAO.getOrdersByDriver(driver.getId(), "SHIPPING");
            if (!activeOrders.isEmpty()) {
                req.setAttribute("activeOrder", activeOrders.get(0));
            }
            
            // Lấy Ví Tài Xế (Thu nhập)
            java.util.Map<String, Object> earnings = orderDAO.getDriverEarnings(driver.getId());
            req.setAttribute("wallet", earnings);
            req.setAttribute("driver", driver);
        }

        req.getRequestDispatcher("/WEB-INF/views/shipper/dashboard.jsp").forward(req, resp);
    }
}
