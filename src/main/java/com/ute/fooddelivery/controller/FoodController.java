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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "FoodController", urlPatterns = {"/foods", "/food-detail"})
public class FoodController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();
    private static final int RECENT_COOKIE_AGE = 60 * 60 * 24 * 7; // 7 ngày

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/food-detail".equals(path)) {
            String idParam = req.getParameter("id");
            if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idParam.trim());
                    Food food = foodService.getFoodById(id);
                    req.setAttribute("food", food);

                    if (food != null) {
                        // Cập nhật Cookie danh sách ID món ăn xem gần đây
                        String recentCookie = CookieUtils.getCookieValue(req, "recent_foods");
                        List<Integer> idList = CookieUtils.parseIdList(recentCookie);
                        idList.remove(Integer.valueOf(id)); // Đưa món hiện tại lên đầu
                        idList.add(0, id);
                        if (idList.size() > 6) {
                            idList = idList.subList(0, 6);
                        }
                        CookieUtils.addCookie(resp, "recent_foods", CookieUtils.formatIdList(idList), RECENT_COOKIE_AGE);

                        // Lấy danh sách các món xem gần đây khác để hiển thị gợi ý
                        List<Integer> otherIds = new ArrayList<>(idList);
                        otherIds.remove(Integer.valueOf(id));
                        if (!otherIds.isEmpty()) {
                            List<Food> recentFoods = foodService.getFoodsByIds(otherIds);
                            req.setAttribute("recentFoods", recentFoods);
                        }
                    }
                } catch (NumberFormatException e) {
                    System.err.println("ID món không hợp lệ: " + idParam);
                }
            }
            req.getRequestDispatcher("/WEB-INF/views/client/food-detail.jsp").forward(req, resp);
        } else {
            String catParam = req.getParameter("cat");
            String searchParam = req.getParameter("search");

            List<Food> foods;
            if (catParam != null && !catParam.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(catParam.trim());
                    foods = foodService.getFoodsByCategory(catId);
                } catch (NumberFormatException e) {
                    foods = foodService.getAllFoods();
                }
            } else if (searchParam != null && !searchParam.trim().isEmpty()) {
                foods = foodService.searchFoods(searchParam.trim());
            } else {
                foods = foodService.getAllFoods();
            }

            req.setAttribute("categories", categoryService.getAllCategories());
            req.setAttribute("foods", foods);
            req.getRequestDispatcher("/WEB-INF/views/client/menu.jsp").forward(req, resp);
        }
    }
}
