<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="${not empty restaurant ? restaurant.name : 'Chi tiết quán ăn'} - Utee" />
</jsp:include>

<div class="page-banner restaurant-detail-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <a href="${pageContext.request.contextPath}/foods">Thực đơn</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>${restaurant != null ? restaurant.name : 'Chi tiết quán'}</span>
        </div>
    </div>
</div>

<div class="container section pt-0">
    <c:choose>
        <c:when test="${not empty restaurant}">
            <!-- Restaurant Profile Hero Card -->
            <div class="restaurant-hero-card">
                <div class="restaurant-hero-cover-wrap">
                    <img src="${not empty restaurant.imageUrl ? restaurant.imageUrl : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1000&auto=format&fit=crop&q=80'}" 
                         alt="${restaurant.name}" class="restaurant-hero-cover" 
                         onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1000&auto=format&fit=crop&q=80'">
                    <div class="restaurant-hero-overlay"></div>
                    <span class="restaurant-hero-status ${'OPEN'.equalsIgnoreCase(restaurant.status) ? 'status-open' : 'status-closed'}">
                        <c:choose>
                            <c:when test="${'OPEN'.equalsIgnoreCase(restaurant.status)}">
                                <i class="fa-solid fa-circle-check"></i> Đang mở cửa đón khách
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-door-closed"></i> Tạm đóng cửa
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <div class="restaurant-hero-info">
                    <div class="restaurant-info-main">
                        <div class="restaurant-badge-tag"><i class="fa-solid fa-store"></i> Quán Ăn Đối Tác Chính Thức</div>
                        <h1 class="restaurant-hero-title">${restaurant.name}</h1>
                        <p class="restaurant-hero-desc">${restaurant.description}</p>
                        
                        <div class="restaurant-meta-list">
                            <div class="meta-item">
                                <i class="fa-solid fa-location-dot text-danger"></i>
                                <span><strong>Địa chỉ:</strong> ${restaurant.address}</span>
                            </div>
                            <div class="meta-item">
                                <i class="fa-solid fa-phone text-primary"></i>
                                <span><strong>Hotline:</strong> ${not empty restaurant.phone ? restaurant.phone : '1900 6868'}</span>
                            </div>
                            <div class="meta-item">
                                <i class="fa-solid fa-clock text-warning"></i>
                                <span><strong>Giờ mở cửa:</strong> ${not empty restaurant.openTime ? restaurant.openTime : '07:00'} - ${not empty restaurant.closeTime ? restaurant.closeTime : '22:00'}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Overall Rating Box (Dựa trên dữ liệu thật) -->
                    <div class="restaurant-rating-summary-box">
                        <div class="summary-score-wrap">
                            <div class="summary-score-num">${restaurant.rating > 0 ? restaurant.rating : '5.0'}</div>
                            <div class="summary-stars">
                                <c:forEach begin="1" end="5" var="s">
                                    <c:choose>
                                        <c:when test="${restaurant.rating >= s}"><i class="fa-solid fa-star"></i></c:when>
                                        <c:when test="${restaurant.rating >= (s - 0.5)}"><i class="fa-solid fa-star-half-stroke"></i></c:when>
                                        <c:otherwise><i class="fa-regular fa-star"></i></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </div>
                            <div class="summary-count-text">
                                <c:choose>
                                    <c:when test="${restaurant.reviewCount > 0}">
                                        <strong>${restaurant.reviewCount}</strong> đánh giá thực tế
                                    </c:when>
                                    <c:otherwise>
                                        Chưa có đánh giá nào
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Star breakdown progress bars -->
                        <div class="rating-breakdown-bars">
                            <c:forEach begin="1" end="5" var="i">
                                <c:set var="starLevel" value="${6 - i}" />
                                <c:set var="starPct" value="${restaurant.getStarPercentage(starLevel)}" />
                                <div class="breakdown-bar-row">
                                    <span class="bar-label">${starLevel} <i class="fa-solid fa-star text-warning"></i></span>
                                    <div class="bar-track">
                                        <div class="bar-fill" style="width: ${starPct}%;"></div>
                                    </div>
                                    <span class="bar-pct">${starPct}%</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Restaurant Gift Voucher Banner (Tặng mã khi ghé quán) -->
            <c:choose>
                <c:when test="${not empty grantedRestaurantVoucher}">
                    <div class="restaurant-gift-banner mt-4 animate__animated animate__fadeInUp">
                        <div class="gift-banner-inner">
                            <div class="gift-banner-icon">
                                <i class="fa-solid fa-gift"></i>
                            </div>
                            <div class="gift-banner-content">
                                <span class="gift-badge"><i class="fa-solid fa-sparkles"></i> Quà Tặng Tri Ân Độc Quyền</span>
                                <h3 class="gift-title">Chào mừng bạn đến với ${restaurant.name}!</h3>
                                <p class="gift-desc">Bạn vừa nhận được mã ưu đãi <strong class="text-danger">${grantedRestaurantVoucher.voucherCode}</strong>: ${grantedRestaurantVoucher.title}. Mã đã được lưu tự động vào <strong>Kho Voucher</strong> của bạn để áp dụng khi đặt món tại quán!</p>
                            </div>
                            <div class="gift-banner-action">
                                <div class="gift-code-badge">
                                    <i class="fa-solid fa-ticket"></i>
                                    <span>${grantedRestaurantVoucher.voucherCode}</span>
                                </div>
                                <span class="badge-saved-indicator"><i class="fa-solid fa-circle-check text-success"></i> Đã trong kho</span>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:when test="${not empty guestRestaurantPromoCode}">
                    <div class="restaurant-gift-banner guest-mode mt-4">
                        <div class="gift-banner-inner">
                            <div class="gift-banner-icon">
                                <i class="fa-solid fa-store"></i>
                            </div>
                            <div class="gift-banner-content">
                                <span class="gift-badge"><i class="fa-solid fa-tags"></i> Ưu Đãi Quán Ăn</span>
                                <h3 class="gift-title">Nhận ngay 20.000 đ khi đặt món tại ${restaurant.name}!</h3>
                                <p class="gift-desc">Đăng nhập tài khoản Utee để tự động nhận mã giảm giá và lưu vào Kho Voucher của bạn.</p>
                            </div>
                            <div class="gift-banner-action">
                                <a href="${pageContext.request.contextPath}/login?redirect=restaurant-detail?id=${restaurant.id}" class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-arrow-right-to-bracket me-1"></i> Đăng nhập nhận mã
                                </a>
                            </div>
                        </div>
                    </div>
                </c:when>
            </c:choose>

            <!-- Restaurant Menu Items -->
            <div class="section-restaurant-menu mt-5">
                <div class="section-header-flex align-items-center mb-3">
                    <div>
                        <span class="sub-heading"><i class="fa-solid fa-utensils"></i> Thực Đơn Phục Vụ</span>
                        <h2 class="section-title">Các Món Ăn Của ${restaurant.name}</h2>
                    </div>
                    <span class="badge-count">${not empty foods ? foods.size() : 0} món</span>
                </div>

                <c:choose>
                    <c:when test="${not empty foods}">
                        <div class="food-grid">
                            <c:forEach items="${foods}" var="food">
                                <div class="food-card">
                                    <div class="food-card-img-wrap">
                                        <span class="food-tag">${not empty food.categoryName ? food.categoryName : 'Món ngon'}</span>
                                        <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}">
                                            <img src="${food.image}" alt="${food.name}" class="food-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                                        </a>
                                        <div class="food-time-badge">
                                            <i class="fa-solid fa-clock"></i> 20-25 phút
                                        </div>
                                    </div>
                                    <div class="food-body">
                                        <div class="food-meta">
                                            <c:choose>
                                                <c:when test="${food.reviewCount > 0}">
                                                    <span class="food-rating"><i class="fa-solid fa-star"></i> ${food.rating} (${food.reviewCount})</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="food-rating text-muted"><i class="fa-regular fa-star"></i> Chưa có đánh giá</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}" class="food-title-link">
                                            <h3 class="food-title">${food.name}</h3>
                                        </a>
                                        <p class="food-desc">${food.description}</p>
                                        <div class="food-footer">
                                            <div class="price-box">
                                                <span class="price-label">Giá chỉ</span>
                                                <span class="food-price">${String.format("%,.0f", food.price)} đ</span>
                                            </div>
                                            <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="foodId" value="${food.id}">
                                                <input type="hidden" name="quantity" value="1">
                                                <button type="submit" class="btn-add-cart" title="Thêm vào giỏ hàng">
                                                    <i class="fa-solid fa-cart-plus"></i>
                                                    <span>Đặt món</span>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-card">
                            <div class="empty-state-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                            <h3>Quán đang cập nhật thêm thực đơn!</h3>
                            <p>Vui lòng quay lại sau ít phút.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Full Customer Reviews & Comments Section for the Store -->
            <div class="section-restaurant-reviews mt-5">
                <div class="section-header-flex align-items-center mb-4">
                    <div>
                        <span class="sub-heading"><i class="fa-solid fa-comments"></i> Phản Hồi Từ Khách Hàng</span>
                        <h2 class="section-title">Đánh Giá &amp; Bình Luận Về Quán</h2>
                        <p class="section-desc mb-0">Tất cả nhận xét đều được thu thập từ các đơn hàng đã hoàn tất giao tận tay thực khách</p>
                    </div>
                    <div class="rating-highlight-pill">
                        <i class="fa-solid fa-shield-check text-success"></i>
                        <span>100% Đánh giá thật đã xác thực</span>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not empty restaurant.reviews}">
                        <div class="full-reviews-list">
                            <c:forEach items="${restaurant.reviews}" var="r">
                                <div class="full-review-card">
                                    <div class="full-review-header">
                                        <div class="reviewer-profile">
                                            <div class="reviewer-avatar-big">${r.customerInitial}</div>
                                            <div class="reviewer-info">
                                                <div class="reviewer-name-row">
                                                    <strong class="reviewer-name">${r.customerName}</strong>
                                                    <span class="verified-order-badge"><i class="fa-solid fa-circle-check"></i> Đã mua hàng</span>
                                                </div>
                                                <div class="reviewer-date text-muted">
                                                    <i class="fa-regular fa-clock"></i> ${r.createdAt}
                                                </div>
                                            </div>
                                        </div>

                                        <div class="reviewer-rating-box">
                                            <div class="review-stars-group">
                                                <c:forEach begin="1" end="${r.rating}">
                                                    <i class="fa-solid fa-star text-warning"></i>
                                                </c:forEach>
                                                <c:forEach begin="${r.rating + 1}" end="5">
                                                    <i class="fa-regular fa-star text-muted"></i>
                                                </c:forEach>
                                            </div>
                                            <span class="review-score-tag">${r.rating}.0 / 5.0</span>
                                        </div>
                                    </div>

                                    <div class="full-review-content">
                                        <p class="full-review-comment">${r.comment}</p>
                                    </div>

                                    <c:if test="${not empty r.orderedFoods}">
                                        <div class="full-review-footer">
                                            <span class="ordered-foods-tag">
                                                <i class="fa-solid fa-bag-shopping text-primary"></i> 
                                                <strong>Món đã đặt:</strong> ${r.orderedFoods}
                                            </span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-card">
                            <div class="empty-state-icon"><i class="fa-regular fa-comment-dots"></i></div>
                            <h3>Quán chưa có lượt đánh giá nào</h3>
                            <p>Hãy là người đầu tiên đặt món và để lại nhận xét cho quán nhé!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state-card">
                <div class="empty-state-icon"><i class="fa-solid fa-store-slash"></i></div>
                <h2>Không tìm thấy thông tin quán ăn!</h2>
                <p>Quán ăn này có thể đã ngừng hoạt động hoặc đường dẫn không chính xác.</p>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-3">Quay Lại Trang Chủ</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
