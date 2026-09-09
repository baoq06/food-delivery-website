package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantOrderController", urlPatterns = {"/merchant/orders"})
public class MerchantOrderController extends HttpServlet {
    private final MerchantService merchantService = new MerchantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        int restaurantId = restaurant.getId();
        String statusFilter = req.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "ALL";
        }

        List<Order> orders = merchantService.getOrders(restaurantId, statusFilter);
        List<Driver> availableDrivers = merchantService.getAvailableDrivers();

        req.setAttribute("orders", orders);
        req.setAttribute("selectedStatus", statusFilter);
        req.setAttribute("availableDrivers", availableDrivers);

        req.getRequestDispatcher("/WEB-INF/views/merchant/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("updateStatus".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String newStatus = req.getParameter("newStatus");

                // Nếu chuyển sang CONFIRMED (Nhận chế biến), bắt buộc phải có shipper được gán
                if ("CONFIRMED".equalsIgnoreCase(newStatus)) {
                    Order currentOrder = merchantService.getOrderById(orderId);
                    if (currentOrder == null || currentOrder.getDriverId() <= 0) {
                        req.getSession().setAttribute("flashError", "Không thể cập nhật trạng thái đơn: Vui lòng gán tài xế shipper trước khi nhận chế biến!");
                        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                        return;
                    }
                }

                boolean success = merchantService.updateOrderStatus(orderId, newStatus);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã cập nhật đơn hàng #" + orderId + " sang trạng thái: " + newStatus);
                } else {
                    req.getSession().setAttribute("flashError", "Không thể cập nhật trạng thái đơn!");
                }
            } else if ("merchantConfirm".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                boolean success = merchantService.confirmMerchantOrder(orderId);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã xác nhận xử lý xong đơn hàng #" + orderId + "! Khi cả khách hàng và quán cùng xác nhận, đơn sẽ được tính vào doanh thu.");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể xác nhận xử lý đơn hàng!");
                }
            } else if ("assignDriver".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                int driverId = Integer.parseInt(req.getParameter("driverId"));

                // Chặn gán shipper nếu đơn đã bị khách hủy (CANCELLED)
                Order currentOrder = merchantService.getOrderById(orderId);
                if (currentOrder != null && "CANCELLED".equalsIgnoreCase(currentOrder.getStatus())) {
                    req.getSession().setAttribute("flashError", "Không thể gán tài xế cho đơn hàng đã bị hủy!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                    return;
                }

                boolean success = merchantService.assignDriver(orderId, driverId);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã gán tài xế cho đơn hàng #" + orderId + " thành công!");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể gán tài xế cho đơn!");
                }
            } else if ("payShipper".equalsIgnoreCase(action)) {
                Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
                if (restaurant != null) {
                    int driverId = Integer.parseInt(req.getParameter("driverId"));
                    String orderIdStr = req.getParameter("orderId");
                    Integer orderId = (orderIdStr != null && !orderIdStr.trim().isEmpty()) ? Integer.parseInt(orderIdStr) : null;
                    double amount = Double.parseDouble(req.getParameter("amount"));
                    String paymentMethod = req.getParameter("paymentMethod");
                    String note = req.getParameter("note");

                    boolean success = merchantService.payDriverFee(restaurant.getId(), driverId, orderId, amount, paymentMethod, note);
                    if (success) {
                        req.getSession().setAttribute("flashMessage", "Đã ghi nhận thanh toán phí shipper thành công!");
                    } else {
                        req.getSession().setAttribute("flashError", "Không thể ghi nhận thanh toán phí shipper!");
                    }
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
    }
}
