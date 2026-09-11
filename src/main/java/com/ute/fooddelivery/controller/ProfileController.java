package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.OrderService;
import com.ute.fooddelivery.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProfileController", urlPatterns = {"/profile", "/account"})
public class ProfileController extends HttpServlet {
    private final UserService userService = new UserService();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        // Lấy thông tin người dùng mới nhất từ CSDL
        User freshUser = userService.getUserById(currentUser.getId());
        if (freshUser != null) {
            session.setAttribute("currentUser", freshUser);
            currentUser = freshUser;
        }

        // Nếu là shipper và đang BẬT chế độ nhận đơn: chặn tab đơn hàng khách và chuyển sang lịch sử giao
        if (currentUser.isShipper()) {
            com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
            com.ute.fooddelivery.model.Driver driver = driverDAO.getOrCreateDriverForUser(currentUser);
            boolean isShipperActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
            session.setAttribute("shipperActive", isShipperActive);
            session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
            req.setAttribute("driver", driver);
            if (driver != null) {
                com.ute.fooddelivery.dao.OrderDAO oDAO = new com.ute.fooddelivery.dao.OrderDAO();
                req.setAttribute("driverWallet", oDAO.getDriverEarnings(driver.getId()));
            }
            String tab = req.getParameter("tab");
            if ("orders".equalsIgnoreCase(tab) && isShipperActive) {
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?tab=history");
                return;
            }
        }

        // Lấy danh sách đơn hàng của người dùng
        List<Order> orders = orderService.getOrdersByUserId(currentUser.getId());

        // Tính toán các chỉ số thống kê khách hàng
        int totalOrders = (orders != null) ? orders.size() : 0;
        int activeOrders = 0;
        int completedOrders = 0;
        double totalSpent = 0;

        if (orders != null) {
            for (Order o : orders) {
                String status = (o.getStatus() != null) ? o.getStatus().toUpperCase() : "";
                if ("PENDING".equals(status) || "CONFIRMED".equals(status) || "SHIPPING".equals(status)) {
                    activeOrders++;
                } else if ("DELIVERED".equals(status)) {
                    completedOrders++;
                }
                if (!"CANCELLED".equals(status)) {
                    totalSpent += o.getTotalAmount();
                }
            }
        }

        // Tab hiển thị
        String activeTab = req.getParameter("tab");
        if (activeTab == null || activeTab.trim().isEmpty()) {
            activeTab = "profile";
        }

        // Đọc thông báo từ query params (Post-Redirect-Get)
        String success = req.getParameter("success");
        if ("profile_updated".equals(success)) {
            req.setAttribute("successMessage", "Cập nhật thông tin tài khoản thành công!");
        } else if ("password_changed".equals(success)) {
            req.setAttribute("successMessage", "Đổi mật khẩu thành công! Hãy ghi nhớ mật khẩu mới của bạn.");
        } else if ("order_cancelled".equals(success)) {
            req.setAttribute("successMessage", "Đã hủy đơn hàng thành công!");
        } else if ("order_confirmed".equals(success)) {
            req.setAttribute("successMessage", "Bạn đã xác nhận nhận hàng thành công! Cảm ơn bạn đã sử dụng dịch vụ.");
        }

        String error = req.getParameter("error");
        if ("cancel_failed".equals(error)) {
            req.setAttribute("errorMessage", "Không thể hủy đơn hàng này (đơn đã được giao hoặc không hợp lệ).");
        } else if ("confirm_failed".equals(error)) {
            req.setAttribute("errorMessage", "Không thể xác nhận đơn hàng lúc này.");
        }

        req.setAttribute("user", currentUser);
        req.setAttribute("orders", orders);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("activeOrders", activeOrders);
        req.setAttribute("completedOrders", completedOrders);
        req.setAttribute("totalSpent", totalSpent);
        req.setAttribute("activeTab", activeTab);

        req.getRequestDispatcher("/WEB-INF/views/client/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");

        if ("update_profile".equalsIgnoreCase(action)) {
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");
            String email = req.getParameter("email");

            String validationError = null;
            if (fullName == null || fullName.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                email == null || email.trim().isEmpty()) {
                validationError = "Vui lòng nhập đầy đủ các trường thông tin bắt buộc (*)!";
            } else if (!phone.trim().matches("^0[0-9]{9,10}$")) {
                validationError = "Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam (10-11 chữ số bắt đầu bằng số 0).";
            } else if (!email.trim().matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                validationError = "Địa chỉ email không hợp lệ!";
            }

            if (validationError != null) {
                req.setAttribute("errorMessage", validationError);
                req.setAttribute("activeTab", "profile");
                req.setAttribute("stickyFullName", fullName);
                req.setAttribute("stickyPhone", phone);
                req.setAttribute("stickyAddress", address);
                req.setAttribute("stickyEmail", email);
                doGet(req, resp);
                return;
            }

            boolean updated = userService.updateProfile(currentUser.getId(), fullName.trim(), phone.trim(), address.trim(), email.trim());
            // Cập nhật session user ngay cả khi DB dùng mock fallback
            currentUser.setFullName(fullName.trim());
            currentUser.setPhone(phone.trim());
            currentUser.setAddress(address.trim());
            currentUser.setEmail(email.trim());
            session.setAttribute("currentUser", currentUser);

            resp.sendRedirect(req.getContextPath() + "/profile?tab=profile&success=profile_updated");
            return;
        } else if ("change_password".equalsIgnoreCase(action)) {
            String currentPassword = req.getParameter("currentPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");

            String validationError = null;
            if (currentPassword == null || currentPassword.isEmpty() ||
                newPassword == null || newPassword.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
                validationError = "Vui lòng điền đầy đủ các thông tin đổi mật khẩu!";
            } else if (newPassword.length() < 6) {
                validationError = "Mật khẩu mới phải có ít nhất 6 ký tự!";
            } else if (!newPassword.equals(confirmPassword)) {
                validationError = "Mật khẩu mới và xác nhận mật khẩu không trùng khớp!";
            } else if (!currentPassword.equals(currentUser.getPassword())) {
                validationError = "Mật khẩu hiện tại không chính xác!";
            }

            if (validationError != null) {
                req.setAttribute("errorMessage", validationError);
                req.setAttribute("activeTab", "security");
                doGet(req, resp);
                return;
            }

            boolean changed = userService.changePassword(currentUser.getId(), currentPassword, newPassword);
            currentUser.setPassword(newPassword);
            session.setAttribute("currentUser", currentUser);

            resp.sendRedirect(req.getContextPath() + "/profile?tab=security&success=password_changed");
            return;
        } else if ("cancel_order".equalsIgnoreCase(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                boolean cancelled = orderService.cancelOrderByCustomer(orderId, currentUser.getId());
                if (cancelled) {
                    resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&success=order_cancelled");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=cancel_failed");
                }
                return;
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=cancel_failed");
                return;
            }
        } else if ("confirm_received".equalsIgnoreCase(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                boolean confirmed = orderService.confirmCustomerOrder(orderId, currentUser.getId());
                if (confirmed) {
                    resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&success=order_confirmed");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=confirm_failed");
                }
                return;
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=confirm_failed");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
