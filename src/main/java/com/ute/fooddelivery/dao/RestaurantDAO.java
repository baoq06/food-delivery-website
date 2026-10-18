package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Restaurant;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RestaurantDAO {
    private static volatile boolean logoColumnChecked = false;
    private static volatile boolean hasLogoColumn = false;
    private static volatile boolean bankColumnsChecked = false;
    private static volatile boolean hasBankColumns = false;

    public static boolean checkHasLogoColumn() {
        if (logoColumnChecked) return hasLogoColumn;
        synchronized (RestaurantDAO.class) {
            if (logoColumnChecked) return hasLogoColumn;
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    DatabaseMetaData meta = conn.getMetaData();
                    try (ResultSet rs = meta.getColumns(null, null, "restaurants", "logo_url")) {
                        if (rs.next()) {
                            hasLogoColumn = true;
                        }
                    }
                    if (!hasLogoColumn) {
                        try (Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN logo_url VARCHAR(500) DEFAULT NULL AFTER image_url");
                            hasLogoColumn = true;
                            System.out.println(">> Đã thêm cột logo_url vào bảng restaurants");
                        } catch (Exception ignore) {}
                    }
                }
            } catch (Exception ignored) {}
            logoColumnChecked = true;
            return hasLogoColumn;
        }
    }

    public static boolean checkHasBankColumns() {
        if (bankColumnsChecked) return hasBankColumns;
        synchronized (RestaurantDAO.class) {
            if (bankColumnsChecked) return hasBankColumns;
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    DatabaseMetaData meta = conn.getMetaData();
                    try (ResultSet rs = meta.getColumns(null, null, "restaurants", "bank_account_no")) {
                        if (rs.next()) {
                            hasBankColumns = true;
                        }
                    }
                    if (!hasBankColumns) {
                        try (Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN bank_code VARCHAR(50) DEFAULT 'TCB'");
                            stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN bank_name VARCHAR(100) DEFAULT 'Techcombank'");
                            stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN bank_account_no VARCHAR(50) DEFAULT '1907 2878 4280 15'");
                            stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN bank_account_name VARCHAR(150) DEFAULT 'LE HAI DANG'");
                            hasBankColumns = true;
                            System.out.println(">> Đã thêm các cột tài khoản ngân hàng (bank_code, bank_name, bank_account_no, bank_account_name) vào bảng restaurants");
                        } catch (Exception e) {
                            System.err.println(">> Lỗi thêm cột bank vào restaurants: " + e.getMessage());
                        }
                    }
                }
            } catch (Exception ignored) {}
            bankColumnsChecked = true;
            return hasBankColumns;
        }
    }

    private static String getBaseQuery() {
        boolean withLogo = checkHasLogoColumn();
        boolean withBank = checkHasBankColumns();
        return "SELECT r.restaurant_id, r.user_id, r.name, r.description, r.phone, r.address, r.image_url, " +
               (withLogo ? "r.logo_url, " : "r.image_url AS logo_url, ") +
               (withBank ? "r.bank_code, r.bank_name, r.bank_account_no, r.bank_account_name, " : "'TCB' AS bank_code, 'Techcombank' AS bank_name, '1907 2878 4280 15' AS bank_account_no, 'LE HAI DANG' AS bank_account_name, ") +
               "r.status, r.latitude, r.longitude, " +
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
    }

    public Restaurant getRestaurantByUserId(int userId) {
        String query = getBaseQuery() + "WHERE r.user_id = ?";
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

        Restaurant defaultRest = new Restaurant(1, userId, "Bếp Việt Quán", "Chuyên các món cơm tấm, món Việt đậm đà chuẩn vị quê nhà.", "0901234567", "45 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM", "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&auto=format&fit=crop&q=60", "OPEN");
        defaultRest.setLatitude(com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LAT);
        defaultRest.setLongitude(com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LNG);
        return defaultRest;
    }

    public Restaurant getRestaurantById(int id) {
        String query = getBaseQuery() + "WHERE r.restaurant_id = ?";
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
        String query = getBaseQuery() + "ORDER BY r.restaurant_id ASC";
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

    public List<Restaurant> searchRestaurants(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllRestaurants();
        }
        List<Restaurant> list = new ArrayList<>();
        String query = getBaseQuery() + 
                       "WHERE LOWER(r.name) LIKE ? OR r.phone LIKE ? OR LOWER(r.address) LIKE ? " +
                       "ORDER BY r.restaurant_id ASC";
        String pattern = "%" + keyword.trim().toLowerCase() + "%";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, pattern);
                    ps.setString(2, pattern);
                    ps.setString(3, pattern);
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
            System.err.println("Lỗi khi tìm kiếm quán ăn: " + e.getMessage());
        }
        return list;
    }

    public Restaurant getRestaurantByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return null;
        String cleanPhone = phone.trim().replaceAll("[\\s\\-\\.\\(\\)]", "");
        String query = getBaseQuery() + 
                       "WHERE REPLACE(REPLACE(REPLACE(REPLACE(r.phone, ' ', ''), '-', ''), '.', ''), '+84', '0') = ? " +
                       "OR r.phone = ? " +
                       "LIMIT 1";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    String formatted = cleanPhone.startsWith("+84") ? ("0" + cleanPhone.substring(3)) : cleanPhone;
                    ps.setString(1, formatted);
                    ps.setString(2, phone.trim());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToRestaurant(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm quán ăn qua SĐT: " + e.getMessage());
        }
        return null;
    }

    public boolean banRestaurantByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String cleanPhone = phone.trim().replaceAll("[\\s\\-\\.\\(\\)]", "");
        String formatted = cleanPhone.startsWith("+84") ? ("0" + cleanPhone.substring(3)) : cleanPhone;
        String query = "UPDATE restaurants SET status = 'BANNED' " +
                       "WHERE REPLACE(REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '.', ''), '+84', '0') = ? " +
                       "OR phone = ? " +
                       "OR user_id IN (SELECT user_id FROM users WHERE REPLACE(REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '.', ''), '+84', '0') = ? OR phone = ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, formatted);
                    ps.setString(2, phone.trim());
                    ps.setString(3, formatted);
                    ps.setString(4, phone.trim());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cấm quán ăn qua SĐT: " + e.getMessage());
        }
        return false;
    }

    public boolean unbanRestaurantByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String cleanPhone = phone.trim().replaceAll("[\\s\\-\\.\\(\\)]", "");
        String formatted = cleanPhone.startsWith("+84") ? ("0" + cleanPhone.substring(3)) : cleanPhone;
        String query = "UPDATE restaurants SET status = 'OPEN' " +
                       "WHERE REPLACE(REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '.', ''), '+84', '0') = ? " +
                       "OR phone = ? " +
                       "OR user_id IN (SELECT user_id FROM users WHERE REPLACE(REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '.', ''), '+84', '0') = ? OR phone = ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, formatted);
                    ps.setString(2, phone.trim());
                    ps.setString(3, formatted);
                    ps.setString(4, phone.trim());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi gỡ cấm quán ăn qua SĐT: " + e.getMessage());
        }
        return false;
    }

    /**
     * Lấy các quán ăn được đánh giá cao nhất (Tab Đánh giá)
     */
    public List<Restaurant> getTopRatedRestaurants(int limit) {
        List<Restaurant> list = new ArrayList<>();
        String query = getBaseQuery() + "WHERE r.status = 'OPEN' ORDER BY avg_rating DESC, review_count DESC, r.restaurant_id ASC LIMIT ?";
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
        String query = getBaseQuery() + "WHERE r.status = 'OPEN' ORDER BY total_orders DESC, review_count DESC, avg_rating DESC, r.restaurant_id ASC LIMIT ?";
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
        boolean withLogo = checkHasLogoColumn();
        boolean withBank = checkHasBankColumns();
        String query = "UPDATE restaurants SET name = ?, description = ?, phone = ?, address = ?, image_url = ?, " +
                       (withLogo ? "logo_url = ?, " : "") +
                       (withBank ? "bank_code = ?, bank_name = ?, bank_account_no = ?, bank_account_name = ?, " : "") +
                       "status = ? WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    int idx = 1;
                    ps.setString(idx++, r.getName());
                    ps.setString(idx++, r.getDescription());
                    ps.setString(idx++, r.getPhone());
                    ps.setString(idx++, r.getAddress());
                    ps.setString(idx++, r.getImageUrl());
                    if (withLogo) {
                        ps.setString(idx++, r.getLogoUrl());
                    }
                    if (withBank) {
                        ps.setString(idx++, r.getBankCode());
                        ps.setString(idx++, r.getBankName());
                        ps.setString(idx++, r.getBankAccountNo());
                        ps.setString(idx++, r.getBankAccountName());
                    }
                    ps.setString(idx++, r.getStatus());
                    ps.setInt(idx++, r.getId());
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
            String logo = rs.getString("logo_url");
            r.setLogoUrl(logo != null && !logo.trim().isEmpty() ? logo : r.getImageUrl());
        } catch (Exception ignored) {
            r.setLogoUrl(r.getImageUrl());
        }
        try {
            String bCode = rs.getString("bank_code");
            if (bCode != null && !bCode.trim().isEmpty()) r.setBankCode(bCode.trim());
        } catch (Exception ignored) {}
        try {
            String bName = rs.getString("bank_name");
            if (bName != null && !bName.trim().isEmpty()) r.setBankName(bName.trim());
        } catch (Exception ignored) {}
        try {
            String bAcc = rs.getString("bank_account_no");
            if (bAcc != null && !bAcc.trim().isEmpty()) r.setBankAccountNo(bAcc.trim());
        } catch (Exception ignored) {}
        try {
            String bAccName = rs.getString("bank_account_name");
            if (bAccName != null && !bAccName.trim().isEmpty()) r.setBankAccountName(bAccName.trim());
        } catch (Exception ignored) {}
        try {
            r.setRating(rs.getDouble("avg_rating"));
            r.setReviewCount(rs.getInt("review_count"));
            r.setTotalOrders(rs.getInt("total_orders"));
        } catch (Exception ignored) {}
        try {
            double lat = rs.getDouble("latitude");
            if (!rs.wasNull()) r.setLatitude(lat);
        } catch (Exception ignored) {}
        try {
            double lng = rs.getDouble("longitude");
            if (!rs.wasNull()) r.setLongitude(lng);
        } catch (Exception ignored) {}

        // Fallback an toàn nếu database chưa có tọa độ
        if (r.getLatitude() == null || r.getLongitude() == null || (r.getLatitude() == 0 && r.getLongitude() == 0)) {
            double[] coords = com.ute.fooddelivery.utils.GeoLocationUtils.getCoordinatesForAddress(r.getAddress());
            r.setLatitude(coords[0]);
            r.setLongitude(coords[1]);
        }
        return r;
    }
}
