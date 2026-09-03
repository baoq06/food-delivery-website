package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.CartItem;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.service.FoodService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {
    private final FoodService foodService = new FoodService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/client/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        @SuppressWarnings("unchecked")
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        if ("add".equalsIgnoreCase(action)) {
            int foodId = Integer.parseInt(req.getParameter("foodId"));
            int quantity = Integer.parseInt(req.getParameter("quantity"));

            if (cart.containsKey(foodId)) {
                CartItem item = cart.get(foodId);
                item.setQuantity(item.getQuantity() + quantity);
            } else {
                Food food = foodService.getFoodById(foodId);
                if (food != null) {
                    cart.put(foodId, new CartItem(food, quantity));
                }
            }
        } else if ("remove".equalsIgnoreCase(action)) {
            int foodId = Integer.parseInt(req.getParameter("foodId"));
            cart.remove(foodId);
        }

        session.setAttribute("cart", cart);
        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}
