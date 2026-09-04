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
}
