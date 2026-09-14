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
            try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    Properties p = new Properties();
                    p.load(input);
                    if (p.getProperty("db.url") != null) {
                        String url = p.getProperty("db.url").trim();
                        props.put("jakarta.persistence.jdbc.url", url);
                        props.put("javax.persistence.jdbc.url", url);
                    }
                    if (p.getProperty("db.username") != null) {
                        String user = p.getProperty("db.username").trim();
                        props.put("jakarta.persistence.jdbc.user", user);
                        props.put("javax.persistence.jdbc.user", user);
                    }
                    if (p.getProperty("db.password") != null) {
                        String pass = p.getProperty("db.password").trim();
                        props.put("jakarta.persistence.jdbc.password", pass);
                        props.put("javax.persistence.jdbc.password", pass);
                    }
                    if (p.getProperty("db.driver") != null) {
                        String driver = p.getProperty("db.driver").trim();
                        props.put("jakarta.persistence.jdbc.driver", driver);
                        props.put("javax.persistence.jdbc.driver", driver);
                    }
                }
            } catch (Exception ex) {
                System.err.println(">> [DBUtil] Khong the doc db.properties: " + ex.getMessage());
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
