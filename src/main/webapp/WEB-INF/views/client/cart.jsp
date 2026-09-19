<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
            <div class="checkout-grid">
                <!-- Left: Cart Items List -->
                <div class="checkout-left">
                    <div class="checkout-box">
                        <div class="box-header">
                            <h3 class="box-title"><i class="fa-solid fa-bag-shopping text-primary"></i> Danh Sách Món Ăn (${sessionScope.cart.size()} món)</h3>
                            <a href="${pageContext.request.contextPath}/foods" class="continue-link"><i class="fa-solid fa-plus"></i> Thêm món khác</a>
                        </div>

                        <div class="cart-items-wrapper">
                            <c:set var="totalBill" value="0" />
                            <c:forEach items="${sessionScope.cart.values()}" var="item">
                                <c:set var="totalBill" value="${totalBill + item.totalPrice}" />
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

                    <!-- Voucher & Promo Code -->
                    <div class="checkout-box mt-3">
                        <div class="voucher-box">
                            <div class="voucher-input-wrap">
                                <i class="fa-solid fa-ticket text-primary"></i>
                                <input type="text" id="couponCode" placeholder="Nhập mã ưu đãi (Ví dụ: VINDELI15, VINDELI30)" class="form-control">
                                <button type="button" class="btn btn-outline btn-sm" onclick="applyCoupon()">Áp dụng</button>
                            </div>
                            <span id="couponMsg" class="coupon-feedback"></span>
                        </div>
                    </div>
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
                            <div class="summary-line text-success" id="discountRow" style="display: none;">
                                <span>Giảm giá voucher:</span>
                                <span id="discountVal">-15,000 đ</span>
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

<script src="${pageContext.request.contextPath}/assets/js/vn-address-picker.js"></script>
<script>
let currentShippingFee = 15000;
let hasDiscount = false;
const baseTotal = ${totalBill != null ? totalBill : 0};
const cartRestId = ${cartRestaurantId != null ? cartRestaurantId : 1};

function recalculateGrandTotal() {
    const finalTotalDisplay = document.getElementById('finalTotalDisplay');
    const discountAmount = hasDiscount ? 15000 : 0;
    const finalTotal = Math.max(0, baseTotal + currentShippingFee - discountAmount);
    if (finalTotalDisplay) {
        finalTotalDisplay.innerText = finalTotal.toLocaleString('vi-VN') + ' đ';
    }
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
                if (feeSpan) {
                    feeSpan.innerText = data.formattedFee;
                }
                const noticeBox = document.getElementById('shippingDistanceNotice');
                const distText = document.getElementById('distText');
                if (noticeBox && distText) {
                    noticeBox.style.display = 'block';
                    distText.innerHTML = '<strong>Khoảng cách giao:</strong> ' + data.distanceKm + ' km (Ước tính ' + data.estimatedMinutes + ' phút) &bull; <strong>Cước ship:</strong> ' + data.formattedFee;
                }
                recalculateGrandTotal();
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
            
            // Thử lấy tên địa chỉ qua Reverse Geocoding
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

    // Quan sát thay đổi địa chỉ từ picker
    if (addrInput) {
        let lastVal = addrInput.value;
        setInterval(function() {
            if (addrInput.value && addrInput.value !== lastVal) {
                lastVal = addrInput.value;
                updateShippingFeeFromAddress(lastVal);
            }
        }, 800);
    }
});

function applyCoupon() {
    const code = document.getElementById('couponCode').value.trim().toUpperCase();
    const msg = document.getElementById('couponMsg');
    const discountRow = document.getElementById('discountRow');

    if (code === 'VINDELI15' || code === 'VINDELI30' || code === 'WELCOME' || code === 'DELI15' || code === 'FOODZONE30') {
        hasDiscount = true;
        msg.innerHTML = '<span style="color: #10ac84; font-weight: 600;"><i class="fa-solid fa-check"></i> Áp dụng mã thành công! Giảm 15.000đ phí giao hàng.</span>';
        if (discountRow) discountRow.style.display = 'flex';
        recalculateGrandTotal();
    } else {
        msg.innerHTML = '<span style="color: #ee5253; font-weight: 500;"><i class="fa-solid fa-circle-exclamation"></i> Mã ưu đãi không hợp lệ hoặc đã hết hạn!</span>';
    }
}

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
