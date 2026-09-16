<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="${food != null ? food.name : 'Chi tiết món ăn'} - Utee" />
</jsp:include>

<div class="page-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <a href="${pageContext.request.contextPath}/foods">Thực đơn</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>${food != null ? food.name : 'Chi tiết món'}</span>
        </div>
        <h1 class="page-title">${food != null ? food.name : 'Chi Tiết Món Ăn'}</h1>
    </div>
</div>

<div class="container section">
    <c:choose>
        <c:when test="${not empty food}">
            <div class="detail-card-layout">
                <!-- Left: Food Image -->
                <div class="detail-media">
                    <div class="detail-img-container">
                        <img src="${food.image}" alt="${food.name}" class="detail-main-img" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80'">
                        <span class="detail-badge-top"><i class="fa-solid fa-award"></i> Đặc sản tuyển chọn</span>
                    </div>
                    <div class="detail-guarantees">
                        <div class="guarantee-item">
                            <i class="fa-solid fa-temperature-arrow-up text-primary"></i>
                            <span>Giao nóng hổi 100%</span>
                        </div>
                        <div class="guarantee-item">
                            <i class="fa-solid fa-clock text-primary"></i>
                            <span>Thời gian: 20-30 phút</span>
                        </div>
                        <div class="guarantee-item">
                            <i class="fa-solid fa-rotate-left text-primary"></i>
                            <span>Đổi mới nếu nguội hoặc đổ vỡ</span>
                        </div>
                    </div>
                </div>

                <!-- Right: Food Info -->
                <div class="detail-content">
                    <div class="detail-rating-row">
                        <c:choose>
                            <c:when test="${food.reviewCount > 0}">
                                <div class="stars">
                                    <c:forEach begin="1" end="5" var="s">
                                        <c:choose>
                                            <c:when test="${food.rating >= s}">
                                                <i class="fa-solid fa-star"></i>
                                            </c:when>
                                            <c:when test="${food.rating >= s - 0.5}">
                                                <i class="fa-solid fa-star-half-stroke"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-regular fa-star"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <span class="rating-score">${food.rating}/5</span>
                                <span class="rating-count">(${food.reviewCount} lượt đánh giá thực tế)</span>
                            </c:when>
                            <c:otherwise>
                                <div class="stars" style="color: #cbd5e1;">
                                    <i class="fa-regular fa-star"></i>
                                    <i class="fa-regular fa-star"></i>
                                    <i class="fa-regular fa-star"></i>
                                    <i class="fa-regular fa-star"></i>
                                    <i class="fa-regular fa-star"></i>
                                </div>
                                <span class="rating-score" style="color: #64748b; font-size: 0.95rem;">Chưa có đánh giá</span>
                                <span class="rating-count" style="color: #94a3b8;">(Món mới chưa có lượt nhận xét)</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h1 class="detail-food-name">${food.name}</h1>

                    <c:if test="${not empty food.restaurantName or not empty food.categoryName}">
                        <div style="display: flex; flex-wrap: wrap; gap: 15px; margin: 8px 0 16px; font-size: 0.95rem; color: #666;">
                            <c:if test="${not empty food.restaurantName}">
                                <span>
                                    <a href="${pageContext.request.contextPath}/restaurant-detail?id=${food.restaurantId}" style="color: #f05454; font-weight: 600; text-decoration: none;" title="Xem thông tin và toàn bộ đánh giá quán ${food.restaurantName}">
                                        <i class="fa-solid fa-store"></i> <strong>Nhà hàng:</strong> ${food.restaurantName} <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 0.78rem;"></i>
                                    </a>
                                </span>
                            </c:if>
                            <c:if test="${not empty food.categoryName}">
                                <span><i class="fa-solid fa-utensils text-primary"></i> <strong>Danh mục:</strong> ${food.categoryName}</span>
                            </c:if>
                        </div>
                    </c:if>

                    <div class="detail-price-box">
                        <span class="detail-currency">${String.format("%,.0f", food.price)}</span>
                        <span class="currency-symbol">VNĐ</span>
                        <span class="tax-included">(Đã bao gồm VAT)</span>
                    </div>

                    <div class="detail-divider"></div>

                    <div class="detail-description-box">
                        <h4>Mô tả hương vị:</h4>
                        <p class="detail-desc-text">${food.description}</p>
                    </div>

                    <c:set var="isMerchantUser" value="${not empty sessionScope.currentUser and (sessionScope.currentUser.seller or sessionScope.currentUser.role eq 'SELLER')}" />
                    <c:choose>
                        <c:when test="${isMerchantUser}">
                            <!-- Merchant View-Only Mode: Không thể đặt món, bố cục cân đối thông thoáng -->
                            <div class="merchant-view-panel">
                                <div class="merchant-view-notice">
                                    <div class="merchant-notice-icon">
                                        <i class="fa-solid fa-store"></i>
                                    </div>
                                    <div class="merchant-notice-body">
                                        <span class="merchant-notice-badge">
                                            <i class="fa-solid fa-eye"></i> Chế độ xem Đối Tác Quán Ăn
                                        </span>
                                        <p class="merchant-notice-desc">
                                            Bạn đang duyệt món ăn với tư cách Đối Tác Quán Ăn. Chức năng chọn số lượng và thêm vào giỏ hàng chỉ dành riêng cho tài khoản Khách hàng.
                                        </p>
                                    </div>
                                </div>
                                <div class="merchant-view-actions">
                                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-lg">
                                        <i class="fa-solid fa-arrow-left"></i> Xem Thực Đơn Các Quán
                                    </a>
                                    <a href="${pageContext.request.contextPath}/merchant/dashboard" class="btn btn-outline btn-lg">
                                        <i class="fa-solid fa-gauge-high"></i> Về Kênh Quán Ăn
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Customer / Guest Order Form -->
                            <form action="${pageContext.request.contextPath}/cart" method="POST" class="detail-order-form">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="foodId" value="${food.id}">

                                <!-- Quantity Stepper -->
                                <div class="order-option-group">
                                    <label class="option-label">Số lượng khẩu phần:</label>
                                    <div class="stepper-box">
                                        <button type="button" class="stepper-btn" onclick="decreaseQty()">-</button>
                                        <input type="number" id="detailQty" name="quantity" value="1" min="1" max="50" class="stepper-input" readonly>
                                        <button type="button" class="stepper-btn" onclick="increaseQty()">+</button>
                                    </div>
                                </div>

                                <!-- Special Request / Notes -->
                                <div class="order-option-group">
                                    <label for="orderNote" class="option-label">Ghi chú cho nhà bếp (tùy chọn):</label>
                                    <input type="text" id="orderNote" name="note" placeholder="Ví dụ: Ít cay, không hành, để sốt riêng..." class="form-control note-input">
                                </div>

                                <!-- Action Buttons -->
                                <div class="detail-cta-group">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.currentUser and sessionScope.currentUser.shipper and (sessionScope.shipperActive eq true or (not empty sessionScope.driverStatus and sessionScope.driverStatus ne 'OFFLINE'))}">
                                            <button type="button" class="btn btn-secondary btn-lg btn-add-full" onclick="alert('Bạn đang BẬT chế độ Shipper nhận đơn. Vui lòng tắt chế độ Shipper ở thanh menu trên cùng nếu muốn đặt món như khách hàng!');" style="opacity: 0.7; cursor: not-allowed; background: #64748b;">
                                                <i class="fa-solid fa-motorcycle"></i> Đang Bật Chế Độ Shipper
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="submit" class="btn btn-primary btn-lg btn-add-full">
                                                <i class="fa-solid fa-bag-shopping"></i> Thêm Vào Giỏ Hàng
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline btn-lg">
                                        <i class="fa-solid fa-arrow-left"></i> Xem Thực Đơn
                                    </a>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
            </div> <!-- Closes detail-content -->
        </div> <!-- Closes detail-card-layout -->

        <!-- Full Customer Reviews & Comments Section for this Food -->
        <div class="section-food-reviews mt-5">
            <div class="reviews-header-block mb-4">
                <div class="reviews-title-wrap">
                    <span class="sub-heading"><i class="fa-solid fa-comments"></i> Nhận Xét &amp; Đánh Giá</span>
                    <h2 class="section-title">Khách Hàng Nói Gì Về ${food.name}?</h2>
                    <p class="section-desc mb-0">Tất cả nhận xét đều được xác thực từ khách hàng đã đặt món và thưởng thức</p>
                </div>
                <div class="rating-highlight-pill">
                    <i class="fa-solid fa-star text-warning"></i>
                    <strong>${food.rating > 0 ? food.rating : '5.0'} / 5.0</strong>
                    <span class="text-muted">(${food.reviewCount} nhận xét)</span>
                </div>
            </div>

            <c:choose>
                <c:when test="${not empty food.reviews}">
                    <div class="food-reviews-layout">
                        <!-- Left: Sticky Summary Scorecard -->
                        <aside class="reviews-summary-card">
                            <div class="summary-score-box">
                                <div class="big-score-row">
                                    <span class="big-score-num">${food.rating > 0 ? food.rating : '5.0'}</span>
                                    <div class="big-score-meta">
                                        <span class="big-score-max">/ 5.0</span>
                                        <div class="summary-stars">
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                        </div>
                                    </div>
                                </div>
                                <div class="summary-count-tag">
                                    <i class="fa-solid fa-certificate text-primary"></i> Dựa trên ${food.reviewCount} lượt đánh giá
                                </div>
                            </div>

                            <!-- Rating Distribution Breakdown -->
                            <div class="rating-breakdown-list">
                                <div class="breakdown-row">
                                    <span class="breakdown-label">5 <i class="fa-solid fa-star"></i></span>
                                    <div class="breakdown-progress">
                                        <div class="breakdown-fill" style="width: 95%;"></div>
                                    </div>
                                    <span class="breakdown-val">95%</span>
                                </div>
                                <div class="breakdown-row">
                                    <span class="breakdown-label">4 <i class="fa-solid fa-star"></i></span>
                                    <div class="breakdown-progress">
                                        <div class="breakdown-fill" style="width: 5%;"></div>
                                    </div>
                                    <span class="breakdown-val">5%</span>
                                </div>
                                <div class="breakdown-row">
                                    <span class="breakdown-label">3 <i class="fa-solid fa-star"></i></span>
                                    <div class="breakdown-progress">
                                        <div class="breakdown-fill" style="width: 0%;"></div>
                                    </div>
                                    <span class="breakdown-val">0%</span>
                                </div>
                                <div class="breakdown-row">
                                    <span class="breakdown-label">2 <i class="fa-solid fa-star"></i></span>
                                    <div class="breakdown-progress">
                                        <div class="breakdown-fill" style="width: 0%;"></div>
                                    </div>
                                    <span class="breakdown-val">0%</span>
                                </div>
                                <div class="breakdown-row">
                                    <span class="breakdown-label">1 <i class="fa-solid fa-star"></i></span>
                                    <div class="breakdown-progress">
                                        <div class="breakdown-fill" style="width: 0%;"></div>
                                    </div>
                                    <span class="breakdown-val">0%</span>
                                </div>
                            </div>

                            <div class="summary-guarantee-note">
                                <div class="guarantee-note-icon"><i class="fa-solid fa-shield-check"></i></div>
                                <div class="guarantee-note-text">
                                    <strong>Đánh Giá Minh Bạch 100%</strong>
                                    <span>Chỉ tài khoản đã đặt và nhận món thành công mới có thể gửi nhận xét.</span>
                                </div>
                            </div>
                        </aside>

                        <!-- Right: Reviews Stream -->
                        <div class="reviews-stream-col">
                            <!-- Filter pills bar -->
                            <div class="reviews-filter-bar">
                                <span class="filter-chip active"><i class="fa-solid fa-list-check"></i> Tất cả (${food.reviewCount})</span>
                                <span class="filter-chip"><i class="fa-solid fa-star text-warning"></i> 5 sao (${food.reviewCount})</span>
                                <span class="filter-chip"><i class="fa-solid fa-comment-dots"></i> Có lời khen (${food.reviewCount})</span>
                            </div>

                            <div class="full-reviews-list">
                                <c:forEach items="${food.reviews}" var="rev">
                                    <div class="full-review-card">
                                        <div class="full-review-header">
                                            <div class="reviewer-profile">
                                                <c:choose>
                                                    <c:when test="${not empty rev.customerAvatar}">
                                                        <img src="${rev.customerAvatar}" alt="${rev.customerName}" class="reviewer-avatar-img">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="reviewer-avatar-big">${rev.customerInitial}</div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="reviewer-info">
                                                    <div class="reviewer-name-row">
                                                        <strong class="reviewer-name">${rev.customerName}</strong>
                                                        <span class="verified-order-badge"><i class="fa-solid fa-circle-check"></i> Đã thưởng thức</span>
                                                    </div>
                                                    <div class="reviewer-date text-muted">
                                                        <i class="fa-regular fa-clock"></i> ${rev.createdAt}
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="reviewer-rating-box">
                                                <div class="review-stars-group">
                                                    <c:forEach begin="1" end="${rev.foodRating != null ? rev.foodRating : rev.rating}">
                                                        <i class="fa-solid fa-star text-warning"></i>
                                                    </c:forEach>
                                                    <c:forEach begin="${(rev.foodRating != null ? rev.foodRating : rev.rating) + 1}" end="5">
                                                        <i class="fa-regular fa-star text-muted"></i>
                                                    </c:forEach>
                                                </div>
                                                <span class="review-score-tag">${rev.foodRating != null ? rev.foodRating : rev.rating}.0 / 5.0</span>
                                            </div>
                                        </div>

                                        <div class="full-review-content">
                                            <p class="full-review-comment">${not empty rev.foodComment ? rev.foodComment : rev.comment}</p>
                                            <c:if test="${not empty rev.imageUrl}">
                                                <div class="review-photo-attachment">
                                                    <img src="${pageContext.request.contextPath}${rev.imageUrl}" 
                                                         alt="Ảnh chụp thực tế từ khách hàng" 
                                                         class="review-customer-photo" 
                                                         onclick="openReviewImageModal('${pageContext.request.contextPath}${rev.imageUrl}')" 
                                                         title="Nhấn để phóng to ảnh món ăn thực tế" />
                                                    <span class="review-photo-badge">
                                                        <i class="fa-solid fa-camera"></i> Ảnh thực tế
                                                    </span>
                                                </div>
                                            </c:if>
                                        </div>

                                        <div class="full-review-footer">
                                            <span class="review-dish-tag">
                                                <i class="fa-solid fa-bowl-food text-primary"></i> Đã đặt: <strong>${food.name}</strong>
                                            </span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state-card reviews-empty-card">
                        <div class="empty-state-icon"><i class="fa-regular fa-comment-dots"></i></div>
                        <h3>Chưa có nhận xét nào cho món này</h3>
                        <p>Hãy là người đầu tiên đặt món và chia sẻ cảm nhận hương vị cho mọi người nhé!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </c:when>
        <c:otherwise>
            <div class="empty-state-card">
                <div class="empty-state-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                <h2>Không tìm thấy thông tin món ăn!</h2>
                <p>Món ăn này có thể đã hết suất trong ngày hoặc không còn phục vụ.</p>
                <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary mt-3">Quay Lại Thực Đơn</a>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Recently Viewed Section -->
    <c:if test="${not empty recentFoods}">
        <div class="recent-foods-section" style="margin-top: 50px; border-top: 1px dashed #e2e8f0; padding-top: 35px;">
            <div class="section-header" style="margin-bottom: 25px;">
                <span class="sub-heading"><i class="fa-solid fa-clock-rotate-left"></i> Lịch Sử Duyệt Món</span>
                <h2 class="section-title" style="font-size: 1.5rem; margin-top: 5px;">Món Bạn Đã Xem Gần Đây</h2>
            </div>
            <div class="food-grid">
                <c:forEach items="${recentFoods}" var="rFood">
                    <div class="food-card">
                        <div class="food-card-img-wrap">
                            <span class="food-tag">${not empty rFood.categoryName ? rFood.categoryName : 'Gợi ý'}</span>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}">
                                <img src="${rFood.image}" alt="${rFood.name}" class="food-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                            </a>
                        </div>
                        <div class="food-body">
                            <div class="food-meta">
                                <span class="food-distance"><i class="fa-solid fa-store text-primary"></i> ${not empty rFood.restaurantName ? rFood.restaurantName : 'Quán đối tác'}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}" class="food-title-link">
                                <h3 class="food-title" style="font-size: 1.05rem;">${rFood.name}</h3>
                            </a>
                            <div class="food-footer">
                                <span class="food-price">${String.format("%,.0f", rFood.price)} đ</span>
                                <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}" class="btn btn-outline btn-sm">Xem lại</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>
</div>

<!-- Lightbox Modal for Review Photos -->
<div id="reviewPhotoModal" class="review-lightbox-modal" onclick="closeReviewImageModal()">
    <div class="lightbox-modal-content" onclick="event.stopPropagation()">
        <button type="button" class="btn-lightbox-close" onclick="closeReviewImageModal()">&times;</button>
        <img id="lightboxModalImg" src="" alt="Ảnh món ăn thực tế" class="lightbox-full-img">
        <div class="lightbox-caption"><i class="fa-solid fa-camera text-warning me-1"></i> Ảnh chụp thực tế từ khách hàng Utee Express</div>
    </div>
</div>

<script>
function increaseQty() {
    const input = document.getElementById('detailQty');
    if (input) {
        let val = parseInt(input.value) || 1;
        if (val < 50) input.value = val + 1;
    }
}
function decreaseQty() {
    const input = document.getElementById('detailQty');
    if (input) {
        let val = parseInt(input.value) || 1;
        if (val > 1) input.value = val - 1;
    }
}
function openReviewImageModal(imgSrc) {
    const modal = document.getElementById('reviewPhotoModal');
    const modalImg = document.getElementById('lightboxModalImg');
    if (modal && modalImg) {
        modalImg.src = imgSrc;
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}
function closeReviewImageModal() {
    const modal = document.getElementById('reviewPhotoModal');
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeReviewImageModal();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
