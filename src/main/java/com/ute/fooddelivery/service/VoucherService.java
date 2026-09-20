package com.ute.fooddelivery.service;

import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.model.Voucher.DiscountType;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class VoucherService {

    private static final Map<String, Voucher> VOUCHER_CATALOG = new LinkedHashMap<>();
    private static final Map<String, String> CODE_ALIASES = new LinkedHashMap<>();

    static {
        // 1. Mã UTEE30: Ưu đãi độc quyền trên Banner Trang chủ
        registerVoucher(new Voucher(
            "UTEE30",
            "Giảm 30.000 đ",
            "Ưu đãi độc quyền Utee cho đơn từ 120.000 đ",
            DiscountType.FIXED,
            30000.0,
            120000.0,
            0.0,
            false,
            "🔥 HOT DEAL"
        ));

        // 2. Mã UTEE20: Ưu đãi Thực đơn
        registerVoucher(new Voucher(
            "UTEE20",
            "Giảm 20.000 đ",
            "Áp dụng cho mọi đơn đặt món từ 100.000 đ",
            DiscountType.FIXED,
            20000.0,
            100000.0,
            0.0,
            false,
            "⭐ ƯU ĐÃI THỰC ĐƠN"
        ));

        // 3. Mã UTEE15: Mã phổ thông mỗi ngày
        registerVoucher(new Voucher(
            "UTEE15",
            "Giảm 15.000 đ",
            "Giảm ngay 15K cho đơn món ngon từ 60.000 đ",
            DiscountType.FIXED,
            15000.0,
            60000.0,
            0.0,
            false,
            "⚡ MỖI NGÀY"
        ));

        // 4. Mã FREESHIP: Hỗ trợ phí vận chuyển
        registerVoucher(new Voucher(
            "FREESHIP",
            "Freeship 15.000 đ",
            "Giảm tối đa 15.000 đ phí giao hàng cho đơn từ 80.000 đ",
            DiscountType.FIXED,
            15000.0,
            80000.0,
            0.0,
            true,
            "🛵 FREESHIP"
        ));

        // 5. Mã WELCOME: Dành cho khách hàng mới
        registerVoucher(new Voucher(
            "WELCOME",
            "Giảm 20% (tối đa 25K)",
            "Ưu đãi chào đón khách hàng mới cho đơn từ 50.000 đ",
            DiscountType.PERCENT,
            20.0,
            50000.0,
            25000.0,
            false,
            "🎁 BẠN MỚI"
        ));

        // Bí danh tương thích ngược (aliases)
        CODE_ALIASES.put("VINDELI30", "UTEE30");
        CODE_ALIASES.put("FOODZONE30", "UTEE30");
        CODE_ALIASES.put("VINDELI15", "UTEE15");
        CODE_ALIASES.put("DELI15", "UTEE15");
    }

    private static void registerVoucher(Voucher voucher) {
        VOUCHER_CATALOG.put(voucher.getCode().toUpperCase(Locale.ROOT), voucher);
    }

    public List<Voucher> getAllVouchers() {
        return Collections.unmodifiableList(new ArrayList<>(VOUCHER_CATALOG.values()));
    }

    public Voucher findVoucherByCode(String inputCode) {
        if (inputCode == null || inputCode.trim().isEmpty()) {
            return null;
        }
        String cleanCode = inputCode.trim().toUpperCase(Locale.ROOT);
        if (CODE_ALIASES.containsKey(cleanCode)) {
            cleanCode = CODE_ALIASES.get(cleanCode);
        }
        return VOUCHER_CATALOG.get(cleanCode);
    }

    public ValidationResult validateAndCalculate(String inputCode, double subtotal, double shippingFee) {
        if (inputCode == null || inputCode.trim().isEmpty()) {
            return new ValidationResult(false, "Vui lòng nhập mã ưu đãi!", 0.0, "0 đ", null);
        }

        Voucher voucher = findVoucherByCode(inputCode);
        if (voucher == null) {
            return new ValidationResult(false, "Mã ưu đãi không hợp lệ hoặc đã hết hạn!", 0.0, "0 đ", null);
        }

        if (subtotal < voucher.getMinOrderAmount()) {
            DecimalFormat df = new DecimalFormat("#,###");
            double missing = voucher.getMinOrderAmount() - subtotal;
            String msg = String.format("Mã %s yêu cầu đơn từ %s đ. Bạn cần thêm %s đ để áp dụng.",
                    voucher.getCode(), df.format(voucher.getMinOrderAmount()), df.format(missing));
            return new ValidationResult(false, msg, 0.0, "0 đ", voucher);
        }

        double discount = voucher.calculateDiscount(subtotal, shippingFee);
        DecimalFormat df = new DecimalFormat("#,###");
        String formattedDiscount = "-" + df.format(discount) + " đ";
        String successMsg = String.format("Áp dụng mã %s thành công! Bạn được giảm %s.",
                voucher.getCode(), df.format(discount) + " đ");

        return new ValidationResult(true, successMsg, discount, formattedDiscount, voucher);
    }

    public static class ValidationResult {
        private final boolean valid;
        private final String message;
        private final double discountAmount;
        private final String formattedDiscount;
        private final Voucher voucher;

        public ValidationResult(boolean valid, String message, double discountAmount, 
                                String formattedDiscount, Voucher voucher) {
            this.valid = valid;
            this.message = message;
            this.discountAmount = discountAmount;
            this.formattedDiscount = formattedDiscount;
            this.voucher = voucher;
        }

        public boolean isValid() {
            return valid;
        }

        public String getMessage() {
            return message;
        }

        public double getDiscountAmount() {
            return discountAmount;
        }

        public String getFormattedDiscount() {
            return formattedDiscount;
        }

        public Voucher getVoucher() {
            return voucher;
        }
    }
}
