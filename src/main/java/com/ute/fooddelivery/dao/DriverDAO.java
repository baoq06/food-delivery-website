package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Driver;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DriverDAO {

    public List<Driver> getAllDrivers() {
        List<Driver> list = new ArrayList<>();
        String query = "SELECT driver_id, name, phone, status FROM drivers ORDER BY status ASC, driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToDriver(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách tài xế: " + e.getMessage());
        }
        return list;
    }

    public List<Driver> getAvailableDrivers() {
        List<Driver> list = new ArrayList<>();
        String query = "SELECT driver_id, name, phone, status FROM drivers WHERE status = 'AVAILABLE' ORDER BY driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToDriver(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách tài xế khả dụng: " + e.getMessage());
        }
        return list;
    }

    public Driver getDriverById(int id) {
        String query = "SELECT driver_id, name, phone, status FROM drivers WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToDriver(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm tài xế theo ID: " + e.getMessage());
        }
        return null;
    }

    public boolean updateStatus(int driverId, String status) {
        String query = "UPDATE drivers SET status = ? WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, status);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái tài xế: " + e.getMessage());
        }
        return false;
    }

    public boolean recordDriverPayment(int restaurantId, int driverId, Integer orderId, double amount, String paymentMethod, String note) {
        String query = "INSERT INTO driver_payments (restaurant_id, driver_id, order_id, amount, payment_method, note) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    ps.setInt(2, driverId);
                    if (orderId != null && orderId > 0) {
                        ps.setInt(3, orderId);
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    ps.setDouble(4, amount);
                    ps.setString(5, paymentMethod != null ? paymentMethod : "CASH");
                    ps.setString(6, note);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi ghi nhận thanh toán phí shipper: " + e.getMessage());
        }
        return false;
    }

    public double getTotalPaidToDrivers(int restaurantId) {
        String query = "SELECT COALESCE(SUM(amount), 0) FROM driver_payments WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return rs.getDouble(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính tổng phí đã trả shipper: " + e.getMessage());
        }
        return 0.0;
    }

    private Driver mapResultSetToDriver(ResultSet rs) throws Exception {
        return new Driver(
            rs.getInt("driver_id"),
            rs.getString("name"),
            rs.getString("phone"),
            rs.getString("status")
        );
    }
}

