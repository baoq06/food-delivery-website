package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import java.util.List;

public class OrderService {
    private final OrderDAO orderDAO = new OrderDAO();

    public int createOrder(Order order, List<OrderItem> items) {
        return orderDAO.createOrder(order, items);
    }

    public List<Order> getOrdersByUserId(int userId) {
        return orderDAO.getOrdersByUserId(userId);
    }

    public boolean cancelOrderByCustomer(int orderId, int userId) {
        return orderDAO.cancelOrderByCustomer(orderId, userId);
    }

    public boolean confirmCustomerOrder(int orderId, int userId) {
        return orderDAO.confirmCustomerOrder(orderId, userId);
    }

    public boolean confirmMerchantOrder(int orderId) {
        return orderDAO.confirmMerchantOrder(orderId);
    }
}

