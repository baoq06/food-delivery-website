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
    private final com.ute.fooddelivery.service.EmailService emailService = new com.ute.fooddelivery.service.EmailService();
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

        req.setAttribute("allUsers", userService.getAllUsers());
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
                com.ute.fooddelivery.utils.CsrfUtils.refreshToken(session);

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
                req.setAttribute("allUsers", userService.getAllUsers());
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
            }
        } else if ("register".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String confirmPassword = req.getParameter("confirmPassword");
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");
            String accountType = req.getParameter("accountType"); // "CUSTOMER", "SELLER" hoặc "SHIPPER"

            // Lấy email từ session nếu request param chưa truyền
            HttpSession checkSession = req.getSession(false);
            if ((email == null || email.trim().isEmpty()) && checkSession != null) {
                String sessEmail = (String) checkSession.getAttribute("verifiedEmail");
                if (sessEmail == null) {
                    sessEmail = (String) checkSession.getAttribute("regEmail");
                }
                if (sessEmail != null) {
                    email = sessEmail;
                }
            }

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
            String restaurantBanner = null;

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
                    Part ownerPart = req.getPart("ownerAvatar");
                    if (ownerPart != null && ownerPart.getSize() > 0) {
                        avatarUrl = UploadUtils.saveUploadedFile(ownerPart, "avatars", req);
                    }
                    Part logoPart = req.getPart("restaurantLogo");
                    if (logoPart != null && logoPart.getSize() > 0) {
                        restaurantLogo = UploadUtils.saveUploadedFile(logoPart, "restaurants", req);
                    }
                    Part bannerPart = req.getPart("restaurantBanner");
                    if (bannerPart != null && bannerPart.getSize() > 0) {
                        restaurantBanner = UploadUtils.saveUploadedFile(bannerPart, "restaurants", req);
                    }
                } catch (Exception ignored) {}
            }

            // Sticky Form & Validation khi đăng ký
            String validationError = null;
            int errorStep = 4;

            // BẢO MẬT: Bắt buộc kiểm tra cờ xác thực OTP trước khi cho phép lưu tài khoản mới
            HttpSession currentSession = req.getSession(false);
            Boolean phoneVerified = currentSession != null ? (Boolean) currentSession.getAttribute("phoneVerified") : null;
            String regPhone = currentSession != null ? (String) currentSession.getAttribute("regPhone") : null;

            if (phoneVerified == null || !phoneVerified) {
                validationError = "Số điện thoại chưa được xác thực mã OTP! Vui lòng hoàn thành bước xác thực số điện thoại qua tin nhắn SMS trước khi đăng ký.";
                errorStep = 2;
            } else if (phone == null || phone.trim().isEmpty() || regPhone == null || !regPhone.trim().equals(phone.trim())) {
                validationError = "Số điện thoại đăng ký (" + (phone != null ? phone.trim() : "") + ") không trùng khớp với số điện thoại đã xác thực mã OTP (" + (regPhone != null ? regPhone : "chưa có") + ")! Vui lòng xác thực lại.";
                errorStep = 2;
            } else if (fullName == null || fullName.trim().isEmpty() ||
                username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                validationError = "Vui lòng điền đầy đủ các thông tin bắt buộc (*)!";
            } else if (email == null || email.trim().isEmpty() || !email.trim().matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                validationError = "Địa chỉ email không hợp lệ! Vui lòng nhập địa chỉ Gmail/Email chính xác.";
            } else if (userService.isEmailExists(email.trim())) {
                validationError = "Địa chỉ email '" + email.trim() + "' đã được sử dụng! Vui lòng chọn email khác.";
            } else if (confirmPassword != null && !password.equals(confirmPassword)) {
                validationError = "Mật khẩu xác nhận không trùng khớp với mật khẩu đã nhập!";
            } else if (password.trim().length() < 6) {
                validationError = "Mật khẩu bảo mật phải có ít nhất 6 ký tự!";
            } else if (!phone.trim().matches("^0[0-9]{9,10}$")) {
                validationError = "Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam 10-11 chữ số bắt đầu bằng số 0.";
            } else if (userService.isPhoneExists(phone.trim())) {
                validationError = "Số điện thoại " + phone.trim() + " đã được đăng ký tài khoản! Vui lòng sử dụng số điện thoại khác.";
            } else if (userService.isUsernameExists(username.trim())) {
                validationError = "Tên đăng nhập '" + username.trim() + "' đã được sử dụng! Vui lòng chọn tên khác.";
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
                req.setAttribute("stickyRegEmail", email);
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
                req.setAttribute("currentStep", errorStep);
                req.setAttribute("allUsers", userService.getAllUsers());
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            String role = "CUSTOMER";
            if (isSellerReg) role = "SELLER";
            if (isShipperReg) role = "SHIPPER";

            User newUser = new User(0, username.trim(), password, fullName.trim(), email.trim(), phone.trim(), address.trim(), role, avatarUrl);
            boolean created;
            if (isSellerReg) {
                created = userService.registerSeller(newUser, restaurantName.trim(), address.trim(), restaurantDesc, openTime, closeTime, restaurantLogo, restaurantBanner);
            } else if (isShipperReg) {
                created = userService.registerShipper(newUser, licensePlate, vehicleType, idCardFront, idCardBack, vehicleDoc, avatarUrl);
            } else {
                created = userService.register(newUser);
            }

            if (!created) {
                req.setAttribute("errorMessage", "Đăng ký không thành công! Tên đăng nhập, email hoặc số điện thoại có thể đã tồn tại trong hệ thống.");
                req.setAttribute("stickyRegFullName", fullName);
                req.setAttribute("stickyRegEmail", email);
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
                req.setAttribute("allUsers", userService.getAllUsers());
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            // Đăng nhập luôn cho user sau khi đăng ký thành công
            User loggedUser = userService.login(username.trim(), password);
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", loggedUser != null ? loggedUser : newUser);

            // Cấp gói voucher chào mừng (UTEE30, UTEE20, FREESHIP, WELCOME, UTEE15) vào Kho Voucher
            if (loggedUser != null && loggedUser.getId() > 0) {
                try {
                    com.ute.fooddelivery.dao.UserVoucherDAO userVoucherDAO = new com.ute.fooddelivery.dao.UserVoucherDAO();
                    userVoucherDAO.grantWelcomeVouchers(loggedUser.getId());
                } catch (Exception e) {
                    System.err.println("Lỗi khi cấp voucher chào mừng: " + e.getMessage());
                }
            }

            // Xóa session OTP
            session.removeAttribute("regOtp");
            session.removeAttribute("regEmail");
            session.removeAttribute("regPhone");
            session.removeAttribute("regOtpTime");
            session.removeAttribute("emailVerified");
            session.removeAttribute("verifiedEmail");
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
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");

        if (email == null || !email.trim().matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Địa chỉ email không hợp lệ! Vui lòng nhập địa chỉ Gmail/Email chính xác (ví dụ: vidu@gmail.com).\"}");
            return;
        }

        String cleanEmail = email.trim().toLowerCase();

        // Kiểm tra email đã tồn tại trong hệ thống chưa
        if (userService.isEmailExists(cleanEmail)) {
            resp.getWriter().write(String.format("{\"success\":false,\"message\":\"Địa chỉ email '%s' đã được đăng ký tài khoản! Vui lòng đăng nhập hoặc sử dụng email khác.\"}", cleanEmail));
            return;
        }

        // Nếu có gửi kèm số điện thoại thì kiểm tra số điện thoại
        if (phone != null && !phone.trim().isEmpty()) {
            String cleanPhone = phone.trim();
            if (!cleanPhone.matches("^0[0-9]{9,10}$")) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Số điện thoại không hợp lệ! Vui lòng nhập 10-11 chữ số bắt đầu bằng số 0.\"}");
                return;
            }
            if (userService.isPhoneExists(cleanPhone)) {
                resp.getWriter().write(String.format("{\"success\":false,\"message\":\"Số điện thoại '%s' đã được đăng ký tài khoản! Vui lòng sử dụng số khác.\"}", cleanPhone));
                return;
            }
        }

        // Sinh mã OTP ngẫu nhiên 6 chữ số
        String otp = com.ute.fooddelivery.service.EmailService.generateOtp();

        HttpSession session = req.getSession(true);
        session.removeAttribute("phoneVerified"); // Reset cờ xác thực khi yêu cầu mã OTP mới
        session.setAttribute("regOtp", otp);
        session.setAttribute("regEmail", cleanEmail);
        if (phone != null && !phone.trim().isEmpty()) {
            session.setAttribute("regPhone", phone.trim());
        }
        session.setAttribute("regOtpTime", System.currentTimeMillis());

        // Gửi email qua Gmail SMTP
        com.ute.fooddelivery.service.EmailService.SendEmailResult sendResult = emailService.sendOtpEmail(cleanEmail, otp);

        if (sendResult.isSuccess()) {
            if (sendResult.isRealSmtp()) {
                // Gửi thật thành công qua Resend / Brevo / Gmail SMTP: không để lộ mã OTP trong JSON trả về
                String safeMsg = sendResult.getMessage().replace("\"", "\\\"").replace("\n", " ");
                resp.getWriter().write(String.format("{\"success\":true,\"isReal\":true,\"email\":\"%s\",\"message\":\"%s\"}", cleanEmail, safeMsg));
            } else {
                // Chế độ Dev Sandbox (dành cho cộng sự chưa cấu hình API): gửi kèm OTP để hiển thị nút điền nhanh
                resp.getWriter().write(String.format("{\"success\":true,\"isReal\":false,\"otp\":\"%s\",\"email\":\"%s\",\"message\":\"%s\"}", otp, cleanEmail, sendResult.getMessage()));
            }
        } else {
            // Gửi email thất bại (sai API key hoặc lỗi mạng)
            String safeMsg = sendResult.getMessage().replace("\"", "\\\"").replace("\n", " ");
            resp.getWriter().write(String.format("{\"success\":false,\"isReal\":false,\"message\":\"%s\"}", safeMsg));
        }
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
        String regEmail = (String) session.getAttribute("regEmail");
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
            session.setAttribute("emailVerified", true);
            session.setAttribute("verifiedEmail", regEmail);
            session.setAttribute("phoneVerified", true);
            resp.getWriter().write(String.format("{\"success\":true,\"message\":\"Xác thực email thành công!\",\"email\":\"%s\"}", regEmail != null ? regEmail : ""));
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
                
                // Nếu giỏ cũ đang chứa món của quán khác, dọn dẹp để ưu tiên món khách vừa chọn
                int currentRestId = -1;
                for (CartItem ci : cart.values()) {
                    if (ci.getFood() != null && ci.getFood().getRestaurantId() > 0) {
                        currentRestId = ci.getFood().getRestaurantId();
                        break;
                    }
                }
                if (currentRestId > 0 && food.getRestaurantId() > 0 && currentRestId != food.getRestaurantId()) {
                    cart.clear();
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
