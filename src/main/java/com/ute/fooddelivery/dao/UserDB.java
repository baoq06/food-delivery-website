package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.util.List;

/**
 * Lớp truy cập dữ liệu User bằng JPA theo chuẩn Chapter 13 Slide 21, 26, 36-39
 */
public class UserDB {

    // Slide 36: Insert a single entity
    public static void insert(User user) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        trans.begin();
        try {
            em.persist(user);
            trans.commit();
        } catch (Exception e) {
            System.err.println(">> [UserDB.insert] Lỗi: " + e.getMessage());
            trans.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // Slide 37: Update a single entity
    public static void update(User user) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        trans.begin();
        try {
            em.merge(user);
            trans.commit();
        } catch (Exception e) {
            System.err.println(">> [UserDB.update] Lỗi: " + e.getMessage());
            trans.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // Slide 38: Delete a single entity
    public static void delete(User user) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        trans.begin();
        try {
            em.remove(em.merge(user));
            trans.commit();
        } catch (Exception e) {
            System.err.println(">> [UserDB.delete] Lỗi: " + e.getMessage());
            trans.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // Slide 21: Retrieve an entity by primary key
    public static User getUserById(int userId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            return em.find(User.class, userId);
        } finally {
            em.close();
        }
    }

    // Slide 26, 39: Retrieve a single entity by email using JPQL
    public static User selectUser(String email) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        String qString = "SELECT u FROM User u WHERE u.email = :email";
        TypedQuery<User> q = em.createQuery(qString, User.class);
        q.setParameter("email", email);
        try {
            return q.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    // JPQL query: Login bằng tài khoản (username/email/phone) và mật khẩu
    public static User login(String account, String password) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        String qString = "SELECT u FROM User u WHERE (u.username = :account OR u.email = :account OR u.phone = :account) AND u.password = :password";
        TypedQuery<User> q = em.createQuery(qString, User.class);
        q.setParameter("account", account);
        q.setParameter("password", password);
        try {
            return q.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    // Slide 39: Check if email exists
    public static boolean emailExists(String email) {
        User u = selectUser(email);
        return u != null;
    }

    // Slide 23: Retrieve multiple entities using JPQL
    public static List<User> selectAllUsers() {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        String qString = "SELECT u FROM User u";
        TypedQuery<User> q = em.createQuery(qString, User.class);
        try {
            return q.getResultList();
        } finally {
            em.close();
        }
    }
}
