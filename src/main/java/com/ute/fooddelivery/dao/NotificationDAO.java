package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean createNotification(Notification notif) {
        String sql = "INSERT INTO notifications (user_id, order_id, title, message, type, link, is_read, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 0, NOW())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notif.getUserId());
            if (notif.getOrderId() != null && notif.getOrderId() > 0) {
                ps.setInt(2, notif.getOrderId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, notif.getTitle());
            ps.setString(4, notif.getMessage());
            ps.setString(5, notif.getType() != null ? notif.getType() : "ORDER");
            ps.setString(6, notif.getLink());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        notif.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tạo notification: " + e.getMessage());
        }
        return false;
    }

    public List<Notification> getNotificationsByUser(int userId, String filter) {
        List<Notification> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT notification_id, user_id, order_id, title, message, type, link, is_read, created_at FROM notifications WHERE user_id = ? ");

        if ("UNREAD".equalsIgnoreCase(filter)) {
            sql.append("AND is_read = 0 ");
        } else if ("ORDER".equalsIgnoreCase(filter)) {
            sql.append("AND type LIKE 'ORDER_%' ");
        } else if ("SYSTEM".equalsIgnoreCase(filter)) {
            sql.append("AND type = 'SYSTEM' ");
        }

        sql.append("ORDER BY created_at DESC LIMIT 50");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification(
                        rs.getInt("notification_id"),
                        rs.getInt("user_id"),
                        (Integer) rs.getObject("order_id"),
                        rs.getString("title"),
                        rs.getString("message"),
                        rs.getString("type"),
                        rs.getString("link"),
                        rs.getBoolean("is_read"),
                        rs.getTimestamp("created_at")
                    );
                    list.add(n);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách notification: " + e.getMessage());
        }
        return list;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi đếm notification chưa đọc: " + e.getMessage());
        }
        return 0;
    }

    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi đánh dấu đã đọc notification: " + e.getMessage());
        }
        return false;
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi đánh dấu tất cả đã đọc: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteNotification(int notificationId, int userId) {
        String sql = "DELETE FROM notifications WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi xóa notification: " + e.getMessage());
        }
        return false;
    }
}
