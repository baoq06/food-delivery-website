package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.utils.GeoLocationUtils;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FoodService {
    private final FoodDAO foodDAO = new FoodDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

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

    public List<Food> getBestSellingFoods(int limit) {
        return foodDAO.getBestSellingFoods(limit);
    }

    public List<Food> getTopRatedFoods(int limit) {
        return foodDAO.getTopRatedFoods(limit);
    }

    public List<Food> getFoodsByIds(List<Integer> ids) {
        List<Food> list = new ArrayList<>();
        if (ids == null || ids.isEmpty()) return list;
        for (Integer id : ids) {
            Food f = foodDAO.getFoodById(id);
            if (f != null) {
                list.add(f);
            }
        }
        return list;
    }

    public List<Food> getFoodsByRestaurant(int restaurantId, int excludeFoodId, int limit) {
        return foodDAO.getFoodsByRestaurant(restaurantId, excludeFoodId, limit);
    }

    public List<Food> getSimilarFoodsByCategory(int categoryId, int excludeFoodId, int limit) {
        return foodDAO.getSimilarFoodsByCategory(categoryId, excludeFoodId, limit);
    }

    public List<Food> getPopularSideDishes(int limit) {
        return foodDAO.getPopularSideDishes(limit);
    }

    public List<Food> getCombosByRestaurant(int restaurantId) {
        return foodDAO.getCombosByRestaurantId(restaurantId);
    }

    public List<Food> getAllCombos() {
        return foodDAO.getAllCombos();
    }

    public List<Food> getRecommendedFoodsForUser(int userId, int limit) {
        return foodDAO.getRecommendedFoodsForUser(userId, limit);
    }

    public List<Food> getRecommendedFoodsByRecentIds(List<Integer> foodIds, int limit) {
        return foodDAO.getRecommendedFoodsByRecentIds(foodIds, limit);
    }

    /**
     * Lấy danh sách món ăn cho mục 'Gần đây':
     * - Sử dụng API bên ngoài (OSRM Routing Table API) tính khoảng cách giữa địa chỉ người dùng và địa chỉ quán.
     * - Quán nào càng gần thì càng xuất hiện đầu.
     * - Trong cùng 1 quán thì món nào có nhiều người mua hơn thì xuất hiện trước.
     */
    public List<Food> getNearbyFoods(double userLat, double userLng, int limit) {
        List<Restaurant> restaurants = restaurantDAO.getAllRestaurants();
        if (restaurants == null || restaurants.isEmpty()) {
            return getBestSellingFoods(limit);
        }

        List<double[]> destCoords = new ArrayList<>();
        for (Restaurant r : restaurants) {
            destCoords.add(new double[]{r.getLatitude(), r.getLongitude()});
        }

        List<Double> distances = GeoLocationUtils.calculateDistancesFromOrigin(userLat, userLng, destCoords);
        Map<Integer, Double> restDistMap = new HashMap<>();
        for (int i = 0; i < restaurants.size(); i++) {
            Restaurant r = restaurants.get(i);
            double d = (i < distances.size()) ? distances.get(i) : 2.0;
            r.setDistanceKm(d);
            restDistMap.put(r.getId(), d);
        }

        List<Food> allFoods = foodDAO.getAllFoods();
        if (allFoods == null || allFoods.isEmpty()) {
            return new ArrayList<>();
        }

        for (Food f : allFoods) {
            Double d = restDistMap.get(f.getRestaurantId());
            f.setDistanceKm(d != null ? d : 999.0);
        }

        // Sắp xếp:
        // 1. Quán nào càng gần thì càng xuất hiện đầu (f1.distance vs f2.distance)
        // 2. Trong cùng 1 quán thì món nào có nhiều người mua hơn thì xuất hiện trước (totalSold DESC)
        // 3. Dự phòng nếu bằng nhau: rating DESC, sau đó food_id ASC
        allFoods.sort((f1, f2) -> {
            double d1 = f1.getDistanceKm() != null ? f1.getDistanceKm() : 999.0;
            double d2 = f2.getDistanceKm() != null ? f2.getDistanceKm() : 999.0;
            int rCmp = Double.compare(d1, d2);
            if (rCmp != 0) {
                return rCmp;
            }
            int soldCmp = Integer.compare(f2.getTotalSold(), f1.getTotalSold());
            if (soldCmp != 0) {
                return soldCmp;
            }
            int rateCmp = Double.compare(f2.getRating(), f1.getRating());
            if (rateCmp != 0) {
                return rateCmp;
            }
            return Integer.compare(f1.getId(), f2.getId());
        });

        if (limit > 0 && allFoods.size() > limit) {
            return new ArrayList<>(allFoods.subList(0, limit));
        }
        return allFoods;
    }
}
