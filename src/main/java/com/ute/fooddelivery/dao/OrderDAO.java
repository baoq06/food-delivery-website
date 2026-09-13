package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.RevenueStat;
import com.ute.fooddelivery.model.TopFoodStat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO {

    public int createOrder(Order order, List<OrderItem> items) {
        String insertOrderSql = 
            "INSERT INTO orders (user_id, customer_name, phone, address, note, total_amount, payment_method, status, customer_confirmed, merchant_confirmed, shipper_accepted, shipper_delivered, merchant_completed) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0)";
        String insertItemSql = 
            "INSERT INTO order_items (order_id, food_id, quantity, unit_price, subtotal) " +
            "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return -1;

            conn.setAutoCommit(false); // Bắt đầu transaction

            int orderId = -1;
            try (PreparedStatement psOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                if (order.getUserId() != null) {
                    psOrder.setInt(1, order.getUserId());
                } else {
                    psOrder.setNull(1, java.sql.Types.INTEGER);
                }
                psOrder.setString(2, order.getCustomerName());
                psOrder.setString(3, order.getPhone());
                psOrder.setString(4, order.getAddress());
                psOrder.setString(5, order.getNote());
                psOrder.setDouble(6, order.getTotalAmount());
                psOrder.setString(7, order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD");
                psOrder.setString(8, "PENDING");

                int affected = psOrder.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = psOrder.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        }
                    }
                }
            }

            if (orderId > 0 && items != null && !items.isEmpty()) {
                try (PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {
                    for (OrderItem item : items) {
                        psItem.setInt(1, orderId);
                        psItem.setInt(2, item.getFoodId());
                        psItem.setInt(3, item.getQuantity());
                        psItem.setDouble(4, item.getUnitPrice());
                        psItem.setDouble(5, item.getSubtotal());
                        psItem.addBatch();
                    }
                    psItem.executeBatch();
                }
            }

            conn.commit(); // Hoàn tất transaction thành công
            return orderId;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback nếu có lỗi
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            System.err.println("Lỗi khi lưu đơn hàng createOrder: " + e.getMessage());
            return -1;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public List<Order> getOrdersByRestaurant(int restaurantId, String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "                o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "                o.customer_confirmed, o.merchant_confirmed, " +
            "                o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "                d.name AS driver_name, d.phone AS driver_phone " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "WHERE f.restaurant_id = ? "
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND o.status = ? ");
        }
        sql.append("ORDER BY o.created_at DESC");

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    ps.setInt(1, restaurantId);
                    if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                        ps.setString(2, statusFilter.trim().toUpperCase());
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Order order = new Order(
                                rs.getInt("order_id"),
                                rs.getInt("user_id"),
                                rs.getString("customer_name"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("note"),
                                rs.getDouble("total_amount"),
                                rs.getString("payment_method"),
                                rs.getString("status"),
                                rs.getInt("driver_id"),
                                rs.getTimestamp("created_at"),
                                rs.getBoolean("customer_confirmed"),
                                rs.getBoolean("merchant_confirmed"),
                                rs.getBoolean("shipper_accepted"),
                                rs.getBoolean("shipper_delivered"),
                                rs.getBoolean("merchant_completed")
                            );
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));

                            // Lấy danh sách món của quán trong đơn này
                            order.setItems(getOrderItemsByOrderIdAndRestaurant(order.getId(), restaurantId));
                            list.add(order);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy đơn hàng của quán: " + e.getMessage());
        }
        return list;
    }

    public List<OrderItem> getOrderItemsByOrderIdAndRestaurant(int orderId, int restaurantId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.order_item_id, oi.order_id, oi.food_id, oi.quantity, oi.unit_price, oi.subtotal, " +
                     "       f.name AS food_name, f.image_url AS food_image " +
                     "FROM order_items oi " +
                     "JOIN foods f ON oi.food_id = f.food_id " +
                     "WHERE oi.order_id = ? AND f.restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            OrderItem item = new OrderItem(
                                rs.getInt("order_item_id"),
                                rs.getInt("order_id"),
                                rs.getInt("food_id"),
                                rs.getInt("quantity"),
                                rs.getDouble("unit_price"),
                                rs.getDouble("subtotal")
                            );
                            item.setFoodName(rs.getString("food_name"));
                            item.setFoodImage(rs.getString("food_image"));
                            items.add(item);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy chi tiết món trong đơn: " + e.getMessage());
        }
        return items;
    }

    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ?, merchant_confirmed = CASE WHEN ? IN ('CONFIRMED', 'SHIPPING', 'DELIVERED') THEN 1 ELSE merchant_confirmed END WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setString(2, status);
                    ps.setInt(3, orderId);
                    int updated = ps.executeUpdate();
                    if (updated > 0 && ("DELIVERED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status))) {
                        // Khi đơn hoàn tất hoặc hủy, giải phóng tài xế về trạng thái AVAILABLE
                        String sqlFreeDriver = "UPDATE drivers SET status = 'AVAILABLE' WHERE driver_id = (SELECT driver_id FROM orders WHERE order_id = ?)";
                        try (PreparedStatement psDriver = conn.prepareStatement(sqlFreeDriver)) {
                            psDriver.setInt(1, orderId);
                            psDriver.executeUpdate();
                        } catch (Exception ignored) {}
                    }
                    return updated > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái đơn: " + e.getMessage());
        }
        return false;
    }


    public Order getOrderById(int orderId) {
        String sql = "SELECT order_id, user_id, customer_name, phone, address, note, total_amount, payment_method, status, driver_id, created_at, customer_confirmed, merchant_confirmed, shipper_accepted, shipper_delivered, merchant_completed FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return new Order(
                                rs.getInt("order_id"),
                                rs.getInt("user_id"),
                                rs.getString("customer_name"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("note"),
                                rs.getDouble("total_amount"),
                                rs.getString("payment_method"),
                                rs.getString("status"),
                                rs.getInt("driver_id"),
                                rs.getTimestamp("created_at"),
                                rs.getBoolean("customer_confirmed"),
                                rs.getBoolean("merchant_confirmed"),
                                rs.getBoolean("shipper_accepted"),
                                rs.getBoolean("shipper_delivered"),
                                rs.getBoolean("merchant_completed")
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm đơn hàng theo ID: " + e.getMessage());
        }
        return null;
    }

    public Map<String, Object> getDriverEarnings(int driverId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTrips", 0);
        stats.put("totalEarnings", 0.0);
        stats.put("todayTrips", 0);
        stats.put("todayEarnings", 0.0);
        // Giả sử mỗi chuyến hoàn thành được 15,000 VND tiền ship
        double feePerTrip = 15000.0;
        
        String sql = "SELECT DATE(created_at) as order_date, COUNT(order_id) as trips " +
                     "FROM orders WHERE driver_id = ? AND status = 'DELIVERED' GROUP BY DATE(created_at)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                int totalTrips = 0;
                int todayTrips = 0;
                String todayStr = new java.sql.Date(System.currentTimeMillis()).toString();
                
                while (rs.next()) {
                    int trips = rs.getInt("trips");
                    String oDate = rs.getString("order_date");
                    totalTrips += trips;
                    if (todayStr.equals(oDate)) {
                        todayTrips += trips;
                    }
                }
                stats.put("totalTrips", totalTrips);
                stats.put("totalEarnings", totalTrips * feePerTrip);
                stats.put("todayTrips", todayTrips);
                stats.put("todayEarnings", todayTrips * feePerTrip);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public Order getPendingDispatchOrder() {
        // Tìm 1 đơn hàng trạng thái CONFIRMED (quán đã nấu xong) chưa có tài xế
        String sql = "SELECT order_id, customer_name, address, total_amount, phone FROM orders " +
                     "WHERE status = 'CONFIRMED' AND driver_id IS NULL ORDER BY created_at ASC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Order order = new Order();
                order.setId(rs.getInt("order_id"));
                order.setCustomerName(rs.getString("customer_name"));
                order.setAddress(rs.getString("address"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setPhone(rs.getString("phone"));
                return order;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Order getPendingAssignedOrderForDriver(int driverId) {
        // Tìm đơn hàng được Quán gán đích danh cho tài xế này nhưng tài xế chưa xác nhận nhận cuốc
        String sql = "SELECT order_id, customer_name, address, total_amount, phone FROM orders " +
                     "WHERE driver_id = ? AND shipper_accepted = 0 AND status != 'CANCELLED' " +
                     "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("order_id"));
                    order.setCustomerName(rs.getString("customer_name"));
                    order.setAddress(rs.getString("address"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setPhone(rs.getString("phone"));
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Order> getOrdersByUser(int userId) {
        String sql = "SELECT o.order_id, o.customer_name, o.address, o.phone, o.total_amount, o.status, o.created_at, " +
                     "o.driver_id, d.name AS driver_name, d.phone AS driver_phone, " +
                     "o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
                     "r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment " +
                     "FROM orders o " +
                     "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
                     "LEFT JOIN order_reviews r ON o.order_id = r.order_id " +
                     "WHERE o.user_id = ? " +
                     "ORDER BY o.created_at DESC";
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("order_id"));
                    order.setCustomerName(rs.getString("customer_name"));
                    order.setAddress(rs.getString("address"));
                    order.setPhone(rs.getString("phone"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setStatus(rs.getString("status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    order.setCustomerConfirmed(rs.getBoolean("customer_confirmed"));
                    order.setMerchantConfirmed(rs.getBoolean("merchant_confirmed"));
                    order.setShipperAccepted(rs.getBoolean("shipper_accepted"));
                    order.setShipperDelivered(rs.getBoolean("shipper_delivered"));
                    order.setMerchantCompleted(rs.getBoolean("merchant_completed"));
                    order.setDriverId(rs.getInt("driver_id"));
                    if (rs.wasNull()) {
                         order.setDriverId(null);
                    } else {
                         order.setDriverName(rs.getString("driver_name"));
                         order.setDriverPhone(rs.getString("driver_phone"));
                    }
                    
                    int reviewId = rs.getInt("review_id");
                    if (!rs.wasNull()) {
                        com.ute.fooddelivery.model.Review review = new com.ute.fooddelivery.model.Review();
                        review.setReviewId(reviewId);
                        review.setOrderId(order.getId());
                        review.setRating(rs.getInt("rating"));
                        review.setComment(rs.getString("comment"));
                        review.setFoodRating((Integer) rs.getObject("food_rating"));
                        review.setFoodComment(rs.getString("food_comment"));
                        review.setDriverRating((Integer) rs.getObject("driver_rating"));
                        review.setDriverComment(rs.getString("driver_comment"));
                        order.setReview(review);
                    }
                    
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<Order> getOrdersByDriver(int driverId, String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "                o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "                o.customer_confirmed, o.merchant_confirmed, " +
            "                o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "                r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment " +
            "FROM orders o " +
            "LEFT JOIN order_reviews r ON o.order_id = r.order_id " +
            "WHERE o.driver_id = ? "
        );
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND o.status = ? ");
        }
        sql.append("ORDER BY o.created_at DESC");

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    ps.setInt(1, driverId);
                    if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                        ps.setString(2, statusFilter.trim().toUpperCase());
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Order order = new Order(
                                rs.getInt("order_id"), rs.getInt("user_id"),
                                rs.getString("customer_name"), rs.getString("phone"),
                                rs.getString("address"), rs.getString("note"),
                                rs.getDouble("total_amount"), rs.getString("payment_method"),
                                rs.getString("status"), rs.getInt("driver_id"),
                                rs.getTimestamp("created_at"),
                                rs.getBoolean("customer_confirmed"),
                                rs.getBoolean("merchant_confirmed"),
                                rs.getBoolean("shipper_accepted"),
                                rs.getBoolean("shipper_delivered"),
                                rs.getBoolean("merchant_completed")
                            );
                            int reviewId = rs.getInt("review_id");
                            if (!rs.wasNull()) {
                                com.ute.fooddelivery.model.Review review = new com.ute.fooddelivery.model.Review();
                                review.setReviewId(reviewId);
                                review.setOrderId(order.getId());
                                review.setRating(rs.getInt("rating"));
                                review.setComment(rs.getString("comment"));
                                review.setFoodRating((Integer) rs.getObject("food_rating"));
                                review.setFoodComment(rs.getString("food_comment"));
                                review.setDriverRating((Integer) rs.getObject("driver_rating"));
                                review.setDriverComment(rs.getString("driver_comment"));
                                order.setReview(review);
                            }
                            list.add(order);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi filter order driver: " + e.getMessage());
        }
        return list;
    }

    // =========================================================================
    // THỐNG KÊ DOANH THU THỰC TẾ THEO NGÀY / THÁNG / NĂM
    // =========================================================================

    public List<RevenueStat> getDailyRevenue(int restaurantId, int year, int month) {
        List<RevenueStat> list = new ArrayList<>();
        String sql = 
            "SELECT DAY(o.created_at) AS period_key, " +
            "       SUM(oi.subtotal) AS total_revenue, " +
            "       COUNT(DISTINCT o.order_id) AS total_orders, " +
            "       SUM(oi.quantity) AS total_items " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE f.restaurant_id = ? " +
            "  AND YEAR(o.created_at) = ? " +
            "  AND MONTH(o.created_at) = ? " +
            "  AND o.status NOT IN ('CANCELLED', 'PENDING') " +
            "  AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 " +
            "GROUP BY DAY(o.created_at) " +
            "ORDER BY period_key ASC";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, restaurantId);
                    ps.setInt(2, year);
                    ps.setInt(3, month);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int day = rs.getInt("period_key");
                            String label = String.format("Ngày %02d/%02d", day, month);
                            list.add(new RevenueStat(
                                label,
                                day,
                                rs.getDouble("total_revenue"),
                                rs.getInt("total_orders"),
                                rs.getInt("total_items")
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính doanh thu theo ngày: " + e.getMessage());
        }
        return list;
    }

    public List<RevenueStat> getMonthlyRevenue(int restaurantId, int year) {
        List<RevenueStat> list = new ArrayList<>();
        String sql = 
            "SELECT MONTH(o.created_at) AS period_key, " +
            "       SUM(oi.subtotal) AS total_revenue, " +
            "       COUNT(DISTINCT o.order_id) AS total_orders, " +
            "       SUM(oi.quantity) AS total_items " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE f.restaurant_id = ? " +
            "  AND YEAR(o.created_at) = ? " +
            "  AND o.status NOT IN ('CANCELLED', 'PENDING') " +
            "  AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 " +
            "GROUP BY MONTH(o.created_at) " +
            "ORDER BY period_key ASC";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, restaurantId);
                    ps.setInt(2, year);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int m = rs.getInt("period_key");
                            String label = String.format("Tháng %02d/%d", m, year);
                            list.add(new RevenueStat(
                                label,
                                m,
                                rs.getDouble("total_revenue"),
                                rs.getInt("total_orders"),
                                rs.getInt("total_items")
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính doanh thu theo tháng: " + e.getMessage());
        }
        return list;
    }

    public List<RevenueStat> getYearlyRevenue(int restaurantId) {
        List<RevenueStat> list = new ArrayList<>();
        String sql = 
            "SELECT YEAR(o.created_at) AS period_key, " +
            "       SUM(oi.subtotal) AS total_revenue, " +
            "       COUNT(DISTINCT o.order_id) AS total_orders, " +
            "       SUM(oi.quantity) AS total_items " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE f.restaurant_id = ? " +
            "  AND o.status NOT IN ('CANCELLED', 'PENDING') " +
            "  AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 " +
            "GROUP BY YEAR(o.created_at) " +
            "ORDER BY period_key DESC";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int y = rs.getInt("period_key");
                            String label = "Năm " + y;
                            list.add(new RevenueStat(
                                label,
                                y,
                                rs.getDouble("total_revenue"),
                                rs.getInt("total_orders"),
                                rs.getInt("total_items")
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính doanh thu theo năm: " + e.getMessage());
        }
        return list;
    }

    public List<Order> getRevenueOrders(int restaurantId, String type, int year, Integer month, Integer day) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "                o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "                o.customer_confirmed, o.merchant_confirmed, " +
            "                o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "                d.name AS driver_name, d.phone AS driver_phone " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "WHERE f.restaurant_id = ? AND o.status NOT IN ('CANCELLED', 'PENDING') " +
            "  AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 "
        );

        if ("DAY".equalsIgnoreCase(type) && month != null && day != null) {
            sql.append("AND YEAR(o.created_at) = ? AND MONTH(o.created_at) = ? AND DAY(o.created_at) = ? ");
        } else if ("MONTH".equalsIgnoreCase(type) && month != null) {
            sql.append("AND YEAR(o.created_at) = ? AND MONTH(o.created_at) = ? ");
        } else {
            sql.append("AND YEAR(o.created_at) = ? ");
        }
        sql.append("ORDER BY o.created_at DESC");

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    ps.setInt(1, restaurantId);
                    if ("DAY".equalsIgnoreCase(type) && month != null && day != null) {
                        ps.setInt(2, year);
                        ps.setInt(3, month);
                        ps.setInt(4, day);
                    } else if ("MONTH".equalsIgnoreCase(type) && month != null) {
                        ps.setInt(2, year);
                        ps.setInt(3, month);
                    } else {
                        ps.setInt(2, year);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Order order = new Order(
                                rs.getInt("order_id"),
                                rs.getInt("user_id"),
                                rs.getString("customer_name"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("note"),
                                rs.getDouble("total_amount"),
                                rs.getString("payment_method"),
                                rs.getString("status"),
                                rs.getInt("driver_id"),
                                rs.getTimestamp("created_at"),
                                rs.getBoolean("customer_confirmed"),
                                rs.getBoolean("merchant_confirmed"),
                                rs.getBoolean("shipper_accepted"),
                                rs.getBoolean("shipper_delivered"),
                                rs.getBoolean("merchant_completed")
                            );
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));
                            order.setItems(getOrderItemsByOrderIdAndRestaurant(order.getId(), restaurantId));
                            list.add(order);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy chi tiết đơn doanh thu: " + e.getMessage());
        }
        return list;
    }

    public List<TopFoodStat> getTopSellingFoods(int restaurantId, int limit) {
        List<TopFoodStat> list = new ArrayList<>();
        String sql = 
            "SELECT f.food_id, f.name AS food_name, f.image_url, f.price, " +
            "       SUM(oi.quantity) AS total_qty, " +
            "       SUM(oi.subtotal) AS total_subtotal " +
            "FROM order_items oi " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "JOIN orders o ON oi.order_id = o.order_id " +
            "WHERE f.restaurant_id = ? AND o.status NOT IN ('CANCELLED', 'PENDING') " +
            "  AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 " +
            "GROUP BY f.food_id, f.name, f.image_url, f.price " +
            "ORDER BY total_qty DESC " +
            "LIMIT ?";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, restaurantId);
                    ps.setInt(2, limit);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(new TopFoodStat(
                                rs.getInt("food_id"),
                                rs.getString("food_name"),
                                rs.getString("image_url"),
                                rs.getDouble("price"),
                                rs.getInt("total_qty"),
                                rs.getDouble("total_subtotal")
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy top món bán chạy: " + e.getMessage());
        }
        return list;
    }

    public Map<String, Object> getRestaurantKPIs(int restaurantId) {
        Map<String, Object> kpis = new HashMap<>();
        kpis.put("totalRevenue", 0.0);
        kpis.put("todayRevenue", 0.0);
        kpis.put("totalOrders", 0);
        kpis.put("deliveredOrders", 0);
        kpis.put("pendingOrders", 0);

        String sql = 
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN o.status NOT IN ('CANCELLED', 'PENDING') AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 THEN oi.subtotal ELSE 0 END), 0) AS total_revenue, " +
            "  COALESCE(SUM(CASE WHEN DATE(o.created_at) = CURDATE() AND o.status NOT IN ('CANCELLED', 'PENDING') AND o.merchant_completed = 1 AND o.customer_confirmed = 1 AND o.shipper_delivered = 1 THEN oi.subtotal ELSE 0 END), 0) AS today_revenue, " +
            "  COUNT(DISTINCT o.order_id) AS total_orders, " +
            "  COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' OR o.status = 'COMPLETED' THEN o.order_id END) AS delivered_orders, " +
            "  COUNT(DISTINCT CASE WHEN o.status = 'PENDING' THEN o.order_id END) AS pending_orders " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE f.restaurant_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            kpis.put("totalRevenue", rs.getDouble("total_revenue"));
                            kpis.put("todayRevenue", rs.getDouble("today_revenue"));
                            kpis.put("totalOrders", rs.getInt("total_orders"));
                            kpis.put("deliveredOrders", rs.getInt("delivered_orders"));
                            kpis.put("pendingOrders", rs.getInt("pending_orders"));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính KPIs quán: " + e.getMessage());
        }
        return kpis;
    }

    // =========================================================================
    // QUẢN LÝ ĐƠN HÀNG DÀNH CHO KHÁCH HÀNG (CUSTOMER)
    // =========================================================================

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = 
            "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "       o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "       d.name AS driver_name, d.phone AS driver_phone, " +
            "       r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment " +
            "FROM orders o " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "LEFT JOIN order_reviews r ON o.order_id = r.order_id " +
            "WHERE o.user_id = ? " +
            "ORDER BY o.created_at DESC";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Order order = new Order(
                                rs.getInt("order_id"),
                                rs.getInt("user_id"),
                                rs.getString("customer_name"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("note"),
                                rs.getDouble("total_amount"),
                                rs.getString("payment_method"),
                                rs.getString("status"),
                                rs.getInt("driver_id"),
                                rs.getTimestamp("created_at"),
                                rs.getBoolean("customer_confirmed"),
                                rs.getBoolean("merchant_confirmed"),
                                rs.getBoolean("shipper_accepted"),
                                rs.getBoolean("shipper_delivered"),
                                rs.getBoolean("merchant_completed")
                            );
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));

                            int reviewId = rs.getInt("review_id");
                            if (!rs.wasNull()) {
                                com.ute.fooddelivery.model.Review review = new com.ute.fooddelivery.model.Review();
                                review.setReviewId(reviewId);
                                review.setOrderId(order.getId());
                                review.setRating(rs.getInt("rating"));
                                review.setComment(rs.getString("comment"));
                                review.setFoodRating((Integer) rs.getObject("food_rating"));
                                review.setFoodComment(rs.getString("food_comment"));
                                review.setDriverRating((Integer) rs.getObject("driver_rating"));
                                review.setDriverComment(rs.getString("driver_comment"));
                                order.setReview(review);
                            }

                            // Lấy danh sách tất cả các món trong đơn hàng này
                            order.setItems(getOrderItemsByOrderId(order.getId()));
                            list.add(order);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách đơn của khách hàng: " + e.getMessage());
        }
        return list;
    }

    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = 
            "SELECT oi.order_item_id, oi.order_id, oi.food_id, oi.quantity, oi.unit_price, oi.subtotal, " +
            "       f.name AS food_name, f.image_url AS food_image " +
            "FROM order_items oi " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "WHERE oi.order_id = ? " +
            "ORDER BY oi.order_item_id ASC";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            OrderItem item = new OrderItem(
                                rs.getInt("order_item_id"),
                                rs.getInt("order_id"),
                                rs.getInt("food_id"),
                                rs.getInt("quantity"),
                                rs.getDouble("unit_price"),
                                rs.getDouble("subtotal")
                            );
                            item.setFoodName(rs.getString("food_name"));
                            item.setFoodImage(rs.getString("food_image"));
                            items.add(item);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy chi tiết các món của đơn hàng: " + e.getMessage());
        }
        return items;
    }

    public boolean cancelOrderByCustomer(int orderId, int userId) {
        String sql = "UPDATE orders SET status = 'CANCELLED' WHERE order_id = ? AND user_id = ? AND status IN ('PENDING', 'CONFIRMED')";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        // Giải phóng tài xế nếu có
                        String sqlFreeDriver = "UPDATE drivers SET status = 'AVAILABLE' WHERE driver_id = (SELECT driver_id FROM orders WHERE order_id = ?)";
                        try (PreparedStatement psDriver = conn.prepareStatement(sqlFreeDriver)) {
                            psDriver.setInt(1, orderId);
                            psDriver.executeUpdate();
                        } catch (Exception ignored) {}
                    }
                    return updated > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng hủy đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean assignDriver(int orderId, int driverId) {
        String sql = "UPDATE orders SET driver_id = ?, shipper_accepted = 0 WHERE order_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi gán shipper cho đơn #" + orderId + ": " + e.getMessage());
        }
        return false;
    }

    public boolean shipperAcceptOrder(int orderId, int driverId) {
        String sql = "UPDATE orders SET shipper_accepted = 1 WHERE order_id = ? AND driver_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, driverId);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        // Đổi trạng thái tài xế sang BUSY
                        String sqlBusy = "UPDATE drivers SET status = 'BUSY' WHERE driver_id = ?";
                        try (PreparedStatement psBusy = conn.prepareStatement(sqlBusy)) {
                            psBusy.setInt(1, driverId);
                            psBusy.executeUpdate();
                        } catch (Exception ignored) {}
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper chấp nhận đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean shipperDeclineOrder(int orderId, int driverId) {
        String sql = "UPDATE orders SET driver_id = NULL, shipper_accepted = 0 WHERE order_id = ? AND driver_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, driverId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper từ chối đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean shipperConfirmDelivered(int orderId) {
        String sql = "UPDATE orders SET shipper_delivered = 1 WHERE order_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper xác nhận đã giao: " + e.getMessage());
        }
        return false;
    }

    public boolean shipperConfirmDelivered(int orderId, int driverId) {
        String sql = "UPDATE orders SET shipper_delivered = 1 WHERE order_id = ? AND driver_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, driverId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper xác nhận đã giao: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmCustomerOrder(int orderId) {
        String sql = "UPDATE orders SET customer_confirmed = 1 WHERE order_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng xác nhận đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmCustomerOrder(int orderId, int userId) {
        String sql = "UPDATE orders SET customer_confirmed = 1 WHERE order_id = ? AND (user_id = ? OR user_id IS NULL) AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng xác nhận đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmMerchantOrder(int orderId) {
        return merchantCompleteOrder(orderId);
    }

    /**
     * Chủ cửa hàng duyệt đơn đã hoàn thành:
     * BẮT BUỘC: Phải được shipper xác nhận đã giao (shipper_delivered = 1)
     * VÀ khách hàng xác nhận đã nhận (customer_confirmed = 1).
     */
    public boolean merchantCompleteOrder(int orderId) {
        String checkSql = "SELECT shipper_delivered, customer_confirmed, driver_id, status FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                boolean ready = false;
                int driverId = 0;
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, orderId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            boolean shipDelivered = rs.getBoolean("shipper_delivered");
                            boolean custConfirmed = rs.getBoolean("customer_confirmed");
                            driverId = rs.getInt("driver_id");
                            ready = shipDelivered && custConfirmed;
                        }
                    }
                }

                if (!ready) {
                    System.err.println("Chưa thể duyệt hoàn thành đơn #" + orderId + ": Cần cả Shipper và Khách cùng xác nhận!");
                    return false;
                }

                String updateSql = "UPDATE orders SET merchant_completed = 1, merchant_confirmed = 1, status = 'DELIVERED' WHERE order_id = ? AND status != 'CANCELLED'";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, orderId);
                    int updated = psUpdate.executeUpdate();
                    if (updated > 0) {
                        // Giải phóng shipper về AVAILABLE để tiếp tục nhận cuốc mới
                        if (driverId > 0) {
                            String sqlFreeDriver = "UPDATE drivers SET status = 'AVAILABLE' WHERE driver_id = ?";
                            try (PreparedStatement psDriver = conn.prepareStatement(sqlFreeDriver)) {
                                psDriver.setInt(1, driverId);
                                psDriver.executeUpdate();
                            } catch (Exception ignored) {}
                        }
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi chủ quán duyệt hoàn tất đơn: " + e.getMessage());
        }
        return false;
    }

    public Integer getMerchantUserIdByOrderId(int orderId) {
        String sql = "SELECT DISTINCT r.user_id " +
                     "FROM order_items oi " +
                     "JOIN foods f ON oi.food_id = f.food_id " +
                     "JOIN restaurants r ON f.restaurant_id = r.restaurant_id " +
                     "WHERE oi.order_id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("user_id");
                    return rs.wasNull() ? null : uid;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getMerchantUserIdByOrderId: " + e.getMessage());
        }
        return null;
    }

    public Integer getCustomerUserIdByOrderId(int orderId) {
        String sql = "SELECT user_id FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("user_id");
                    return rs.wasNull() ? null : uid;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getCustomerUserIdByOrderId: " + e.getMessage());
        }
        return null;
    }

    public Integer getDriverUserIdByOrderId(int orderId) {
        String sql = "SELECT d.user_id FROM orders o JOIN drivers d ON o.driver_id = d.driver_id WHERE o.order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("user_id");
                    return rs.wasNull() ? null : uid;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getDriverUserIdByOrderId: " + e.getMessage());
        }
        return null;
    }

    public double getTotalDeliveredRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status = 'DELIVERED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính tổng doanh thu cho admin: " + e.getMessage());
        }
        return 0.0;
    }

    public Map<String, Integer> getOrderStatusCounts() {
        Map<String, Integer> map = new HashMap<>();
        map.put("TOTAL", 0);
        map.put("PENDING", 0);
        map.put("CONFIRMED", 0);
        map.put("SHIPPING", 0);
        map.put("DELIVERED", 0);
        map.put("CANCELLED", 0);
        String sql = "SELECT status, COUNT(*) AS cnt FROM orders GROUP BY status";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int total = 0;
            while (rs.next()) {
                String st = rs.getString("status");
                int count = rs.getInt("cnt");
                if (st != null) {
                    map.put(st.toUpperCase(), count);
                }
                total += count;
            }
            map.put("TOTAL", total);
        } catch (Exception e) {
            System.err.println("Lỗi khi đếm trạng thái đơn cho admin: " + e.getMessage());
        }
        return map;
    }

    public List<Order> getRecentOrdersForAdmin(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
                     "       o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
                     "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
                     "       d.name AS driver_name, " +
                     "       (SELECT GROUP_CONCAT(CONCAT(f.name, ' (x', oi.quantity, ')') SEPARATOR ', ') " +
                     "        FROM order_items oi JOIN foods f ON oi.food_id = f.food_id WHERE oi.order_id = o.order_id) AS food_summary " +
                     "FROM orders o " +
                     "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
                     "ORDER BY o.created_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order(
                        rs.getInt("order_id"),
                        rs.getInt("user_id"),
                        rs.getString("customer_name"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getString("note"),
                        rs.getDouble("total_amount"),
                        rs.getString("payment_method"),
                        rs.getString("status"),
                        rs.getInt("driver_id"),
                        rs.getTimestamp("created_at"),
                        rs.getBoolean("customer_confirmed"),
                        rs.getBoolean("merchant_confirmed"),
                        rs.getBoolean("shipper_accepted"),
                        rs.getBoolean("shipper_delivered"),
                        rs.getBoolean("merchant_completed")
                    );
                    order.setDriverName(rs.getString("driver_name"));
                    order.setFoodSummary(rs.getString("food_summary"));
                    list.add(order);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách đơn cho admin: " + e.getMessage());
        }
        return list;
    }
}
