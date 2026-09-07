<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Kênh Tài Xế - Bảng tin" />
</jsp:include>

<style>
    .dashboard-layout { display: flex; gap: 24px; flex-wrap: wrap; }
    .dashboard-sidebar { flex: 0 0 280px; }
    .dashboard-main { flex: 1; min-width: 0; }
    .card { background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 24px; }
    .card-header { padding: 16px 20px; font-weight: 700; font-size: 1.1rem; }
    .bg-warning { background-color: #ffc107; color: #000; }
    .card-body { padding: 20px; }
    .list-group { display: flex; flex-direction: column; }
    .list-group-item { padding: 12px 20px; border-bottom: 1px solid #eee; text-decoration: none; color: #333; display: block; }
    .list-group-item.active { background-color: #fff3cd; color: #856404; font-weight: bold; border-left: 4px solid #ffc107; }
    .list-group-item:hover:not(.active) { background-color: #f8f9fa; }
    .status-panel { padding: 20px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; }
</style>

<div class="container mt-4 mb-5" style="margin-top: 40px; margin-bottom: 60px;">
    <div class="dashboard-layout">
        <!-- Sidebar Tài Xế -->
        <div class="dashboard-sidebar">
            <div class="card">
                <div class="card-header bg-warning text-center">
                    <h5 class="mb-0" style="margin: 0;"><i class="fa-solid fa-motorcycle"></i> Đối Tác Giao Hàng</h5>
                </div>
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/shipper/dashboard" class="list-group-item active">
                        <i class="fa-solid fa-house me-2"></i> Bảng điều khiển
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history" class="list-group-item">
                        <i class="fa-solid fa-clock-rotate-left me-2"></i> Lịch sử giao hàng
                    </a>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="dashboard-main">
            <div class="card">
                <div class="card-body">
                    <h2 class="mb-4" style="margin-bottom: 20px;">Chào mừng tài xế, <span class="text-primary">${sessionScope.currentUser.fullName}</span>!</h2>

                    <!-- Driver Status Panel -->
                    <div class="status-panel" style="background-color: #fff9e6; border: 1px solid #ffeeba;">
                        <div>
                            <h3 class="mb-2" style="font-size: 1.2rem; margin-bottom: 8px;">Trạng thái nhận đơn</h3>
                            <c:choose>
                                <c:when test="${not empty driver and driver.status eq 'AVAILABLE'}">
                                    <p class="text-success" style="font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-check"></i> <strong>ĐANG BẬT ỨNG DỤNG (TRỰC TUYẾN)</strong></p>
                                    <p class="text-muted" style="margin: 0;">Hệ thống sẽ tự động ghép đơn hàng cho bạn ở khu vực lân cận.</p>
                                </c:when>
                                <c:when test="${not empty driver and driver.status eq 'BUSY'}">
                                    <p class="text-danger" style="font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-play"></i> <strong>ĐANG GIAO ĐƠN</strong></p>
                                    <p class="text-muted" style="margin: 0;">Bạn đang trong quá trình thực hiện giao đơn hàng. Vui lòng hoàn tất đơn hiện tại.</p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-secondary" style="color: #6c757d; font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-minus"></i> <strong>ĐANG TẮT ỨNG DỤNG (NGỌAI TUYẾN)</strong></p>
                                    <p class="text-muted" style="margin: 0;">Bạn đang không nhận đơn. Hiện tại bạn có thể đặt đồ ăn như khách hàng!</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="text-end">
                            <c:if test="${driver.status ne 'BUSY'}">
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <button type="submit" class="btn ${driver.status eq 'AVAILABLE' ? 'btn-danger' : 'btn-primary'} btn-lg" style="border-radius: 50px; font-weight: 600; padding: 12px 30px; font-size: 1.1rem;">
                                        <i class="fa-solid fa-power-off me-1"></i> ${driver.status eq 'AVAILABLE' ? 'TẮT ỨNG DỤNG' : 'BẬT MÁY NHẬN ĐƠN'}
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>

                    <!-- Cuốc gần đây (Mô phỏng chức năng) -->
                    <c:if test="${driver.status eq 'AVAILABLE'}">
                        <h4 style="margin-top: 30px; margin-bottom: 16px;">Đơn hàng quanh đây (Đang chờ nhận)</h4>
                        <div style="background: #e0f7fa; color: #006064; padding: 20px; text-align: center; border-radius: 12px; border: 1px dashed #b2ebf2;">
                            <i class="fa-solid fa-spinner fa-spin" style="margin-right: 8px;"></i>
                            Đang quét các đơn hàng mới nhất khu vực của bạn...
                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
