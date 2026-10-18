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
    <c:if test="${param.notice eq 'tracking_not_available'}">
        <div class="alert alert-info alert-dismissible fade show" role="alert" style="border-radius: 12px; border-left: 5px solid #0284c7; background: #f0f9ff;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <i class="fa-solid fa-circle-info" style="font-size: 1.4rem; color: #0284c7;"></i>
                <div>
                    <h6 style="margin: 0; font-weight: 700; color: #0369a1;">Chưa thể xem bản đồ trực tiếp</h6>
                    <small style="color: #475569;">Bản đồ Live Map chỉ khả dụng khi Quán đã hoàn tất làm món và Shipper đang trên đường đi giao hàng đến bạn.</small>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success eq 'order_cancelled'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius: 12px;">
            <i class="fa-solid fa-circle-check me-2"></i> Đã hủy đơn hàng thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success eq 'order_confirmed'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius: 12px;">
            <i class="fa-solid fa-circle-check me-2"></i> Bạn đã xác nhận nhận hàng thành công! Cảm ơn bạn đã sử dụng dịch vụ.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error eq 'cancel_failed'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert" style="border-radius: 12px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> Không thể hủy đơn hàng này (đơn đã được giao hoặc không hợp lệ).
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error eq 'confirm_failed'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert" style="border-radius: 12px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> Không thể xác nhận đơn hàng lúc này.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error eq 'shipper_not_delivered'}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert" style="border-radius: 12px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> Tài xế shipper chưa bấm xác nhận đã giao hàng tận nơi. Vui lòng đợi nhận món từ shipper trước khi bấm xác nhận!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
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
                            <div class="d-flex align-items-center gap-2">
                                <h5 style="margin:0;">Mã đơn: <strong class="text-danger">#FZ-${order.id}</strong></h5>
                                <c:if test="${not empty order.restaurantName}">
                                    <span class="badge bg-light text-dark border" style="font-size: 0.85rem; font-weight: 600;">
                                        <i class="fa-solid fa-store me-1 text-danger"></i>${order.restaurantName}
                                    </span>
                                </c:if>
                            </div>
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
                            <!-- Dynamically set progress line based on status -->
                            <c:set var="progressWidth" value="0%" />
                            <c:if test="${order.status eq 'CONFIRMED'}"><c:set var="progressWidth" value="33.33%" /></c:if>
                            <c:if test="${order.status eq 'SHIPPING'}"><c:set var="progressWidth" value="66.67%" /></c:if>
                            <c:if test="${order.status eq 'DELIVERED'}"><c:set var="progressWidth" value="100%" /></c:if>
                            
                            <!-- Timeline Track Line (bounded exactly between Step 1 center and Step 4 center) -->
                            <div style="position: absolute; top: 18px; left: 12.5%; right: 12.5%; height: 4px; background: #e0e0e0; z-index: 1; border-radius: 2px; overflow: hidden;">
                                <c:choose>
                                    <c:when test="${order.status eq 'CANCELLED'}">
                                        <div style="width: 100%; height: 100%; background: #ffcdd2;"></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width: ${progressWidth}; height: 100%; background: #4caf50; border-radius: 2px; transition: width 0.5s ease-in-out;"></div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

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
                                <c:if test="${order.status eq 'SHIPPING'}">
                                    <a href="${pageContext.request.contextPath}/order/tracking?orderId=${order.id}" class="badge bg-danger text-white text-decoration-none mt-1" style="font-size: 0.72rem; padding: 3px 8px; border-radius: 50px; display: inline-flex; align-items: center; gap: 4px; box-shadow: 0 2px 6px rgba(239,68,68,0.35);">
                                        <i class="fa-solid fa-satellite-dish fa-fade"></i> Xem Live Map
                                    </a>
                                </c:if>
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
                            <p>
                                <strong><i class="fa-solid fa-money-bill-wave text-success"></i> Phương thức thanh toán:</strong> 
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'QR'}">
                                        <span class="badge bg-primary" style="font-size: 0.8rem; padding: 4px 8px; border-radius: 6px;">
                                            <i class="fa-solid fa-qrcode me-1"></i> Chuyển khoản VietQR
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary" style="font-size: 0.8rem; padding: 4px 8px; border-radius: 6px;">
                                            <i class="fa-solid fa-hand-holding-dollar me-1"></i> Tiền mặt khi nhận (COD)
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
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
                        <div class="d-flex align-items-center gap-2">
                            <c:if test="${order.paymentMethod eq 'QR' and (order.status eq 'PENDING' or order.status eq 'CONFIRMED')}">
                                <button type="button" class="btn btn-outline-primary btn-sm" style="border-radius: 8px; font-weight: 600;"
                                        onclick="openOrderVietQrModal('${order.id}', '${order.vietQrUrl}', '${order.restaurantBankName}', '${order.restaurantBankCode}', '${order.restaurantBankAccountNo}', '${order.cleanRestaurantBankAccountNo}', '${order.restaurantBankAccountName}', '${order.totalAmount}')">
                                    <i class="fa-solid fa-qrcode me-1"></i> Mã VietQR
                                </button>
                            </c:if>
                            <c:if test="${order.status eq 'PENDING'}">
                                <form action="${pageContext.request.contextPath}/profile" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #FZ-${order.id} không?');" style="display:inline; margin:0;">
                                    <input type="hidden" name="action" value="cancel_order">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <button type="submit" class="btn btn-outline-danger btn-sm" style="border-radius: 8px; font-weight: 600;">
                                        <i class="fa-solid fa-ban me-1"></i> Hủy đơn
                                    </button>
                                </form>
                            </c:if>
                            <c:if test="${not order.customerConfirmed and order.status ne 'CANCELLED' and order.status ne 'PENDING'}">
                                <form action="${pageContext.request.contextPath}/profile" method="POST" style="display:inline; margin:0;">
                                    <input type="hidden" name="action" value="confirm_received">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <button type="submit" class="btn btn-success btn-sm shadow-sm" style="border-radius: 8px; font-weight: 700; background: #10ac84; border-color: #10ac84; color: #fff;" title="Xác nhận bạn đã nhận được món ăn từ shipper">
                                        <i class="fa-solid fa-circle-check me-1"></i> Đã nhận món
                                    </button>
                                </form>
                            </c:if>
                            <c:if test="${order.status eq 'SHIPPING'}">
                                <a href="${pageContext.request.contextPath}/order/tracking?orderId=${order.id}" class="btn btn-primary btn-sm" style="border-radius: 8px; font-weight: 700; background: linear-gradient(135deg, #ef4444, #f97316); border: none; animation: pulseTrack 2s infinite;">
                                    <i class="fa-solid fa-map-location-dot me-1"></i> Theo dõi trực tiếp
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline-secondary btn-sm" style="border-radius: 8px; font-weight: 600;">
                                <i class="fa-solid fa-cart-plus me-1"></i> Đặt lại món
                            </a>
                            <c:if test="${not empty order.restaurantId and order.restaurantId > 0}">
                                <button type="button" class="btn btn-outline-danger btn-sm" style="border-radius: 8px; font-weight: 600;"
                                        data-restaurant-id="${order.restaurantId}"
                                        data-restaurant-name="<c:out value='${order.restaurantName}' escapeXml='true'/>"
                                        data-order-id="${order.id}"
                                        onclick="openChatWithRestaurant(this.dataset.restaurantId, this.dataset.restaurantName, this.dataset.orderId)">
                                    <i class="fa-solid fa-comments me-1"></i> Nhắn tin cho quán
                                </button>
                            </c:if>
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

<!-- Modal xem lại mã VietQR thanh toán cho đơn hàng -->
<div id="orderVietQrModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1050; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
    <div class="modal-content" style="background: #ffffff; border-radius: 16px; padding: 24px; max-width: 440px; width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); position: relative; max-height: 90vh; overflow-y: auto;">
        <button type="button" class="btn-close" style="position: absolute; top: 16px; right: 16px;" onclick="closeOrderVietQrModal()" title="Đóng"></button>
        
        <div class="text-center mb-2">
            <div style="width: 50px; height: 50px; border-radius: 50%; background: rgba(37, 99, 235, 0.1); color: #2563eb; display: inline-flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 8px;">
                <i class="fa-solid fa-qrcode"></i>
            </div>
            <h4 class="fw-bold mb-1" style="font-size: 1.2rem;">Thanh Toán Mã VietQR</h4>
            <p class="text-muted" style="font-size: 0.82rem; margin-bottom: 12px;">Quét mã QR bằng ứng dụng ngân hàng bất kỳ để thanh toán cho quán</p>
        </div>

        <div class="text-center p-2 rounded-3 my-2" style="background: #f8fafc; border: 1px dashed #cbd5e1;">
            <img id="vqrModalImg" src="" alt="VietQR" style="max-width: 210px; width: 100%; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.06); background: #fff; padding: 4px;" />
        </div>

        <!-- Bảng chi tiết STK -->
        <div class="bank-details-card text-start p-2 rounded-2 mt-3" style="background: #f8fafc; border: 1px solid #e2e8f0; font-size: 0.82rem;">
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom">
                <span class="text-muted">Ngân hàng:</span>
                <strong id="vqrModalBank" class="text-dark">Techcombank (TCB)</strong>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom">
                <span class="text-muted">Số tài khoản:</span>
                <div class="d-flex align-items-center gap-1">
                    <strong class="text-danger" id="vqrModalAcc">1907 2878 4280 15</strong>
                    <button type="button" class="btn btn-sm btn-light p-0 px-1 border" style="font-size: 0.72rem;" onclick="copyVqrText('vqrModalAccClean', 'Đã sao chép STK!')" title="Sao chép STK">
                        <i class="fa-regular fa-copy text-primary"></i>
                    </button>
                    <input type="hidden" id="vqrModalAccClean" value="" />
                </div>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom">
                <span class="text-muted">Chủ tài khoản:</span>
                <strong id="vqrModalAccName" class="text-dark" style="text-transform: uppercase;">LE HAI DANG</strong>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom">
                <span class="text-muted">Số tiền:</span>
                <div class="d-flex align-items-center gap-1">
                    <strong class="text-danger" id="vqrModalAmount" style="font-size: 0.95rem;">0 đ</strong>
                    <button type="button" class="btn btn-sm btn-light p-0 px-1 border" style="font-size: 0.72rem;" onclick="copyVqrText('vqrModalAmountRaw', 'Đã sao chép số tiền!')" title="Sao chép số tiền">
                        <i class="fa-regular fa-copy text-primary"></i>
                    </button>
                    <input type="hidden" id="vqrModalAmountRaw" value="" />
                </div>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1">
                <span class="text-muted">Nội dung CK:</span>
                <div class="d-flex align-items-center gap-1">
                    <strong class="text-primary" id="vqrModalMemo" style="font-family: monospace; font-size: 0.95rem;">DH0</strong>
                    <button type="button" class="btn btn-sm btn-light p-0 px-1 border" style="font-size: 0.72rem;" onclick="copyVqrText('vqrModalMemo', 'Đã sao chép nội dung!')" title="Sao chép nội dung">
                        <i class="fa-regular fa-copy text-primary"></i>
                    </button>
                </div>
            </div>
        </div>

        <button type="button" class="btn btn-primary w-100 mt-3" style="font-weight: 700; border-radius: 10px;" onclick="closeOrderVietQrModal()">
            <i class="fa-solid fa-check me-1"></i> Đã Hiểu &amp; Đóng
        </button>
    </div>
</div>

<script>
function openOrderVietQrModal(orderId, vietQrUrl, bankName, bankCode, bankAccNo, bankAccClean, bankAccName, totalAmount) {
    const modal = document.getElementById('orderVietQrModal');
    if (!modal) return;
    
    document.getElementById('vqrModalImg').src = vietQrUrl;
    document.getElementById('vqrModalBank').textContent = (bankName || 'Techcombank') + ' (' + (bankCode || 'TCB') + ')';
    document.getElementById('vqrModalAcc').textContent = bankAccNo || '1907 2878 4280 15';
    document.getElementById('vqrModalAccClean').value = bankAccClean || (bankAccNo ? bankAccNo.replace(/[\s\-\.]/g, '') : '19072878428015');
    document.getElementById('vqrModalAccName').textContent = bankAccName || 'LE HAI DANG';
    
    const parsedAmount = Math.round(parseFloat(totalAmount) || 0);
    document.getElementById('vqrModalAmount').textContent = parsedAmount.toLocaleString('vi-VN') + ' đ';
    document.getElementById('vqrModalAmountRaw').value = parsedAmount;
    document.getElementById('vqrModalMemo').textContent = 'DH' + orderId;
    
    modal.style.display = 'flex';
}

function closeOrderVietQrModal() {
    const modal = document.getElementById('orderVietQrModal');
    if (modal) modal.style.display = 'none';
}

function copyVqrText(elementId, msg) {
    const el = document.getElementById(elementId);
    let val = '';
    if (el) {
        val = el.value !== undefined ? el.value : el.textContent;
    }
    if (!val) return;
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(val).then(function() {
            alert(msg || 'Đã sao chép!');
        }).catch(function() {
            alert('Đã sao chép: ' + val);
        });
    } else {
        alert('Đã sao chép: ' + val);
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
