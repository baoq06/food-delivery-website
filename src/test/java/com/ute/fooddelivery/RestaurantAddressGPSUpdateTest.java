package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Restaurant;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class RestaurantAddressGPSUpdateTest {

    private RestaurantDAO restaurantDAO;
    private Restaurant originalRestaurant;
    private String originalAddress;
    private Double originalLat;
    private Double originalLng;

    @Before
    public void setUp() {
        restaurantDAO = new RestaurantDAO();
        List<Restaurant> list = restaurantDAO.getAllRestaurants();
        assertNotNull(list);
        assertFalse("Cần ít nhất 1 nhà hàng để test", list.isEmpty());
        originalRestaurant = list.get(0);
        originalAddress = originalRestaurant.getAddress();
        originalLat = originalRestaurant.getLatitude();
        originalLng = originalRestaurant.getLongitude();
    }

    @After
    public void tearDown() {
        if (originalRestaurant != null) {
            originalRestaurant.setAddress(originalAddress);
            originalRestaurant.setLatitude(originalLat);
            originalRestaurant.setLongitude(originalLng);
            restaurantDAO.updateRestaurant(originalRestaurant);
        }
    }

    @Test
    public void testUpdateAddressAutomaticallyUpdatesGPSCoordinates() {
        // 1. Cập nhật địa chỉ sang 'Chợ Thủ Đức, TP. Hồ Chí Minh'
        // Theo KNOWN_LOCATIONS trong GeoLocationUtils: chợ thủ đức -> [10.8546, 106.7583]
        String newAddressChoThuDuc = "Chợ Thủ Đức, Kha Vạn Cân, TP. Thủ Đức, TP. Hồ Chí Minh";
        originalRestaurant.setAddress(newAddressChoThuDuc);

        boolean updated = restaurantDAO.updateRestaurant(originalRestaurant);
        assertTrue("Cập nhật nhà hàng thành công", updated);

        // Truy vấn lại từ database để đảm bảo tọa độ đã được lưu vào đĩa cứng
        Restaurant reloaded1 = restaurantDAO.getRestaurantById(originalRestaurant.getId());
        assertNotNull(reloaded1);
        assertEquals(newAddressChoThuDuc, reloaded1.getAddress());
        assertEquals("Vĩ độ (latitude) phải cập nhật tự động theo Chợ Thủ Đức", 10.8546, reloaded1.getLatitude(), 0.01);
        assertEquals("Kinh độ (longitude) phải cập nhật tự động theo Chợ Thủ Đức", 106.7583, reloaded1.getLongitude(), 0.01);

        // 2. Chuyển địa điểm sang 'Gigamall Phạm Văn Đồng'
        // Theo KNOWN_LOCATIONS: gigamall -> [10.8286, 106.7231]
        String newAddressGigamall = "TTTM Gigamall, 240 Phạm Văn Đồng, TP. Thủ Đức";
        originalRestaurant.setAddress(newAddressGigamall);

        boolean updated2 = restaurantDAO.updateRestaurant(originalRestaurant);
        assertTrue("Cập nhật nhà hàng lần 2 thành công", updated2);

        Restaurant reloaded2 = restaurantDAO.getRestaurantById(originalRestaurant.getId());
        assertNotNull(reloaded2);
        assertEquals(newAddressGigamall, reloaded2.getAddress());
        assertEquals("Vĩ độ phải thay đổi theo Gigamall", 10.8286, reloaded2.getLatitude(), 0.01);
        assertEquals("Kinh độ phải thay đổi theo Gigamall", 106.7231, reloaded2.getLongitude(), 0.01);
    }
}
