package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.UserService;
import com.ute.fooddelivery.utils.CookieUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AuthController", urlPatterns = {"/auth"})
public class AuthController extends HttpServlet {
    private final UserService userService = new UserService();
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
            resp.sendRedirect(req.getContextPath() + "/home");
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

        if ("login".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String remember = req.getParameter("remember");

            User user = userService.login(username, password);

            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("currentUser", user);

                // Xử lý Cookie Remember Me
                if (remember != null) {
                    CookieUtils.addCookie(resp, "remember_user", username, REMEMBER_ME_AGE);
                } else {
                    CookieUtils.deleteCookie(resp, "remember_user");
                }

                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
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
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");

            // Sticky Form & Validation khi đăng ký
            String validationError = null;
            if (fullName == null || fullName.trim().isEmpty() ||
                username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                validationError = "Vui lòng điền đầy đủ các thông tin bắt buộc (*)!";
            } else if (password.trim().length() < 6) {
                validationError = "Mật khẩu bảo mật phải có ít nhất 6 ký tự!";
            } else if (!phone.trim().matches("^0[0-9]{9,10}$")) {
                validationError = "Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam 10-11 chữ số bắt đầu bằng số 0.";
            }

            if (validationError != null) {
                req.setAttribute("errorMessage", validationError);
                // Giữ lại dữ liệu đã nhập (Sticky Form)
                req.setAttribute("stickyRegFullName", fullName);
                req.setAttribute("stickyRegUsername", username);
                req.setAttribute("stickyRegPhone", phone);
                req.setAttribute("stickyRegAddress", address);
                req.setAttribute("activeTab", "registerTab");
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            User newUser = new User(0, username.trim(), password, fullName.trim(), username.trim() + "@gmail.com", phone.trim(), address.trim(), "CUSTOMER");
            boolean created = userService.register(newUser);

            if (!created) {
                req.setAttribute("errorMessage", "Tên đăng nhập '" + username + "' đã được sử dụng! Vui lòng chọn tên khác.");
                req.setAttribute("stickyRegFullName", fullName);
                req.setAttribute("stickyRegPhone", phone);
                req.setAttribute("stickyRegAddress", address);
                req.setAttribute("activeTab", "registerTab");
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
                return;
            }

            // Đăng nhập luôn cho user sau khi đăng ký thành công
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", newUser);
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}
