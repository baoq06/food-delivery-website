# Utee - Food Delivery Website 🍔🛵

Hệ thống đặt đồ ăn và giao hàng trực tuyến (Food Delivery Website) được xây dựng bằng **Java Web** (Jakarta EE) và triển khai trên **Apache Tomcat**. 

Dự án này là mô hình hoàn chỉnh vận hành 4 vai trò (Roles) chính:
- **Khách hàng (Customer)**: Mua trực tuyến, tìm kiếm món ăn, cho đồ vào giỏ hàng và theo dõi đơn hàng.
- **Chủ quán ăn (Seller/Merchant)**: Quản lý thực đơn, xem thông kê doanh thu và xác nhận đơn của người mua.
- **Tài xế giao hàng (Shipper)**: Kênh dành riêng cho tài xế, nhận cuốc đơn và cập nhật trạng thái hoạt động trên nền tảng.
- **Quản trị viên (Admin)**: Quản trị tổng thể hệ thống, thống kê toàn sàn và xử lý tài khoản người dùng/quán ăn/tài xế.

## 🛠️ Công Nghệ Sử Dụng
- **Language**: Java 21
- **Platform**: Jakarta Servlet 6.0, JSP, JSTL
- **Build tool**: Maven
- **Database**: MySQL / TiDB
- **Web Server**: Apache Tomcat 11 (hoặc Tomcat 10.1)
- **Frontend / UI**: HTML5, CSS3, Flexbox/Grid (Thiết kế tone Đỏ Utee Vibrant, Typography chuẩn), FontAwesome

## 🚀 Hướng Dẫn Cài Đặt Khởi Chạy Nhanh (Quick Start)

Dự án đã được tích hợp sẵn Script PowerShell tự động biên dịch và tải (deploy) ứng dụng qua Apache Tomcat chỉ bằng một câu lệnh!

### Bước 1: Yêu Cầu Máy Chủ Cục Bộ (Local)
1. Hãy đảm bảo bạn đã cài đặt sẵn bản **Java JDK** (Tốt nhất là Java 17 hoặc 21).
2. Hãy đảm bảo bạn đã cài đặt sẵn **Apache Maven** và gõ thử lệnh `mvn -v` trên terminal thành công.
3. Giải nén cài đặt **Apache Tomcat 11** về một thư mục trên máy (Ví dụ: `C:\apache-tomcat-11.0.25`).

### Bước 2: Kéo Mã Nguồn Về
Clone repository đồ án này hoặc giải nén source file ra một vùng lưu trữ trên máy tính của bạn (VD: `D:\WEBPROGRAMMING\food-delivery-website\`).

### Bước 3: Cấu hình thư mục Tomcat & Chạy
Script khởi động `run_web.ps1` sẽ làm nhiệm vụ: `mvn clean package`, xóa file cũ trong tomcat và copy bản WAR mới vào khởi động server. Nhờ vậy bạn không cần dùng tính năng deploy thủ công khá phức tạp.
1. Mở file `run_web.ps1` trong VS Code hoặc Notepad. Gắn dòng trỏ đến thư mục Tomcat cục bộ của máy tính bạn sao cho chính xác ở dòng đầu tiên.
   (Ví dụ: `$tomcatDir = "C:\Users\Admin\apache-tomcat-11.0.25"`)
2. Mở cửa sổ dòng lệnh Terminal hoặc PowerShell tại thư mục đồ án hiện tại. Gõ đoạn lệnh sau và ấn phím **Enter**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File run_web.ps1
   ```
3. Chờ công cụ biên dịch tự động. File **.war** sẽ đi vào mục cài đặt Tomcat và một Window Console Tomcat 11 sẽ tự động hiện lên báo "Server startup...".
4. Mở trình duyệt web của bạn và truy cập: 👉 `http://localhost:8080/food-delivery-website`

> ⚠️ ***Lưu ý kẹt cổng Tomcat:*** 
> Nếu Command Window của Tomcat báo lỗi BindException: "Kẹt cổng 8080 hoặc cổng 8005", điều này là do một phiên bản Tomcat cũ đang chạy ẩn ngốn tài nguyên. Lúc này mở PowerShell gõ lệnh sau để dập:
> `for /f "tokens=5" %a in ('netstat -ano ^| findstr 8080') do taskkill /PID %a /F` rồi chạy lại Bước 3.

## 💾 Hướng Dẫn Thiết Lập Database (Cơ Sở Dữ Liệu)
Mọi câu lệnh thiết lập cấu trúc bảng đều đã được tóm tắt trong thư mục `dtb\`:
1. Mở DataGrip, MySQL Workbench hoặc giao diện CSDL Cloud như **TiDB**.
2. Thực thi toàn bộ lệnh trong thư mục `dtb\schema.sql`. Script này sẽ tạo Database `food_delivery_db` và khởi tạo các bảng: users, drivers, restaurants, foods, categories, orders.
3. Riêng thiết lập cho Shipper: Nhớ chạy file `dtb\update_shipper.sql` để nối 2 bảng Customer và Driver bằng Cột (Khóa Ngoại) `user_id`. (Đọc thêm lưu ý nếu chạy trên DB TiDB tại nội dung note nhỏ bên trong tệp tin đó).

## Demo Đăng Nhập Nhanh
- **Trang Khách hàng (Home/Store)**: Bất kỳ user nào ấn vô Đăng kí ở tab bên trái. 
- Mọi tài khoản Khởi Tạo tùy chọn Customer Hoặc Seller Hoặc Shipper 
- **Trang Admin**: Truy cập bằng tài khoản (Chỉnh role Admin trong SQL Dtb nếu mới test nha).

🌟 **Code With Logic, Designed For Food!** 🌟
