<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Kênh Quán Ăn - Tổng Quan | Utee" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container section pt-0">
        <!-- Metric Stat Cards Đồng Bộ Với Trang Admin -->
        <div class="admin-stats-grid">
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Doanh Thu Toàn Thời Gian</span>
                    <h3 class="stat-val text-primary"><fmt:formatNumber value="${kpis.totalRevenue}" type="number" /> đ</h3>
                    <span class="stat-trend trend-up"><i class="fa-solid fa-clock"></i> Hôm nay: <fmt:formatNumber value="${kpis.todayRevenue}" type="number" /> đ</span>
                </div>
            </div>

            <div class="admin-stat-card card-orders">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Đơn Hàng</span>
                    <h3 class="stat-val">${kpis.totalOrders} đơn</h3>
                    <span class="stat-sub text-success"><i class="fa-solid fa-circle-check"></i> Đã giao: ${kpis.deliveredOrders} đơn</span>
                </div>
            </div>

            <div class="admin-stat-card card-pending">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-bell"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Đơn Cần Chế Biến</span>
                    <h3 class="stat-val text-warning">${kpis.pendingOrders} đơn</h3>
                    <span class="stat-sub"><a href="${pageContext.request.contextPath}/merchant/orders?status=PENDING" class="text-primary font-weight-bold">Xử lý ngay &rarr;</a></span>
                </div>
            </div>

            <div class="admin-stat-card card-shippers">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Shipper Đang Sẵn Sàng</span>
                    <h3 class="stat-val text-info">${availableShipperCount} tài xế</h3>
                    <span class="stat-sub"><a href="${pageContext.request.contextPath}/merchant/shippers" class="text-primary font-weight-bold">Xem danh sách &rarr;</a></span>
                </div>
            </div>
        </div>

        <!-- 2 Cột: Bảng Đơn Gần Đây & Top Món Bán Chạy -->
        <div class="merchant-grid-split mt-4">
            <!-- Cột Trái: Đơn Gần Đây -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Đặt Hàng Gần Đây Của Quán</h3>
                        <span class="table-card-sub">Theo dõi tiến trình chế biến và giao hàng thực tế</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/orders" class="btn btn-outline btn-sm">Xem Tất Cả &rarr;</a>
                </div>

                <div class="table-responsive">
                    <table class="admin-data-table">
                        <thead>
                            <tr>
                                <th>Mã Đơn</th>
                                <th>Khách Hàng</th>
                                <th>Món Đặt</th>
                                <th>Tổng Tiền</th>
                                <th>Trạng Thái</th>
                                <th>Tài Xế</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentOrders}">
                                    <c:forEach var="order" items="${recentOrders}">
                                        <tr>
                                            <td><strong>#DH-${order.id}</strong></td>
                                            <td>
                                                <strong>${order.customerName}</strong><br/>
                                                <small class="text-muted">${order.phone}</small>
                                            </td>
                                            <td>
                                                <div style="max-width: 200px; font-size: 0.88rem;">
                                                    <c:forEach var="item" items="${order.items}" varStatus="loop">
                                                        <span>${item.foodName} (x${item.quantity})<c:if test="${not loop.last}">, </c:if></span>
                                                    </c:forEach>
                                                </div>
                                            </td>
                                            <td class="font-weight-bold text-primary"><fmt:formatNumber value="${order.totalAmount}" type="number" /> đ</td>
                                            <td>
                                                <span class="badge ${order.status eq 'DELIVERED' ? 'badge-done' : (order.status eq 'SHIPPING' ? 'badge-shipping' : (order.status eq 'PENDING' ? 'badge-pending' : 'badge-qr'))}">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">Chờ xác nhận</c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}">Đang chế biến</c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}">Đang giao</c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}">Hoàn tất</c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}">Đã hủy</c:when>
                                                        <c:otherwise>${order.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${order.status ne 'CANCELLED'}">
                                                    <div style="font-size: 0.72rem; color: #666; margin-top: 3px;">
                                                        <c:choose>
                                                            <c:when test="${order.fullyConfirmed}">
                                                                <span class="text-success font-weight-bold"><i class="fa-solid fa-circle-check"></i> Khách đã nhận (Tính doanh thu)</span>
                                                            </c:when>
                                                            <c:when test="${order.merchantConfirmed and not order.customerConfirmed}">
                                                                <span class="text-warning font-weight-bold"><i class="fa-solid fa-clock"></i> Đợi khách nhận hàng</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted"><i class="fa-solid fa-hourglass"></i> Chờ xử lý</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty order.driverName}">
                                                        <span class="text-success font-weight-bold"><i class="fa-solid fa-motorcycle"></i> ${order.driverName}</span>
                                                    </c:when>
                                                    <c:when test="${order.status eq 'CANCELLED'}">
                                                        <span class="text-muted">Chưa gán shipper</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/merchant/shippers" class="text-muted"><i class="fa-solid fa-plus-circle"></i> Gán shipper</a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <div style="font-size: 2rem; margin-bottom: 8px;">📦</div>
                                            <strong style="color: #666;">Chưa có đơn đặt hàng nào phát sinh!</strong>
                                            <p class="small text-muted mb-0 mt-1">Khi khách hàng đặt món từ quán của bạn, danh sách và trạng thái giao hàng sẽ hiển thị tại đây.</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Cột Phải: Top Món Bán Chạy -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-fire text-danger"></i> Top Món Bán Chạy</h3>
                        <span class="table-card-sub">Món được khách đặt nhiều nhất</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-outline btn-sm">Quản Lý Món</a>
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
                            <div class="text-center py-5 text-muted">
                                <div style="font-size: 2rem; margin-bottom: 8px;">🔥</div>
                                <strong style="color: #666;">Chưa có dữ liệu món bán chạy!</strong>
                                <p class="small text-muted mb-3 mt-1">Các món ăn được khách hàng ưa chuộng sẽ được tự động xếp hạng sau khi đơn hoàn tất.</p>
                                <a href="${pageContext.request.contextPath}/merchant/foods?action=add" class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-plus-circle"></i> Đăng Món Mới
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Phím tắt nhanh -->
                <div class="merchant-quick-box mt-4">
                    <h4><i class="fa-solid fa-bolt text-warning"></i> Thao Tác Nhanh</h4>
                    <div class="quick-btn-row">
                        <a href="${pageContext.request.contextPath}/merchant/foods?action=add" class="quick-btn">
                            <i class="fa-solid fa-plus-circle text-primary"></i>
                            <span>Đăng món mới</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/merchant/revenue?view=DAY" class="quick-btn">
                            <i class="fa-solid fa-calendar-day text-success"></i>
                            <span>Doanh thu ngày</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/merchant/shippers?status=AVAILABLE" class="quick-btn">
                            <i class="fa-solid fa-motorcycle text-info"></i>
                            <span>Shipper sẵn sàng</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
