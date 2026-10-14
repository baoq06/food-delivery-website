<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
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
                    <span class="restaurant-hero-status ${'BANNED'.equalsIgnoreCase(restaurant.status) ? 'status-banned' : ('OPEN'.equalsIgnoreCase(restaurant.status) ? 'status-open' : 'status-closed')}">
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

            <!-- ==========================================================
                 MÃ GIẢM GIÁ & KHUYẾN MÃI CỦA QUÁN (XUẤT HIỆN Ở ĐẦU TRANG)
                 ========================================================== -->
            <c:if test="${not empty restaurantVouchers}">
                <div class="restaurant-vouchers-showcase mt-4 animate__animated animate__fadeInUp">
                    <div class="vouchers-showcase-header">
                        <div class="showcase-header-left">
                            <span class="showcase-badge"><i class="fa-solid fa-sparkles"></i> Ưu Đãi Độc Quyền</span>
                            <h2 class="showcase-title">🎟️ Mã Giảm Giá &amp; Khuyến Mãi Của Quán</h2>
                            <p class="showcase-subtitle">Lưu mã ngay để áp dụng trực tiếp khi thanh toán các món ngon tại <strong>${restaurant.name}</strong></p>
                        </div>
                        <div class="showcase-header-right">
                            <span class="badge-vouchers-count">
                                <i class="fa-solid fa-ticket"></i> ${restaurantVouchers.size()} Khuyến Mãi
                            </span>
                        </div>
                    </div>

                    <div class="restaurant-vouchers-grid">
                        <c:forEach items="${restaurantVouchers}" var="v">
                            <c:set var="isClaimed" value="${claimedVoucherCodes != null && claimedVoucherCodes.contains(v.code.toUpperCase())}" />
                            <div class="voucher-ticket-card ${isClaimed ? 'is-in-wallet' : ''}" id="voucher-card-${v.code}">
                                <!-- Left side: Badge & Discount Amount -->
                                <div class="voucher-ticket-left">
                                    <div class="ticket-tag-badge">${v.badge}</div>
                                    <div class="ticket-discount-amount">
                                        <c:choose>
                                            <c:when test="${v.discountType eq 'PERCENT'}">
                                                <span class="discount-num">${v.discountValue}</span><span class="discount-unit">%</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="discount-num"><fmt:formatNumber value="${v.discountValue / 1000}" type="number" maxFractionDigits="0" /></span><span class="discount-unit">K</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="ticket-discount-label">GIẢM NGAY</div>
                                    <span class="ticket-notch notch-top"></span>
                                    <span class="ticket-notch notch-bottom"></span>
                                </div>

                                <!-- Right side: Voucher Info & Actions -->
                                <div class="voucher-ticket-right">
                                    <div class="ticket-header-row">
                                        <div class="ticket-code-wrap">
                                            <strong class="ticket-code-text">${v.code}</strong>
                                            <button type="button" class="btn-copy-code" onclick="copyVoucherCode('${v.code}')" title="Sao chép mã">
                                                <i class="fa-regular fa-copy"></i>
                                            </button>
                                        </div>
                                        <button type="button" class="btn-terms-info" 
                                                data-code="${v.code}" 
                                                data-title="<c:out value='${v.title}'/>" 
                                                data-desc="<c:out value='${v.description}'/>" 
                                                data-type="${v.discountType}" 
                                                data-val="${v.discountValue}" 
                                                data-min="${v.minOrderAmount}" 
                                                data-max="${v.maxDiscount}" 
                                                data-limit="${v.usageLimit}" 
                                                data-used="${v.usedCount}" 
                                                data-peruser="${v.perUserLimit}" 
                                                data-expiry="${v.formattedExpiry}" 
                                                onclick="openVoucherTermsModalFromBtn(this)" 
                                                title="Xem điều kiện">
                                            <i class="fa-solid fa-circle-info"></i> Điều kiện
                                        </button>
                                    </div>

                                    <h4 class="ticket-title">${v.title}</h4>

                                    <div class="ticket-conditions-meta">
                                        <span class="condition-item"><i class="fa-solid fa-basket-shopping"></i> ${v.formattedMinOrder}</span>
                                        <c:if test="${v.discountType eq 'PERCENT' and v.maxDiscount > 0}">
                                            <span class="condition-item"><i class="fa-solid fa-shield-halved"></i> Tối đa <fmt:formatNumber value="${v.maxDiscount}" type="number" /> đ</span>
                                        </c:if>
                                        <span class="condition-item text-muted"><i class="fa-regular fa-calendar"></i> ${v.formattedExpiry}</span>
                                    </div>

                                    <!-- Usage Limit Progress Bar -->
                                    <c:if test="${v.usageLimit > 0}">
                                        <div class="ticket-usage-box">
                                            <div class="usage-text-row">
                                                <span class="usage-label">Đã dùng: <strong>${v.usedCount}</strong>/${v.usageLimit} lượt</span>
                                                <span class="usage-rem-badge">Còn ${v.remainingUsage} lượt</span>
                                            </div>
                                            <div class="progress usage-progress-bar">
                                                <div class="progress-bar ${v.usagePercentage >= 90 ? 'bg-danger' : (v.usagePercentage >= 60 ? 'bg-warning' : 'bg-success')}" 
                                                     style="width: ${v.usagePercentage}%;"></div>
                                            </div>
                                        </div>
                                    </c:if>

                                    <!-- Action Buttons: Lưu mã / Đã lưu -->
                                    <div class="ticket-footer-action">
                                        <c:choose>
                                            <c:when test="${isClaimed}">
                                                <button type="button" class="btn-ticket-action is-claimed" disabled>
                                                    <i class="fa-solid fa-circle-check"></i> Đã Trong Ví
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn-ticket-action btn-claim" data-code="${v.code}" onclick="claimRestaurantVoucher('${v.code}', this)">
                                                    <i class="fa-solid fa-bookmark"></i> Lưu Mã Ưu Đãi
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

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

<!-- ====================================================================
     MODAL: CHI TIẾT ĐIỀU KIỆN VOUCHER
     ==================================================================== -->
<div class="modal fade" id="voucherTermsModal" tabindex="-1" aria-labelledby="voucherTermsModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-md">
        <div class="modal-content" style="border-radius: 20px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.15);">
            <div class="modal-header" style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); color: #fff; padding: 16px 20px;">
                <h5 class="modal-title fw-bold" id="voucherTermsModalTitle">
                    <i class="fa-solid fa-circle-info me-2"></i> Điều Kiện Sử Dụng Voucher
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4" style="background: #fafafa;">
                <div class="text-center mb-3">
                    <div style="display: inline-block; background: #fff7ed; border: 2px dashed #fdba74; border-radius: 12px; padding: 6px 18px; margin-bottom: 8px;">
                        <span id="termsVoucherCode" class="font-monospace fw-bold text-danger" style="font-size: 1.35rem; letter-spacing: 1px;">VOUCHER</span>
                    </div>
                    <h5 id="termsVoucherTitle" class="fw-bold text-dark mb-1">Tiêu đề khuyến mãi</h5>
                    <p id="termsVoucherDesc" class="text-muted mb-0" style="font-size: 0.88rem;">Mô tả chi tiết áp dụng...</p>
                </div>

                <div class="terms-details-list" style="background: #fff; border-radius: 14px; border: 1px solid #e2e8f0; padding: 14px 18px;">
                    <div class="terms-item" style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-solid fa-coins text-warning me-2"></i>Mức giảm giá:</span>
                        <strong id="termsDiscountVal" class="text-danger">20.000 đ</strong>
                    </div>
                    <div class="terms-item" style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-solid fa-basket-shopping text-primary me-2"></i>Đơn tối thiểu:</span>
                        <strong id="termsMinOrder" class="text-dark">80.000 đ</strong>
                    </div>
                    <div class="terms-item" id="termsMaxDiscountRow" style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-solid fa-shield text-danger me-2"></i>Giảm tối đa:</span>
                        <strong id="termsMaxDiscount" class="text-dark">35.000 đ</strong>
                    </div>
                    <div class="terms-item" style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-solid fa-list-check text-success me-2"></i>Giới hạn sử dụng:</span>
                        <strong id="termsUsageLimit" class="text-dark">50 lượt toàn quán</strong>
                    </div>
                    <div class="terms-item" style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-solid fa-user-check text-info me-2"></i>Mỗi khách hàng:</span>
                        <strong id="termsPerUser" class="text-dark">Tối đa 1 lần</strong>
                    </div>
                    <div class="terms-item" style="display: flex; justify-content: space-between; padding: 8px 0; font-size: 0.88rem;">
                        <span class="text-muted"><i class="fa-regular fa-calendar-check text-danger me-2"></i>Hạn sử dụng:</span>
                        <strong id="termsExpiry" class="text-dark">31/12/2026</strong>
                    </div>
                </div>

                <div class="alert alert-info mt-3 mb-0" style="background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; border-radius: 12px; font-size: 0.82rem; padding: 10px 14px;">
                    <i class="fa-solid fa-circle-check me-1"></i> Mã chỉ áp dụng cho các món ăn được đặt từ <strong>${restaurant.name}</strong> khi thanh toán qua hệ thống Utee.
                </div>
            </div>
            <div class="modal-footer bg-white p-3" style="border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between;">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-primary rounded-pill px-4 fw-bold" id="btnModalClaimVoucher" onclick="claimVoucherFromModal()" style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); border: none;">
                    <i class="fa-solid fa-bookmark me-1"></i> Lưu Mã Này Vào Ví
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ====================================================================
     FLOATING TOAST CONTAINER
     ==================================================================== -->
<div id="voucherToastContainer" style="position: fixed; bottom: 30px; right: 30px; z-index: 9999; display: flex; flex-direction: column; gap: 10px; pointer-events: none;"></div>

<!-- ====================================================================
     VOUCHER SHOWCASE STYLES & INTERACTION SCRIPT
     ==================================================================== -->
<style>
.restaurant-vouchers-showcase {
    background: #ffffff;
    border-radius: 20px;
    padding: 24px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.04);
    border: 1px solid #f1f5f9;
    margin-bottom: 24px;
}

.vouchers-showcase-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    margin-bottom: 20px;
    padding-bottom: 14px;
    border-bottom: 1px solid #f1f5f9;
}

.showcase-badge {
    background: #fff1f2;
    color: #e11d48;
    font-size: 0.75rem;
    font-weight: 800;
    padding: 3px 10px;
    border-radius: 20px;
    display: inline-block;
    margin-bottom: 4px;
    border: 1px solid #fecdd3;
}

.showcase-title {
    font-size: 1.35rem;
    font-weight: 800;
    color: #0f172a;
    margin: 0 0 4px 0;
}

.showcase-subtitle {
    font-size: 0.88rem;
    color: #64748b;
    margin: 0;
}

.badge-vouchers-count {
    background: #fff7ed;
    color: #ea580c;
    border: 1px solid #fed7aa;
    font-weight: 800;
    padding: 6px 14px;
    border-radius: 30px;
    font-size: 0.85rem;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.restaurant-vouchers-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 16px;
}

@media (max-width: 768px) {
    .restaurant-vouchers-grid {
        grid-template-columns: 1fr;
    }
}

.voucher-ticket-card {
    display: flex;
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #fed7aa;
    overflow: hidden;
    box-shadow: 0 4px 14px rgba(234,88,12,0.06);
    transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    position: relative;
}

.voucher-ticket-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 25px rgba(234,88,12,0.14);
    border-color: #f97316;
}

.voucher-ticket-card.is-in-wallet {
    border-color: #a7f3d0;
    background: #fafdfc;
}

.voucher-ticket-left {
    width: 110px;
    min-width: 110px;
    background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
    color: #ffffff;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 14px 8px;
    position: relative;
    text-align: center;
    border-right: 2px dashed #fed7aa;
}

.voucher-ticket-card.is-in-wallet .voucher-ticket-left {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    border-right-color: #a7f3d0;
}

.ticket-notch {
    width: 14px;
    height: 14px;
    background: #ffffff;
    border-radius: 50%;
    position: absolute;
    right: -7px;
    z-index: 2;
}

.notch-top {
    top: -7px;
}

.notch-bottom {
    bottom: -7px;
}

.ticket-tag-badge {
    font-size: 0.65rem;
    background: rgba(255,255,255,0.22);
    border-radius: 20px;
    padding: 2px 6px;
    margin-bottom: 6px;
    white-space: nowrap;
    font-weight: 700;
}

.ticket-discount-amount {
    line-height: 1;
    margin-bottom: 4px;
}

.ticket-discount-amount .discount-num {
    font-size: 1.7rem;
    font-weight: 800;
}

.ticket-discount-amount .discount-unit {
    font-size: 1rem;
    font-weight: 700;
}

.ticket-discount-label {
    font-size: 0.65rem;
    font-weight: 800;
    letter-spacing: 0.5px;
    opacity: 0.9;
}

.voucher-ticket-right {
    flex: 1;
    padding: 14px 16px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.ticket-header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 6px;
}

.ticket-code-wrap {
    background: #fff7ed;
    border: 1px dashed #fdba74;
    border-radius: 6px;
    padding: 2px 8px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.voucher-ticket-card.is-in-wallet .ticket-code-wrap {
    background: #ecfdf5;
    border-color: #6ee7b7;
}

.ticket-code-text {
    font-family: monospace;
    font-weight: 800;
    color: #ea580c;
    font-size: 0.92rem;
}

.voucher-ticket-card.is-in-wallet .ticket-code-text {
    color: #059669;
}

.btn-copy-code {
    background: none;
    border: none;
    color: #94a3b8;
    padding: 0;
    cursor: pointer;
    font-size: 0.78rem;
    transition: color 0.15s;
}

.btn-copy-code:hover {
    color: #ea580c;
}

.btn-terms-info {
    background: none;
    border: none;
    font-size: 0.75rem;
    color: #64748b;
    cursor: pointer;
    font-weight: 600;
    padding: 0;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.btn-terms-info:hover {
    color: #2563eb;
    text-decoration: underline;
}

.ticket-title {
    font-size: 0.95rem;
    font-weight: 700;
    color: #0f172a;
    margin: 4px 0 6px 0;
    line-height: 1.3;
}

.ticket-conditions-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    font-size: 0.78rem;
    color: #64748b;
    margin-bottom: 8px;
}

.condition-item {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    background: #f8fafc;
    padding: 2px 8px;
    border-radius: 6px;
    border: 1px solid #f1f5f9;
}

.ticket-usage-box {
    margin: 4px 0 8px 0;
}

.usage-text-row {
    display: flex;
    justify-content: space-between;
    font-size: 0.75rem;
    margin-bottom: 3px;
    color: #64748b;
}

.usage-rem-badge {
    font-weight: 700;
    color: #ea580c;
}

.usage-progress-bar {
    height: 5px;
    border-radius: 4px;
    background: #f1f5f9;
}

.btn-ticket-action {
    width: 100%;
    padding: 8px 12px;
    border-radius: 10px;
    font-weight: 700;
    font-size: 0.85rem;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-ticket-action.btn-claim {
    background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
    color: #ffffff;
    box-shadow: 0 4px 10px rgba(234,88,12,0.22);
}

.btn-ticket-action.btn-claim:hover {
    transform: scale(1.02);
    box-shadow: 0 6px 14px rgba(234,88,12,0.32);
}

.btn-ticket-action.is-claimed {
    background: #ecfdf5;
    color: #059669;
    border: 1px solid #a7f3d0;
    cursor: default;
}
</style>

<script>
let currentModalCode = '';

function claimRestaurantVoucher(code, btn) {
    if (!code) return;
    const originalContent = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';

    fetch('${pageContext.request.contextPath}/api/voucher?action=claim-code&code=' + encodeURIComponent(code), {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    .then(r => r.json())
    .then(data => {
        if (data.requireLogin) {
            window.location.href = '${pageContext.request.contextPath}/login?redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
            return;
        }

        if (data.success) {
            btn.className = 'btn-ticket-action is-claimed';
            btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> Đã Trong Ví';
            btn.disabled = true;

            const card = document.getElementById('voucher-card-' + code);
            if (card) {
                card.classList.add('is-in-wallet');
            }

            showVoucherToast(data.message || 'Đã lưu mã vào Kho Voucher thành công!', 'success');
        } else {
            btn.disabled = false;
            btn.innerHTML = originalContent;
            showVoucherToast(data.message || 'Không thể lưu mã voucher!', 'danger');
        }
    })
    .catch(err => {
        console.error(err);
        btn.disabled = false;
        btn.innerHTML = originalContent;
        showVoucherToast('Lỗi kết nối máy chủ khi lưu mã!', 'danger');
    });
}

function openVoucherTermsModalFromBtn(btn) {
    const code = btn.dataset.code || '';
    const title = btn.dataset.title || '';
    const desc = btn.dataset.desc || '';
    const type = btn.dataset.type || 'FIXED';
    const val = parseFloat(btn.dataset.val) || 0;
    const minOrder = parseFloat(btn.dataset.min) || 0;
    const maxDiscount = parseFloat(btn.dataset.max) || 0;
    const limit = parseInt(btn.dataset.limit) || 0;
    const used = parseInt(btn.dataset.used) || 0;
    const perUser = parseInt(btn.dataset.peruser) || 1;
    const expiry = btn.dataset.expiry || 'Vô thời hạn';

    currentModalCode = code;
    document.getElementById('termsVoucherCode').textContent = code;
    document.getElementById('termsVoucherTitle').textContent = title;
    document.getElementById('termsVoucherDesc').textContent = desc || 'Áp dụng cho mọi món ăn tại quán khi đặt qua Utee.';

    if (type === 'PERCENT') {
        document.getElementById('termsDiscountVal').textContent = 'Giảm ' + val + '%';
        if (maxDiscount > 0) {
            document.getElementById('termsMaxDiscountRow').style.display = 'flex';
            document.getElementById('termsMaxDiscount').textContent = new Intl.NumberFormat('vi-VN').format(maxDiscount) + ' đ';
        } else {
            document.getElementById('termsMaxDiscountRow').style.display = 'none';
        }
    } else {
        document.getElementById('termsDiscountVal').textContent = 'Giảm ' + new Intl.NumberFormat('vi-VN').format(val) + ' đ';
        document.getElementById('termsMaxDiscountRow').style.display = 'none';
    }

    document.getElementById('termsMinOrder').textContent = minOrder > 0 ? (new Intl.NumberFormat('vi-VN').format(minOrder) + ' đ') : 'Đơn bất kỳ';
    document.getElementById('termsUsageLimit').textContent = limit > 0 ? (limit + ' lượt toàn hệ thống (Đã dùng ' + used + ')') : 'Không giới hạn tổng lượt';
    document.getElementById('termsPerUser').textContent = 'Tối đa ' + perUser + ' lần/khách';
    document.getElementById('termsExpiry').textContent = expiry;

    const modal = new bootstrap.Modal(document.getElementById('voucherTermsModal'));
    modal.show();
}

function claimVoucherFromModal() {
    if (!currentModalCode) return;
    const btn = document.querySelector('#voucher-card-' + currentModalCode + ' .btn-claim');
    if (btn) {
        claimRestaurantVoucher(currentModalCode, btn);
    } else {
        claimRestaurantVoucher(currentModalCode, document.getElementById('btnModalClaimVoucher'));
    }
    const modalEl = document.getElementById('voucherTermsModal');
    const modalInstance = bootstrap.Modal.getInstance(modalEl);
    if (modalInstance) modalInstance.hide();
}

function copyVoucherCode(code) {
    if (!code) return;
    navigator.clipboard.writeText(code).then(() => {
        showVoucherToast('Đã sao chép mã <strong>' + code + '</strong> vào bộ nhớ tạm!', 'success');
    }).catch(() => {
        prompt('Sao chép mã voucher bên dưới:', code);
    });
}

function showVoucherToast(msg, type) {
    const container = document.getElementById('voucherToastContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.style.cssText = 'pointer-events: auto; padding: 12px 18px; border-radius: 12px; font-weight: 600; font-size: 0.9rem; display: flex; align-items: center; gap: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); animation: fadeInUp 0.3s ease;';
    
    if (type === 'success') {
        toast.style.background = '#ecfdf5';
        toast.style.border = '1px solid #a7f3d0';
        toast.style.color = '#065f46';
        toast.innerHTML = '<i class="fa-solid fa-circle-check text-success" style="font-size: 1.15rem;"></i> <span>' + msg + '</span>';
    } else {
        toast.style.background = '#fef2f2';
        toast.style.border = '1px solid #fecaca';
        toast.style.color = '#991b1b';
        toast.innerHTML = '<i class="fa-solid fa-circle-exclamation text-danger" style="font-size: 1.15rem;"></i> <span>' + msg + '</span>';
    }

    container.appendChild(toast);
    setTimeout(() => {
        toast.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(10px)';
        setTimeout(() => toast.remove(), 400);
    }, 3500);
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

