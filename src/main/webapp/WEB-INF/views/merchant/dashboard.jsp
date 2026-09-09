<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Kênh Quán Ăn - Tổng Quan | Utee" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
        <!-- 4 Metric KPI Stat Cards -->
        <div class="admin-stats-grid merchant-stats-top">
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Doanh Thu Tích Lũy</span>
                    <h3 class="stat-val text-primary"><fmt:formatNumber value="${kpis.totalRevenue}" type="number" /> đ</h3>
                    <span class="stat-sub text-success"><i class="fa-solid fa-calendar-day"></i> Hôm nay: <strong><fmt:formatNumber value="${kpis.todayRevenue}" type="number" /> đ</strong></span>
                </div>
            </div>

            <div class="admin-stat-card card-orders">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Số Đơn Hàng</span>
                    <h3 class="stat-val">${kpis.totalOrders} đơn</h3>
                    <span class="stat-sub text-success"><i class="fa-solid fa-circle-check"></i> Đã giao thành công: <strong>${kpis.deliveredOrders}</strong></span>
                </div>
            </div>

            <div class="admin-stat-card card-pending">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-bell"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Đơn Cần Chế Biến</span>
                    <h3 class="stat-val" style="color: #d97706;">${kpis.pendingOrders} đơn</h3>
                    <span class="stat-sub"><a href="${pageContext.request.contextPath}/merchant/orders?status=PENDING" class="text-primary font-weight-bold">Xử lý nhận đơn &rarr;</a></span>
                </div>
            </div>

            <div class="admin-stat-card card-shippers">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tài Xế Đang Sẵn Sàng</span>
                    <h3 class="stat-val" style="color: #2563eb;">${availableShipperCount} tài xế</h3>
                    <span class="stat-sub"><a href="${pageContext.request.contextPath}/merchant/shippers" class="text-primary font-weight-bold">Xem đội ngũ shipper &rarr;</a></span>
                </div>
            </div>
        </div>

        <!-- Bento Grid: Bảng Đơn Gần Đây (Rộng hơn) & Top Món Bán Chạy (Gọn hơn) -->
        <div class="merchant-dashboard-grid">
            <!-- Cột Trái: Đơn Gần Đây -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Hàng Gần Đây Của Quán</h3>
                        <span class="table-card-sub">Theo dõi tiến độ nhận đơn, chế biến và bàn giao shipper</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/orders" class="btn-merchant-quick">
                        <span>Xem tất cả</span>
                        <i class="fa-solid fa-arrow-right"></i>
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="admin-data-table">
                        <thead>
                            <tr>
                                <th style="width: 90px;">Mã Đơn</th>
                                <th style="width: 160px;">Khách Hàng</th>
                                <th>Món Đặt</th>
                                <th style="width: 120px;">Tổng Tiền</th>
                                <th style="width: 130px;">Trạng Thái</th>
                                <th style="width: 130px;">Tài Xế</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentOrders}">
                                    <c:forEach var="order" items="${recentOrders}">
                                        <tr>
                                            <td><strong style="color: #0f172a;">#DH-${order.id}</strong></td>
                                            <td>
                                                <strong style="color: #1e293b;">${order.customerName}</strong><br/>
                                                <small class="text-muted"><i class="fa-solid fa-phone"></i> ${order.phone}</small>
                                            </td>
                                            <td>
                                                <div style="font-size: 0.86rem; line-height: 1.4;">
                                                    <c:forEach var="item" items="${order.items}" varStatus="loop">
                                                        <span>${item.foodName} &times; <strong>${item.quantity}</strong><c:if test="${not loop.last}">, </c:if></span>
                                                    </c:forEach>
                                                </div>
                                            </td>
                                            <td class="font-weight-bold text-primary">
                                                <fmt:formatNumber value="${order.totalAmount}" type="number" /> đ
                                            </td>
                                            <td>
                                                <span class="badge ${order.status eq 'DELIVERED' ? 'badge-done' : (order.status eq 'SHIPPING' ? 'badge-shipping' : (order.status eq 'PENDING' ? 'badge-pending' : (order.status eq 'CANCELLED' ? 'badge-cancelled' : 'badge-confirmed')))}">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">Chờ nhận đơn</c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}">Đang chế biến</c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}">Đang giao</c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}">Hoàn tất</c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}">Đã hủy</c:when>
                                                        <c:otherwise>${order.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty order.driverName}">
                                                        <span class="text-success font-weight-bold" style="font-size: 0.85rem;">
                                                            <i class="fa-solid fa-motorcycle"></i> ${order.driverName}
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${order.status eq 'CANCELLED'}">
                                                        <span class="text-muted small">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/merchant/orders" class="text-primary font-weight-bold" style="font-size: 0.82rem;">
                                                            <i class="fa-solid fa-user-plus"></i> Gán shipper
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <div style="font-size: 2.2rem; margin-bottom: 8px;">📦</div>
                                            <strong style="color: #334155;">Chưa có đơn đặt hàng nào phát sinh!</strong>
                                            <p class="small text-muted mb-0 mt-1">Khi khách đặt món từ quán của bạn, danh sách đơn hàng sẽ xuất hiện trực tiếp tại đây.</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Cột Phải: Top Món Bán Chạy & Thao Tác Nhanh -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-fire text-danger"></i> Món Bán Chạy Nhất</h3>
                        <span class="table-card-sub">Top món ăn được yêu thích nhất</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/foods" class="btn-merchant-quick">
                        <span>Xem menu</span>
                    </a>
                </div>

                <div class="top-foods-list">
                    <c:choose>
                        <c:when test="${not empty topFoods}">
                            <c:forEach var="tf" items="${topFoods}" varStatus="status">
                                <div class="top-food-item">
                                    <div class="top-food-rank rank-${status.count}">${status.count}</div>
                                    <img src="${tf.imageUrl}" alt="${tf.foodName}" class="top-food-img" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&fit=crop'" />
                                    <div class="top-food-details">
                                        <h4 class="top-food-name">${tf.foodName}</h4>
                                        <span class="top-food-price"><fmt:formatNumber value="${tf.price}" type="number" /> đ</span>
                                    </div>
                                    <div class="top-food-stats">
                                        <span class="badge-qty">${tf.totalQuantitySold} đã bán</span>
                                        <span class="total-rev"><fmt:formatNumber value="${tf.totalRevenue}" type="number" /> đ</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-4 text-muted">
                                <div style="font-size: 2rem; margin-bottom: 8px;">🔥</div>
                                <strong style="color: #334155;">Chưa có dữ liệu món bán chạy!</strong>
                                <p class="small text-muted mb-3 mt-1">Các món ăn sẽ được tự động xếp hạng ngay sau khi đơn giao thành công.</p>
                                <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-plus-circle"></i> Đăng Món Mới
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
