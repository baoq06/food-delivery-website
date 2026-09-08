package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Review;
import java.sql.*;

public class ReviewDAO {
    // Thêm đánh giá
    public boolean addReview(Review review) {
        String sql = "INSERT INTO order_reviews (order_id, customer_id, driver_id, restaurant_id, rating, comment) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, review.getOrderId());
            ps.setInt(2, review.getCustomerId());
            if (review.getDriverId() != null) ps.setInt(3, review.getDriverId()); else ps.setNull(3, Types.INTEGER);
            if (review.getRestaurantId() != null) ps.setInt(4, review.getRestaurantId()); else ps.setNull(4, Types.INTEGER);
            ps.setInt(5, review.getRating());
            ps.setString(6, review.getComment());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Kiểm tra xem đơn hàng đã được đánh giá chưa
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
                    review.setDriverId(rs.getInt("driver_id"));
                    if (rs.wasNull()) review.setDriverId(null);
                    review.setRestaurantId(rs.getInt("restaurant_id"));
                    if (rs.wasNull()) review.setRestaurantId(null);
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    review.setCreatedAt(rs.getTimestamp("created_at"));
                    return review;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
