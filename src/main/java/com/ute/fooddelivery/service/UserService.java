package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.User;

public class UserService {
    private final UserDAO userDAO = new UserDAO();

    public User login(String username, String password) {
        return userDAO.login(username, password);
    }

    public boolean register(User user) {
        return userDAO.register(user);
    }

    public boolean registerSeller(User user, String restaurantName, String restaurantAddress) {
        return userDAO.registerSeller(user, restaurantName, restaurantAddress);
    }

    public boolean registerShipper(User user) {
        return userDAO.registerShipper(user);
    }
}
