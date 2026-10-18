package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.NotificationService;
import com.ute.fooddelivery.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "OrderTrackingController", urlPatterns = {"/order/tracking", "/client/order-tracking"})
public class OrderTrackingController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderService orderService = new OrderService();
    private final NotificationService notifSvc = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            String redirectUrl = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/client/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/client/orders");
            return;
        }

        Order order = orderDAO.getCustomerOrderForTracking(orderId, currentUser.getId());
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/client/orders?error=order_not_found");
            return;
        }

        // Cho phép theo dõi Live Map khi đơn hàng đang ở bước ĐANG GIAO HÀNG (SHIPPING)
        // hoặc ĐÃ GIAO HÀNG (DELIVERED) / khách đã xác nhận nhận hàng thành công
        boolean isTrackingAllowed = "SHIPPING".equalsIgnoreCase(order.getStatus())
                || "DELIVERED".equalsIgnoreCase(order.getStatus())
                || order.isCustomerConfirmed()
                || "confirmed".equalsIgnoreCase(req.getParameter("success"));
        if (!isTrackingAllowed) {
            resp.sendRedirect(req.getContextPath() + "/client/orders?notice=tracking_not_available");
            return;
        }

        req.setAttribute("order", order);
        req.getRequestDispatcher("/WEB-INF/views/client/order-tracking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        String orderIdStr = req.getParameter("orderId");

        if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr.trim());
                if ("confirm_received".equalsIgnoreCase(action)) {
                    Order currentOrder = orderDAO.getOrderById(orderId);
                    if (currentOrder == null || "CANCELLED".equalsIgnoreCase(currentOrder.getStatus()) || "PENDING".equalsIgnoreCase(currentOrder.getStatus())) {
                        resp.sendRedirect(req.getContextPath() + "/order/tracking?orderId=" + orderId + "&error=confirm_failed");
                        return;
                    }

                    boolean confirmed = orderService.confirmCustomerOrder(orderId, currentUser.getId());
                    if (confirmed) {
                        try {
                            Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                            Integer shipperUserId = orderDAO.getDriverUserIdByOrderId(orderId);
                            Order updatedOrder = orderDAO.getOrderById(orderId);
                            if (updatedOrder != null && "DELIVERED".equalsIgnoreCase(updatedOrder.getStatus())) {
                                notifSvc.notifyOrderCompleted(currentUser.getId(), shipperUserId, merchantUserId, orderId);
                            } else {
                                notifSvc.notifyCustomerConfirmed(shipperUserId, merchantUserId, orderId, currentUser.getFullName());
                            }
                        } catch (Exception ignored) {}
                        resp.sendRedirect(req.getContextPath() + "/order/tracking?orderId=" + orderId + "&success=confirmed");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/order/tracking?orderId=" + orderId + "&error=confirm_failed");
                    }
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/client/orders");
    }
}
