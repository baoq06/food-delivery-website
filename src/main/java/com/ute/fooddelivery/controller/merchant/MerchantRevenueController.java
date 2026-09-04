package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.RevenueStat;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "MerchantRevenueController", urlPatterns = {"/merchant/revenue"})
public class MerchantRevenueController extends HttpServlet {
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
        LocalDate now = LocalDate.now();

        // 1. Đọc các tham số lọc: view (DAY, MONTH, YEAR), year, month
        String view = req.getParameter("view");
        if (view == null || (!"DAY".equalsIgnoreCase(view) && !"MONTH".equalsIgnoreCase(view) && !"YEAR".equalsIgnoreCase(view))) {
            view = "DAY";
        }
        view = view.toUpperCase();

        int year = now.getYear();
        try {
            String yParam = req.getParameter("year");
            if (yParam != null && !yParam.trim().isEmpty()) {
                year = Integer.parseInt(yParam.trim());
            }
        } catch (Exception ignored) {}

        int month = now.getMonthValue();
        try {
            String mParam = req.getParameter("month");
            if (mParam != null && !mParam.trim().isEmpty()) {
                month = Integer.parseInt(mParam.trim());
            }
        } catch (Exception ignored) {}

        Integer day = null;
        try {
            String dParam = req.getParameter("day");
            if (dParam != null && !dParam.trim().isEmpty()) {
                day = Integer.parseInt(dParam.trim());
            }
        } catch (Exception ignored) {}

        // 2. Truy vấn thống kê từ CSDL theo chế độ xem
        List<RevenueStat> stats;
        if ("MONTH".equalsIgnoreCase(view)) {
            stats = merchantService.getMonthlyRevenue(restaurantId, year);
        } else if ("YEAR".equalsIgnoreCase(view)) {
            stats = merchantService.getYearlyRevenue(restaurantId);
        } else {
            // DAY (theo từng ngày trong tháng được chọn)
            stats = merchantService.getDailyRevenue(restaurantId, year, month);
        }

        // 3. Tính toán các chỉ số tổng hợp thực tế
        double totalRevenue = 0;
        int totalOrders = 0;
        int totalItems = 0;
        double maxRevenue = 0;

        for (RevenueStat s : stats) {
            totalRevenue += s.getRevenue();
            totalOrders += s.getOrderCount();
            totalItems += s.getItemCount();
            if (s.getRevenue() > maxRevenue) {
                maxRevenue = s.getRevenue();
            }
        }

        double avgOrderValue = totalOrders > 0 ? (totalRevenue / totalOrders) : 0;

        // 4. Lấy danh sách các đơn hàng chi tiết đóng góp vào doanh thu này
        List<Order> detailedOrders = merchantService.getRevenueOrders(restaurantId, view, year, month, day);

        // 5. Gán dữ liệu sang request để JSP hiển thị
        req.setAttribute("selectedView", view);
        req.setAttribute("selectedYear", year);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("selectedDay", day);
        req.setAttribute("stats", stats);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("avgOrderValue", avgOrderValue);
        req.setAttribute("maxRevenue", maxRevenue);
        req.setAttribute("detailedOrders", detailedOrders);

        req.getRequestDispatcher("/WEB-INF/views/merchant/revenue.jsp").forward(req, resp);
    }
}
