package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Review;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class FoodDAO {

    private static volatile boolean comboSupportChecked = false;

    public static void ensureComboSupport() {
        if (comboSupportChecked) return;
        synchronized (FoodDAO.class) {
            if (comboSupportChecked) return;
            try (Connection conn = DBContext.getConnection();
                 Statement stmt = conn.createStatement()) {
                if (conn != null) {
                    DatabaseMetaData meta = conn.getMetaData();
                    // 1. Kiểm tra cột is_combo
                    boolean hasCombo = false;
                    try (ResultSet rs = meta.getColumns(null, null, "foods", "is_combo")) {
                        if (rs.next()) hasCombo = true;
                    }
                    if (!hasCombo) {
                        try {
                            stmt.executeUpdate("ALTER TABLE foods ADD COLUMN is_combo TINYINT(1) DEFAULT 0");
                        } catch (SQLException ignore) {}
                    }

                    // 2. Kiểm tra cột original_price
                    boolean hasOrig = false;
                    try (ResultSet rs = meta.getColumns(null, null, "foods", "original_price")) {
                        if (rs.next()) hasOrig = true;
                    }
                    if (!hasOrig) {
                        try {
                            stmt.executeUpdate("ALTER TABLE foods ADD COLUMN original_price DOUBLE NULL DEFAULT NULL");
                        } catch (SQLException ignore) {}
                    }

                    // 3. Kiểm tra cột combo_items
                    boolean hasItems = false;
                    try (ResultSet rs = meta.getColumns(null, null, "foods", "combo_items")) {
                        if (rs.next()) hasItems = true;
                    }
                    if (!hasItems) {
                        try {
                            stmt.executeUpdate("ALTER TABLE foods ADD COLUMN combo_items TEXT NULL DEFAULT NULL");
                        } catch (SQLException ignore) {}
                    }

                    // 4. Đảm bảo danh mục Combo & Set Tiết Kiệm tồn tại
                    try (ResultSet rs = stmt.executeQuery("SELECT category_id FROM categories WHERE name LIKE '%Combo%' LIMIT 1")) {
                        if (!rs.next()) {
                            stmt.executeUpdate("INSERT INTO categories (name, image_icon, description) VALUES " +
                                "('Combo & Set Tiết Kiệm', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&auto=format&fit=crop&q=80', 'Các set ăn và combo tiết kiệm giá tốt nhất')");
                        }
                    } catch (Exception ignore) {}
                }
            } catch (Exception e) {
                System.err.println("Lưu ý khi kiểm tra hỗ trợ combo: " + e.getMessage());
            }
            comboSupportChecked = true;
        }
    }

    private static final String BASE_QUERY = 
        "SELECT f.food_id, f.name, f.description, f.price, f.image_url, f.is_available, " +
        "       f.category_id, c.name AS category_name, " +
        "       f.restaurant_id, r.name AS restaurant_name, " +
        "       COALESCE(f.is_combo, 0) AS is_combo, " +
        "       f.original_price, f.combo_items, " +
        "       COALESCE(sub.avg_rating, 0.0) AS avg_rating, " +
        "       COALESCE(sub.review_count, 0) AS review_count, " +
        "       COALESCE(sub_sales.total_sold, 0) AS total_sold " +
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
        ") sub ON f.food_id = sub.food_id " +
        "LEFT JOIN (" +
        "    SELECT oi.food_id, SUM(oi.quantity) AS total_sold " +
        "    FROM order_items oi " +
        "    JOIN orders o ON oi.order_id = o.order_id " +
        "    WHERE o.status IN ('DELIVERED', 'COMPLETED') " +
        "    GROUP BY oi.food_id " +
        ") sub_sales ON f.food_id = sub_sales.food_id ";

    private void attachReviews(List<Food> list, int maxPerFood) {
        if (list == null || list.isEmpty()) return;
        List<Integer> ids = new ArrayList<>();
        for (Food f : list) {
            ids.add(f.getId());
        }
        ReviewDAO reviewDAO = new ReviewDAO();
        Map<Integer, List<Review>> revMap = reviewDAO.getRecentReviewsForFoods(ids, maxPerFood);
        for (Food f : list) {
            List<Review> revs = revMap.get(f.getId());
            if (revs != null) {
                f.setReviews(revs);
            }
        }
    }

    public List<Food> getAllFoods() {
        ensureComboSupport();
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
        attachReviews(list, 2);
        return list;
    }

    public List<Food> getFoodsByCategory(int categoryId) {
        ensureComboSupport();
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
        attachReviews(list, 2);
        return list;
    }

    public List<Food> searchFoods(String keyword) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND (f.name LIKE ? OR f.description LIKE ? OR r.name LIKE ?) ORDER BY f.food_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    String pattern = "%" + keyword + "%";
                    ps.setString(1, pattern);
                    ps.setString(2, pattern);
                    ps.setString(3, pattern);
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
        attachReviews(list, 2);
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
                            Food food = mapResultSetToFood(rs);
                            ReviewDAO reviewDAO = new ReviewDAO();
                            food.setReviews(reviewDAO.getReviewsByFoodId(id, 20));
                            return food;
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
        return getBestSellingFoods(limit);
    }

    /**
     * Lấy các món ăn bán chạy nhất dựa trên số lượng bán thật (Tab Bán chạy)
     */
    public List<Food> getBestSellingFoods(int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 ORDER BY COALESCE(sub_sales.total_sold, 0) DESC, sub.avg_rating DESC, f.food_id ASC LIMIT ?";
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
            System.err.println("Lỗi khi lấy best selling foods: " + e.getMessage());
        }
        attachReviews(list, 2);
        return list;
    }

    /**
     * Lấy các món ăn được đánh giá cao nhất dựa trên rating thật (Tab Đánh giá)
     */
    public List<Food> getTopRatedFoods(int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 ORDER BY sub.avg_rating DESC, sub.review_count DESC, f.food_id ASC LIMIT ?";
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
            System.err.println("Lỗi khi lấy top rated foods: " + e.getMessage());
        }
        attachReviews(list, 2);
        return list;
    }

    public List<Food> getFoodsByRestaurantId(int restaurantId) {
        ensureComboSupport();
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
        attachReviews(list, 2);
        return list;
    }

    public boolean insertFood(Food food) {
        ensureComboSupport();
        String query = "INSERT INTO foods (name, description, price, image_url, category_id, restaurant_id, is_available, is_combo, original_price, combo_items) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
                    ps.setInt(8, food.isCombo() ? 1 : 0);
                    if (food.getOriginalPrice() != null) {
                        ps.setDouble(9, food.getOriginalPrice());
                    } else {
                        ps.setNull(9, java.sql.Types.DOUBLE);
                    }
                    ps.setString(10, food.getComboItems());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi thêm món ăn mới: " + e.getMessage());
        }
        return false;
    }

    public List<Food> getFoodsByRestaurant(int restaurantId, int excludeFoodId, int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.restaurant_id = ? " +
                       (excludeFoodId > 0 ? "AND f.food_id != ? " : "") +
                       "ORDER BY f.food_id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    if (excludeFoodId > 0) {
                        ps.setInt(2, excludeFoodId);
                        ps.setInt(3, limit);
                    } else {
                        ps.setInt(2, limit);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món theo quán: " + e.getMessage());
        }
        attachReviews(list, 3);
        return list;
    }

    public List<Food> getSimilarFoodsByCategory(int categoryId, int excludeFoodId, int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.category_id = ? " +
                       (excludeFoodId > 0 ? "AND f.food_id != ? " : "") +
                       "ORDER BY sub.avg_rating DESC, sub.review_count DESC, f.food_id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, categoryId);
                    if (excludeFoodId > 0) {
                        ps.setInt(2, excludeFoodId);
                        ps.setInt(3, limit);
                    } else {
                        ps.setInt(2, limit);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFood(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món tương tự theo danh mục: " + e.getMessage());
        }
        attachReviews(list, 3);
        return list;
    }

    public List<Food> getPopularSideDishes(int limit) {
        List<Food> list = new ArrayList<>();
        // Tìm các món đồ uống, tráng miệng, món phụ (category_id = 3 hoặc 4 hoặc giá dưới 35k)
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND (f.category_id IN (3, 4) OR f.price <= 35000) ORDER BY f.price ASC LIMIT ?";
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
            System.err.println("Lỗi khi lấy món phụ/đồ uống: " + e.getMessage());
        }
        attachReviews(list, 2);
        return list;
    }

    /**
     * Gợi ý món ăn cá nhân hóa cho khách hàng (Tab "Cho bạn"):
     * - Các món xuất hiện ban đầu dựa vào món khách đặt gần nhất (cùng danh mục món gần nhất)
     * - Các món xuất hiện tiếp theo dựa vào món khách đặt gần nhì, ba...
     * - Ưu tiên hiển thị món khách đã đặt trong danh mục đó, sau đó đến các món khác cùng danh mục.
     */
    public List<Food> getRecommendedFoodsForUser(int userId, int limit) {
        if (userId <= 0) {
            return new ArrayList<>();
        }
        ensureComboSupport();

        // 1. Lấy danh sách các món khách đã đặt theo thứ tự thời gian mới nhất -> cũ nhất
        String sql = 
            "SELECT oi.food_id, f.category_id, o.created_at " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE o.user_id = ? AND (o.status IS NULL OR o.status != 'CANCELLED') " +
            "ORDER BY o.created_at DESC, o.order_id DESC, oi.order_item_id DESC";

        List<Integer> orderedCategories = new ArrayList<>();
        java.util.Set<Integer> seenCategories = new java.util.HashSet<>();
        Map<Integer, List<Integer>> categoryToOrderedFoods = new java.util.LinkedHashMap<>();

        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return new ArrayList<>();

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int fId = rs.getInt("food_id");
                        int catId = rs.getInt("category_id");

                        if (!seenCategories.contains(catId)) {
                            seenCategories.add(catId);
                            orderedCategories.add(catId);
                        }

                        categoryToOrderedFoods.computeIfAbsent(catId, k -> new ArrayList<>());
                        if (!categoryToOrderedFoods.get(catId).contains(fId)) {
                            categoryToOrderedFoods.get(catId).add(fId);
                        }
                    }
                }
            }

            if (orderedCategories.isEmpty()) {
                return new ArrayList<>();
            }

            return buildRecommendedFoodsFromCategories(conn, orderedCategories, categoryToOrderedFoods, limit);
        } catch (Exception e) {
            System.err.println("Lỗi khi gợi ý món ăn cho user: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    /**
     * Gợi ý món ăn dựa trên danh sách món đã xem gần đây (Fallback khi chưa có đơn hàng):
     * - Các món xuất hiện ban đầu dựa vào món xem gần nhất (cùng danh mục món gần nhất)
     * - Các món xuất hiện tiếp theo dựa vào món xem gần nhì, ba...
     */
    public List<Food> getRecommendedFoodsByRecentIds(List<Integer> recentFoodIds, int limit) {
        if (recentFoodIds == null || recentFoodIds.isEmpty()) {
            return new ArrayList<>();
        }
        ensureComboSupport();

        List<Integer> orderedCategories = new ArrayList<>();
        java.util.Set<Integer> seenCategories = new java.util.HashSet<>();
        Map<Integer, List<Integer>> categoryToOrderedFoods = new java.util.LinkedHashMap<>();

        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return new ArrayList<>();

            for (int fId : recentFoodIds) {
                Food f = getFoodByIdInternal(conn, fId);
                if (f != null) {
                    int catId = f.getCategoryId();
                    if (!seenCategories.contains(catId)) {
                        seenCategories.add(catId);
                        orderedCategories.add(catId);
                    }
                    categoryToOrderedFoods.computeIfAbsent(catId, k -> new ArrayList<>());
                    if (!categoryToOrderedFoods.get(catId).contains(fId)) {
                        categoryToOrderedFoods.get(catId).add(fId);
                    }
                }
            }

            if (orderedCategories.isEmpty()) {
                return new ArrayList<>();
            }

            return buildRecommendedFoodsFromCategories(conn, orderedCategories, categoryToOrderedFoods, limit);
        } catch (Exception e) {
            System.err.println("Lỗi khi gợi ý món theo recent ids: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private List<Food> buildRecommendedFoodsFromCategories(Connection conn, 
                                                           List<Integer> orderedCategories, 
                                                           Map<Integer, List<Integer>> categoryToOrderedFoods, 
                                                           int limit) {
        List<Food> result = new ArrayList<>();
        java.util.Set<Integer> addedFoodIds = new java.util.HashSet<>();

        int numCats = orderedCategories.size();
        Map<Integer, Integer> categoryQuotas = new java.util.HashMap<>();
        if (numCats == 1) {
            categoryQuotas.put(orderedCategories.get(0), limit);
        } else if (numCats == 2) {
            categoryQuotas.put(orderedCategories.get(0), 7);
            categoryQuotas.put(orderedCategories.get(1), 5);
        } else {
            categoryQuotas.put(orderedCategories.get(0), 5); // Gần nhất: 5 món
            categoryQuotas.put(orderedCategories.get(1), 4); // Gần nhì: 4 món
            categoryQuotas.put(orderedCategories.get(2), 3); // Gần ba: 3 món
            for (int i = 3; i < numCats; i++) {
                categoryQuotas.put(orderedCategories.get(i), 2);
            }
        }

        // Lần 1: Lấy theo hạn ngạch quota của từng danh mục
        for (int catId : orderedCategories) {
            int quota = categoryQuotas.getOrDefault(catId, 3);
            int countFromCat = 0;

            // 1. Thêm món khách đã đặt trong danh mục này trước (nếu còn available)
            List<Integer> orderedFoodsInCat = categoryToOrderedFoods.get(catId);
            if (orderedFoodsInCat != null) {
                for (int fId : orderedFoodsInCat) {
                    if (!addedFoodIds.contains(fId)) {
                        Food f = getFoodByIdInternal(conn, fId);
                        if (f != null && f.isAvailable()) {
                            result.add(f);
                            addedFoodIds.add(fId);
                            countFromCat++;
                            if (result.size() >= limit || countFromCat >= quota) {
                                break;
                            }
                        }
                    }
                }
            }

            if (result.size() >= limit) break;

            // 2. Thêm các món khác cùng danh mục
            if (countFromCat < quota) {
                List<Food> otherFoods = getAvailableFoodsByCategoryInternal(conn, catId, quota * 2);
                for (Food f : otherFoods) {
                    if (!addedFoodIds.contains(f.getId())) {
                        result.add(f);
                        addedFoodIds.add(f.getId());
                        countFromCat++;
                        if (result.size() >= limit || countFromCat >= quota) {
                            break;
                        }
                    }
                }
            }

            if (result.size() >= limit) break;
        }

        // Lần 2: Nếu chưa đủ limit (do danh mục ít món), vét thêm các món còn lại trong các danh mục theo thứ tự ưu tiên
        if (result.size() < limit) {
            for (int catId : orderedCategories) {
                List<Food> extraFoods = getAvailableFoodsByCategoryInternal(conn, catId, limit);
                for (Food f : extraFoods) {
                    if (!addedFoodIds.contains(f.getId())) {
                        result.add(f);
                        addedFoodIds.add(f.getId());
                        if (result.size() >= limit) break;
                    }
                }
                if (result.size() >= limit) break;
            }
        }

        attachReviews(result, 2);
        return result;
    }

    private Food getFoodByIdInternal(Connection conn, int id) {
        String query = BASE_QUERY + "WHERE f.food_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFood(rs);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món theo ID (internal): " + e.getMessage());
        }
        return null;
    }

    private List<Food> getAvailableFoodsByCategoryInternal(Connection conn, int categoryId, int limit) {
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.category_id = ? " +
                       "ORDER BY COALESCE(sub_sales.total_sold, 0) DESC, sub.avg_rating DESC, f.food_id ASC LIMIT ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFood(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy món theo danh mục (internal): " + e.getMessage());
        }
        return list;
    }

    public boolean updateFood(Food food) {
        ensureComboSupport();
        String query = "UPDATE foods SET name = ?, description = ?, price = ?, image_url = ?, category_id = ?, is_available = ?, is_combo = ?, original_price = ?, combo_items = ? " +
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
                    ps.setInt(7, food.isCombo() ? 1 : 0);
                    if (food.getOriginalPrice() != null) {
                        ps.setDouble(8, food.getOriginalPrice());
                    } else {
                        ps.setNull(8, java.sql.Types.DOUBLE);
                    }
                    ps.setString(9, food.getComboItems());
                    ps.setInt(10, food.getId());
                    ps.setInt(11, food.getRestaurantId());
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

    public List<Food> getCombosByRestaurantId(int restaurantId) {
        ensureComboSupport();
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.restaurant_id = ? AND f.is_combo = 1 ORDER BY f.food_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFood(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy combo theo quán: " + e.getMessage());
        }
        attachReviews(list, 2);
        return list;
    }

    public List<Food> getAllCombos() {
        ensureComboSupport();
        List<Food> list = new ArrayList<>();
        String query = BASE_QUERY + "WHERE f.is_available = 1 AND f.is_combo = 1 ORDER BY f.restaurant_id, f.food_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToFood(rs));
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy tất cả combos: " + e.getMessage());
        }
        attachReviews(list, 2);
        return list;
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
            food.setTotalSold(rs.getInt("total_sold"));
        } catch (Exception ignored) {}

        try {
            food.setCombo(rs.getInt("is_combo") == 1);
            double orig = rs.getDouble("original_price");
            if (!rs.wasNull()) {
                food.setOriginalPrice(orig);
            }
            food.setComboItems(rs.getString("combo_items"));
        } catch (Exception ignored) {}

        return food;
    }
}
