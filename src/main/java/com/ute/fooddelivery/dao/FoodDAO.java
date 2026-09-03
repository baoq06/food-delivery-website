package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Food;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FoodDAO {

    private static final List<Food> SAMPLE_FOODS = new ArrayList<>();

    static {
        SAMPLE_FOODS.add(new Food(1, "Burger Bò Phô Mai Tan Chảy",
                "Thịt bò Úc nướng than hoa thơm lừng, phủ 2 lớp phô mai Cheddar béo ngậy kèm sốt tiêu đen đặc biệt.", 69000,
                "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&auto=format&fit=crop&q=80", 1,
                true));
        SAMPLE_FOODS.add(new Food(2, "Pizza Hải Sản Sốt Pesto Ý",
                "Tôm sú tươi, mực lá giòn ngọt, ớt chuông Đà Lạt quyện cùng phô mai Mozzarella trên đế bánh nướng củi.", 159000,
                "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700&auto=format&fit=crop&q=80", 1,
                true));
        SAMPLE_FOODS.add(new Food(3, "Gà Rán Giòn Cay Sốt Cay Hàn Quốc",
                "Gà tươi chiên giòn rụm bên ngoài mọng nước bên trong, phủ đẫm sốt cay ngọt kiểu Hàn cùng mè rang thơm.", 89000,
                "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=700&auto=format&fit=crop&q=80", 2,
                true));
        SAMPLE_FOODS.add(new Food(4, "Mì Ý Sốt Bò Bằm Phô Mai Parmigiano",
                "Sợi mì Spaghetti chuẩn al dente đượm sốt bò bằm cà chua thơm nức thảo mộc hương thảo, rắc phô mai bào.", 79000,
                "https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=700&auto=format&fit=crop&q=80", 1,
                true));
        SAMPLE_FOODS.add(new Food(5, "Trà Sữa Ô Long Nướng Trân Châu Hoàng Kim",
                "Vị trà đậm đà rang mộc, sữa tươi thanh béo kết hợp trân châu hoàng kim dai dẻo nấu từ đường thốt nốt.", 42000,
                "https://images.unsplash.com/photo-1558857563-b37cf0e0e014?w=700&auto=format&fit=crop&q=80", 3,
                true));
        SAMPLE_FOODS.add(new Food(6, "Cơm Sườn Cốt Lết Nướng Mật Ong Rừng",
                "Sườn non tẩm ướp mật ong rừng đậm vị nướng xém cạnh, ăn kèm cơm tấm thơm dẻo, chả trứng và đồ chua.", 59000,
                "https://images.unsplash.com/photo-1544025162-d76694265947?w=700&auto=format&fit=crop&q=80", 4,
                true));
        SAMPLE_FOODS.add(new Food(7, "Phở Bò Tái Lăn Hà Nội Đặc Biệt",
                "Thịt bò tươi xào lăn lửa lớn dậy mùi gừng tỏi thơm phức, nước dùng hầm xương ngọt thanh trong 12 tiếng.", 65000,
                "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=700&auto=format&fit=crop&q=80", 4,
                true));
        SAMPLE_FOODS.add(new Food(8, "Bánh Mì Kẹp Thịt Nướng Giòn Rụm",
                "Vỏ bánh nóng giòn tan, nhân thịt nướng xiên que thơm ngậy, pate béo bùi, rau mùi dưa leo tươi mát.", 35000,
                "https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&auto=format&fit=crop&q=80", 1,
                true));
        SAMPLE_FOODS.add(new Food(9, "Salad Ức Gà Áp Chảo Sốt Mè Rang",
                "Ức gà áp chảo mềm mọng, xà lách romaine giòn, cà chua bi, trứng luộc lòng đào và sốt mè rang bùi béo.", 62000,
                "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=700&auto=format&fit=crop&q=80", 5,
                true));
        SAMPLE_FOODS.add(new Food(10, "Cà Phê Muối Kem Béo Huế",
                "Cà phê Robusta Đắk Lắk pha phin nguyên chất kết hợp lớp kem sữa mặn béo ngậy ngọt ngào mê mẩn.", 38000,
                "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=700&auto=format&fit=crop&q=80", 3,
                true));
    }

    public List<Food> getAllFoods() {
        List<Food> list = new ArrayList<>();
        String query = "SELECT * FROM foods WHERE available = 1";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new Food(
                                rs.getInt("id"),
                                rs.getString("name"),
                                rs.getString("description"),
                                rs.getDouble("price"),
                                rs.getString("image"),
                                rs.getInt("category_id"),
                                rs.getBoolean("available")));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lưu ý: Không thể truy vấn CSDL, chuyển sang dữ liệu mẫu: " + e.getMessage());
        }

        // Nếu CSDL rỗng hoặc chưa tạo bảng, trả về danh sách mẫu để giao diện luôn hiển
        // thị đẹp
        if (list.isEmpty()) {
            return new ArrayList<>(SAMPLE_FOODS);
        }
        return list;
    }

    public Food getFoodById(int id) {
        String query = "SELECT * FROM foods WHERE id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return new Food(
                                    rs.getInt("id"),
                                    rs.getString("name"),
                                    rs.getString("description"),
                                    rs.getDouble("price"),
                                    rs.getString("image"),
                                    rs.getInt("category_id"),
                                    rs.getBoolean("available"));
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lưu ý: Không thể lấy món theo ID từ CSDL: " + e.getMessage());
        }

        // Fallback tìm trong danh sách mẫu
        return SAMPLE_FOODS.stream()
                .filter(f -> f.getId() == id)
                .findFirst()
                .orElse(null);
    }
}
