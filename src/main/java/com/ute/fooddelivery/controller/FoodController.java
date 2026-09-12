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
        com.ute.fooddelivery.model.User currentUser = (req.getSession(false) != null) ?
                (com.ute.fooddelivery.model.User) req.getSession(false).getAttribute("currentUser") : null;
        if (currentUser != null && currentUser.isSeller()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/error/404.jsp").forward(req, resp);
            return;
        }

        String path = req.getServletPath();

        if ("/food-detail".equals(path)) {
            String idParam = req.getParameter("id");
            if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idParam.trim());
                    Food food = foodService.getFoodById(id);
                    req.setAttribute("food", food);

                    if (food != null) {
                        // Dọn dẹp cookie dùng chung cũ nếu còn sót
                        CookieUtils.cleanLegacyRecentFoods(req, resp);

                        // Cập nhật Cookie danh sách ID món ăn xem gần đây theo từng tài khoản riêng biệt
                        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
                        String recentCookie = CookieUtils.getCookieValue(req, cookieName);
                        List<Integer> idList = CookieUtils.parseIdList(recentCookie);
                        idList.remove(Integer.valueOf(id)); // Đưa món hiện tại lên đầu
                        idList.add(0, id);
                        if (idList.size() > 6) {
                            idList = idList.subList(0, 6);
                        }
                        CookieUtils.addCookie(resp, cookieName, CookieUtils.formatIdList(idList), RECENT_COOKIE_AGE);

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

            List<Food> allFoods = foodService.getAllFoods();
            req.setAttribute("categories", categoryService.getAllCategories());
            req.setAttribute("allFoods", allFoods);
            req.setAttribute("foods", (foods != null && !foods.isEmpty()) ? foods : allFoods);
            req.getRequestDispatcher("/WEB-INF/views/client/menu.jsp").forward(req, resp);
        }
    }
}
