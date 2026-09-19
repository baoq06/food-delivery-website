package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.utils.GeoLocationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.DecimalFormat;

@WebServlet("/api/shipping-fee")
public class ShippingFeeAPI extends HttpServlet {
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            String restIdParam = req.getParameter("restaurantId");
            int restaurantId = 1;
            if (restIdParam != null && !restIdParam.trim().isEmpty()) {
                try {
                    restaurantId = Integer.parseInt(restIdParam.trim());
                } catch (Exception ignored) {}
            }

            Restaurant restaurant = restaurantDAO.getRestaurantById(restaurantId);
            double restLat = restaurant != null ? restaurant.getLatitude() : GeoLocationUtils.DEFAULT_LAT;
            double restLng = restaurant != null ? restaurant.getLongitude() : GeoLocationUtils.DEFAULT_LNG;

            String address = req.getParameter("address");
            String latParam = req.getParameter("lat");
            String lngParam = req.getParameter("lng");

            double custLat;
            double custLng;

            if (latParam != null && lngParam != null && !latParam.trim().isEmpty() && !lngParam.trim().isEmpty()) {
                custLat = Double.parseDouble(latParam.trim());
                custLng = Double.parseDouble(lngParam.trim());
            } else {
                double[] coords = GeoLocationUtils.getCoordinatesForAddress(address);
                custLat = coords[0];
                custLng = coords[1];
            }

            double distanceKm = GeoLocationUtils.calculateRouteDistance(restLat, restLng, custLat, custLng);
            double shippingFee = GeoLocationUtils.calculateShippingFee(distanceKm);
            int estimatedMinutes = GeoLocationUtils.estimateDeliveryMinutes(distanceKm);

            DecimalFormat df = new DecimalFormat("#,###");
            String formattedFee = df.format(shippingFee) + " đ";

            String json = String.format(java.util.Locale.US,
                "{\"status\":\"success\", \"distanceKm\":%.1f, \"shippingFee\":%.0f, \"formattedFee\":\"%s\", \"estimatedMinutes\":%d}",
                distanceKm, shippingFee, formattedFee, estimatedMinutes
            );
            resp.getWriter().write(json);
        } catch (Exception e) {
            resp.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
