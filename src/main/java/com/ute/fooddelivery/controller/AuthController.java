package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.CartItem;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.service.UserService;
import com.ute.fooddelivery.utils.CookieUtils;
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
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AuthController", urlPatterns = {"/auth"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AuthController extends HttpServlet {
    private final UserService userService = new UserService();
    private final FoodService foodService = new FoodService();
    private static final int REMEMBER_ME_AGE = 60 * 60 * 24 * 30; // 30 ngày

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            CookieUtils.deleteCookie(resp, "deli_name");
            CookieUtils.deleteCookie(resp, "deli_phone");
            CookieUtils.deleteCookie(resp, "deli_address");
            CookieUtils.deleteCookie(resp, "recent_foods");
            CookieUtils.deleteCookie(resp, "recent_foods_guest");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if ("send_otp".equalsIgnoreCase(action)) {
            handleSendOtp(req, resp);
            return;
        } else if ("verify_otp".equalsIgnoreCase(action)) {
            handleVerifyOtp(req, resp);
            return;
        }

        // Đọc cookie Remember Me nếu có
        String rememberedUser = CookieUtils.getCookieValue(req, "remember_user");
        if (rememberedUser != null && !rememberedUser.trim().isEmpty()) {
            req.setAttribute("cookieUsername", rememberedUser);
            req.setAttribute("cookieRemember", true);
        }

        req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("send_otp".equalsIgnoreCase(action)) {
            handleSendOtp(req, resp);
            return;
        } else if ("verify_otp".equalsIgnoreCase(action)) {
            handleVerifyOtp(req, resp);
            return;
        }

        if ("login".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String remember = req.getParameter("remember");

            User user = userService.login(username, password);

            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("currentUser", user);

                // Thêm món ăn chờ (nếu trước đó khách chưa đăng nhập đã bấm đặt món)
                processPendingFood(session);

                // Xử lý Cookie Remember Me
                if (remember != null) {
                    CookieUtils.addCookie(resp, "remember_user", username, REMEMBER_ME_AGE);
                } else {
                    CookieUtils.deleteCookie(resp, "remember_user");
                }

                String redirect = req.getParameter("redirect");
                if (user.isAdmin()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                } else if (user.isSeller()) {
                    resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
                } else if (user.isShipper()) {
                    com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
                    com.ute.fooddelivery.model.Driver driver = driverDAO.getOrCreateDriverForUser(user);
                    boolean isActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
                    session.setAttribute("shipperActive", isActive);
                    session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
                    if (isActive) {
                        session.removeAttribute("cart");
                    }
                    resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
                } else if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
                    resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
                } else {
                    resp.sendRedirect(req.getContextPath() + "/home");
                }
            } else {
                // Sticky form đăng nhập
                req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
                req.setAttribute("stickyUsername", username);
                req.setAttribute("stickyRemember", remember != null);
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
            }
        } else if ("register".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String confirmPassword = req.getParameter("confirmPassword");
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");
            String accountType = req.getParameter("accountType"); // "CUSTOMER", "SELLER" hoặc "SHIPPER"

            if (accountType == null || accountType.trim().isEmpty()) {
                accountType = "CUSTOMER";
            }
            boolean isSellerReg = "SELLER".equalsIgnoreCase(accountType);
            boolean isShipperReg = "SHIPPER".equalsIgnoreCase(accountType);

            // Các trường theo vai trò
            String restaurantName = req.getParameter("restaurantName");
            String restaurantDesc = req.getParameter("restaurantDesc");
            String openTime = req.getParameter("openTime");
            String closeTime = req.getParameter("closeTime");

            String licensePlate = req.getParameter("licensePlate");
            String vehicleType = req.getParameter("vehicleType");

            // Xử lý upload tệp
            String avatarUrl = null;
            String idCardFront = null;
            String idCardBack = null;
            String vehicleDoc = null;
            String restaurantLogo = null;

            try {
                Part avatarPart = req.getPart("avatarFile");
                if (avatarPart != null && avatarPart.getSize() > 0) {
                    avatarUrl = UploadUtils.saveUploadedFile(avatarPart, "avatars", req);
                }
            } catch (Exception ignored) {}

            if (isShipperReg) {
                try {
                    Part facePart = req.getPart("facePhoto");
                    if (facePart != null && facePart.getSize() > 0) {
                        String faceUrl = UploadUtils.saveUploadedFile(facePart, "drivers", req);
                        avatarUrl = faceUrl; // Ảnh mặt làm avatar luôn
                    }
                    Part frontPart = req.getPart("idCardFront");
                    if (frontPart != null && frontPart.getSize() > 0) {
                        idCardFront = UploadUtils.saveUploadedFile(frontPart, "drivers", req);
                    }
                    Part backPart = req.getPart("idCardBack");
                    if (backPart != null && backPart.getSize() > 0) {
                        idCardBack = UploadUtils.saveUploadedFile(backPart, "drivers", req);
                    }
                    Part docPart = req.getPart("vehicleDoc");
                    if (docPart != null && docPart.getSize() > 0) {
                        vehicleDoc = UploadUtils.saveUploadedFile(docPart, "drivers", req);
                    }
                } catch (Exception ignored) {}
            } else if (isSellerReg) {
                try {
                    Part logoPart = req.getPart("restaurantLogo");
                    if (logoPart != null && logoPart.getSize() > 0) {
                        restaurantLogo = UploadUtils.saveUploadedFile(logoPart, "restaurants", req);
                        if (avatarUrl == null) avatarUrl = restaurantLogo;
                    }
                } catch (Exception ignored) {}
            }

            // Sticky Form & Validation khi đăng ký
            String validationError = null;
            if (fullName == null || fullName.trim().isEmpty() ||
                username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                validationError = "Vui lòng điền đầy đủ các thông tin bắt buộc (*)!";
            } else if (confirmPassword != null && !password.equals(confirmPassword)) {
                validationError = "Mật khẩu xác nhận không trùng khớp với mật khẩu đã nhập!";
            } else if (password.trim().length() < 6) {
                validationError = "Mật khẩu bảo mật phải có ít nhất 6 ký tự!";
            } else if (!phone.trim().matches("^0[0-9]{9,10}$")) {
                validationError = "Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam 10-11 chữ số bắt đầu bằng số 0.";
            } else if (isSellerReg && (restaurantName == null || restaurantName.trim().isEmpty())) {
                validationError = "Chủ quán vui lòng nhập Tên quán ăn / Nhà hàng của bạn!";
            } else if (isShipperReg && (licensePlate == null || licensePlate.trim().isEmpty())) {
                validationError = "Đối tác Shipper vui lòng nhập Biển số xe máy của bạn!";
            } else if (isShipperReg && (avatarUrl == null || avatarUrl.trim().isEmpty())) {
                validationError = "Đối tác Shipper bắt buộc phải tải lên ảnh chân dung khuôn mặt!";
            } else if (isShipperReg && (idCardFront == null || idCardBack == null)) {
                validationError = "Đối tác Shipper bắt buộc phải chụp cả 2 mặt căn cước công dân (CCCD)!";
            } else if (isShipperReg && (vehicleDoc == null || vehicleDoc.trim().isEmpty())) {
                validationError = "Đối tác Shipper bắt buộc phải chụp giấy tờ xe / cà vẹt xe!";
            }

            String redirect = req.getParameter("redirect");

            if (validationError != null) {
                req.setAttribute("errorMessage", validationError);
                req.setAttribute("stickyRegFullName", fullName);
                req.setAttribute("stickyRegUsername", username);
                req.setAttribute("stickyRegPhone", phone);
                req.setAttribute("stickyRegAddress", address);
                req.setAttribute("stickyAccountType", accountType);
                req.setAttribute("stickyRestaurantName", restaurantName);
                req.setAttribute("stickyRestaurantDesc", restaurantDesc);
                req.setAttribute("stickyOpenTime", openTime);
                req.setAttribute("stickyCloseTime", closeTime);
                req.setAttribute("stickyLicensePlate", licensePlate);
                req.setAttribute("stickyVehicleType", vehicleType);
                req.setAttribute("redirect", redirect);
                req.setAttribute("activeTab", "registerTab");
                req.setAttribute("currentStep", 4);
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            String role = "CUSTOMER";
            if (isSellerReg) role = "SELLER";
            if (isShipperReg) role = "SHIPPER";

            User newUser = new User(0, username.trim(), password, fullName.trim(), username.trim() + "@gmail.com", phone.trim(), address.trim(), role, avatarUrl);
            boolean created;
            if (isSellerReg) {
                created = userService.registerSeller(newUser, restaurantName.trim(), address.trim(), restaurantDesc, openTime, closeTime, restaurantLogo);
            } else if (isShipperReg) {
                created = userService.registerShipper(newUser, licensePlate, vehicleType, idCardFront, idCardBack, vehicleDoc, avatarUrl);
            } else {
                created = userService.register(newUser);
            }

            if (!created) {
                req.setAttribute("errorMessage", "Tên đăng nhập '" + username + "' đã được sử dụng! Vui lòng chọn tên khác.");
                req.setAttribute("stickyRegFullName", fullName);
                req.setAttribute("stickyRegPhone", phone);
                req.setAttribute("stickyRegAddress", address);
                req.setAttribute("stickyAccountType", accountType);
                req.setAttribute("stickyRestaurantName", restaurantName);
                req.setAttribute("stickyRestaurantDesc", restaurantDesc);
                req.setAttribute("stickyOpenTime", openTime);
                req.setAttribute("stickyCloseTime", closeTime);
                req.setAttribute("stickyLicensePlate", licensePlate);
                req.setAttribute("stickyVehicleType", vehicleType);
                req.setAttribute("redirect", redirect);
                req.setAttribute("activeTab", "registerTab");
                req.setAttribute("currentStep", 4);
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            // Đăng nhập luôn cho user sau khi đăng ký thành công
            User loggedUser = userService.login(username.trim(), password);
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", loggedUser != null ? loggedUser : newUser);

            // Xóa session OTP
            session.removeAttribute("regOtp");
            session.removeAttribute("regPhone");
            session.removeAttribute("phoneVerified");

            // Thêm món ăn chờ (nếu trước đó khách chưa đăng nhập đã bấm đặt món)
            processPendingFood(session);

            if (isSellerReg) {
                resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
            } else if (isShipperReg || "DRIVER".equalsIgnoreCase(role)) {
                com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
                User targetUser = loggedUser != null ? loggedUser : newUser;
                com.ute.fooddelivery.model.Driver driver = driverDAO.getOrCreateDriverForUser(targetUser);
                boolean isActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
                session.setAttribute("shipperActive", isActive);
                session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard");
            } else if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
                resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
            } else {
                resp.sendRedirect(req.getContextPath() + "/home");
            }
        }
    }

    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String phone = req.getParameter("phone");
        if (phone == null || !phone.trim().matches("^0[0-9]{9,10}$")) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam 10 chữ số (bắt đầu bằng 0).\"}");
            return;
        }

        // Sinh mã OTP ngẫu nhiên 6 chữ số
        int randomNum = (int) (Math.random() * 900000) + 100000;
        String otp = String.valueOf(randomNum);

        HttpSession session = req.getSession(true);
        session.setAttribute("regOtp", otp);
        session.setAttribute("regPhone", phone.trim());
        session.setAttribute("regOtpTime", System.currentTimeMillis());

        System.out.println(">> [SMS GATEWAY SIMULATOR] Gửi OTP " + otp + " tới số điện thoại " + phone.trim());

        resp.getWriter().write(String.format("{\"success\":true,\"otp\":\"%s\",\"phone\":\"%s\",\"message\":\"Mã xác thực OTP đã được gửi thành công đến số %s\"}", otp, phone.trim(), phone.trim()));
    }

    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String inputOtp = req.getParameter("otp");
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Phiên xác thực đã hết hạn. Vui lòng bấm gửi lại mã OTP!\"}");
            return;
        }

        String sessionOtp = (String) session.getAttribute("regOtp");
        Long otpTime = (Long) session.getAttribute("regOtpTime");

        if (sessionOtp == null || otpTime == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Chưa có mã OTP nào được yêu cầu hoặc mã đã hết hiệu lực!\"}");
            return;
        }

        if (System.currentTimeMillis() - otpTime > 5 * 60 * 1000) {
            session.removeAttribute("regOtp");
            resp.getWriter().write("{\"success\":false,\"message\":\"Mã OTP đã hết hạn (quá 5 phút). Vui lòng bấm gửi lại mã mới!\"}");
            return;
        }

        if (inputOtp != null && inputOtp.trim().equals(sessionOtp)) {
            session.setAttribute("phoneVerified", true);
            resp.getWriter().write("{\"success\":true,\"message\":\"Xác thực số điện thoại thành công!\"}");
        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại!\"}");
        }
    }

    private void processPendingFood(HttpSession session) {
        if (session == null) return;
        Integer pendingFoodId = (Integer) session.getAttribute("pendingFoodId");
        if (pendingFoodId != null) {
            int qty = 1;
            Integer pendingQty = (Integer) session.getAttribute("pendingQuantity");
            if (pendingQty != null && pendingQty > 0) {
                qty = pendingQty;
            }

            Food food = foodService.getFoodById(pendingFoodId);
            if (food != null) {
                @SuppressWarnings("unchecked")
                Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
                if (cart == null) {
                    cart = new HashMap<>();
                }
                if (cart.containsKey(pendingFoodId)) {
                    CartItem item = cart.get(pendingFoodId);
                    item.setQuantity(item.getQuantity() + qty);
                } else {
                    cart.put(pendingFoodId, new CartItem(food, qty));
                }
                session.setAttribute("cart", cart);
            }
            session.removeAttribute("pendingFoodId");
            session.removeAttribute("pendingQuantity");
        }
    }
}
