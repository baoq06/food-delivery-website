package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.service.FoodService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "HomeController", urlPatterns = {"", "/home"})
public class HomeController extends HttpServlet {
    private final FoodService foodService = new FoodService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("featuredFoods", foodService.getAllFoods());
        req.getRequestDispatcher("/WEB-INF/views/client/home.jsp").forward(req, resp);
    }
}
