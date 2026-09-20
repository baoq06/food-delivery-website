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

        DecimalFormat df = new DecimalFormat("#,###");

        if ("list".equalsIgnoreCase(action)) {
            List<Voucher> vouchers = voucherService.getAllVouchers();
            StringBuilder sb = new StringBuilder();
            sb.append("{\"success\":true,\"vouchers\":[");
            for (int i = 0; i < vouchers.size(); i++) {
                Voucher v = vouchers.get(i);
                boolean eligible = v.isEligible(subtotal);
                double missing = v.getMissingAmount(subtotal);

                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"code\":\"").append(escapeJson(v.getCode())).append("\",");
                sb.append("\"title\":\"").append(escapeJson(v.getTitle())).append("\",");
                sb.append("\"description\":\"").append(escapeJson(v.getDescription())).append("\",");
                sb.append("\"badge\":\"").append(escapeJson(v.getBadge())).append("\",");
                sb.append("\"minOrder\":").append(String.format(Locale.US, "%.0f", v.getMinOrderAmount())).append(",");
                sb.append("\"formattedMinOrder\":\"").append(df.format(v.getMinOrderAmount())).append(" đ\",");
                sb.append("\"eligible\":").append(eligible).append(",");
                sb.append("\"missingAmount\":").append(String.format(Locale.US, "%.0f", missing)).append(",");
                sb.append("\"formattedMissing\":\"").append(df.format(missing)).append(" đ\"");
                sb.append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
            return;
        }

        // Default: validate
        String code = req.getParameter("code");
        ValidationResult result = voucherService.validateAndCalculate(code, subtotal, shippingFee);

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
