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
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="text-muted small">Không gán tài xế</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn-mo-quick-assign" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')" title="Gán shipper cho đơn này">
                                                                <i class="fa-solid fa-user-plus"></i> Gán shipper
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
                                                <c:choose>
                                                    <c:when test="${order.fullyConfirmed}">
                                                        <span class="mo-sub-status text-success fw-bold">
                                                            <i class="fa-solid fa-check-double me-1"></i> Khách đã nhận
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${order.merchantConfirmed and not order.customerConfirmed}">
                                                        <span class="mo-sub-status text-warning fw-medium" style="color: #d97706 !important;">
                                                            <i class="fa-solid fa-hourglass-half me-1"></i> Chờ khách xác nhận
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="mo-sub-status text-muted">
                                                            <i class="fa-regular fa-circle-dot me-1"></i> Chưa giao shipper
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                        </td>

                                        <!-- Cột 7: Thao Tác Tiến Trình -->
                                        <td class="col-mo-actions text-end">
                                            <div class="mo-actions-group">
                                                <c:if test="${order.status eq 'PENDING'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CONFIRMED" />
                                                        <button type="submit" class="btn-mo-action btn-mo-action-accept" title="Xác nhận nhận đơn">
                                                            <i class="fa-solid fa-check"></i> Nhận đơn
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CONFIRMED'}">
                                                    <c:choose>
                                                        <c:when test="${empty order.driverName}">
                                                            <button type="button" class="btn-mo-action btn-mo-action-dispatch" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')" title="Gán shipper giao món">
                                                                <i class="fa-solid fa-motorcycle"></i> Gán Shipper
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <button type="submit" class="btn-mo-action btn-mo-action-ship" title="Chuyển món cho tài xế giao đi">
                                                                    <i class="fa-solid fa-truck-fast"></i> Giao Shipper
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>

                                                <c:if test="${order.status eq 'SHIPPING'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="DELIVERED" />
                                                        <button type="submit" class="btn-mo-action btn-mo-action-delivered" title="Xác nhận shipper đã giao món xong">
                                                            <i class="fa-solid fa-circle-check"></i> Đã Giao
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'DELIVERED' and not empty order.driverName}">
                                                    <button type="button" class="btn-mo-action btn-mo-action-pay" onclick="openPayShipperModal(${order.driverId}, '${order.driverName}', ${order.id})" title="Thanh toán tiền cước giao hàng cho shipper">
                                                        <i class="fa-solid fa-money-bill-wave"></i> Trả Phí Ship
                                                    </button>
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

<!-- Modal Trả Phí Cho Shipper -->
<div id="payShipperModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="merchant-modal-header">
            <h3 class="merchant-modal-title">
                <i class="fa-solid fa-money-bill-wave text-success"></i> Trả Phí Cho Shipper
            </h3>
            <button type="button" class="merchant-modal-close" onclick="closePayShipperModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
            <input type="hidden" name="action" value="payShipper" />
            <input type="hidden" name="driverId" id="payDriverId" value="" />
            <input type="hidden" name="orderId" id="payOrderId" value="" />

            <div class="merchant-modal-body">
                <div class="p-3 mb-3 rounded-3" style="background: #f0fdf4; border: 1px solid #bbf7d0;">
                    <div class="text-muted small">Tài xế thụ hưởng:</div>
                    <div id="payDriverName" class="fw-bold text-success fs-6 mt-1"></div>
                    <div id="payOrderInfo" class="text-muted small mt-1"></div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Số tiền thanh toán (VNĐ) <span class="text-danger">*</span></label>
                    <input type="number" name="amount" class="form-control" value="25000" min="1000" step="1000" required style="border-radius: 10px;" />
                </div>

                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Hình thức chi trả</label>
                    <select name="paymentMethod" class="form-select form-control" style="border-radius: 10px; height: 44px;">
                        <option value="CASH">Tiền mặt trực tiếp (Cash)</option>
                        <option value="BANK_TRANSFER">Chuyển khoản VietQR</option>
                    </select>
                </div>

                <div class="form-group mb-2">
                    <label class="form-label fw-bold mb-1">Ghi chú chi trả</label>
                    <input type="text" name="note" class="form-control" placeholder="VD: Phí ship đơn hoàn tất + thưởng..." style="border-radius: 10px;" />
                </div>
            </div>

            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closePayShipperModal()">Đóng</button>
                <button type="submit" class="btn btn-success d-inline-flex align-items-center gap-1">
                    <i class="fa-solid fa-paper-plane"></i> Xác Nhận Chi Trả
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

    function openPayShipperModal(driverId, driverName, orderId) {
        document.getElementById('payDriverId').value = driverId;
        document.getElementById('payDriverName').innerText = driverName;
        document.getElementById('payOrderId').value = orderId || '';
        document.getElementById('payOrderInfo').innerText = orderId ? ('Gắn liền với đơn hàng #' + orderId) : '';
        document.getElementById('payShipperModal').style.display = 'flex';
    }

    function closePayShipperModal() {
        document.getElementById('payShipperModal').style.display = 'none';
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
