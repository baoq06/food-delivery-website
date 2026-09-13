<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Bảng Điều Khiển Quản Trị - Utee Admin" />
</jsp:include>

<div class="admin-dashboard-container">
    <div class="container section">
        <!-- Success Alert if Action Performed -->
        <c:if test="${param.msg eq 'approved'}">
            <div style="background: #ecfdf5; border: 1px solid #10b981; color: #065f46; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-circle-check text-success" style="font-size: 1.2rem;"></i>
                <span>Đã duyệt đơn hàng thành công! Đơn đã được chuyển cho nhà bếp và tài xế.</span>
            </div>
        </c:if>

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

        <!-- Metric Stat Cards (Real Database Data) -->
        <div class="admin-stats-grid">
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Doanh Thu Admin (10%)</span>
                    <h3 class="stat-val"><fmt:formatNumber value="${adminRevenue}" pattern="#,##0" /> đ</h3>
                    <span class="stat-sub"><i class="fa-solid fa-circle-check text-success"></i> 10% giá trị món giao (${orderStats['DELIVERED'] != null ? orderStats['DELIVERED'] : 0} đơn, trừ ship)</span>
                </div>
            </div>

            <div class="admin-stat-card card-orders">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Đơn Hàng</span>
                    <h3 class="stat-val">${orderStats['TOTAL'] != null ? orderStats['TOTAL'] : 0} đơn</h3>
                    <span class="stat-sub">${orderStats['PENDING'] != null ? orderStats['PENDING'] : 0} chờ duyệt • ${orderStats['SHIPPING'] != null ? orderStats['SHIPPING'] : 0} đang giao</span>
                </div>
            </div>

            <div class="admin-stat-card card-foods">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-bowl-food"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Món Ăn Hoạt Động</span>
                    <h3 class="stat-val">${foodCount} món</h3>
                    <span class="stat-sub">Phân bố trên ${categoryCount} danh mục</span>
                </div>
            </div>

            <div class="admin-stat-card card-users">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-users"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Người Dùng</span>
                    <h3 class="stat-val">${userStats['totalUsers'] != null ? userStats['totalUsers'] : 0} thành viên</h3>
                    <span class="stat-sub">${userStats['customerCount'] != null ? userStats['customerCount'] : 0} khách • ${userStats['driverCount'] != null ? userStats['driverCount'] : 0} shipper • ${userStats['restaurantCount'] != null ? userStats['restaurantCount'] : 0} quán</span>
                </div>
            </div>
        </div>

        <!-- Recent Orders Table (Real Database Data) -->
        <div class="admin-table-card mt-4">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Đặt Hàng Gần Đây Cần Xử Lý</h3>
                    <span class="table-card-sub">Dữ liệu được cập nhật trực tiếp từ cơ sở dữ liệu</span>
                </div>
                <button class="btn btn-primary btn-sm" onclick="window.location.href='${pageContext.request.contextPath}/admin/dashboard'"><i class="fa-solid fa-rotate"></i> Làm mới</button>
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
                        <c:choose>
                            <c:when test="${not empty recentOrders}">
                                <c:forEach items="${recentOrders}" var="order">
                                    <tr>
                                        <td><strong>#${order.id}</strong></td>
                                        <td><c:out value="${order.customerName}" /></td>
                                        <td><c:out value="${order.phone}" /></td>
                                        <td>
                                            <span title="<c:out value='${not empty order.foodSummary ? order.foodSummary : \"Đơn đặt món\"}' />">
                                                <c:out value="${not empty order.foodSummary ? order.foodSummary : 'Đơn đặt món'}" />
                                            </span>
                                        </td>
                                        <td class="font-weight-bold text-primary">
                                            <fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> đ
                                            <c:if test="${order.adminCommission > 0}">
                                                <div style="font-size: 0.78rem; color: #059669; font-weight: 600;" title="Hoa hồng Admin 10% giá trị món ăn">
                                                    +<fmt:formatNumber value="${order.adminCommission}" pattern="#,##0" /> đ (10%)
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <span class="badge ${order.paymentMethod eq 'COD' ? 'badge-cod' : 'badge-qr'}">
                                                <c:out value="${order.paymentMethod != null ? order.paymentMethod : 'COD'}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status eq 'PENDING'}">
                                                    <span class="badge badge-pending">Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${order.status eq 'CONFIRMED'}">
                                                    <span class="badge" style="background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd;">Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${order.status eq 'SHIPPING'}">
                                                    <span class="badge badge-shipping">Đang giao hàng</span>
                                                </c:when>
                                                <c:when test="${order.status eq 'DELIVERED'}">
                                                    <span class="badge badge-done">Đã hoàn thành</span>
                                                </c:when>
                                                <c:when test="${order.status eq 'CANCELLED'}">
                                                    <span class="badge" style="background: #fee2e2; color: #991b1b; border: 1px solid #fecaca;">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">${order.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status eq 'PENDING'}">
                                                    <a href="${pageContext.request.contextPath}/admin/dashboard?action=approve&orderId=${order.id}"
                                                       class="btn-action btn-approve"
                                                       onclick="return confirm('Bạn có chắc chắn muốn duyệt đơn #${order.id}?');">
                                                        <i class="fa-solid fa-check"></i> Duyệt
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted" style="font-size: 0.85rem;"><i class="fa-solid fa-circle-check text-success"></i> Đã xử lý</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 40px 20px; color: #64748b;">
                                        <i class="fa-solid fa-inbox" style="font-size: 2rem; margin-bottom: 10px; display: block; color: #94a3b8;"></i>
                                        Hiện tại chưa có đơn đặt hàng nào trong hệ thống.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

