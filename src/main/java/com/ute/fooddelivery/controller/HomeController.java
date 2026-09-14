package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.service.RestaurantService;
import com.ute.fooddelivery.utils.CookieUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeController", urlPatterns = {"", "/home", "/nearby"})
public class HomeController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();
    private final RestaurantService restaurantService = new RestaurantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String servletPath = req.getServletPath();
        String tab = req.getParameter("tab");

        // Khi bấm vào tab 'Gần tôi' (chưa có API vị trí) -> hiển thị trang 404 theo yêu cầu
        if ("/nearby".equals(servletPath) || "nearby".equalsIgnoreCase(tab)) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
            return;
        }

        if (tab == null || tab.trim().isEmpty()) {
            tab = "bestseller";
        }

        List<Food> tabFoods;
        List<Restaurant> tabRestaurants;

        if ("toprated".equalsIgnoreCase(tab)) {
            // Tab 'Đánh giá': Lấy các món ăn và quán ăn có rating cao nhất từ dữ liệu thật
            tabFoods = foodService.getTopRatedFoods(8);
            tabRestaurants = restaurantService.getTopRatedRestaurants(4);
        } else {
            // Tab 'Bán chạy' (mặc định): Lấy các món ăn và quán ăn bán chạy nhất từ dữ liệu thật
            tab = "bestseller";
            tabFoods = foodService.getBestSellingFoods(8);
            tabRestaurants = restaurantService.getBestSellingRestaurants(4);
        }

        req.setAttribute("activeTab", tab);
        req.setAttribute("tabFoods", tabFoods);
        req.setAttribute("tabRestaurants", tabRestaurants);
        req.setAttribute("featuredFoods", tabFoods);
        req.setAttribute("categories", categoryService.getAllCategories());

        // Dọn dẹp cookie dùng chung cũ nếu còn sót
        CookieUtils.cleanLegacyRecentFoods(req, resp);

        // Lấy danh sách món vừa xem gần đây theo từng tài khoản (hoặc khách vãng lai riêng)
        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
        String recentCookie = CookieUtils.getCookieValue(req, cookieName);
        List<Integer> idList = CookieUtils.parseIdList(recentCookie);
        if (!idList.isEmpty()) {
            List<Food> recentFoods = foodService.getFoodsByIds(idList);
            req.setAttribute("recentFoods", recentFoods);
        }

        req.getRequestDispatcher("/WEB-INF/views/client/home.jsp").forward(req, resp);
    }
}
