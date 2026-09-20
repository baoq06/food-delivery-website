package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.*;

public class VoucherOrderFlowTest {

    private OrderDAO orderDAO;
    private int createdOrderId = -1;
    private final int testUserId = 2; // Khách hàng test mẫu

    @Before
    public void setUp() {
        orderDAO = new OrderDAO();
    }

    @After
    public void tearDown() {
        if (createdOrderId > 0) {
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
                ps.setInt(1, createdOrderId);
                ps.executeUpdate();
                System.out.println(">> Đã dọn dẹp đơn hàng test voucher #" + createdOrderId);
            } catch (Exception ignored) {}
        }
    }

    @Test
    public void testCreateAndRetrieveOrderWithVoucher() {
        // 1. Chuẩn bị món ăn trong giỏ từ dữ liệu thực tế
        com.ute.fooddelivery.dao.FoodDAO foodDAO = new com.ute.fooddelivery.dao.FoodDAO();
        List<com.ute.fooddelivery.model.Food> foods = foodDAO.getAllFoods();
        int foodId = (!foods.isEmpty()) ? foods.get(0).getId() : 1;
        String foodName = (!foods.isEmpty()) ? foods.get(0).getName() : "Món Test";

        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem(foodId, foodName, "test.jpg", 2, 75000.0, 150000.0));

        double subtotal = 150000.0;
        double shippingFee = 16000.0;
        double discountAmount = 30000.0; // Áp dụng mã UTEE30
        double totalBill = subtotal + shippingFee - discountAmount; // 136.000 đ

        Order order = new Order();
        order.setUserId(testUserId);
        order.setCustomerName("Khách Hàng Test Voucher");
        order.setPhone("0912345678");
        order.setAddress("1 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh");
        order.setNote("Giao nóng, test voucher flow");
        order.setShippingFee(shippingFee);
        order.setDistanceKm(2.5);
        order.setDiscountAmount(discountAmount);
        order.setVoucherCode("UTEE30");
        order.setTotalAmount(totalBill);
        order.setPaymentMethod("COD");

        // 2. Thực thi lưu đơn hàng
        createdOrderId = orderDAO.createOrder(order, items);
        assertTrue("Đơn hàng phải được tạo thành công với orderId > 0", createdOrderId > 0);

        // 3. Truy vấn lại đơn hàng theo ID
        Order retrievedOrder = orderDAO.getOrderById(createdOrderId);
        assertNotNull("Phải tìm thấy đơn hàng vừa tạo", retrievedOrder);
        assertEquals("Mã voucher phải khớp UTEE30", "UTEE30", retrievedOrder.getVoucherCode());
        assertEquals("Tiền giảm giá voucher phải bằng 30.000 đ", discountAmount, retrievedOrder.getDiscountAmount(), 0.01);
        assertEquals("Phí ship phải bằng 16.000 đ", shippingFee, retrievedOrder.getShippingFee(), 0.01);
        assertEquals("Tổng thanh toán phải đúng sau khi trừ giảm giá", totalBill, retrievedOrder.getTotalAmount(), 0.01);

        // 4. Kiểm tra lấy qua danh sách đơn của User
        List<Order> userOrders = orderDAO.getOrdersByUserId(testUserId);
        assertNotNull(userOrders);
        Order matched = userOrders.stream().filter(o -> o.getId() == createdOrderId).findFirst().orElse(null);
        assertNotNull("Đơn hàng test phải có trong danh sách đơn của user", matched);
        assertEquals("UTEE30", matched.getVoucherCode());
        assertEquals(discountAmount, matched.getDiscountAmount(), 0.01);
        assertEquals(totalBill, matched.getTotalAmount(), 0.01);
    }
}
