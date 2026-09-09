<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Báo Cáo Doanh Thu Thực Tế - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
        <!-- Toolbar Bộ Lọc & Chuyển Đổi Tab Chế Độ Xem -->
        <div class="merchant-filter-bar">
            <div class="merchant-filter-left">
                <span class="merchant-filter-label">
                    <i class="fa-solid fa-chart-pie text-primary"></i> Chế độ xem:
                </span>
                <div class="merchant-filter-group">
                    <a href="${pageContext.request.contextPath}/merchant/revenue?view=DAY&year=${selectedYear}&month=${selectedMonth}" 
                       class="merchant-filter-pill ${selectedView eq 'DAY' ? 'active' : ''}">
                        <i class="fa-solid fa-calendar-day"></i> <span>Theo Ngày</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/revenue?view=MONTH&year=${selectedYear}" 
                       class="merchant-filter-pill ${selectedView eq 'MONTH' ? 'active' : ''}">
                        <i class="fa-solid fa-calendar-alt"></i> <span>Theo Tháng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/revenue?view=YEAR" 
                       class="merchant-filter-pill ${selectedView eq 'YEAR' ? 'active' : ''}">
                        <i class="fa-solid fa-calendar"></i> <span>Theo Năm</span>
                    </a>
                </div>
            </div>

            <!-- Filter Controls -->
            <div class="merchant-filter-right">
                <form action="${pageContext.request.contextPath}/merchant/revenue" method="GET" class="d-flex align-items-center gap-2 flex-wrap">
                    <input type="hidden" name="view" value="${selectedView}" />
                    
                    <c:if test="${selectedView eq 'DAY'}">
                        <div class="d-flex align-items-center gap-2">
                            <label class="text-muted small fw-bold mb-0">Tháng:</label>
                            <select name="month" class="form-select form-control" onchange="this.form.submit()" style="width: 120px; height: 38px; border-radius: 8px;">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>

                    <c:if test="${selectedView eq 'DAY' || selectedView eq 'MONTH'}">
                        <div class="d-flex align-items-center gap-2">
                            <label class="text-muted small fw-bold mb-0">Năm:</label>
                            <select name="year" class="form-select form-control" onchange="this.form.submit()" style="width: 110px; height: 38px; border-radius: 8px;">
                                <c:forEach var="y" begin="2024" end="2027">
                                    <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>

                    <button type="submit" class="btn btn-outline-primary btn-sm d-inline-flex align-items-center gap-1" style="height: 38px; border-radius: 8px; padding: 0 14px;">
                        <i class="fa-solid fa-rotate"></i> <span>Áp dụng</span>
                    </button>
                </form>
            </div>
        </div>

        <!-- Metric Stat Cards (Đồng bộ chuẩn Admin Dashboard) -->
        <div class="admin-stats-grid">
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Doanh Thu Kỳ Này</span>
                    <h3 class="stat-val text-primary"><fmt:formatNumber value="${totalRevenue}" type="number" /> đ</h3>
                    <span class="stat-trend trend-up"><i class="fa-solid fa-circle-check"></i> Đã duyệt xác nhận 2 bên</span>
                </div>
            </div>

            <div class="admin-stat-card card-orders">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Tổng Đơn Hàng Kỳ Này</span>
                    <h3 class="stat-val">${totalOrders} đơn</h3>
                    <span class="stat-sub text-success"><i class="fa-solid fa-circle-check"></i> Đã loại trừ đơn hủy</span>
                </div>
            </div>

            <div class="admin-stat-card card-foods">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-utensils"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Số Lượng Món Xuất Bán</span>
                    <h3 class="stat-val text-warning">${totalItems} phần</h3>
                    <span class="stat-sub">Tổng lượng món chế biến</span>
                </div>
            </div>

            <div class="admin-stat-card card-users">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-calculator"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Giá Trị Trung Bình / Đơn</span>
                    <h3 class="stat-val text-info"><fmt:formatNumber value="${avgOrderValue}" type="number" /> đ</h3>
                    <span class="stat-sub">Chỉ số AOV trung bình</span>
                </div>
            </div>
        </div>

        <!-- Biểu Đồ Cột Xu Hướng (admin-table-card) -->
        <div class="admin-table-card mt-4">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-chart-column text-primary"></i> Biểu Đồ Cột Xu Hướng Doanh Thu Thực Tế</h3>
                    <span class="table-card-sub">
                        Hiển thị theo: <strong>${selectedView eq 'DAY' ? 'Từng ngày trong tháng' : (selectedView eq 'MONTH' ? '12 tháng trong năm' : 'Tổng hợp theo các năm')}</strong>
                    </span>
                </div>
            </div>

            <div class="revenue-chart-container">
                <c:choose>
                    <c:when test="${not empty stats && totalRevenue > 0}">
                        <div class="chart-bars-wrap">
                            <c:forEach var="stat" items="${stats}">
                                <c:set var="barHeight" value="${maxRevenue > 0 ? (stat.revenue / maxRevenue * 100) : 0}" />
                                <div class="chart-col">
                                    <div class="chart-bar-tooltip">
                                        <strong>${stat.label}</strong><br/>
                                        Doanh thu: <fmt:formatNumber value="${stat.revenue}" type="number" /> đ<br/>
                                        Số đơn: ${stat.orderCount} đơn
                                    </div>
                                    <div class="chart-bar-outer">
                                        <div class="chart-bar-fill" style="height: ${barHeight}%;"></div>
                                    </div>
                                    <span class="chart-bar-label">${stat.periodKey}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <div style="font-size: 2.2rem; margin-bottom: 8px;">📈</div>
                            <strong style="color: #666;">Chưa có dữ liệu đơn hàng nào phát sinh doanh thu trong kỳ này.</strong>
                            <p class="small text-muted mb-0 mt-1">Khi quán hoàn tất các đơn giao hàng thành công, biểu đồ doanh thu sẽ được vẽ chi tiết.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Bảng Tổng Hợp Chi Tiết Theo Thời Gian -->
        <div class="admin-table-card mt-4">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-table-list text-primary"></i> Bảng Kê Doanh Thu &amp; Sản Lượng</h3>
                    <span class="table-card-sub">Chi tiết số tiền và số đơn hàng theo từng mốc</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th>Mốc Thời Gian</th>
                            <th>Doanh Thu Thực Tế</th>
                            <th>Số Lượng Đơn</th>
                            <th>Số Lượng Món</th>
                            <th>Giá Trị Trung Bình / Đơn</th>
                            <th>Tỷ Trọng Doanh Thu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty stats}">
                                <c:forEach var="s" items="${stats}">
                                    <c:set var="ratio" value="${totalRevenue > 0 ? (s.revenue / totalRevenue * 100) : 0}" />
                                    <tr>
                                        <td><strong>${s.label}</strong></td>
                                        <td class="font-weight-bold text-primary"><fmt:formatNumber value="${s.revenue}" type="number" /> đ</td>
                                        <td>${s.orderCount} đơn</td>
                                        <td>${s.itemCount} phần</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${s.orderCount > 0}">
                                                    <fmt:formatNumber value="${s.revenue / s.orderCount}" type="number" /> đ
                                                </c:when>
                                                <c:otherwise>0 đ</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="progress-bar-wrap">
                                                <div class="progress-fill" style="width: ${ratio}%;"></div>
                                                <span class="progress-text"><fmt:formatNumber value="${ratio}" maxFractionDigits="1" />%</span>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <div style="font-size: 1.8rem; margin-bottom: 6px;">📊</div>
                                        <span>Không có dữ liệu bảng kê doanh thu trong khoảng thời gian đã chọn.</span>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Danh Sách Đơn Hàng Thực Tế Trong Kỳ -->
        <div class="admin-table-card mt-4">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-file-invoice-dollar text-success"></i> Đơn Hàng Thực Tế Cấu Thành Doanh Thu</h3>
                    <span class="table-card-sub">Minh bạch từng đơn hàng đã được cả hai bên (khách &amp; quán) xác nhận</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th>Mã Đơn</th>
                            <th>Thời Gian</th>
                            <th>Khách Hàng</th>
                            <th>Món Đặt Của Quán</th>
                            <th>Tiền Món</th>
                            <th>Trạng Thái</th>
                            <th>Thanh Toán</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty detailedOrders}">
                                <c:forEach var="ord" items="${detailedOrders}">
                                    <c:set var="restTotal" value="0" />
                                    <tr>
                                        <td><span class="fw-bold font-monospace text-dark">#DH-${ord.id}</span></td>
                                        <td>
                                            <div class="text-dark fw-medium" style="font-size: 0.88rem;">
                                                <fmt:formatDate value="${ord.createdAt}" pattern="HH:mm" />
                                            </div>
                                            <div class="text-muted" style="font-size: 0.78rem;">
                                                <fmt:formatDate value="${ord.createdAt}" pattern="dd/MM/yyyy" />
                                            </div>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark" style="font-size: 0.92rem;">${ord.customerName}</div>
                                            <div class="text-muted small">
                                                <i class="fa-solid fa-phone text-primary" style="font-size: 0.75rem;"></i> ${ord.phone}
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.85rem; max-width: 260px;">
                                                <c:forEach var="it" items="${ord.items}" varStatus="loop">
                                                    <span class="text-dark">${it.foodName} <strong class="text-primary">&times; ${it.quantity}</strong><c:if test="${not loop.last}">, </c:if></span>
                                                    <c:set var="restTotal" value="${restTotal + it.subtotal}" />
                                                </c:forEach>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-bold text-primary" style="font-size: 0.98rem;">
                                                <fmt:formatNumber value="${restTotal}" type="number" /> đ
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge ${ord.status eq 'DELIVERED' ? 'badge-done' : (ord.status eq 'SHIPPING' ? 'badge-shipping' : 'badge-pending')}">
                                                <c:choose>
                                                    <c:when test="${ord.status eq 'DELIVERED'}"><i class="fa-solid fa-circle-check me-1"></i> Hoàn tất</c:when>
                                                    <c:when test="${ord.status eq 'SHIPPING'}"><i class="fa-solid fa-truck-fast me-1"></i> Đang giao</c:when>
                                                    <c:otherwise><i class="fa-solid fa-clock me-1"></i> Chờ xử lý</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td><span class="badge badge-cod" style="font-size: 0.75rem; text-transform: uppercase;">${ord.paymentMethod}</span></td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <div style="font-size: 1.8rem; margin-bottom: 6px;">🧾</div>
                                        <span>Không có đơn hàng nào phát sinh trong khoảng thời gian này.</span>
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
