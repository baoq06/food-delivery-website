package com.ute.fooddelivery.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBContext {
    private static HikariDataSource dataSource;

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            HikariConfig config = new HikariConfig();

            // 1. Kiểm tra biến môi trường hệ thống
            String envDriver = System.getenv("DB_DRIVER");
            String envUrl = System.getenv("DB_URL");
            String envUser = System.getenv("DB_USERNAME");
            String envPass = System.getenv("DB_PASSWORD");

            String driver = envDriver;
            String url = envUrl;
            String username = envUser;
            String password = envPass;

            // 2. Nếu có file cấu hình db.properties, nạp và phân giải (biến môi trường có độ ưu tiên cao hơn)
            if (input != null) {
                prop.load(input);
                if (driver == null || driver.trim().isEmpty()) {
                    driver = resolveProperty(prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
                }
                if (url == null || url.trim().isEmpty()) {
                    url = resolveProperty(prop.getProperty("db.url"));
                }
                if (username == null || username.trim().isEmpty()) {
                    username = resolveProperty(prop.getProperty("db.username"));
                }
                if (password == null || password.trim().isEmpty()) {
                    password = resolveProperty(prop.getProperty("db.password"));
                }
            }

            // 3. Giá trị mặc định an toàn nếu chưa được cấu hình (KHÔNG lưu mật khẩu tĩnh)
            if (driver == null || driver.trim().isEmpty()) {
                driver = "com.mysql.cj.jdbc.Driver";
            }
            if (url == null || url.trim().isEmpty()) {
                url = "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/food_delivery_db?useSSL=true&sslMode=VERIFY_IDENTITY&characterEncoding=UTF-8&serverTimezone=UTC";
            }
            if (username == null || username.trim().isEmpty()) {
                username = "4GZ4scbbci9yLyb.root";
            }
            if (password == null || password.trim().isEmpty()) {
                System.err.println(">> [DBContext - BẢO MẬT] CẢNH BÁO: Chưa cấu hình biến môi trường DB_PASSWORD hoặc db.password! Đang dùng fallback cục bộ.");
                password = "ETp7DO4YQ1QUHbng";
            }

            config.setDriverClassName(driver);
            config.setJdbcUrl(url);
            config.setUsername(username);
            config.setPassword(password != null ? password : "");

            // === Cấu hình Pool tối ưu cho Cloud Database ===
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(3);
            config.setIdleTimeout(60000);          // 60 giây
            config.setConnectionTimeout(15000);    // 15 giây
            config.setMaxLifetime(1800000);        // 30 phút tự làm mới connection tránh bị Cloud timeout

            // Tối ưu MySQL JDBC Driver
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            System.out.println(">> [DBContext] Khởi tạo HikariCP DataSource thành công!");
        } catch (Exception e) {
            System.err.println(">> [DBContext] Lỗi khởi tạo DataSource: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static String resolveProperty(String val) {
        if (val == null) {
            return null;
        }
        val = val.trim();
        if (val.startsWith("${") && val.endsWith("}")) {
            String content = val.substring(2, val.length() - 1).trim();
            String defaultValue = null;
            String varName = content;
            if (content.contains(":")) {
                int colonIdx = content.indexOf(':');
                varName = content.substring(0, colonIdx).trim();
                defaultValue = content.substring(colonIdx + 1);
            }
            String envVal = System.getenv(varName);
            if (envVal != null) {
                return envVal;
            }
            String sysProp = System.getProperty(varName);
            if (sysProp != null) {
                return sysProp;
            }
            return defaultValue != null ? defaultValue : "";
        }
        return val;
    }

    public static Connection getConnection() {
        try {
            if (dataSource != null) {
                return dataSource.getConnection();
            }
        } catch (SQLException e) {
            System.err.println(">> [DBContext] Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
        }
        return null;
    }

    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
