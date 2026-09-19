<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Kênh Quán Ăn - Tổng Quan | Utee" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp">
        <jsp:param name="activeTab" value="dashboard" />
    </jsp:include>

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

        <!-- KHỐI CHÍNH DASHBOARD: BẢNG ĐƠN HÀNG RÚT GỌN (TRÁI) & MÓN BÁN CHẠY (PHẢI) -->
        <div class="merchant-dashboard-grid">
            <!-- CỘT TRÁI: Bảng Đơn Hàng Gần Đây (Rút Gọn 5 Cột Thông Minh) -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Hàng Gần Đây</h3>
                        <span class="table-card-sub">Tiến trình nhận đơn và điều phối shipper theo thời gian thực</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/orders" class="btn-merchant-quick">
                        <span>Xem tất cả</span>
                        <i class="fa-solid fa-arrow-right"></i>
                    </a>
                </div>

                <div class="dashboard-table-responsive">
                    <table class="dashboard-compact-order-table">
                        <thead>
                            <tr>
                                <th class="col-d-order"><i class="fa-solid fa-hashtag me-1"></i> Đơn &amp; Khách</th>
                                <th class="col-d-items"><i class="fa-solid fa-utensils me-1"></i> Món Quán</th>
                                <th class="col-d-amount"><i class="fa-solid fa-wallet me-1"></i> Tổng Tiền</th>
                                <th class="col-d-status"><i class="fa-solid fa-tags me-1"></i> Trạng Thái</th>
                                <th class="col-d-actions text-end"><i class="fa-solid fa-sliders me-1"></i> Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentOrders}">
                                    <c:forEach var="order" items="${recentOrders}">
                                        <tr>
                                            <!-- Cột 1: Đơn Hàng & Khách -->
                                            <td class="col-d-order">
                                                <div class="d-order-top">
                                                    <span class="d-order-badge">#DH-${order.id}</span>
                                                    <span class="d-order-time">
                                                        <i class="fa-regular fa-clock"></i>
                                                        <fmt:formatDate value="${order.createdAt}" pattern="HH:mm" />
                                                    </span>
                                                </div>
                                                <div class="d-customer-name" title="${order.customerName}">${order.customerName}</div>
                                                <a href="tel:${order.phone}" class="d-customer-phone" title="Gọi khách: ${order.phone}">
                                                    <i class="fa-solid fa-phone"></i> ${order.phone}
                                                </a>
                                            </td>

                                            <!-- Cột 2: Món Quán Đặt -->
                                            <td class="col-d-items">
                                                <div class="d-items-list" title="<c:forEach var='it' items='${order.items}'>${it.foodName} x${it.quantity}&#10;</c:forEach>">
                                                    <c:forEach var="item" items="${order.items}" varStatus="itemStatus">
                                                        <c:if test="${itemStatus.index < 2}">
                                                            <div class="d-item-line">
                                                                <span class="d-item-name" title="${item.foodName}">${item.foodName}</span>
                                                                <span class="d-item-qty">&times; ${item.quantity}</span>
                                                            </div>
                                                        </c:if>
                                                    </c:forEach>
                                                    <c:if test="${order.items.size() > 2}">
                                                        <div class="d-items-more">+${order.items.size() - 2} món khác</div>
                                                    </c:if>
                                                </div>
                                            </td>

                                            <!-- Cột 3: Tổng Tiền & Phương Thức -->
                                            <td class="col-d-amount">
                                                <div class="d-amount-val">
                                                    <fmt:formatNumber value="${order.totalAmount}" type="number" /> đ
                                                </div>
                                                <span class="mo-pay-badge ${order.paymentMethod eq 'CASH' ? 'badge-cod' : 'badge-vietqr'}">
                                                    <i class="fa-solid ${order.paymentMethod eq 'CASH' ? 'fa-money-bill-1' : 'fa-qrcode'}"></i>
                                                    ${order.paymentMethod}
                                                </span>
                                            </td>

                                            <!-- Cột 4: Trạng Thái & Tài Xế -->
                                            <td class="col-d-status">
                                                <div class="d-status-wrap">
                                                    <span class="mo-status-badge ${order.status eq 'DELIVERED' ? 'status-delivered' : (order.status eq 'SHIPPING' ? 'status-shipping' : (order.status eq 'PENDING' ? 'status-pending' : (order.status eq 'CANCELLED' ? 'status-cancelled' : 'status-confirmed')))}">
                                                        <c:choose>
                                                            <c:when test="${order.status eq 'PENDING'}">
                                                                <c:choose>
                                                                    <c:when test="${empty order.driverName}">
                                                                        <i class="fa-solid fa-bell fa-shake"></i> Đơn mới
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i class="fa-solid fa-hourglass-half"></i> Chờ tài xế
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:when>
                                                            <c:when test="${order.status eq 'CONFIRMED'}"><i class="fa-solid fa-fire-burner"></i> Đang nấu</c:when>
                                                            <c:when test="${order.status eq 'SHIPPING'}"><i class="fa-solid fa-truck-fast"></i> Đang giao</c:when>
                                                            <c:when test="${order.status eq 'DELIVERED'}"><i class="fa-solid fa-circle-check"></i> Hoàn tất</c:when>
                                                            <c:when test="${order.status eq 'CANCELLED'}"><i class="fa-solid fa-circle-xmark"></i> Đã hủy</c:when>
                                                            <c:otherwise>${order.status}</c:otherwise>
                                                        </c:choose>
                                                    </span>

                                                    <c:choose>
                                                        <c:when test="${not empty order.driverName}">
                                                            <div class="d-driver-tag" title="Tài xế: ${order.driverName} (${order.driverPhone})">
                                                                <i class="fa-solid fa-motorcycle text-success"></i>
                                                                <span>${order.driverName}</span>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <div class="d-driver-tag text-muted">
                                                                <i class="fa-solid fa-clock"></i>
                                                                <span>Chưa gán xế</span>
                                                            </div>
                                                        </c:when>
                                                    </c:choose>
                                                </div>
                                            </td>

                                            <!-- Cột 5: Thao Tác Nhanh -->
                                            <td class="col-d-actions">
                                                <div class="d-actions-wrap">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <!-- Nút Nhận Đơn (Gọi Radar Modal Tự Tìm Shipper Gần Nhất) -->
                                                            <button type="button" 
                                                                    class="btn-d-action btn-d-action-accept" 
                                                                    data-order-id="${order.id}" 
                                                                    data-customer="${order.customerName}" 
                                                                    onclick="handleAutoDispatchBtn(this)" 
                                                                    title="Đồng ý nhận &amp; quét tìm tài xế gần nhất">
                                                                <i class="fa-solid fa-check"></i> Nhận
                                                            </button>

                                                            <!-- Nút Từ Chối Đơn -->
                                                            <button type="button" 
                                                                    class="btn-d-action btn-d-action-reject" 
                                                                    data-order-id="${order.id}" 
                                                                    data-customer="${order.customerName}" 
                                                                    onclick="handleRejectBtn(this)" 
                                                                    title="Từ chối đơn hàng">
                                                                <i class="fa-solid fa-xmark"></i>
                                                            </button>
                                                        </c:when>

                                                        <c:when test="${order.status eq 'CONFIRMED'}">
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" class="d-inline m-0">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/merchant/dashboard" />
                                                                <button type="submit" class="btn-d-action btn-d-action-handover" title="Bàn giao món cho tài xế">
                                                                    <i class="fa-solid fa-boxes-packing"></i> Bàn giao
                                                                </button>
                                                            </form>
                                                        </c:when>

                                                        <c:when test="${order.status eq 'SHIPPING'}">
                                                            <c:choose>
                                                                <c:when test="${order.shipperDelivered}">
                                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" class="d-inline m-0">
                                                                        <input type="hidden" name="action" value="completeOrder" />
                                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                                        <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/merchant/dashboard" />
                                                                        <button type="submit" class="btn-d-action btn-d-action-complete" title="Xác nhận hoàn tất đơn hàng">
                                                                            <i class="fa-solid fa-circle-check"></i> Hoàn Tất
                                                                        </button>
                                                                    </form>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle py-1 px-2" style="font-size: 0.72rem;">
                                                                        <i class="fa-solid fa-motorcycle me-1"></i> Đang giao
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>

                                                        <c:when test="${order.status eq 'DELIVERED'}">
                                                            <span class="text-success small fw-bold" style="font-size: 0.78rem;">
                                                                <i class="fa-solid fa-circle-check"></i> Xong
                                                            </span>
                                                        </c:when>

                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="text-muted small" style="font-size: 0.75rem;">Đã hủy</span>
                                                        </c:when>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">
                                            <div style="font-size: 2rem; margin-bottom: 6px;">📦</div>
                                            <strong style="color: #334155; font-size: 0.88rem;">Chưa có đơn đặt hàng nào!</strong>
                                            <p class="small text-muted mb-0 mt-1">Đơn đặt món mới sẽ xuất hiện trực tiếp tại đây.</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- CỘT PHẢI: Top Món Bán Chạy Nhất -->
            <div class="admin-table-card dashboard-top-foods-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-fire text-danger"></i> Món Bán Chạy</h3>
                        <span class="table-card-sub">Top món ăn yêu thích nhất</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/foods" class="btn-merchant-quick">
                        <span>Menu</span>
                        <i class="fa-solid fa-arrow-right"></i>
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
                                <div style="font-size: 1.8rem; margin-bottom: 6px;">🔥</div>
                                <strong style="color: #334155; font-size: 0.88rem;">Chưa có món bán chạy!</strong>
                                <p class="small text-muted mb-2 mt-1">Sẽ tự xếp hạng khi hoàn tất đơn.</p>
                                <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-plus-circle"></i> Đăng Món
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- =========================================================================
     RADAR SCANNING MODAL: TỰ ĐỘNG TÌM SHIPPER GẦN QUÁN NHẤT (~1 GIÂY ANIMATION)
     ========================================================================= -->
<div id="radarSearchModal" class="radar-search-modal-backdrop" style="display: none;">
    <div class="radar-search-modal-box">
        <!-- Close Button (hidden during search, shown if error) -->
        <button type="button" class="radar-modal-close" id="radarModalCloseBtn" onclick="closeRadarSearchModal()" style="display: none;">&times;</button>

        <!-- Dynamic Header Title -->
        <div class="radar-modal-header text-center">
            <span class="radar-modal-badge"><i class="fa-solid fa-satellite-dish fa-spin"></i> AI SMART DISPATCH</span>
            <h3 class="radar-modal-title" id="radarModalTitle">Đang Tìm Shipper Gần Quán Nhất...</h3>
            <p class="radar-modal-subtitle" id="radarModalSubtitle">Đơn hàng <strong id="radarOrderCodeText">#DH-0</strong> • Khách: <span id="radarCustomerNameText">...</span></p>
        </div>

        <!-- Radar Visual Screen Container -->
        <div class="radar-screen-wrap">
            <div class="radar-circle-outer">
                <!-- Concentric Pulsing Rings -->
                <div class="radar-ring radar-ring-1"></div>
                <div class="radar-ring radar-ring-2"></div>
                <div class="radar-ring radar-ring-3"></div>

                <!-- Radar Sweep Beam (Rotating 360deg) -->
                <div class="radar-sweep-beam"></div>

                <!-- Center Restaurant Icon Anchor -->
                <div class="radar-center-hub">
                    <i class="fa-solid fa-store"></i>
                    <span class="radar-center-label">Quán</span>
                </div>

                <!-- Simulated Floating Shipper Blips -->
                <div class="radar-blip radar-blip-1" title="Tài xế A"><i class="fa-solid fa-motorcycle"></i></div>
                <div class="radar-blip radar-blip-2" title="Tài xế B"><i class="fa-solid fa-motorcycle"></i></div>
                <div class="radar-blip radar-blip-3" title="Tài xế C"><i class="fa-solid fa-motorcycle"></i></div>
            </div>

            <!-- Success Checkmark Overlay (Appears when found) -->
            <div class="radar-success-overlay" id="radarSuccessOverlay" style="display: none;">
                <div class="radar-success-circle">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
            </div>
        </div>

        <!-- Status Progress & Log Text -->
        <div class="radar-progress-box text-center">
            <div class="radar-dynamic-status" id="radarDynamicStatus">
                <span class="spinner-grow spinner-grow-sm text-primary me-2" role="status" id="radarStatusSpinner"></span>
                <span id="radarStatusText">Đang quét vị trí GPS các tài xế trong bán kính 3km...</span>
            </div>
            <div class="radar-progress-bar-wrap">
                <div class="radar-progress-bar-fill" id="radarProgressBarFill"></div>
            </div>
        </div>

        <!-- Found Result Card (Populated dynamically) -->
        <div class="radar-found-card" id="radarFoundCard" style="display: none;">
            <div class="d-flex align-items-center gap-3">
                <div class="radar-found-avatar">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
                <div class="flex-grow-1 text-start">
                    <div class="d-flex align-items-center justify-content-between">
                        <strong class="radar-found-name" id="radarFoundDriverName">Tài Xế Shipper</strong>
                        <span class="badge bg-success-subtle text-success border border-success-subtle" id="radarFoundDistanceBadge">0.8 km</span>
                    </div>
                    <div class="radar-found-meta text-muted small">
                        <span id="radarFoundDriverPhone"><i class="fa-solid fa-phone me-1"></i> 09xx xxx xxx</span> • 
                        <span class="text-success"><i class="fa-solid fa-shield-check"></i> Đang trực tuyến</span>
                    </div>
                </div>
            </div>
            <div class="radar-found-alert mt-2">
                <i class="fa-solid fa-paper-plane me-1"></i> Đã gửi yêu cầu nhận đơn. Đang chờ tài xế bấm xác nhận trên app...
            </div>
        </div>
    </div>
</div>

<script>
    function handleAutoDispatchBtn(btn) {
        const orderId = btn.getAttribute('data-order-id');
        const customer = btn.getAttribute('data-customer');
        acceptAndAutoFindShipper(orderId, customer);
    }

    function handleRejectBtn(btn) {
        const orderId = btn.getAttribute('data-order-id');
        const customer = btn.getAttribute('data-customer');
        rejectOrderPrompt(orderId, customer);
    }

    function acceptAndAutoFindShipper(orderId, customerName) {
        const modal = document.getElementById('radarSearchModal');
        const orderCodeText = document.getElementById('radarOrderCodeText');
        const customerNameText = document.getElementById('radarCustomerNameText');
        const statusText = document.getElementById('radarStatusText');
        const statusSpinner = document.getElementById('radarStatusSpinner');
        const progressFill = document.getElementById('radarProgressBarFill');
        const successOverlay = document.getElementById('radarSuccessOverlay');
        const foundCard = document.getElementById('radarFoundCard');
        const title = document.getElementById('radarModalTitle');
        const closeBtn = document.getElementById('radarModalCloseBtn');

        if (orderCodeText) orderCodeText.innerText = '#DH-' + orderId;
        if (customerNameText) customerNameText.innerText = customerName || '';
        if (title) title.innerText = 'Đang Tìm Shipper Gần Quán Nhất...';
        if (statusText) statusText.innerText = 'Đang quét vị trí GPS các tài xế trong bán kính 3km quanh quán...';
        if (statusSpinner) statusSpinner.style.display = 'inline-block';
        if (progressFill) { progressFill.style.width = '0%'; progressFill.style.transition = 'width 1.2s cubic-bezier(0.16, 1, 0.3, 1)'; }
        if (successOverlay) successOverlay.style.display = 'none';
        if (foundCard) foundCard.style.display = 'none';
        if (closeBtn) closeBtn.style.display = 'none';

        modal.style.display = 'flex';

        // Start progress bar animation
        setTimeout(() => { if (progressFill) progressFill.style.width = '75%'; }, 50);

        // After 600ms, update text to simulated step 2
        setTimeout(() => {
            if (statusText) statusText.innerText = 'Đang phân tích cự ly & kết nối tài xế sẵn sàng nhận đơn...';
            if (progressFill) progressFill.style.width = '90%';
        }, 600);

        // Call API at around 1100ms (to give exactly ~1.1s realistic radar animation)
        setTimeout(() => {
            const formData = new URLSearchParams();
            formData.append('orderId', orderId);
            formData.append('driverId', 'auto');

            fetch('${pageContext.request.contextPath}/merchant/api/dispatch', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (progressFill) progressFill.style.width = '100%';
                if (data.status === 'success') {
                    // Show success animation
                    if (title) title.innerText = '✅ Đã Tìm Thấy Tài Xế Gần Nhất!';
                    if (statusSpinner) statusSpinner.style.display = 'none';
                    if (statusText) statusText.innerHTML = '<span class="text-success fw-bold">Tìm kiếm thành công! Đã gửi đơn đến shipper.</span>';
                    if (successOverlay) successOverlay.style.display = 'flex';

                    if (foundCard) {
                        document.getElementById('radarFoundDriverName').innerText = data.driverName || 'Tài xế Shipper';
                        document.getElementById('radarFoundDriverPhone').innerHTML = '<i class="fa-solid fa-phone me-1"></i> ' + (data.driverPhone || '09xx xxx xxx');
                        document.getElementById('radarFoundDistanceBadge').innerText = (data.distanceKm ? data.distanceKm.toFixed(1) : '0.8') + ' km';
                        foundCard.style.display = 'block';
                    }

                    // After 1.2s viewing found shipper card, auto-reload page to reflect new status
                    setTimeout(() => {
                        window.location.reload();
                    }, 1300);
                } else {
                    if (title) title.innerText = 'Chưa Tìm Thấy Tài Xế';
                    if (statusSpinner) statusSpinner.style.display = 'none';
                    if (statusText) statusText.innerHTML = '<span class="text-danger fw-bold">' + (data.message || 'Chưa có tài xế trực tuyến') + '</span>';
                    if (closeBtn) closeBtn.style.display = 'flex';
                }
            })
            .catch(err => {
                console.error(err);
                if (title) title.innerText = 'Lỗi Kết Nối';
                if (statusSpinner) statusSpinner.style.display = 'none';
                if (statusText) statusText.innerHTML = '<span class="text-danger">Không thể kết nối đến máy chủ. Vui lòng thử lại!</span>';
                if (closeBtn) closeBtn.style.display = 'flex';
            });
        }, 1100);
    }

    function closeRadarSearchModal() {
        const modal = document.getElementById('radarSearchModal');
        if (modal) modal.style.display = 'none';
    }

    function rejectOrderPrompt(orderId, customerName) {
        if (confirm('Bạn có chắc chắn muốn TỪ CHỐI đơn hàng #' + orderId + ' của khách ' + customerName + '?\nĐơn hàng sẽ bị hủy và gửi thông báo đến khách.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/merchant/orders';

            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'updateStatus';
            form.appendChild(actionInput);

            const orderIdInput = document.createElement('input');
            orderIdInput.type = 'hidden';
            orderIdInput.name = 'orderId';
            orderIdInput.value = orderId;
            form.appendChild(orderIdInput);

            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'newStatus';
            statusInput.value = 'CANCELLED';
            form.appendChild(statusInput);

            const redirectInput = document.createElement('input');
            redirectInput.type = 'hidden';
            redirectInput.name = 'redirectUrl';
            redirectInput.value = '${pageContext.request.contextPath}/merchant/dashboard';
            form.appendChild(redirectInput);

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
