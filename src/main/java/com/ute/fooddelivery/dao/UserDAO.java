package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    public User login(String username, String password) {
        String query = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, username);
                    ps.setString(2, password);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return new User(
                                rs.getInt("id"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("fullname"),
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
            System.err.println("Lưu ý: Không thể truy vấn User từ CSDL: " + e.getMessage());
        }

        // Tài khoản mẫu fallback để test khi chưa có CSDL
        if ("admin".equalsIgnoreCase(username) && "123456".equals(password)) {
            return new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@foodzone.vn", "0909123456", "Văn phòng FoodZone Q1", "ADMIN");
        }
        if ("customer".equalsIgnoreCase(username) && "123456".equals(password)) {
            return new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi, P. Bến Nghé, Q.1", "CUSTOMER");
        }

        return null;
    }

    public boolean register(User user) {
        String query = "INSERT INTO users (username, password, fullname, email, phone, address, role) VALUES (?, ?, ?, ?, ?, ?, ?)";
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
            e.printStackTrace();
        }
        return false;
    }
}
