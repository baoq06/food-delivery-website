<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Giỏ Hàng Của Bạn - Utee" />
</jsp:include>

<div class="page-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>Giỏ hàng & Đặt món</span>
        </div>
        <h1 class="page-title">Giỏ Hàng & Thanh Toán</h1>
    </div>
</div>

<div class="container section">
    <c:choose>
        <c:when test="${not empty sessionScope.cart and sessionScope.cart.size() > 0}">
            <c:set var="totalBill" value="0" />
            <c:forEach items="${sessionScope.cart.values()}" var="item">
                <c:set var="totalBill" value="${totalBill + item.totalPrice}" />
            </c:forEach>
            <c:set var="cartFreeshipGoal" value="99000" />
            <c:set var="cartFreeshipRemaining" value="${cartFreeshipGoal - totalBill}" />
            <c:set var="cartFreeshipPercent" value="${(totalBill / cartFreeshipGoal) * 100}" />
            <c:if test="${cartFreeshipPercent > 100}">
                <c:set var="cartFreeshipPercent" value="100" />
            </c:if>

            <div class="checkout-grid">
                <!-- Left: Cart Items List -->
                <div class="checkout-left">
                    <!-- Smart Freeship Progress Bar Banner -->
                    <div class="cart-freeship-main-banner ${cartFreeshipRemaining <= 0 ? 'achieved' : ''}">
                        <div class="cf-banner-icon">
                            <i class="fa-solid fa-truck-fast"></i>
                        </div>
                        <div class="cf-banner-body">
                            <div class="cf-banner-title-row">
                                <c:choose>
                                    <c:when test="${cartFreeshipRemaining <= 0}">
                                        <strong class="text-success"><i class="fa-solid fa-circle-check"></i> Chúc mừng! Đơn hàng đã đủ điều kiện FREESHIP 15.000 đ</strong>
                                    </c:when>
                                    <c:otherwise>
                                        <span>Mua thêm <strong class="text-primary">${String.format("%,.0f", cartFreeshipRemaining)} đ</strong> để nhận <strong class="text-success">MIỄN PHÍ VẬN CHUYỂN 15.000 đ</strong> 🛵</span>
                                    </c:otherwise>
                                </c:choose>
                                <span class="cf-percent-badge"><fmt:formatNumber value="${cartFreeshipPercent}" maxFractionDigits="0" />%</span>
                            </div>
                            <div class="cf-progress-track">
                                <div class="cf-progress-fill" style="width: ${cartFreeshipPercent}%;"></div>
                            </div>
                        </div>
                    </div>

                    <div class="checkout-box mt-3">
                        <div class="box-header">
                            <h3 class="box-title"><i class="fa-solid fa-bag-shopping text-primary"></i> Danh Sách Món Ăn (${sessionScope.cart.size()} món)</h3>
                            <a href="${pageContext.request.contextPath}/foods" class="continue-link"><i class="fa-solid fa-plus"></i> Thêm món khác</a>
                        </div>

                        <div class="cart-items-wrapper">
                            <c:forEach items="${sessionScope.cart.values()}" var="item">
                                <div class="cart-item-row">
                                    <img src="${item.food.image}" alt="${item.food.name}" class="cart-item-img" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&auto=format&fit=crop&q=60'">
                                    <div class="cart-item-info">
                                        <h4 class="cart-item-name">${item.food.name}</h4>
                                        <div class="cart-item-unit-price">${String.format("%,.0f", item.food.price)} đ / phần</div>
                                    </div>
                                    
                                    <div class="cart-item-qty">
                                        <span class="qty-badge">Số lượng: <strong>${item.quantity}</strong></span>
                                    </div>

                                    <div class="cart-item-subtotal">
                                        ${String.format("%,.0f", item.totalPrice)} đ
                                    </div>

                                    <div class="cart-item-remove">
                                        <form action="${pageContext.request.contextPath}/cart" method="POST">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="foodId" value="${item.food.id}">
                                            <button type="submit" class="btn-remove-item" title="Xóa món này">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Voucher Action Box (Shopee-Style) -->
                    <div class="checkout-box mt-3 cart-voucher-compact-box">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fa-solid fa-ticket text-danger" style="font-size: 1.35rem;"></i>
                                <div>
                                    <strong style="color: #1e293b; font-size: 0.95rem;">Ưu Đãi &amp; Mã Giảm Giá</strong>
                                    <div class="text-muted" style="font-size: 0.8rem;">Áp dụng tối đa 1 mã freeship &amp; 1 mã món ăn</div>
                                </div>
                            </div>
                            <button type="button" class="btn-apply-shopee-promo" onclick="openShopeeVoucherModal()">
                                <i class="fa-solid fa-ticket me-1"></i> Áp mã ưu đãi
                            </button>
                        </div>

                        <!-- Applied Voucher Card (Hiển thị khi mã được áp dụng) -->
                        <div id="voucherAppliedCard" class="voucher-applied-box mt-3" style="display: none;">
                            <div class="voucher-applied-info">
                                <span class="voucher-applied-badge" id="appliedVCode">UTEE</span>
                                <div class="voucher-applied-text">
                                    <strong id="appliedVTitle">Đã áp dụng giảm giá</strong>
                                    <p id="appliedVDesc" class="mb-0">Ưu đãi giảm trực tiếp vào đơn hàng</p>
                                </div>
                            </div>
                            <div class="d-flex gap-2 align-items-center">
                                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="openShopeeVoucherModal()" title="Đổi sang mã khác" style="font-size: 0.78rem; padding: 4px 8px; border-radius: 6px;">
                                    Đổi mã
                                </button>
                                <button type="button" class="btn-remove-voucher" onclick="clearAllVouchers()" title="Hủy áp dụng mã này">
                                    <i class="fa-solid fa-xmark"></i> Bỏ chọn
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Upsell / Cross-sell: Món ăn kèm / Đồ uống gợi ý 1-Click -->
                    <c:if test="${not empty popularSideDishes}">
                        <div class="checkout-box mt-3 cart-upsell-box">
                            <div class="cart-upsell-header">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-fire text-danger"></i>
                                    <div>
                                        <h4 class="cart-upsell-title">Món Ngon Gọi Kèm Siêu Tiết Kiệm</h4>
                                        <p class="cart-upsell-subtitle">Thêm đồ uống &amp; món phụ thanh mát chỉ với 1 chạm</p>
                                    </div>
                                </div>
                                <span class="badge bg-warning text-dark font-weight-bold" style="font-size: 0.75rem; border-radius: 20px;">Mua kèm giá sốc</span>
                            </div>
                            <div class="cart-upsell-grid">
                                <c:forEach items="${popularSideDishes}" var="side">
                                    <div class="cart-upsell-card">
                                        <img src="${side.image}" alt="${side.name}" class="cart-upsell-img" onerror="this.src='https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=120'">
                                        <div class="cart-upsell-info">
                                            <div class="cart-upsell-name" title="${side.name}">${side.name}</div>
                                            <div class="cart-upsell-price">${String.format("%,.0f", side.price)} đ</div>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/cart" method="POST" class="ajax-cart-form upsell-add-form" data-food-id="${side.id}">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="foodId" value="${side.id}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn-upsell-add" title="Thêm vào giỏ">
                                                <i class="fa-solid fa-plus"></i>
                                            </button>
                                        </form>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Right: Delivery Info & Checkout Summary -->
                <div class="checkout-right">
                    <div class="checkout-box summary-card">
                        <h3 class="box-title"><i class="fa-solid fa-truck-ramp-box text-primary"></i> Thông Tin Giao Hàng</h3>
                        
                        <c:if test="${not empty checkoutError}">
                            <div class="alert-box-danger" style="margin-bottom: 16px; padding: 12px 16px; background-color: #ffeaa7; border-left: 4px solid #d63031; border-radius: 6px; color: #d63031; display: flex; align-items: center; gap: 10px; font-weight: 500;">
                                <i class="fa-solid fa-circle-exclamation"></i>
                                <span>${checkoutError}</span>
                            </div>
                        </c:if>

                        <form id="orderForm" action="${pageContext.request.contextPath}/cart" method="POST">
                            <input type="hidden" name="action" value="checkout">
                            <input type="hidden" id="appliedVoucherCode" name="voucherCode" value="<c:out value='${not empty stickyVoucherCode ? stickyVoucherCode : \"\"}' />">
                            <input type="hidden" id="shippingVoucherCode" name="shippingVoucherCode" value="<c:out value='${not empty stickyShippingVoucherCode ? stickyShippingVoucherCode : \"\"}' />">
                            <input type="hidden" id="foodVoucherCode" name="foodVoucherCode" value="<c:out value='${not empty stickyFoodVoucherCode ? stickyFoodVoucherCode : \"\"}' />">
                            <div class="form-group">
                                <label for="receiverName">Họ và tên người nhận *</label>
                                <input type="text" id="receiverName" name="receiverName" class="form-control" required placeholder="Nhập tên của bạn..." 
                                       value="<c:out value='${not empty stickyReceiverName ? stickyReceiverName : sessionScope.currentUser.fullName}' />">
                            </div>

                            <div class="form-group">
                                <label for="receiverPhone">Số điện thoại nhận hàng *</label>
                                <input type="tel" id="receiverPhone" name="receiverPhone" class="form-control" required placeholder="Ví dụ: 0912 345 678" 
                                       value="<c:out value='${not empty stickyReceiverPhone ? stickyReceiverPhone : sessionScope.currentUser.phone}' />">
                            </div>

                            <div class="form-group">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <label class="form-label mb-0">Địa chỉ giao hàng chi tiết *</label>
                                    <button type="button" id="btnCartGPS" class="btn btn-sm btn-outline-primary" style="font-size: 0.78rem; border-radius: 20px; padding: 2px 10px;" onclick="locateUserForShipping()">
                                        <i class="fa-solid fa-location-crosshairs me-1"></i> Định vị GPS của tôi
                                    </button>
                                </div>
                                <div id="cartVNAddressPicker"></div>
                                <input type="hidden" id="receiverAddress" name="receiverAddress" required 
                                       value="<c:out value='${not empty stickyReceiverAddress ? stickyReceiverAddress : sessionScope.currentUser.address}' />">
                                <div id="shippingDistanceNotice" class="p-2 mt-2 rounded" style="font-size: 0.82rem; background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; display: none;">
                                    <i class="fa-solid fa-route me-1 text-success"></i> <span id="distText">Đang tính cự ly...</span>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="receiverNote">Ghi chú cho tài xế (nếu có)</label>
                                <input type="text" id="receiverNote" name="receiverNote" class="form-control" placeholder="Giao trước 12h, gọi trước khi đến..."
                                       value="<c:out value='${stickyReceiverNote}' />">
                                <!-- Quick Note Chips -->
                                <div class="quick-note-chips-container mt-2">
                                    <span class="quick-note-chip" onclick="toggleQuickNote(this, 'receiverNote', 'Gọi trước khi đến')">📞 Gọi trước khi đến</span>
                                    <span class="quick-note-chip" onclick="toggleQuickNote(this, 'receiverNote', 'Giao tận cửa phòng')">🚪 Giao tận cửa</span>
                                    <span class="quick-note-chip" onclick="toggleQuickNote(this, 'receiverNote', 'Treo ở cổng/bảo vệ')">🏠 Treo ở cổng</span>
                                    <span class="quick-note-chip" onclick="toggleQuickNote(this, 'receiverNote', 'Không bấm chuông')">🔕 Không bấm chuông</span>
                                    <span class="quick-note-chip" onclick="toggleQuickNote(this, 'receiverNote', 'Giao nóng hổi')">🔥 Giao nóng hổi</span>
                                </div>
                            </div>

                            <!-- Payment Method -->
                            <div class="form-group">
                                <label class="option-label">Phương thức thanh toán:</label>
                                <div class="payment-options">
                                    <label class="payment-radio">
                                        <input type="radio" name="paymentMethod" value="COD" ${empty stickyPaymentMethod or stickyPaymentMethod eq 'COD' ? 'checked' : ''}>
                                        <span class="radio-custom"></span>
                                        <i class="fa-solid fa-hand-holding-dollar text-primary"></i>
                                        <span>Tiền mặt khi nhận (COD)</span>
                                    </label>
                                    <label class="payment-radio">
                                        <input type="radio" name="paymentMethod" value="QR" ${stickyPaymentMethod eq 'QR' ? 'checked' : ''}>
                                        <span class="radio-custom"></span>
                                        <i class="fa-solid fa-qrcode text-primary"></i>
                                        <span>Chuyển khoản mã VietQR</span>
                                    </label>
                                </div>
                            </div>

                            <!-- Shopee-Style Voucher Selector Bar -->
                            <div class="shopee-voucher-bar" id="shopeeVoucherBar" onclick="openShopeeVoucherModal()" title="Nhấn để tự do chọn mã giảm giá Utee">
                                <div class="svb-left">
                                    <i class="fa-solid fa-ticket svb-icon"></i>
                                    <span class="svb-title">Utee Voucher</span>
                                </div>
                                <div class="svb-right">
                                    <span class="svb-badge" id="svbBadgeText">Áp mã ưu đãi</span>
                                    <i class="fa-solid fa-chevron-right svb-arrow"></i>
                                </div>
                            </div>

                            <div class="order-bill-divider"></div>

                            <!-- Bill summary -->
                            <div class="summary-line">
                                <span>Tạm tính món:</span>
                                <span>${String.format("%,.0f", totalBill)} đ</span>
                            </div>
                            <div class="summary-line">
                                <span>Phí vận chuyển (30 phút):</span>
                                <span id="shippingFee">15,000 đ</span>
                            </div>
                            <div class="summary-line text-success" id="shippingDiscountRow" style="display: none;">
                                <span><i class="fa-solid fa-motorcycle me-1"></i> Giảm phí vận chuyển (<span id="shippingDiscountCodeDisplay"></span>):</span>
                                <strong id="shippingDiscountVal">-0 đ</strong>
                            </div>
                            <div class="summary-line text-success" id="foodDiscountRow" style="display: none;">
                                <span><i class="fa-solid fa-utensils me-1"></i> Giảm giá món ăn (<span id="foodDiscountCodeDisplay"></span>):</span>
                                <strong id="foodDiscountVal">-0 đ</strong>
                            </div>
                            <div class="summary-line text-success" id="discountRow" style="display: none;">
                                <span><i class="fa-solid fa-tag me-1"></i> Tổng giảm ưu đãi (<span id="discountCodeDisplay"></span>):</span>
                                <strong id="discountVal">-0 đ</strong>
                            </div>

                            <div class="summary-total-line">
                                <span>Tổng thanh toán:</span>
                                <span class="final-total" id="finalTotalDisplay">${String.format("%,.0f", totalBill + 15000)} đ</span>
                            </div>

                            <button type="submit" class="btn btn-primary btn-block btn-lg btn-order mt-3">
                                <i class="fa-solid fa-check"></i> XÁC NHẬN ĐẶT MÓN NGAY
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-cart-card">
                <div class="empty-cart-icon">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>
                <h2>Giỏ Hàng Của Bạn Đang Trống!</h2>
                <p>Bạn chưa thêm món ăn nào vào giỏ hàng. Hãy lướt qua thực đơn món ngon phong phú của Utee và đặt ngay nhé.</p>
                <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-lg mt-3">
                    <i class="fa-solid fa-utensils"></i> Khám Phá Thực Đơn Ngay
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Order Success Modal -->
<div id="orderSuccessModal" class="modal-overlay">
    <div class="modal-content">
        <div class="success-icon-wrap">
            <i class="fa-solid fa-circle-check"></i>
        </div>
        <h2>Đặt Hàng Thành Công!</h2>
        <p class="modal-sub">Cảm ơn bạn đã lựa chọn Utee. Đơn hàng của bạn đã được tiếp nhận và nhà bếp đang chuẩn bị.</p>
        
        <div class="order-info-card">
            <div class="info-row">
                <span>Mã đơn hàng:</span>
                <strong id="modalOrderId"><c:out value="${placedOrderId}" /></strong>
            </div>
            <c:if test="${not empty successSubtotal}">
                <div class="info-row">
                    <span>Tạm tính món:</span>
                    <span>${String.format("%,.0f", successSubtotal)} đ</span>
                </div>
                <div class="info-row">
                    <span>Phí vận chuyển:</span>
                    <span>${String.format("%,.0f", successShippingFee)} đ</span>
                </div>
            </c:if>
            <c:if test="${not empty successVoucherCode and successDiscountAmount > 0}">
                <div class="info-row text-success">
                    <span><i class="fa-solid fa-tag me-1"></i> Giảm giá voucher (${successVoucherCode}):</span>
                    <strong>-${String.format("%,.0f", successDiscountAmount)} đ</strong>
                </div>
            </c:if>
            <c:if test="${not empty successTotalAmount}">
                <div class="info-row" style="border-top: 1px dashed #cbd5e1; padding-top: 8px; margin-top: 8px;">
                    <span style="font-weight: 700; color: #1e293b;">Tổng thanh toán:</span>
                    <strong style="color: var(--primary-color, #ff4757); font-size: 1.15rem;">${String.format("%,.0f", successTotalAmount)} đ</strong>
                </div>
            </c:if>
            <div class="info-row">
                <span>Dự kiến giao hàng:</span>
                <strong class="text-primary">25 - 30 phút nữa</strong>
            </div>
            <div class="info-row">
                <span>Trạng thái:</span>
                <span class="status-badge">Đang chuẩn bị món</span>
            </div>
        </div>

        <div class="modal-actions">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary btn-block">Về Trang Chủ</a>
        </div>
    </div>
</div>

<!-- Shopee-Style Voucher Modal (Hỗ trợ tối đa 2 mã: 1 Freeship + 1 Giảm Món) -->
<div id="shopeeVoucherModal" class="shopee-modal-overlay" onclick="handleShopeeOverlayClick(event)">
    <div class="shopee-modal-dialog" onclick="event.stopPropagation()">
        <!-- Header -->
        <div class="shopee-modal-header">
            <div>
                <h3><i class="fa-solid fa-ticket"></i> Chọn Utee Voucher</h3>
                <p class="shopee-header-sub mb-0" style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                    Áp dụng tối đa 1 mã Freeship &amp; 1 mã Giảm Món Ăn
                </p>
            </div>
            <button type="button" class="shopee-modal-close" onclick="closeShopeeVoucherModal()" title="Đóng">&times;</button>
        </div>

        <!-- Search / Input Bar -->
        <div class="shopee-input-bar">
            <div class="input-wrap">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="shopeeInputCode" placeholder="Nhập mã ưu đãi Utee..." onkeydown="if(event.key==='Enter'){event.preventDefault(); applyShopeeInputCode();}">
            </div>
            <button type="button" class="btn-shopee-apply" onclick="applyShopeeInputCode()">Áp Dụng</button>
        </div>
        <div id="shopeeInputFeedback" class="shopee-input-feedback" style="display: none;"></div>

        <!-- Body / 2 Dedicated Voucher Slots -->
        <div class="shopee-modal-body" id="shopeeVoucherList">
            
            <!-- SECTION 1: FREESHIP VOUCHERS -->
            <div class="shopee-slot-group">
                <div class="shopee-slot-header">
                    <div class="d-flex align-items-center gap-2">
                        <i class="fa-solid fa-motorcycle text-success" style="font-size: 1.15rem;"></i>
                        <span class="slot-title" style="font-weight: 700; color: #1e293b;">1. Mã Miễn Phí Vận Chuyển</span>
                    </div>
                    <span class="slot-badge-limit">Chọn tối đa 1 mã</span>
                </div>

                <!-- Option: Không dùng mã ship -->
                <div class="shopee-none-slot-item" onclick="selectCandidateShipping('')">
                    <label class="d-flex align-items-center justify-content-between w-100 mb-0" style="cursor: pointer;">
                        <span class="text-muted" style="font-size: 0.86rem;"><i class="fa-solid fa-ban me-1"></i> Không sử dụng mã vận chuyển</span>
                        <input type="radio" name="shopeeShippingRadio" id="radioShip_none" value="" checked onclick="event.stopPropagation(); selectCandidateShipping('')">
                    </label>
                </div>

                <!-- List of Shipping Vouchers -->
                <c:forEach items="${availableVouchers}" var="v">
                    <c:if test="${v.freeShip}">
                        <c:set var="isEligible" value="${totalBill >= v.minOrderAmount}" />
                        <div class="shopee-ticket-card freeship-card ${isEligible ? 'eligible' : 'ineligible'}" 
                             id="shopeeCard_${v.code}"
                             data-code="${v.code}"
                             data-type="shipping"
                             data-eligible="${isEligible}"
                             onclick="${isEligible ? 'selectCandidateShipping(\"' : ''}${isEligible ? v.code : ''}${isEligible ? '\")' : ''}">
                            <!-- Left Stub -->
                            <div class="ticket-stub freeship">
                                <i class="fa-solid fa-motorcycle stub-icon"></i>
                                <span class="stub-badge">${v.badge}</span>
                                <span class="stub-code">${v.code}</span>
                            </div>

                            <!-- Right Details -->
                            <div class="ticket-content">
                                <div class="ticket-header">
                                    <div>
                                        <h4 class="ticket-title">${v.title}</h4>
                                        <p class="ticket-desc">${v.description}</p>
                                    </div>
                                    <div class="ticket-radio-wrap">
                                        <input type="radio" name="shopeeShippingRadio" id="radioShip_${v.code}" value="${v.code}"
                                               ${not isEligible ? 'disabled' : ''}
                                               onclick="event.stopPropagation(); selectCandidateShipping('${v.code}')">
                                    </div>
                                </div>
                                <div class="ticket-meta">
                                    <span class="ticket-cond ${isEligible ? '' : 'ineligible'}">
                                        <c:choose>
                                            <c:when test="${isEligible}">
                                                <i class="fa-solid fa-circle-check"></i> Đủ điều kiện sử dụng
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-circle-exclamation"></i> Cần thêm ${String.format("%,.0f", v.minOrderAmount - totalBill)} đ
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <c:if test="${v.quantity > 0}">
                                        <span class="wallet-badge-pill">
                                            <i class="fa-solid fa-bookmark"></i> Số lượng: x${v.quantity}
                                        </span>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <!-- SECTION 2: FOOD DISCOUNT & RESTAURANT VOUCHERS -->
            <div class="shopee-slot-group mt-4">
                <div class="shopee-slot-header">
                    <div class="d-flex align-items-center gap-2">
                        <i class="fa-solid fa-utensils text-danger" style="font-size: 1.15rem;"></i>
                        <span class="slot-title" style="font-weight: 700; color: #1e293b;">2. Mã Giảm Giá Món Ăn &amp; Quán Ăn</span>
                    </div>
                    <span class="slot-badge-limit">Chọn tối đa 1 mã</span>
                </div>

                <!-- Option: Không dùng mã món -->
                <div class="shopee-none-slot-item" onclick="selectCandidateFood('')">
                    <label class="d-flex align-items-center justify-content-between w-100 mb-0" style="cursor: pointer;">
                        <span class="text-muted" style="font-size: 0.86rem;"><i class="fa-solid fa-ban me-1"></i> Không sử dụng mã giảm món</span>
                        <input type="radio" name="shopeeFoodRadio" id="radioFood_none" value="" checked onclick="event.stopPropagation(); selectCandidateFood('')">
                    </label>
                </div>

                <!-- List of Food Vouchers -->
                <c:forEach items="${availableVouchers}" var="v">
                    <c:if test="${not v.freeShip}">
                        <c:set var="isOrderEligible" value="${totalBill >= v.minOrderAmount}" />
                        <c:set var="isRestEligible" value="${empty v.restaurantId or v.restaurantId <= 0 or v.restaurantId == cartRestaurantId}" />
                        <c:set var="isEligible" value="${isOrderEligible and isRestEligible}" />
                        <div class="shopee-ticket-card food-card ${isEligible ? 'eligible' : 'ineligible'}" 
                             id="shopeeCard_${v.code}"
                             data-code="${v.code}"
                             data-type="food"
                             data-eligible="${isEligible}"
                             onclick="${isEligible ? 'selectCandidateFood(\"' : ''}${isEligible ? v.code : ''}${isEligible ? '\")' : ''}">
                            <!-- Left Stub -->
                            <div class="ticket-stub ${v.discountType == 'PERCENT' ? 'percent' : ''}">
                                <i class="fa-solid fa-utensils stub-icon"></i>
                                <span class="stub-badge">${v.badge}</span>
                                <span class="stub-code">${v.code}</span>
                            </div>

                            <!-- Right Details -->
                            <div class="ticket-content">
                                <div class="ticket-header">
                                    <div>
                                        <h4 class="ticket-title">${v.title}</h4>
                                        <p class="ticket-desc">${v.description}</p>
                                        <c:if test="${not empty v.restaurantId and v.restaurantId > 0}">
                                            <span class="badge-restaurant-promo">
                                                <i class="fa-solid fa-store me-1"></i> Quán: ${v.restaurantName}
                                            </span>
                                        </c:if>
                                    </div>
                                    <div class="ticket-radio-wrap">
                                        <input type="radio" name="shopeeFoodRadio" id="radioFood_${v.code}" value="${v.code}"
                                               ${not isEligible ? 'disabled' : ''}
                                               onclick="event.stopPropagation(); selectCandidateFood('${v.code}')">
                                    </div>
                                </div>
                                <div class="ticket-meta">
                                    <span class="ticket-cond ${isEligible ? '' : 'ineligible'}">
                                        <c:choose>
                                            <c:when test="${not isRestEligible}">
                                                <i class="fa-solid fa-circle-xmark"></i> Chỉ dùng cho quán ${v.restaurantName}
                                            </c:when>
                                            <c:when test="${not isOrderEligible}">
                                                <i class="fa-solid fa-circle-exclamation"></i> Cần thêm ${String.format("%,.0f", v.minOrderAmount - totalBill)} đ
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-circle-check"></i> Đủ điều kiện sử dụng
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <c:if test="${v.quantity > 0}">
                                        <span class="wallet-badge-pill">
                                            <i class="fa-solid fa-bookmark"></i> Số lượng: x${v.quantity}
                                        </span>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

        </div>

        <!-- Sticky Footer -->
        <div class="shopee-modal-footer">
            <button type="button" class="btn-shopee-none" onclick="clearAllVouchers()" title="Bỏ chọn không áp dụng mã nào">
                <i class="fa-solid fa-ban"></i> Không áp mã
            </button>
            <div class="shopee-footer-right">
                <button type="button" class="btn-shopee-cancel" onclick="closeShopeeVoucherModal()">Trở lại</button>
                <button type="button" class="btn-shopee-confirm" onclick="confirmShopeeVouchers()">Đồng ý</button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/vn-address-picker.js"></script>
<script>
let currentShippingFee = 15000;
let activeShippingCode = '';
let activeFoodCode = '';
let activeShippingDiscount = 0;
let activeFoodDiscount = 0;
let activeTotalDiscount = 0;

let candidateShippingCode = '';
let candidateFoodCode = '';

const baseTotal = ${totalBill != null ? totalBill : 0};
const cartRestId = ${cartRestaurantId != null ? cartRestaurantId : 1};
const currentUserId = ${sessionScope.currentUser != null ? sessionScope.currentUser.id : 0};

function recalculateShippingFeeDisplay() {
    const feeSpan = document.getElementById('shippingFee');
    if (!feeSpan) return;
    if (activeShippingDiscount > 0) {
        const remainingFee = Math.max(0, currentShippingFee - activeShippingDiscount);
        feeSpan.innerHTML = '<span style="text-decoration: line-through; color: #94a3b8; font-size: 0.88em; margin-right: 6px;">' + 
            Math.round(currentShippingFee).toLocaleString('vi-VN') + ' đ</span>' +
            '<strong style="color: #10ac84;">' + 
            (remainingFee === 0 ? '0 đ (Miễn phí)' : (Math.round(remainingFee).toLocaleString('vi-VN') + ' đ')) + '</strong>';
    } else {
        feeSpan.innerText = Math.round(currentShippingFee).toLocaleString('vi-VN') + ' đ';
    }
}

function recalculateGrandTotal() {
    recalculateShippingFeeDisplay();
    const finalTotalDisplay = document.getElementById('finalTotalDisplay');
    const finalTotal = Math.max(0, baseTotal + currentShippingFee - activeTotalDiscount);
    if (finalTotalDisplay) {
        finalTotalDisplay.innerText = Math.round(finalTotal).toLocaleString('vi-VN') + ' đ';
    }
}

function updateShopeeVoucherBar() {
    const bar = document.getElementById('shopeeVoucherBar');
    const text = document.getElementById('svbBadgeText');
    if (!bar || !text) return;

    if (activeTotalDiscount > 0) {
        bar.classList.add('has-voucher');
        let label = '';
        if (activeShippingCode && activeFoodCode) {
            label = activeShippingCode + ' + ' + activeFoodCode;
        } else {
            label = activeShippingCode || activeFoodCode;
        }
        text.innerHTML = '<span class="svb-applied-tag">-' + Math.round(activeTotalDiscount).toLocaleString('vi-VN') + ' đ</span> ' + label;
    } else {
        bar.classList.remove('has-voucher');
        text.innerText = 'Áp mã ưu đãi';
    }
}

function openShopeeVoucherModal() {
    candidateShippingCode = activeShippingCode || '';
    candidateFoodCode = activeFoodCode || '';
    syncModalRadioSelections();
    const modal = document.getElementById('shopeeVoucherModal');
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeShopeeVoucherModal() {
    const modal = document.getElementById('shopeeVoucherModal');
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}

function handleShopeeOverlayClick(event) {
    if (event.target && event.target.id === 'shopeeVoucherModal') {
        closeShopeeVoucherModal();
    }
}

function selectCandidateShipping(code) {
    candidateShippingCode = code || '';
    syncModalRadioSelections();
}

function selectCandidateFood(code) {
    candidateFoodCode = code || '';
    syncModalRadioSelections();
}

function syncModalRadioSelections() {
    // Shipping radios
    const shipRadios = document.querySelectorAll('input[name="shopeeShippingRadio"]');
    shipRadios.forEach(r => {
        r.checked = (r.value === candidateShippingCode);
    });
    document.querySelectorAll('.freeship-card').forEach(card => {
        const code = card.getAttribute('data-code');
        if (code === candidateShippingCode) card.classList.add('selected');
        else card.classList.remove('selected');
    });

    // Food radios
    const foodRadios = document.querySelectorAll('input[name="shopeeFoodRadio"]');
    foodRadios.forEach(r => {
        r.checked = (r.value === candidateFoodCode);
    });
    document.querySelectorAll('.food-card').forEach(card => {
        const code = card.getAttribute('data-code');
        if (code === candidateFoodCode) card.classList.add('selected');
        else card.classList.remove('selected');
    });
}

function confirmShopeeVouchers() {
    if (candidateShippingCode || candidateFoodCode) {
        applyDualVouchers(candidateShippingCode, candidateFoodCode);
    } else {
        clearAllVouchers();
    }
    closeShopeeVoucherModal();
}

function clearAllVouchers() {
    candidateShippingCode = '';
    candidateFoodCode = '';
    removeDualVouchers();
    closeShopeeVoucherModal();
    if (typeof window.showToast === 'function') {
        window.showToast('ℹ️ Bạn đã chọn không áp dụng mã giảm giá.');
    }
}

function applyDualVouchers(shippingCode, foodCode) {
    shippingCode = (shippingCode || '').trim().toUpperCase();
    foodCode = (foodCode || '').trim().toUpperCase();

    if (!shippingCode && !foodCode) {
        removeDualVouchers();
        return;
    }

    const url = '${pageContext.request.contextPath}/api/voucher?action=validate-dual' +
                '&shippingCode=' + encodeURIComponent(shippingCode) +
                '&freeshipCode=' + encodeURIComponent(shippingCode) +
                '&foodCode=' + encodeURIComponent(foodCode) +
                '&subtotal=' + encodeURIComponent(baseTotal) +
                '&shippingFee=' + encodeURIComponent(currentShippingFee) +
                '&restaurantId=' + encodeURIComponent(cartRestId);

    fetch(url)
        .then(r => r.json())
        .then(data => {
            if (data.valid) {
                activeShippingCode = data.shippingCode || data.appliedFreeshipCode || (data.shippingDiscount > 0 ? shippingCode : '');
                activeFoodCode = data.foodCode || data.appliedFoodCode || (data.foodDiscount > 0 ? foodCode : '');
                activeShippingDiscount = data.shippingDiscount || 0;
                activeFoodDiscount = data.foodDiscount || 0;
                activeTotalDiscount = data.totalDiscount || 0;

                // Hidden form inputs
                const shipInput = document.getElementById('shippingVoucherCode');
                const foodInput = document.getElementById('foodVoucherCode');
                const combinedInput = document.getElementById('appliedVoucherCode');
                if (shipInput) shipInput.value = activeShippingCode;
                if (foodInput) foodInput.value = activeFoodCode;
                if (combinedInput) combinedInput.value = data.combinedCode || '';

                // Summary lines
                const shipRow = document.getElementById('shippingDiscountRow');
                const shipVal = document.getElementById('shippingDiscountVal');
                const shipDisplay = document.getElementById('shippingDiscountCodeDisplay');
                if (shipRow && shipVal && shipDisplay) {
                    if (activeShippingDiscount > 0) {
                        shipRow.style.display = 'flex';
                        shipVal.innerText = '-' + Math.round(activeShippingDiscount).toLocaleString('vi-VN') + ' đ';
                        shipDisplay.innerText = activeShippingCode;
                    } else {
                        shipRow.style.display = 'none';
                    }
                }

                const foodRow = document.getElementById('foodDiscountRow');
                const foodVal = document.getElementById('foodDiscountVal');
                const foodDisplay = document.getElementById('foodDiscountCodeDisplay');
                if (foodRow && foodVal && foodDisplay) {
                    if (activeFoodDiscount > 0) {
                        foodRow.style.display = 'flex';
                        foodVal.innerText = '-' + Math.round(activeFoodDiscount).toLocaleString('vi-VN') + ' đ';
                        foodDisplay.innerText = activeFoodCode;
                    } else {
                        foodRow.style.display = 'none';
                    }
                }

                const totalRow = document.getElementById('discountRow');
                const totalVal = document.getElementById('discountVal');
                const totalDisplay = document.getElementById('discountCodeDisplay');
                if (totalRow && totalVal && totalDisplay) {
                    if (activeTotalDiscount > 0) {
                        totalRow.style.display = 'flex';
                        totalVal.innerText = '-' + Math.round(activeTotalDiscount).toLocaleString('vi-VN') + ' đ';
                        totalDisplay.innerText = data.combinedCode || '';
                    } else {
                        totalRow.style.display = 'none';
                    }
                }

                // Applied Card
                const appliedCard = document.getElementById('voucherAppliedCard');
                const appliedVCode = document.getElementById('appliedVCode');
                const appliedVTitle = document.getElementById('appliedVTitle');
                const appliedVDesc = document.getElementById('appliedVDesc');
                if (appliedCard && appliedVCode && appliedVTitle && appliedVDesc) {
                    appliedCard.style.display = 'flex';
                    appliedVCode.innerText = data.combinedCode || 'VOUCHER';
                    appliedVTitle.innerText = 'Đã giảm: ' + Math.round(activeTotalDiscount).toLocaleString('vi-VN') + ' đ';
                    appliedVDesc.innerText = data.message || 'Áp dụng mã ưu đãi thành công';
                }

                updateShopeeVoucherBar();
                recalculateGrandTotal();

                if (typeof window.showToast === 'function') {
                    window.showToast('✅ Đã áp dụng mã: ' + data.combinedCode + ' (Giảm ' + Math.round(activeTotalDiscount).toLocaleString('vi-VN') + ' đ)');
                }
            } else {
                if (typeof window.showToast === 'function') {
                    window.showToast('❌ ' + data.message);
                } else {
                    alert(data.message);
                }
            }
        })
        .catch(err => {
            console.error('Lỗi khi thẩm định voucher:', err);
            alert('Có lỗi khi kết nối máy chủ để thẩm định mã.');
        });
}

function removeDualVouchers() {
    activeShippingCode = '';
    activeFoodCode = '';
    activeShippingDiscount = 0;
    activeFoodDiscount = 0;
    activeTotalDiscount = 0;

    const shipInput = document.getElementById('shippingVoucherCode');
    const foodInput = document.getElementById('foodVoucherCode');
    const combinedInput = document.getElementById('appliedVoucherCode');
    if (shipInput) shipInput.value = '';
    if (foodInput) foodInput.value = '';
    if (combinedInput) combinedInput.value = '';

    const shipRow = document.getElementById('shippingDiscountRow');
    const foodRow = document.getElementById('foodDiscountRow');
    const totalRow = document.getElementById('discountRow');
    if (shipRow) shipRow.style.display = 'none';
    if (foodRow) foodRow.style.display = 'none';
    if (totalRow) totalRow.style.display = 'none';

    const appliedCard = document.getElementById('voucherAppliedCard');
    if (appliedCard) appliedCard.style.display = 'none';

    updateShopeeVoucherBar();
    syncModalRadioSelections();
    recalculateGrandTotal();
}

function applyShopeeInputCode() {
    const input = document.getElementById('shopeeInputCode');
    const code = (input ? input.value : '').trim().toUpperCase();
    const fb = document.getElementById('shopeeInputFeedback');
    if (!code) {
        if (fb) {
            fb.style.display = 'block';
            fb.innerHTML = '<span style="color: #ef4444;"><i class="fa-solid fa-circle-exclamation"></i> Vui lòng nhập mã voucher!</span>';
        }
        return;
    }

    if (fb) {
        fb.style.display = 'block';
        fb.innerHTML = '<span style="color: #64748b;"><i class="fa-solid fa-spinner fa-spin"></i> Đang kiểm tra...</span>';
    }

    const url = '${pageContext.request.contextPath}/api/voucher?action=validate&code=' + encodeURIComponent(code) +
                '&subtotal=' + encodeURIComponent(baseTotal) +
                '&shippingFee=' + encodeURIComponent(currentShippingFee) +
                '&restaurantId=' + encodeURIComponent(cartRestId);

    fetch(url)
        .then(r => r.json())
        .then(data => {
            if (data.valid) {
                if (data.isFreeShip) {
                    candidateShippingCode = data.code || code;
                } else {
                    candidateFoodCode = data.code || code;
                }
                syncModalRadioSelections();
                if (fb) {
                    fb.innerHTML = '<span style="color: #10ac84; font-weight: 600;"><i class="fa-solid fa-circle-check"></i> ' + data.message + ' (Đã chọn vào mục ' + (data.isFreeShip ? 'Freeship' : 'Món ăn') + ')</span>';
                }
            } else {
                if (fb) {
                    fb.innerHTML = '<span style="color: #ef4444; font-weight: 600;"><i class="fa-solid fa-circle-exclamation"></i> ' + data.message + '</span>';
                }
            }
        })
        .catch(() => {
            if (fb) {
                fb.innerHTML = '<span style="color: #ef4444;">Có lỗi kết nối. Vui lòng thử lại!</span>';
            }
        });
}

function updateShippingFeeFromAddress(addressText, lat, lng) {
    if (!addressText || addressText.trim().length < 3) return;
    
    let url = '${pageContext.request.contextPath}/api/shipping-fee?restaurantId=' + cartRestId + '&address=' + encodeURIComponent(addressText);
    if (lat && lng) {
        url += '&lat=' + encodeURIComponent(lat) + '&lng=' + encodeURIComponent(lng);
    }

    fetch(url)
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                currentShippingFee = data.shippingFee;
                const feeSpan = document.getElementById('shippingFee');
                if (feeSpan && activeShippingDiscount === 0) {
                    feeSpan.innerText = data.formattedFee;
                }
                const noticeBox = document.getElementById('shippingDistanceNotice');
                const distText = document.getElementById('distText');
                if (noticeBox && distText) {
                    noticeBox.style.display = 'block';
                    distText.innerHTML = '<strong>Khoảng cách giao:</strong> ' + data.distanceKm + ' km (Ước tính ' + data.estimatedMinutes + ' phút) &bull; <strong>Cước ship:</strong> ' + data.formattedFee;
                }
                // Nếu đang dùng mã giảm giá, tính lại theo phí ship mới
                if (activeShippingCode || activeFoodCode) {
                    applyDualVouchers(activeShippingCode, activeFoodCode);
                } else {
                    recalculateGrandTotal();
                }
            }
        })
        .catch(err => console.error('Lỗi tính phí ship:', err));
}

function locateUserForShipping() {
    const btn = document.getElementById('btnCartGPS');
    if (!navigator.geolocation) {
        alert('Trình duyệt của bạn không hỗ trợ định vị GPS!');
        return;
    }
    
    if (btn) {
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Đang lấy tọa độ...';
        btn.disabled = true;
    }

    navigator.geolocation.getCurrentPosition(
        function(pos) {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            
            fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng + '&accept-language=vi')
                .then(r => r.json())
                .then(geoData => {
                    let fullAddr = geoData && geoData.display_name ? geoData.display_name : ('Vị trí GPS (' + lat.toFixed(4) + ', ' + lng.toFixed(4) + '), TP. Hồ Chí Minh');
                    const addrInput = document.getElementById('receiverAddress');
                    if (addrInput) {
                        addrInput.value = fullAddr;
                    }
                    updateShippingFeeFromAddress(fullAddr, lat, lng);
                    if (btn) {
                        btn.innerHTML = '<i class="fa-solid fa-check text-success me-1"></i> Đã nhận vị trí';
                        setTimeout(() => {
                            btn.innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Định vị GPS của tôi';
                            btn.disabled = false;
                        }, 3000);
                    }
                })
                .catch(() => {
                    const fallbackAddr = 'Vị trí GPS (' + lat.toFixed(4) + ', ' + lng.toFixed(4) + '), TP. Hồ Chí Minh';
                    const addrInput = document.getElementById('receiverAddress');
                    if (addrInput) {
                        addrInput.value = fallbackAddr;
                    }
                    updateShippingFeeFromAddress(fallbackAddr, lat, lng);
                    if (btn) {
                        btn.innerHTML = '<i class="fa-solid fa-check text-success me-1"></i> Đã nhận vị trí';
                        btn.disabled = false;
                    }
                });
        },
        function(err) {
            alert('Không thể truy cập GPS: ' + err.message + '. Bạn có thể chọn địa chỉ từ danh sách.');
            if (btn) {
                btn.innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Định vị GPS của tôi';
                btn.disabled = false;
            }
        },
        { timeout: 8000 }
    );
}

document.addEventListener('DOMContentLoaded', function() {
    const addrInput = document.getElementById('receiverAddress');
    if (document.getElementById('cartVNAddressPicker') && typeof VNAddressPicker !== 'undefined') {
        VNAddressPicker.init({
            container: 'cartVNAddressPicker',
            targetInput: 'receiverAddress',
            initialAddress: addrInput ? addrInput.value : ''
        });
    }

    if (addrInput && addrInput.value) {
        updateShippingFeeFromAddress(addrInput.value);
    }

    if (addrInput) {
        let lastVal = addrInput.value;
        setInterval(function() {
            if (addrInput.value && addrInput.value !== lastVal) {
                lastVal = addrInput.value;
                updateShippingFeeFromAddress(lastVal);
            }
        }, 800);
    }

    // Tự động áp dụng lại mã voucher nếu trước đó có lỗi sticky form
    const shipInput = document.getElementById('shippingVoucherCode');
    const foodInput = document.getElementById('foodVoucherCode');
    const appliedInput = document.getElementById('appliedVoucherCode');
    const sVal = shipInput ? shipInput.value.trim() : '';
    const fVal = foodInput ? foodInput.value.trim() : '';
    const aVal = appliedInput ? appliedInput.value.trim() : '';

    if (sVal || fVal) {
        applyDualVouchers(sVal, fVal);
    } else if (aVal) {
        if (aVal.indexOf(',') !== -1) {
            const parts = aVal.split(',');
            applyDualVouchers(parts[0].trim(), parts[1].trim());
        } else {
            applyDualVouchers('', aVal);
        }
    } else {
        // Tự động tìm và áp mã giảm giá tốt nhất cho khách hàng
        checkAndAutoApplyBestVouchers();
        updateShopeeVoucherBar();
    }

    // Đồng bộ Kho Voucher
    if (typeof window.updateVoucherSaveButtons === 'function') {
        window.updateVoucherSaveButtons();
    }
});

function toggleQuickNote(chipEl, targetInputId, noteText) {
    const input = document.getElementById(targetInputId);
    if (!input) return;
    let currentVal = input.value.trim();
    chipEl.classList.toggle('active');
    const isActive = chipEl.classList.contains('active');
    
    if (isActive) {
        if (currentVal.length > 0) {
            input.value = currentVal + ', ' + noteText;
        } else {
            input.value = noteText;
        }
    } else {
        let parts = currentVal.split(',').map(function(s) { return s.trim(); }).filter(function(s) { return s && s !== noteText; });
        input.value = parts.join(', ');
    }
}

function checkAndAutoApplyBestVouchers() {
    let bestShip = '';
    let bestFood = '';
    if (baseTotal >= 99000) {
        bestShip = 'FREESHIP';
    }
    if (baseTotal >= 60000) {
        bestFood = 'UTEE30';
    } else if (baseTotal >= 50000) {
        bestFood = 'UTEE20';
    } else if (baseTotal >= 30000) {
        bestFood = 'UTEE15';
    }
    if (bestShip || bestFood) {
        applyDualVouchers(bestShip, bestFood);
        if (typeof window.showToast === 'function') {
            window.showToast('✨ Hệ thống đã tự động chọn ưu đãi tốt nhất cho đơn hàng của bạn!');
        }
    }
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const modal = document.getElementById('shopeeVoucherModal');
        if (modal && modal.classList.contains('active')) {
            closeShopeeVoucherModal();
        }
    }
});

<c:if test="${orderSuccess}">
document.addEventListener('DOMContentLoaded', function() {
    const modal = document.getElementById('orderSuccessModal');
    if (modal) {
        modal.classList.add('active');
    }
});
</c:if>
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

