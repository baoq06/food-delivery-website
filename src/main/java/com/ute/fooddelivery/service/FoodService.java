package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.model.Food;
import java.util.List;

public class FoodService {
    private final FoodDAO foodDAO = new FoodDAO();

    public List<Food> getAllFoods() {
        return foodDAO.getAllFoods();
    }

    public List<Food> getFoodsByCategory(int categoryId) {
        return foodDAO.getFoodsByCategory(categoryId);
    }

    public List<Food> searchFoods(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllFoods();
        }
        return foodDAO.searchFoods(keyword.trim());
    }

    public Food getFoodById(int id) {
        return foodDAO.getFoodById(id);
    }

    public List<Food> getFeaturedFoods(int limit) {
        return foodDAO.getFeaturedFoods(limit);
    }
}
