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

    private Driver mapResultSetToDriver(ResultSet rs) throws Exception {
        return new Driver(
            rs.getInt("driver_id"),
            rs.getString("name"),
            rs.getString("phone"),
            rs.getString("status")
        );
    }
}
