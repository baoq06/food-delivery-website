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
        double restLat = (restaurant.getLatitude() != null) ? restaurant.getLatitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LAT;
        double restLng = (restaurant.getLongitude() != null) ? restaurant.getLongitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LNG;
        List<Driver> availableDrivers = driverDAO.findNearestDrivers(restLat, restLng);

        req.setAttribute("orders", orders);
        req.setAttribute("selectedStatus", statusFilter);
        req.setAttribute("availableDrivers", availableDrivers);

        req.getRequestDispatcher("/WEB-INF/views/merchant/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String redirectUrl = req.getParameter("redirectUrl");
        if (redirectUrl == null || redirectUrl.trim().isEmpty()) {
            redirectUrl = req.getContextPath() + "/merchant/orders";
        }

        Restaurant currentRestaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (currentRestaurant == null) {
            com.ute.fooddelivery.model.User currentUser = (com.ute.fooddelivery.model.User) req.getSession().getAttribute("currentUser");
            if (currentUser != null) {
                currentRestaurant = merchantService.getRestaurantForUser(currentUser.getId());
            }
        }

        if (currentRestaurant == null) {
            req.getSession().setAttribute("flashError", "Không tìm thấy thông tin quán ăn của bạn!");
            resp.sendRedirect(redirectUrl);
            return;
        }

        try {
            int orderId = 0;
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                orderId = Integer.parseInt(orderIdStr.trim());
            }

            if (orderId <= 0) {
                req.getSession().setAttribute("flashError", "Mã đơn hàng không hợp lệ!");
                resp.sendRedirect(redirectUrl);
                return;
            }

            Order currentOrder = merchantService.getOrderById(orderId);
            if (currentOrder == null) {
                req.getSession().setAttribute("flashError", "Không tìm thấy đơn hàng!");
                resp.sendRedirect(redirectUrl);
                return;
            }

            // KIỂM TRA CHỦ SỞ HỮU NHÀ HÀNG (Chặn IDOR)
            if (currentOrder.getRestaurantId() != currentRestaurant.getId()) {
                req.getSession().setAttribute("flashError", "Bạn không có quyền thao tác trên đơn hàng của quán khác!");
                resp.sendRedirect(redirectUrl);
                return;
            }

            if ("merchantConfirm".equalsIgnoreCase(action) || "completeOrder".equalsIgnoreCase(action) ||
                ("updateStatus".equalsIgnoreCase(action) && "DELIVERED".equalsIgnoreCase(req.getParameter("newStatus")))) {

                if ("DELIVERED".equalsIgnoreCase(currentOrder.getStatus())) {
                    req.getSession().setAttribute("flashMessage", "Đơn hàng #" + orderId + " đã được hoàn tất thành công!");
                    resp.sendRedirect(redirectUrl);
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
                String newStatus = req.getParameter("newStatus");

                // Chỉ khi bàn giao cho shipper đi giao (SHIPPING) mới bắt buộc phải có tài xế đã nhận cuốc
                if ("SHIPPING".equalsIgnoreCase(newStatus)) {
                    if (currentOrder.getDriverId() == null || currentOrder.getDriverId() <= 0) {
                        req.getSession().setAttribute("flashError", "Vui lòng gán tài xế shipper khả dụng trước khi bàn giao đơn hàng!");
                        resp.sendRedirect(redirectUrl);
                        return;
                    }

                    // BẮT BUỘC: Đợi shipper xác nhận nhận giao đơn đó
                    if (!currentOrder.isShipperAccepted()) {
                        req.getSession().setAttribute("flashError", "Chưa thể bàn giao: Vui lòng đợi tài xế xác nhận nhận cuốc xe giao đơn này!");
                        resp.sendRedirect(redirectUrl);
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
                        Integer merchantUserId = currentRestaurant.getUserId();

                        // Hoàn trả voucher cho khách hàng khi quán từ chối / hủy đơn
                        orderDAO.restoreVouchersForOrder(orderId);

                        notificationService.notifyOrderCancelled(customerUserId, shipperUserId, merchantUserId, orderId, "Quán hủy đơn");
                    }
                    req.getSession().setAttribute("flashMessage", "Đã cập nhật đơn hàng #" + orderId + " sang trạng thái: " + newStatus);
                } else {
                    req.getSession().setAttribute("flashError", "Không thể cập nhật trạng thái đơn!");
                }
            } else if ("assignDriver".equalsIgnoreCase(action)) {
                int driverId = Integer.parseInt(req.getParameter("driverId"));

                // Chặn gán shipper nếu đơn đã bị khách hủy (CANCELLED)
                if ("CANCELLED".equalsIgnoreCase(currentOrder.getStatus())) {
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
                                currentOrder.getTotalAmount(), 
                                currentOrder.getAddress() != null ? currentOrder.getAddress() : "TP.HCM"
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
                double restLat = (currentRestaurant.getLatitude() != null) ? currentRestaurant.getLatitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LAT;
                double restLng = (currentRestaurant.getLongitude() != null) ? currentRestaurant.getLongitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LNG;

                List<Driver> nearest = driverDAO.findNearestDrivers(restLat, restLng);
                if (!nearest.isEmpty()) {
                    Driver nearestDriver = nearest.get(0);
                    boolean success = merchantService.assignDriver(orderId, nearestDriver.getId());
                    if (success) {
                        try {
                            if (nearestDriver.getUserId() != null) {
                                notificationService.notifyOrderAssignedToShipper(
                                    nearestDriver.getUserId(),
                                    orderId,
                                    currentOrder.getTotalAmount(),
                                    currentOrder.getAddress() != null ? currentOrder.getAddress() : "TP.HCM"
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

        resp.sendRedirect(redirectUrl);
    }
}
