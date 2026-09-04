package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Food;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FoodDAO {

    private static final String BASE_QUERY = 
        "SELECT f.food_id, f.name, f.description, f.price, f.image_url, f.is_available, " +
        "       f.category_id, c.name AS category_name, " +
        "       f.restaurant_id, r.name AS restaurant_name " +
        "FROM foods f " +
        "LEFT JOIN categories c ON f.category_id = c.category_id " +
        "LEFT JOIN restaurants r ON f.restaurant_id = r.restaurant_id ";

    public List<Food> getAllFoods() {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 ORDER BY f.food_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToFood(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn getAllFoods: " + e.getMessage());
        }
        return list;
    }

    public List<Food> getFoodsByCategory(int categoryId) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.category_id = ? ORDER BY f.food_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, categoryId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn getFoodsByCategory: " + e.getMessage());
        }
        return list;
    }

    public List<Food> searchFoods(String keyword) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND (f.name LIKE ? OR f.description LIKE ?) ORDER BY f.food_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    String pattern = "%" + keyword + "%";
                    ps.setString(1, pattern);
                    ps.setString(2, pattern);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm kiếm searchFoods: " + e.getMessage());
        }
        return list;
    }

    public Food getFoodById(int id) {
        String query = BASE_QUERY + "WHERE f.food_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToFood(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món theo ID: " + e.getMessage());
        }
        return null;
    }

    public List<Food> getFeaturedFoods(int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 ORDER BY f.food_id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, limit);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy featured foods: " + e.getMessage());
        }
        return list;
    }

    private Food mapResultSetToFood(ResultSet rs) throws Exception {
        return new Food(
            rs.getInt("food_id"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getDouble("price"),
            rs.getString("image_url"),
            rs.getInt("category_id"),
            rs.getString("category_name"),
            rs.getInt("restaurant_id"),
            rs.getString("restaurant_name"),
            rs.getInt("is_available") == 1
        );
    }
}
