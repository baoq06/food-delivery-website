package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

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
}
