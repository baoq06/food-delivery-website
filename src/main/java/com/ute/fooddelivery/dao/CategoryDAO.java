package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Category;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String query = "SELECT category_id, name, image_icon, description FROM categories ORDER BY category_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new Category(
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("image_icon"),
                            rs.getString("description")
                        ));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn CategoryDAO.getAllCategories: " + e.getMessage());
        }
        return list;
    }

    public Category getCategoryById(int id) {
        String query = "SELECT category_id, name, image_icon, description FROM categories WHERE category_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return new Category(
                                rs.getInt("category_id"),
                                rs.getString("name"),
                                rs.getString("image_icon"),
                                rs.getString("description")
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy Category theo ID: " + e.getMessage());
        }
        return null;
    }
}
