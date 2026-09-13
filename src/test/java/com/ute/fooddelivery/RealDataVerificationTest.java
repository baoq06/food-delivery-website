package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import org.junit.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class RealDataVerificationTest {

    @Test
    public void testDatabaseCleanupAndUpdates() throws Exception {
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            assertNotNull("Connection should not be null", conn);

            // 1. Verify restaurants count is exactly 2
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM restaurants")) {
                assertTrue(rs.next());
                int count = rs.getInt(1);
                assertEquals("Should have exactly 2 restaurants left", 2, count);
            }

            // Verify restaurant IDs 3 and 4 do NOT exist
            try (ResultSet rs = stmt.executeQuery("SELECT restaurant_id, name FROM restaurants WHERE restaurant_id IN (3, 4)")) {
                assertFalse("Restaurants 3 and 4 must not exist", rs.next());
            }

            // 2. Verify driver Nguyễn Văn Giao does not exist
            try (ResultSet rs = stmt.executeQuery("SELECT driver_id, name FROM drivers WHERE name LIKE '%Nguyễn Văn Giao%'")) {
                assertFalse("Nguyễn Văn Giao must not exist in drivers", rs.next());
            }

            // 3. Verify driver tran gia kiet exists and Kaito Kid is renamed
            try (ResultSet rs = stmt.executeQuery("SELECT driver_id, name FROM drivers WHERE name = 'tran gia kiet'")) {
                assertTrue("Driver 'tran gia kiet' must exist", rs.next());
            }
            try (ResultSet rs = stmt.executeQuery("SELECT driver_id, name FROM drivers WHERE name LIKE '%Kaito Kid%'")) {
                assertFalse("Driver 'Kaito Kid' must no longer exist", rs.next());
            }
        }
    }

    @Test
    public void testAdminRealDataQueries() {
        OrderDAO orderDAO = new OrderDAO();
        UserDAO userDAO = new UserDAO();

        // 1. Total revenue
        double revenue = orderDAO.getTotalDeliveredRevenue();
        assertTrue("Revenue should be non-negative", revenue >= 0);

        // 2. Order status counts
        Map<String, Integer> orderStats = orderDAO.getOrderStatusCounts();
        assertNotNull(orderStats);
        assertTrue("Order stats should contain TOTAL key", orderStats.containsKey("TOTAL"));
        assertTrue("Total orders should be non-negative", orderStats.get("TOTAL") >= 0);

        // 3. User stats
        Map<String, Integer> userStats = userDAO.getUserStats();
        assertNotNull(userStats);
        assertTrue("Total users should be > 0", userStats.get("totalUsers") > 0);
        assertEquals("Should have 2 drivers", Integer.valueOf(2), userStats.get("driverCount"));
        assertEquals("Should have 2 restaurants", Integer.valueOf(2), userStats.get("restaurantCount"));

        // 4. Recent orders for admin
        List<Order> recentOrders = orderDAO.getRecentOrdersForAdmin(10);
        assertNotNull(recentOrders);
        for (Order o : recentOrders) {
            assertTrue("Order id should be > 0", o.getId() > 0);
            assertNotNull("Status should not be null", o.getStatus());
        }
    }

    @Test
    public void testFoodRealRatingData() {
        FoodDAO foodDAO = new FoodDAO();
        List<Food> foods = foodDAO.getAllFoods();
        assertNotNull(foods);
        assertFalse("Foods list should not be empty", foods.isEmpty());

        for (Food f : foods) {
            assertTrue("Food ID should be > 0", f.getId() > 0);
            assertNotNull("Food name should not be null", f.getName());
            assertTrue("Food rating should be >= 0.0 and <= 5.0", f.getRating() >= 0.0 && f.getRating() <= 5.0);
            assertTrue("Review count should be >= 0", f.getReviewCount() >= 0);

            // Verify foods belong only to active restaurants (ID 1 or 2)
            assertTrue("Food must belong to active restaurant", f.getRestaurantId() == 1 || f.getRestaurantId() == 2);
        }
    }
}
