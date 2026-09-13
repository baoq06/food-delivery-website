<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Danh Sách Tài Xế Shipper - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
        <!-- Toolbar Bộ Lọc Shipper -->
        <div class="merchant-filter-bar">
            <div class="merchant-filter-left">
                <span class="merchant-filter-label">
                    <i class="fa-solid fa-motorcycle text-primary"></i> Trạng thái:
                </span>
                <div class="merchant-filter-group">
                    <a href="${pageContext.request.contextPath}/merchant/shippers?status=ALL" class="merchant-filter-pill ${selectedStatus eq 'ALL' ? 'active' : ''}">
                        <span>Tất cả</span> <span class="badge ms-1">${availableCount + busyCount + offlineCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/shippers?status=AVAILABLE" class="merchant-filter-pill ${selectedStatus eq 'AVAILABLE' ? 'active' : ''}">
                        <span class="dot-pulse"></span> <span>Sẵn sàng</span> <span class="badge ms-1">${availableCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/shippers?status=BUSY" class="merchant-filter-pill ${selectedStatus eq 'BUSY' ? 'active' : ''}">
                        <i class="fa-solid fa-road"></i> <span>Đang giao</span> <span class="badge ms-1">${busyCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/shippers?status=OFFLINE" class="merchant-filter-pill ${selectedStatus eq 'OFFLINE' ? 'active' : ''}">
                        <i class="fa-solid fa-moon"></i> <span>Ngoại tuyến</span> <span class="badge ms-1">${offlineCount}</span>
                    </a>
                </div>
            </div>

            <div class="merchant-filter-right">
                <span class="badge badge-done" style="font-size: 0.82rem; padding: 7px 14px;">
                    <i class="fa-solid fa-motorcycle me-1"></i> ${availableCount} tài xế sẵn sàng
                </span>
            </div>
        </div>

        <!-- Bảng Danh Sách Tài Xế Shipper (admin-table-card) -->
        <div class="admin-table-card">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-motorcycle text-primary"></i> Đội Ngũ Tài Xế Giao Vận Khả Dụng</h3>
                    <span class="table-card-sub">Theo dõi danh sách tài xế trực tuyến và điều phối đơn hàng nhanh chóng</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th style="width: 100px;">Mã Tài Xế</th>
                            <th>Họ &amp; Tên Tài Xế</th>
                            <th>Số Điện Thoại</th>
                            <th>Khu Vực Hoạt Động</th>
                            <th style="width: 160px;">Trạng Thái</th>
                            <th style="width: 140px;">Đánh Giá</th>
                            <th class="text-end" style="width: 200px;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty drivers}">
                                <c:forEach var="driver" items="${drivers}">
                                    <tr>
                                        <td><span class="fw-bold font-monospace text-dark">#TX-${driver.id}</span></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div style="width: 40px; height: 40px; border-radius: 12px; background: #fee2e2; color: #ef4444; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; box-shadow: 0 2px 6px rgba(239, 68, 68, 0.15);">
                                                    <i class="fa-solid fa-helmet-safety"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-bold text-dark" style="font-size: 0.96rem;">${driver.name}</div>
                                                    <small class="text-muted">Đối tác giao nhận Utee</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="fw-medium text-dark">${driver.phone}</span>
                                                <a href="tel:${driver.phone}" class="btn btn-sm btn-outline-success d-inline-flex align-items-center gap-1" style="padding: 2px 10px; border-radius: 20px; font-size: 0.78rem;" title="Gọi điện">
                                                    <i class="fa-solid fa-phone"></i> <span>Gọi</span>
                                                </a>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="text-muted small">
                                                <i class="fa-solid fa-location-dot text-danger me-1"></i> TP. Hồ Chí Minh (Q.1, Q.3, Bình Thạnh)
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${driver.status eq 'AVAILABLE'}">
                                                    <span class="badge badge-done"><span class="dot-pulse"></span> Sẵn Sàng Nhận</span>
                                                </c:when>
                                                <c:when test="${driver.status eq 'BUSY'}">
                                                    <span class="badge badge-shipping"><i class="fa-solid fa-clock me-1"></i> Đang Bận Giao</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-cod"><i class="fa-solid fa-moon me-1"></i> Ngoại Tuyến</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <span class="text-warning fw-bold"><i class="fa-solid fa-star"></i> 4.9</span>
                                                <small class="text-muted">(120+ đơn)</small>
                                            </div>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2 justify-content-end align-items-center">
                                                <c:if test="${driver.status eq 'AVAILABLE'}">
                                                    <c:choose>
                                                        <c:when test="${not empty unassignedOrders}">
                                                            <button type="button" class="btn btn-primary btn-sm d-inline-flex align-items-center gap-1" onclick="openDispatchModal(${driver.id}, '${driver.name}')">
                                                                <i class="fa-solid fa-paper-plane"></i> Giao Đơn
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted small"><i class="fa-solid fa-check text-success me-1"></i> Hết đơn chờ</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.5rem; margin-bottom: 12px; color: #bdc3c7;">
                                            <i class="fa-solid fa-motorcycle"></i>
                                        </div>
                                        <div class="fw-bold fs-6 text-dark mb-1">Hiện tại chưa có tài xế nào theo bộ lọc</div>
                                        <p class="small text-muted mb-0">Danh sách tài xế sẽ tự động cập nhật ngay khi shipper đăng nhập và bật trạng thái nhận đơn.</p>
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

<!-- Modal Điều Phối Đơn Hàng Cho Tài Xế -->
<div id="dispatchModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="merchant-modal-header">
            <h3 class="merchant-modal-title">
                <i class="fa-solid fa-paper-plane text-primary"></i> Điều Phối Đơn Cho Tài Xế
            </h3>
            <button type="button" class="merchant-modal-close" onclick="closeDispatchModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/shippers" method="POST">
            <input type="hidden" name="action" value="assign" />
            <input type="hidden" name="driverId" id="dispatchDriverId" value="" />

            <div class="merchant-modal-body">
                <div class="p-3 mb-3 rounded-3" style="background: var(--surface-light); border: 1px solid var(--border-color);">
                    <div class="text-muted small">Tài xế giao hàng:</div>
                    <div id="dispatchDriverName" class="fw-bold text-primary fs-6 mt-1"></div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Chọn đơn hàng chờ giao của quán: <span class="text-danger">*</span></label>
                    <select name="orderId" class="form-select form-control" required style="border-radius: 10px; height: 44px;">
                        <c:forEach var="ord" items="${unassignedOrders}">
                            <option value="${ord.id}">
                                #DH-${ord.id} - ${ord.customerName} (${ord.phone}) - <fmt:formatNumber value="${ord.totalAmount}" type="number" /> đ
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="alert alert-info d-flex align-items-center gap-2 p-2 rounded-2 mb-0" style="font-size: 0.85rem; background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af;">
                    <i class="fa-solid fa-circle-info"></i>
                    <span>Sau khi gán, tài xế sẽ chuyển sang trạng thái <strong>ĐANG BẬN</strong> và đơn hàng chuyển sang <strong>ĐANG GIAO</strong>.</span>
                </div>
            </div>

            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeDispatchModal()">Đóng</button>
                <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-1">
                    <i class="fa-solid fa-check"></i> Xác Nhận Giao Đơn
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openDispatchModal(driverId, driverName) {
        document.getElementById('dispatchDriverId').value = driverId;
        document.getElementById('dispatchDriverName').innerText = driverName;
        document.getElementById('dispatchModal').style.display = 'flex';
    }

    function closeDispatchModal() {
        document.getElementById('dispatchModal').style.display = 'none';
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
