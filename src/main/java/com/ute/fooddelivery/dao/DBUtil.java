package com.ute.fooddelivery.dao;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * Lớp tiện ích JPA theo chuẩn Chapter 13 Slide 19
 * Quản lý khởi tạo và cung cấp EntityManagerFactory cho persistence unit 'foodDeliveryPU'
 */
public class DBUtil {
    private static final EntityManagerFactory emf;

    static {
        EntityManagerFactory factory = null;
        try {
            Map<String, Object> props = new HashMap<>();

            // 1. Kiểm tra biến môi trường hệ thống
            String envDriver = System.getenv("DB_DRIVER");
            String envUrl = System.getenv("DB_URL");
            String envUser = System.getenv("DB_USERNAME");
            String envPass = System.getenv("DB_PASSWORD");

            String driver = envDriver;
            String url = envUrl;
            String user = envUser;
            String pass = envPass;

            // 2. Nạp từ db.properties và phân giải
            try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    Properties p = new Properties();
                    p.load(input);
                    if (driver == null || driver.trim().isEmpty()) {
                        driver = DBContext.resolveProperty(p.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
                    }
                    if (url == null || url.trim().isEmpty()) {
                        url = DBContext.resolveProperty(p.getProperty("db.url"));
                    }
                    if (user == null || user.trim().isEmpty()) {
                        user = DBContext.resolveProperty(p.getProperty("db.username"));
                    }
                    if (pass == null || pass.trim().isEmpty()) {
                        pass = DBContext.resolveProperty(p.getProperty("db.password"));
                    }
                }
            } catch (Exception ex) {
                System.err.println(">> [DBUtil] Khong the doc db.properties: " + ex.getMessage());
            }

            if (driver != null && !driver.trim().isEmpty()) {
                props.put("jakarta.persistence.jdbc.driver", driver.trim());
                props.put("javax.persistence.jdbc.driver", driver.trim());
            }
            if (url != null && !url.trim().isEmpty()) {
                props.put("jakarta.persistence.jdbc.url", url.trim());
                props.put("javax.persistence.jdbc.url", url.trim());
            }
            if (user != null && !user.trim().isEmpty()) {
                props.put("jakarta.persistence.jdbc.user", user.trim());
                props.put("javax.persistence.jdbc.user", user.trim());
            }
            if (pass != null && !pass.trim().isEmpty()) {
                props.put("jakarta.persistence.jdbc.password", pass.trim());
                props.put("javax.persistence.jdbc.password", pass.trim());
            }

            if (!props.isEmpty()) {
                factory = Persistence.createEntityManagerFactory("foodDeliveryPU", props);
            } else {
                factory = Persistence.createEntityManagerFactory("foodDeliveryPU");
            }
            System.out.println(">> [DBUtil] Khởi tạo EntityManagerFactory (foodDeliveryPU) thành công!");
        } catch (Throwable e) {
            System.err.println(">> [DBUtil] Lỗi khởi tạo EntityManagerFactory: " + e.getMessage());
            e.printStackTrace();
        }
        emf = factory;
    }

    public static EntityManagerFactory getEmFactory() {
        return emf;
    }

    public static void closeEmFactory() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
