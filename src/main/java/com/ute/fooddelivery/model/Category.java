package com.ute.fooddelivery.model;

import java.io.Serializable;

public class Category implements Serializable {
    private int id;
    private String name;
    private String imageIcon;
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
