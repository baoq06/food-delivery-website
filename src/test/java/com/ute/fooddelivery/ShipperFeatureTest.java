package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.UserService;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;

import static org.junit.Assert.*;

public class ShipperFeatureTest {

    @Test
    public void testKaitokidAccount() {
        UserDAO userDAO = new UserDAO();
        DriverDAO driverDAO = new DriverDAO();

        // 1. Kiểm tra tài khoản kaitokid đăng nhập
        User kaito = userDAO.login("kaitokid", "123456");
        assertNotNull("Tài khoản kaitokid phải tồn tại trên TiDB Cloud", kaito);
        assertEquals("SHIPPER", kaito.getRole());
        assertTrue(kaito.isShipper());

        // 2. Kiểm tra bản ghi Driver của kaitokid
        Driver driver = driverDAO.getDriverByUserId(kaito.getId());
        assertNotNull("Bản ghi driver của kaitokid phải tồn tại", driver);
        assertEquals("AVAILABLE", driver.getStatus());
        assertEquals("59-X3 999.99", driver.getLicensePlate());
        assertEquals("Honda Air Blade 160", driver.getVehicleType());
    }

    @Test
    public void testRegisterNewShipperWithVehicleInfo() {
        UserService userService = new UserService();
        DriverDAO driverDAO = new DriverDAO();

        String tempUser = "new_shipper_reg_test";
        // Dọn dẹp trước nếu tồn tại
        cleanupUser(tempUser);

        User newUser = new User(0, tempUser, "123456", "Nguyễn Văn Giao Hàng", "shipperreg@utee.vn", "0911223344", "Thủ Đức, TP.HCM", "SHIPPER");
        boolean created = userService.registerShipper(newUser, "59-V1 888.88", "Yamaha Exciter 155");
        assertTrue("Đăng ký tài khoản shipper mới phải thành công", created);

        User logged = userService.login(tempUser, "123456");
        assertNotNull(logged);
        assertTrue(logged.isShipper());

        Driver driver = driverDAO.getDriverByUserId(logged.getId());
        assertNotNull("Driver record phải được tự động tạo khi đăng ký", driver);
        assertEquals("59-V1 888.88", driver.getLicensePlate());
        assertEquals("Yamaha Exciter 155", driver.getVehicleType());

        // Dọn dẹp sau khi kiểm thử
        cleanupUser(tempUser);
    }

    private void cleanupUser(String username) {
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                int uid = -1;
                try (PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM users WHERE username = ?")) {
                    ps.setString(1, username);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) uid = rs.getInt("user_id");
                    }
                }
                if (uid > 0) {
                    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM drivers WHERE user_id = ?")) {
                        ps.setInt(1, uid);
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id = ?")) {
                        ps.setInt(1, uid);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (Exception ignored) {}
    }
}
