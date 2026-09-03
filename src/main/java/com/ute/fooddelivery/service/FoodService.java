package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.model.Food;
import java.util.List;

public class FoodService {
    private final FoodDAO foodDAO = new FoodDAO();

    public List<Food> getAllFoods() {
        return foodDAO.getAllFoods();
    }

    public Food getFoodById(int id) {
        return foodDAO.getFoodById(id);
    }
}
