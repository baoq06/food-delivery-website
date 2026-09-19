package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.MerchantService;
import com.ute.fooddelivery.service.NotificationService;
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
    private final OrderDAO orderDAO = new OrderDAO();
    private final DriverDAO driverDAO = new DriverDAO();
    private final NotificationService notificationService = new NotificationService();

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
        List<Driver> availableDrivers = driverDAO.findNearestDrivers(restaurant.getLatitude(), restaurant.getLongitude());

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
            if ("merchantConfirm".equalsIgnoreCase(action) || "completeOrder".equalsIgnoreCase(action) ||
                ("updateStatus".equalsIgnoreCase(action) && "DELIVERED".equalsIgnoreCase(req.getParameter("newStatus")))) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                Order currentOrder = merchantService.getOrderById(orderId);

                if (currentOrder == null) {
                    req.getSession().setAttribute("flashError", "Không tìm thấy đơn hàng!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                    return;
                }

                if ("DELIVERED".equalsIgnoreCase(currentOrder.getStatus())) {
                    req.getSession().setAttribute("flashMessage", "Đơn hàng #" + orderId + " đã được hoàn tất thành công!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                    return;
                }

                boolean success = orderDAO.merchantCompleteOrder(orderId);
                if (success) {
                    Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                    Integer shipperUserId = orderDAO.getDriverUserIdByOrderId(orderId);
                    notificationService.notifyOrderCompleted(customerUserId, shipperUserId, null, orderId);

                    req.getSession().setAttribute("flashMessage", "Đã hoàn thành đơn hàng #" + orderId + "! Đơn hàng đã được chính thức ghi nhận vào doanh thu của quán.");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể duyệt hoàn tất đơn hàng!");
                }
            } else if ("updateStatus".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String newStatus = req.getParameter("newStatus");

                Order currentOrder = merchantService.getOrderById(orderId);
                if (currentOrder == null) {
                    req.getSession().setAttribute("flashError", "Không tìm thấy đơn hàng!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                    return;
                }

                // Nếu chuyển sang CONFIRMED hoặc SHIPPING (Nhận chế biến / Bàn giao shipper)
                if ("CONFIRMED".equalsIgnoreCase(newStatus) || "SHIPPING".equalsIgnoreCase(newStatus)) {
                    if (currentOrder.getDriverId() == null || currentOrder.getDriverId() <= 0) {
                        req.getSession().setAttribute("flashError", "Vui lòng gán tài xế shipper khả dụng trước khi nhận chế biến đơn hàng!");
                        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                        return;
                    }

                    // BẮT BUỘC: Đợi shipper xác nhận nhận giao đơn đó
                    if (!currentOrder.isShipperAccepted()) {
                        req.getSession().setAttribute("flashError", "Chưa thể bắt đầu chế biến: Vui lòng đợi tài xế xác nhận nhận cuốc xe giao đơn này!");
                        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                        return;
                    }
                }

                boolean success = merchantService.updateOrderStatus(orderId, newStatus);
                if (success) {
                    // Nếu bắt đầu giao hàng (SHIPPING), tự động gửi thông báo đến Khách và Shipper
                    if ("SHIPPING".equalsIgnoreCase(newStatus) || "CONFIRMED".equalsIgnoreCase(newStatus)) {
                        Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                        Integer shipperUserId = orderDAO.getDriverUserIdByOrderId(orderId);
                        notificationService.notifyOrderShipping(customerUserId, shipperUserId, orderId);
                    } else if ("CANCELLED".equalsIgnoreCase(newStatus)) {
                        Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                        Integer shipperUserId = orderDAO.getDriverUserIdByOrderId(orderId);
                        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
                        Integer merchantUserId = restaurant != null ? restaurant.getUserId() : null;
                        notificationService.notifyOrderCancelled(customerUserId, shipperUserId, merchantUserId, orderId, "Quán hủy đơn");
                    }
                    req.getSession().setAttribute("flashMessage", "Đã cập nhật đơn hàng #" + orderId + " sang trạng thái: " + newStatus);
                } else {
                    req.getSession().setAttribute("flashError", "Không thể cập nhật trạng thái đơn!");
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

                // Chặn gán nếu shipper này đã có 3 đơn đang chờ nhận
                if (orderDAO.countPendingAssignedOrders(driverId) >= 3) {
                    req.getSession().setAttribute("flashError", "Tài xế này đã được gán tối đa 3 đơn đang chờ nhận! Vui lòng chọn tài xế khác hoặc đợi tài xế phản hồi.");
                    resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                    return;
                }

                boolean success = merchantService.assignDriver(orderId, driverId);
                if (success) {
                    // Gửi thông báo đến Shipper vừa được gán
                    try {
                        Driver driver = driverDAO.getDriverById(driverId);
                        if (driver != null && driver.getUserId() != null) {
                            notificationService.notifyOrderAssignedToShipper(
                                driver.getUserId(), 
                                orderId, 
                                currentOrder != null ? currentOrder.getTotalAmount() : 0, 
                                currentOrder != null ? currentOrder.getAddress() : "TP.HCM"
                            );
                        }
                    } catch (Exception e) {
                        System.err.println("Lỗi khi gửi thông báo gán shipper: " + e.getMessage());
                    }

                    req.getSession().setAttribute("flashMessage", "Đã gán tài xế cho đơn hàng #" + orderId + "! Đang chờ tài xế xác nhận nhận cuốc giao.");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể gán tài xế cho đơn!");
                }
            } else if ("autoAssignNearest".equalsIgnoreCase(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
                double restLat = restaurant != null ? restaurant.getLatitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LAT;
                double restLng = restaurant != null ? restaurant.getLongitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LNG;

                List<Driver> nearest = driverDAO.findNearestDrivers(restLat, restLng);
                if (!nearest.isEmpty()) {
                    Driver nearestDriver = nearest.get(0);
                    boolean success = merchantService.assignDriver(orderId, nearestDriver.getId());
                    if (success) {
                        try {
                            if (nearestDriver.getUserId() != null) {
                                Order curOrder = merchantService.getOrderById(orderId);
                                notificationService.notifyOrderAssignedToShipper(
                                    nearestDriver.getUserId(),
                                    orderId,
                                    curOrder != null ? curOrder.getTotalAmount() : 0,
                                    curOrder != null ? curOrder.getAddress() : "TP.HCM"
                                );
                            }
                        } catch (Exception ignored) {}
                        double dist = nearestDriver.getDistanceToTarget() != null ? nearestDriver.getDistanceToTarget() : 0.8;
                        req.getSession().setAttribute("flashMessage", "Đã tự động dò tìm & gán tài xế gần quán nhất: " + nearestDriver.getName() + " (Cách quán " + String.format(java.util.Locale.US, "%.1f", dist) + " km)!");
                    } else {
                        req.getSession().setAttribute("flashError", "Không thể gán tài xế cho đơn!");
                    }
                } else {
                    req.getSession().setAttribute("flashError", "Không tìm thấy tài xế nào khả dụng quanh khu vực quán!");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
    }
}
