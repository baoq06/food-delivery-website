package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.NotificationDAO;
import com.ute.fooddelivery.model.Notification;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "NotificationController", urlPatterns = {"/notifications", "/api/notifications/unread-count"})
public class NotificationController extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String servletPath = req.getServletPath();

        // API Endpoint trả về số thông báo chưa đọc (AJAX polling)
        if ("/api/notifications/unread-count".equalsIgnoreCase(servletPath)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            int count = 0;
            if (currentUser != null) {
                count = notificationDAO.getUnreadCount(currentUser.getId());
            }
            resp.getWriter().write("{\"unreadCount\":" + count + "}");
            return;
        }

        // Trang danh sách thông báo
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        String filter = req.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "ALL";
        }

        List<Notification> notifications = notificationDAO.getNotificationsByUser(currentUser.getId(), filter);
        int unreadCount = notificationDAO.getUnreadCount(currentUser.getId());

        req.setAttribute("notifications", notifications);
        req.setAttribute("unreadCount", unreadCount);
        req.setAttribute("currentFilter", filter);

        req.getRequestDispatcher("/WEB-INF/views/common/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        if ("markAsRead".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                notificationDAO.markAsRead(id, currentUser.getId());
            } catch (Exception ignored) {}
        } else if ("markAllAsRead".equalsIgnoreCase(action)) {
            notificationDAO.markAllAsRead(currentUser.getId());
            session.setAttribute("flashMessage", "Đã đánh dấu tất cả thông báo là đã đọc!");
        } else if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                notificationDAO.deleteNotification(id, currentUser.getId());
            } catch (Exception ignored) {}
        }

        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
            resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }
}
