package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Review;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
     * Thống kê Rating Tổng của Quán ăn (Restaurant Rating) từ dữ liệu thật:
     * - Điểm trung bình thật (avgRating), nếu 0 review trả về 0.0
     * - Tổng số lượt đánh giá thật (reviewCount)
     * - Phân bố số sao 5★, 4★, 3★, 2★, 1★ (ratingBreakdown)
     */
    public Map<String, Object> getRestaurantRatingStats(int restaurantId) {
        Map<String, Object> res = new HashMap<>();
        res.put("avgRating", 0.0);
        res.put("reviewCount", 0);
        Map<Integer, Integer> breakdown = new HashMap<>();
        breakdown.put(5, 0);
        breakdown.put(4, 0);
        breakdown.put(3, 0);
        breakdown.put(2, 0);
        breakdown.put(1, 0);
        res.put("breakdown", breakdown);

        String sql = 
            "SELECT " +
            "   COUNT(DISTINCT r.review_id) AS total_reviews, " +
            "   AVG(COALESCE(r.food_rating, r.rating)) AS avg_r, " +
            "   SUM(CASE WHEN ROUND(COALESCE(r.food_rating, r.rating)) >= 5 THEN 1 ELSE 0 END) AS star_5, " +
            "   SUM(CASE WHEN ROUND(COALESCE(r.food_rating, r.rating)) = 4 THEN 1 ELSE 0 END) AS star_4, " +
            "   SUM(CASE WHEN ROUND(COALESCE(r.food_rating, r.rating)) = 3 THEN 1 ELSE 0 END) AS star_3, " +
            "   SUM(CASE WHEN ROUND(COALESCE(r.food_rating, r.rating)) = 2 THEN 1 ELSE 0 END) AS star_2, " +
            "   SUM(CASE WHEN ROUND(COALESCE(r.food_rating, r.rating)) <= 1 THEN 1 ELSE 0 END) AS star_1 " +
            "FROM order_reviews r " +
            "LEFT JOIN order_items oi ON r.order_id = oi.order_id " +
            "LEFT JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE r.restaurant_id = ? OR f.restaurant_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            ps.setInt(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalCnt = rs.getInt("total_reviews");
                    if (totalCnt > 0) {
                        double avg = rs.getDouble("avg_r");
                        res.put("avgRating", Math.round(avg * 10.0) / 10.0);
                        res.put("reviewCount", totalCnt);
                        breakdown.put(5, rs.getInt("star_5"));
                        breakdown.put(4, rs.getInt("star_4"));
                        breakdown.put(3, rs.getInt("star_3"));
                        breakdown.put(2, rs.getInt("star_2"));
                        breakdown.put(1, rs.getInt("star_1"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi tính rating tổng của quán: " + e.getMessage());
        }
        return res;
    }

    /**
     * Lấy danh sách đánh giá & bình luận của người dùng cho Quán Ăn
     */
    public List<Review> getReviewsByRestaurantId(int restaurantId, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = 
            "SELECT r.review_id, r.order_id, r.customer_id, r.restaurant_id, r.driver_id, " +
            "       r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, " +
            "       r.created_at, COALESCE(u.name, o.customer_name, 'Khách hàng Utee') AS cust_name, " +
            "       GROUP_CONCAT(CONCAT(f.name, ' (x', oi.quantity, ')') SEPARATOR ', ') AS ordered_foods " +
            "FROM order_reviews r " +
            "LEFT JOIN users u ON r.customer_id = u.user_id " +
            "LEFT JOIN orders o ON r.order_id = o.order_id " +
            "LEFT JOIN order_items oi ON r.order_id = oi.order_id " +
            "LEFT JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE r.restaurant_id = ? OR f.restaurant_id = ? " +
            "GROUP BY r.review_id, r.order_id, r.customer_id, r.restaurant_id, r.driver_id, " +
            "         r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, " +
            "         r.created_at, u.name, o.customer_name " +
            "ORDER BY r.created_at DESC " +
            (limit > 0 ? "LIMIT ?" : "");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            ps.setInt(2, restaurantId);
            if (limit > 0) {
                ps.setInt(3, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rev = mapResultSetToReview(rs);
                    rev.setOrderedFoods(rs.getString("ordered_foods"));
                    list.add(rev);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy danh sách đánh giá của quán: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy danh sách đánh giá & bình luận của người dùng cho Món Ăn
     */
    public List<Review> getReviewsByFoodId(int foodId, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = 
            "SELECT r.review_id, r.order_id, r.customer_id, r.restaurant_id, r.driver_id, " +
            "       r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, " +
            "       r.created_at, COALESCE(u.name, o.customer_name, 'Khách hàng Utee') AS cust_name, " +
            "       f.name AS food_name " +
            "FROM order_reviews r " +
            "JOIN order_items oi ON r.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "LEFT JOIN users u ON r.customer_id = u.user_id " +
            "LEFT JOIN orders o ON r.order_id = o.order_id " +
            "WHERE oi.food_id = ? " +
            "GROUP BY r.review_id, r.order_id, r.customer_id, r.restaurant_id, r.driver_id, " +
            "         r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, " +
            "         r.created_at, u.name, o.customer_name, f.name " +
            "ORDER BY r.created_at DESC " +
            (limit > 0 ? "LIMIT ?" : "");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            if (limit > 0) {
                ps.setInt(2, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rev = mapResultSetToReview(rs);
                    rev.setOrderedFoods(rs.getString("food_name"));
                    list.add(rev);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy danh sách đánh giá của món: " + e.getMessage());
        }
        return list;
    }

    /**
     * Nạp nhanh các đánh giá gần nhất cho nhiều món ăn cùng lúc (tối ưu hiệu năng 1 truy vấn)
     */
    public Map<Integer, List<Review>> getRecentReviewsForFoods(List<Integer> foodIds, int maxPerFood) {
        Map<Integer, List<Review>> map = new HashMap<>();
        if (foodIds == null || foodIds.isEmpty()) return map;

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < foodIds.size(); i++) {
            inClause.append(i == 0 ? "?" : ", ?");
        }

        String sql = 
            "SELECT oi.food_id, r.review_id, r.order_id, r.customer_id, r.restaurant_id, r.driver_id, " +
            "       r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, " +
            "       r.created_at, COALESCE(u.name, o.customer_name, 'Khách hàng Utee') AS cust_name " +
            "FROM order_reviews r " +
            "JOIN order_items oi ON r.order_id = oi.order_id " +
            "LEFT JOIN users u ON r.customer_id = u.user_id " +
            "LEFT JOIN orders o ON r.order_id = o.order_id " +
            "WHERE oi.food_id IN (" + inClause + ") " +
            "ORDER BY r.created_at DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < foodIds.size(); i++) {
                ps.setInt(i + 1, foodIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int fId = rs.getInt("food_id");
                    List<Review> revList = map.computeIfAbsent(fId, k -> new ArrayList<>());
                    if (maxPerFood <= 0 || revList.size() < maxPerFood) {
                        Review rev = mapResultSetToReview(rs);
                        revList.add(rev);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy recent reviews cho danh sách món: " + e.getMessage());
        }
        return map;
    }

    private Review mapResultSetToReview(ResultSet rs) {
        Review review = new Review();
        try { review.setReviewId(rs.getInt("review_id")); } catch (Exception ignored) {}
        try { review.setOrderId(rs.getInt("order_id")); } catch (Exception ignored) {}
        try { review.setCustomerId(rs.getInt("customer_id")); } catch (Exception ignored) {}
        try { review.setDriverId((Integer) rs.getObject("driver_id")); } catch (Exception ignored) {}
        try { review.setRestaurantId((Integer) rs.getObject("restaurant_id")); } catch (Exception ignored) {}
        try { review.setRating(rs.getInt("rating")); } catch (Exception ignored) {}
        try { review.setComment(rs.getString("comment")); } catch (Exception ignored) {}
        try { review.setFoodRating((Integer) rs.getObject("food_rating")); } catch (Exception ignored) {}
        try { review.setFoodComment(rs.getString("food_comment")); } catch (Exception ignored) {}
        try { review.setDriverRating((Integer) rs.getObject("driver_rating")); } catch (Exception ignored) {}
        try { review.setDriverComment(rs.getString("driver_comment")); } catch (Exception ignored) {}
        try { review.setCreatedAt(rs.getTimestamp("created_at")); } catch (Exception ignored) {}
        try { review.setCustomerName(rs.getString("cust_name")); } catch (Exception ignored) {}
        return review;
    }
}
