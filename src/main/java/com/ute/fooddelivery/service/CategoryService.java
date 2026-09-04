package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.CategoryDAO;
import com.ute.fooddelivery.model.Category;
import java.util.List;

public class CategoryService {
    private final CategoryDAO categoryDAO = new CategoryDAO();

    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    public Category getCategoryById(int id) {
        return categoryDAO.getCategoryById(id);
    }
}
