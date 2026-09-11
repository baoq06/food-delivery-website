<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Đăng Nhập & Đăng Ký - Utee Food Delivery" />
    <jsp:param name="isAuthPage" value="true" />
</jsp:include>

<!-- Hide generic topbar, nav and footer for dedicated 100vh full-bleed split auth view -->
<style>
    .topbar, .navbar, .footer { display: none !important; }
    .main-content { padding: 0 !important; margin: 0 !important; min-height: 100vh !important; }
    body { background: #ffffff !important; overflow-x: hidden; }
</style>

<div class="auth-fullscreen-split">
    <!-- ===================================================================
         LEFT COLUMN (FULL BLEED): Cinematic Visual & Sleek Ambient Brand
         =================================================================== -->
    <div class="auth-split-visual">
        <!-- Ambient subtle glow accents -->
        <div class="auth-visual-glow auth-glow-1"></div>
        <div class="auth-visual-glow auth-glow-2"></div>

        <!-- Full-bleed background image -->
        <img src="${pageContext.request.contextPath}/assets/images/log_sign_in_image_food.jpg" 
             alt="Utee Food Delivery" 
             class="auth-split-bg-img" 
             loading="eager">
        
        <!-- Deep cinematic gradient overlay with warm undertones -->
        <div class="auth-split-overlay"></div>

        <!-- Top branding over image -->
        <div class="auth-visual-top-bar">
            <a href="${pageContext.request.contextPath}/home" class="auth-visual-brand-badge" title="Trang chủ Utee">
                <img src="${pageContext.request.contextPath}/assets/images/logo/logo-light-transparent.png" alt="Utee" class="auth-visual-logo-img">
                <span class="auth-visual-tagline-badge">
                    <span class="auth-pulse-dot"></span>
                    <span>Ăn ngon mỗi ngày</span>
                </span>
            </a>
        </div>

        <!-- Bottom brand story: Simplified, inspiring, no text fatigue -->
        <div class="auth-visual-bottom-content">
            <div class="auth-visual-chip">
                <i class="fa-solid fa-bolt-lightning"></i>
                <span>Giao nhanh 30 phút</span>
            </div>

            <h1 class="auth-visual-headline">
                Món ngon tận nơi,<br>
                <span class="auth-gradient-text">trọn vị từng bữa.</span>
            </h1>
            <p class="auth-visual-subheadline">
                Khám phá hàng ngàn món ăn hấp dẫn cùng ngập tràn ưu đãi mỗi ngày.
            </p>

            <!-- Minimalist Stats / Feature Pill Strip -->
            <div class="auth-mini-perks">
                <div class="auth-perk-pill">
                    <i class="fa-solid fa-ticket"></i>
                    <span>Voucher 30K</span>
                </div>
                <div class="auth-perk-pill">
                    <i class="fa-solid fa-star"></i>
                    <span>4.9/5 đánh giá</span>
                </div>
                <div class="auth-perk-pill">
                    <i class="fa-solid fa-shield-halved"></i>
                    <span>Quán chọn lọc</span>
                </div>
            </div>
        </div>
    </div>

    <!-- ===================================================================
         RIGHT COLUMN: Streamlined Authentication Form (Login / Register)
         =================================================================== -->
    <div class="auth-split-form-panel">
        <!-- Top header action bar inside form panel -->
        <div class="auth-form-topbar">
            <a href="${pageContext.request.contextPath}/home" class="auth-back-home-btn" title="Quay lại trang chủ">
                <i class="fa-solid fa-arrow-left"></i>
                <span>Trang chủ</span>
            </a>
            <a href="tel:19006868" class="auth-support-pill">
                <i class="fa-solid fa-headset text-primary"></i>
                <span>1900 6868</span>
            </a>
        </div>

        <!-- Centered Interactive Form Card -->
        <div class="auth-form-central-card">
            <!-- Brand header for right panel -->
            <div class="auth-form-heading">
                <a href="${pageContext.request.contextPath}/home" class="auth-mobile-logo-link">
                    <img src="${pageContext.request.contextPath}/assets/images/logo/logo-dark-transparent.png" alt="Utee" class="auth-form-logo-img">
                </a>
                <h2 class="auth-form-main-title" id="authTitleText">Đăng nhập</h2>
                <p class="auth-form-desc" id="authDescText">Mừng bạn quay lại với Utee</p>
            </div>

            <!-- Segmented Pill Tabs Switcher -->
            <div class="auth-segmented-tabs" role="tablist">
                <button type="button" class="auth-segmented-tab active" id="tabLoginBtn" onclick="switchAuthTab('loginTab')">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    <span>Đăng nhập</span>
                </button>
                <button type="button" class="auth-segmented-tab" id="tabRegisterBtn" onclick="switchAuthTab('registerTab')">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Đăng ký</span>
                </button>
            </div>

            <!-- Error Alert Banner -->
            <c:if test="${not empty errorMessage}">
                <div class="auth-error-banner" role="alert">
                    <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                    <div class="auth-error-msg">
                        <strong>Lưu ý:</strong> ${errorMessage}
                    </div>
                </div>
            </c:if>

            <!-- ==============================
                 FORM 1: ĐĂNG NHẬP (LOGIN)
                 ============================== -->
            <div id="loginTab" class="auth-tab-view active">
                <form action="${pageContext.request.contextPath}/auth" method="POST" class="auth-form-body" id="loginForm">
                    <input type="hidden" name="action" value="login">
                    <input type="hidden" name="redirect" value="<c:out value='${not empty param.redirect ? param.redirect : redirect}' />">
                    
                    <div class="auth-field-group">
                        <label for="loginUsername" class="auth-field-label">Tên đăng nhập</label>
                        <div class="auth-field-control">
                            <span class="auth-field-icon"><i class="fa-solid fa-user"></i></span>
                            <input type="text" id="loginUsername" name="username" class="auth-field-input" required 
                                   value="<c:out value='${not empty stickyUsername ? stickyUsername : (not empty cookieUsername ? cookieUsername : \"\")}' />"
                                   placeholder="Nhập tên đăng nhập">
                        </div>
                    </div>

                    <div class="auth-field-group">
                        <div class="auth-field-label-row">
                            <label for="loginPassword" class="auth-field-label">Mật khẩu</label>
                            <a href="javascript:void(0)" class="auth-forgot-link" onclick="alert('Vui lòng liên hệ hotline 1900 6868 hoặc dùng tài khoản thử bên dưới.'); return false;">Quên mật khẩu?</a>
                        </div>
                        <div class="auth-field-control">
                            <span class="auth-field-icon"><i class="fa-solid fa-lock"></i></span>
                            <input type="password" id="loginPassword" name="password" class="auth-field-input" required placeholder="Nhập mật khẩu">
                            <button type="button" class="auth-password-toggle-btn" onclick="togglePasswordVisibility('loginPassword', this)" title="Ẩn/hiện mật khẩu">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="auth-options-bar">
                        <label class="auth-checkbox-container">
                            <input type="checkbox" name="remember" ${(not empty stickyRemember and stickyRemember) or (empty stickyUsername and not empty cookieRemember and cookieRemember) ? 'checked' : ''}>
                            <span class="auth-checkbox-text">Ghi nhớ đăng nhập</span>
                        </label>
                    </div>

                    <button type="submit" class="auth-primary-submit-btn">
                        <span>Đăng nhập ngay</span>
                        <i class="fa-solid fa-arrow-right"></i>
                    </button>
                </form>

                <!-- Minimalist Inline Demo Quick Chips -->
                <div class="auth-demo-inline">
                    <span class="auth-demo-label"><i class="fa-solid fa-wand-magic-sparkles"></i> Thử nhanh:</span>
                    <button type="button" class="auth-demo-chip" onclick="fillDemo('customer', '123456')">
                        <span>👤 Khách hàng</span>
                    </button>
                    <button type="button" class="auth-demo-chip" onclick="fillDemo('bepviet', '123456')">
                        <span>🏪 Người bán hàng</span>
                    </button>
                    <button type="button" class="auth-demo-chip" onclick="fillDemo('kaitokid', '123456')">
                        <span>🛵 Shipper</span>
                    </button>
                    <button type="button" class="auth-demo-chip" onclick="fillDemo('admin', '123456')">
                        <span>⚡ Quản trị</span>
                    </button>
                </div>

                <div class="auth-tab-switch-footer">
                    <span>Chưa có tài khoản?</span>
                    <a href="javascript:void(0)" onclick="switchAuthTab('registerTab')" class="auth-switch-link">Đăng ký ngay</a>
                </div>
            </div>

            <!-- ==============================
                 FORM 2: ĐĂNG KÝ (REGISTER)
                 ============================== -->
            <div id="registerTab" class="auth-tab-view">
                <form action="${pageContext.request.contextPath}/auth" method="POST" class="auth-form-body" id="registerForm">
                    <input type="hidden" name="action" value="register">
                    <input type="hidden" name="redirect" value="<c:out value='${not empty param.redirect ? param.redirect : redirect}' />">
                    
                    <!-- Row 1: Họ tên & Tên đăng nhập (2 Cột cân xứng) -->
                    <div class="auth-fields-row-2">
                        <div class="auth-field-group">
                            <label for="regFullName" class="auth-field-label">Họ và tên *</label>
                            <div class="auth-field-control">
                                <span class="auth-field-icon"><i class="fa-solid fa-id-card"></i></span>
                                <input type="text" id="regFullName" name="fullName" class="auth-field-input" required 
                                       value="<c:out value='${stickyRegFullName}' />"
                                       placeholder="Nguyễn Văn A">
                            </div>
                        </div>

                        <div class="auth-field-group">
                            <label for="regUsername" class="auth-field-label">Tên đăng nhập *</label>
                            <div class="auth-field-control">
                                <span class="auth-field-icon"><i class="fa-solid fa-user"></i></span>
                                <input type="text" id="regUsername" name="username" class="auth-field-input" required 
                                       value="<c:out value='${stickyRegUsername}' />"
                                       placeholder="Chọn username">
                            </div>
                        </div>
                    </div>

                    <!-- Row 2: Mật khẩu & Số điện thoại (2 Cột cân xứng) -->
                    <div class="auth-fields-row-2">
                        <div class="auth-field-group">
                            <label for="regPassword" class="auth-field-label">Mật khẩu *</label>
                            <div class="auth-field-control">
                                <span class="auth-field-icon"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" id="regPassword" name="password" class="auth-field-input" required placeholder="Tối thiểu 6 ký tự">
                                <button type="button" class="auth-password-toggle-btn" onclick="togglePasswordVisibility('regPassword', this)" title="Ẩn/hiện mật khẩu">
                                    <i class="fa-regular fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="auth-field-group">
                            <label for="regPhone" class="auth-field-label">Số điện thoại *</label>
                            <div class="auth-field-control">
                                <span class="auth-field-icon"><i class="fa-solid fa-phone"></i></span>
                                <input type="tel" id="regPhone" name="phone" class="auth-field-input" required 
                                       value="<c:out value='${stickyRegPhone}' />"
                                       placeholder="0912 345 678">
                            </div>
                        </div>
                    </div>

                    <!-- Row 3: Địa chỉ nhận món -->
                    <div class="auth-field-group">
                        <label for="regAddress" class="auth-field-label">Địa chỉ nhận món *</label>
                        <div class="auth-field-control">
                            <span class="auth-field-icon"><i class="fa-solid fa-location-dot"></i></span>
                            <input type="text" id="regAddress" name="address" class="auth-field-input" required 
                                   value="<c:out value='${stickyRegAddress}' />"
                                   placeholder="Số nhà, tên đường, phường/xã...">
                        </div>
                    </div>

                    <!-- Row 4: Loại tài khoản - Clean & Compact -->
                    <div class="auth-field-group" style="margin-bottom: 12px;">
                        <label class="auth-field-label">Loại tài khoản</label>
                        <div class="auth-account-type-grid">
                            <label class="auth-type-radio-card ${empty stickyAccountType || stickyAccountType eq 'CUSTOMER' ? 'selected' : ''}">
                                <input type="radio" name="accountType" id="typeCustomer" value="CUSTOMER" ${empty stickyAccountType || stickyAccountType eq 'CUSTOMER' ? 'checked' : ''} onchange="toggleSellerFields()" />
                                <div class="type-radio-content">
                                    <div class="type-radio-icon">👤</div>
                                    <div class="type-radio-texts">
                                        <strong>Khách hàng</strong>
                                        <span>Đặt món ăn</span>
                                    </div>
                                </div>
                            </label>
                            <label class="auth-type-radio-card ${stickyAccountType eq 'SELLER' ? 'selected' : ''}">
                                <input type="radio" name="accountType" id="typeSeller" value="SELLER" ${stickyAccountType eq 'SELLER' ? 'checked' : ''} onchange="toggleSellerFields()" />
                                <div class="type-radio-content">
                                    <div class="type-radio-icon">🏪</div>
                                    <div class="type-radio-texts">
                                        <strong>Chủ quán ăn</strong>
                                        <span>Bán hàng</span>
                                    </div>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Extra Dynamic Field for Seller Mode -->
                    <div class="auth-seller-input-box" id="sellerFields" style="display: ${stickyAccountType eq 'SELLER' ? 'block' : 'none'};">
                        <label for="restaurantName" class="auth-field-label text-primary font-weight-bold">
                            <i class="fa-solid fa-store mr-1"></i> Tên quán ăn / Nhà hàng *
                        </label>
                        <div class="auth-field-control">
                            <span class="auth-field-icon"><i class="fa-solid fa-utensils text-primary"></i></span>
                            <input type="text" id="restaurantName" name="restaurantName" class="auth-field-input" 
                                   value="<c:out value='${stickyRestaurantName}' />"
                                   placeholder="Ví dụ: Bếp Việt Quán, Cơm Tấm Sài Gòn...">
                        </div>
                    </div>

                    <button type="submit" class="auth-primary-submit-btn" style="margin-top: 6px;">
                        <span>Tạo tài khoản ngay</span>
                        <i class="fa-solid fa-arrow-right"></i>
                    </button>
                </form>

                <div class="auth-tab-switch-footer">
                    <span>Đã có tài khoản?</span>
                    <a href="javascript:void(0)" onclick="switchAuthTab('loginTab')" class="auth-switch-link">Đăng nhập ngay</a>
                </div>
            </div>
        </div>

        <!-- Form Panel Footer Copyright -->
        <div class="auth-form-bottom-info">
            <p>© 2026 Utee Food Delivery. Nhanh chóng • Chuẩn vị • Tiện lợi.</p>
        </div>
    </div>
</div>

<script>
function switchAuthTab(tabId) {
    const btnLogin = document.getElementById('tabLoginBtn');
    const btnRegister = document.getElementById('tabRegisterBtn');
    const tabLogin = document.getElementById('loginTab');
    const tabRegister = document.getElementById('registerTab');
    const title = document.getElementById('authTitleText');
    const desc = document.getElementById('authDescText');

    if (tabId === 'loginTab') {
        btnLogin.classList.add('active');
        btnRegister.classList.remove('active');
        tabLogin.classList.add('active');
        tabRegister.classList.remove('active');
        if (title) title.innerText = 'Đăng nhập';
        if (desc) desc.innerText = 'Mừng bạn quay lại với Utee';
    } else {
        btnRegister.classList.add('active');
        btnLogin.classList.remove('active');
        tabRegister.classList.add('active');
        tabLogin.classList.remove('active');
        if (title) title.innerText = 'Tạo tài khoản';
        if (desc) desc.innerText = 'Nhận ngay ưu đãi cho đơn hàng đầu tiên';
    }
}

function togglePasswordVisibility(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}

function fillDemo(user, pass) {
    const userField = document.getElementById('loginUsername');
    const passField = document.getElementById('loginPassword');
    if (userField && passField) {
        userField.value = user;
        passField.value = pass;
        userField.focus();
    }
}

function toggleSellerFields() {
    const isSeller = document.getElementById('typeSeller').checked;
    const sellerBox = document.getElementById('sellerFields');
    const restNameInput = document.getElementById('restaurantName');
    const cards = document.querySelectorAll('.auth-type-radio-card');

    cards.forEach(c => c.classList.remove('selected'));
    if (isSeller) {
        if (cards[1]) cards[1].classList.add('selected');
        if (sellerBox) sellerBox.style.display = 'block';
        if (restNameInput) restNameInput.required = true;
    } else {
        if (cards[0]) cards[0].classList.add('selected');
        if (sellerBox) sellerBox.style.display = 'none';
        if (restNameInput) restNameInput.required = false;
    }
}

// Auto select tab if hash is #register or validation error redirected to register
<c:choose>
    <c:when test="${activeTab eq 'registerTab'}">
        switchAuthTab('registerTab');
    </c:when>
    <c:otherwise>
        if (window.location.hash === '#register') {
            switchAuthTab('registerTab');
        }
    </c:otherwise>
</c:choose>
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

