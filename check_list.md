# BẢNG CHECKLIST RÀ SOÁT CODEBASE (NHÁNH MASTER) & KẾ HOẠCH KHẮC PHỤC

> **Thời gian cập nhật:** 19/10/2026  
> **Trạng thái codebase:** Nhánh `master` (commit `1c72f3f`)  
> **Phạm vi rà soát:** Toàn bộ controllers, services, DAOs, models, filters, schema SQL và giao diện JSP.

---

## I. TỔNG QUAN CÁC LỖI ĐÃ ĐƯỢC KHẮC PHỤC TRƯỚC ĐÓ

Trong các commit gần đây (`6bace38`, `fa6d6e6`, `1c72f3f`, `eef553a`), các lỗi lớn sau đây **đã được xử lý triệt để**:

1. ✅ **UploadUtils**: Đã bỏ gán cứng ổ `c:/...`, thay bằng cơ chế phân giải đường dẫn động đa tầng (`resolvePersistentUploadDir`).
2. ✅ **Giỏ hàng đa nhà hàng**: Đã thêm kiểm tra xung đột quán ăn khi bấm "Thêm vào giỏ" (popup xác nhận làm mới giỏ) và chặn checkout nếu giỏ có nhiều quán ăn.
3. ✅ **Xác nhận chế biến của Quán**: Đã gỡ bỏ điều kiện ép buộc phải có Shipper mới được chuyển sang `CONFIRMED`.
4. ✅ **Tính Voucher phần trăm**: Đã thêm hàm `parsePercentage` giữ nguyên dấu thập phân, không còn lỗi phóng đại % giảm giá.
5. ✅ **Doanh thu Quán**: Đã sửa điều kiện SQL trong `OrderDAO` thành `(o.merchant_completed = 1 OR o.shipper_delivered = 1)`.
6. ✅ **Hoàn trả Voucher**: Đã xây dựng hàm `restoreVouchersForOrder` đảm bảo hoàn trả voucher khi đơn hàng bị hủy bởi Khách, Quán hoặc Shipper.
7. ✅ **Lỗ hổng Voucher chưa lưu**: `VoucherService` và `UserVoucherDAO` đã siết chặt kiểm tra, chỉ cho phép áp dụng voucher đã lưu trong kho với `quantity > 0`.
8. ✅ **Bảo mật Shipper**: Đã chặn toàn bộ các thao tác đổi trạng thái đơn qua HTTP GET trong `ShipperDashboardController`, chuyển sang HTTP POST có kiểm tra CSRF token.
9. ✅ **Giải phóng tài xế có điều kiện**: Đã kiểm tra `hasActiveOrders` trước khi chuyển tài xế về `AVAILABLE` để không xung đột cuốc xe khác.
10. ✅ **Redirect trang Live Map**: `OrderTrackingController` đã cho phép hiển thị khi trạng thái là `DELIVERED` hoặc `confirmed`.
11. ✅ **Cập nhật GPS khi đổi địa chỉ quán**: `RestaurantDAO.updateRestaurant` đã tự động đồng bộ tọa độ GPS mới.

---

## II. DANH SÁCH CÁC BUG & TỒN ĐỌNG CÒN LẠI TRÊN NHÁNH MASTER

Dưới đây là các lỗi, rủi ro concurrency, bảo mật và tính nhất quán dữ liệu **vẫn còn tồn tại** cần có kế hoạch xử lý:

---

### ✅ 1. [CRITICAL] Tranh chấp cuốc xe & Cướp đơn hàng giữa các Shipper (Race Condition) - ĐÃ XỬ LÝ
- **Mức độ:** `CRITICAL`
- **Trạng thái:** ✅ **ĐÃ KHẮC PHỤC**
- **Vị trí file:** 
  - [ShipperDashboardController.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/controller/shipper/ShipperDashboardController.java)
  - [OrderDAO.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/dao/OrderDAO.java)
- **Giải pháp đã thực hiện:**
  - Trong `OrderDAO.assignDriver`: Thắt chặt điều kiện SQL chỉ gán khi trạng thái là `PENDING` hoặc `CONFIRMED` và `(driver_id IS NULL OR driver_id = ? OR shipper_accepted = 0)`.
  - Trong `ShipperDashboardController.handleAcceptOrder`: Kiểm tra trạng thái đơn hiện thời, chặn nhận đơn nếu đã có tài xế khác chấp nhận hoặc đơn không còn hợp lệ, kiểm tra kết quả `assignDriver` trước khi chấp nhận.

---

### ✅ 2. [HIGH] Tài xế bị Quản trị viên cấm (BANNED) vẫn truy cập được phân hệ Shipper - ĐÃ XỬ LÝ
- **Mức độ:** `HIGH`
- **Trạng thái:** ✅ **ĐÃ KHẮC PHỤC**
- **Vị trí file:** 
  - [ShipperFilter.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/filter/ShipperFilter.java)
  - [AuthController.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/controller/AuthController.java)
- **Giải pháp đã thực hiện:**
  - Trong `ShipperFilter`: Bổ sung kiểm tra `driver != null && "BANNED".equalsIgnoreCase(driver.getStatus())`. Trả về HTTP 403 Forbidden kèm JSON đối với API request và chuyển hướng về `/auth?action=login&error=account_banned` đối với web request.
  - Trong `AuthController`: Bổ sung hiển thị thông báo lỗi thân thiện khi tài khoản đối tác tài xế bị tạm khóa.

---

### ✅ 3. [MEDIUM] Không nhất quán đường dẫn ảnh món ăn (`contextPath`) gây nguy cơ lỗi 404 - ĐÃ XỬ LÝ
- **Mức độ:** `MEDIUM`
- **Trạng thái:** ✅ **ĐÃ KHẮC PHỤC**
- **Vị trí file:** [MerchantFoodController.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/controller/merchant/MerchantFoodController.java)
- **Giải pháp đã thực hiện:**
  - Bỏ nối `req.getContextPath()` trước `savedRelPath` khi lưu URL ảnh món ăn, giữ đường dẫn tương đối `/assets/uploads/foods/...` đồng nhất với `UploadUtils` và các controller khác.

---

### ⏭️ 4. [MEDIUM] Mất món ăn trong giỏ hàng tạm khi khách hàng đăng ký tài khoản mới - BỎ QUA
- **Mức độ:** `MEDIUM`
- **Trạng thái:** ⏭️ **BỎ QUA THEO YÊU CẦU NGƯỜI DÙNG** (Không quan trọng, không cần thiết)
- **Vị trí file:** [AuthController.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/controller/AuthController.java)

---

### ✅ 5. [MEDIUM] File `dtb/schema.sql` thiếu định nghĩa các bảng và cột dữ liệu mới - ĐÃ XỬ LÝ
- **Mức độ:** `MEDIUM`
- **Trạng thái:** ✅ **ĐÃ KHẮC PHỤC** (Xử lý an toàn tuyệt đối cho dữ liệu hiện có)
- **Vị trí file:** [dtb/schema.sql](file:///d:/food-delivery-website/dtb/schema.sql)
- **Giải pháp đã thực hiện:**
  - Bổ sung đầy đủ 5 bảng còn thiếu: `vouchers`, `user_vouchers`, `driver_wallet_transactions`, `chat_conversations`, `chat_messages`.
  - Cập nhật đầy đủ các cột mới: `image_url` trong `order_reviews`, các cột ngân hàng trong `restaurants`, giấy tờ và `wallet_balance` trong `drivers`, combo trong `foods`, `proof_image` trong `orders`, `is_cod_locked`, `boom_count` trong `users`.
  - **Bảo toàn dữ liệu an toàn:** Gỡ bỏ hoàn toàn các câu lệnh `DROP TABLE IF EXISTS`, chuyển toàn bộ sang cú pháp an toàn `CREATE TABLE IF NOT EXISTS` và dùng `INSERT IGNORE` / `ON DUPLICATE KEY UPDATE` cho dữ liệu mẫu để không làm mất mát hoặc ghi đè dữ liệu đang hoạt động.

---

### ✅ 6. [LOW] Đoạn code thừa `getOrdersByUser` trong `OrderDAO` - ĐÃ XỬ LÝ
- **Mức độ:** `LOW`
- **Trạng thái:** ✅ **ĐÃ KHẮC PHỤC**
- **Vị trí file:** [OrderDAO.java](file:///d:/food-delivery-website/src/main/java/com/ute/fooddelivery/dao/OrderDAO.java)
- **Giải pháp đã thực hiện:**
  - Thay thế đoạn code SQL truy vấn cũ trùng lặp bằng cách chuyển tiếp trực tiếp: `return getOrdersByUserId(userId);`.

---

## III. MA TRẬN KẾ HOẠCH SỬA CHỮA (ACTION ROADMAP)

| Thứ tự | Hạng mục công việc | File liên quan | Trạng thái |
| :---: | :--- | :--- | :---: |
| **Bước 1** | Khắc phục lỗ hổng tranh chấp cuốc xe & cướp đơn hàng giữa các tài xế | `OrderDAO.java`, `ShipperDashboardController.java` | ✅ Hoàn thành |
| **Bước 2** | Chặn triệt để tài xế bị cấm (`BANNED`) truy cập phân hệ Shipper | `ShipperFilter.java`, `AuthController.java` | ✅ Hoàn thành |
| **Bước 3** | Chuẩn hóa đường dẫn ảnh món ăn (bỏ lặp `contextPath`) | `MerchantFoodController.java` | ✅ Hoàn thành |
| **Bước 4** | Nạp món chờ (`processPendingFood`) khi đăng ký tài khoản mới thành công | `AuthController.java` | ⏭️ Bỏ qua theo yêu cầu |
| **Bước 5** | Đồng bộ toàn bộ DDL (vouchers, user_vouchers, chat, wallet) vào `schema.sql` (bảo toàn data) | `dtb/schema.sql` | ✅ Hoàn thành |
| **Bước 6** | Dọn dẹp dead-code `getOrdersByUser` trong `OrderDAO.java` | `OrderDAO.java` | ✅ Hoàn thành |
