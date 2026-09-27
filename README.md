# Utee - Food Delivery Website

## Overview
The Food Delivery Website is an online ordering and delivery platform built with Java Web (Jakarta EE) and deployed on Apache Tomcat.

The system supports four main roles:
- Customer: Browse menus, manage cart, place and track orders.
- Merchant: Manage menus, view revenue statistics, and process orders.
- Shipper: Receive dispatch requests, manage deliveries, and update order statuses.
- Administrator: System management, dashboard analytics, and user moderation.

## Technologies
- Language: Java 21
- Platform: Jakarta Servlet 6.0, JSP, JSTL
- Build Tool: Maven
- Database: MySQL / TiDB
- Web Server: Apache Tomcat 11 (or 10.1)
- Frontend: HTML5, CSS3, Flexbox/Grid

## Installation & Running

### Requirements
- Java Development Kit (JDK 17 or 21)
- Apache Maven
- Apache Tomcat 11
- MySQL Server

### Database Setup
1. Create a new MySQL database (e.g., food_delivery_db).
2. Execute the schema file located at `dtb/schema.sql` to initialize the core tables: users, drivers, restaurants, foods, categories, and orders.
3. Configure your database credentials in the application's database configuration file (`DBContext.java`).
4. Execute `dtb/update_shipper.sql` to establish shipper-related tables and constraints.

### Build and Deploy
1. Clone the repository to your local workspace.
2. Open a terminal in the project root directory.
3. Compile and build the project using Maven:
   ```bash
   mvn clean package -DskipTests
   ```
4. Upon successful build, a `.war` file will be generated in the `target/` directory (e.g., `target/food-delivery-website.war`).
5. Copy the generated `.war` file into the `webapps` directory of your Apache Tomcat server installation.
6. Start the Tomcat server.
7. Access the application in your web browser at: `http://localhost:8080/food-delivery-website`

## User Accounts and Testing
- General Access: Users can register via the standard signup page and select their desired role (Customer, Seller, or Shipper).
- Admin Access: To test administrator features, register a standard account and manually update the user's role to 'ADMIN' directly within the database.
