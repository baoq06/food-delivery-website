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
                int userId = -1;
                // Insert User
                String insertUser = "INSERT INTO users (username, password, name, email, phone, address, role) VALUES ('shippertest', '123456', 'Test Shipper', 'a@a.com', '0123456789', 'HCM', 'SHIPPER')";
                java.sql.PreparedStatement ps = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS);
                ps.executeUpdate();
                ResultSet generatedKeys = ps.getGeneratedKeys();
                if (generatedKeys.next()) userId = generatedKeys.getInt(1);
                
                // Insert Driver
                String insertDriver = "INSERT INTO drivers (user_id, name, phone, status) VALUES (" + userId + ", 'Test Shipper', '0123456789', 'OFFLINE')";
                stmt.executeUpdate(insertDriver);
                
                System.out.println("Shipper user created perfectly!");
            } catch(Exception e) { 
                e.printStackTrace(); 
            }


            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
