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
                            <c:when test="${order.status eq 'SHIPPING'}">
                                <c:choose>
                                    <c:when test="${order.shipperPickedUp}">
                                        <span class="order-status status-shipping"><i class="fa-solid fa-motorcycle"></i> Đang giao tới bạn</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="order-status status-shipping" style="background: #fff7ed; color: #c2410c;"><i class="fa-solid fa-store"></i> Shipper đang lấy món</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise><span class="order-status status-pending">Đang xử lý</span></c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong><i class="fa-solid fa-location-dot text-danger"></i> Giao đến:</strong> ${order.address}</p>
                            <p><strong><i class="fa-solid fa-route text-primary"></i> Cự ly &amp; Phí giao:</strong> ${order.distanceKm != null ? order.distanceKm : 2.0} km (Cước ship: <fmt:formatNumber value="${order.shippingFee != null ? order.shippingFee : 15000}" pattern="#,###"/> đ)</p>
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
                    
                    <!-- Phần đánh giá đơn hàng & Nút thao tác -->
                    <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mt-3 pt-3 border-top">
                        <div>
                            <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline-secondary btn-sm" style="border-radius: 8px; font-weight: 600;">
                                <i class="fa-solid fa-cart-plus me-1"></i> Đặt lại món
                            </a>
                        </div>
                        <c:if test="${order.status eq 'DELIVERED' or order.customerConfirmed}">
                            <c:choose>
                                <c:when test="${not empty order.review}">
                                    <div class="order-review-done-bar m-0" style="flex: 1; max-width: 550px;">
                                        <div class="review-done-left">
                                            <span class="review-badge-pill">
                                                <i class="fa-solid fa-circle-check"></i> Đã đánh giá
                                            </span>
                                            <span class="review-stars-summary">
                                                <span class="score-item"><i class="fa-solid fa-utensils text-danger"></i> Món: <strong>${order.review.foodRating}★</strong></span>
                                                <span class="score-divider">•</span>
                                                <span class="score-item"><i class="fa-solid fa-motorcycle text-primary"></i> Tài xế: <strong>${order.review.driverRating}★</strong></span>
                                            </span>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/order-review?orderId=${order.id}" class="btn-review-view-detail" title="Xem chi tiết nhận xét">
                                            <span>Xem chi tiết</span>
                                            <i class="fa-solid fa-chevron-right"></i>
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/order-review?orderId=${order.id}" class="btn btn-review-cta" title="Đánh giá món ăn & dịch vụ shipper">
                                        <i class="fa-solid fa-star"></i>
                                        <span>Đánh giá đơn hàng</span>
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
