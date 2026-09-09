<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Đơn Hàng - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
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

        <!-- Bảng Đơn Hàng Của Quán (admin-table-card) -->
        <div class="admin-table-card">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-receipt text-primary"></i> Danh Sách Đơn Đặt Hàng Của Quán</h3>
                    <span class="table-card-sub">Theo dõi và cập nhật trực tiếp tiến trình đơn hàng</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th style="width: 100px;">Mã Đơn</th>
                            <th style="width: 120px;">Thời Gian</th>
                            <th>Khách Hàng &amp; Địa Chỉ</th>
                            <th>Món Đặt Của Quán</th>
                            <th style="width: 140px;">Tổng Tiền</th>
                            <th style="width: 160px;">Tài Xế Shipper</th>
                            <th style="width: 160px;">Trạng Thái</th>
                            <th class="text-end" style="width: 190px;">Thao Tác Tiến Trình</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach var="order" items="${orders}">
                                    <tr>
                                        <td>
                                            <span class="fw-bold text-dark font-monospace" style="font-size: 0.95rem;">#DH-${order.id}</span>
                                        </td>
                                        <td>
                                            <div class="text-dark fw-medium" style="font-size: 0.88rem;">
                                                <fmt:formatDate value="${order.createdAt}" pattern="HH:mm" />
                                            </div>
                                            <div class="text-muted" style="font-size: 0.78rem;">
                                                <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy" />
                                            </div>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark" style="font-size: 0.95rem;">${order.customerName}</div>
                                            <div class="text-muted small mt-1 d-flex align-items-center gap-1">
                                                <i class="fa-solid fa-phone text-primary" style="font-size: 0.75rem;"></i>
                                                <a href="tel:${order.phone}" class="text-muted text-decoration-none">${order.phone}</a>
                                            </div>
                                            <div class="text-muted small mt-1" style="max-width: 240px; line-height: 1.35;">
                                                <i class="fa-solid fa-location-dot text-danger" style="font-size: 0.75rem;"></i> ${order.address}
                                            </div>
                                            <c:if test="${not empty order.note}">
                                                <div class="mt-2 p-1 px-2 rounded-2" style="font-size: 0.78rem; background: #fff8eb; border: 1px solid #ffeaa7; color: #d68910; display: inline-block;">
                                                    <i class="fa-solid fa-comment-dots me-1"></i> ${order.note}
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.88rem; max-width: 220px; line-height: 1.45;">
                                                <c:forEach var="item" items="${order.items}">
                                                    <div class="d-flex justify-content-between align-items-baseline mb-1 pb-1 border-bottom border-light">
                                                        <span class="text-dark">${item.foodName}</span>
                                                        <span class="badge bg-light text-dark fw-bold ms-2">&times; ${item.quantity}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-primary" style="font-size: 1.05rem;">
                                                <fmt:formatNumber value="${order.totalAmount}" type="number" /> đ
                                            </div>
                                            <div class="mt-1">
                                                <span class="badge badge-cod" style="font-size: 0.72rem; text-transform: uppercase;">
                                                    <i class="fa-solid fa-wallet me-1"></i> ${order.paymentMethod}
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty order.driverName}">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div style="width: 32px; height: 32px; border-radius: 50%; background: #e8f8f5; color: #00b894; display: flex; align-items: center; justify-content: center; font-size: 0.85rem;">
                                                            <i class="fa-solid fa-motorcycle"></i>
                                                        </div>
                                                        <div>
                                                            <div class="fw-bold text-dark" style="font-size: 0.88rem;">${order.driverName}</div>
                                                            <div class="text-muted" style="font-size: 0.78rem;">${order.driverPhone}</div>
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="text-muted small">Không gán tài xế</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn btn-outline-primary btn-sm py-1 px-2" style="font-size: 0.8rem; border-radius: 8px;" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')">
                                                                <i class="fa-solid fa-user-plus me-1"></i> Gán shipper
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div>
                                                <span class="badge ${order.status eq 'DELIVERED' ? 'badge-done' : (order.status eq 'SHIPPING' ? 'badge-shipping' : (order.status eq 'PENDING' ? 'badge-pending' : (order.status eq 'CANCELLED' ? 'badge-cod' : 'badge-qr')))}">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}"><i class="fa-solid fa-clock me-1"></i> Chờ nhận đơn</c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}"><i class="fa-solid fa-fire-burner me-1"></i> Đang chế biến</c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}"><i class="fa-solid fa-truck-fast me-1"></i> Đang giao</c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}"><i class="fa-solid fa-circle-check me-1"></i> Hoàn tất</c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}"><i class="fa-solid fa-circle-xmark me-1"></i> Đã hủy</c:when>
                                                        <c:otherwise>${order.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <c:if test="${order.status ne 'CANCELLED'}">
                                                <div class="mt-2" style="font-size: 0.75rem; line-height: 1.35;">
                                                    <c:choose>
                                                        <c:when test="${order.fullyConfirmed}">
                                                            <span class="text-success fw-bold">
                                                                <i class="fa-solid fa-check-double me-1"></i> Khách đã nhận
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${order.merchantConfirmed and not order.customerConfirmed}">
                                                            <span style="color: #f39c12; font-weight: 500;">
                                                                <i class="fa-solid fa-hourglass-half me-1"></i> Chờ khách xác nhận
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">
                                                                <i class="fa-regular fa-circle-dot me-1"></i> Chưa giao shipper
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2 flex-wrap justify-content-end align-items-center">
                                                <c:if test="${order.status eq 'PENDING'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CONFIRMED" />
                                                        <button type="submit" class="btn btn-primary btn-sm d-inline-flex align-items-center gap-1">
                                                            <i class="fa-solid fa-check"></i> Nhận đơn
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CONFIRMED'}">
                                                    <c:choose>
                                                        <c:when test="${empty order.driverName}">
                                                            <button type="button" class="btn btn-warning btn-sm d-inline-flex align-items-center gap-1 text-white" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')">
                                                                <i class="fa-solid fa-motorcycle"></i> Gán Shipper
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <button type="submit" class="btn btn-success btn-sm d-inline-flex align-items-center gap-1">
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
                                                        <button type="submit" class="btn btn-outline btn-sm text-success border-success d-inline-flex align-items-center gap-1">
                                                            <i class="fa-solid fa-circle-check"></i> Đã Giao
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'DELIVERED' and not empty order.driverName}">
                                                    <button type="button" class="btn btn-sm btn-outline-primary d-inline-flex align-items-center gap-1" onclick="openPayShipperModal(${order.driverId}, '${order.driverName}', ${order.id})">
                                                        <i class="fa-solid fa-money-bill-wave"></i> Trả Phí Ship
                                                    </button>
                                                </c:if>

                                                <c:if test="${order.status eq 'PENDING' || order.status eq 'CONFIRMED'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CANCELLED" />
                                                        <button type="submit" class="btn btn-outline-danger btn-sm" title="Hủy đơn hàng">
                                                            <i class="fa-solid fa-ban"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CANCELLED'}">
                                                    <span class="text-muted small">Đã hủy</span>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.5rem; margin-bottom: 12px; color: #bdc3c7;">
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
