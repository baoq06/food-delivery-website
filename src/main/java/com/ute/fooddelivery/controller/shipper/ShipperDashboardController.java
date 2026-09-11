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
    private final com.ute.fooddelivery.service.NotificationService notificationService = new com.ute.fooddelivery.service.NotificationService();

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
        } else if ("updateOrder".equals(action) || "confirmDelivered".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String status = req.getParameter("status");
                if ("confirmDelivered".equals(action) || "DELIVERED".equalsIgnoreCase(status)) {
                    // Shipper xác nhận đã giao hàng tận nơi cho khách
                    if (driver != null) {
                        orderDAO.shipperConfirmDelivered(orderId, driver.getId());
                        Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                        Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                        notificationService.notifyShipperDelivered(customerUserId, merchantUserId, orderId, driver.getName());
                    }
                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                    orderDAO.updateOrderStatus(orderId, "CANCELLED");
                    driverDAO.updateStatusByUserId(user.getId(), "AVAILABLE");
                    if (driver != null) driver.setStatus("AVAILABLE");
                    session.setAttribute("shipperActive", true);
                    session.setAttribute("driverStatus", "AVAILABLE");
                } else if ("SHIPPING".equalsIgnoreCase(status)) {
                    orderDAO.updateOrderStatus(orderId, "SHIPPING");
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
        } else if ("acceptOrder".equals(action) || "acceptAssignedOrder".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                if (driver != null) {
                    // Nếu đơn chưa gán driver này thì gán trước
                    orderDAO.assignDriver(orderId, driver.getId());
                    boolean success = orderDAO.shipperAcceptOrder(orderId, driver.getId());
                    if (success) {
                        driver.setStatus("BUSY");
                        session.setAttribute("shipperActive", true);
                        session.setAttribute("driverStatus", "BUSY");

                        // Bắn thông báo cho Quán và Khách hàng
                        Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                        Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                        notificationService.notifyShipperAccepted(merchantUserId, customerUserId, orderId, driver.getName(), driver.getPhone());

                        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=accept_failed");
            return;
        } else if ("declineOrder".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                if (driver != null) {
                    orderDAO.shipperDeclineOrder(orderId, driver.getId());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
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
            // Đơn đang được gán chờ Shipper xác nhận nhận cuốc
            Order pendingAssignedOrder = orderDAO.getPendingAssignedOrderForDriver(driver.getId());
            req.setAttribute("pendingAssignedOrder", pendingAssignedOrder);

            // Đơn đang giao (SHIPPING)
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
