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
                        <div class="stars">
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                        </div>
                        <span class="rating-score">4.9/5</span>
                        <span class="rating-count">(Hơn 250 lượt đánh giá tích cực)</span>
                    </div>

                    <h1 class="detail-food-name">${food.name}</h1>

                    <c:if test="${not empty food.restaurantName or not empty food.categoryName}">
                        <div style="display: flex; flex-wrap: wrap; gap: 15px; margin: 8px 0 16px; font-size: 0.95rem; color: #666;">
                            <c:if test="${not empty food.restaurantName}">
                                <span><i class="fa-solid fa-store text-primary"></i> <strong>Nhà hàng:</strong> ${food.restaurantName}</span>
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

                    <!-- Order Form -->
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
                            <button type="submit" class="btn btn-primary btn-lg btn-add-full">
                                <i class="fa-solid fa-bag-shopping"></i> Thêm Vào Giỏ Hàng
                            </button>
                            <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline btn-lg">
                                <i class="fa-solid fa-arrow-left"></i> Xem Thực Đơn
                            </a>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- NEW: Customer Reviews Section -->
            <div class="reviews-section" style="margin-top: 40px; padding: 25px; background: #fff; border-radius: 12px; border: 1px solid #e0e0e0; box-shadow: 0 4px 6px rgba(0,0,0,0.02);">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h3 class="m-0" style="font-size: 1.4rem; font-weight: 700; color: #2c3e50;">
                        <i class="fa-solid fa-comments text-primary" style="margin-right: 8px;"></i> Nhận Xét Của Khách Hàng
                    </h3>
                    <div style="font-size: 1.1rem; font-weight: 600;">
                        <span style="color: #ffc107;"><i class="fa-solid fa-star"></i> 4.9</span>
                        <span class="text-muted" style="font-size: 0.9em; font-weight: 400;">(250+ đánh giá)</span>
                    </div>
                </div>
                
                <div class="review-list">
                    <!-- Dummy Review 1 -->
                    <div class="review-item" style="border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; margin-bottom: 15px;">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="d-flex align-items-center gap-3">
                                <img src="https://i.pravatar.cc/150?u=a042581f4e29026704d" alt="User" style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover; border: 2px solid #e0e0e0;">
                                <div>
                                    <strong style="display: block; color: #333; font-size: 1rem;">Nguyễn Văn A</strong>
                                    <div class="stars" style="color: #ffc107; font-size: 0.85em;">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                    </div>
                                </div>
                            </div>
                            <small class="text-muted"><i class="fa-regular fa-clock"></i> 12/09/2026</small>
                        </div>
                        <p class="mb-0 text-secondary" style="line-height: 1.6; font-size: 0.95rem;">Món ăn rất ngon, thời gian giao hàng siêu nhanh. Đóng gói rất cẩn thận, shipper lịch sự và nhiệt tình. Món vẫn còn nóng hổi khi nhận được. Sẽ ủng hộ quán dài dài!</p>
                    </div>

                    <!-- Dummy Review 2 -->
                    <div class="review-item" style="border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; margin-bottom: 15px;">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="d-flex align-items-center gap-3">
                                <img src="https://i.pravatar.cc/150?u=a042581f4e29026024d" alt="User" style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover; border: 2px solid #e0e0e0;">
                                <div>
                                    <strong style="display: block; color: #333; font-size: 1rem;">Trần Thị Bầu</strong>
                                    <div class="stars" style="color: #ffc107; font-size: 0.85em;">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star"></i>
                                    </div>
                                </div>
                            </div>
                            <small class="text-muted"><i class="fa-regular fa-clock"></i> 10/09/2026</small>
                        </div>
                        <p class="mb-0 text-secondary" style="line-height: 1.6; font-size: 0.95rem;">Hương vị đậm đà, vừa miệng. Tuy nhiên phần nước chấm hơi ít so với khẩu vị của mình. Lần sau đặt sẽ note xin thêm phần sốt. Đánh giá 4 sao về trải nghiệm hương vị!</p>
                    </div>
                </div>
                
                <div class="text-center mt-3">
                    <button class="btn btn-outline-primary" style="border-radius: 20px; font-weight: 500; padding: 8px 24px;">
                        <i class="fa-solid fa-angles-down text-primary"></i> Tải Thêm Đánh Giá
                    </button>
                </div>
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
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
