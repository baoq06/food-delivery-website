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
    private static volatile boolean discountColumnsChecked = false;

    public static void ensureOrderDiscountColumns() {
        if (discountColumnsChecked) return;
        synchronized (OrderDAO.class) {
            if (discountColumnsChecked) return;
            try (Connection conn = DBContext.getConnection()) {
                if (conn == null) return;
                try (Statement stmt = conn.createStatement()) {
                    java.sql.DatabaseMetaData meta = conn.getMetaData();
                    boolean hasDiscount = false;
                    boolean hasVoucher = false;
                    boolean hasVoucherRefunded = false;
                    boolean hasProofImage = false;
                    try (ResultSet rs = meta.getColumns(null, null, "orders", "discount_amount")) {
                        if (rs.next()) hasDiscount = true;
                    }
                    try (ResultSet rs = meta.getColumns(null, null, "orders", "voucher_code")) {
                        if (rs.next()) hasVoucher = true;
                    }
                    try (ResultSet rs = meta.getColumns(null, null, "orders", "voucher_refunded")) {
                        if (rs.next()) hasVoucherRefunded = true;
                    }
                    try (ResultSet rs = meta.getColumns(null, null, "orders", "proof_image")) {
                        if (rs.next()) hasProofImage = true;
                    }

                    if (!hasDiscount) {
                        try {
                            stmt.executeUpdate("ALTER TABLE orders ADD COLUMN discount_amount DOUBLE NOT NULL DEFAULT 0 AFTER distance_km");
                            System.out.println(">> Đã thêm cột discount_amount vào bảng orders");
                        } catch (SQLException ignore) {}
                    }
                    if (!hasVoucher) {
                        try {
                            stmt.executeUpdate("ALTER TABLE orders ADD COLUMN voucher_code VARCHAR(50) DEFAULT NULL AFTER discount_amount");
                            System.out.println(">> Đã thêm cột voucher_code vào bảng orders");
                        } catch (SQLException ignore) {}
                    }
                    if (!hasVoucherRefunded) {
                        try {
                            stmt.executeUpdate("ALTER TABLE orders ADD COLUMN voucher_refunded TINYINT(1) DEFAULT 0 AFTER voucher_code");
                            System.out.println(">> Đã thêm cột voucher_refunded vào bảng orders");
                        } catch (SQLException ignore) {}
                    }
                    if (!hasProofImage) {
                        try {
                            stmt.executeUpdate("ALTER TABLE orders ADD COLUMN proof_image VARCHAR(500) DEFAULT NULL AFTER note");
                            System.out.println(">> Đã thêm cột proof_image vào bảng orders");
                        } catch (SQLException ignore) {}
                    }
                }
            } catch (Exception e) {
                System.err.println("Lưu ý khi kiểm tra cột discount trong bảng orders: " + e.getMessage());
            }
            discountColumnsChecked = true;
        }
    }

    public OrderDAO() {
        ensureOrderDiscountColumns();
        syncCompletedOrders();
    }

    public int createOrder(Order order, List<OrderItem> items) {
        ensureOrderDiscountColumns();
        String insertOrderSql = 
            "INSERT INTO orders (user_id, customer_name, phone, address, note, total_amount, shipping_fee, distance_km, payment_method, status, customer_confirmed, merchant_confirmed, shipper_accepted, shipper_picked_up, shipper_delivered, merchant_completed, discount_amount, voucher_code) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0, 0, ?, ?)";
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
                psOrder.setDouble(7, order.getShippingFee() > 0 ? order.getShippingFee() : 15000.0);
                psOrder.setDouble(8, order.getDistanceKm() > 0 ? order.getDistanceKm() : 2.0);
                psOrder.setString(9, order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD");
                psOrder.setString(10, "PENDING");
                psOrder.setDouble(11, order.getDiscountAmount());
                psOrder.setString(12, order.getVoucherCode());

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
            "                o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, o.payment_method, o.status, o.driver_id, o.created_at, " +
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
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                            try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
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
                        // Tự động kiểm tra phục hồi uy tín COD cho khách hàng nếu hoàn tất đơn
                        if ("DELIVERED".equalsIgnoreCase(status)) {
                            handleCodUnlockOnDeliveredByOrderId(orderId);
                            settleDriverWalletOnOrderCompletedByOrderId(orderId);
                        }

                        // Khi đơn hoàn tất hoặc hủy, giải phóng tài xế về trạng thái AVAILABLE nếu không còn đơn nào khác đang giao
                        Integer driverId = getDriverIdByOrderId(orderId);
                        if (driverId != null && driverId > 0) {
                            boolean hasOtherActiveOrders = hasActiveOrders(driverId, orderId);
                            if (!hasOtherActiveOrders) {
                                new DriverDAO().updateStatus(driverId, "AVAILABLE");
                            }
                        }

                        // Tự động hoàn trả voucher cho khách khi đơn bị hủy
                        if ("CANCELLED".equalsIgnoreCase(status)) {
                            restoreVouchersForOrder(orderId);
                        }
                    }
                    return updated > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean reportOrderFailed(int orderId, String reason, String shipperNote, String proofUrl) {
        ensureOrderDiscountColumns();
        StringBuilder noteBuilder = new StringBuilder();
        noteBuilder.append(" [BOM HÀNG / GIAO THẤT BẠI: ").append(reason != null ? reason.trim() : "Khách không nhận");
        if (shipperNote != null && !shipperNote.trim().isEmpty()) {
            noteBuilder.append(" | Ghi chú tài xế: ").append(shipperNote.trim());
        }
        if (proofUrl != null && !proofUrl.trim().isEmpty()) {
            noteBuilder.append(" | Bằng chứng: ").append(proofUrl.trim());
        }
        noteBuilder.append("]");

        String sql = "UPDATE orders SET status = 'CANCELLED', note = CONCAT(IFNULL(note, ''), ?), proof_image = COALESCE(?, proof_image) WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, noteBuilder.toString());
                    ps.setString(2, proofUrl);
                    ps.setInt(3, orderId);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        Integer driverId = getDriverIdByOrderId(orderId);
                        if (driverId != null && driverId > 0) {
                            boolean hasOtherActiveOrders = hasActiveOrders(driverId, orderId);
                            if (!hasOtherActiveOrders) {
                                new DriverDAO().updateStatus(driverId, "AVAILABLE");
                            }
                        }

                        restoreVouchersForOrder(orderId);
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi reportOrderFailed: " + e.getMessage());
        }
        return updateOrderStatus(orderId, "CANCELLED");
    }


    public Order getOrderById(int orderId) {
        String sql = "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, o.proof_image, " +
                     "       o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, " +
                     "       o.payment_method, o.status, o.driver_id, o.created_at, " +
                     "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_picked_up, " +
                     "       o.shipper_delivered, o.merchant_completed, " +
                     "       (SELECT f.restaurant_id FROM order_items oi JOIN foods f ON oi.food_id = f.food_id WHERE oi.order_id = o.order_id LIMIT 1) AS restaurant_id, " +
                     "       (SELECT r.name FROM order_items oi JOIN foods f ON oi.food_id = f.food_id JOIN restaurants r ON f.restaurant_id = r.restaurant_id WHERE oi.order_id = o.order_id LIMIT 1) AS restaurant_name " +
                     "FROM orders o WHERE o.order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
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
                            try { order.setProofImage(rs.getString("proof_image")); } catch (Exception ignored) {}
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                            try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
                            try { order.setShipperPickedUp(rs.getBoolean("shipper_picked_up")); } catch (Exception ignored) {}
                            try {
                                Object restIdObj = rs.getObject("restaurant_id");
                                if (restIdObj instanceof Number) {
                                    order.setRestaurantId(((Number) restIdObj).intValue());
                                }
                                order.setRestaurantName(rs.getString("restaurant_name"));
                            } catch (Exception ignored) {}
                            return order;
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
        stats.put("weekTrips", 0);
        stats.put("weekEarnings", 0.0);
        stats.put("monthTrips", 0);
        stats.put("monthEarnings", 0.0);

        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate startOfWeek = today.with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
        int currentMonth = today.getMonthValue();
        int currentYear = today.getYear();

        // Chuẩn bị 7 ngày gần nhất để vẽ biểu đồ doanh thu
        java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
        Map<java.time.LocalDate, Double> last7Earnings = new java.util.LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            last7Earnings.put(today.minusDays(i), 0.0);
        }

        String sql = "SELECT DATE(created_at) as order_date, COUNT(order_id) as trips, " +
                     "COALESCE(SUM(COALESCE(shipping_fee, 15000)), 0) as earnings " +
                     "FROM orders WHERE driver_id = ? AND status = 'DELIVERED' GROUP BY DATE(created_at)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                int totalTrips = 0;
                double totalEarnings = 0.0;
                int todayTrips = 0;
                double todayEarnings = 0.0;
                int weekTrips = 0;
                double weekEarnings = 0.0;
                int monthTrips = 0;
                double monthEarnings = 0.0;

                while (rs.next()) {
                    int trips = rs.getInt("trips");
                    double earn = rs.getDouble("earnings");
                    String oDateStr = rs.getString("order_date");
                    totalTrips += trips;
                    totalEarnings += earn;

                    if (oDateStr != null && !oDateStr.trim().isEmpty()) {
                        try {
                            java.time.LocalDate oDate = java.time.LocalDate.parse(oDateStr.substring(0, 10));
                            if (oDate.equals(today)) {
                                todayTrips += trips;
                                todayEarnings += earn;
                            }
                            if (!oDate.isBefore(startOfWeek) && !oDate.isAfter(today)) {
                                weekTrips += trips;
                                weekEarnings += earn;
                            }
                            if (oDate.getYear() == currentYear && oDate.getMonthValue() == currentMonth) {
                                monthTrips += trips;
                                monthEarnings += earn;
                            }
                            if (last7Earnings.containsKey(oDate)) {
                                last7Earnings.put(oDate, earn);
                            }
                        } catch (Exception ignored) {}
                    }
                }
                stats.put("totalTrips", totalTrips);
                stats.put("totalEarnings", totalEarnings);
                stats.put("todayTrips", todayTrips);
                stats.put("todayEarnings", todayEarnings);
                stats.put("weekTrips", weekTrips);
                stats.put("weekEarnings", weekEarnings);
                stats.put("monthTrips", monthTrips);
                stats.put("monthEarnings", monthEarnings);

                // Build chart JSON arrays
                StringBuilder labelsJson = new StringBuilder("[");
                StringBuilder dataJson = new StringBuilder("[");
                int idx = 0;
                for (Map.Entry<java.time.LocalDate, Double> entry : last7Earnings.entrySet()) {
                    if (idx > 0) {
                        labelsJson.append(", ");
                        dataJson.append(", ");
                    }
                    labelsJson.append("\"").append(entry.getKey().format(dtf)).append("\"");
                    dataJson.append(Math.round(entry.getValue()));
                    idx++;
                }
                labelsJson.append("]");
                dataJson.append("]");
                stats.put("chartLabelsJson", labelsJson.toString());
                stats.put("chartDataJson", dataJson.toString());
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

    public int countPendingAssignedOrders(int driverId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE driver_id = ? AND shipper_accepted = 0 AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi đếm đơn chờ của shipper #" + driverId + ": " + e.getMessage());
        }
        return 0;
    }

    public List<Order> getPendingAssignedOrdersForDriver(int driverId) {
        // Tìm danh sách các đơn hàng được Quán gán đích danh cho tài xế này nhưng tài xế chưa xác nhận nhận cuốc
        // Đơn cũ hơn ưu tiên hiện ở trên trước -> ORDER BY created_at ASC, tối đa 3 đơn
        String sql = "SELECT order_id, user_id, customer_name, phone, address, note, total_amount, payment_method, status, created_at FROM orders " +
                     "WHERE driver_id = ? AND shipper_accepted = 0 AND status != 'CANCELLED' " +
                     "ORDER BY created_at ASC LIMIT 3";
        List<Order> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setCustomerName(rs.getString("customer_name"));
                    order.setPhone(rs.getString("phone"));
                    order.setAddress(rs.getString("address"));
                    order.setNote(rs.getString("note"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setStatus(rs.getString("status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    order.setDriverId(driverId);
                    list.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Order getPendingAssignedOrderForDriver(int driverId) {
        List<Order> list = getPendingAssignedOrdersForDriver(driverId);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<Order> getOrdersByUser(int userId) {
        return getOrdersByUserId(userId);
    }

    public List<Order> getOrdersByDriver(int driverId, String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, o.proof_image, " +
            "                o.total_amount, o.shipping_fee, o.distance_km, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "                o.customer_confirmed, o.merchant_confirmed, " +
            "                o.shipper_accepted, o.shipper_picked_up, o.shipper_delivered, o.merchant_completed, " +
            "                r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment " +
            "FROM orders o " +
            "LEFT JOIN order_reviews r ON o.order_id = r.order_id " +
            "WHERE o.driver_id = ? "
        );
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            if ("SHIPPING".equalsIgnoreCase(statusFilter)) {
                sql.append("AND (o.status = 'SHIPPING' OR (o.shipper_accepted = 1 AND o.shipper_delivered = 0 AND o.status != 'CANCELLED')) ");
            } else {
                sql.append("AND o.status = ? ");
            }
        }
        sql.append("ORDER BY o.created_at DESC");

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    ps.setInt(1, driverId);
                    if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter) && !"SHIPPING".equalsIgnoreCase(statusFilter)) {
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
                            try { order.setProofImage(rs.getString("proof_image")); } catch (Exception ignored) {}
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setShipperPickedUp(rs.getBoolean("shipper_picked_up")); } catch (Exception ignored) {}
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
            "  AND o.status = 'DELIVERED' " +
            "  AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) " +
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
            "  AND o.status = 'DELIVERED' " +
            "  AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) " +
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
            "  AND o.status = 'DELIVERED' " +
            "  AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) " +
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
            "                o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "                o.customer_confirmed, o.merchant_confirmed, " +
            "                o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "                d.name AS driver_name, d.phone AS driver_phone " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "WHERE f.restaurant_id = ? AND o.status = 'DELIVERED' " +
            "  AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) "
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
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                            try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
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
            "WHERE f.restaurant_id = ? AND o.status = 'DELIVERED' " +
            "  AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) " +
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
            "  COALESCE(SUM(CASE WHEN (o.status = 'DELIVERED' OR o.status = 'COMPLETED') AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) THEN oi.subtotal ELSE 0 END), 0) AS total_revenue, " +
            "  COALESCE(SUM(CASE WHEN DATE(o.created_at) = CURDATE() AND (o.status = 'DELIVERED' OR o.status = 'COMPLETED') AND (o.merchant_completed = 1 OR o.shipper_delivered = 1) THEN oi.subtotal ELSE 0 END), 0) AS today_revenue, " +
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
        RestaurantDAO.checkHasBankColumns();
        List<Order> list = new ArrayList<>();
        String sql = 
            "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, o.proof_image, " +
            "       o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_picked_up, o.shipper_delivered, o.merchant_completed, " +
            "       d.name AS driver_name, d.phone AS driver_phone, " +
            "       rest.restaurant_id, rest.name AS restaurant_name, rest.image_url AS restaurant_image, rest.image_url, " +
            "       rest.bank_code, rest.bank_name, rest.bank_account_no, rest.bank_account_name, " +
            "       r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment " +
            "FROM orders o " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "LEFT JOIN ( " +
            "    SELECT oi.order_id, " +
            "           MIN(f.restaurant_id) AS restaurant_id, " +
            "           MIN(res.name) AS name, " +
            "           MIN(res.image_url) AS image_url, " +
            "           MIN(res.bank_code) AS bank_code, " +
            "           MIN(res.bank_name) AS bank_name, " +
            "           MIN(res.bank_account_no) AS bank_account_no, " +
            "           MIN(res.bank_account_name) AS bank_account_name " +
            "    FROM order_items oi " +
            "    JOIN foods f ON oi.food_id = f.food_id " +
            "    JOIN restaurants res ON f.restaurant_id = res.restaurant_id " +
            "    GROUP BY oi.order_id " +
            ") rest ON o.order_id = rest.order_id " +
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
                            try { order.setProofImage(rs.getString("proof_image")); } catch (Exception ignored) {}
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                            try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
                            try { order.setShipperPickedUp(rs.getBoolean("shipper_picked_up")); } catch (Exception ignored) {}
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));
                            try {
                                Object restIdObj = rs.getObject("restaurant_id");
                                if (restIdObj instanceof Number) {
                                    order.setRestaurantId(((Number) restIdObj).intValue());
                                }
                            } catch (Exception ignored) {}
                            try { order.setRestaurantName(rs.getString("restaurant_name")); } catch (Exception ignored) {}
                            try {
                                String restImg = rs.getString("restaurant_image");
                                if (restImg == null) {
                                    restImg = rs.getString("image_url");
                                }
                                order.setRestaurantImage(restImg);
                            } catch (Exception ignored) {}
                            try {
                                String bc = rs.getString("bank_code");
                                if (bc != null && !bc.trim().isEmpty()) order.setRestaurantBankCode(bc.trim());
                            } catch (Exception ignored) {}
                            try {
                                String bn = rs.getString("bank_name");
                                if (bn != null && !bn.trim().isEmpty()) order.setRestaurantBankName(bn.trim());
                            } catch (Exception ignored) {}
                            try {
                                String bac = rs.getString("bank_account_no");
                                if (bac != null && !bac.trim().isEmpty()) order.setRestaurantBankAccountNo(bac.trim());
                            } catch (Exception ignored) {}
                            try {
                                String ban = rs.getString("bank_account_name");
                                if (ban != null && !ban.trim().isEmpty()) order.setRestaurantBankAccountName(ban.trim());
                            } catch (Exception ignored) {}

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

    public Order getCustomerOrderForReview(int orderId, int userId) {
        String sql = 
            "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "       o.total_amount, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
            "       d.name AS driver_name, d.phone AS driver_phone, " +
            "       rest.restaurant_id, rest.name AS restaurant_name, rest.image_url AS restaurant_image, rest.address AS restaurant_address, " +
            "       r.review_id, r.rating, r.comment, r.food_rating, r.food_comment, r.driver_rating, r.driver_comment, r.image_url, r.created_at AS review_created_at " +
            "FROM orders o " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "LEFT JOIN order_reviews r ON o.order_id = r.order_id " +
            "LEFT JOIN ( " +
            "    SELECT oi2.order_id, f2.restaurant_id, r2.name, r2.image_url, r2.address " +
            "    FROM order_items oi2 " +
            "    JOIN foods f2 ON oi2.food_id = f2.food_id " +
            "    JOIN restaurants r2 ON f2.restaurant_id = r2.restaurant_id " +
            "    WHERE oi2.order_id = ? LIMIT 1 " +
            ") rest ON o.order_id = rest.order_id " +
            "WHERE o.order_id = ? AND o.user_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, orderId);
                    ps.setInt(3, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
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
                            order.setRestaurantId((Integer) rs.getObject("restaurant_id"));
                            order.setRestaurantName(rs.getString("restaurant_name"));
                            order.setRestaurantImage(rs.getString("restaurant_image"));
                            order.setRestaurantAddress(rs.getString("restaurant_address"));

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
                                try { review.setImageUrl(rs.getString("image_url")); } catch (Exception ignored) {}
                                review.setCreatedAt(rs.getTimestamp("review_created_at"));
                                order.setReview(review);
                            }

                            order.setItems(getOrderItemsByOrderId(order.getId()));
                            return order;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy thông tin đơn hàng đánh giá: " + e.getMessage());
        }
        return null;
    }

    public Order getCustomerOrderForTracking(int orderId, int userId) {
        String sql = 
            "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, " +
            "       o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, o.payment_method, o.status, o.driver_id, o.created_at, " +
            "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_picked_up, o.shipper_delivered, o.merchant_completed, " +
            "       d.name AS driver_name, d.phone AS driver_phone, " +
            "       rest.restaurant_id, rest.name AS restaurant_name, rest.image_url AS restaurant_image, rest.address AS restaurant_address, " +
            "       rest.latitude AS restaurant_lat, rest.longitude AS restaurant_lng " +
            "FROM orders o " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "LEFT JOIN ( " +
            "    SELECT oi2.order_id, f2.restaurant_id, r2.name, r2.image_url, r2.address, r2.latitude, r2.longitude " +
            "    FROM order_items oi2 " +
            "    JOIN foods f2 ON oi2.food_id = f2.food_id " +
            "    JOIN restaurants r2 ON f2.restaurant_id = r2.restaurant_id " +
            "    WHERE oi2.order_id = ? LIMIT 1 " +
            ") rest ON o.order_id = rest.order_id " +
            "WHERE o.order_id = ? AND (o.user_id = ? OR o.user_id IS NULL)";

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, orderId);
                    ps.setInt(3, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
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
                            try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                            try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                            try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                            try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
                            try { order.setShipperPickedUp(rs.getBoolean("shipper_picked_up")); } catch (Exception ignored) {}
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));
                            order.setRestaurantId((Integer) rs.getObject("restaurant_id"));
                            order.setRestaurantName(rs.getString("restaurant_name"));
                            order.setRestaurantImage(rs.getString("restaurant_image"));
                            order.setRestaurantAddress(rs.getString("restaurant_address"));

                            double restLat = rs.getDouble("restaurant_lat");
                            double restLng = rs.getDouble("restaurant_lng");
                            if (!rs.wasNull() && restLat != 0.0 && restLng != 0.0) {
                                order.setRestaurantLatitude(restLat);
                                order.setRestaurantLongitude(restLng);
                            } else {
                                double[] restCoords = com.ute.fooddelivery.utils.GeoLocationUtils.getCoordinatesForAddress(order.getRestaurantAddress());
                                order.setRestaurantLatitude(restCoords[0]);
                                order.setRestaurantLongitude(restCoords[1]);
                            }

                            double[] custCoords = com.ute.fooddelivery.utils.GeoLocationUtils.getCoordinatesForAddress(order.getAddress());
                            order.setCustomerLatitude(custCoords[0]);
                            order.setCustomerLongitude(custCoords[1]);

                            order.setItems(getOrderItemsByOrderId(order.getId()));
                            return order;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy thông tin tracking đơn hàng: " + e.getMessage());
        }
        return null;
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
                        // Giải phóng tài xế nếu có và không còn đơn nào khác đang giao
                        Integer driverId = getDriverIdByOrderId(orderId);
                        if (driverId != null && driverId > 0) {
                            boolean hasOtherActiveOrders = hasActiveOrders(driverId, orderId);
                            if (!hasOtherActiveOrders) {
                                new DriverDAO().updateStatus(driverId, "AVAILABLE");
                            }
                        }

                        // Hoàn trả voucher cho khách hàng nếu có
                        restoreVouchersForOrder(orderId);
                    }
                    return updated > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng hủy đơn: " + e.getMessage());
        }
        return false;
    }

    /**
     * Hoàn trả voucher cho khách hàng và giảm used_count của voucher khi đơn hàng bị hủy
     * (Khách tự hủy, Quán từ chối, Shipper báo hủy do sự cố / bom hàng).
     */
    public boolean restoreVouchersForOrder(int orderId) {
        if (orderId <= 0) return false;
        String selectSql = "SELECT user_id, voucher_code, voucher_refunded FROM orders WHERE order_id = ?";
        int userId = -1;
        String voucherCode = null;
        boolean alreadyRefunded = false;

        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return false;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                        voucherCode = rs.getString("voucher_code");
                        try {
                            alreadyRefunded = rs.getInt("voucher_refunded") == 1;
                        } catch (Exception ignored) {}
                    } else {
                        return false;
                    }
                }
            } catch (SQLException e) {
                // Fallback nếu bảng orders chưa có cột voucher_refunded
                String fallbackSql = "SELECT user_id, voucher_code FROM orders WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt("user_id");
                            voucherCode = rs.getString("voucher_code");
                        } else {
                            return false;
                        }
                    }
                }
            }

            if (voucherCode == null || voucherCode.trim().isEmpty() || alreadyRefunded || userId <= 0) {
                return false;
            }

            // Đánh dấu đã hoàn trả để đảm bảo tính Idempotent (không bị hoàn trùng lặp)
            String markSql = "UPDATE orders SET voucher_refunded = 1 WHERE order_id = ? AND (voucher_refunded = 0 OR voucher_refunded IS NULL)";
            try (PreparedStatement psMark = conn.prepareStatement(markSql)) {
                psMark.setInt(1, orderId);
                int marked = psMark.executeUpdate();
                if (marked == 0 && !alreadyRefunded) {
                    return false;
                }
            } catch (SQLException ignored) {}

            UserVoucherDAO userVoucherDAO = new UserVoucherDAO();
            VoucherDAO voucherDAO = new VoucherDAO();
            String[] codes = voucherCode.split(",");
            boolean anyRestored = false;
            for (String rawCode : codes) {
                String clean = rawCode.trim();
                if (!clean.isEmpty()) {
                    boolean restored = userVoucherDAO.restoreVoucher(userId, clean);
                    if (restored) {
                        voucherDAO.decrementUsedCount(clean);
                        anyRestored = true;
                        System.out.println(">> [Voucher Refund] Đã hoàn trả mã voucher [" + clean + "] cho khách hàng user_id=" + userId + " (Đơn #" + orderId + ")");
                    } else {
                        System.out.println(">> [Voucher Refund] Bỏ qua hoàn trả mã [" + clean + "] do không tìm thấy bản ghi trong ví của user_id=" + userId);
                    }
                }
            }
            return anyRestored;
        } catch (Exception e) {
            System.err.println("Lỗi khi hoàn trả voucher cho đơn hàng #" + orderId + ": " + e.getMessage());
            return false;
        }
    }

    public boolean assignDriver(int orderId, int driverId) {
        // Quán chỉ được gán cho 1 shipper tối đa 3 đơn khi shipper đó chưa nhận đơn nào
        if (countPendingAssignedOrders(driverId) >= 3) {
            System.err.println("Không thể gán đơn #" + orderId + " cho shipper #" + driverId + ": Shipper đã đạt tối đa 3 đơn chờ nhận!");
            return false;
        }
        String sql = "UPDATE orders SET driver_id = ?, shipper_accepted = 0 " +
                     "WHERE order_id = ? " +
                     "  AND status IN ('PENDING', 'CONFIRMED') " +
                     "  AND (driver_id IS NULL OR driver_id = ? OR shipper_accepted = 0)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, orderId);
            ps.setInt(3, driverId);
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
        String sql = "UPDATE orders SET driver_id = NULL, status = 'PENDING', shipper_accepted = 0, shipper_picked_up = 0 WHERE order_id = ? AND driver_id = ? AND status != 'CANCELLED'";
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

    private static boolean syncedOrdersOnStartup = false;

    public static synchronized void syncCompletedOrders() {
        if (syncedOrdersOnStartup) return;
        syncedOrdersOnStartup = true;
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return;
            try (Statement stmt = conn.createStatement()) {
                // Tự động kiểm tra và thêm các cột mới nếu CSDL chưa có (Migration an toàn)
                try { stmt.executeUpdate("ALTER TABLE orders ADD COLUMN shipping_fee DOUBLE NOT NULL DEFAULT 15000"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE orders ADD COLUMN distance_km DOUBLE NOT NULL DEFAULT 2.0"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE orders ADD COLUMN shipper_picked_up TINYINT(1) DEFAULT 0"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE drivers ADD COLUMN current_latitude DOUBLE DEFAULT 10.8510"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE drivers ADD COLUMN current_longitude DOUBLE DEFAULT 106.7725"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE drivers ADD COLUMN current_address VARCHAR(255) DEFAULT '1 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh'"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE drivers ADD COLUMN last_location_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN latitude DOUBLE DEFAULT 10.8505"); } catch (Exception ignored) {}
                try { stmt.executeUpdate("ALTER TABLE restaurants ADD COLUMN longitude DOUBLE DEFAULT 106.7719"); } catch (Exception ignored) {}

                // Quy tắc mới: Chỉ cần shipper_delivered = 1 là đơn đủ điều kiện hoàn tất
                String sql = "UPDATE orders SET status = 'DELIVERED', merchant_completed = 1, merchant_confirmed = 1 " +
                             "WHERE shipper_delivered = 1 AND status != 'CANCELLED' AND (status != 'DELIVERED' OR merchant_completed = 0)";
                int count = stmt.executeUpdate(sql);
                if (count > 0) {
                    System.out.println(">> [OrderDAO] Đã tự động đồng bộ " + count + " đơn shipper đã giao sang trạng thái DELIVERED.");
                    stmt.executeUpdate("UPDATE drivers SET status = 'AVAILABLE' WHERE driver_id IN " +
                                       "(SELECT DISTINCT driver_id FROM orders WHERE shipper_delivered = 1 AND status = 'DELIVERED' AND driver_id IS NOT NULL AND driver_id > 0)");
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi syncCompletedOrders: " + e.getMessage());
        }
    }

    /**
     * BƯỚC MỚI: Shipper xác nhận đã lấy món ăn từ quán
     * Chỉ được phép khi Quán đã bấm nhận đơn / chế biến (CONFIRMED hoặc merchant_confirmed = 1)
     */
    public boolean shipperConfirmPickedUp(int orderId) {
        String sql = "UPDATE orders SET shipper_picked_up = 1, status = 'SHIPPING' WHERE order_id = ? AND status != 'CANCELLED' AND (status IN ('CONFIRMED', 'SHIPPING') OR merchant_confirmed = 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper xác nhận đã lấy món: " + e.getMessage());
        }
        return false;
    }

    /**
     * BƯỚC MỚI: Shipper xác nhận đã lấy món ăn từ quán (kèm xác thực driverId)
     * Chỉ được phép khi Quán đã bấm nhận đơn / chế biến (CONFIRMED hoặc merchant_confirmed = 1)
     */
    public boolean shipperConfirmPickedUp(int orderId, int driverId) {
        String sql = "UPDATE orders SET shipper_picked_up = 1, status = 'SHIPPING' WHERE order_id = ? AND driver_id = ? AND status != 'CANCELLED' AND (status IN ('CONFIRMED', 'SHIPPING') OR merchant_confirmed = 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, driverId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper xác nhận đã lấy món: " + e.getMessage());
        }
        return false;
    }

    public boolean shipperConfirmDelivered(int orderId) {
        String sql = "UPDATE orders SET shipper_delivered = 1 WHERE order_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                checkAndAutoCompleteOrder(orderId);
            }
            return updated;
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
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                checkAndAutoCompleteOrder(orderId);
            }
            return updated;
        } catch (Exception e) {
            System.err.println("Lỗi khi shipper xác nhận đã giao: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmCustomerOrder(int orderId) {
        String sql = "UPDATE orders SET customer_confirmed = 1 WHERE order_id = ? AND status != 'CANCELLED' AND (shipper_picked_up = 1 OR shipper_delivered = 1 OR status = 'DELIVERED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                checkAndAutoCompleteOrder(orderId);
            }
            return updated;
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng xác nhận đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmCustomerOrder(int orderId, int userId) {
        String sql = "UPDATE orders SET customer_confirmed = 1 WHERE order_id = ? AND (user_id = ? OR user_id IS NULL) AND status != 'CANCELLED' AND (shipper_picked_up = 1 OR shipper_delivered = 1 OR status = 'DELIVERED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                checkAndAutoCompleteOrder(orderId);
            }
            return updated;
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng xác nhận đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean confirmMerchantOrder(int orderId) {
        return checkAndAutoCompleteOrder(orderId);
    }

    /**
     * Tự động hoàn tất đơn hàng:
     * - Đơn hàng CHỈ chính thức hoàn tất (DELIVERED) khi SHIPPER đã bấm xác nhận đã giao hàng tận nơi.
     * - Tự động cập nhật status = 'DELIVERED', merchant_completed = 1, merchant_confirmed = 1.
     * - Tự động giải phóng tài xế (drivers status = 'AVAILABLE') để tiếp tục nhận chuyến mới.
     */
    public boolean checkAndAutoCompleteOrder(int orderId) {
        String checkSql = "SELECT shipper_delivered, customer_confirmed, driver_id, status, user_id FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                boolean shipDelivered = false;
                boolean custConfirmed = false;
                int driverId = 0;
                String currentStatus = null;
                int customerUserId = 0;

                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, orderId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            shipDelivered = rs.getBoolean("shipper_delivered");
                            custConfirmed = rs.getBoolean("customer_confirmed");
                            driverId = rs.getInt("driver_id");
                            currentStatus = rs.getString("status");
                            customerUserId = rs.getInt("user_id");
                        }
                    }
                }

                if ("CANCELLED".equalsIgnoreCase(currentStatus)) {
                    return false;
                }

                // Đơn hàng CHỈ chính thức hoàn tất (DELIVERED) khi SHIPPER đã bấm xác nhận đã giao hàng tận nơi
                if (shipDelivered) {
                    boolean wasDelivered = "DELIVERED".equalsIgnoreCase(currentStatus);
                    String updateSql = "UPDATE orders SET merchant_completed = 1, merchant_confirmed = 1, status = 'DELIVERED' WHERE order_id = ? AND status != 'CANCELLED'";
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                        psUpdate.setInt(1, orderId);
                        int updated = psUpdate.executeUpdate();
                        if (updated > 0 || wasDelivered) {
                            // Nếu đơn vừa chính thức hoàn tất DELIVERED lần đầu, xử lý tích lũy đơn uy tín mở lại COD
                            if (!wasDelivered && customerUserId > 0) {
                                handleCodUnlockOnDelivered(customerUserId, orderId);
                            }
                            // Quyết toán ví tài xế: trừ COD thu khách và cộng thù lao giao hàng
                            if (!wasDelivered && driverId > 0) {
                                settleDriverWalletOnOrderCompleted(orderId, driverId);
                            }

                            // Giải phóng shipper về AVAILABLE nếu không còn đơn SHIPPING nào khác
                            if (driverId > 0) {
                                boolean hasOtherActiveOrders = hasActiveOrders(driverId, orderId);
                                if (!hasOtherActiveOrders) {
                                    new DriverDAO().updateStatus(driverId, "AVAILABLE");
                                }
                            }
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tự động hoàn tất đơn #" + orderId + ": " + e.getMessage());
        }
        return false;
    }

    /**
     * Dành cho chủ quán nếu muốn bấm hoàn tất đơn (hoặc xử lý ngoại lệ):
     */
    public boolean merchantCompleteOrder(int orderId) {
        String updateSql = "UPDATE orders SET merchant_completed = 1, merchant_confirmed = 1, status = 'DELIVERED' WHERE order_id = ? AND status != 'CANCELLED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
            psUpdate.setInt(1, orderId);
            int updated = psUpdate.executeUpdate();
            if (updated > 0) {
                handleCodUnlockOnDeliveredByOrderId(orderId);
                Order o = getOrderById(orderId);
                if (o != null && o.getDriverId() != null && o.getDriverId() > 0) {
                    int driverId = o.getDriverId();
                    boolean hasOtherActiveOrders = hasActiveOrders(driverId, orderId);
                    if (!hasOtherActiveOrders) {
                        new DriverDAO().updateStatus(driverId, "AVAILABLE");
                    }
                }
                return true;
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi chủ quán hoàn tất đơn: " + e.getMessage());
        }
        return false;
    }

    public boolean hasActiveOrders(int driverId, int currentOrderId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE driver_id = ? AND status = 'SHIPPING' AND order_id != ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, currentOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi kiểm tra active orders của driver #" + driverId + ": " + e.getMessage());
        }
        return false;
    }

    public boolean hasActiveOrders(int driverId) {
        return hasActiveOrders(driverId, -1);
    }

    public Integer getDriverIdByOrderId(int orderId) {
        String sql = "SELECT driver_id FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int driverId = rs.getInt("driver_id");
                    return rs.wasNull() ? null : driverId;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy driver_id theo mã đơn #" + orderId + ": " + e.getMessage());
        }
        return null;
    }

    private void handleCodUnlockOnDelivered(int customerUserId, int orderId) {
        if (customerUserId <= 0) return;
        try {
            UserDAO uDao = new UserDAO();
            boolean autoUnlocked = uDao.recordCompletedOrderForCodProgress(customerUserId);
            if (autoUnlocked) {
                com.ute.fooddelivery.service.NotificationService notifService = new com.ute.fooddelivery.service.NotificationService();
                notifService.notifyCodAutoUnlocked(customerUserId, orderId);
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi kiểm tra tiến độ mở COD cho khách #" + customerUserId + " (đơn #" + orderId + "): " + e.getMessage());
        }
    }

    private void handleCodUnlockOnDeliveredByOrderId(int orderId) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM orders WHERE order_id = ?")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("user_id");
                    handleCodUnlockOnDelivered(userId, orderId);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn user_id từ order_id #" + orderId + ": " + e.getMessage());
        }
    }

    /**
     * Quyết toán số dư ví tài xế khi đơn hoàn tất:
     * - Nếu đơn COD: Trừ số tiền COD thu hộ của khách vào ví tài xế (khoản thu hộ nhà hàng), và cộng thù lao giao hàng vào ví tài xế.
     * - Nếu đơn Online (VNPay, Momo, v.v.): Chỉ cộng thù lao giao hàng vào ví tài xế.
     */
    public void settleDriverWalletOnOrderCompleted(int orderId, int driverId) {
        if (driverId <= 0 || orderId <= 0) return;
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return;

            // 1. Kiểm tra idempotency: Nếu đã từng quyết toán ví cho đơn này rồi thì bỏ qua
            String checkTransSql = "SELECT COUNT(*) FROM driver_wallet_transactions WHERE driver_id = ? AND order_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkTransSql)) {
                psCheck.setInt(1, driverId);
                psCheck.setInt(2, orderId);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                        return; // Đã quyết toán cho đơn này rồi
                    }
                }
            }

            // 2. Lấy thông tin đơn hàng
            String orderSql = "SELECT total_amount, shipping_fee, payment_method FROM orders WHERE order_id = ?";
            double totalAmount = 0.0;
            double shippingFee = 15000.0;
            String paymentMethod = "COD";
            try (PreparedStatement psOrder = conn.prepareStatement(orderSql)) {
                psOrder.setInt(1, orderId);
                try (ResultSet rsOrder = psOrder.executeQuery()) {
                    if (rsOrder.next()) {
                        totalAmount = rsOrder.getDouble("total_amount");
                        double fee = rsOrder.getDouble("shipping_fee");
                        if (fee > 0) shippingFee = fee;
                        String pm = rsOrder.getString("payment_method");
                        if (pm != null && !pm.trim().isEmpty()) paymentMethod = pm.trim();
                    } else {
                        return;
                    }
                }
            }

            DriverDAO driverDAO = new DriverDAO();
            double currentBalance = driverDAO.getWalletBalance(driverId);
            boolean isCod = "COD".equalsIgnoreCase(paymentMethod);

            if (isCod) {
                // Đơn COD:
                // 1. Khách trả tiền mặt cho shipper -> Trừ tiền thu hộ vào ví shipper
                double balanceAfterDeduction = currentBalance - totalAmount;
                driverDAO.updateWalletBalance(driverId, balanceAfterDeduction);
                driverDAO.recordWalletTransaction(
                    driverId,
                    orderId,
                    "COD_DEDUCTION",
                    -totalAmount,
                    balanceAfterDeduction,
                    "Trừ tiền COD thu khách đơn #FZ-" + orderId
                );

                // 2. Cộng thù lao giao hàng vào ví shipper
                double balanceAfterEarning = balanceAfterDeduction + shippingFee;
                driverDAO.updateWalletBalance(driverId, balanceAfterEarning);
                driverDAO.recordWalletTransaction(
                    driverId,
                    orderId,
                    "SHIPPING_EARNING",
                    shippingFee,
                    balanceAfterEarning,
                    "Thù lao giao hàng đơn #FZ-" + orderId
                );
            } else {
                // Đơn thanh toán online: Khách đã trả trước, chỉ cộng thù lao giao hàng vào ví
                double balanceAfterEarning = currentBalance + shippingFee;
                driverDAO.updateWalletBalance(driverId, balanceAfterEarning);
                driverDAO.recordWalletTransaction(
                    driverId,
                    orderId,
                    "SHIPPING_EARNING",
                    shippingFee,
                    balanceAfterEarning,
                    "Thù lao giao đơn Online #FZ-" + orderId + " (" + paymentMethod + ")"
                );
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi quyết toán ví tài xế cho đơn #" + orderId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void settleDriverWalletOnOrderCompletedByOrderId(int orderId) {
        String sql = "SELECT driver_id FROM orders WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int driverId = rs.getInt("driver_id");
                    if (driverId > 0) {
                        settleDriverWalletOnOrderCompleted(orderId, driverId);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm tài xế để quyết toán ví theo mã đơn #" + orderId + ": " + e.getMessage());
        }
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

    /**
     * Doanh thu của Admin: Mỗi đơn hàng hoàn tất (DELIVERED) của bất kỳ nhà hàng nào,
     * Admin được hưởng 10% giá trị của đơn đó (tổng giá trị món ăn, không tính phí ship).
     */
    public double getAdminCommissionRevenue() {
        String sql = "SELECT COALESCE(SUM(oi.subtotal), 0) * 0.10 " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.order_id " +
                     "WHERE o.status = 'DELIVERED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính doanh thu hoa hồng admin 10%: " + e.getMessage());
        }
        return 0.0;
    }

    public double getTotalDeliveredFoodValue() {
        String sql = "SELECT COALESCE(SUM(oi.subtotal), 0) " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.order_id " +
                     "WHERE o.status = 'DELIVERED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính tổng giá trị món giao: " + e.getMessage());
        }
        return 0.0;
    }

    public double getTotalDeliveredRevenue() {
        return getAdminCommissionRevenue();
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
        String sql = "SELECT o.order_id, o.user_id, o.customer_name, o.phone, o.address, o.note, o.proof_image, " +
                     "       o.total_amount, o.shipping_fee, o.distance_km, o.discount_amount, o.voucher_code, o.payment_method, o.status, o.driver_id, o.created_at, " +
                     "       o.customer_confirmed, o.merchant_confirmed, o.shipper_accepted, o.shipper_delivered, o.merchant_completed, " +
                     "       d.name AS driver_name, " +
                     "       (SELECT GROUP_CONCAT(CONCAT(f.name, ' (x', oi.quantity, ')') SEPARATOR ', ') " +
                     "        FROM order_items oi JOIN foods f ON oi.food_id = f.food_id WHERE oi.order_id = o.order_id) AS food_summary, " +
                     "       COALESCE((SELECT SUM(oi2.subtotal) FROM order_items oi2 WHERE oi2.order_id = o.order_id), 0) AS food_value, " +
                     "       (SELECT r.name FROM order_items oi3 JOIN foods f ON oi3.food_id = f.food_id JOIN restaurants r ON f.restaurant_id = r.restaurant_id WHERE oi3.order_id = o.order_id LIMIT 1) AS restaurant_name " +
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
                    try { order.setProofImage(rs.getString("proof_image")); } catch (Exception ignored) {}
                    try { order.setShippingFee(rs.getDouble("shipping_fee")); } catch (Exception ignored) {}
                    try { order.setDistanceKm(rs.getDouble("distance_km")); } catch (Exception ignored) {}
                    try { order.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ignored) {}
                    try { order.setVoucherCode(rs.getString("voucher_code")); } catch (Exception ignored) {}
                    order.setDriverName(rs.getString("driver_name"));
                    try { order.setRestaurantName(rs.getString("restaurant_name")); } catch (Exception ignored) {}
                    order.setFoodSummary(rs.getString("food_summary"));
                    double fVal = rs.getDouble("food_value");
                    order.setFoodValue(fVal);
                    order.setAdminCommission(Math.round(fVal * 0.10 * 10.0) / 10.0);
                    list.add(order);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách đơn cho admin: " + e.getMessage());
        }
        return list;
    }

    /**
     * Xóa toàn bộ dữ liệu đơn hàng và lịch sử đơn hàng trong hệ thống (dành cho Admin kiểm thử hệ thống).
     * Bao gồm: Đánh giá đơn (order_reviews), Chi tiết món (order_items), Thông báo đơn (notifications),
     * Tin nhắn liên quan (chat_messages) và toàn bộ Đơn hàng (orders).
     * Đồng thời reset trạng thái tài xế BUSY về AVAILABLE và reset AUTO_INCREMENT.
     */
    public boolean deleteAllOrders() {
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return false;
            conn.setAutoCommit(false);
            try (Statement stmt = conn.createStatement()) {
                // 1. Xóa các đánh giá đơn hàng
                try {
                    stmt.executeUpdate("DELETE FROM order_reviews");
                } catch (SQLException ignore) {}

                // 2. Xóa chi tiết các món trong đơn hàng
                try {
                    stmt.executeUpdate("DELETE FROM order_items");
                } catch (SQLException ignore) {}

                // 3. Xóa các thông báo liên quan đến đơn hàng
                try {
                    stmt.executeUpdate("DELETE FROM notifications WHERE order_id IS NOT NULL OR type LIKE 'ORDER%'");
                } catch (SQLException ignore) {}

                // 4. Gỡ liên kết order_id trong bảng tin nhắn chat (nếu có bảng chat)
                try {
                    stmt.executeUpdate("UPDATE chat_messages SET order_id = NULL WHERE order_id IS NOT NULL");
                } catch (SQLException ignore) {}

                // 5. Xóa toàn bộ đơn hàng trong bảng orders
                stmt.executeUpdate("DELETE FROM orders");

                // 6. Reset AUTO_INCREMENT để đơn mới bắt đầu lại từ #1
                try {
                    stmt.executeUpdate("ALTER TABLE order_items AUTO_INCREMENT = 1");
                    stmt.executeUpdate("ALTER TABLE orders AUTO_INCREMENT = 1");
                } catch (SQLException ignore) {}

                // 7. Giải phóng tài xế đang bận giao đơn về trạng thái sẵn sàng (AVAILABLE)
                try {
                    stmt.executeUpdate("UPDATE drivers SET status = 'AVAILABLE' WHERE status = 'BUSY'");
                } catch (SQLException ignore) {}

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Lỗi khi xóa toàn bộ đơn hàng: " + e.getMessage());
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("Lỗi kết nối khi xóa toàn bộ đơn hàng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
