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
import java.util.stream.Collectors;

@WebServlet(name = "MerchantShipperController", urlPatterns = {"/merchant/shippers"})
public class MerchantShipperController extends HttpServlet {
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

        // 1. Lấy toàn bộ danh sách shipper
        List<Driver> allDrivers = merchantService.getAllDrivers();

        // Đếm theo trạng thái
        long availableCount = allDrivers.stream().filter(d -> "AVAILABLE".equalsIgnoreCase(d.getStatus())).count();
        long busyCount = allDrivers.stream().filter(d -> "BUSY".equalsIgnoreCase(d.getStatus())).count();
        long offlineCount = allDrivers.stream().filter(d -> "OFFLINE".equalsIgnoreCase(d.getStatus())).count();

        // Lọc theo query param status
        String statusFilter = req.getParameter("status");
        List<Driver> displayedDrivers = allDrivers;
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            displayedDrivers = allDrivers.stream()
                .filter(d -> statusFilter.equalsIgnoreCase(d.getStatus()))
                .collect(Collectors.toList());
            req.setAttribute("selectedStatus", statusFilter.toUpperCase());
        } else {
            req.setAttribute("selectedStatus", "ALL");
        }

        // Lấy các đơn hàng đang chờ giao của quán để hỗ trợ gán nhanh tài xế
        List<Order> unassignedOrders = merchantService.getOrders(restaurantId, "ALL").stream()
            .filter(o -> "CONFIRMED".equalsIgnoreCase(o.getStatus()) || "PENDING".equalsIgnoreCase(o.getStatus()))
            .collect(Collectors.toList());

        req.setAttribute("drivers", displayedDrivers);
        req.setAttribute("availableCount", availableCount);
        req.setAttribute("busyCount", busyCount);
        req.setAttribute("offlineCount", offlineCount);
        req.setAttribute("unassignedOrders", unassignedOrders);

        req.getRequestDispatcher("/WEB-INF/views/merchant/shippers.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("assign".equalsIgnoreCase(action)) {
                int driverId = Integer.parseInt(req.getParameter("driverId"));
                int orderId = Integer.parseInt(req.getParameter("orderId"));

                boolean success = merchantService.assignDriver(orderId, driverId);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã điều phối đơn hàng #" + orderId + " cho tài xế thành công! Trạng thái đơn chuyển sang 'Đang giao'.");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể gán tài xế, vui lòng thử lại!");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/shippers");
    }
}
