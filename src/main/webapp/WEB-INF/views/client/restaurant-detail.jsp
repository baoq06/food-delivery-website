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
                    <c:set var="rawBanner" value="${not empty restaurant.imageUrl ? restaurant.imageUrl : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1000&auto=format&fit=crop&q=80'}" />
                    <c:set var="finalBannerUrl" value="${rawBanner.startsWith('http') || rawBanner.startsWith('/') ? (rawBanner.startsWith('/') ? pageContext.request.contextPath.concat(rawBanner) : rawBanner) : pageContext.request.contextPath.concat('/').concat(rawBanner)}" />
                    <img src="${finalBannerUrl}" 
                         alt="${restaurant.name}" class="restaurant-hero-cover" 
                         onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1000&auto=format&fit=crop&q=80'">
                    <div class="restaurant-hero-overlay"></div>
                    <span class="restaurant-hero-status ${'OPEN'.equalsIgnoreCase(restaurant.status) ? 'status-open' : 'status-closed'}" style="${'BANNED'.equalsIgnoreCase(restaurant.status) ? 'background: #fee2e2; color: #991b1b; border: 1px solid #fecaca;' : ''}">
                        <c:choose>
                            <c:when test="${'BANNED'.equalsIgnoreCase(restaurant.status)}">
                                <i class="fa-solid fa-ban"></i> Quán đang bị tạm khóa
                            </c:when>
                            <c:when test="${'OPEN'.equalsIgnoreCase(restaurant.status)}">
                                <i class="fa-solid fa-circle-check"></i> Đang mở cửa đón khách
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-door-closed"></i> Tạm đóng cửa
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <c:if test="${'BANNED'.equalsIgnoreCase(restaurant.status)}">
                    <div style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 14px 20px; border-radius: 12px; margin: 16px 24px 0 24px; font-weight: 600; display: flex; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.25rem; color: #dc2626;"></i>
                        <span>Quán ăn này hiện đang bị tạm khóa hoạt động bởi Quản trị viên Utee. Bạn không thể đặt món từ quán tại thời điểm này.</span>
                    </div>
                </c:if>

                <div class="restaurant-hero-info">
                    <div class="restaurant-info-main">
                        <div class="restaurant-hero-brand-header">
                            <c:set var="rawLogo" value="${not empty restaurant.logoUrl ? restaurant.logoUrl : ''}" />
                            <c:if test="${not empty rawLogo}">
                                <c:set var="finalLogoUrl" value="${rawLogo.startsWith('http') || rawLogo.startsWith('/') ? (rawLogo.startsWith('/') ? pageContext.request.contextPath.concat(rawLogo) : rawLogo) : pageContext.request.contextPath.concat('/').concat(rawLogo)}" />
                                <div class="restaurant-hero-logo-wrap">
                                    <img src="${finalLogoUrl}" alt="${restaurant.name}" class="restaurant-hero-logo-img" onerror="this.parentElement.style.display='none';" />
                                </div>
                            </c:if>
                            <div class="restaurant-hero-title-box">
                                <div class="restaurant-badge-tag"><i class="fa-solid fa-circle-check"></i> Quán Ăn Đối Tác Chính Thức</div>
                                <h1 class="restaurant-hero-title">${restaurant.name}</h1>
                            </div>
                        </div>

                        <p class="restaurant-hero-desc">${restaurant.description}</p>
                        
                        <div class="restaurant-meta-list">
                            <div class="meta-item">
                                <div class="meta-icon-circle text-danger"><i class="fa-solid fa-location-dot"></i></div>
                                <span><strong>Địa chỉ:</strong> ${restaurant.address}</span>
                            </div>
                            <div class="meta-item">
                                <div class="meta-icon-circle text-primary"><i class="fa-solid fa-phone"></i></div>
                                <span><strong>Hotline:</strong> <a href="tel:${restaurant.phone}" style="color: inherit; text-decoration: none; font-weight: 600;">${not empty restaurant.phone ? restaurant.phone : '1900 6868'}</a></span>
                            </div>
                            <div class="meta-item">
                                <div class="meta-icon-circle text-warning"><i class="fa-solid fa-clock"></i></div>
                                <span><strong>Giờ mở cửa:</strong> ${not empty restaurant.openTime ? restaurant.openTime : '07:00'} - ${not empty restaurant.closeTime ? restaurant.closeTime : '22:00'}</span>
                            </div>
                        </div>

                        <!-- Chat & Share Action Buttons -->
                        <div class="restaurant-hero-actions mt-4">
                            <button type="button" class="btn btn-primary d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill font-weight-bold btn-chat-rest" 
                                    data-restaurant-id="${restaurant.id}"
                                    data-restaurant-name="<c:out value='${restaurant.name}' escapeXml='true'/>"
                                    onclick="openChatWithRestaurant(this.dataset.restaurantId, this.dataset.restaurantName)">
                                <i class="fa-solid fa-comments"></i>
                                <span>Nhắn tin với quán</span>
                            </button>
                            <button type="button" class="btn btn-outline-secondary d-inline-flex align-items-center gap-2 px-3 py-2 rounded-pill font-weight-bold" 
                                    onclick="navigator.clipboard.writeText(window.location.href); alert('Đã sao chép liên kết quán ăn!');"
                                    title="Chia sẻ quán">
                                <i class="fa-solid fa-share-nodes"></i>
                                <span>Chia sẻ</span>
                            </button>
                        </div>
                    </div>

                    <!-- Overall Rating Box (Dựa trên dữ liệu thật) -->
                    <div class="restaurant-rating-summary-box">
                        <div class="summary-score-header">
                            <span class="score-badge-label"><i class="fa-solid fa-medal text-warning"></i> Điểm Chất Lượng</span>
                        </div>
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
                                        Dựa trên <strong>${restaurant.reviewCount}</strong> đánh giá từ thực khách
                                    </c:when>
                                    <c:otherwise>
                                        Chưa có lượt đánh giá nào
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

            <!-- ==========================================
                 MỤC 1: COMBO & SET TIẾT KIỆM (NẾU CÓ)
                 ========================================== -->
            <c:if test="${not empty comboFoods}">
                <div class="section-restaurant-combos mt-5">
                    <div class="section-header-flex align-items-center mb-4">
                        <div>
                            <span class="sub-heading text-danger">
                                <i class="fa-solid fa-fire-flame-curved"></i> Ưu Đãi Độc Quyền
                            </span>
                            <h2 class="section-title mb-1">🔥 Combo &amp; Set Ăn Tiết Kiệm</h2>
                            <p class="section-desc mb-0 text-muted">
                                Các set ăn thịnh soạn kết hợp hài hòa, tiết kiệm từ 15% - 25% so với giá gọi món đơn lẻ
                            </p>
                        </div>
                        <span class="badge-count badge-combo-count" style="background: #fff1f2; color: #e11d48; border: 1px solid #fecdd3; font-weight: 800; padding: 6px 16px; border-radius: 50px; font-size: 0.88rem;">
                            <i class="fa-solid fa-fire me-1"></i> ${comboFoods.size()} Set Combo
                        </span>
                    </div>

                    <div class="food-grid">
                        <c:forEach items="${comboFoods}" var="food">
                            <div class="food-card is-combo-card" 
                                 data-food-id="${food.id}"
                                 onclick="if (!event.target.closest('.btn-add-cart, .add-cart-form, .combo-chips, button, input, form')) { window.location.href='${pageContext.request.contextPath}/food-detail?id=${food.id}'; }">
                                <div class="food-card-img-wrap">
                                    <span class="combo-badge-tag">
                                        <i class="fa-solid fa-fire"></i> Set Tiết Kiệm
                                    </span>
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

                                    <!-- Combo items chips list -->
                                    <c:if test="${not empty food.comboItemList}">
                                        <div class="combo-items-box">
                                            <div class="combo-items-box-label"><i class="fa-solid fa-layer-group"></i> Món trong set:</div>
                                            <div class="combo-items-list">
                                                <c:forEach items="${food.comboItemList}" var="itemPart">
                                                    <span class="combo-chip"><i class="fa-solid fa-circle-check"></i> ${itemPart}</span>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>

                                    <p class="food-desc">${food.description}</p>

                                    <div class="food-footer combo-footer">
                                        <div class="price-box">
                                            <c:choose>
                                                <c:when test="${not empty food.originalPrice and food.originalPrice > food.price}">
                                                    <div class="combo-savings-strip">
                                                        <span class="combo-price-original">${String.format("%,.0f", food.originalPrice)} đ</span>
                                                        <span class="combo-saving-badge">-${food.savingsPercent}%</span>
                                                    </div>
                                                    <span class="combo-price-final">${String.format("%,.0f", food.price)} đ</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="price-label">Giá chỉ</span>
                                                    <span class="food-price">${String.format("%,.0f", food.price)} đ</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form ajax-cart-form" data-food-id="${food.id}">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="foodId" value="${food.id}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn-add-cart btn-ajax-add btn-add-combo" title="Đặt Combo Tiết Kiệm">
                                                <i class="fa-solid fa-fire"></i>
                                                <span>Đặt Combo</span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <!-- ==========================================
                 MỤC 2: THỰC ĐƠN MÓN ĐƠN PHỤC VỤ
                 ========================================== -->
            <div class="section-restaurant-regular-foods ${not empty comboFoods ? 'border-top-dashed' : 'mt-5'}">
                <div class="section-header-flex align-items-center mb-4">
                    <div>
                        <span class="sub-heading"><i class="fa-solid fa-utensils text-primary"></i> Thực Đơn Món Lẻ</span>
                        <h2 class="section-title mb-1">Món Đơn Phục Vụ</h2>
                        <p class="section-desc mb-0 text-muted">
                            Các món ăn đậm đà chuẩn vị, nguyên liệu tươi sạch được đầu bếp nấu ngay khi nhận đơn
                        </p>
                    </div>
                    <span class="badge-count" style="background: #f1f5f9; color: #334155; font-weight: 800; padding: 6px 16px; border-radius: 50px; font-size: 0.88rem;">
                        ${not empty regularFoods ? regularFoods.size() : 0} món
                    </span>
                </div>

                <c:choose>
                    <c:when test="${not empty regularFoods}">
                        <div class="food-grid">
                            <c:forEach items="${regularFoods}" var="food">
                                <div class="food-card" 
                                     data-food-id="${food.id}"
                                     onclick="if (!event.target.closest('.btn-add-cart, .add-cart-form, .combo-chips, button, input, form')) { window.location.href='${pageContext.request.contextPath}/food-detail?id=${food.id}'; }">
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
                                            <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form ajax-cart-form" data-food-id="${food.id}">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="foodId" value="${food.id}">
                                                <input type="hidden" name="quantity" value="1">
                                                <button type="submit" class="btn-add-cart btn-ajax-add" title="Thêm vào giỏ hàng">
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
                    <c:when test="${empty comboFoods}">
                        <div class="empty-state-card">
                            <div class="empty-state-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                            <h3>Quán đang cập nhật thêm thực đơn!</h3>
                            <p>Vui lòng quay lại sau ít phút.</p>
                        </div>
                    </c:when>
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
