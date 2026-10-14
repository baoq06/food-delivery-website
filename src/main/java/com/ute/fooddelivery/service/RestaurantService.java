package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.utils.GeoLocationUtils;
import java.util.ArrayList;
import java.util.Comparator;
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

    /**
     * Lấy danh sách quán ăn sắp xếp theo khoảng cách từ địa chỉ người dùng (gần nhất đứng đầu)
     * Tính toán khoảng cách qua OSRM Routing API với Haversine fallback.
     */
    public List<Restaurant> getNearbyRestaurants(double userLat, double userLng, int limit) {
        List<Restaurant> all = restaurantDAO.getAllRestaurants();
        if (all == null || all.isEmpty()) return new ArrayList<>();

        List<double[]> destCoords = new ArrayList<>();
        for (Restaurant r : all) {
            destCoords.add(new double[]{r.getLatitude(), r.getLongitude()});
        }

        List<Double> distances = GeoLocationUtils.calculateDistancesFromOrigin(userLat, userLng, destCoords);
        for (int i = 0; i < all.size(); i++) {
            double d = (i < distances.size()) ? distances.get(i) : 2.0;
            all.get(i).setDistanceKm(d);
        }

        all.sort(Comparator.comparingDouble(r -> r.getDistanceKm() != null ? r.getDistanceKm() : 999.0));

        if (limit > 0 && all.size() > limit) {
            return new ArrayList<>(all.subList(0, limit));
        }
        return all;
    }
}
