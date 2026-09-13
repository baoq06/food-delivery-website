package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Review;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class ReviewDAO {

    // Thêm đánh giá
    public boolean addReview(Review review) {
        String sql = "INSERT INTO order_reviews (order_id, customer_id, driver_id, restaurant_id, rating, comment, food_rating, food_comment, driver_rating, driver_comment) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                // Auto-resolve restaurantId if missing
                if ((review.getRestaurantId() == null || review.getRestaurantId() <= 0) && review.getOrderId() > 0) {
                    String rSql = "SELECT f.restaurant_id FROM order_items oi JOIN foods f ON oi.food_id = f.food_id WHERE oi.order_id = ? LIMIT 1";
                    try (PreparedStatement psR = conn.prepareStatement(rSql)) {
                        psR.setInt(1, review.getOrderId());
                        try (ResultSet rsR = psR.executeQuery()) {
                            if (rsR.next()) {
                                review.setRestaurantId(rsR.getInt(1));
                            }
                        }
                    } catch (Exception ignored) {}
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, review.getOrderId());
                    ps.setInt(2, review.getCustomerId());
                    if (review.getDriverId() != null && review.getDriverId() > 0) ps.setInt(3, review.getDriverId()); else ps.setNull(3, Types.INTEGER);
                    if (review.getRestaurantId() != null && review.getRestaurantId() > 0) ps.setInt(4, review.getRestaurantId()); else ps.setNull(4, Types.INTEGER);
                    
                    // Overall rating / fallback
                    int foodR = review.getFoodRating() != null ? review.getFoodRating() : (review.getRating() > 0 ? review.getRating() : 5);
                    int driverR = review.getDriverRating() != null ? review.getDriverRating() : (review.getRating() > 0 ? review.getRating() : 5);
                    int overall = (foodR + driverR) / 2;
                    if (overall < 1) overall = 1;

                    ps.setInt(5, overall);
                    ps.setString(6, review.getComment() != null ? review.getComment() : (review.getFoodComment() != null ? review.getFoodComment() : "Đánh giá tốt"));

                    if (review.getFoodRating() != null) ps.setInt(7, review.getFoodRating()); else ps.setInt(7, foodR);
                    ps.setString(8, review.getFoodComment() != null ? review.getFoodComment() : review.getComment());

                    if (review.getDriverRating() != null) ps.setInt(9, review.getDriverRating()); else ps.setInt(9, driverR);
                    ps.setString(10, review.getDriverComment() != null ? review.getDriverComment() : review.getComment());
                    
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lưu đánh giá: " + e.getMessage());
        }
        return false;
    }
    
    // Tìm đánh giá theo mã đơn hàng
    public Review getReviewByOrderId(int orderId) {
        String sql = "SELECT * FROM order_reviews WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review review = new Review();
                    review.setReviewId(rs.getInt("review_id"));
                    review.setOrderId(rs.getInt("order_id"));
                    review.setCustomerId(rs.getInt("customer_id"));
                    review.setDriverId((Integer) rs.getObject("driver_id"));
                    review.setRestaurantId((Integer) rs.getObject("restaurant_id"));
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    
                    review.setFoodRating((Integer) rs.getObject("food_rating"));
                    review.setFoodComment(rs.getString("food_comment"));
                    review.setDriverRating((Integer) rs.getObject("driver_rating"));
                    review.setDriverComment(rs.getString("driver_comment"));
                    
                    review.setCreatedAt(rs.getTimestamp("created_at"));
                    return review;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi đọc đánh giá theo order_id: " + e.getMessage());
        }
        return null;
    }

    /**
     * Thống kê rating trung bình và số lượng đánh giá của Tài xế (Shipper)
     * Công thức: AVG(driver_rating) cho tất cả các đơn mà tài xế này đã giao.
     */
    public Map<String, Object> getDriverRatingStats(int driverId) {
        Map<String, Object> res = new HashMap<>();
        res.put("avgRating", 5.0);
        res.put("reviewCount", 0);

        String sql = "SELECT AVG(COALESCE(driver_rating, rating)) AS avg_r, COUNT(*) AS cnt " +
                     "FROM order_reviews WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("cnt");
                    if (count > 0) {
                        double avg = rs.getDouble("avg_r");
                        res.put("avgRating", Math.round(avg * 10.0) / 10.0);
                        res.put("reviewCount", count);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tính rating tài xế: " + e.getMessage());
        }
        return res;
    }

    /**
     * Thống kê rating trung bình của Món ăn
     */
    public Map<String, Object> getFoodRatingStats(int foodId) {
        Map<String, Object> res = new HashMap<>();
        res.put("avgRating", 5.0);
        res.put("reviewCount", 0);

        String sql = "SELECT AVG(COALESCE(r.food_rating, r.rating)) AS avg_r, COUNT(DISTINCT r.review_id) AS cnt " +
                     "FROM order_reviews r " +
                     "JOIN order_items oi ON r.order_id = oi.order_id " +
                     "WHERE oi.food_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("cnt");
                    if (count > 0) {
                        double avg = rs.getDouble("avg_r");
                        res.put("avgRating", Math.round(avg * 10.0) / 10.0);
                        res.put("reviewCount", count);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tính rating món ăn: " + e.getMessage());
        }
        return res;
    }

    /**
     * Thống kê Rating Tổng của Quán ăn (Restaurant Rating):
     * Quy tắc: Rating tổng của quán = AVG của tất cả các món mà quán hiện bán.
     * (Ví dụ quán có 2 món: món 1 có avg 5.0 sao, món 2 có avg 5.0 sao => rating tổng của quán = 5.0 sao).
     */
    public Map<String, Object> getRestaurantRatingStats(int restaurantId) {
        Map<String, Object> res = new HashMap<>();
        res.put("avgRating", 5.0);
        res.put("reviewCount", 0);

        String sql = 
            "SELECT AVG(food_avg) AS rest_avg, SUM(food_cnt) AS total_reviews " +
            "FROM (" +
            "   SELECT f.food_id, AVG(COALESCE(r.food_rating, r.rating)) AS food_avg, COUNT(r.review_id) AS food_cnt " +
            "   FROM foods f " +
            "   JOIN order_items oi ON f.food_id = oi.food_id " +
            "   JOIN order_reviews r ON oi.order_id = r.order_id " +
            "   WHERE f.restaurant_id = ? " +
            "   GROUP BY f.food_id " +
            ") sub";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalCnt = rs.getInt("total_reviews");
                    if (totalCnt > 0) {
                        double avg = rs.getDouble("rest_avg");
                        res.put("avgRating", Math.round(avg * 10.0) / 10.0);
                        res.put("reviewCount", totalCnt);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tính rating tổng của quán: " + e.getMessage());
        }
        return res;
    }
}
