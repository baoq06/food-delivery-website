package com.ute.fooddelivery.controller.shipper;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.ReviewDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.NotificationService;
import com.ute.fooddelivery.utils.CsrfUtils;
import com.ute.fooddelivery.utils.UploadUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet(name = "ShipperDashboardController", urlPatterns = {"/shipper/dashboard", "/shipper/history"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 20
)
public class ShipperDashboardController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ShipperDashboardController.class.getName());

    private final DriverDAO driverDAO = new DriverDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        // Đảm bảo CSRF token luôn sẵn sàng trong session và request attribute
        String csrfToken = CsrfUtils.getOrCreateToken(session);
        req.setAttribute("csrfToken", csrfToken);

        // BẢO MẬT & CHỐNG KÍCH HOẠT NGẦM:
        // Chặn tuyệt đối mọi thao tác thay đổi dữ liệu/trạng thái qua HTTP GET
        // (ngăn chặn bot crawler, browser prefetch và tấn công CSRF qua GET)
        String action = req.getParameter("action");
        if (action != null && !action.trim().isEmpty()) {
            LOGGER.warning("Security alert: Blocked state-modifying action '" + action + "' requested via HTTP GET by user ID " + user.getId());
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=method_not_allowed");
            return;
        }

        Driver driver = driverDAO.getOrCreateDriverForUser(user);

        // Đồng bộ trạng thái hiện tại vào session
        boolean isCurrentActive = driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()) && !"BANNED".equalsIgnoreCase(driver.getStatus());
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
        } else if ("income".equalsIgnoreCase(tab)) {
            req.setAttribute("activeTab", "income");
        } else if ("violations".equalsIgnoreCase(tab)) {
            req.setAttribute("activeTab", "violations");
        } else if ("settings".equalsIgnoreCase(tab)) {
            req.setAttribute("activeTab", "settings");
        } else if ("help".equalsIgnoreCase(tab)) {
            req.setAttribute("activeTab", "help");
        } else {
            req.setAttribute("activeTab", "dispatch");
        }

        if (driver != null) {
            // Đơn đang được gán chờ Shipper xác nhận nhận cuốc (tối đa 3 đơn, xếp theo thời gian cũ nhất lên trước)
            List<Order> pendingAssignedOrders = orderDAO.getPendingAssignedOrdersForDriver(driver.getId());
            req.setAttribute("pendingAssignedOrders", pendingAssignedOrders);
            req.setAttribute("pendingAssignedOrder", pendingAssignedOrders.isEmpty() ? null : pendingAssignedOrders.get(0));

            // Đơn đang giao (SHIPPING)
            List<Order> activeOrders = orderDAO.getOrdersByDriver(driver.getId(), "SHIPPING");
            req.setAttribute("activeOrders", activeOrders);
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

            // Thống kê ví tài xế & Rating tài xế
            Map<String, Object> earnings = orderDAO.getDriverEarnings(driver.getId());
            Map<String, Object> driverRatingStats = reviewDAO.getDriverRatingStats(driver.getId());
            req.setAttribute("wallet", earnings);
            req.setAttribute("driverRatingStats", driverRatingStats);
            req.setAttribute("driver", driver);
        }

        req.getRequestDispatcher("/WEB-INF/views/shipper/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        // BẢO MẬT: Kiểm tra tính hợp lệ của CSRF Token
        if (!CsrfUtils.validate(req)) {
            LOGGER.warning("Security alert: Invalid or missing CSRF token on POST request by user ID " + user.getId());
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=csrf_invalid");
            return;
        }

        Driver driver = driverDAO.getOrCreateDriverForUser(user);
        String action = req.getParameter("action");

        if ("toggleStatus".equals(action)) {
            handleToggleStatus(req, resp, session, user, driver);
        } else if ("confirmPickedUp".equals(action)) {
            handleConfirmPickedUp(req, resp, session, user, driver);
        } else if ("confirmDelivered".equals(action)) {
            handleConfirmDelivered(req, resp, session, user, driver);
        } else if ("updateOrder".equals(action)) {
            handleUpdateOrder(req, resp, session, user, driver);
        } else if ("reportFailed".equals(action)) {
            handleReportFailed(req, resp, session, user, driver);
        } else if ("acceptOrder".equals(action) || "acceptAssignedOrder".equals(action)) {
            handleAcceptOrder(req, resp, session, user, driver);
        } else if ("declineOrder".equals(action)) {
            handleDeclineOrder(req, resp, user, driver);
        } else {
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
        if (driver != null) {
            if ("BANNED".equalsIgnoreCase(driver.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=banned");
                return;
            }
            if ("BUSY".equalsIgnoreCase(driver.getStatus())) {
                List<Order> checkActive = orderDAO.getOrdersByDriver(driver.getId(), "SHIPPING");
                if (checkActive != null && !checkActive.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=busy_cannot_toggle");
                    return;
                }
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
            if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://") && !redirect.contains("\r") && !redirect.contains("\n")) {
                resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void handleConfirmPickedUp(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            if (driver != null) {
                Order currentOrder = orderDAO.getOrderById(orderId);
                if (currentOrder != null && "PENDING".equalsIgnoreCase(currentOrder.getStatus()) && !currentOrder.isMerchantConfirmed()) {
                    session.setAttribute("flashError", "Quán chưa bấm xác nhận chế biến món! Vui lòng đợi quán chuẩn bị món xong mới xác nhận lấy hàng.");
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                    return;
                }
                boolean success = orderDAO.shipperConfirmPickedUp(orderId, driver.getId());
                if (success) {
                    driverDAO.updateStatusByUserId(user.getId(), "BUSY");
                    driver.setStatus("BUSY");
                    session.setAttribute("shipperActive", true);
                    session.setAttribute("driverStatus", "BUSY");

                    Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                    notificationService.notifyOrderShipping(customerUserId, user.getId(), orderId);
                } else {
                    session.setAttribute("flashError", "Không thể xác nhận lấy món lúc này. Vui lòng đảm bảo quán đã bấm chế biến món ăn!");
                }
            }
        } catch (Exception e) {
            LOGGER.severe("Error confirming order picked up: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void handleConfirmDelivered(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            if (driver != null) {
                orderDAO.shipperConfirmDelivered(orderId, driver.getId());
                Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);

                syncDriverStatusAfterDelivery(session, user, driver, orderId);

                notificationService.notifyOrderCompleted(customerUserId, user.getId(), merchantUserId, orderId);

                Order deliveredOrder = orderDAO.getOrderById(orderId);
                if (deliveredOrder != null && deliveredOrder.getAddress() != null) {
                    String destAddress = URLEncoder.encode(deliveredOrder.getAddress(), StandardCharsets.UTF_8);
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?completedAddr=" + destAddress);
                    return;
                }
            }
        } catch (Exception e) {
            LOGGER.severe("Error confirming order delivered: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void handleUpdateOrder(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String status = req.getParameter("status");

            if ("DELIVERED".equalsIgnoreCase(status)) {
                handleConfirmDelivered(req, resp, session, user, driver);
                return;
            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                String cancelReason = req.getParameter("cancelReason");
                if (cancelReason != null && (cancelReason.contains("Quán đóng cửa") || cancelReason.contains("Hết món"))) {
                    // Trường hợp quán đóng cửa / hết món: đơn vị không thể tiếp tục -> Hủy đơn và hoàn trả voucher
                    try (Connection conn = com.ute.fooddelivery.dao.DBContext.getConnection();
                         PreparedStatement ps = conn.prepareStatement("UPDATE orders SET status = 'CANCELLED', note = CONCAT(IFNULL(note, ''), ' [HỦY SỰ CỐ QUÁN: ', ?, ']') WHERE order_id = ?")) {
                        ps.setString(1, cancelReason.trim());
                        ps.setInt(2, orderId);
                        ps.executeUpdate();
                    } catch (Exception ex) {
                        orderDAO.updateOrderStatus(orderId, "CANCELLED");
                    }
                    orderDAO.restoreVouchersForOrder(orderId);

                    Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                    Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                    notificationService.notifyOrderCancelled(customerUserId, user.getId(), merchantUserId, orderId, "Sự cố: " + cancelReason.trim());
                } else if (cancelReason != null && !cancelReason.trim().isEmpty()) {
                    try (Connection conn = com.ute.fooddelivery.dao.DBContext.getConnection();
                         PreparedStatement ps = conn.prepareStatement("UPDATE orders SET driver_id = NULL, status = 'PENDING', shipper_accepted = 0, shipper_picked_up = 0, note = CONCAT(IFNULL(note, ''), ' [Shipper Trả Đơn: ', ?, ']') WHERE order_id = ?")) {
                        ps.setString(1, cancelReason.trim());
                        ps.setInt(2, orderId);
                        ps.executeUpdate();
                    } catch (Exception ex) {
                        orderDAO.shipperDeclineOrder(orderId, driver != null ? driver.getId() : 0);
                    }
                } else {
                    orderDAO.shipperDeclineOrder(orderId, driver != null ? driver.getId() : 0);
                }

                if (driver != null) {
                    syncDriverStatusAfterDelivery(session, user, driver, orderId);
                }
            } else if ("FAILED_DELIVERY".equalsIgnoreCase(status) || "BOOM".equalsIgnoreCase(status)) {
                handleReportFailed(req, resp, session, user, driver);
                return;
            } else if ("SHIPPING".equalsIgnoreCase(status)) {
                orderDAO.updateOrderStatus(orderId, "SHIPPING");
                driverDAO.updateStatusByUserId(user.getId(), "BUSY");
                if (driver != null) driver.setStatus("BUSY");
                session.setAttribute("shipperActive", true);
                session.setAttribute("driverStatus", "BUSY");
            }
        } catch (Exception e) {
            LOGGER.severe("Error updating order: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void handleReportFailed(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String boomReason = req.getParameter("cancelReason");
            if (boomReason == null || boomReason.trim().isEmpty()) {
                boomReason = "Khách hàng không nhận hàng / không liên lạc được khi giao";
            }
            String shipperNote = req.getParameter("shipperNote");

            // Xử lý upload ảnh chụp bằng chứng (cuộc gọi nhỡ / địa chỉ giao hàng)
            String proofUrl = null;
            try {
                Part proofPart = req.getPart("proofImage");
                if (proofPart != null && proofPart.getSize() > 0) {
                    proofUrl = UploadUtils.saveUploadedFile(proofPart, "proofs", req);
                }
            } catch (Throwable ex) {
                LOGGER.warning("Could not process proof image part: " + ex.getMessage());
            }

            Order targetOrder = orderDAO.getOrderById(orderId);
            if (targetOrder != null) {
                int customerUserId = targetOrder.getUserId();

                // 1. Cập nhật trạng thái đơn CANCELLED kèm ghi chú và ảnh bằng chứng
                orderDAO.reportOrderFailed(orderId, boomReason, shipperNote, proofUrl);

                // 2. Ghi nhận vi phạm bom hàng và khóa COD của khách hàng
                userDAO.recordCustomerBoom(customerUserId, boomReason);

                // 3. Gửi thông báo kiểm tra đến Khách hàng, Chủ quán và Ban Quản Trị
                Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                notificationService.notifyBoomReported(customerUserId, merchantUserId, orderId, boomReason, shipperNote, proofUrl);
            }

            if (driver != null) {
                syncDriverStatusAfterDelivery(session, user, driver, orderId);
            }
            resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?msg=boom_reported");
            return;
        } catch (Exception e) {
            LOGGER.severe("Error reporting failed delivery: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void handleAcceptOrder(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User user, Driver driver) throws IOException {
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

                    // Gửi thông báo cho Quán và Khách hàng
                    Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                    Integer customerUserId = orderDAO.getCustomerUserIdByOrderId(orderId);
                    notificationService.notifyShipperAccepted(merchantUserId, customerUserId, orderId, driver.getName(), driver.getPhone());

                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                    return;
                }
            }
        } catch (Exception e) {
            LOGGER.severe("Error accepting order: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?error=accept_failed");
    }

    private void handleDeclineOrder(HttpServletRequest req, HttpServletResponse resp, User user, Driver driver) throws IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            if (driver != null) {
                boolean success = orderDAO.shipperDeclineOrder(orderId, driver.getId());
                if (success) {
                    Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                    notificationService.notifyShipperDeclinedToMerchant(merchantUserId, orderId, driver.getName());
                }
            }
        } catch (Exception e) {
            LOGGER.severe("Error declining order: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
    }

    private void syncDriverStatusAfterDelivery(HttpSession session, User user, Driver driver, int excludedOrderId) {
        List<Order> activeLeft = orderDAO.getOrdersByDriver(driver.getId(), "SHIPPING");
        boolean stillHasActive = activeLeft.stream().anyMatch(o -> o.getId() != excludedOrderId);
        if (!stillHasActive) {
            driverDAO.updateStatusByUserId(user.getId(), "AVAILABLE");
            driver.setStatus("AVAILABLE");
            session.setAttribute("shipperActive", true);
            session.setAttribute("driverStatus", "AVAILABLE");
        } else {
            driver.setStatus("BUSY");
            session.setAttribute("shipperActive", true);
            session.setAttribute("driverStatus", "BUSY");
        }
    }
}
