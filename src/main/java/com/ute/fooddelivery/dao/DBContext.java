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

            if (input != null) {
                prop.load(input);
                config.setDriverClassName(resolveProperty(prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver")));
                config.setJdbcUrl(resolveProperty(prop.getProperty("db.url")));
                config.setUsername(resolveProperty(prop.getProperty("db.username")));
                config.setPassword(resolveProperty(prop.getProperty("db.password")));
            } else {
                // Fallback nếu không tìm thấy file cấu hình
                config.setDriverClassName("com.mysql.cj.jdbc.Driver");
                config.setJdbcUrl("jdbc:mysql://localhost:3306/food_delivery_db?useSSL=false");
                config.setUsername("root");
                config.setPassword(System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "");
            }

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

    private static String resolveProperty(String val) {
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
