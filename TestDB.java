// No package

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/food_delivery_db?useSSL=true&sslMode=REQUIRED&characterEncoding=UTF-8&serverTimezone=UTC";
        String user = "4GZ4scbbci9yLyb.root";
        String password = "ETp7DO4YQ1QUHbng";

        try {
            System.out.println("Connecting to TiDB...");
            Connection conn = DriverManager.getConnection(url, user, password);
            System.out.println("Connected successfully!");
            System.out.println("Running user registration test...");
            try { 
                String insertOrder = "INSERT INTO orders (customer_name, phone, address, note, total_amount, payment_method, status) VALUES ('Khách Test Nổ Đơn', '0999999999', '123 Đường Test, HCM', 'Gọi khi tới', 150000, 'COD', 'CONFIRMED')";
                Statement stmt = conn.createStatement();
                stmt.executeUpdate(insertOrder);
                System.out.println("Order CONFIRMED created perfectly for dispatch testing!");
            } catch(Exception e) { 
                e.printStackTrace(); 
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
