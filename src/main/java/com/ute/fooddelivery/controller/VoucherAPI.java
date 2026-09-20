package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.VoucherService;
import com.ute.fooddelivery.service.VoucherService.ValidationResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.DecimalFormat;
import java.util.List;
import java.util.Locale;

@WebServlet("/api/voucher")
public class VoucherAPI extends HttpServlet {
    private final VoucherService voucherService = new VoucherService();
    private final com.ute.fooddelivery.dao.UserVoucherDAO userVoucherDAO = new com.ute.fooddelivery.dao.UserVoucherDAO();
    private final com.ute.fooddelivery.service.RestaurantService restaurantService = new com.ute.fooddelivery.service.RestaurantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processRequest(req, resp);
    }

    private void processRequest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        jakarta.servlet.http.HttpSession session = req.getSession(false);
        com.ute.fooddelivery.model.User currentUser = session != null ? (com.ute.fooddelivery.model.User) session.getAttribute("currentUser") : null;
        int userId = currentUser != null ? currentUser.getId() : 0;

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "validate";
        }

        double subtotal = 0.0;
        try {
            String subParam = req.getParameter("subtotal");
            if (subParam != null && !subParam.trim().isEmpty()) {
                subtotal = Double.parseDouble(subParam.trim());
            }
        } catch (Exception ignored) {}

        double shippingFee = 15000.0;
        try {
            String shipParam = req.getParameter("shippingFee");
            if (shipParam != null && !shipParam.trim().isEmpty()) {
                shippingFee = Double.parseDouble(shipParam.trim());
            }
        } catch (Exception ignored) {}

        int restaurantId = 0;
        try {
            String rParam = req.getParameter("restaurantId");
            if (rParam != null && !rParam.trim().isEmpty()) {
                restaurantId = Integer.parseInt(rParam.trim());
            }
        } catch (Exception ignored) {}

        DecimalFormat df = new DecimalFormat("#,###");

        if ("list".equalsIgnoreCase(action)) {
            StringBuilder sb = new StringBuilder();
            sb.append("{\"success\":true,\"vouchers\":[");

            if (userId > 0) {
                List<com.ute.fooddelivery.model.UserVoucher> uvList = userVoucherDAO.getUserVouchers(userId);
                for (int i = 0; i < uvList.size(); i++) {
                    com.ute.fooddelivery.model.UserVoucher uv = uvList.get(i);
                    boolean eligibleOrder = subtotal >= uv.getMinOrderAmount();
                    boolean eligibleRest = uv.isEligibleForRestaurant(restaurantId);
                    boolean eligible = eligibleOrder && eligibleRest;

                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"code\":\"").append(escapeJson(uv.getVoucherCode())).append("\",");
                    sb.append("\"title\":\"").append(escapeJson(uv.getTitle())).append("\",");
                    sb.append("\"description\":\"").append(escapeJson(uv.getDescription())).append("\",");
                    sb.append("\"badge\":\"").append(escapeJson(uv.getBadge())).append("\",");
                    sb.append("\"minOrder\":").append(String.format(Locale.US, "%.0f", uv.getMinOrderAmount())).append(",");
                    sb.append("\"formattedMinOrder\":\"").append(df.format(uv.getMinOrderAmount())).append(" đ\",");
                    sb.append("\"isFreeShip\":").append(uv.isFreeShip()).append(",");
                    sb.append("\"restaurantId\":").append(uv.getRestaurantId() != null ? uv.getRestaurantId() : 0).append(",");
                    sb.append("\"restaurantName\":\"").append(escapeJson(uv.getRestaurantName())).append("\",");
                    sb.append("\"quantity\":").append(uv.getQuantity()).append(",");
                    sb.append("\"eligible\":").append(eligible).append(",");
                    sb.append("\"eligibleRest\":").append(eligibleRest).append(",");
                    sb.append("\"eligibleOrder\":").append(eligibleOrder);
                    sb.append("}");
                }
            } else {
                List<Voucher> vouchers = voucherService.getAllVouchers();
                for (int i = 0; i < vouchers.size(); i++) {
                    Voucher v = vouchers.get(i);
                    boolean eligible = v.isEligible(subtotal);

                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"code\":\"").append(escapeJson(v.getCode())).append("\",");
                    sb.append("\"title\":\"").append(escapeJson(v.getTitle())).append("\",");
                    sb.append("\"description\":\"").append(escapeJson(v.getDescription())).append("\",");
                    sb.append("\"badge\":\"").append(escapeJson(v.getBadge())).append("\",");
                    sb.append("\"minOrder\":").append(String.format(Locale.US, "%.0f", v.getMinOrderAmount())).append(",");
                    sb.append("\"formattedMinOrder\":\"").append(df.format(v.getMinOrderAmount())).append(" đ\",");
                    sb.append("\"isFreeShip\":").append(v.isFreeShip()).append(",");
                    sb.append("\"restaurantId\":0,");
                    sb.append("\"restaurantName\":\"\",");
                    sb.append("\"quantity\":1,");
                    sb.append("\"eligible\":").append(eligible).append(",");
                    sb.append("\"eligibleRest\":true,");
                    sb.append("\"eligibleOrder\":").append(eligible);
                    sb.append("}");
                }
            }

            sb.append("]}");
            resp.getWriter().write(sb.toString());
            return;
        }

        if ("validate-dual".equalsIgnoreCase(action)) {
            String freeshipCode = req.getParameter("freeshipCode");
            if (freeshipCode == null || freeshipCode.trim().isEmpty()) {
                freeshipCode = req.getParameter("shippingCode");
            }
            if (freeshipCode == null || freeshipCode.trim().isEmpty()) {
                freeshipCode = req.getParameter("shippingVoucherCode");
            }

            String foodCode = req.getParameter("foodCode");
            if (foodCode == null || foodCode.trim().isEmpty()) {
                foodCode = req.getParameter("foodVoucherCode");
            }

            VoucherService.DualValidationResult dResult = voucherService.validateTwoVouchers(
                    freeshipCode, foodCode, subtotal, shippingFee, restaurantId, userId
            );

            String appliedFreeship = dResult.getFreeshipVoucher() != null ? dResult.getFreeshipVoucher().getCode() : (dResult.isValid() && freeshipCode != null && !freeshipCode.trim().isEmpty() && dResult.getShippingDiscount() > 0 ? freeshipCode.trim().toUpperCase() : "");
            String appliedFood = dResult.getFoodVoucher() != null ? dResult.getFoodVoucher().getCode() : (dResult.isValid() && foodCode != null && !foodCode.trim().isEmpty() && dResult.getFoodDiscount() > 0 ? foodCode.trim().toUpperCase() : "");

            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"success\":true,");
            sb.append("\"valid\":").append(dResult.isValid()).append(",");
            sb.append("\"message\":\"").append(escapeJson(dResult.getMessage())).append("\",");
            sb.append("\"shippingDiscount\":").append(String.format(Locale.US, "%.0f", dResult.getShippingDiscount())).append(",");
            sb.append("\"formattedShippingDiscount\":\"").append(escapeJson(dResult.getFormattedShippingDiscount())).append("\",");
            sb.append("\"foodDiscount\":").append(String.format(Locale.US, "%.0f", dResult.getFoodDiscount())).append(",");
            sb.append("\"formattedFoodDiscount\":\"").append(escapeJson(dResult.getFormattedFoodDiscount())).append("\",");
            sb.append("\"totalDiscount\":").append(String.format(Locale.US, "%.0f", dResult.getTotalDiscount())).append(",");
            sb.append("\"formattedTotalDiscount\":\"").append(escapeJson(dResult.getFormattedTotalDiscount())).append("\",");
            sb.append("\"shippingCode\":\"").append(escapeJson(appliedFreeship)).append("\",");
            sb.append("\"appliedFreeshipCode\":\"").append(escapeJson(appliedFreeship)).append("\",");
            sb.append("\"foodCode\":\"").append(escapeJson(appliedFood)).append("\",");
            sb.append("\"appliedFoodCode\":\"").append(escapeJson(appliedFood)).append("\",");
            sb.append("\"combinedCode\":\"").append(escapeJson(dResult.getCombinedCode())).append("\"");
            sb.append("}");
            resp.getWriter().write(sb.toString());
            return;
        }

        if ("claim-restaurant".equalsIgnoreCase(action)) {
            if (userId <= 0) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để nhận mã ưu đãi từ quán!\"}");
                return;
            }
            if (restaurantId <= 0) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy thông tin quán ăn!\"}");
                return;
            }
            com.ute.fooddelivery.model.Restaurant r = restaurantService.getRestaurantById(restaurantId);
            if (r == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Quán ăn không tồn tại!\"}");
                return;
            }

            com.ute.fooddelivery.model.UserVoucher uv = userVoucherDAO.grantRestaurantVoucherIfEligible(userId, r);
            if (uv != null) {
                resp.getWriter().write(String.format(Locale.US,
                        "{\"success\":true,\"claimed\":true,\"code\":\"%s\",\"title\":\"%s\",\"message\":\"Chúc mừng! Đã lưu mã %s (Giảm 20K tại %s) vào kho voucher của bạn!\"}",
                        escapeJson(uv.getVoucherCode()), escapeJson(uv.getTitle()), escapeJson(uv.getVoucherCode()), escapeJson(r.getName())));
            } else {
                resp.getWriter().write(String.format(Locale.US,
                        "{\"success\":true,\"claimed\":false,\"code\":\"QUAN%d_20K\",\"message\":\"Bạn đã có mã ưu đãi của quán %s trong Kho Voucher rồi!\"}",
                        restaurantId, escapeJson(r.getName())));
            }
            return;
        }

        // Default: validate single code
        String code = req.getParameter("code");
        ValidationResult result = voucherService.validateAndCalculate(code, subtotal, shippingFee, restaurantId, userId);

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"valid\":").append(result.isValid()).append(",");
        sb.append("\"message\":\"").append(escapeJson(result.getMessage())).append("\",");
        sb.append("\"discountAmount\":").append(String.format(Locale.US, "%.0f", result.getDiscountAmount())).append(",");
        sb.append("\"formattedDiscount\":\"").append(escapeJson(result.getFormattedDiscount())).append("\"");

        if (result.getVoucher() != null) {
            Voucher v = result.getVoucher();
            sb.append(",\"code\":\"").append(escapeJson(v.getCode())).append("\"");
            sb.append(",\"title\":\"").append(escapeJson(v.getTitle())).append("\"");
            sb.append(",\"badge\":\"").append(escapeJson(v.getBadge())).append("\"");
            sb.append(",\"isFreeShip\":").append(v.isFreeShip());
        }

        sb.append("}");
        resp.getWriter().write(sb.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
