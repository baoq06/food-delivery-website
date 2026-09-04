package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "FoodController", urlPatterns = {"/foods", "/food-detail"})
public class FoodController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();

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
