package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@WebServlet(name = "MerchantVoucherController", urlPatterns = {"/merchant/vouchers"})
public class MerchantVoucherController extends HttpServlet {
    private final MerchantService merchantService = new MerchantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        int restaurantId = restaurant.getId();
        List<Voucher> vouchers = merchantService.getRestaurantVouchers(restaurantId);

        // Lọc theo từ khóa tìm kiếm
        String keyword = req.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            String lower = keyword.trim().toLowerCase(Locale.ROOT);
            vouchers = vouchers.stream()
                    .filter(v -> (v.getCode() != null && v.getCode().toLowerCase(Locale.ROOT).contains(lower)) ||
                            (v.getTitle() != null && v.getTitle().toLowerCase(Locale.ROOT).contains(lower)) ||
                            (v.getDescription() != null && v.getDescription().toLowerCase(Locale.ROOT).contains(lower)))
                    .collect(Collectors.toList());
            req.setAttribute("keyword", keyword.trim());
        }

        // Lọc theo trạng thái (ALL, ACTIVE, INACTIVE, EXPIRED)
        String statusFilter = req.getParameter("status");
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
                vouchers = vouchers.stream().filter(v -> v.isActive() && !v.isExpired()).collect(Collectors.toList());
            } else if ("INACTIVE".equalsIgnoreCase(statusFilter)) {
                vouchers = vouchers.stream().filter(v -> !v.isActive()).collect(Collectors.toList());
            } else if ("EXPIRED".equalsIgnoreCase(statusFilter)) {
                vouchers = vouchers.stream().filter(Voucher::isExpired).collect(Collectors.toList());
            }
            req.setAttribute("selectedStatus", statusFilter);
        }

        // Thống kê KPIs Voucher của Quán
        int totalVouchers = merchantService.getRestaurantVouchers(restaurantId).size();
        int activeVouchers = merchantService.getActiveRestaurantVouchers(restaurantId).size();
        int totalUsedCount = (int) merchantService.getVoucherKPIs(restaurantId).getOrDefault("totalUsedCount", 0);

        req.setAttribute("vouchers", vouchers);
        req.setAttribute("totalVouchers", totalVouchers);
        req.setAttribute("activeVouchers", activeVouchers);
        req.setAttribute("totalUsedCount", totalUsedCount);

        req.getRequestDispatcher("/WEB-INF/views/merchant/vouchers.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        int restaurantId = restaurant.getId();
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        try {
            if ("add".equalsIgnoreCase(action)) {
                String code = req.getParameter("code");
                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String discountTypeStr = req.getParameter("discountType");
                String discountValStr = req.getParameter("discountValue");
                String minOrderStr = req.getParameter("minOrderAmount");
                String maxDiscountStr = req.getParameter("maxDiscount");
                String usageLimitStr = req.getParameter("usageLimit");
                String perUserLimitStr = req.getParameter("perUserLimit");
                String startDate = req.getParameter("startDate");
                String endDate = req.getParameter("endDate");
                String badge = req.getParameter("badge");
                boolean isActive = "on".equalsIgnoreCase(req.getParameter("isActive")) || "true".equalsIgnoreCase(req.getParameter("isActive"));

                if (code == null || code.trim().isEmpty()) {
                    session.setAttribute("flashError", "Mã voucher không được để trống!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                String cleanCode = code.trim().toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9_-]", "");
                if (cleanCode.length() < 3) {
                    session.setAttribute("flashError", "Mã voucher phải có ít nhất 3 ký tự (chữ cái, số, gạch nối)!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                if (merchantService.isVoucherCodeExists(cleanCode, null)) {
                    session.setAttribute("flashError", "Mã voucher '" + cleanCode + "' đã tồn tại trên hệ thống! Vui lòng chọn mã khác.");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                if (title == null || title.trim().isEmpty()) {
                    session.setAttribute("flashError", "Vui lòng nhập tiêu đề khuyến mãi cho voucher!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                Voucher.DiscountType type = "PERCENT".equalsIgnoreCase(discountTypeStr) ? Voucher.DiscountType.PERCENT : Voucher.DiscountType.FIXED;
                double discountValue = parseDoubleSafe(discountValStr, 0);
                if (discountValue <= 0) {
                    session.setAttribute("flashError", "Mức giảm giá phải lớn hơn 0!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }
                if (type == Voucher.DiscountType.PERCENT && discountValue > 100) {
                    session.setAttribute("flashError", "Mức giảm theo phần trăm không được vượt quá 100%!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                double minOrder = parseDoubleSafe(minOrderStr, 0);
                double maxDiscount = parseDoubleSafe(maxDiscountStr, 0);
                int usageLimit = parseIntSafe(usageLimitStr, 0);
                int perUserLimit = Math.max(1, parseIntSafe(perUserLimitStr, 1));

                // Validate ngày hiệu lực
                if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                    try {
                        LocalDate start = LocalDate.parse(startDate.trim());
                        LocalDate end = LocalDate.parse(endDate.trim());
                        if (end.isBefore(start)) {
                            session.setAttribute("flashError", "Ngày kết thúc không được nhỏ hơn ngày bắt đầu!");
                            resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                            return;
                        }
                    } catch (Exception ignored) {}
                }

                Voucher v = new Voucher();
                v.setRestaurantId(restaurantId);
                v.setCode(cleanCode);
                v.setTitle(title.trim());
                v.setDescription(description != null ? description.trim() : "");
                v.setDiscountType(type);
                v.setDiscountValue(discountValue);
                v.setMinOrderAmount(minOrder);
                v.setMaxDiscount(maxDiscount);
                v.setFreeShip(false);
                v.setUsageLimit(usageLimit);
                v.setUsedCount(0);
                v.setPerUserLimit(perUserLimit);
                v.setStartDate(startDate != null && !startDate.trim().isEmpty() ? startDate.trim() : null);
                v.setEndDate(endDate != null && !endDate.trim().isEmpty() ? endDate.trim() : null);
                v.setActive(isActive);
                v.setBadge(badge != null && !badge.trim().isEmpty() ? badge.trim() : "🔥 ƯU ĐÃI QUÁN");

                boolean ok = merchantService.addVoucher(v);
                if (ok) {
                    session.setAttribute("flashMessage", "Tạo voucher '" + cleanCode + "' thành công! Khách hàng sẽ thấy voucher này ở đầu trang quán.");
                } else {
                    session.setAttribute("flashError", "Lỗi khi lưu voucher vào cơ sở dữ liệu!");
                }
                resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                return;

            } else if ("edit".equalsIgnoreCase(action)) {
                int id = parseIntSafe(req.getParameter("id"), 0);
                if (id <= 0) {
                    session.setAttribute("flashError", "Không tìm thấy ID voucher cần sửa!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                String code = req.getParameter("code");
                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String discountTypeStr = req.getParameter("discountType");
                String discountValStr = req.getParameter("discountValue");
                String minOrderStr = req.getParameter("minOrderAmount");
                String maxDiscountStr = req.getParameter("maxDiscount");
                String usageLimitStr = req.getParameter("usageLimit");
                String perUserLimitStr = req.getParameter("perUserLimit");
                String startDate = req.getParameter("startDate");
                String endDate = req.getParameter("endDate");
                String badge = req.getParameter("badge");
                boolean isActive = "on".equalsIgnoreCase(req.getParameter("isActive")) || "true".equalsIgnoreCase(req.getParameter("isActive"));

                String cleanCode = code != null ? code.trim().toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9_-]", "") : "";
                if (cleanCode.length() < 3) {
                    session.setAttribute("flashError", "Mã voucher phải có ít nhất 3 ký tự!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                if (merchantService.isVoucherCodeExists(cleanCode, id)) {
                    session.setAttribute("flashError", "Mã voucher '" + cleanCode + "' đã được sử dụng bởi voucher khác!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                Voucher.DiscountType type = "PERCENT".equalsIgnoreCase(discountTypeStr) ? Voucher.DiscountType.PERCENT : Voucher.DiscountType.FIXED;
                double discountValue = parseDoubleSafe(discountValStr, 0);
                if (discountValue <= 0) {
                    session.setAttribute("flashError", "Mức giảm giá phải lớn hơn 0!");
                    resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                    return;
                }

                double minOrder = parseDoubleSafe(minOrderStr, 0);
                double maxDiscount = parseDoubleSafe(maxDiscountStr, 0);
                int usageLimit = parseIntSafe(usageLimitStr, 0);
                int perUserLimit = Math.max(1, parseIntSafe(perUserLimitStr, 1));

                Voucher v = new Voucher();
                v.setId(id);
                v.setRestaurantId(restaurantId);
                v.setCode(cleanCode);
                v.setTitle(title != null ? title.trim() : "");
                v.setDescription(description != null ? description.trim() : "");
                v.setDiscountType(type);
                v.setDiscountValue(discountValue);
                v.setMinOrderAmount(minOrder);
                v.setMaxDiscount(maxDiscount);
                v.setFreeShip(false);
                v.setUsageLimit(usageLimit);
                v.setPerUserLimit(perUserLimit);
                v.setStartDate(startDate != null && !startDate.trim().isEmpty() ? startDate.trim() : null);
                v.setEndDate(endDate != null && !endDate.trim().isEmpty() ? endDate.trim() : null);
                v.setActive(isActive);
                v.setBadge(badge != null && !badge.trim().isEmpty() ? badge.trim() : "🔥 ƯU ĐÃI QUÁN");

                boolean ok = merchantService.updateVoucher(v);
                if (ok) {
                    session.setAttribute("flashMessage", "Cập nhật voucher '" + cleanCode + "' thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể cập nhật thông tin voucher!");
                }
                resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                return;

            } else if ("toggle".equalsIgnoreCase(action)) {
                int id = parseIntSafe(req.getParameter("id"), 0);
                if (id > 0) {
                    boolean ok = merchantService.toggleVoucherStatus(id, restaurantId);
                    if (ok) {
                        session.setAttribute("flashMessage", "Đã thay đổi trạng thái kích hoạt của voucher!");
                    } else {
                        session.setAttribute("flashError", "Lỗi khi thay đổi trạng thái voucher!");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                return;

            } else if ("delete".equalsIgnoreCase(action)) {
                int id = parseIntSafe(req.getParameter("id"), 0);
                if (id > 0) {
                    boolean ok = merchantService.deleteVoucher(id, restaurantId);
                    if (ok) {
                        session.setAttribute("flashMessage", "Đã xóa voucher khuyến mãi thành công!");
                    } else {
                        session.setAttribute("flashError", "Không thể xóa voucher!");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
                return;
            }

        } catch (Exception e) {
            session.setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/vouchers");
    }

    private double parseDoubleSafe(String val, double defaultVal) {
        if (val == null || val.trim().isEmpty()) return defaultVal;
        try {
            return Double.parseDouble(val.trim().replace(",", "").replace(".", ""));
        } catch (Exception e) {
            try {
                return Double.parseDouble(val.trim());
            } catch (Exception ignored) {
                return defaultVal;
            }
        }
    }

    private int parseIntSafe(String val, int defaultVal) {
        if (val == null || val.trim().isEmpty()) return defaultVal;
        try {
            return Integer.parseInt(val.trim().replace(",", "").replace(".", ""));
        } catch (Exception e) {
            return defaultVal;
        }
    }
}
