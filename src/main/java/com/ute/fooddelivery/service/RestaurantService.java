package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Restaurant;
import java.util.List;

public class RestaurantService {
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    public List<Restaurant> getAllRestaurants() {
        return restaurantDAO.getAllRestaurants();
    }

    public Restaurant getRestaurantById(int id) {
        return restaurantDAO.getRestaurantById(id);
    }

    public List<Restaurant> getTopRatedRestaurants(int limit) {
        return restaurantDAO.getTopRatedRestaurants(limit);
    }

    public List<Restaurant> getBestSellingRestaurants(int limit) {
        return restaurantDAO.getBestSellingRestaurants(limit);
    }
}
