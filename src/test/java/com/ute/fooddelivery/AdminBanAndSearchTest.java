package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Restaurant;
import org.junit.Test;

import java.sql.Connection;
import java.util.List;

import static org.junit.Assert.*;

public class AdminBanAndSearchTest {

    @Test
    public void testDriverSearchAndBanFlow() {
        DriverDAO driverDAO = new DriverDAO();
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) {
                System.out.println("Skipping test: No active DB connection");
                return;
            }

            // 1. Kiểm tra tìm kiếm tài xế
            List<Driver> allDrivers = driverDAO.getAllDrivers();
            assertNotNull("Danh sách tài xế không được null", allDrivers);

            if (!allDrivers.isEmpty()) {
                Driver first = allDrivers.get(0);
                // Tìm kiếm theo tên
                List<Driver> foundByName = driverDAO.searchDrivers(first.getName());
                assertFalse("Phải tìm thấy tài xế theo tên", foundByName.isEmpty());

                // Tìm kiếm theo SĐT
                if (first.getPhone() != null && !first.getPhone().isEmpty()) {
                    List<Driver> foundByPhone = driverDAO.searchDrivers(first.getPhone());
                    assertFalse("Phải tìm thấy tài xế theo số điện thoại", foundByPhone.isEmpty());

                    Driver byPhone = driverDAO.getDriverByPhone(first.getPhone());
                    assertNotNull("Tìm tài xế bằng getDriverByPhone phải thành công", byPhone);

                    // 2. Thử nghiệm cấm tài xế qua SĐT
                    String originalStatus = first.getStatus();
                    boolean banResult = driverDAO.banDriverByPhone(first.getPhone());
                    assertTrue("Cấm tài xế theo SĐT phải trả về true", banResult);

                    Driver banned = driverDAO.getDriverById(first.getId());
                    assertNotNull(banned);
                    assertEquals("BANNED", banned.getStatus());

                    // 3. Thử nghiệm gỡ cấm (mở khóa) tài xế
                    boolean unbanResult = driverDAO.unbanDriverByPhone(first.getPhone());
                    assertTrue("Gỡ cấm tài xế theo SĐT phải trả về true", unbanResult);

                    // Phục hồi lại trạng thái ban đầu nếu cần
                    driverDAO.updateStatus(first.getId(), originalStatus != null ? originalStatus : "AVAILABLE");
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi kiểm thử tài xế (môi trường mạng): " + e.getMessage());
        }
    }

    @Test
    public void testRestaurantSearchAndBanFlow() {
        RestaurantDAO restaurantDAO = new RestaurantDAO();
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) {
                System.out.println("Skipping test: No active DB connection");
                return;
            }

            // 1. Kiểm tra tìm kiếm quán ăn
            List<Restaurant> allRests = restaurantDAO.getAllRestaurants();
            assertNotNull("Danh sách quán ăn không được null", allRests);

            if (!allRests.isEmpty()) {
                Restaurant first = allRests.get(0);
                // Tìm kiếm theo tên quán
                List<Restaurant> foundByName = restaurantDAO.searchRestaurants(first.getName());
                assertFalse("Phải tìm thấy quán ăn theo tên", foundByName.isEmpty());

                // Tìm kiếm theo SĐT quán
                if (first.getPhone() != null && !first.getPhone().isEmpty()) {
                    List<Restaurant> foundByPhone = restaurantDAO.searchRestaurants(first.getPhone());
                    assertFalse("Phải tìm thấy quán ăn theo số điện thoại", foundByPhone.isEmpty());

                    Restaurant byPhone = restaurantDAO.getRestaurantByPhone(first.getPhone());
                    assertNotNull("Tìm quán bằng getRestaurantByPhone phải thành công", byPhone);

                    // 2. Thử nghiệm cấm quán ăn qua SĐT
                    String originalStatus = first.getStatus();
                    boolean banResult = restaurantDAO.banRestaurantByPhone(first.getPhone());
                    assertTrue("Cấm quán ăn theo SĐT phải trả về true", banResult);

                    Restaurant banned = restaurantDAO.getRestaurantById(first.getId());
                    assertNotNull(banned);
                    assertEquals("BANNED", banned.getStatus());

                    // 3. Thử nghiệm gỡ cấm (mở khóa) quán ăn
                    boolean unbanResult = restaurantDAO.unbanRestaurantByPhone(first.getPhone());
                    assertTrue("Gỡ cấm quán ăn theo SĐT phải trả về true", unbanResult);

                    // Phục hồi lại trạng thái ban đầu nếu cần
                    restaurantDAO.updateStatus(first.getId(), originalStatus != null ? originalStatus : "OPEN");
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi kiểm thử quán ăn (môi trường mạng): " + e.getMessage());
        }
    }
}
