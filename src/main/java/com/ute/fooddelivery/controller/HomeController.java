package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.utils.CookieUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeController", urlPatterns = {"", "/home"})
public class HomeController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("categories", categoryService.getAllCategories());
        req.setAttribute("featuredFoods", foodService.getFeaturedFoods(8));

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
