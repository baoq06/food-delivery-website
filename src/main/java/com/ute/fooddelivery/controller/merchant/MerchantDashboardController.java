package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.TopFoodStat;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MerchantDashboardController", urlPatterns = {"/merchant/dashboard"})
public class MerchantDashboardController extends HttpServlet {
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

        // 1. Thống kê KPIs
        Map<String, Object> kpis = merchantService.getRestaurantKPIs(restaurantId);
        req.setAttribute("kpis", kpis);

        // 2. Danh sách đơn hàng gần đây (5 đơn mới nhất)
        List<Order> recentOrders = merchantService.getOrders(restaurantId, "ALL");
        if (recentOrders.size() > 5) {
            recentOrders = recentOrders.subList(0, 5);
        }
        req.setAttribute("recentOrders", recentOrders);

        // 3. Top 4 món bán chạy nhất của quán
        List<TopFoodStat> topFoods = merchantService.getTopSellingFoods(restaurantId, 4);
        req.setAttribute("topFoods", topFoods);

        // 4. Số lượng tài xế khả dụng đang trực tuyến
        int availableShippers = merchantService.getAvailableDrivers().size();
        req.setAttribute("availableShipperCount", availableShippers);

        req.getRequestDispatcher("/WEB-INF/views/merchant/dashboard.jsp").forward(req, resp);
    }
}
