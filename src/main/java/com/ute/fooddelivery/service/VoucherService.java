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
            "Ưu đãi độc quyền Utee cho mọi đơn món ngon",
            DiscountType.FIXED,
            30000.0,
            0.0,
            0.0,
            false,
            "🔥 HOT DEAL"
        ));

        // 2. Mã UTEE20: Ưu đãi Thực đơn
        registerVoucher(new Voucher(
            "UTEE20",
            "Giảm 20.000 đ",
            "Áp dụng cho mọi đơn đặt món tại Utee",
            DiscountType.FIXED,
            20000.0,
            0.0,
            0.0,
            false,
            "⭐ ƯU ĐÃI THỰC ĐƠN"
        ));

        // 3. Mã UTEE15: Mã phổ thông mỗi ngày
        registerVoucher(new Voucher(
            "UTEE15",
            "Giảm 15.000 đ",
            "Giảm ngay 15K cho mọi đơn đặt món",
            DiscountType.FIXED,
            15000.0,
            0.0,
            0.0,
            false,
            "⚡ MỖI NGÀY"
        ));

        // 4. Mã FREESHIP: Hỗ trợ phí vận chuyển
        registerVoucher(new Voucher(
            "FREESHIP",
            "Freeship 15.000 đ",
            "Giảm 15.000 đ phí giao hàng cho mọi đơn",
            DiscountType.FIXED,
            15000.0,
            0.0,
            0.0,
            true,
            "🛵 FREESHIP"
        ));

        // 5. Mã WELCOME: Dành cho khách hàng mới
        registerVoucher(new Voucher(
            "WELCOME",
            "Giảm 20% (tối đa 25K)",
            "Ưu đãi chào đón khách hàng mới",
            DiscountType.PERCENT,
            20.0,
            0.0,
            25000.0,
            false,
            "🎁 BẠN MỚI"
        ));
    }

    private static void registerVoucher(Voucher voucher) {
        VOUCHER_CATALOG.put(voucher.getCode().toUpperCase(Locale.ROOT), voucher);
    }

    private final com.ute.fooddelivery.dao.UserVoucherDAO userVoucherDAO = new com.ute.fooddelivery.dao.UserVoucherDAO();

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

    public Voucher findVoucherForUser(String inputCode, int userId) {
        if (inputCode == null || inputCode.trim().isEmpty()) {
            return null;
        }
        String cleanCode = inputCode.trim().toUpperCase(Locale.ROOT);
        if (CODE_ALIASES.containsKey(cleanCode)) {
            cleanCode = CODE_ALIASES.get(cleanCode);
        }
        if (userId > 0) {
            com.ute.fooddelivery.model.UserVoucher uvRecord = userVoucherDAO.getUserVoucherRecord(userId, cleanCode);
            if (uvRecord != null) {
                if (uvRecord.getQuantity() > 0) {
                    return new Voucher(
                            uvRecord.getVoucherCode(),
                            uvRecord.getTitle(),
                            uvRecord.getDescription(),
                            uvRecord.getDiscountType(),
                            uvRecord.getDiscountValue(),
                            uvRecord.getMinOrderAmount(),
                            uvRecord.getMaxDiscount(),
                            uvRecord.isFreeShip(),
                            uvRecord.getBadge(),
                            uvRecord.getRestaurantId(),
                            uvRecord.getRestaurantName()
                    );
                } else {
                    // Đã hết số lượng mã trong kho -> không cho phép áp dụng
                    return null;
                }
            }
        }
        return findVoucherByCode(cleanCode);
    }

    public ValidationResult validateAndCalculate(String inputCode, double subtotal, double shippingFee) {
        return validateAndCalculate(inputCode, subtotal, shippingFee, 0, 0);
    }

    public ValidationResult validateAndCalculate(String inputCode, double subtotal, double shippingFee, int cartRestaurantId, int userId) {
        if (inputCode == null || inputCode.trim().isEmpty()) {
            return new ValidationResult(false, "Vui lòng nhập mã ưu đãi!", 0.0, "0 đ", null);
        }

        Voucher voucher = findVoucherForUser(inputCode, userId);
        if (voucher == null) {
            return new ValidationResult(false, "Mã ưu đãi không hợp lệ hoặc đã hết lượt dùng trong kho!", 0.0, "0 đ", null);
        }

        if (voucher.getRestaurantId() != null && voucher.getRestaurantId() > 0) {
            if (cartRestaurantId > 0 && voucher.getRestaurantId() != cartRestaurantId) {
                String rName = voucher.getRestaurantName() != null ? voucher.getRestaurantName() : "quán chỉ định";
                return new ValidationResult(false, "Mã " + voucher.getCode() + " chỉ áp dụng cho món ăn tại " + rName + "!", 0.0, "0 đ", voucher);
            }
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

    public DualValidationResult validateTwoVouchers(String freeshipCode, String foodCode, double subtotal,
                                                    double shippingFee, int cartRestaurantId, int userId) {
        DecimalFormat df = new DecimalFormat("#,###");
        boolean hasFreeship = freeshipCode != null && !freeshipCode.trim().isEmpty();
        boolean hasFood = foodCode != null && !foodCode.trim().isEmpty();

        if (!hasFreeship && !hasFood) {
            return new DualValidationResult(true, "Không áp dụng mã giảm giá.", 0.0, "0 đ", 0.0, "0 đ", 0.0, "0 đ", null, null, "");
        }

        double shippingDiscount = 0.0;
        Voucher appliedFreeship = null;

        if (hasFreeship) {
            Voucher vShip = findVoucherForUser(freeshipCode, userId);
            if (vShip == null) {
                return new DualValidationResult(false, "Mã vận chuyển không hợp lệ hoặc đã hết lượt dùng!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            if (!vShip.isFreeShip()) {
                return new DualValidationResult(false, "Mã " + vShip.getCode() + " không phải là mã giảm phí vận chuyển!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            if (subtotal < vShip.getMinOrderAmount()) {
                double missing = vShip.getMinOrderAmount() - subtotal;
                return new DualValidationResult(false, "Mã freeship " + vShip.getCode() + " yêu cầu đơn từ " + df.format(vShip.getMinOrderAmount()) + " đ (còn thiếu " + df.format(missing) + " đ)!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            shippingDiscount = vShip.calculateDiscount(subtotal, shippingFee);
            appliedFreeship = vShip;
        }

        double foodDiscount = 0.0;
        Voucher appliedFood = null;

        if (hasFood) {
            Voucher vFood = findVoucherForUser(foodCode, userId);
            if (vFood == null) {
                return new DualValidationResult(false, "Mã giảm giá món ăn không hợp lệ hoặc đã hết lượt dùng!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            if (vFood.isFreeShip()) {
                return new DualValidationResult(false, "Mã " + vFood.getCode() + " là mã vận chuyển, vui lòng chọn ở mục Freeship!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            if (vFood.getRestaurantId() != null && vFood.getRestaurantId() > 0) {
                if (cartRestaurantId > 0 && vFood.getRestaurantId() != cartRestaurantId) {
                    String rName = vFood.getRestaurantName() != null ? vFood.getRestaurantName() : "quán chỉ định";
                    return new DualValidationResult(false, "Mã " + vFood.getCode() + " chỉ áp dụng cho món ăn tại " + rName + "!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
                }
            }
            if (subtotal < vFood.getMinOrderAmount()) {
                double missing = vFood.getMinOrderAmount() - subtotal;
                return new DualValidationResult(false, "Mã " + vFood.getCode() + " yêu cầu đơn từ " + df.format(vFood.getMinOrderAmount()) + " đ (còn thiếu " + df.format(missing) + " đ)!", 0, "0 đ", 0, "0 đ", 0, "0 đ", null, null, "");
            }
            foodDiscount = vFood.calculateDiscount(subtotal, shippingFee);
            appliedFood = vFood;
        }

        double totalDiscount = shippingDiscount + foodDiscount;
        String formattedShip = shippingDiscount > 0 ? ("-" + df.format(shippingDiscount) + " đ") : "0 đ";
        String formattedFood = foodDiscount > 0 ? ("-" + df.format(foodDiscount) + " đ") : "0 đ";
        String formattedTotal = totalDiscount > 0 ? ("-" + df.format(totalDiscount) + " đ") : "0 đ";

        StringBuilder combinedCodes = new StringBuilder();
        if (appliedFreeship != null) combinedCodes.append(appliedFreeship.getCode());
        if (appliedFood != null) {
            if (combinedCodes.length() > 0) combinedCodes.append(", ");
            combinedCodes.append(appliedFood.getCode());
        }

        String msg;
        if (appliedFreeship != null && appliedFood != null) {
            msg = String.format("Áp dụng thành công 2 mã (%s & %s)! Tổng giảm %s.",
                    appliedFreeship.getCode(), appliedFood.getCode(), df.format(totalDiscount) + " đ");
        } else if (appliedFreeship != null) {
            msg = String.format("Áp dụng mã freeship %s thành công! Giảm %s.",
                    appliedFreeship.getCode(), df.format(shippingDiscount) + " đ");
        } else {
            msg = String.format("Áp dụng mã giảm món %s thành công! Giảm %s.",
                    appliedFood.getCode(), df.format(foodDiscount) + " đ");
        }

        return new DualValidationResult(true, msg, shippingDiscount, formattedShip, foodDiscount, formattedFood,
                totalDiscount, formattedTotal, appliedFreeship, appliedFood, combinedCodes.toString());
    }

    public static class DualValidationResult {
        private final boolean valid;
        private final String message;
        private final double shippingDiscount;
        private final String formattedShippingDiscount;
        private final double foodDiscount;
        private final String formattedFoodDiscount;
        private final double totalDiscount;
        private final String formattedTotalDiscount;
        private final Voucher freeshipVoucher;
        private final Voucher foodVoucher;
        private final String combinedCode;

        public DualValidationResult(boolean valid, String message, double shippingDiscount, String formattedShippingDiscount,
                                    double foodDiscount, String formattedFoodDiscount, double totalDiscount,
                                    String formattedTotalDiscount, Voucher freeshipVoucher, Voucher foodVoucher,
                                    String combinedCode) {
            this.valid = valid;
            this.message = message;
            this.shippingDiscount = shippingDiscount;
            this.formattedShippingDiscount = formattedShippingDiscount;
            this.foodDiscount = foodDiscount;
            this.formattedFoodDiscount = formattedFoodDiscount;
            this.totalDiscount = totalDiscount;
            this.formattedTotalDiscount = formattedTotalDiscount;
            this.freeshipVoucher = freeshipVoucher;
            this.foodVoucher = foodVoucher;
            this.combinedCode = combinedCode;
        }

        public boolean isValid() {
            return valid;
        }

        public String getMessage() {
            return message;
        }

        public double getShippingDiscount() {
            return shippingDiscount;
        }

        public String getFormattedShippingDiscount() {
            return formattedShippingDiscount;
        }

        public double getFoodDiscount() {
            return foodDiscount;
        }

        public String getFormattedFoodDiscount() {
            return formattedFoodDiscount;
        }

        public double getTotalDiscount() {
            return totalDiscount;
        }

        public String getFormattedTotalDiscount() {
            return formattedTotalDiscount;
        }

        public Voucher getFreeshipVoucher() {
            return freeshipVoucher;
        }

        public Voucher getFoodVoucher() {
            return foodVoucher;
        }

        public String getCombinedCode() {
            return combinedCode;
        }
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
