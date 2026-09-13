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
        "       f.restaurant_id, r.name AS restaurant_name, " +
        "       COALESCE(sub.avg_rating, 0.0) AS avg_rating, " +
        "       COALESCE(sub.review_count, 0) AS review_count " +
        "FROM foods f " +
        "LEFT JOIN categories c ON f.category_id = c.category_id " +
        "LEFT JOIN restaurants r ON f.restaurant_id = r.restaurant_id " +
        "LEFT JOIN (" +
        "    SELECT oi.food_id, " +
        "           ROUND(AVG(COALESCE(rv.food_rating, rv.rating)), 1) AS avg_rating, " +
        "           COUNT(DISTINCT rv.review_id) AS review_count " +
        "    FROM order_items oi " +
        "    JOIN order_reviews rv ON oi.order_id = rv.order_id " +
        "    GROUP BY oi.food_id " +
        ") sub ON f.food_id = sub.food_id ";

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

    public List<Food> getFoodsByRestaurantId(int restaurantId) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.restaurant_id = ? ORDER BY f.food_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món ăn theo nhà hàng: " + e.getMessage());
        }
        return list;
    }

    public boolean insertFood(Food food) {
        String query = "INSERT INTO foods (name, description, price, image_url, category_id, restaurant_id, is_available) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, food.getName());
                    ps.setString(2, food.getDescription());
                    ps.setDouble(3, food.getPrice());
                    ps.setString(4, food.getImageUrl() != null && !food.getImageUrl().trim().isEmpty() ? 
                                    food.getImageUrl() : "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80");
                    ps.setInt(5, food.getCategoryId());
                    ps.setInt(6, food.getRestaurantId());
                    ps.setInt(7, food.isAvailable() ? 1 : 0);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi thêm món ăn mới: " + e.getMessage());
        }
        return false;
    }

    public boolean updateFood(Food food) {
        String query = "UPDATE foods SET name = ?, description = ?, price = ?, image_url = ?, category_id = ?, is_available = ? " +
                       "WHERE food_id = ? AND restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, food.getName());
                    ps.setString(2, food.getDescription());
                    ps.setDouble(3, food.getPrice());
                    ps.setString(4, food.getImageUrl());
                    ps.setInt(5, food.getCategoryId());
                    ps.setInt(6, food.isAvailable() ? 1 : 0);
                    ps.setInt(7, food.getId());
                    ps.setInt(8, food.getRestaurantId());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật món ăn: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteFood(int foodId, int restaurantId) {
        String query = "DELETE FROM foods WHERE food_id = ? AND restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, foodId);
                    ps.setInt(2, restaurantId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            // Nếu ràng buộc khóa ngoại với order_items, chuyển sang tắt món (soft delete)
            return toggleAvailability(foodId, restaurantId, false);
        }
        return false;
    }

    public boolean toggleAvailability(int foodId, int restaurantId, boolean isAvailable) {
        String query = "UPDATE foods SET is_available = ? WHERE food_id = ? AND restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, isAvailable ? 1 : 0);
                    ps.setInt(2, foodId);
                    ps.setInt(3, restaurantId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi chuyển trạng thái món: " + e.getMessage());
        }
        return false;
    }

    private Food mapResultSetToFood(ResultSet rs) throws Exception {
        Food food = new Food(
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
        try {
            food.setRating(rs.getDouble("avg_rating"));
            food.setReviewCount(rs.getInt("review_count"));
        } catch (Exception ignored) {}
        return food;
    }
}
