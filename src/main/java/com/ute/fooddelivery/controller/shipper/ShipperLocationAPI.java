package com.ute.fooddelivery.controller.shipper;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/shipper/api/location")
public class ShipperLocationAPI extends HttpServlet {
    private final DriverDAO driverDAO = new DriverDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.setStatus(401);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Driver driver = driverDAO.getDriverByUserId(user.getId());
        if (driver != null) {
            String json = String.format(java.util.Locale.US,
                "{\"status\":\"success\", \"driverId\":%d, \"name\":\"%s\", \"lat\":%.6f, \"lng\":%.6f, \"address\":\"%s\", \"driverStatus\":\"%s\"}",
                driver.getId(),
                driver.getName() != null ? driver.getName().replace("\"", "\\\"") : "",
                driver.getCurrentLatitude(),
                driver.getCurrentLongitude(),
                driver.getCurrentAddress() != null ? driver.getCurrentAddress().replace("\"", "\\\"") : "",
                driver.getStatus() != null ? driver.getStatus() : "AVAILABLE"
            );
            resp.getWriter().write(json);
        } else {
            resp.getWriter().write("{\"status\":\"not_found\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !user.isShipper()) {
            resp.setStatus(401);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");
            String address = req.getParameter("address");

            if (latStr == null || lngStr == null || latStr.trim().isEmpty() || lngStr.trim().isEmpty()) {
                resp.getWriter().write("{\"status\":\"error\", \"message\":\"Tọa độ không hợp lệ\"}");
                return;
            }

            double lat = Double.parseDouble(latStr.trim());
            double lng = Double.parseDouble(lngStr.trim());

            if (address == null || address.trim().isEmpty()) {
                address = "Vị trí GPS (" + String.format(java.util.Locale.US, "%.4f, %.4f", lat, lng) + "), TP. Thủ Đức";
            }

            Driver driver = driverDAO.getOrCreateDriverForUser(user);
            if (driver != null) {
                boolean ok = driverDAO.updateLocation(driver.getId(), lat, lng, address.trim());
                if (ok) {
                    resp.getWriter().write("{\"status\":\"success\", \"message\":\"Đã cập nhật vị trí GPS thành công\"}");
                    return;
                }
            }
            resp.getWriter().write("{\"status\":\"error\", \"message\":\"Không thể cập nhật vị trí\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
