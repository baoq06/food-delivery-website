package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.*;

import java.util.List;
import java.util.Map;

public class MerchantService {
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final FoodDAO foodDAO = new FoodDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final DriverDAO driverDAO = new DriverDAO();

    // Quản lý Nhà Hàng / Quán Ăn
    public Restaurant getRestaurantForUser(int userId) {
        return restaurantDAO.getRestaurantByUserId(userId);
    }

    public boolean updateRestaurantProfile(Restaurant r) {
        return restaurantDAO.updateRestaurant(r);
    }

    public boolean updateRestaurantStatus(int restaurantId, String status) {
        return restaurantDAO.updateStatus(restaurantId, status);
    }

    // Quản lý Món Ăn
    public List<Food> getFoods(int restaurantId) {
        return foodDAO.getFoodsByRestaurantId(restaurantId);
    }

    public Food getFoodById(int foodId) {
        return foodDAO.getFoodById(foodId);
    }

    public boolean addFood(Food food) {
        return foodDAO.insertFood(food);
    }

    public boolean updateFood(Food food) {
        return foodDAO.updateFood(food);
    }

    public boolean deleteFood(int foodId, int restaurantId) {
        return foodDAO.deleteFood(foodId, restaurantId);
    }

    public boolean toggleFoodAvailability(int foodId, int restaurantId, boolean isAvailable) {
        return foodDAO.toggleAvailability(foodId, restaurantId, isAvailable);
    }

    // Quản lý Đơn Hàng & Tài Xế
    public List<Order> getOrders(int restaurantId, String statusFilter) {
        return orderDAO.getOrdersByRestaurant(restaurantId, statusFilter);
    }

    public boolean updateOrderStatus(int orderId, String status) {
        return orderDAO.updateOrderStatus(orderId, status);
    }

    public boolean assignDriver(int orderId, int driverId) {
        return orderDAO.assignDriver(orderId, driverId);
    }

    public List<Driver> getAllDrivers() {
        return driverDAO.getAllDrivers();
    }

    public List<Driver> getAvailableDrivers() {
        return driverDAO.getAvailableDrivers();
    }

    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    public boolean payDriverFee(int restaurantId, int driverId, Integer orderId, double amount, String paymentMethod, String note) {
        return driverDAO.recordDriverPayment(restaurantId, driverId, orderId, amount, paymentMethod, note);
    }

    public double getTotalPaidToDrivers(int restaurantId) {
        return driverDAO.getTotalPaidToDrivers(restaurantId);
    }

    // Báo Cáo Doanh Thu Theo Ngày / Tháng / Năm
    public List<RevenueStat> getDailyRevenue(int restaurantId, int year, int month) {
        return orderDAO.getDailyRevenue(restaurantId, year, month);
    }

    public List<RevenueStat> getMonthlyRevenue(int restaurantId, int year) {
        return orderDAO.getMonthlyRevenue(restaurantId, year);
    }

    public List<RevenueStat> getYearlyRevenue(int restaurantId) {
        return orderDAO.getYearlyRevenue(restaurantId);
    }

    public List<Order> getRevenueOrders(int restaurantId, String type, int year, Integer month, Integer day) {
        return orderDAO.getRevenueOrders(restaurantId, type, year, month, day);
    }

    public List<TopFoodStat> getTopSellingFoods(int restaurantId, int limit) {
        return orderDAO.getTopSellingFoods(restaurantId, limit);
    }

    public Map<String, Object> getRestaurantKPIs(int restaurantId) {
        return orderDAO.getRestaurantKPIs(restaurantId);
    }
}
