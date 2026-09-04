package com.ute.fooddelivery.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet đóng vai trò Default Handler bắt toàn bộ các đường dẫn (URL) không tồn tại
 * trong ứng dụng web để tự động điều hướng sang trang 404.jsp.
 */
@WebServlet(name = "NotFoundServlet", urlPatterns = {"/"})
public class NotFoundServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handleNotFound(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handleNotFound(req, resp);
    }

    private void handleNotFound(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        // 1. Nếu là đường dẫn gốc (root context)
        if (path == null || path.isEmpty() || "/".equals(path)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // 2. Nếu là tài nguyên tĩnh thực tế có trên đĩa (CSS, JS, Hình ảnh, JSP...)
        try {
            if (getServletContext().getResource(path) != null) {
                // Nhường lại cho DefaultServlet gốc của container phục vụ
                getServletContext().getNamedDispatcher("default").forward(req, resp);
                return;
            }
        } catch (Exception ignored) {
        }

        // 3. Nếu đường dẫn hoàn toàn không tồn tại trong hệ thống:
        // Đặt mã trạng thái 404 và chuyển tiếp ngay tới trang lỗi 404.jsp
        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        req.getRequestDispatcher("/error/404.jsp").forward(req, resp);
    }
}
