package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.service.FoodService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "FoodController", urlPatterns = {"/foods", "/food-detail"})
public class FoodController extends HttpServlet {
    private final FoodService foodService = new FoodService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/food-detail".equals(path)) {
            String idParam = req.getParameter("id");
            if (idParam != null) {
                int id = Integer.parseInt(idParam);
                Food food = foodService.getFoodById(id);
                req.setAttribute("food", food);
            }
            req.getRequestDispatcher("/WEB-INF/views/client/food-detail.jsp").forward(req, resp);
        } else {
            req.setAttribute("foods", foodService.getAllFoods());
            req.getRequestDispatcher("/WEB-INF/views/client/menu.jsp").forward(req, resp);
        }
    }
}
