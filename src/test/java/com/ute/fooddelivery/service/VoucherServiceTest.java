package com.ute.fooddelivery.service;

import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.VoucherService.ValidationResult;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class VoucherServiceTest {

    private VoucherService voucherService;

    @Before
    public void setUp() {
        voucherService = new VoucherService();
    }

    @Test
    public void testGetAllVouchers() {
        List<Voucher> vouchers = voucherService.getAllVouchers();
        assertNotNull(vouchers);
        assertTrue("Hệ thống phải có ít nhất 5 voucher chuẩn", vouchers.size() >= 5);

        boolean hasUtee30 = vouchers.stream().anyMatch(v -> "UTEE30".equals(v.getCode()));
        boolean hasUtee20 = vouchers.stream().anyMatch(v -> "UTEE20".equals(v.getCode()));
        boolean hasUtee15 = vouchers.stream().anyMatch(v -> "UTEE15".equals(v.getCode()));
        boolean hasFreeship = vouchers.stream().anyMatch(v -> "FREESHIP".equals(v.getCode()));
        boolean hasWelcome = vouchers.stream().anyMatch(v -> "WELCOME".equals(v.getCode()));

        assertTrue(hasUtee30);
        assertTrue(hasUtee20);
        assertTrue(hasUtee15);
        assertTrue(hasFreeship);
        assertTrue(hasWelcome);
    }

    @Test
    public void testFindVoucherWithAliases() {
        Voucher v1 = voucherService.findVoucherByCode("utee30");
        assertNotNull(v1);
        assertEquals("UTEE30", v1.getCode());

        Voucher v2 = voucherService.findVoucherByCode("VINDELI30");
        assertNotNull(v2);
        assertEquals("UTEE30", v2.getCode());

        Voucher v3 = voucherService.findVoucherByCode("FOODZONE30");
        assertNotNull(v3);
        assertEquals("UTEE30", v3.getCode());

        Voucher v4 = voucherService.findVoucherByCode("VINDELI15");
        assertNotNull(v4);
        assertEquals("UTEE15", v4.getCode());
    }

    @Test
    public void testUtee30SuccessAndEligibility() {
        // Đơn 150.000 đ > 120.000 đ -> Giảm 30.000 đ
        ValidationResult resSuccess = voucherService.validateAndCalculate("UTEE30", 150000, 15000);
        assertTrue(resSuccess.isValid());
        assertEquals(30000.0, resSuccess.getDiscountAmount(), 0.01);
        assertEquals("-30,000 đ", resSuccess.getFormattedDiscount());

        // Đơn 80.000 đ < 120.000 đ -> Báo lỗi thiếu tiền
        ValidationResult resFail = voucherService.validateAndCalculate("UTEE30", 80000, 15000);
        assertFalse(resFail.isValid());
        assertEquals(0.0, resFail.getDiscountAmount(), 0.01);
        assertTrue(resFail.getMessage().contains("yêu cầu đơn từ"));
    }

    @Test
    public void testUtee20Validation() {
        // Đơn 110.000 đ > 100.000 đ -> Giảm 20.000 đ
        ValidationResult res = voucherService.validateAndCalculate("UTEE20", 110000, 15000);
        assertTrue(res.isValid());
        assertEquals(20000.0, res.getDiscountAmount(), 0.01);

        // Đơn 70.000 đ < 100.000 đ
        ValidationResult resUnder = voucherService.validateAndCalculate("UTEE20", 70000, 15000);
        assertFalse(resUnder.isValid());
    }

    @Test
    public void testFreeshipVoucher() {
        // Đơn 100.000 đ > 80.000 đ, ship 20.000 đ -> Giảm tối đa 15.000 đ
        ValidationResult res1 = voucherService.validateAndCalculate("FREESHIP", 100000, 20000);
        assertTrue(res1.isValid());
        assertEquals(15000.0, res1.getDiscountAmount(), 0.01);

        // Đơn 100.000 đ, ship chỉ có 12.000 đ -> Giảm đúng 12.000 đ (không giảm vượt phí ship)
        ValidationResult res2 = voucherService.validateAndCalculate("FREESHIP", 100000, 12000);
        assertTrue(res2.isValid());
        assertEquals(12000.0, res2.getDiscountAmount(), 0.01);
    }

    @Test
    public void testWelcomePercentVoucher() {
        // Đơn 80.000 đ, giảm 20% = 16.000 đ (< max 25k)
        ValidationResult res1 = voucherService.validateAndCalculate("WELCOME", 80000, 15000);
        assertTrue(res1.isValid());
        assertEquals(16000.0, res1.getDiscountAmount(), 0.01);

        // Đơn 200.000 đ, giảm 20% = 40.000 đ -> Giới hạn maxDiscount = 25.000 đ
        ValidationResult res2 = voucherService.validateAndCalculate("WELCOME", 20000, 15000);
        // Nhưng 20.000 < minOrderAmount (50.000) -> Không hợp lệ
        assertFalse(res2.isValid());

        ValidationResult res3 = voucherService.validateAndCalculate("WELCOME", 200000, 15000);
        assertTrue(res3.isValid());
        assertEquals(25000.0, res3.getDiscountAmount(), 0.01);
    }

    @Test
    public void testInvalidCode() {
        ValidationResult res = voucherService.validateAndCalculate("INVALID_CODE_XYZ", 200000, 15000);
        assertFalse(res.isValid());
        assertEquals(0.0, res.getDiscountAmount(), 0.01);
    }
}
