package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBUtil;
import com.ute.fooddelivery.dao.UserDB;
import com.ute.fooddelivery.model.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.junit.Assert;
import org.junit.Test;
import java.util.List;

public class JPATest {

    @Test
    public void testJPAConnectionAndUserQuery() {
        System.out.println("=== BAT DAU KIEM TRA KET NOI JPA & TIDB CLOUD ===");
        
        EntityManagerFactory emf = DBUtil.getEmFactory();
        Assert.assertNotNull("EntityManagerFactory phai khoi tao thanh cong!", emf);
        Assert.assertTrue("EntityManagerFactory phai dang mo!", emf.isOpen());

        EntityManager em = emf.createEntityManager();
        Assert.assertNotNull("EntityManager phai khoi tao duoc!", em);
        try {
            System.out.println(">> [JPA Test] Tao EntityManager thanh cong!");

            // Test 1: Lay danh sach Users bang JPQL
            List<User> users = UserDB.selectAllUsers();
            System.out.println(">> [JPA Test] So luong users lay duoc qua JPQL: " + users.size());
            for (User u : users) {
                System.out.println("   + User ID: " + u.getId() + " | Username: " + u.getUsername() + " | Role: " + u.getRole());
            }
            Assert.assertFalse("Danh sach user tu TiDB khong duoc rong!", users.isEmpty());

            // Test 2: Tim user theo Primary Key bang em.find
            int firstId = users.get(0).getId();
            User found = UserDB.getUserById(firstId);
            Assert.assertNotNull("Phai tim thay user co id: " + firstId, found);
            System.out.println(">> [JPA Test] Tim thay User bang em.find(): " + found.getFullName() + " (" + found.getEmail() + ")");

        } finally {
            em.close();
        }
        System.out.println("=== KIEM TRA JPA & TIDB CLOUD HOAN TOAN THANH CONG! ===");
    }
}
