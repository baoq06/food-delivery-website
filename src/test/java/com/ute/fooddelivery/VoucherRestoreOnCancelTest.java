package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserVoucherDAO;
import com.ute.fooddelivery.dao.VoucherDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.UserVoucher;
import com.ute.fooddelivery.model.Voucher;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

public class VoucherRestoreOnCancelTest {

    private OrderDAO orderDAO;
    private UserVoucherDAO userVoucherDAO;
    private VoucherDAO voucherDAO;
    private FoodDAO foodDAO;
    private final int testUserId = 2; // Khách hàng hợp lệ trong CSDL mẫu
    private int validFoodId = 1;
    private int createdOrderId = -1;

    @Before
    public void setUp() {
        orderDAO = new OrderDAO();
        userVoucherDAO = new UserVoucherDAO();
        voucherDAO = new VoucherDAO();
        foodDAO = new FoodDAO();

        List<Food> foods = foodDAO.getAllFoods();
        if (!foods.isEmpty()) {
            validFoodId = foods.get(0).getId();
        }

        // Dọn dẹp và cấp mới voucher test cho testUserId
        cleanTestUserVoucher("UTEE30");
        cleanTestUserVoucher("FREESHIP");
        cleanTestUserVoucher("UTEE20");

        userVoucherDAO.addOrIncrementVoucher(testUserId, "UTEE30", "Giảm 30K", "Test",
                Voucher.DiscountType.FIXED, 30000.0, 0, 0, false, "HOT", null, null, 1);
        userVoucherDAO.addOrIncrementVoucher(testUserId, "FREESHIP", "Freeship", "Test",
                Voucher.DiscountType.FIXED, 15000.0, 0, 0, true, "FREESHIP", null, null, 2);
        userVoucherDAO.addOrIncrementVoucher(testUserId, "UTEE20", "Giảm 20K", "Test",
                Voucher.DiscountType.FIXED, 20000.0, 0, 0, false, "HOT", null, null, 1);
    }

    private void cleanTestUserVoucher(String code) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM user_vouchers WHERE user_id = ? AND UPPER(voucher_code) = ?")) {
            ps.setInt(1, testUserId);
            ps.setString(2, code.toUpperCase());
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }

    @After
    public void tearDown() {
        if (createdOrderId > 0) {
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
                ps.setInt(1, createdOrderId);
                ps.executeUpdate();
            } catch (Exception ignored) {}
        }
    }

    @Test
    public void testCustomerCancelRestoresVouchers() {
        // Đảm bảo voucher ban đầu có sẵn
        UserVoucher uvBefore = userVoucherDAO.getUserVoucherRecord(testUserId, "UTEE30");
        assertNotNull(uvBefore);
        assertEquals(1, uvBefore.getQuantity());

        // 1. Giả lập trừ voucher khi đặt hàng
        boolean used = userVoucherDAO.useVouchers(testUserId, Arrays.asList("UTEE30", "FREESHIP"));
        assertTrue("Trừ voucher khi đặt hàng phải thành công", used);
        voucherDAO.incrementUsedCount("UTEE30");
        voucherDAO.incrementUsedCount("FREESHIP");

        Voucher vDb = voucherDAO.getVoucherByCode("UTEE30");
        int usedCountAfterDeduct = (vDb != null) ? vDb.getUsedCount() : 0;

        // 2. Tạo đơn hàng với mã "UTEE30, FREESHIP"
        Order order = new Order();
        order.setUserId(testUserId);
        order.setCustomerName("Khách Hàng Test Hủy");
        order.setPhone("0912345678");
        order.setAddress("1 Võ Văn Ngân, Thủ Đức");
        order.setVoucherCode("UTEE30, FREESHIP");
        order.setDiscountAmount(45000.0);
        order.setTotalAmount(100000.0);

        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem(validFoodId, "Món Test", "test.jpg", 1, 100000.0, 100000.0));
        createdOrderId = orderDAO.createOrder(order, items);
        assertTrue(createdOrderId > 0);

        // 3. Khách hàng hủy đơn (cancelOrderByCustomer)
        boolean cancelled = orderDAO.cancelOrderByCustomer(createdOrderId, testUserId);
        assertTrue("Hủy đơn thành công", cancelled);

        // 4. Kiểm tra voucher đã được hoàn trả lại cho khách
        UserVoucher uvAfter = userVoucherDAO.getUserVoucherRecord(testUserId, "UTEE30");
        assertNotNull(uvAfter);
        assertEquals("Số lượng voucher UTEE30 phải được hoàn lại như ban đầu (1)", 1, uvAfter.getQuantity());

        UserVoucher uvShipAfter = userVoucherDAO.getUserVoucherRecord(testUserId, "FREESHIP");
        assertNotNull(uvShipAfter);
        assertEquals("Số lượng voucher FREESHIP phải được hoàn lại như ban đầu (2)", 2, uvShipAfter.getQuantity());

        if (vDb != null) {
            Voucher vDbAfter = voucherDAO.getVoucherByCode("UTEE30");
            assertEquals("used_count của voucher phải được giảm đi 1", usedCountAfterDeduct - 1, vDbAfter.getUsedCount());
        }

        // 5. Kiểm tra tính Idempotent: Gọi lại restoreVouchersForOrder lần nữa không được hoàn lặp
        boolean secondRestore = orderDAO.restoreVouchersForOrder(createdOrderId);
        assertFalse("Không được hoàn trả lần 2 cho cùng một đơn hàng", secondRestore);
        assertEquals("Số lượng voucher không bị tăng lặp", 1, userVoucherDAO.getUserVoucherRecord(testUserId, "UTEE30").getQuantity());
    }

    @Test
    public void testMerchantOrShipperCancelRestoresVouchers() {
        UserVoucher uvBefore = userVoucherDAO.getUserVoucherRecord(testUserId, "UTEE20");
        assertNotNull(uvBefore);
        assertEquals(1, uvBefore.getQuantity());

        // Giả lập dùng mã UTEE20
        userVoucherDAO.useVoucher(testUserId, "UTEE20");
        voucherDAO.incrementUsedCount("UTEE20");

        // Tạo đơn hàng
        Order order = new Order();
        order.setUserId(testUserId);
        order.setCustomerName("Khách Hàng Test Quán Hủy");
        order.setPhone("0912345678");
        order.setAddress("1 Võ Văn Ngân, Thủ Đức");
        order.setVoucherCode("UTEE20");
        order.setDiscountAmount(20000.0);
        order.setTotalAmount(80000.0);

        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem(validFoodId, "Món Test 2", "test.jpg", 1, 100000.0, 100000.0));
        int oId = orderDAO.createOrder(order, items);
        assertTrue(oId > 0);

        // Quán hủy / Shipper hủy: Cập nhật status = CANCELLED
        boolean updated = orderDAO.updateOrderStatus(oId, "CANCELLED");
        assertTrue("Cập nhật sang CANCELLED thành công", updated);

        // Voucher phải được tự động hoàn trả
        UserVoucher uvAfter = userVoucherDAO.getUserVoucherRecord(testUserId, "UTEE20");
        assertNotNull(uvAfter);
        assertEquals("Voucher UTEE20 phải được hoàn trả đầy đủ khi quán hoặc shipper hủy", 1, uvAfter.getQuantity());

        // Dọn dẹp
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
            ps.setInt(1, oId);
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }

    @Test
    public void testOrderCancelledWithoutPriorVoucherDoesNotGiftVoucher() {
        String testCode = "BEPVIET20K";
        // Đảm bảo user chưa từng có voucher này trong ví
        cleanTestUserVoucher(testCode);
        assertNull("Khách chưa lưu mã này vào ví", userVoucherDAO.getUserVoucherRecord(testUserId, testCode));

        // Giả lập đơn hàng có mã này bị hủy
        Order order = new Order();
        order.setUserId(testUserId);
        order.setCustomerName("Khách Hàng Test Không Tặng Voucher");
        order.setPhone("0912345678");
        order.setAddress("1 Võ Văn Ngân, Thủ Đức");
        order.setVoucherCode(testCode);
        order.setDiscountAmount(20000.0);
        order.setTotalAmount(80000.0);

        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem(validFoodId, "Món Test 3", "test.jpg", 1, 100000.0, 100000.0));
        int oId = orderDAO.createOrder(order, items);
        assertTrue(oId > 0);

        // Hủy đơn hàng
        boolean updated = orderDAO.updateOrderStatus(oId, "CANCELLED");
        assertTrue(updated);

        // Kiểm tra ví: Khách tuyệt đối KHÔNG được tự động tặng mã này vào ví!
        UserVoucher uvWallet = userVoucherDAO.getUserVoucherRecord(testUserId, testCode);
        assertNull("Hủy đơn không được tự động cấp mới voucher vào ví khách hàng", uvWallet);

        // Dọn dẹp
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
            ps.setInt(1, oId);
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }
}
