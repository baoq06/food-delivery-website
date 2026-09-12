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

    public User getUserById(int id) {
        return userDAO.getUserById(id);
    }

    public boolean updateProfile(int userId, String fullName, String phone, String address, String email) {
        return userDAO.updateProfile(userId, fullName, phone, address, email);
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        return userDAO.changePassword(userId, oldPassword, newPassword);
    }

    public boolean registerShipper(User user) {
        return userDAO.registerShipper(user);
    }

    public boolean registerShipper(User user, String licensePlate, String vehicleType) {
        return userDAO.registerShipper(user, licensePlate, vehicleType);
    }
}

