<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Đơn Hàng - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container section pt-0">
        <!-- Toolbar Bộ Lọc Trạng Thái Đơn Hàng -->
        <div class="admin-header-box mb-4 py-3">
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <span class="text-muted font-weight-bold" style="font-size: 0.9rem;">Lọc trạng thái:</span>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=ALL" class="btn btn-sm ${selectedStatus eq 'ALL' ? 'btn-primary' : 'btn-outline'}">
                    Tất cả
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=PENDING" class="btn btn-sm ${selectedStatus eq 'PENDING' ? 'btn-primary' : 'btn-outline'}">
                    Chờ nhận đơn
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=CONFIRMED" class="btn btn-sm ${selectedStatus eq 'CONFIRMED' ? 'btn-primary' : 'btn-outline'}">
                    Đang chế biến
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=SHIPPING" class="btn btn-sm ${selectedStatus eq 'SHIPPING' ? 'btn-primary' : 'btn-outline'}">
                    Đang giao
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=DELIVERED" class="btn btn-sm ${selectedStatus eq 'DELIVERED' ? 'btn-primary' : 'btn-outline'}">
                    Hoàn tất
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders?status=CANCELLED" class="btn btn-sm ${selectedStatus eq 'CANCELLED' ? 'btn-primary' : 'btn-outline'}">
                    Đã hủy
                </a>
            </div>

            <a href="${pageContext.request.contextPath}/merchant/orders?status=${selectedStatus}" class="btn btn-outline btn-sm">
                <i class="fa-solid fa-rotate"></i> Làm mới dữ liệu
            </a>
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
                            <th>Mã Đơn</th>
                            <th>Thời Gian</th>
                            <th>Khách Hàng &amp; Địa Chỉ</th>
                            <th>Món Đặt Của Quán</th>
                            <th>Tổng Tiền</th>
                            <th>Tài Xế Shipper</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Thao Tác Tiến Trình</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach var="order" items="${orders}">
                                    <tr>
                                        <td><strong>#DH-${order.id}</strong></td>
                                        <td>
                                            <span class="text-muted"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM HH:mm" /></span>
                                        </td>
                                        <td>
                                            <strong>${order.customerName}</strong><br/>
                                            <small class="text-muted"><i class="fa-solid fa-phone"></i> ${order.phone}</small><br/>
                                            <small class="text-muted"><i class="fa-solid fa-location-dot"></i> ${order.address}</small>
                                            <c:if test="${not empty order.note}">
                                                <div class="mt-1" style="font-size: 0.8rem; color: #e67e22;">
                                                    <i class="fa-solid fa-comment-dots"></i> ${order.note}
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.88rem; max-width: 220px;">
                                                <c:forEach var="item" items="${order.items}">
                                                    <div>${item.foodName} &times; <strong>${item.quantity}</strong></div>
                                                </c:forEach>
                                            </div>
                                        </td>
                                        <td>
                                            <strong class="text-primary fs-6"><fmt:formatNumber value="${order.totalAmount}" type="number" /> đ</strong>
                                            <div><span class="badge badge-cod">${order.paymentMethod}</span></div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty order.driverName}">
                                                    <span class="text-success font-weight-bold">
                                                        <i class="fa-solid fa-motorcycle"></i> ${order.driverName}
                                                    </span><br/>
                                                    <small class="text-muted">${order.driverPhone}</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="text-muted">Chưa gán shipper</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn btn-outline-primary btn-sm py-1 px-2" style="font-size: 0.8rem;" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')">
                                                                <i class="fa-solid fa-user-plus"></i> Gán shipper
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
                                                        <c:when test="${order.status eq 'PENDING'}">Chờ nhận đơn</c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}">Đang chế biến</c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}">Đang giao</c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}">Hoàn tất</c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}">Đã hủy</c:when>
                                                        <c:otherwise>${order.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <c:if test="${order.status ne 'CANCELLED'}">
                                                <div class="mt-1" style="font-size: 0.75rem; line-height: 1.3;">
                                                    <c:choose>
                                                        <c:when test="${order.fullyConfirmed}">
                                                            <span style="color: #2ed573; font-weight: 600;">
                                                                <i class="fa-solid fa-circle-check"></i> Khách đã nhận (Tính doanh thu)
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${order.merchantConfirmed and not order.customerConfirmed}">
                                                            <span style="color: #ffa502; font-weight: 500;">
                                                                <i class="fa-solid fa-clock"></i> Đang giao - Chờ khách nhận hàng
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #a4b0be;">
                                                                <i class="fa-solid fa-circle-dot"></i> Chưa gán shipper
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2 flex-wrap justify-content-end">
                                                <c:if test="${order.status eq 'PENDING'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CONFIRMED" />
                                                        <button type="submit" class="btn btn-primary btn-sm">
                                                            <i class="fa-solid fa-check"></i> Nhận Chế Biến
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CONFIRMED'}">
                                                    <c:choose>
                                                        <c:when test="${empty order.driverName}">
                                                            <button type="button" class="btn btn-warning btn-sm" onclick="openOrderDispatchModal(${order.id}, '${order.customerName}')">
                                                                <i class="fa-solid fa-motorcycle"></i> Gán Shipper
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="updateStatus" />
                                                                <input type="hidden" name="orderId" value="${order.id}" />
                                                                <input type="hidden" name="newStatus" value="SHIPPING" />
                                                                <button type="submit" class="btn btn-success btn-sm">
                                                                    <i class="fa-solid fa-truck-fast"></i> Giao Cho Shipper
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>

                                                <c:if test="${order.status eq 'SHIPPING' or (order.status eq 'CONFIRMED' and not empty order.driverName)}">
                                                    <c:if test="${order.merchantConfirmed and not order.customerConfirmed}">
                                                        <span class="badge bg-warning text-dark" style="font-size: 0.78rem;">
                                                            <i class="fa-solid fa-clock"></i> Đợi khách nhận hàng
                                                        </span>
                                                    </c:if>
                                                </c:if>

                                                <c:if test="${order.status eq 'SHIPPING'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="DELIVERED" />
                                                        <button type="submit" class="btn btn-outline btn-sm text-success border-success">
                                                            <i class="fa-solid fa-truck-ramp-box"></i> Đã Giao Xong
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'DELIVERED' and not empty order.driverName}">
                                                    <button type="button" class="btn btn-sm btn-outline-primary" onclick="openPayShipperModal(${order.driverId}, '${order.driverName}', ${order.id})">
                                                        <i class="fa-solid fa-money-bill-wave"></i> Trả Phí Shipper
                                                    </button>
                                                </c:if>

                                                <c:if test="${order.status eq 'PENDING' || order.status eq 'CONFIRMED'}">
                                                    <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                                        <input type="hidden" name="action" value="updateStatus" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="newStatus" value="CANCELLED" />
                                                        <button type="submit" class="btn btn-danger btn-sm" title="Hủy đơn"><i class="fa-solid fa-ban"></i></button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${order.status eq 'CANCELLED'}">
                                                    <span class="text-muted small">Đơn đã hủy</span>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.2rem; margin-bottom: 8px;">🧾</div>
                                        <strong style="color: #666;">Chưa có đơn hàng nào theo bộ lọc đã chọn!</strong>
                                        <p class="small text-muted mb-0 mt-1">Các đơn hàng mới của khách sẽ xuất hiện tại đây để quán tiếp nhận và chế biến.</p>
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
        <div class="modal-header">
            <h3><i class="fa-solid fa-motorcycle text-primary"></i> Gán Tài Xế Giao Hàng</h3>
            <button type="button" class="modal-close-btn" onclick="closeOrderDispatchModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
            <input type="hidden" name="action" value="assignDriver" />
            <input type="hidden" name="orderId" id="modalOrderId" value="" />

            <div class="modal-body">
                <p>Điều phối tài xế giao cho đơn hàng: <strong id="modalCustomerName" class="text-primary fs-5"></strong></p>

                <div class="form-group mt-3">
                    <label class="form-label font-weight-bold">Chọn tài xế khả dụng đang trực tuyến:</label>
                    <select name="driverId" class="form-select" required>
                        <c:forEach var="d" items="${availableDrivers}">
                            <option value="${d.id}">🏍️ ${d.name} (${d.phone}) - [Sẵn sàng]</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeOrderDispatchModal()">Đóng</button>
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Xác Nhận Giao</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Trả Phí Cho Shipper -->
<div id="payShipperModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="modal-header">
            <h3><i class="fa-solid fa-money-bill-wave text-success"></i> Trả Phí Giao Hàng Cho Shipper</h3>
            <button type="button" class="modal-close-btn" onclick="closePayShipperModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
            <input type="hidden" name="action" value="payShipper" />
            <input type="hidden" name="driverId" id="payDriverId" value="" />
            <input type="hidden" name="orderId" id="payOrderId" value="" />

            <div class="modal-body">
                <p>Thanh toán phí cho tài xế: <strong id="payDriverName" class="text-primary fs-5"></strong></p>
                <div id="payOrderInfo" class="mb-3 text-muted small"></div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Số tiền thanh toán (VNĐ): <span class="text-danger">*</span></label>
                    <input type="number" name="amount" class="form-control" value="25000" min="1000" step="1000" required />
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Hình thức chi trả:</label>
                    <select name="paymentMethod" class="form-select">
                        <option value="CASH">Tiền mặt trực tiếp (Cash)</option>
                        <option value="BANK_TRANSFER">Chuyển khoản VietQR</option>
                    </select>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Ghi chú:</label>
                    <input type="text" name="note" class="form-control" placeholder="VD: Phí ship đơn hoàn tất + thưởng thêm..." />
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closePayShipperModal()">Đóng</button>
                <button type="submit" class="btn btn-success"><i class="fa-solid fa-paper-plane"></i> Xác Nhận Thanh Toán</button>
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
