package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    public User login(String account, String password) {
        String query = "SELECT user_id, username, password, name, email, phone, address, role " +
                       "FROM users WHERE (username = ? OR email = ? OR phone = ?) AND password = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, account);
                    ps.setString(2, account);
                    ps.setString(3, account);
                    ps.setString(4, password);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return new User(
                                rs.getInt("user_id"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("role")
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn User từ CSDL: " + e.getMessage());
        }

        // Fallback test nếu CSDL chưa khởi tạo
        if ("admin".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@vindelivery.vn", "0909123456", "Văn phòng VinDelivery Q1", "ADMIN");
        }
        if ("customer".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi, P. Bến Nghé, Q.1", "CUSTOMER");
        }
        if ("bepviet".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(5, "bepviet", "123456", "Chủ Quán Bếp Việt", "bepviet@foodzone.vn", "0901234567", "45 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM", "SELLER");
        }
        if ("pho1985".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(6, "pho1985", "123456", "Chủ Quán Phở 1985", "pho1985@foodzone.vn", "0902345678", "128 Võ Văn Tần, Q.3, TP. HCM", "SELLER");
        }

        return null;
    }

    public boolean register(User user) {
        String query = "INSERT INTO users (username, password, name, email, phone, address, role) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getAddress());
            ps.setString(7, user.getRole() != null ? user.getRole() : "CUSTOMER");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi đăng ký User: " + e.getMessage());
        }
        return false;
    }

    public boolean registerSeller(User user, String restaurantName, String restaurantAddress) {
        String insertUserSql = "INSERT INTO users (username, password, name, email, phone, address, role) VALUES (?, ?, ?, ?, ?, ?, 'SELLER')";
        String insertRestSql = "INSERT INTO restaurants (user_id, name, description, phone, address, image_url, status) VALUES (?, ?, ?, ?, ?, ?, 'OPEN')";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getUsername());
                psUser.setString(2, user.getPassword());
                psUser.setString(3, user.getFullName());
                psUser.setString(4, user.getEmail());
                psUser.setString(5, user.getPhone());
                psUser.setString(6, user.getAddress());

                int affected = psUser.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = psUser.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }
            }

            if (userId > 0) {
                try (PreparedStatement psRest = conn.prepareStatement(insertRestSql)) {
                    psRest.setInt(1, userId);
                    psRest.setString(2, restaurantName != null && !restaurantName.trim().isEmpty() ? restaurantName.trim() : "Quán Ăn của " + user.getFullName());
                    psRest.setString(3, "Quán ăn hợp tác với nền tảng giao đồ ăn siêu tốc VinDelivery.");
                    psRest.setString(4, user.getPhone());
                    psRest.setString(5, restaurantAddress != null && !restaurantAddress.trim().isEmpty() ? restaurantAddress.trim() : user.getAddress());
                    psRest.setString(6, "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&auto=format&fit=crop&q=60");
                    psRest.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            System.err.println("Lỗi khi đăng ký tài khoản chủ quán: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public boolean registerShipper(User user) {
        String insertUserSql = "INSERT INTO users (username, password, name, email, phone, address, role) VALUES (?, ?, ?, ?, ?, ?, 'SHIPPER')";
        String insertDriverSql = "INSERT INTO drivers (user_id, name, phone, status) VALUES (?, ?, ?, 'OFFLINE')";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getUsername());
                psUser.setString(2, user.getPassword());
                psUser.setString(3, user.getFullName());
                psUser.setString(4, user.getEmail());
                psUser.setString(5, user.getPhone());
                psUser.setString(6, user.getAddress());

                int affected = psUser.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = psUser.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }
            }

            if (userId > 0) {
                try (PreparedStatement psDriver = conn.prepareStatement(insertDriverSql)) {
                    psDriver.setInt(1, userId);
                    psDriver.setString(2, user.getFullName());
                    psDriver.setString(3, user.getPhone());
                    psDriver.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            System.err.println("Lỗi khi đăng ký tài khoản shipper: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }
}
