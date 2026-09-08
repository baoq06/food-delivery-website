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
                    <c:if test="${order.status eq 'DELIVERED'}">
                        <c:choose>
                            <c:when test="${not empty order.review}">
                                <div class="rating-section" style="background: #fff8e1; border-color: #ffc107;">
                                    <h6 class="text-warning"><i class="fa-solid fa-star"></i> Bạn đã đánh giá ${order.review.rating} sao</h6>
                                    <p class="mb-0 text-muted"><em>"${order.review.comment}"</em></p>
                                </div>
                            </c:when>
                            
                            <c:otherwise>
                                <div class="rating-section">
                                    <h6><i class="fa-solid fa-comment-dots text-primary"></i> Đánh giá trải nghiệm dịch vụ & Tài xế</h6>
                                    <form action="${pageContext.request.contextPath}/client/orders" method="POST">
                                        <input type="hidden" name="action" value="rate">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <input type="hidden" name="driverId" value="${order.driverId != null ? order.driverId : 0}">
                                        
                                        <div class="star-rating">
                                            <input type="radio" id="star5-${order.id}" name="rating" value="5" required/><label for="star5-${order.id}" class="fa-solid fa-star"></label>
                                            <input type="radio" id="star4-${order.id}" name="rating" value="4" /><label for="star4-${order.id}" class="fa-solid fa-star"></label>
                                            <input type="radio" id="star3-${order.id}" name="rating" value="3" /><label for="star3-${order.id}" class="fa-solid fa-star"></label>
                                            <input type="radio" id="star2-${order.id}" name="rating" value="2" /><label for="star2-${order.id}" class="fa-solid fa-star"></label>
                                            <input type="radio" id="star1-${order.id}" name="rating" value="1" /><label for="star1-${order.id}" class="fa-solid fa-star"></label>
                                        </div>
                                        
                                        <div class="d-flex" style="gap: 10px;">
                                            <input type="text" name="comment" class="form-control" placeholder="Ghi chú đánh giá (ví dụ: Shipper rất dễ thương...)" required>
                                            <button type="submit" class="btn btn-warning" style="white-space: nowrap;">Gửi Đánh Giá</button>
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
