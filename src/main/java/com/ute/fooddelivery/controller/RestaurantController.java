package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.RestaurantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RestaurantController", urlPatterns = {"/restaurant-detail", "/restaurant"})
public class RestaurantController extends HttpServlet {
    private final RestaurantService restaurantService = new RestaurantService();
    private final FoodDAO foodDAO = new FoodDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Restaurant restaurant = restaurantService.getRestaurantById(id);
                if (restaurant != null) {
                    List<Food> foods = foodDAO.getFoodsByRestaurantId(id);
                    req.setAttribute("restaurant", restaurant);
                    req.setAttribute("foods", foods);
                    req.getRequestDispatcher("/WEB-INF/views/client/restaurant-detail.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
