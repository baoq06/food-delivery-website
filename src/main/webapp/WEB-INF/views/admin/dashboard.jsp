<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Bảng Điều Khiển Quản Trị - FoodZone Admin" />
</jsp:include>

<div class="admin-dashboard-container">
    <div class="container section">
        <!-- Admin Header -->
        <div class="admin-header-box">
            <div>
                <span class="admin-badge"><i class="fa-solid fa-shield-halved"></i> Hệ Thống Quản Trị Trung Tâm</span>
                <h1 class="admin-main-title">Bảng Điều Khiển & Giám Sát Đơn Hàng</h1>
                <p class="admin-sub">Xin chào, <strong>${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : 'Quản trị viên'}</strong>! Chúc bạn một ngày làm việc hiệu quả.</p>
            </div>
            <div class="admin-actions">
                <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline"><i class="fa-solid fa-eye"></i> Xem Website Khách</a>
                <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-danger"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng Xuất</a>
            </div>
        </div>

        <!-- Metric Stat Cards -->
        <div class="admin-stats-grid">
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Doanh Thu Hôm Nay</span>
                    <h3 class="stat-val">12,850,000 đ</h3>
                    <span class="stat-trend trend-up"><i class="fa-solid fa-arrow-trend-up"></i> +18.5% so với hôm qua</span>
                </div>
            </div>

            <div class="admin-stat-card card-orders">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Đơn Hàng Mới</span>
                    <h3 class="stat-val">42 đơn</h3>
                    <span class="stat-sub">12 đơn đang giao tận nơi</span>
                </div>
            </div>

            <div class="admin-stat-card card-foods">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-bowl-food"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Món Ăn Hoạt Động</span>
                    <h3 class="stat-val">24 món</h3>
                    <span class="stat-sub">Phân bố trên 5 danh mục</span>
                </div>
            </div>

            <div class="admin-stat-card card-users">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-users"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Khách Hàng Đăng Ký</span>
                    <h3 class="stat-val">358 thành viên</h3>
                    <span class="stat-trend trend-up"><i class="fa-solid fa-arrow-trend-up"></i> +24 người dùng mới</span>
                </div>
            </div>
        </div>

        <!-- Recent Orders Table -->
        <div class="admin-table-card mt-4">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Đặt Hàng Gần Đây Cần Xử Lý</h3>
                    <span class="table-card-sub">Dữ liệu được cập nhật theo thời gian thực</span>
                </div>
                <button class="btn btn-primary btn-sm" onclick="alert('Đã làm mới dữ liệu mới nhất!')"><i class="fa-solid fa-rotate"></i> Làm mới</button>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th>Mã Đơn</th>
                            <th>Khách Hàng</th>
                            <th>Số Điện Thoại</th>
                            <th>Món Đặt</th>
                            <th>Tổng Tiền</th>
                            <th>Thanh Toán</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>#FZ-9821</strong></td>
                            <td>Nguyễn Văn An</td>
                            <td>0912 345 678</td>
                            <td>Burger Bò Phô Mai Tan Chảy (x2)</td>
                            <td class="font-weight-bold text-primary">153,000 đ</td>
                            <td><span class="badge badge-cod">COD</span></td>
                            <td><span class="badge badge-pending">Chờ xác nhận</span></td>
                            <td>
                                <button class="btn-action btn-approve" onclick="alert('Đã duyệt đơn #FZ-9821 và chuyển cho nhà bếp!')"><i class="fa-solid fa-check"></i> Duyệt</button>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>#FZ-9820</strong></td>
                            <td>Trần Thị Mai</td>
                            <td>0988 765 432</td>
                            <td>Pizza Hải Sản Sốt Pesto Ý (x1)</td>
                            <td class="font-weight-bold text-primary">174,000 đ</td>
                            <td><span class="badge badge-qr">VietQR</span></td>
                            <td><span class="badge badge-shipping">Đang giao hàng</span></td>
                            <td>
                                <button class="btn-action btn-detail" onclick="alert('Đơn hàng đang trên đường giao bởi tài xế Nguyễn Tuấn')"><i class="fa-solid fa-eye"></i> Xem</button>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>#FZ-9819</strong></td>
                            <td>Lê Hoàng Nam</td>
                            <td>0903 112 233</td>
                            <td>Gà Rán Giòn Cay (x2), Trà Sữa (x2)</td>
                            <td class="font-weight-bold text-primary">277,000 đ</td>
                            <td><span class="badge badge-qr">VietQR</span></td>
                            <td><span class="badge badge-done">Đã hoàn thành</span></td>
                            <td>
                                <span class="text-muted"><i class="fa-solid fa-circle-check text-success"></i> Xong</span>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>#FZ-9818</strong></td>
                            <td>Phạm Quỳnh Chi</td>
                            <td>0977 445 566</td>
                            <td>Mì Ý Sốt Bò Bằm Parmigiano (x1)</td>
                            <td class="font-weight-bold text-primary">94,000 đ</td>
                            <td><span class="badge badge-cod">COD</span></td>
                            <td><span class="badge badge-shipping">Đang giao hàng</span></td>
                            <td>
                                <button class="btn-action btn-detail" onclick="alert('Đang giao hàng')"><i class="fa-solid fa-eye"></i> Xem</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
