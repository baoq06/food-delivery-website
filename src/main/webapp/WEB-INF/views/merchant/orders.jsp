<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Đơn Hàng - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp">
        <jsp:param name="activeTab" value="orders" />
    </jsp:include>

    <div class="merchant-orders-container pb-5">
        <!-- Toolbar Bộ Lọc Trạng Thái Đơn Hàng -->
        <div class="merchant-filter-bar">
            <div class="merchant-filter-left">
                <span class="merchant-filter-label">
                    <i class="fa-solid fa-filter text-primary"></i> Trạng thái:
                </span>
                <div class="merchant-filter-group">
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=ALL" class="merchant-filter-pill ${selectedStatus eq 'ALL' ? 'active' : ''}">
                        <span>Tất cả</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=PENDING" class="merchant-filter-pill ${selectedStatus eq 'PENDING' ? 'active' : ''}">
                        <i class="fa-solid fa-hourglass-half"></i> <span>Chờ nhận đơn</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=CONFIRMED" class="merchant-filter-pill ${selectedStatus eq 'CONFIRMED' ? 'active' : ''}">
                        <i class="fa-solid fa-kitchen-set"></i> <span>Đang chế biến</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=SHIPPING" class="merchant-filter-pill ${selectedStatus eq 'SHIPPING' ? 'active' : ''}">
                        <i class="fa-solid fa-motorcycle"></i> <span>Đang giao</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=DELIVERED" class="merchant-filter-pill ${selectedStatus eq 'DELIVERED' ? 'active' : ''}">
                        <i class="fa-solid fa-circle-check"></i> <span>Hoàn tất</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/orders?status=CANCELLED" class="merchant-filter-pill ${selectedStatus eq 'CANCELLED' ? 'active' : ''}">
                        <i class="fa-solid fa-circle-xmark"></i> <span>Đã hủy</span>
                    </a>
                </div>
            </div>

            <div class="merchant-filter-right">
                <a href="${pageContext.request.contextPath}/merchant/orders?status=${selectedStatus}" class="merchant-filter-refresh-btn" title="Làm mới danh sách đơn hàng">
                    <i class="fa-solid fa-rotate"></i>
                    <span>Làm mới dữ liệu</span>
                </a>
            </div>
        </div>

        <!-- Bảng Đơn Hàng Của Quán (merchant-order-card) -->
        <div class="merchant-order-card">
            <div class="merchant-order-header">
                <div>
                    <h3 class="merchant-order-title">
                        <i class="fa-solid fa-receipt text-primary"></i> Danh Sách Đơn Đặt Hàng Của Quán
                    </h3>
                    <span class="merchant-order-sub">Theo dõi và cập nhật trực tiếp tiến trình đơn hàng theo thời gian thực</span>
                </div>
            </div>

            <div class="merchant-table-wrapper">
                <table class="merchant-order-table">
                    <thead>
                        <tr>
                            <th class="col-mo-code"><i class="fa-solid fa-hashtag me-1"></i> Mã &amp; Giờ Đặt</th>
                            <th class="col-mo-customer"><i class="fa-solid fa-user me-1"></i> Khách Hàng &amp; Địa Chỉ</th>
                            <th class="col-mo-items"><i class="fa-solid fa-utensils me-1"></i> Món Quán Đặt</th>
                            <th class="col-mo-amount"><i class="fa-solid fa-wallet me-1"></i> Tổng Tiền</th>
                            <th class="col-mo-driver"><i class="fa-solid fa-motorcycle me-1"></i> Tài Xế Shipper</th>
                            <th class="col-mo-status"><i class="fa-solid fa-tags me-1"></i> Trạng Thái</th>
                            <th class="col-mo-actions text-end"><i class="fa-solid fa-sliders me-1"></i> Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach var="order" items="${orders}">
                                    <tr>
                                        <!-- Cột 1: Mã Đơn & Thời Gian -->
                                        <td class="col-mo-code">
                                            <span class="mo-code-badge">#DH-${order.id}</span>
                                            <div class="mo-time-wrap">
                                                <span class="mo-time-hour">
                                                    <i class="fa-regular fa-clock text-muted"></i>
                                                    <fmt:formatDate value="${order.createdAt}" pattern="HH:mm" />
                                                </span>
                                                <span class="mo-time-date">
                                                    <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy" />
                                                </span>
                                            </div>
                                        </td>

                                        <!-- Cột 2: Khách Hàng & Địa Chỉ -->
                                        <td class="col-mo-customer">
                                            <div class="mo-customer-name">${order.customerName}</div>
                                            <a href="tel:${order.phone}" class="mo-customer-phone" title="Gọi cho khách hàng">
                                                <i class="fa-solid fa-phone"></i> ${order.phone}
                                            </a>
                                            <div class="mo-customer-address" title="${order.address}">
                                                <i class="fa-solid fa-location-dot"></i> ${order.address}
                                            </div>
                                            <c:if test="${not empty order.note}">
                                                <div class="mo-customer-note" title="${order.note}">
                                                    <i class="fa-solid fa-comment-dots"></i>
                                                    <span>${order.note}</span>
                                                </div>
                                            </c:if>
                                        </td>

                                        <!-- Cột 3: Món Đặt Của Quán -->
                                        <td class="col-mo-items">
                                            <div class="mo-items-box">
                                                <c:forEach var="item" items="${order.items}">
                                                    <div class="mo-item-row">
                                                        <span class="mo-item-name">${item.foodName}</span>
                                                        <span class="mo-item-qty">&times; ${item.quantity}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </td>

                                        <!-- Cột 4: Tổng Tiền & Phương Thức -->
                                        <td class="col-mo-amount">
                                            <div class="mo-amount-val">
                                                <fmt:formatNumber value="${order.totalAmount}" type="number" /> đ
                                            </div>
                                            <div>
                                                <span class="mo-pay-badge ${order.paymentMethod eq 'CASH' ? 'badge-cod' : 'badge-vietqr'}">
                                                    <i class="fa-solid ${order.paymentMethod eq 'CASH' ? 'fa-money-bill-1' : 'fa-qrcode'}"></i>
                                                    ${order.paymentMethod}
                                                </span>
                                            </div>
                                        </td>

                                        <!-- Cột 5: Tài Xế Shipper -->
                                        <td class="col-mo-driver">
                                            <c:choose>
                                                <c:when test="${not empty order.driverName}">
                                                    <div class="mo-driver-info">
                                                        <div class="mo-driver-avatar" title="Tài xế giao hàng">
                                                            <i class="fa-solid fa-motorcycle"></i>
                                                        </div>
                                                        <div>
                                                            <div class="mo-driver-name">${order.driverName}</div>
                                                            <div class="mo-driver-phone">
                                                                <i class="fa-solid fa-phone-volume me-1" style="font-size: 0.68rem; color: #10b981;"></i>${order.driverPhone}
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="mt-1">
                                                        <c:choose>
                                                            <c:when test="${order.shipperAccepted}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle" style="font-size: 0.72rem;">
                                                                    <i class="fa-solid fa-check"></i> Tài xế đã nhận
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle" style="font-size: 0.72rem;">
                                                                    <i class="fa-solid fa-hourglass-half"></i> Chờ tài xế nhận
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="text-muted small">Không gán tài xế</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-light text-muted border py-1 px-2" style="font-size: 0.76rem;">
                                                                <i class="fa-solid fa-clock me-1"></i> Chờ quán nhận đơn
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cột 6: Trạng Thái Đơn Hàng -->
                                        <td class="col-mo-status">
                                            <div>
                                                <span class="mo-status-badge ${order.status eq 'DELIVERED' ? 'status-delivered' : (order.status eq 'SHIPPING' ? 'status-shipping' : (order.status eq 'PENDING' ? 'status-pending' : (order.status eq 'CANCELLED' ? 'status-cancelled' : 'status-confirmed')))}">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <c:choose>
                                                                <c:when test="${empty order.driverName}">
                                                                    <i class="fa-solid fa-bell fa-shake text-warning"></i> Đơn mới
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fa-solid fa-hourglass-half"></i> Chờ shipper nhận
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}"><i class="fa-solid fa-fire-burner"></i> Đang chế biến</c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}"><i class="fa-solid fa-truck-fast"></i> Đang giao</c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}"><i class="fa-solid fa-circle-check"></i> Hoàn tất</c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}"><i class="fa-solid fa-circle-xmark"></i> Đã hủy</c:when>
                                                        <c:otherwise>${order.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <c:if test="${order.status ne 'CANCELLED'}">
                                                <div class="mt-2 d-flex flex-column gap-1" style="font-size: 0.72rem; line-height: 1.3;">
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${order.shipperDelivered}">
                                                                <span class="text-success fw-bold"><i class="fa-solid fa-check"></i> Shipper: Đã giao</span>
                                                            </c:when>
                                                            <c:when test="${order.shipperAccepted}">
                                                                <span class="text-primary"><i class="fa-solid fa-motorcycle"></i> Shipper: Đang giao</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted"><i class="fa-solid fa-circle-dot"></i> Shipper: Chưa nhận</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${order.customerConfirmed}">
                                                                <span class="text-success fw-bold"><i class="fa-solid fa-check"></i> Khách: Đã nhận</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted"><i class="fa-solid fa-circle-dot"></i> Khách: Chưa nhận</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${order.merchantCompleted or order.status eq 'DELIVERED' or order.shipperDelivered}">
                                                                <span class="badge bg-success text-white py-0 px-1" style="font-size: 0.7rem;"><i class="fa-solid fa-sack-dollar"></i> Đã tính doanh thu</span>
                                                            </c:when>
                                                            <c:when test="${order.status eq 'SHIPPING'}">
                                                                <c:choose>
                                                                    <c:when test="${order.customerConfirmed and not order.shipperDelivered}">
                                                                        <span class="badge bg-info text-white py-0 px-1" style="font-size: 0.7rem;"><i class="fa-solid fa-clock"></i> Chờ shipper giao</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge bg-primary text-white py-0 px-1" style="font-size: 0.7rem;"><i class="fa-solid fa-motorcycle"></i> Đang vận chuyển</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </td>

                                        <!-- Cột 7: Thao Tác Tiến Trình -->
                                        <td class="col-mo-actions text-end">
                                            <div class="mo-actions-group">
                                                <c:choose>
                                                    <%-- BƯỚC 1: ĐƠN MỚI CHƯA GÁN SHIPPER -> QUÁN ĐỒNG Ý NHẬN HOẶC TỪ CHỐI --%>
                                                    <c:when test="${order.status eq 'PENDING' and empty order.driverName}">
                                                        <div class="d-flex align-items-center gap-1 justify-content-end">
                                                            <button type="button" class="btn-mo-action btn-mo-action-accept-auto" 
                                                                    data-order-id="${order.id}" 
                                                                    data-customer="<c:out value='${order.customerName}' />" 
                                                                    onclick="handleAutoDispatchBtn(this)" 
                                                                    title="Quán đồng ý nhận đơn và hệ thống tự động tìm kiếm shipper">
                                                                <i class="fa-solid fa-circle-check"></i>
                                                                <span>Đồng Ý Nhận</span>
                                                            </button>
                                                            <button type="button" class="btn-mo-action-cancel" 
                                                                    data-order-id="${order.id}" 
                                                                    data-customer="<c:out value='${order.customerName}' />" 
                                                                    onclick="handleRejectBtn(this)" 
                                                                    title="Từ chối đơn hàng này">
                                                                <i class="fa-solid fa-ban"></i>
                                                            </button>
                                                        </div>
                                                    </c:when>

                                                    <%-- BƯỚC 2: QUÁN ĐÃ ĐỒNG Ý & ĐÃ GÁN SHIPPER, ĐANG CHỜ SHIPPER PHẢN HỒI (NHẬN/TỪ CHỐI) --%>
                                                    <c:when test="${not empty order.driverName and not order.shipperAccepted and order.status ne 'CANCELLED'}">
                                                        <div class="d-flex align-items-center gap-1 justify-content-end">
                                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle py-1 px-2" style="font-size: 0.78rem;" title="Đang chờ tài xế bấm nhận đơn trên ứng dụng">
                                                                <i class="fa-solid fa-hourglass-half fa-spin me-1"></i> Chờ <strong>${order.driverName}</strong> nhận...
                                                            </span>
                                                            <button type="button" class="btn-mo-action-cancel" 
                                                                    data-order-id="${order.id}" 
                                                                    data-customer="<c:out value='${order.customerName}' />" 
                                                                    onclick="handleRejectBtn(this)" 
                                                                    title="Hủy đơn hàng">
                                                                <i class="fa-solid fa-ban"></i>
                                                            </button>
                                                        </div>
                                                    </c:when>

                                                    <%-- BƯỚC 3: SHIPPER ĐÃ ĐỒNG Ý NHẬN ĐƠN -> QUÁN CHẾ BIẾN & BÀN GIAO --%>
                                                    <c:when test="${order.shipperAccepted and (order.status eq 'PENDING' or order.status eq 'CONFIRMED')}">
                                                        <c:if test="${order.status eq 'PENDING'}">
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" class="d-inline">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="CONFIRMED" />
                                                                <button type="submit" class="btn-mo-action btn-mo-action-accept" title="Tài xế đã nhận cuốc! Bắt đầu chế biến món">
                                                                    <i class="fa-solid fa-fire-burner"></i> Chế Biến
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${order.status eq 'CONFIRMED'}">
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" class="d-inline">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <button type="submit" class="btn-mo-action btn-mo-action-ship" title="Món đã xong, bàn giao cho shipper đi giao">
                                                                    <i class="fa-solid fa-truck-fast"></i> Bàn Giao Shipper
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <button type="button" class="btn-mo-action-cancel" 
                                                                data-order-id="${order.id}" 
                                                                data-customer="<c:out value='${order.customerName}' />" 
                                                                onclick="handleRejectBtn(this)" 
                                                                title="Hủy đơn hàng này">
                                                            <i class="fa-solid fa-ban"></i>
                                                        </button>
                                                    </c:when>

                                                    <%-- BƯỚC 4: ĐANG GIAO HÀNG / HOÀN TẤT --%>
                                                    <c:when test="${order.status eq 'SHIPPING'}">
                                                        <c:choose>
                                                            <c:when test="${order.shipperDelivered or order.customerConfirmed}">
                                                                <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" class="d-inline">
                                                                    <input type="hidden" name="action" value="completeOrder" />
                                                                    <input type="hidden" name="orderId" value="${order.id}" />
                                                                    <button type="submit" class="btn-mo-action btn-mo-action-complete" title="Xác nhận hoàn tất đơn hàng">
                                                                        <i class="fa-solid fa-circle-check"></i> Hoàn Tất
                                                                    </button>
                                                                </form>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle py-1 px-2" style="font-size: 0.78rem;">
                                                                    <i class="fa-solid fa-motorcycle me-1"></i> Đang giao hàng
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>

                                                    <c:when test="${order.status eq 'DELIVERED'}">
                                                        <span class="text-success small fw-bold" style="font-size: 0.82rem;">
                                                            <i class="fa-solid fa-circle-check"></i> Hoàn tất
                                                        </span>
                                                    </c:when>

                                                    <c:when test="${order.status eq 'CANCELLED'}">
                                                        <span class="text-muted small" style="font-size: 0.8rem;">Đã hủy</span>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.5rem; margin-bottom: 12px; color: #cbd5e1;">
                                            <i class="fa-solid fa-receipt"></i>
                                        </div>
                                        <div class="fw-bold fs-6 text-dark">Chưa có đơn hàng nào theo bộ lọc đã chọn</div>
                                        <p class="small text-muted mb-0 mt-1">Các đơn hàng mới của khách sẽ hiển thị tại đây để quán tiếp nhận và chế biến.</p>
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

<!-- Modal Gán Tài Xế Nhanh & Thuật Toán Tìm Tuyến Đường Thông Minh -->
<div id="orderDispatchModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box" style="max-width: 580px;">
        <div class="merchant-modal-header">
            <h3 class="merchant-modal-title">
                <i class="fa-solid fa-motorcycle text-primary"></i> Điều Phối &amp; Gán Shipper Cho Đơn Hàng
            </h3>
            <button type="button" class="merchant-modal-close" onclick="closeOrderDispatchModal()">&times;</button>
        </div>

        <!-- 1-Click Thuật Toán Tự Động Gán Shipper Gần Nhất -->
        <div class="p-3" style="background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%); border-bottom: 1px solid #bbf7d0;">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                <div>
                    <span class="badge bg-success text-white mb-1"><i class="fa-solid fa-wand-magic-sparkles"></i> Thuật Toán Đề Xuất Tối Ưu</span>
                    <div style="font-weight: 800; font-size: 0.95rem; color: #166534;">Dò tìm shipper gần quán nhất không đang giao đơn</div>
                </div>
                <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="margin: 0;">
                    <input type="hidden" name="action" value="autoAssignNearest" />
                    <input type="hidden" name="orderId" id="autoAssignOrderId" value="" />
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3 py-2 shadow-sm" style="border-radius: 50px; background: #16a34a; border-color: #16a34a;">
                        <i class="fa-solid fa-bolt me-1"></i> Gán Tự Động 1-Click
                    </button>
                </form>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
            <input type="hidden" name="action" value="assignDriver" />
            <input type="hidden" name="orderId" id="modalOrderId" value="" />

            <div class="merchant-modal-body">
                <div class="p-3 mb-3 rounded-3" style="background: var(--surface-light); border: 1px solid var(--border-color);">
                    <div class="text-muted small">Đơn hàng cần điều phối:</div>
                    <div id="modalCustomerName" class="fw-bold text-primary fs-6 mt-1"></div>
                </div>

                <div class="form-group">
                    <label class="form-label fw-bold mb-2">Hoặc chọn thủ công tài xế trong danh sách (đã xếp theo cự ly gần quán nhất):</label>
                    <select name="driverId" class="form-select form-control" required style="border-radius: 10px; height: 48px; font-size: 0.92rem;">
                        <c:forEach var="d" items="${availableDrivers}" varStatus="dLoop">
                            <c:choose>
                                <c:when test="${d.pendingOrderCount >= 3}">
                                    <option value="${d.id}" disabled style="color: #94a3b8; background-color: #f1f5f9;">
                                        🏍️ ${d.name} (${d.phone}) - [ĐÃ ĐỦ 3 ĐƠN CHỜ NHẬN]
                                    </option>
                                </c:when>
                                <c:otherwise>
                                    <option value="${d.id}" ${dLoop.first ? 'selected' : ''}>
                                        🏍️ ${d.name} (${d.phone}) - Cách quán: ${d.distanceToTarget != null ? String.format('%.1f', d.distanceToTarget) : '0.8'} km ${dLoop.first ? '★ [GẦN QUÁN NHẤT]' : ''} ${d.pendingOrderCount > 0 ? '('.concat(d.pendingOrderCount).concat('/3 chờ)') : '(Sẵn sàng)'}
                                    </option>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeOrderDispatchModal()">Đóng</button>
                <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-1">
                    <i class="fa-solid fa-check"></i> Xác Nhận Giao Cho Tài Xế Đã Chọn
                </button>
            </div>
        </form>
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

    function openOrderDispatchModal(orderId, customerName) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('autoAssignOrderId').value = orderId;
        document.getElementById('modalCustomerName').innerText = '#' + orderId + ' - ' + customerName;
        document.getElementById('orderDispatchModal').style.display = 'flex';
    }

    function closeOrderDispatchModal() {
        document.getElementById('orderDispatchModal').style.display = 'none';
    }

    function acceptAndAutoFindShipper(orderId, customerName, totalAmount) {
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

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
