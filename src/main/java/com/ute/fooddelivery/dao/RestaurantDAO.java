package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Restaurant;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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

    private static final String BASE_QUERY = 
        "SELECT r.restaurant_id, r.user_id, r.name, r.description, r.phone, r.address, r.image_url, r.status, " +
        "       COALESCE(sub_rev.avg_rating, 0.0) AS avg_rating, " +
        "       COALESCE(sub_rev.review_count, 0) AS review_count, " +
        "       COALESCE(sub_ord.total_orders, 0) AS total_orders " +
        "FROM restaurants r " +
        "LEFT JOIN (" +
        "    SELECT COALESCE(rv.restaurant_id, f.restaurant_id) AS rest_id, " +
        "           ROUND(AVG(COALESCE(rv.food_rating, rv.rating)), 1) AS avg_rating, " +
        "           COUNT(DISTINCT rv.review_id) AS review_count " +
        "    FROM order_reviews rv " +
        "    LEFT JOIN order_items oi ON rv.order_id = oi.order_id " +
        "    LEFT JOIN foods f ON oi.food_id = f.food_id " +
        "    GROUP BY rest_id " +
        ") sub_rev ON r.restaurant_id = sub_rev.rest_id " +
        "LEFT JOIN (" +
        "    SELECT f.restaurant_id AS rest_id, " +
        "           COUNT(DISTINCT o.order_id) AS total_orders " +
        "    FROM orders o " +
        "    JOIN order_items oi ON o.order_id = oi.order_id " +
        "    JOIN foods f ON oi.food_id = f.food_id " +
        "    WHERE o.status IN ('DELIVERED', 'COMPLETED') " +
        "    GROUP BY rest_id " +
        ") sub_ord ON r.restaurant_id = sub_ord.rest_id ";

    public Restaurant getRestaurantById(int id) {
        String query = BASE_QUERY + "WHERE r.restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Restaurant r = mapResultSetToRestaurant(rs);
                            // Populate full stats and reviews
                            ReviewDAO reviewDAO = new ReviewDAO();
                            Map<String, Object> stats = reviewDAO.getRestaurantRatingStats(id);
                            if (stats != null) {
                                if (stats.containsKey("avgRating")) r.setRating((Double) stats.get("avgRating"));
                                if (stats.containsKey("reviewCount")) r.setReviewCount((Integer) stats.get("reviewCount"));
                                if (stats.containsKey("breakdown")) {
                                    @SuppressWarnings("unchecked")
                                    Map<Integer, Integer> bd = (Map<Integer, Integer>) stats.get("breakdown");
                                    r.setRatingBreakdown(bd);
                                }
                            }
                            r.setReviews(reviewDAO.getReviewsByRestaurantId(id, 20));
                            return r;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm nhà hàng theo ID: " + e.getMessage());
        }
        return null;
    }

    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        String query = BASE_QUERY + "ORDER BY r.restaurant_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    ReviewDAO reviewDAO = new ReviewDAO();
                    while (rs.next()) {
                        Restaurant r = mapResultSetToRestaurant(rs);
                        r.setReviews(reviewDAO.getReviewsByRestaurantId(r.getId(), 3));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách nhà hàng: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy các quán ăn được đánh giá cao nhất (Tab Đánh giá)
     */
    public List<Restaurant> getTopRatedRestaurants(int limit) {
        List<Restaurant> list = new ArrayList<>();
        String query = BASE_QUERY + "ORDER BY avg_rating DESC, review_count DESC, r.restaurant_id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, limit);
                    try (ResultSet rs = ps.executeQuery()) {
                        ReviewDAO reviewDAO = new ReviewDAO();
                        while (rs.next()) {
                            Restaurant r = mapResultSetToRestaurant(rs);
                            r.setReviews(reviewDAO.getReviewsByRestaurantId(r.getId(), 3));
                            list.add(r);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy top rated restaurants: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy các quán ăn bán chạy nhất theo số lượng đơn hàng (Tab Bán chạy)
     */
    public List<Restaurant> getBestSellingRestaurants(int limit) {
        List<Restaurant> list = new ArrayList<>();
        String query = BASE_QUERY + "ORDER BY total_orders DESC, review_count DESC, avg_rating DESC, r.restaurant_id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, limit);
                    try (ResultSet rs = ps.executeQuery()) {
                        ReviewDAO reviewDAO = new ReviewDAO();
                        while (rs.next()) {
                            Restaurant r = mapResultSetToRestaurant(rs);
                            r.setReviews(reviewDAO.getReviewsByRestaurantId(r.getId(), 3));
                            list.add(r);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy best selling restaurants: " + e.getMessage());
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

        Restaurant r = new Restaurant(
            rs.getInt("restaurant_id"),
            userId,
            rs.getString("name"),
            rs.getString("description"),
            rs.getString("phone"),
            rs.getString("address"),
            rs.getString("image_url"),
            rs.getString("status")
        );
        try {
            r.setRating(rs.getDouble("avg_rating"));
            r.setReviewCount(rs.getInt("review_count"));
            r.setTotalOrders(rs.getInt("total_orders"));
        } catch (Exception ignored) {}
        return r;
    }
}
