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

@WebServlet(name = "NotificationController", urlPatterns = {
    "/notifications",
    "/api/notifications/unread-count",
    "/api/notifications/mark-read",
    "/api/notifications/recent",
    "/api/notifications/mark-all-read"
})
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

        // API Endpoint trả về danh sách tóm tắt vài thông báo mới nhất cho Popover
        if ("/api/notifications/recent".equalsIgnoreCase(servletPath)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (currentUser == null) {
                resp.getWriter().write("{\"success\":false,\"unreadCount\":0,\"notifications\":[]}");
                return;
            }
            int unreadCount = notificationDAO.getUnreadCount(currentUser.getId());
            List<Notification> recent = notificationDAO.getRecentNotifications(currentUser.getId(), 5);

            com.google.gson.JsonArray arr = new com.google.gson.JsonArray();
            for (Notification n : recent) {
                com.google.gson.JsonObject obj = new com.google.gson.JsonObject();
                obj.addProperty("id", n.getId());
                obj.addProperty("title", n.getTitle());
                obj.addProperty("message", n.getMessage());
                obj.addProperty("type", n.getType());
                obj.addProperty("link", n.getLink() != null ? n.getLink() : "");
                obj.addProperty("read", n.isRead());
                obj.addProperty("timeAgo", n.getTimeAgo());
                obj.addProperty("iconClass", n.getIconClass());
                arr.add(obj);
            }

            com.google.gson.JsonObject result = new com.google.gson.JsonObject();
            result.addProperty("success", true);
            result.addProperty("unreadCount", unreadCount);
            result.add("notifications", arr);

            resp.getWriter().write(result.toString());
            return;
        }

        // API Endpoint đánh dấu tất cả đã đọc qua AJAX
        if ("/api/notifications/mark-all-read".equalsIgnoreCase(servletPath)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (currentUser == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
                return;
            }
            notificationDAO.markAllAsRead(currentUser.getId());
            resp.getWriter().write("{\"success\":true,\"unreadCount\":0}");
            return;
        }

        // API Endpoint đánh dấu đã đọc một thông báo qua AJAX
        if ("/api/notifications/mark-read".equalsIgnoreCase(servletPath)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (currentUser == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
                return;
            }
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                notificationDAO.markAsRead(id, currentUser.getId());
                int count = notificationDAO.getUnreadCount(currentUser.getId());
                resp.getWriter().write("{\"success\":true,\"unreadCount\":" + count + "}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        // Trang danh sách thông báo
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + req.getServletPath());
            return;
        }

        // Xử lý khi người dùng nhấn "Xem chi tiết" -> Tự động đánh dấu đã đọc và chuyển hướng đến trang liên quan
        String action = req.getParameter("action");
        if ("readAndRedirect".equalsIgnoreCase(action) || "view".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                notificationDAO.markAsRead(id, currentUser.getId());
            } catch (Exception ignored) {}

            String redirect = req.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
                resp.sendRedirect(req.getContextPath() + (redirect.startsWith("/") ? redirect : "/" + redirect));
            } else {
                resp.sendRedirect(req.getContextPath() + "/notifications");
            }
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
