package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.NotificationService;
import com.ute.fooddelivery.utils.GeoLocationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/merchant/api/dispatch")
public class MerchantDispatchAPI extends HttpServlet {
    private final DriverDAO driverDAO = new DriverDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || (!user.isSeller() && !user.isAdmin())) {
            resp.setStatus(401);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            int orderId = 0;
            String orderIdParam = req.getParameter("orderId");
            if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
                orderId = Integer.parseInt(orderIdParam.trim());
            }

            Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
            if (restaurant == null) {
                restaurant = restaurantDAO.getRestaurantByUserId(user.getId());
            }

            double restLat = restaurant != null ? restaurant.getLatitude() : GeoLocationUtils.DEFAULT_LAT;
            double restLng = restaurant != null ? restaurant.getLongitude() : GeoLocationUtils.DEFAULT_LNG;

            // Thuật toán dò tìm tài xế gần quán nhất và không bận đơn nào
            List<Driver> nearestDrivers = driverDAO.findNearestDrivers(restLat, restLng);

            StringBuilder json = new StringBuilder();
            json.append("{\"status\":\"success\", \"restaurantLat\":").append(restLat)
                .append(", \"restaurantLng\":").append(restLng)
                .append(", \"drivers\":[");

            for (int i = 0; i < nearestDrivers.size(); i++) {
                Driver d = nearestDrivers.get(i);
                if (i > 0) json.append(",");
                double dist = d.getDistanceToTarget() != null ? d.getDistanceToTarget() : 2.0;
                int eta = GeoLocationUtils.estimateDeliveryMinutes(dist);

                json.append("{")
                    .append("\"id\":").append(d.getId()).append(",")
                    .append("\"name\":\"").append(d.getName().replace("\"", "\\\"")).append("\",")
                    .append("\"phone\":\"").append(d.getPhone()).append("\",")
                    .append("\"status\":\"").append(d.getStatus()).append("\",")
                    .append("\"vehicle\":\"").append(d.getVehicleType() != null ? d.getVehicleType().replace("\"", "\\\"") : "Xe máy").append("\",")
                    .append("\"plate\":\"").append(d.getLicensePlate() != null ? d.getLicensePlate() : "").append("\",")
                    .append("\"address\":\"").append(d.getCurrentAddress() != null ? d.getCurrentAddress().replace("\"", "\\\"") : "").append("\",")
                    .append("\"distanceKm\":").append(String.format(java.util.Locale.US, "%.1f", dist)).append(",")
                    .append("\"etaMinutes\":").append(eta).append(",")
                    .append("\"pendingCount\":").append(d.getPendingOrderCount()).append(",")
                    .append("\"isNearest\":").append(i == 0)
                    .append("}");
            }
            json.append("]}");

            resp.getWriter().write(json.toString());
        } catch (Exception e) {
            resp.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || (!user.isSeller() && !user.isAdmin())) {
            resp.setStatus(401);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String driverIdStr = req.getParameter("driverId");
            int driverId = 0;

            Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
            if (restaurant == null) {
                restaurant = restaurantDAO.getRestaurantByUserId(user.getId());
            }

            if (driverIdStr != null && !driverIdStr.trim().isEmpty() && !"auto".equalsIgnoreCase(driverIdStr)) {
                driverId = Integer.parseInt(driverIdStr.trim());
            } else {
                // Tự động tìm shipper gần quán nhất
                double restLat = restaurant != null ? restaurant.getLatitude() : GeoLocationUtils.DEFAULT_LAT;
                double restLng = restaurant != null ? restaurant.getLongitude() : GeoLocationUtils.DEFAULT_LNG;
                List<Driver> nearest = driverDAO.findNearestDrivers(restLat, restLng);
                if (!nearest.isEmpty()) {
                    driverId = nearest.get(0).getId();
                }
            }

            if (driverId <= 0) {
                resp.getWriter().write("{\"status\":\"error\", \"message\":\"Không tìm thấy tài xế khả dụng gần quán!\"}");
                return;
            }

            // Gán tài xế vào đơn
            boolean assigned = orderDAO.assignDriver(orderId, driverId);
            if (assigned) {
                Driver assignedDriver = driverDAO.getDriverById(driverId);
                Order order = orderDAO.getOrderById(orderId);

                // Gửi thông báo đến Shipper
                if (assignedDriver != null && assignedDriver.getUserId() != null) {
                    notificationService.notifyOrderAssignedToShipper(
                        assignedDriver.getUserId(),
                        orderId,
                        order != null ? order.getTotalAmount() : 0,
                        order != null ? order.getAddress() : "TP.HCM"
                    );
                }

                resp.getWriter().write(String.format(java.util.Locale.US,
                    "{\"status\":\"success\", \"message\":\"Đã gán tài xế %s (cách quán %.1f km)\", \"driverId\":%d, \"driverName\":\"%s\"}",
                    assignedDriver != null ? assignedDriver.getName().replace("\"", "\\\"") : "Shipper",
                    assignedDriver != null && assignedDriver.getDistanceToTarget() != null ? assignedDriver.getDistanceToTarget() : 0.8,
                    driverId,
                    assignedDriver != null ? assignedDriver.getName().replace("\"", "\\\"") : ""
                ));
            } else {
                resp.getWriter().write("{\"status\":\"error\", \"message\":\"Không thể gán tài xế vào đơn!\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
