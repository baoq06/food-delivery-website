package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.UserService;
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
        req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("login".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            User user = userService.login(username, password);

            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("currentUser", user);
                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/home");
                }
            } else {
                req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
                req.getRequestDispatcher("/WEB-INF/views/client/login.jsp").forward(req, resp);
            }
        } else if ("register".equalsIgnoreCase(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");

            User newUser = new User(0, username, password, fullName, username + "@gmail.com", phone, address, "CUSTOMER");
            userService.register(newUser);

            // Đăng nhập luôn cho user sau khi đăng ký
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", newUser);
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}
