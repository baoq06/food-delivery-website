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
                    
                    <!-- NEW: Delivery History Timeline -->
                    <div class="order-timeline-container" style="padding: 30px 20px 20px; margin-bottom: 25px; background: #fafafa; border-radius: 8px;">
                        <h6 style="margin-bottom: 20px; font-weight: 600; color: #444;"><i class="fa-solid fa-route text-primary text-opacity-75"></i> Lịch sử và tiến độ đơn hàng</h6>
                        <div class="timeline" style="display: flex; justify-content: space-between; align-items: flex-start; position: relative; max-width: 100%;">
                            <!-- Timeline Background Line -->
                            <div style="position: absolute; top: 18px; left: 12.5%; right: 12.5%; height: 4px; background: #e0e0e0; z-index: 1; border-radius: 2px;"></div>
                            
                            <!-- Dynamically set progress line based on status -->
                            <c:set var="progressWidth" value="0%" />
                            <c:if test="${order.status eq 'CONFIRMED'}"><c:set var="progressWidth" value="33.3%" /></c:if>
                            <c:if test="${order.status eq 'SHIPPING'}"><c:set var="progressWidth" value="66.6%" /></c:if>
                            <c:if test="${order.status eq 'DELIVERED'}"><c:set var="progressWidth" value="100%" /></c:if>
                            
                            <!-- Cancelled overrides -->
                            <c:if test="${order.status eq 'CANCELLED'}">
                                <div style="position: absolute; top: 18px; left: 12.5%; right: 12.5%; height: 4px; background: #ffcdd2; z-index: 2; border-radius: 2px;"></div>
                            </c:if>
                            <c:if test="${order.status ne 'CANCELLED'}">
                                <div style="position: absolute; top: 18px; left: 12.5%; width: ${progressWidth}; height: 4px; background: #4caf50; z-index: 2; border-radius: 2px; transition: width 0.5s ease-in-out;"></div>
                            </c:if>

                            <!-- STEP 1: Pending -->
                            <div class="timeline-step text-center" style="z-index: 3; position: relative; width: 25%;">
                                <div class="step-icon" style="width: 40px; height: 40px; border-radius: 50%; background: ${order.status eq 'CANCELLED' ? '#ef5350' : '#4caf50'}; color: white; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; border: 4px solid #fafafa;">
                                    <i class="fa-solid fa-receipt"></i>
                                </div>
                                <span style="font-size: 0.85em; font-weight: 600; color: #333; display: block;">Đã đặt đơn</span>
                                <small class="text-muted" style="font-size: 0.75em;"><fmt:formatDate value="${order.createdAt}" pattern="HH:mm" /></small>
                            </div>

                            <!-- STEP 2: Confirmed -->
                            <c:set var="step2Active" value="${order.status eq 'CONFIRMED' or order.status eq 'SHIPPING' or order.status eq 'DELIVERED'}" />
                            <div class="timeline-step text-center" style="z-index: 3; position: relative; width: 25%;">
                                <div class="step-icon" style="width: 40px; height: 40px; border-radius: 50%; background: ${step2Active ? '#4caf50' : '#e0e0e0'}; color: ${step2Active ? 'white' : '#9e9e9e'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; border: 4px solid #fafafa;">
                                    <i class="fa-solid fa-fire-burner"></i>
                                </div>
                                <span style="font-size: 0.85em; font-weight: 600; color: ${step2Active ? '#333' : '#9e9e9e'}; display: block;">Đã xác nhận & Chế biến</span>
                            </div>

                            <!-- STEP 3: Shipping -->
                            <c:set var="step3Active" value="${order.status eq 'SHIPPING' or order.status eq 'DELIVERED'}" />
                            <div class="timeline-step text-center" style="z-index: 3; position: relative; width: 25%;">
                                <div class="step-icon" style="width: 40px; height: 40px; border-radius: 50%; background: ${step3Active ? '#4caf50' : '#e0e0e0'}; color: ${step3Active ? 'white' : '#9e9e9e'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; border: 4px solid #fafafa;">
                                    <i class="fa-solid fa-motorcycle"></i>
                                </div>
                                <span style="font-size: 0.85em; font-weight: 600; color: ${step3Active ? '#333' : '#9e9e9e'}; display: block;">Đang giao hàng</span>
                            </div>

                            <!-- STEP 4: Delivered -->
                            <c:set var="step4Active" value="${order.status eq 'DELIVERED'}" />
                            <div class="timeline-step text-center" style="z-index: 3; position: relative; width: 25%;">
                                <div class="step-icon" style="width: 40px; height: 40px; border-radius: 50%; background: ${step4Active ? '#4caf50' : '#e0e0e0'}; color: ${step4Active ? 'white' : '#9e9e9e'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; border: 4px solid #fafafa;">
                                    <i class="fa-solid fa-box-open"></i>
                                </div>
                                <span style="font-size: 0.85em; font-weight: 600; color: ${step4Active ? '#333' : '#9e9e9e'}; display: block;">Hoàn thành</span>
                            </div>
                        </div>
                        <c:if test="${order.status eq 'CANCELLED'}">
                            <div class="text-center mt-3 text-danger" style="font-weight: 600; background: #ffebee; padding: 8px; border-radius: 4px;">
                                <i class="fa-solid fa-circle-exclamation"></i> Đơn hàng này đã bị hủy.
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong><i class="fa-solid fa-location-dot text-danger"></i> Giao đến:</strong> ${order.address}</p>
                            <p><strong><i class="fa-solid fa-route text-primary"></i> Cự ly &amp; Phí giao:</strong> ${order.distanceKm != null ? order.distanceKm : 2.0} km (Cước ship: <fmt:formatNumber value="${order.shippingFee != null ? order.shippingFee : 15000}" pattern="#,###"/> đ)</p>
                            <p><strong><i class="fa-solid fa-money-bill-wave text-success"></i> Phương thức thanh toán:</strong> ${not empty order.paymentMethod ? order.paymentMethod : 'COD'}</p>
                            <c:if test="${order.discountAmount > 0 or not empty order.voucherCode}">
                                <p class="text-success" style="margin-bottom: 6px;">
                                    <strong><i class="fa-solid fa-tag"></i> Giảm giá voucher <c:if test="${not empty order.voucherCode}">(${order.voucherCode})</c:if>:</strong> 
                                    -<fmt:formatNumber value="${order.discountAmount}" pattern="#,###"/> đ
                                </p>
                            </c:if>
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
