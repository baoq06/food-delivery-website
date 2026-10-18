package com.ute.fooddelivery.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBContext {
    private static volatile HikariDataSource dataSource;

    static {
        initDataSource();
    }

    /**
     * Khởi tạo hoặc tái tạo HikariDataSource một cách an toàn đa luồng.
     */
    public static synchronized void initDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        try {
            Properties prop = new Properties();
            HikariConfig config = new HikariConfig();

            // 1. Nạp từ classpath
            try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    prop.load(input);
                }
            } catch (Exception e) {
                System.err.println(">> [DBContext] Cảnh báo khi đọc db.properties từ classpath: " + e.getMessage());
            }

            // 2. Nạp từ file vật lý nếu có (hỗ trợ môi trường local dev)
            String[] possiblePaths = new String[] {
                "d:/WEBPROGRAMMING/food-delivery-website/src/main/resources/db.properties",
                "src/main/resources/db.properties"
            };
            for (String p : possiblePaths) {
                try {
                    java.io.File f = new java.io.File(p);
                    if (f.exists() && f.canRead()) {
                        try (java.io.FileInputStream fis = new java.io.FileInputStream(f)) {
                            prop.load(fis);
                        }
                        break;
                    }
                } catch (Exception ignored) {}
            }

            // 3. Phân giải các thuộc tính: Ưu tiên giá trị rõ ràng trong db.properties
            String driver = resolveProperty(prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            String url = resolveProperty(prop.getProperty("db.url"));
            String username = resolveProperty(prop.getProperty("db.username"));
            String password = resolveProperty(prop.getProperty("db.password"));

            // 4. Nếu chưa có trong file, fallback sang biến môi trường hệ thống
            if (driver == null || driver.trim().isEmpty()) {
                driver = System.getenv("DB_DRIVER");
            }
            if (url == null || url.trim().isEmpty()) {
                url = System.getenv("DB_URL");
            }
            if (username == null || username.trim().isEmpty()) {
                username = System.getenv("DB_USERNAME");
            }
            if (password == null || password.trim().isEmpty()) {
                password = System.getenv("DB_PASSWORD");
            }

            // 5. Giá trị mặc định an toàn cho TiDB Cloud
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
                password = "ETp7DO4YQ1QUHbng";
            }

            config.setDriverClassName(driver);
            config.setJdbcUrl(url);
            config.setUsername(username);
            config.setPassword(password);

            // === Cấu hình Pool tối ưu cho Cloud Database ===
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(3);
            config.setIdleTimeout(60000);          // 60 giây
            config.setConnectionTimeout(15000);    // 15 giây
            config.setMaxLifetime(1800000);        // 30 phút tự làm mới connection

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
            if (envVal != null && !envVal.trim().isEmpty()) {
                return envVal.trim();
            }
            String sysProp = System.getProperty(varName);
            if (sysProp != null && !sysProp.trim().isEmpty()) {
                return sysProp.trim();
            }
            return defaultValue != null ? defaultValue : "";
        }
        return val;
    }

    /**
     * Lấy kết nối cơ sở dữ liệu với cơ chế Auto-Reconnect tự động khôi phục nếu Pool chưa khởi tạo hoặc bị đóng.
     */
    public static Connection getConnection() {
        if (dataSource == null || dataSource.isClosed()) {
            initDataSource();
        }
        if (dataSource != null) {
            try {
                return dataSource.getConnection();
            } catch (SQLException e) {
                System.err.println(">> [DBContext] Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
                // Thử tái tạo nếu pool gặp sự cố kết nối
                try {
                    if (dataSource.isClosed()) {
                        initDataSource();
                        if (dataSource != null) {
                            return dataSource.getConnection();
                        }
                    }
                } catch (Exception ignored) {}
            }
        }
        return null;
    }

    public static synchronized void reload() {
        close();
        initDataSource();
    }

    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
