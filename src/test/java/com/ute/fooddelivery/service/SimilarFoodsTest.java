package com.ute.fooddelivery.service;

import com.ute.fooddelivery.model.Food;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class SimilarFoodsTest {

    @Test
    public void testGetSimilarFoodsByCategory() {
        FoodService foodService = new FoodService();
        List<Food> allFoods = foodService.getAllFoods();
        assertNotNull("Danh sách món không được null", allFoods);
        
        if (!allFoods.isEmpty()) {
            Food firstFood = allFoods.get(0);
            int catId = firstFood.getCategoryId();
            int foodId = firstFood.getId();
            
            List<Food> similarFoods = foodService.getSimilarFoodsByCategory(catId, foodId, 4);
            assertNotNull("Danh sách món tương tự không được null", similarFoods);
            assertTrue("Số lượng không vượt quá limit 4", similarFoods.size() <= 4);
            
            for (Food sFood : similarFoods) {
                assertNotEquals("Không được chứa món ăn hiện tại", foodId, sFood.getId());
                assertEquals("Phải cùng category_id", catId, sFood.getCategoryId());
            }
        }
    }
}
