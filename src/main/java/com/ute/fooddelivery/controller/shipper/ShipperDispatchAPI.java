package com.ute.fooddelivery.controller.shipper;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/shipper/api/dispatch")
public class ShipperDispatchAPI extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.setStatus(401);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Order pendingOrder = orderDAO.getPendingDispatchOrder();
        if (pendingOrder != null) {
            String json = String.format(
                "{\"status\":\"found\", \"orderId\":%d, \"customer\":\"%s\", \"address\":\"%s\", \"amount\":%.0f}",
                pendingOrder.getId(), 
                pendingOrder.getCustomerName() != null ? pendingOrder.getCustomerName().replace("\"", "\\\"") : "", 
                pendingOrder.getAddress() != null ? pendingOrder.getAddress().replace("\"", "\\\"") : "", 
                pendingOrder.getTotalAmount()
            );
            resp.getWriter().write(json);
        } else {
            resp.getWriter().write("{\"status\":\"none\"}");
        }
    }
}
