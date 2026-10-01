package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.FoodDAO;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.Assert.assertTrue;

public class MigrateComboAndFoodsTest {

    @Test
    public void seedCombosAndNewFoods() throws Exception {
        FoodDAO.ensureComboSupport();

        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {

            // Lấy ID của danh mục "Combo & Set Tiết Kiệm"
            int comboCatId = 1;
            try (ResultSet rs = stmt.executeQuery("SELECT category_id FROM categories WHERE name LIKE '%Combo%' LIMIT 1")) {
                if (rs.next()) {
                    comboCatId = rs.getInt(1);
                }
            }

            System.out.println(">> Combo category ID: " + comboCatId);

            // ==========================================
            // 1. Thêm 10 món đơn mới (cả đồ ăn & nước uống)
            // ==========================================
            String insertFoodSql = "INSERT INTO foods (name, description, price, image_url, category_id, restaurant_id, is_available, is_combo, original_price, combo_items) " +
                    "SELECT ?, ?, ?, ?, ?, ?, 1, 0, NULL, NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM foods WHERE name = ? AND restaurant_id = ?)";

            try (PreparedStatement ps = conn.prepareStatement(insertFoodSql)) {

                // --- Restaurant 1 (Bếp Việt Quán) ---
                // Món 1 (Đồ ăn): Cơm Tấm Sườn Bì Chả Đặc Biệt
                addFoodParam(ps, "Cơm Tấm Sườn Bì Chả Đặc Biệt",
                        "Cơm tấm thơm dẻo hạt tấm nhuyễn, sườn nướng than hoa mật ong, bì dai giòn và chả trứng hấp béo ngậy kèm đồ chua.",
                        58000.0,
                        "https://images.unsplash.com/photo-1544025162-d76694265947?w=700&auto=format&fit=crop&q=80",
                        1, 1);
                ps.executeUpdate();

                // Món 2 (Đồ ăn): Canh Rong Biển Thịt Bằm
                addFoodParam(ps, "Canh Rong Biển Thịt Bằm",
                        "Nước dùng thanh ngọt ninh từ xương thịt bằm tươi ngon, rong biển tươi giàu khoáng chất tốt cho sức khỏe.",
                        22000.0,
                        "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=700&auto=format&fit=crop&q=80",
                        1, 1);
                ps.executeUpdate();

                // Món 3 (Đồ ăn vặt): Chả Giò Hải Sản Rế Giòn Rụm (4 cuốn)
                addFoodParam(ps, "Chả Giò Hải Sản Rế Giòn Rụm (4 cuốn)",
                        "Vỏ bánh rế chiên vàng ươm giòn tan, nhân tôm thịt nấm mèo tươi ngọt đậm đà chấm kèm sốt tương ớt mayonnaise.",
                        32000.0,
                        "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=700&auto=format&fit=crop&q=80",
                        4, 1);
                ps.executeUpdate();

                // Món 4 (Nước uống): Trà Tắc Xí Muội Đường Phèn
                addFoodParam(ps, "Trà Tắc Xí Muội Đường Phèn",
                        "Trà lài hảo hạng ủ lạnh pha cùng tắc tươi mọng nước, vị chua ngọt thanh dịu kết hợp xí muội mặn nhẹ giải nhiệt tức thì.",
                        20000.0,
                        "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=700&auto=format&fit=crop&q=80",
                        3, 1);
                ps.executeUpdate();

                // Món 5 (Nước uống): Trà Sữa Trân Châu Đường Đen Utee
                addFoodParam(ps, "Trà Sữa Trân Châu Đường Đen Utee",
                        "Trà đen đậm vị hòa quyện sữa tươi béo ngậy, trân châu hoàng kim nấu đường đen dẻo dai thơm lừng.",
                        35000.0,
                        "https://images.unsplash.com/photo-1558857563-b37cfb87d605?w=700&auto=format&fit=crop&q=80",
                        3, 1);
                ps.executeUpdate();

                // --- Restaurant 2 (Phở & Bún Gia Truyền 1985) ---
                // Món 6 (Đồ ăn): Phở Gà Ta Thịt Đùi Trứng Non
                addFoodParam(ps, "Phở Gà Ta Thịt Đùi Trứng Non",
                        "Thịt gà ta thả vườn vàng ươm da giòn thịt ngọt, kèm chùm trứng non bùi béo trong bát nước dùng thanh trong thơm nức lá chanh.",
                        60000.0,
                        "https://images.unsplash.com/photo-1594998893017-36147cbcae05?w=700&auto=format&fit=crop&q=80",
                        2, 2);
                ps.executeUpdate();

                // Món 7 (Đồ ăn): Bún Chả Hà Nội Nướng Than Hoa
                addFoodParam(ps, "Bún Chả Hà Nội Nướng Than Hoa",
                        "Chả miếng và chả viên nướng xém cạnh trên than hoa đượm khói, bát nước mắm chua ngọt ấm nóng kèm đu đủ giòn và rau sống tươi.",
                        58000.0,
                        "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&auto=format&fit=crop&q=80",
                        2, 2);
                ps.executeUpdate();

                // Món 8 (Đồ ăn kèm): Đĩa Quẩy Giòn Rụm Ăn Phở (3 cái)
                addFoodParam(ps, "Đĩa Quẩy Giòn Rụm Ăn Phở (3 cái)",
                        "Quẩy chiên mới nóng hổi giòn rụm bên ngoài xốp mềm bên trong, chuẩn vị chấm cùng nước dùng phở bò gia truyền.",
                        12000.0,
                        "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=700&auto=format&fit=crop&q=80",
                        4, 2);
                ps.executeUpdate();

                // Món 9 (Nước uống): Sữa Đậu Nành Nấu Lá Dứa Tươi
                addFoodParam(ps, "Sữa Đậu Nành Nấu Lá Dứa Tươi",
                        "Đậu nành nguyên chất xay nấu thủ công mỗi sáng, thơm mát hương lá dứa tự nhiên, ngọt thanh dịu nhẹ.",
                        18000.0,
                        "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=700&auto=format&fit=crop&q=80",
                        3, 2);
                ps.executeUpdate();

                // Món 10 (Nước uống): Nước Rau Má Đậu Xanh Béo Bùi
                addFoodParam(ps, "Nước Rau Má Đậu Xanh Béo Bùi",
                        "Rau má tươi ép nguyên chất hòa quyện lớp đậu xanh nấu nhuyễn cốt dừa béo bùi thanh nhiệt cơ thể.",
                        22000.0,
                        "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=700&auto=format&fit=crop&q=80",
                        3, 2);
                ps.executeUpdate();
            }

            System.out.println(">> Đã thêm xong 10 món đơn mới!");

            // ==========================================
            // 2. Thêm các Combo / Set Tiết Kiệm cho quán
            // ==========================================
            String insertComboSql = "INSERT INTO foods (name, description, price, image_url, category_id, restaurant_id, is_available, is_combo, original_price, combo_items) " +
                    "SELECT ?, ?, ?, ?, ?, ?, 1, 1, ?, ? FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM foods WHERE name = ? AND restaurant_id = ?)";

            try (PreparedStatement ps = conn.prepareStatement(insertComboSql)) {

                // --- Restaurant 1 (Bếp Việt Quán) ---
                // Combo 1:
                addComboParam(ps, "Set Cơm Sườn Bì Chả + Canh Rong Biển + Trà Tắc",
                        "Bữa trưa hoàn hảo gồm 1 đĩa cơm sườn bì chả nướng thơm lừng, 1 tô canh rong biển thịt bằm thanh mát giải ngấy và 1 ly trà tắc xí muội mát lạnh.",
                        79000.0,
                        100000.0,
                        "Cơm Tấm Sườn Bì Chả Đặc Biệt, Canh Rong Biển Thịt Bằm, Trà Tắc Xí Muội Đường Phèn",
                        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 1);
                ps.executeUpdate();

                // Combo 2:
                addComboParam(ps, "Set Đôi Bạn Thân Bếp Việt (2 Người Ăn)",
                        "Set thịnh soạn tiết kiệm cho 2 người gồm 2 phần cơm bán chạy nhất quán, 1 đĩa chả giò hải sản giòn rụm và 2 ly trà đào cam sả tươi mát sảng khoái.",
                        169000.0,
                        212000.0,
                        "1 Cơm Sườn Nướng Mật Ong, 1 Cơm Tấm Sườn Bì Chả, 1 Đĩa Chả Giò Hải Sản (4 cuốn), 2 Ly Trà Đào Cam Sả",
                        "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 1);
                ps.executeUpdate();

                // Combo 3:
                addComboParam(ps, "Set Trà Sữa Ăn Vặt Chiều Chill",
                        "Set ăn vặt buổi chiều giải tỏa căng thẳng: trà sữa đậm đà trân châu dai mềm cùng 2 món ăn vặt nóng giòn chuẩn vị.",
                        82000.0,
                        103000.0,
                        "1 Trà Sữa Trân Châu Đường Đen, 1 Nem Chua Thanh Hóa, 1 Chả Giò Hải Sản Rế",
                        "https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 1);
                ps.executeUpdate();

                // --- Restaurant 2 (Phở & Bún Gia Truyền 1985) ---
                // Combo 4:
                addComboParam(ps, "Set Phở Bò Tái Nạm Truyền Thống + Quẩy + Sữa Đậu Nành",
                        "Combo điểm tâm chuẩn vị người sành ăn: bát phở bò tái nạm nước dùng thơm phức, quẩy giòn nhúng phở và ly sữa đậu nành lá dứa thanh nhẹ.",
                        75000.0,
                        92000.0,
                        "1 Tô Phở Bò Tái Nạm 1985, 1 Đĩa Quẩy Giòn (3 cái), 1 Ly Sữa Đậu Nành Lá Dứa",
                        "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 2);
                ps.executeUpdate();

                // Combo 5:
                addComboParam(ps, "Set Bún Bò Huế Chả Cua No Say + Chim Nướng + Nước Rau Má",
                        "Set ăn đậm đà chuẩn vị Cố Đô với bún bò huế chả cua cay nồng hấp dẫn, chim nướng béo ngậy mỡ hành và ly nước rau má đậu xanh mát lành.",
                        79000.0,
                        97000.0,
                        "1 Tô Bún Bò Huế Chả Cua Đặc Biệt, 1 Phần Chim Nướng Mỡ Hành, 1 Ly Nước Rau Má Đậu Xanh",
                        "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 2);
                ps.executeUpdate();

                // Combo 6:
                addComboParam(ps, "Set Đại Tiệc Gia Đình 1985 (3-4 Người Ăn)",
                        "Bữa tiệc sum họp gia đình hoặc nhóm bạn 3-4 người gồm 3 món bún phở đặc sản tinh hoa, kèm quẩy giòn và đồ uống cho cả nhà.",
                        209000.0,
                        259000.0,
                        "1 Phở Gà Ta Đùi Trứng Non, 1 Phở Bò Tái Nạm, 1 Bún Chả Hà Nội, 2 Đĩa Quẩy Giòn, 3 Ly Sữa Đậu Nành",
                        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 2);
                ps.executeUpdate();

                // --- Restaurant 60002 (Quán Ốc KTV) ---
                // Combo 7:
                addComboParam(ps, "Set Ốc Đêm Chill: Ốc Hương Bơ Tỏi + Bánh Mì + Nước Mía Tắc",
                        "Ốc hương tươi giòn sần sật quyện sốt bơ tỏi vàng óng chấm bánh mì nóng giòn, nhâm nhi cùng nước mía mát lạnh.",
                        69000.0,
                        84000.0,
                        "1 Phần Ốc Hương Xào Bơ Tỏi, 1 Bánh Mì Giòn, 1 Ly Nước Mía Cốt Tắc",
                        "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=700&auto=format&fit=crop&q=80",
                        comboCatId, 60002);
                ps.executeUpdate();
            }

            System.out.println(">> Đã thêm xong các Combos!");

            // Kiểm tra tổng số combo
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM foods WHERE is_combo = 1")) {
                if (rs.next()) {
                    System.out.println(">> Tổng số combo hiện có trong hệ thống: " + rs.getInt(1));
                    assertTrue(rs.getInt(1) >= 6);
                }
            }
        }
    }

    private void addFoodParam(PreparedStatement ps, String name, String desc, double price, String img, int catId, int restId) throws Exception {
        ps.setString(1, name);
        ps.setString(2, desc);
        ps.setDouble(3, price);
        ps.setString(4, img);
        ps.setInt(5, catId);
        ps.setInt(6, restId);
        ps.setString(7, name);
        ps.setInt(8, restId);
    }

    private void addComboParam(PreparedStatement ps, String name, String desc, double price, double origPrice, String comboItems, String img, int catId, int restId) throws Exception {
        ps.setString(1, name);
        ps.setString(2, desc);
        ps.setDouble(3, price);
        ps.setString(4, img);
        ps.setInt(5, catId);
        ps.setInt(6, restId);
        ps.setDouble(7, origPrice);
        ps.setString(8, comboItems);
        ps.setString(9, name);
        ps.setInt(10, restId);
    }
}
