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
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ShipperDashboardController", urlPatterns = {"/shipper/dashboard", "/shipper/history"})
public class ShipperDashboardController extends HttpServlet {
    private final DriverDAO driverDAO = new DriverDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        Driver driver = driverDAO.getOrCreateDriverForUser(user);
        
        String action = req.getParameter("action");
        if ("toggleStatus".equals(action)) {
            if (driver != null) {
                if ("BUSY".equalsIgnoreCase(driver.getStatus())) {
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=busy_cannot_toggle");
                    return;
                }
                String newStatus = "AVAILABLE".equalsIgnoreCase(driver.getStatus()) ? "OFFLINE" : "AVAILABLE";
                driverDAO.updateStatusByUserId(user.getId(), newStatus);
                driver.setStatus(newStatus);
                boolean isNowActive = "AVAILABLE".equalsIgnoreCase(newStatus);
                session.setAttribute("shipperActive", isNowActive);
                session.setAttribute("driverStatus", newStatus);
                if (isNowActive) {
                    session.removeAttribute("cart");
                }
                String redirect = req.getParameter("redirect");
                if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
                    resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                return;
            }
        } else if ("updateOrder".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String status = req.getParameter("status");
                orderDAO.updateOrderStatus(orderId, status);
                // Nếu giao xong hoặc bom hàng, đổi tài xế về AVAILABLE
                if ("DELIVERED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) {
                    driverDAO.updateStatusByUserId(user.getId(), "AVAILABLE");
                    if (driver != null) driver.setStatus("AVAILABLE");
                    session.setAttribute("shipperActive", true);
                    session.setAttribute("driverStatus", "AVAILABLE");
                } else if ("SHIPPING".equalsIgnoreCase(status)) {
                    driverDAO.updateStatusByUserId(user.getId(), "BUSY");
                    if (driver != null) driver.setStatus("BUSY");
                    session.setAttribute("shipperActive", true);
                    session.setAttribute("driverStatus", "BUSY");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
            return;
        } else if ("acceptOrder".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                if (driver != null && "AVAILABLE".equalsIgnoreCase(driver.getStatus())) {
                    boolean success = orderDAO.assignDriver(orderId, driver.getId());
                    if (success) {
                        driver.setStatus("BUSY");
                        session.setAttribute("shipperActive", true);
                        session.setAttribute("driverStatus", "BUSY");
                        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=accept_failed");
            return;
        }

        // Đồng bộ trạng thái hiện tại vào session
        boolean isCurrentActive = driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus());
        session.setAttribute("shipperActive", isCurrentActive);
        session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
        if (isCurrentActive) {
            session.removeAttribute("cart");
        }

        // Xác định tab đang xem
        String servletPath = req.getServletPath();
        String tab = req.getParameter("tab");
        if ("/shipper/history".equalsIgnoreCase(servletPath) || "history".equalsIgnoreCase(tab)) {
            req.setAttribute("activeTab", "history");
        } else {
            req.setAttribute("activeTab", "dispatch");
        }

        if (driver != null) {
            // Đơn đang giao
            List<Order> activeOrders = orderDAO.getOrdersByDriver(driver.getId(), "SHIPPING");
            if (!activeOrders.isEmpty()) {
                req.setAttribute("activeOrder", activeOrders.get(0));
            }
            
            // Toàn bộ lịch sử các chuyến xe mà shipper này đã nhận
            List<Order> allDeliveries = orderDAO.getOrdersByDriver(driver.getId(), "ALL");
            int totalDeliveryCount = allDeliveries.size();
            int deliveredCount = 0;
            int cancelledCount = 0;
            int shippingCount = 0;
            for (Order o : allDeliveries) {
                if ("DELIVERED".equalsIgnoreCase(o.getStatus())) deliveredCount++;
                else if ("CANCELLED".equalsIgnoreCase(o.getStatus())) cancelledCount++;
                else if ("SHIPPING".equalsIgnoreCase(o.getStatus())) shippingCount++;
            }
            req.setAttribute("totalDeliveryCount", totalDeliveryCount);
            req.setAttribute("deliveredCount", deliveredCount);
            req.setAttribute("cancelledCount", cancelledCount);
            req.setAttribute("shippingCount", shippingCount);

            String statusFilter = req.getParameter("statusFilter");
            if (statusFilter == null || statusFilter.trim().isEmpty()) {
                statusFilter = "ALL";
            }
            req.setAttribute("currentStatusFilter", statusFilter);

            if ("ALL".equalsIgnoreCase(statusFilter)) {
                req.setAttribute("deliveryHistory", allDeliveries);
            } else {
                req.setAttribute("deliveryHistory", orderDAO.getOrdersByDriver(driver.getId(), statusFilter));
            }

            // Thống kê ví tài xế
            java.util.Map<String, Object> earnings = orderDAO.getDriverEarnings(driver.getId());
            req.setAttribute("wallet", earnings);
            req.setAttribute("driver", driver);
        }

        req.getRequestDispatcher("/WEB-INF/views/shipper/dashboard.jsp").forward(req, resp);
    }
}
