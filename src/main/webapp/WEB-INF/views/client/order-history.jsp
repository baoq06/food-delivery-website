<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Đơn hàng của tôi" />
</jsp:include>

<style>
    .order-history-cont { margin-top: 40px; margin-bottom: 60px; min-height: 50vh; }
    .order-card { background: #fff; border-radius: 12px; border: 1px solid #e0e0e0; margin-bottom: 24px; padding: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.03); }
    .order-card-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; margin-bottom: 15px; }
    .order-status { font-weight: 700; padding: 5px 12px; border-radius: 50px; font-size: 0.9em; }
    .status-confirmed, .status-pending { background: #e0f7fa; color: #00838f; }
    .status-shipping { background: #fff3e0; color: #e65100; }
    .status-delivered { background: #e8f5e9; color: #2e7d32; }
    .status-cancelled { background: #ffebee; color: #c62828; }
    
    .rating-section { background: #f9f9f9; padding: 15px; border-radius: 8px; margin-top: 15px; border: 1px dashed #ccc; }
    
    .star-rating {
        direction: rtl; display: inline-block; padding: 5px 0;
    }
    .star-rating input[type="radio"] { display: none; }
    .star-rating label {
        color: #ddd; font-size: 2rem; padding: 0; cursor: pointer; transition: all 0.2s;
    }
    .star-rating label:hover,
    .star-rating label:hover ~ label,
    .star-rating input[type="radio"]:checked ~ label {
        color: #ffc107;
    }
</style>

<div class="container order-history-cont">
    <h2 class="mb-4"><i class="fa-solid fa-receipt text-primary"></i> Lịch Sử Đơn Hàng</h2>
    
    <c:choose>
        <c:when test="${empty orders}">
            <div class="text-center" style="padding: 50px 0;">
                <img src="https://cdn-icons-png.flaticon.com/512/7488/7488079.png" style="width: 150px; opacity: 0.5;" alt="No orders" />
                <h4 class="mt-4 text-muted">Bạn chưa có đơn hàng nào!</h4>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-2">Bắt đầu đặt món ngay</a>
            </div>
        </c:when>
        
        <c:otherwise>
            <c:forEach var="order" items="${orders}">
                <div class="order-card">
                    <div class="order-card-header">
                        <div>
                            <h5 style="margin:0;">Mã đơn: <strong class="text-danger">#FZ-${order.id}</strong></h5>
                            <small class="text-muted"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm:ss" /></small>
                        </div>
                        
                        <c:choose>
                            <c:when test="${order.status eq 'DELIVERED'}"><span class="order-status status-delivered"><i class="fa-solid fa-check"></i> Hoàn thành</span></c:when>
                            <c:when test="${order.status eq 'CANCELLED'}"><span class="order-status status-cancelled"><i class="fa-solid fa-xmark"></i> Đã hủy</span></c:when>
                            <c:when test="${order.status eq 'SHIPPING'}"><span class="order-status status-shipping"><i class="fa-solid fa-motorcycle"></i> Đang giao hàng</span></c:when>
                            <c:otherwise><span class="order-status status-pending">Đang xử lý</span></c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong><i class="fa-solid fa-location-dot text-danger"></i> Giao đến:</strong> ${order.address}</p>
                            <p><strong><i class="fa-solid fa-money-bill-wave text-success"></i> Phương thức thanh toán:</strong> COD</p>
                            <h5 class="mt-3">Tổng cộng: <strong class="text-danger"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> đ</strong></h5>
                        </div>
                        
                        <div class="col-md-6">
                            <c:if test="${not empty order.driverId}">
                                <div style="background: #e3f2fd; padding: 12px; border-radius: 8px;">
                                    <h6 style="color: #1976d2; margin-bottom: 5px;"><i class="fa-solid fa-motorcycle"></i> Thông tin Tài xế Utee</h6>
                                    <p style="margin:0;"><strong>Tên:</strong> ${order.driverName}</p>
                                    <p style="margin:0;"><strong>SĐT:</strong> ${order.driverPhone}</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Phần đánh giá đơn hàng -->
                    <c:if test="${order.status eq 'DELIVERED' or order.customerConfirmed}">
                        <c:choose>
                            <c:when test="${not empty order.review}">
                                <div class="rating-section" style="background: #fffdf5; border-color: #ffe082; padding: 16px; border-radius: 12px;">
                                    <h6 class="text-warning font-weight-bold mb-2"><i class="fa-solid fa-star"></i> Đánh giá của bạn cho đơn hàng này:</h6>
                                    <div class="row g-2" style="font-size: 0.9rem;">
                                        <div class="col-md-6">
                                            <div style="background: #fff; padding: 10px 14px; border-radius: 8px; border: 1px solid #fef3c7;">
                                                <div style="font-weight: 700; color: #d97706; margin-bottom: 2px;">
                                                    <i class="fa-solid fa-utensils me-1"></i> Món ăn &amp; Quán: ⭐ ${order.review.foodRating}/5 sao
                                                </div>
                                                <div style="color: #475569; font-style: italic;">"${order.review.foodComment}"</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div style="background: #fff; padding: 10px 14px; border-radius: 8px; border: 1px solid #fef3c7;">
                                                <div style="font-weight: 700; color: #d97706; margin-bottom: 2px;">
                                                    <i class="fa-solid fa-motorcycle me-1"></i> Tài xế Shipper: ⭐ ${order.review.driverRating}/5 sao
                                                </div>
                                                <div style="color: #475569; font-style: italic;">"${order.review.driverComment}"</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            
                            <c:otherwise>
                                <div class="rating-section" style="background: #f8fafc; border-color: #cbd5e1; padding: 16px; border-radius: 12px;">
                                    <h6 class="text-primary mb-3"><i class="fa-solid fa-comment-dots"></i> Đánh giá trải nghiệm Món ăn &amp; Tài xế Shipper</h6>
                                    <form action="${pageContext.request.contextPath}/client/orders" method="POST">
                                        <input type="hidden" name="action" value="rate">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <input type="hidden" name="driverId" value="${order.driverId != null ? order.driverId : 0}">
                                        
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div style="background: #fff; padding: 12px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                                    <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.85rem;">
                                                        <i class="fa-solid fa-utensils text-danger me-1"></i> 1. Đánh giá món ăn:
                                                    </label>
                                                    <select name="foodRating" class="form-select form-select-sm mb-2" style="font-weight: 700; color: #b45309;" required>
                                                        <option value="5" selected>⭐⭐⭐⭐⭐ (5 sao)</option>
                                                        <option value="4">⭐⭐⭐⭐ (4 sao)</option>
                                                        <option value="3">⭐⭐⭐ (3 sao)</option>
                                                        <option value="2">⭐⭐ (2 sao)</option>
                                                        <option value="1">⭐ (1 sao)</option>
                                                    </select>
                                                    <input type="text" name="foodComment" class="form-control form-control-sm" placeholder="Ghi chú về món ăn..." required>
                                                </div>
                                            </div>

                                            <div class="col-md-6">
                                                <div style="background: #fff; padding: 12px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                                    <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.85rem;">
                                                        <i class="fa-solid fa-motorcycle text-primary me-1"></i> 2. Đánh giá shipper:
                                                    </label>
                                                    <select name="driverRating" class="form-select form-select-sm mb-2" style="font-weight: 700; color: #b45309;" required>
                                                        <option value="5" selected>⭐⭐⭐⭐⭐ (5 sao)</option>
                                                        <option value="4">⭐⭐⭐⭐ (4 sao)</option>
                                                        <option value="3">⭐⭐⭐ (3 sao)</option>
                                                        <option value="2">⭐⭐ (2 sao)</option>
                                                        <option value="1">⭐ (1 sao)</option>
                                                    </select>
                                                    <input type="text" name="driverComment" class="form-control form-control-sm" placeholder="Ghi chú về shipper..." required>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="text-end mt-3">
                                            <button type="submit" class="btn btn-warning px-4" style="border-radius: 50px; font-weight: 700;">Gửi Đánh Giá</button>
                                        </div>
                                    </form>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
