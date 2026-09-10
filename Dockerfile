# Stage 1: Build file war với Maven & Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml và tải trước các dependency để tối ưu cache
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy mã nguồn và đóng gói
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Chạy ứng dụng với Tomcat 11
FROM tomcat:11.0-jdk21-temurin

# Xóa các webapp mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Đổi tên file war thành ROOT.war để web chạy ngay tại domain gốc (/)
COPY --from=build /app/target/food-delivery-website.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
