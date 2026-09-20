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
    public void testOldCodesRejected() {
        Voucher v1 = voucherService.findVoucherByCode("utee30");
        assertNotNull(v1);
        assertEquals("UTEE30", v1.getCode());

        // Old codes must be null/rejected
        assertNull(voucherService.findVoucherByCode("VINDELI30"));
        assertNull(voucherService.findVoucherByCode("FOODZONE30"));
        assertNull(voucherService.findVoucherByCode("VINDELI15"));
        assertNull(voucherService.findVoucherByCode("DELI15"));
    }

    @Test
    public void testUtee30SuccessAnyOrder() {
        // Đơn 150.000 đ -> Giảm 30.000 đ
        ValidationResult res1 = voucherService.validateAndCalculate("UTEE30", 150000, 15000);
        assertTrue(res1.isValid());
        assertEquals(30000.0, res1.getDiscountAmount(), 0.01);
        assertEquals("-30,000 đ", res1.getFormattedDiscount());

        // Đơn nhỏ 40.000 đ -> Vẫn áp dụng thành công, giảm 30.000 đ
        ValidationResult resSmall = voucherService.validateAndCalculate("UTEE30", 40000, 15000);
        assertTrue(resSmall.isValid());
        assertEquals(30000.0, resSmall.getDiscountAmount(), 0.01);

        // Đơn siêu nhỏ 25.000 đ -> Không bị âm, giảm tối đa bằng subtotal (25.000 đ)
        ValidationResult resTiny = voucherService.validateAndCalculate("UTEE30", 25000, 15000);
        assertTrue(resTiny.isValid());
        assertEquals(25000.0, resTiny.getDiscountAmount(), 0.01);
    }

    @Test
    public void testUtee20Validation() {
        // Đơn nhỏ 35.000 đ -> Áp dụng thành công UTEE20
        ValidationResult res = voucherService.validateAndCalculate("UTEE20", 35000, 15000);
        assertTrue(res.isValid());
        assertEquals(20000.0, res.getDiscountAmount(), 0.01);
    }

    @Test
    public void testFreeshipVoucher() {
        // Đơn 50.000 đ, ship 20.000 đ -> Giảm tối đa 15.000 đ
        ValidationResult res1 = voucherService.validateAndCalculate("FREESHIP", 50000, 20000);
        assertTrue(res1.isValid());
        assertEquals(15000.0, res1.getDiscountAmount(), 0.01);

        // Đơn 50.000 đ, ship chỉ có 12.000 đ -> Giảm đúng 12.000 đ (không giảm vượt phí ship)
        ValidationResult res2 = voucherService.validateAndCalculate("FREESHIP", 50000, 12000);
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
