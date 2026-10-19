package com.ute.fooddelivery.filter;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(filterName = "ShipperFilter", urlPatterns = {"/shipper/*"})
public class ShipperFilter implements Filter {
    private final DriverDAO driverDAO = new DriverDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String uri = req.getRequestURI();
        boolean isApiRequest = uri != null && (uri.contains("/api/") || "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With")));

        // 1. Kiểm tra đăng nhập
        if (currentUser == null) {
            if (isApiRequest) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập tài khoản Shipper!\"}");
                return;
            }
            String redirectUrl = req.getServletPath();
            if (req.getPathInfo() != null) {
                redirectUrl += req.getPathInfo();
            }
            if (req.getQueryString() != null) {
                redirectUrl += "?" + req.getQueryString();
            }
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=unauthorized_shipper&redirect="
                    + URLEncoder.encode(redirectUrl, StandardCharsets.UTF_8));
            return;
        }

        // 2. Kiểm tra vai trò: Phải là SHIPPER hoặc ADMIN
        if (!currentUser.isShipper() && !currentUser.isAdmin()) {
            if (isApiRequest) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Tài khoản không có quyền truy cập khu vực Shipper!\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=unauthorized_shipper");
            return;
        }

        // 3. Tự động gắn thông tin đối tác tài xế vào request attribute và kiểm tra trạng thái cấm (BANNED)
        try {
            Driver driver = driverDAO.getOrCreateDriverForUser(currentUser);
            req.setAttribute("currentDriver", driver);
            req.setAttribute("driver", driver);

            if (!currentUser.isAdmin() && driver != null && "BANNED".equalsIgnoreCase(driver.getStatus())) {
                if (isApiRequest) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":false,\"message\":\"Tài khoản đối tác tài xế của bạn đã bị khóa! Vui lòng liên hệ quản trị viên.\"}");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=account_banned");
                return;
            }
        } catch (Exception ex) {
            System.err.println(">> [ShipperFilter] Lỗi nạp thông tin Driver: " + ex.getMessage());
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
