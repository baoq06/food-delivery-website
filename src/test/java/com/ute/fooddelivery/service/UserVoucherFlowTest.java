package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.UserVoucherDAO;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.UserVoucher;
import com.ute.fooddelivery.service.VoucherService.DualValidationResult;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

public class UserVoucherFlowTest {

    private UserVoucherDAO userVoucherDAO;
    private VoucherService voucherService;
    private final int testUserId = 999999;

    @Before
    public void setUp() {
        userVoucherDAO = new UserVoucherDAO();
        voucherService = new VoucherService();
        cleanTestUserVouchers();
    }

    @After
    public void tearDown() {
        cleanTestUserVouchers();
    }

    private void cleanTestUserVouchers() {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM user_vouchers WHERE user_id = ?")) {
            ps.setInt(1, testUserId);
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }

    @Test
    public void testWelcomeVouchersGranting() {
        // Cấp mã chào mừng cho người dùng mới
        userVoucherDAO.grantWelcomeVouchers(testUserId);

        List<UserVoucher> vouchers = userVoucherDAO.getUserVouchers(testUserId);
        assertNotNull(vouchers);
        assertFalse("Kho voucher không được rỗng sau khi cấp", vouchers.isEmpty());

        UserVoucher utee30 = userVoucherDAO.getUserVoucher(testUserId, "UTEE30");
        assertNotNull("Phải có mã UTEE30", utee30);
        assertTrue("Số lượng mã UTEE30 phải >= 1", utee30.getQuantity() >= 1);

        UserVoucher freeship = userVoucherDAO.getUserVoucher(testUserId, "FREESHIP");
        assertNotNull("Phải có mã FREESHIP", freeship);
        assertTrue("FREESHIP phải có cờ isFreeShip", freeship.isFreeShip());
        assertEquals(3, freeship.getQuantity());

        UserVoucher utee20 = userVoucherDAO.getUserVoucher(testUserId, "UTEE20");
        assertNotNull("Phải có mã UTEE20", utee20);
        assertEquals(2, utee20.getQuantity());

        // Kiểm tra không cấp trùng nếu gọi lại
        userVoucherDAO.grantWelcomeVouchers(testUserId);
        assertEquals(1, userVoucherDAO.getUserVoucher(testUserId, "UTEE30").getQuantity());
    }

    @Test
    public void testRestaurantVoucherGranting() {
        Restaurant rest = new Restaurant();
        rest.setId(777);
        rest.setName("Bún Bò Huế Utee Quán");

        UserVoucher granted = userVoucherDAO.grantRestaurantVoucherIfEligible(testUserId, rest);
        assertNotNull("Lần đầu ghé quán phải được tặng mã", granted);
        assertEquals("QUAN777_20K", granted.getVoucherCode());
        assertEquals(Integer.valueOf(777), granted.getRestaurantId());
        assertEquals("Bún Bò Huế Utee Quán", granted.getRestaurantName());

        // Ghé lại ngay lập tức -> Không được cấp thêm (chưa quá 7 ngày)
        UserVoucher secondVisit = userVoucherDAO.grantRestaurantVoucherIfEligible(testUserId, rest);
        assertNull("Ghé lại ngay không được cấp thêm", secondVisit);
    }

    @Test
    public void testDualVoucherValidation() {
        userVoucherDAO.grantWelcomeVouchers(testUserId);

        // Áp dụng đồng thời 1 freeship (15k) + 1 voucher món UTEE30 (30k) trên đơn 100k, ship 15k
        DualValidationResult result = voucherService.validateTwoVouchers(
                "FREESHIP", "UTEE30", 100000, 15000, 1, testUserId
        );

        assertTrue(result.isValid());
        assertEquals(15000.0, result.getShippingDiscount(), 0.01);
        assertEquals(30000.0, result.getFoodDiscount(), 0.01);
        assertEquals(45000.0, result.getTotalDiscount(), 0.01);
        assertEquals("FREESHIP, UTEE30", result.getCombinedCode());
    }

    @Test
    public void testFreeshipOnlyValidation() {
        userVoucherDAO.grantWelcomeVouchers(testUserId);

        // Áp dụng CHỈ MÃ FREESHIP trên đơn 80k, ship 15k
        DualValidationResult result = voucherService.validateTwoVouchers(
                "FREESHIP", null, 80000, 15000, 1, testUserId
        );

        assertTrue(result.isValid());
        assertEquals(15000.0, result.getShippingDiscount(), 0.01);
        assertEquals(0.0, result.getFoodDiscount(), 0.01);
        assertEquals(15000.0, result.getTotalDiscount(), 0.01);
        assertEquals("FREESHIP", result.getCombinedCode());
        assertNotNull(result.getFreeshipVoucher());
        assertNull(result.getFoodVoucher());
    }

    @Test
    public void testRestaurantVoucherConstraint() {
        Restaurant rest = new Restaurant();
        rest.setId(777);
        rest.setName("Bún Bò Huế Utee Quán");
        userVoucherDAO.grantRestaurantVoucherIfEligible(testUserId, rest);

        // Áp dụng đúng quán 777 -> Hợp lệ
        DualValidationResult validResult = voucherService.validateTwoVouchers(
                null, "QUAN777_20K", 100000, 15000, 777, testUserId
        );
        assertTrue("Mã quán phải hợp lệ khi đặt đúng quán", validResult.isValid());
        assertEquals(20000.0, validResult.getFoodDiscount(), 0.01);

        // Áp dụng sai quán (ví dụ giỏ hàng từ quán 888) -> Bị từ chối
        DualValidationResult invalidResult = voucherService.validateTwoVouchers(
                null, "QUAN777_20K", 100000, 15000, 888, testUserId
        );
        assertFalse("Mã quán phải bị từ chối khi đặt món ở quán khác", invalidResult.isValid());
        assertTrue(invalidResult.getMessage().contains("chỉ áp dụng cho món ăn tại"));
    }

    @Test
    public void testVoucherDeductionFlow() {
        userVoucherDAO.grantWelcomeVouchers(testUserId);

        UserVoucher vBefore = userVoucherDAO.getUserVoucher(testUserId, "UTEE30");
        assertNotNull(vBefore);
        int initialQty = vBefore.getQuantity();
        assertEquals(1, initialQty);

        // Khách chốt đơn áp mã UTEE30 và FREESHIP
        boolean used = userVoucherDAO.useVouchers(testUserId, Arrays.asList("UTEE30", "FREESHIP"));
        assertTrue("Trừ số lượng voucher phải thành công", used);

        // Mã UTEE30 có quantity=1, sau khi trừ sẽ về 0 và getUserVoucher (chỉ lấy quantity > 0) trả về null
        UserVoucher vAfter30 = userVoucherDAO.getUserVoucher(testUserId, "UTEE30");
        assertNull("Mã UTEE30 đã dùng hết số lượng không còn khả dụng", vAfter30);

        UserVoucher vAfterShip = userVoucherDAO.getUserVoucher(testUserId, "FREESHIP");
        assertNotNull(vAfterShip);
        assertEquals(2, vAfterShip.getQuantity());

        // Dùng tiếp mã UTEE30 khi số lượng đã về 0 -> Bị chặn
        boolean useAgain = userVoucherDAO.useVoucher(testUserId, "UTEE30");
        assertFalse("Không thể dùng tiếp mã đã hết số lượng", useAgain);

        // Thẩm định cũng phải thất bại vì số lượng = 0
        DualValidationResult resZero = voucherService.validateTwoVouchers(
                null, "UTEE30", 100000, 15000, 1, testUserId
        );
        assertFalse("Không thể thẩm định mã đã hết lượt dùng trong kho", resZero.isValid());
    }
}
