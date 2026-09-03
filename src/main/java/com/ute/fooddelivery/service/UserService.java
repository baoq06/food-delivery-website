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
}
