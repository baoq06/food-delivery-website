package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.RevenueStat;
import com.ute.fooddelivery.model.TopFoodStat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO {

    public int createOrder(Order order, List<OrderItem> items) {
        String insertOrderSql = 
            "INSERT INTO orders (user_id, customer_name, phone, address, note, total_amount, payment_method, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
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
                                rs.getTimestamp("created_at")
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
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setInt(2, orderId);
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

    public boolean assignDriver(int orderId, int driverId) {
        String sqlOrder = "UPDATE orders SET driver_id = ?, status = CASE WHEN status = 'PENDING' THEN 'CONFIRMED' ELSE 'SHIPPING' END WHERE order_id = ? AND status != 'CANCELLED'";
        String sqlDriver = "UPDATE drivers SET status = 'BUSY' WHERE driver_id = ?";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(sqlOrder);
                 PreparedStatement ps2 = conn.prepareStatement(sqlDriver)) {
                ps1.setInt(1, driverId);
                ps1.setInt(2, orderId);
                int orderUpdated = ps1.executeUpdate();
                if (orderUpdated <= 0) {
                    conn.rollback();
                    return false;
                }

                ps2.setInt(1, driverId);
                ps2.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            System.err.println("Lỗi khi gán tài xế cho đơn: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public Order getOrderById(int orderId) {
        String sql = "SELECT order_id, user_id, customer_name, phone, address, note, total_amount, payment_method, status, driver_id, created_at FROM orders WHERE order_id = ?";
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
                                rs.getTimestamp("created_at")
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
            "                d.name AS driver_name, d.phone AS driver_phone " +
            "FROM orders o " +
            "JOIN order_items oi ON o.order_id = oi.order_id " +
            "JOIN foods f ON oi.food_id = f.food_id " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
            "WHERE f.restaurant_id = ? AND o.status NOT IN ('CANCELLED', 'PENDING') "
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
                                rs.getTimestamp("created_at")
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
            "  COALESCE(SUM(CASE WHEN o.status NOT IN ('CANCELLED', 'PENDING') THEN oi.subtotal ELSE 0 END), 0) AS total_revenue, " +
            "  COALESCE(SUM(CASE WHEN DATE(o.created_at) = CURDATE() AND o.status NOT IN ('CANCELLED', 'PENDING') THEN oi.subtotal ELSE 0 END), 0) AS today_revenue, " +
            "  COUNT(DISTINCT o.order_id) AS total_orders, " +
            "  COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) AS delivered_orders, " +
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
            "       d.name AS driver_name, d.phone AS driver_phone " +
            "FROM orders o " +
            "LEFT JOIN drivers d ON o.driver_id = d.driver_id " +
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
                                rs.getTimestamp("created_at")
                            );
                            order.setDriverName(rs.getString("driver_name"));
                            order.setDriverPhone(rs.getString("driver_phone"));

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
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi khách hàng hủy đơn: " + e.getMessage());
        }
        return false;
    }
}
