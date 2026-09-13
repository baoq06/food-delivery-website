<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Đơn Hàng - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

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
                                                            <button type="button" class="btn-mo-quick-assign" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')" title="Chọn shipper giao đơn này">
                                                                <i class="fa-solid fa-motorcycle"></i> Chọn shipper
                                                            </button>
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
                                                        <c:when test="${order.status eq 'PENDING'}"><i class="fa-solid fa-clock"></i> Chờ nhận đơn</c:when>
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
                                                            <c:when test="${order.merchantCompleted}">
                                                                <span class="badge bg-success text-white py-0 px-1" style="font-size: 0.7rem;"><i class="fa-solid fa-sack-dollar"></i> Đã tính doanh thu</span>
                                                            </c:when>
                                                            <c:when test="${order.readyForMerchantComplete}">
                                                                <span class="badge bg-warning text-dark py-0 px-1" style="font-size: 0.7rem;"><i class="fa-solid fa-bell"></i> Sẵn sàng duyệt</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </td>

                                        <!-- Cột 7: Thao Tác Tiến Trình -->
                                        <td class="col-mo-actions text-end">
                                            <div class="mo-actions-group">
                                                <c:if test="${order.status eq 'PENDING' || order.status eq 'CONFIRMED'}">
                                                    <c:choose>
                                                        <c:when test="${empty order.driverName}">
                                                            <button type="button" class="btn-mo-action btn-mo-action-dispatch" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')" title="Chọn shipper giao đơn này">
                                                                <i class="fa-solid fa-motorcycle"></i> Gán Shipper
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${not order.shipperAccepted}">
                                                            <button type="button" class="btn-mo-action" disabled title="Đang chờ tài xế xác nhận nhận cuốc xe" style="background: #f1f5f9; color: #64748b; border: 1px solid #cbd5e1; cursor: not-allowed;">
                                                                <i class="fa-solid fa-hourglass-half"></i> Chờ Shipper...
                                                            </button>
                                                            <button type="button" class="btn-mo-action" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')" title="Đổi tài xế khác" style="background: #ffffff; color: #475569; border: 1px solid #cbd5e1;">
                                                                <i class="fa-solid fa-repeat"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <button type="submit" class="btn-mo-action btn-mo-action-accept" title="Tài xế đã đồng ý: Bắt đầu nấu và bàn giao món cho shipper">
                                                                    <i class="fa-solid fa-fire-burner"></i> Nấu &amp; Bàn giao Shipper
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>

                                                <c:if test="${order.status eq 'SHIPPING'}">
                                                    <c:choose>
                                                        <c:when test="${order.readyForMerchantComplete}">
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="completeOrder" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <button type="submit" class="btn-mo-action btn-mo-action-delivered shadow-sm" style="animation: pulse 1.5s infinite;" title="Cả Shipper và Khách đã xác nhận. Bấm để duyệt hoàn tất và ghi nhận doanh thu!">
                                                                    <i class="fa-solid fa-circle-check"></i> Duyệt Hoàn Tất Đơn
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn-mo-action" disabled title="Cần cả Shipper báo đã giao VÀ Khách xác nhận đã nhận mới có thể duyệt hoàn tất!" style="background: #f1f5f9; color: #64748b; border: 1px solid #cbd5e1; cursor: not-allowed;">
                                                                <i class="fa-solid fa-hourglass-half"></i> Chờ 2 bên xác nhận
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>

                                                <c:if test="${order.status eq 'DELIVERED'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2" style="font-size: 0.78rem;">
                                                        <i class="fa-solid fa-circle-check me-1"></i> Đã hoàn tất
                                                    </span>
                                                </c:if>

                                                <c:if test="${order.status eq 'PENDING' || order.status eq 'CONFIRMED'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CANCELLED" />
                                                        <button type="submit" class="btn-mo-action-cancel" title="Hủy đơn hàng này">
                                                            <i class="fa-solid fa-ban"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CANCELLED'}">
                                                    <span class="text-muted small" style="font-size: 0.8rem;">Đã hủy</span>
                                                </c:if>
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

<!-- Modal Gán Tài Xế Nhanh Trong Đơn Hàng -->
<div id="orderDispatchModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="merchant-modal-header">
            <h3 class="merchant-modal-title">
                <i class="fa-solid fa-motorcycle text-primary"></i> Gán Tài Xế Giao Hàng
            </h3>
            <button type="button" class="merchant-modal-close" onclick="closeOrderDispatchModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
            <input type="hidden" name="action" value="assignDriver" />
            <input type="hidden" name="orderId" id="modalOrderId" value="" />

            <div class="merchant-modal-body">
                <div class="p-3 mb-3 rounded-3" style="background: var(--surface-light); border: 1px solid var(--border-color);">
                    <div class="text-muted small">Đơn hàng:</div>
                    <div id="modalCustomerName" class="fw-bold text-primary fs-6 mt-1"></div>
                </div>

                <div class="form-group">
                    <label class="form-label fw-bold mb-2">Chọn tài xế đang trực tuyến:</label>
                    <select name="driverId" class="form-select form-control" required style="border-radius: 10px; height: 44px;">
                        <c:forEach var="d" items="${availableDrivers}">
                            <option value="${d.id}">🏍️ ${d.name} (${d.phone}) - [Sẵn sàng nhận]</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeOrderDispatchModal()">Đóng</button>
                <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-1">
                    <i class="fa-solid fa-check"></i> Xác Nhận Giao Cho Tài Xế
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openOrderDispatchModal(orderId, customerName) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('modalCustomerName').innerText = '#' + orderId + ' - ' + customerName;
        document.getElementById('orderDispatchModal').style.display = 'flex';
    }

    function closeOrderDispatchModal() {
        document.getElementById('orderDispatchModal').style.display = 'none';
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
