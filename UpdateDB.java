import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.nio.file.Files;
import java.nio.file.Paths;

public class UpdateDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test?sslMode=VERIFY_IDENTITY&sslKeyStore=C:/Users/Admin/keystore.jks&sslKeyStorePassword=changeit&sslTrustStore=C:/Users/Admin/cacerts.jks&sslTrustStorePassword=changeit";
        String user = "3rP99tMps22F3zH.root";
        String password = "xxxx"; // I need to read the password from DBContext or TestDB

        try {
            // Wait, let's extract credentials from src/main/resources/db.properties
            java.util.Properties props = new java.util.Properties();
            props.load(new java.io.FileInputStream("src/main/resources/db.properties"));
            
            Connection conn = DriverManager.getConnection(props.getProperty("db.url"), props.getProperty("db.username"), props.getProperty("db.password"));
            System.out.println("Connected to TiDB for updating reviews table!");
            
            String sql = new String(Files.readAllBytes(Paths.get("dtb/update_reviews.sql")));
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);
            System.out.println("Reviews table created successfully!");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
