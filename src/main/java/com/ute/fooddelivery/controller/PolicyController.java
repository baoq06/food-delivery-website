package com.ute.fooddelivery.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "PolicyController", urlPatterns = {"/policy", "/policies", "/chinh-sach"})
public class PolicyController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tab = req.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = req.getParameter("type");
        }
        if (tab == null || tab.trim().isEmpty()) {
            tab = "delivery";
        }

        // Validate allowed tabs
        tab = tab.toLowerCase().trim();
        if (!tab.equals("delivery") && !tab.equals("food-quality") && !tab.equals("payment-refund") 
            && !tab.equals("privacy") && !tab.equals("guide")) {
            tab = "delivery";
        }

        req.setAttribute("activeTab", tab);
        req.getRequestDispatcher("/WEB-INF/views/common/policy.jsp").forward(req, resp);
    }
}
