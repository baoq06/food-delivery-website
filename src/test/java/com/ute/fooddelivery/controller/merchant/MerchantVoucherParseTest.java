package com.ute.fooddelivery.controller.merchant;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class MerchantVoucherParseTest {

    private MerchantVoucherController controller;

    @Before
    public void setUp() {
        controller = new MerchantVoucherController();
    }

    @Test
    public void testParsePercentageWithDot() {
        // Test "10.5" -> 10.5 (trước đây bị lỗi xóa dấu chấm thành 105)
        double result = controller.parsePercentage("10.5", 0);
        assertEquals(10.5, result, 0.001);

        // Test "10.0" -> 10.0 (trước đây bị lỗi xóa dấu chấm thành 100)
        double result2 = controller.parsePercentage("10.0", 0);
        assertEquals(10.0, result2, 0.001);

        // Test "5.0" -> 5.0 (trước đây bị lỗi xóa dấu chấm thành 50)
        double result3 = controller.parsePercentage("5.0", 0);
        assertEquals(5.0, result3, 0.001);
    }

    @Test
    public void testParsePercentageWithComma() {
        // Test chuẩn tiếng Việt "10,5" -> 10.5
        double result = controller.parsePercentage("10,5", 0);
        assertEquals(10.5, result, 0.001);

        // Test "7,25" -> 7.25
        double result2 = controller.parsePercentage("7,25", 0);
        assertEquals(7.25, result2, 0.001);
    }

    @Test
    public void testParsePercentageWithPercentSymbol() {
        // Test "15%" -> 15.0
        double result = controller.parsePercentage("15%", 0);
        assertEquals(15.0, result, 0.001);

        // Test "12.5%" -> 12.5
        double result2 = controller.parsePercentage("12.5%", 0);
        assertEquals(12.5, result2, 0.001);
    }

    @Test
    public void testParseCurrencyVND() {
        // Test số tiền có dấu chấm phân cách hàng nghìn: "50.000" -> 50000.0
        double result = controller.parseCurrency("50.000", 0);
        assertEquals(50000.0, result, 0.001);

        // Test số tiền có dấu phẩy: "100,000" -> 100000.0
        double result2 = controller.parseCurrency("100,000", 0);
        assertEquals(100000.0, result2, 0.001);

        // Test số nguyên thông thường: "25000" -> 25000.0
        double result3 = controller.parseCurrency("25000", 0);
        assertEquals(25000.0, result3, 0.001);
    }
}
