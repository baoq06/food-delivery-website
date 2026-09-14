package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "categories")
public class Category implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private int id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "image_icon")
    private String imageIcon;

    @Column(name = "description")
    private String description;

    public Category() {
    }

    public Category(int id, String name, String imageIcon) {
        this.id = id;
        this.name = name;
        this.imageIcon = imageIcon;
    }

    public Category(int id, String name, String imageIcon, String description) {
        this.id = id;
        this.name = name;
        this.imageIcon = imageIcon;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImageIcon() {
        return imageIcon != null ? imageIcon : "🍔";
    }

    public void setImageIcon(String imageIcon) {
        this.imageIcon = imageIcon;
    }

    public String getIcon() {
        return getImageIcon();
    }

    // Tương thích ngược với thuộc tính image cũ
    public String getImage() {
        return getImageIcon();
    }

    public void setImage(String image) {
        this.imageIcon = image;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
