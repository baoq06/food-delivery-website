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

                boolean success = merchantService.updateOrderStatus(orderId, newStatus);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã cập nhật đơn hàng #" + orderId + " sang trạng thái: " + newStatus);
                } else {
                    req.getSession().setAttribute("flashError", "Không thể cập nhật trạng thái đơn!");
                }
            } else if ("assignDriver".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                int driverId = Integer.parseInt(req.getParameter("driverId"));

                boolean success = merchantService.assignDriver(orderId, driverId);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã gán tài xế cho đơn hàng #" + orderId + " thành công!");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể gán tài xế cho đơn!");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
    }
}
