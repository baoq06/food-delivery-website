import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.nio.file.Files;
import java.nio.file.Paths;

public class UpdateDB {
    public static void main(String[] args) {
        try {
            java.util.Properties props = new java.util.Properties();
            try (java.io.InputStream in = UpdateDB.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (in != null) props.load(in);
            } catch (Exception ignored) {}

            String url = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : props.getProperty("db.url");
            String user = System.getenv("DB_USERNAME") != null ? System.getenv("DB_USERNAME") : props.getProperty("db.username");
            String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : props.getProperty("db.password");
            
            Connection conn = DriverManager.getConnection(url, user, password);
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
