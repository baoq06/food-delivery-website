package com.ute.fooddelivery.service;

import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

public class ProfileTest {
    private UserService userService;
    private OrderService orderService;

    @Before
    public void setUp() {
        userService = new UserService();
        orderService = new OrderService();
    }

    @Test
    public void testGetUserByIdFallback() {
        User customer = userService.getUserById(2);
        Assert.assertNotNull("Customer with ID 2 should not be null", customer);
        Assert.assertEquals("customer", customer.getUsername());
        Assert.assertTrue("Should have CUSTOMER role", customer.isCustomer());
    }

    @Test
    public void testCustomerOrders() {
        List<Order> orders = orderService.getOrdersByUserId(2);
        Assert.assertNotNull("Orders list should not be null", orders);
    }
}
