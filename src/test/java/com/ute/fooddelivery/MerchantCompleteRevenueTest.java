package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.RevenueStat;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.*;

public class MerchantCompleteRevenueTest {

    private OrderDAO orderDAO;
    private FoodDAO foodDAO;
    private int testOrderId = -1;
    private int testRestaurantId = 1;

    @Before
    public void setUp() {
        orderDAO = new OrderDAO();
        foodDAO = new FoodDAO();
    }

    @After
    public void tearDown() {
        if (testOrderId > 0) {
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try (PreparedStatement ps1 = conn.prepareStatement("DELETE FROM order_items WHERE order_id = ?");
                         PreparedStatement ps2 = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
                        ps1.setInt(1, testOrderId);
                        ps1.executeUpdate();
                        ps2.setInt(1, testOrderId);
                        ps2.executeUpdate();
                    }
                }
            } catch (Exception ignored) {}
        }
    }

    @Test
    public void testMerchantCompleteOrderIncludedInRevenue() {
        // 1. Lấy một món ăn thực tế của quán
        List<Food> foods = foodDAO.getAllFoods();
        assertNotNull(foods);
        assertFalse(foods.isEmpty());
        Food testFood = foods.get(0);
        testRestaurantId = testFood.getRestaurantId();

        // 2. Tạo đơn hàng mới cho quán này
        double itemPrice = 80000.0;
        int qty = 2;
        double subtotal = itemPrice * qty; // 160.000 đ
        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem(testFood.getId(), testFood.getName(), testFood.getImageUrl(), qty, itemPrice, subtotal));

        Order order = new Order();
        order.setUserId(2);
        order.setCustomerName("Khách Test Doanh Thu");
        order.setPhone("0987654321");
        order.setAddress("97 Võ Văn Ngân, Thủ Đức");
        order.setShippingFee(15000.0);
        order.setDistanceKm(1.5);
        order.setTotalAmount(subtotal + 15000.0);
        order.setPaymentMethod("COD");

        testOrderId = orderDAO.createOrder(order, items);
        assertTrue("Tạo đơn hàng test thành công", testOrderId > 0);

        // 3. Quán tự bấm hoàn tất đơn (merchantCompleteOrder)
        // Lúc này merchant_completed = 1, status = 'DELIVERED', nhưng shipper_delivered = 0
        boolean ok = orderDAO.merchantCompleteOrder(testOrderId);
        assertTrue("Quán bấm hoàn tất đơn thành công", ok);

        Order completedOrder = orderDAO.getOrderById(testOrderId);
        assertNotNull(completedOrder);
        assertEquals("DELIVERED", completedOrder.getStatus());
        assertTrue("merchantCompleted phải bằng true", completedOrder.isMerchantCompleted());
        assertFalse("shipperDelivered vẫn là false vì quán tự bấm", completedOrder.isShipperDelivered());

        // 4. Kiểm tra thống kê doanh thu ngày hiện tại
        LocalDate now = LocalDate.now();
        List<RevenueStat> dailyStats = orderDAO.getDailyRevenue(testRestaurantId, now.getYear(), now.getMonthValue());
        assertNotNull(dailyStats);
        boolean hasRevenueToday = dailyStats.stream().anyMatch(s -> s.getPeriodKey() == now.getDayOfMonth() && s.getRevenue() >= subtotal);
        assertTrue("Doanh thu ngày phải ghi nhận đơn hàng do Quán tự hoàn tất", hasRevenueToday);

        // 5. Kiểm tra danh sách chi tiết đơn hàng tính doanh thu (getRevenueOrders)
        List<Order> revenueOrders = orderDAO.getRevenueOrders(testRestaurantId, "DAY", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
        assertNotNull(revenueOrders);
        boolean foundOrder = revenueOrders.stream().anyMatch(o -> o.getId() == testOrderId);
        assertTrue("Danh sách đơn doanh thu phải bao gồm đơn testOrderId #" + testOrderId, foundOrder);
    }
}
