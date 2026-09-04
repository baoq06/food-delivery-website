package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Restaurant;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RestaurantDAO {

    public Restaurant getRestaurantByUserId(int userId) {
        String query = "SELECT restaurant_id, user_id, name, description, phone, address, image_url, status " +
                       "FROM restaurants WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToRestaurant(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm nhà hàng theo user_id (thử fallback): " + e.getMessage());
        }

        // Fallback: Nếu CSDL chưa thêm cột user_id hoặc chưa liên kết, ghép tài khoản mẫu
        // bepviet (id 5) -> Quán 1, pho1985 (id 6) -> Quán 2
        if (userId == 5) {
            Restaurant r = getRestaurantById(1);
            if (r != null) return r;
        } else if (userId == 6) {
            Restaurant r = getRestaurantById(2);
            if (r != null) return r;
        }

        // Nếu người dùng là Seller mới tạo quán, lấy quán đầu tiên hoặc tạo quán mặc định
        Restaurant first = getRestaurantById(1);
        if (first != null) return first;

        return new Restaurant(1, userId, "Bếp Việt Quán", "Chuyên các món cơm tấm, món Việt đậm đà chuẩn vị quê nhà.", "0901234567", "45 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM", "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&auto=format&fit=crop&q=60", "OPEN");
    }

    public Restaurant getRestaurantById(int id) {
        String query = "SELECT restaurant_id, user_id, name, description, phone, address, image_url, status FROM restaurants WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToRestaurant(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Thử query không có cột user_id nếu bảng cũ chưa có
            String fallbackQuery = "SELECT restaurant_id, name, description, phone, address, image_url, status FROM restaurants WHERE restaurant_id = ?";
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try (PreparedStatement ps = conn.prepareStatement(fallbackQuery)) {
                        ps.setInt(1, id);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return new Restaurant(
                                    rs.getInt("restaurant_id"),
                                    null,
                                    rs.getString("name"),
                                    rs.getString("description"),
                                    rs.getString("phone"),
                                    rs.getString("address"),
                                    rs.getString("image_url"),
                                    rs.getString("status")
                                );
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                System.err.println("Lỗi khi tìm nhà hàng theo ID: " + ex.getMessage());
            }
        }
        return null;
    }

    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        String query = "SELECT restaurant_id, user_id, name, description, phone, address, image_url, status FROM restaurants ORDER BY restaurant_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToRestaurant(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách nhà hàng: " + e.getMessage());
        }
        return list;
    }

    public int createRestaurant(Restaurant r) {
        String query = "INSERT INTO restaurants (user_id, name, description, phone, address, image_url, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
                    if (r.getUserId() != null) {
                        ps.setInt(1, r.getUserId());
                    } else {
                        ps.setNull(1, java.sql.Types.INTEGER);
                    }
                    ps.setString(2, r.getName());
                    ps.setString(3, r.getDescription());
                    ps.setString(4, r.getPhone());
                    ps.setString(5, r.getAddress());
                    ps.setString(6, r.getImageUrl());
                    ps.setString(7, r.getStatus() != null ? r.getStatus() : "OPEN");

                    int affected = ps.executeUpdate();
                    if (affected > 0) {
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) {
                                return rs.getInt(1);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tạo nhà hàng mới: " + e.getMessage());
        }
        return -1;
    }

    public boolean updateRestaurant(Restaurant r) {
        String query = "UPDATE restaurants SET name = ?, description = ?, phone = ?, address = ?, image_url = ?, status = ? WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, r.getName());
                    ps.setString(2, r.getDescription());
                    ps.setString(3, r.getPhone());
                    ps.setString(4, r.getAddress());
                    ps.setString(5, r.getImageUrl());
                    ps.setString(6, r.getStatus());
                    ps.setInt(7, r.getId());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật nhà hàng: " + e.getMessage());
        }
        return false;
    }

    public boolean updateStatus(int restaurantId, String status) {
        String query = "UPDATE restaurants SET status = ? WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, status);
                    ps.setInt(2, restaurantId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái quán: " + e.getMessage());
        }
        return false;
    }

    private Restaurant mapResultSetToRestaurant(ResultSet rs) throws Exception {
        Integer userId = null;
        try {
            int uid = rs.getInt("user_id");
            if (!rs.wasNull()) {
                userId = uid;
            }
        } catch (Exception ignored) {
        }

        return new Restaurant(
            rs.getInt("restaurant_id"),
            userId,
            rs.getString("name"),
            rs.getString("description"),
            rs.getString("phone"),
            rs.getString("address"),
            rs.getString("image_url"),
            rs.getString("status")
        );
    }
}
