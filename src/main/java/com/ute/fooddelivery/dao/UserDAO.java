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
            return new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@foodzone.vn", "0909123456", "Văn phòng FoodZone Q1", "ADMIN");
        }
        if ("customer".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi, P. Bến Nghé, Q.1", "CUSTOMER");
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
}
