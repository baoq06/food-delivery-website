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

    /* Stepper 4 bước đăng ký */
    .auth-wizard-stepper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: relative;
        margin: 6px 0 16px 0;
        padding: 0 4px;
    }
    .auth-wizard-stepper::before {
        content: '';
        position: absolute;
        top: 14px;
        left: 20px;
        right: 20px;
        height: 3px;
        background: #e2e8f0;
        z-index: 1;
    }
    .stepper-progress-fill {
        position: absolute;
        top: 14px;
        left: 20px;
        height: 3px;
        background: linear-gradient(90deg, #ea580c, #f97316);
        z-index: 2;
        transition: width 0.35s ease;
        width: 0%;
    }
    .stepper-node {
        position: relative;
        z-index: 3;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
    }
    .stepper-circle {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: #ffffff;
        border: 2px solid #cbd5e1;
        color: #94a3b8;
        font-size: 0.76rem;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.25s ease;
    }
    .stepper-label {
        font-size: 0.72rem;
        font-weight: 600;
        color: #94a3b8;
        white-space: nowrap;
        transition: color 0.25s ease;
    }
    .stepper-node.active .stepper-circle {
        border-color: #ea580c;
        background: #ea580c;
        color: #ffffff;
        box-shadow: 0 0 0 3px rgba(234, 88, 12, 0.2);
    }
    .stepper-node.active .stepper-label {
        color: #ea580c;
        font-weight: 700;
    }
    .stepper-node.completed .stepper-circle {
        border-color: #10b981;
        background: #10b981;
        color: #ffffff;
    }
    .stepper-node.completed .stepper-label {
        color: #059669;
    }

    /* Email Box & Chip */
    .auth-email-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 14px 16px;
        margin-bottom: 12px;
    }
    .auth-email-input-wrap {
        display: flex;
        align-items: center;
        background: #ffffff;
        border: 1.5px solid #e2e8f0;
        border-radius: 12px;
        overflow: hidden;
        transition: all 0.22s ease;
        position: relative;
    }
    .auth-email-input-wrap:focus-within {
        border-color: #ea580c;
        box-shadow: 0 0 0 3.5px rgba(234, 88, 12, 0.14);
    }
    .auth-email-icon-box {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        height: 44px;
        background: #fff7ed;
        color: #ea580c;
        font-size: 1.05rem;
        border-right: 1px solid #fed7aa;
        flex-shrink: 0;
    }
    .auth-email-field {
        flex: 1;
        height: 44px;
        border: none;
        outline: none;
        padding: 0 12px;
        font-size: 0.95rem;
        font-weight: 600;
        color: #1e293b;
        background: transparent;
    }
    .auth-email-suggestion-chip {
        margin-right: 8px;
        padding: 4px 10px;
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
        border-radius: 20px;
        font-size: 0.74rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s;
        white-space: nowrap;
    }
    .auth-email-suggestion-chip:hover {
        background: #ea580c;
        color: #ffffff;
        border-color: #ea580c;
    }

    /* Verified Credentials Strip ở Bước 4 */
    .auth-verified-credentials-strip {
        background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);
        border: 1.5px solid #86efac;
        border-radius: 12px;
        padding: 10px 14px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
    }
    .verified-left {
        display: flex;
        align-items: center;
        gap: 10px;
        min-width: 0;
    }
    .verified-icon {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #22c55e;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.9rem;
        flex-shrink: 0;
    }
    .verified-text {
        font-size: 0.82rem;
        color: #166534;
        min-width: 0;
    }
    .verified-badge {
        background: #dcfce7;
        color: #15803d;
        font-size: 0.72rem;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 6px;
        border: 1px solid #86efac;
    /* Tự động co giãn theo nội dung, loại bỏ hoàn toàn giới hạn 480px / 380px gây đè chữ */
    .auth-tab-view {
        height: auto !important;
        min-height: auto !important;
        max-height: none !important;
        display: none;
    }
    .auth-tab-view.active {
        display: flex !important;
        flex-direction: column !important;
        justify-content: flex-start !important;
    }

    .auth-wizard-step {
        height: auto !important;
        min-height: auto !important;
        max-height: none !important;
        display: none;
        flex-direction: column;
        justify-content: flex-start;
    }
    .auth-wizard-step.active {
        display: flex !important;
    }

    /* Đảm bảo Switch Tab Footer nằm ngay dưới form, có khoảng cách rõ ràng, không đè lên nút hay card */
    .auth-tab-switch-footer {
        margin-top: 18px !important;
        padding-top: 14px !important;
        border-top: 1px dashed #e2e8f0 !important;
        position: relative !important;
        clear: both !important;
        width: 100% !important;
        text-align: center !important;
    }

    /* Tối ưu khoảng cách cho các nút điều hướng Wizard (Quay lại / Tiếp tục) */
    .auth-step-nav-actions {
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
        margin-top: 16px !important;
        margin-bottom: 6px !important;
    }

    /* Card lợi ích ở Bước 2 gọn gàng, tinh tế */
    .auth-phone-benefits {
        margin-top: 8px !important;
        margin-bottom: 4px !important;
        padding: 9px 12px !important;
        gap: 6px !important;
    }
    .auth-phone-benefit-item {
        font-size: 0.8rem !important;
        gap: 8px !important;
    }
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

                <!-- ===================================================================
                     KHU VỰC ĐĂNG NHẬP NHANH - DROPDOWN MENU TẤT CẢ USER TRONG DATABASE
                     =================================================================== -->
                <div class="auth-quick-login-wrap" id="authQuickLoginWrap">
                    <div class="auth-quick-login-header">
                        <span class="auth-quick-label">
                            <i class="fa-solid fa-wand-magic-sparkles text-warning"></i> Đăng nhập nhanh:
                        </span>
                        <span class="auth-quick-sub-count">${not empty allUsers ? allUsers.size() : 5} tài khoản trong DB</span>
                    </div>

                    <!-- Nút Bấm Kích Hoạt Dropdown Menu -->
                    <button type="button" class="auth-quick-dropdown-toggle" id="quickLoginDropdownToggle" onclick="toggleQuickLoginDropdown(event)" aria-expanded="false" aria-haspopup="true">
                        <div class="quick-toggle-left">
                            <span class="quick-toggle-icon"><i class="fa-solid fa-users"></i></span>
                            <span class="quick-toggle-text" id="quickToggleDisplay">Chọn tài khoản từ CSDL để đăng nhập nhanh...</span>
                        </div>
                        <i class="fa-solid fa-chevron-down quick-toggle-arrow" id="quickDropdownArrow"></i>
                    </button>

                    <!-- Dropdown Menu Box (Nổi bồng bềnh, hỗ trợ Tìm kiếm & Lọc theo Role) -->
                    <div class="auth-quick-dropdown-box" id="quickLoginDropdownBox" style="display: none;">
                        <!-- Thanh Tìm Kiếm Trực Tiếp Trong Dropdown -->
                        <div class="quick-dropdown-search-bar">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" id="quickUserSearchInput" class="quick-search-input" 
                                   placeholder="Tìm tên, username (@admin, @bepviet)..." 
                                   oninput="handleQuickUserSearch(this.value)">
                            <button type="button" class="quick-search-clear" id="quickSearchClearBtn" onclick="clearQuickUserSearch()" style="display:none;">&times;</button>
                        </div>

                        <!-- Thanh Lọc Theo Vai Trò (Role Tabs) -->
                        <div class="quick-role-tabs">
                            <button type="button" class="quick-role-tab active" onclick="filterQuickRole('ALL', this)">Tất cả</button>
                            <button type="button" class="quick-role-tab" onclick="filterQuickRole('ADMIN', this)"><i class="fa-solid fa-shield-halved me-1"></i> Quản trị</button>
                            <button type="button" class="quick-role-tab" onclick="filterQuickRole('SELLER', this)"><i class="fa-solid fa-store me-1"></i> Quán ăn</button>
                            <button type="button" class="quick-role-tab" onclick="filterQuickRole('SHIPPER', this)"><i class="fa-solid fa-motorcycle me-1"></i> Shipper</button>
                            <button type="button" class="quick-role-tab" onclick="filterQuickRole('CUSTOMER', this)"><i class="fa-solid fa-user me-1"></i> Khách</button>
                        </div>

                        <!-- Danh Sách Toàn Bộ Người Dùng Trong Database (Cuộn Mượt Mà) -->
                        <div class="quick-users-list" id="quickUsersScrollList">
                            <c:choose>
                                <c:when test="${not empty allUsers}">
                                    <c:forEach var="u" items="${allUsers}">
                                        <div class="quick-user-row" 
                                             data-role="${u.role}" 
                                             data-username="${u.username.toLowerCase()}" 
                                             data-name="${u.fullName.toLowerCase()}"
                                             onclick="applyQuickUser('${u.username}', '${not empty u.password ? u.password : '123456'}', false)">
                                            
                                            <div class="quick-user-avatar role-${u.role.toLowerCase()}">
                                                <c:choose>
                                                    <c:when test="${u.role eq 'ADMIN'}"><i class="fa-solid fa-shield-halved"></i></c:when>
                                                    <c:when test="${u.role eq 'SELLER'}"><i class="fa-solid fa-store"></i></c:when>
                                                    <c:when test="${u.role eq 'SHIPPER'}"><i class="fa-solid fa-motorcycle"></i></c:when>
                                                    <c:otherwise><i class="fa-solid fa-user"></i></c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="quick-user-info">
                                                <div class="quick-user-name-line">
                                                    <strong class="quick-user-fullname">${u.fullName}</strong>
                                                    <span class="quick-user-role-badge role-${u.role.toLowerCase()}">${u.role}</span>
                                                </div>
                                                <div class="quick-user-meta">
                                                    <span class="quick-user-uname">@${u.username}</span>
                                                    <span class="quick-user-meta-dot">•</span>
                                                    <span class="quick-user-pass">Mật khẩu: <code>${not empty u.password ? u.password : '123456'}</code></span>
                                                </div>
                                            </div>

                                            <!-- Nút Đăng Nhập Ngay 1-Click -->
                                            <button type="button" class="quick-login-now-btn" 
                                                    title="Đăng nhập ngay với tài khoản này"
                                                    onclick="event.stopPropagation(); applyQuickUser('${u.username}', '${not empty u.password ? u.password : '123456'}', true)">
                                                <i class="fa-solid fa-bolt"></i>
                                                <span>Vào ngay</span>
                                            </button>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <!-- Fallback nếu allUsers chưa load kịp -->
                                    <div class="quick-user-row" data-role="ADMIN" data-username="admin" data-name="quản trị viên" onclick="applyQuickUser('admin', '123456', false)">
                                        <div class="quick-user-avatar role-admin"><i class="fa-solid fa-shield-halved"></i></div>
                                        <div class="quick-user-info">
                                            <div class="quick-user-name-line">
                                                <strong class="quick-user-fullname">Quản Trị Viên (Admin)</strong>
                                                <span class="quick-user-role-badge role-admin">ADMIN</span>
                                            </div>
                                            <div class="quick-user-meta">
                                                <span class="quick-user-uname">@admin</span>
                                                <span class="quick-user-meta-dot">•</span>
                                                <span class="quick-user-pass">Mật khẩu: <code>123456</code></span>
                                            </div>
                                        </div>
                                        <button type="button" class="quick-login-now-btn" onclick="event.stopPropagation(); applyQuickUser('admin', '123456', true)">
                                            <i class="fa-solid fa-bolt"></i>
                                            <span>Vào ngay</span>
                                        </button>
                                    </div>
                                    <div class="quick-user-row" data-role="SELLER" data-username="bepviet" data-name="chủ quán bếp việt" onclick="applyQuickUser('bepviet', '123456', false)">
                                        <div class="quick-user-avatar role-seller"><i class="fa-solid fa-store"></i></div>
                                        <div class="quick-user-info">
                                            <div class="quick-user-name-line">
                                                <strong class="quick-user-fullname">Chủ Quán Bếp Việt</strong>
                                                <span class="quick-user-role-badge role-seller">SELLER</span>
                                            </div>
                                            <div class="quick-user-meta"><span class="quick-user-uname">@bepviet</span> • Mật khẩu: <code>123456</code></div>
                                        </div>
                                        <button type="button" class="quick-login-now-btn" onclick="event.stopPropagation(); applyQuickUser('bepviet', '123456', true)"><i class="fa-solid fa-bolt"></i> Vào ngay</button>
                                    </div>
                                    <div class="quick-user-row" data-role="SHIPPER" data-username="kaitokid" data-name="kiệt gia shipper" onclick="applyQuickUser('kaitokid', '123456', false)">
                                        <div class="quick-user-avatar role-shipper"><i class="fa-solid fa-motorcycle"></i></div>
                                        <div class="quick-user-info">
                                            <div class="quick-user-name-line">
                                                <strong class="quick-user-fullname">Kiệt Gia (Shipper)</strong>
                                                <span class="quick-user-role-badge role-shipper">SHIPPER</span>
                                            </div>
                                            <div class="quick-user-meta"><span class="quick-user-uname">@kaitokid</span> • Mật khẩu: <code>123456</code></div>
                                        </div>
                                        <button type="button" class="quick-login-now-btn" onclick="event.stopPropagation(); applyQuickUser('kaitokid', '123456', true)"><i class="fa-solid fa-bolt"></i> Vào ngay</button>
                                    </div>
                                    <div class="quick-user-row" data-role="CUSTOMER" data-username="customer" data-name="nguyễn văn khách" onclick="applyQuickUser('customer', '123456', false)">
                                        <div class="quick-user-avatar role-customer"><i class="fa-solid fa-user"></i></div>
                                        <div class="quick-user-info">
                                            <div class="quick-user-name-line">
                                                <strong class="quick-user-fullname">Nguyễn Văn Khách</strong>
                                                <span class="quick-user-role-badge role-customer">CUSTOMER</span>
                                            </div>
                                            <div class="quick-user-meta"><span class="quick-user-uname">@customer</span> • Mật khẩu: <code>123456</code></div>
                                        </div>
                                        <button type="button" class="quick-login-now-btn" onclick="event.stopPropagation(); applyQuickUser('customer', '123456', true)"><i class="fa-solid fa-bolt"></i> Vào ngay</button>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div id="quickUserNoResult" class="quick-user-no-result" style="display: none;">
                                <i class="fa-solid fa-user-slash"></i>
                                <span>Không tìm thấy người dùng phù hợp</span>
                            </div>
                        </div>
                    </div>

                    <!-- Shortcut Chips Nhanh 4 Vai Trò Phổ Biến -->
                    <div class="auth-demo-inline" style="margin-top: 8px;">
                        <span class="auth-demo-label"><i class="fa-solid fa-bolt-lightning"></i> Thử nhanh:</span>
                        <button type="button" class="auth-demo-chip" onclick="applyQuickUser('customer', '123456', false)" title="Điền tài khoản Khách hàng">
                            <span><i class="fa-solid fa-user me-1"></i> Khách</span>
                        </button>
                        <button type="button" class="auth-demo-chip" onclick="applyQuickUser('bepviet', '123456', false)" title="Điền tài khoản Quán ăn">
                            <span><i class="fa-solid fa-store me-1"></i> Quán ăn</span>
                        </button>
                        <button type="button" class="auth-demo-chip" onclick="applyQuickUser('kaitokid', '123456', false)" title="Điền tài khoản Shipper">
                            <span><i class="fa-solid fa-motorcycle me-1"></i> Shipper</span>
                        </button>
                        <button type="button" class="auth-demo-chip" onclick="applyQuickUser('admin', '123456', false)" title="Điền tài khoản Quản trị">
                            <span><i class="fa-solid fa-shield-halved me-1"></i> Admin</span>
                        </button>
                    </div>
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
                <form action="${pageContext.request.contextPath}/auth" method="POST" enctype="multipart/form-data" class="auth-form-body" id="registerForm" novalidate onsubmit="return validateFinalRegisterForm()">
                    <input type="hidden" name="action" value="register">
                    <input type="hidden" name="redirect" value="<c:out value='${not empty param.redirect ? param.redirect : redirect}' />">
                    <input type="hidden" name="accountType" id="wizardAccountType" value="<c:out value='${not empty stickyAccountType ? stickyAccountType : \"CUSTOMER\"}' />">
                    <input type="hidden" name="email" id="wizardSubmittedEmail" value="<c:out value='${stickyRegEmail}' />">
                    <input type="hidden" name="phone" id="wizardSubmittedPhone" value="<c:out value='${stickyRegPhone}' />">
                    <input type="hidden" name="address" id="wizardSubmittedAddress" value="<c:out value='${stickyRegAddress}' />">

                    <!-- Stepper Bar 4 Bước Đăng Ký -->
                    <div class="auth-wizard-stepper">
                        <div class="stepper-progress-fill" id="stepperProgressBar"></div>
                        <div class="stepper-node active" id="stepIndicator1">
                            <div class="stepper-circle">1</div>
                            <span class="stepper-label">Vai trò</span>
                        </div>
                        <div class="stepper-node" id="stepIndicator2">
                            <div class="stepper-circle">2</div>
                            <span class="stepper-label">Email OTP</span>
                        </div>
                        <div class="stepper-node" id="stepIndicator3">
                            <div class="stepper-circle">3</div>
                            <span class="stepper-label">Xác nhận</span>
                        </div>
                        <div class="stepper-node" id="stepIndicator4">
                            <div class="stepper-circle">4</div>
                            <span class="stepper-label">Thông tin</span>
                        </div>
                    </div>

                    <!-- ==============================================
                         BƯỚC 1: CHỌN LOẠI USER (Role Selection)
                         ============================================== -->
                    <div class="auth-wizard-step active" id="wizardStep1">
                        <p class="auth-step-instruction">
                            <i class="fa-solid fa-circle-info text-primary mr-1"></i>
                            Vui lòng chọn vai trò tài khoản bạn muốn đồng hành cùng Utee:
                        </p>

                        <div class="auth-role-cards-grid">
                            <!-- Role 1: Customer -->
                            <div class="auth-role-card ${empty stickyAccountType || stickyAccountType eq 'CUSTOMER' ? 'selected' : ''}" 
                                 id="roleCardCustomer" onclick="selectRole('CUSTOMER')">
                                 <div class="auth-role-icon-box role-icon-customer">
                                    <i class="fa-solid fa-user"></i>
                                </div>
                                <div class="auth-role-info">
                                    <div class="auth-role-header">
                                        <span class="auth-role-title">Khách hàng</span>
                                        <span class="auth-role-badge">Đặt món ăn</span>
                                    </div>
                                    <p class="auth-role-desc">Đặt món nhanh chóng từ hàng ngàn nhà hàng chuẩn vị, tận hưởng ngập tràn voucher ưu đãi mỗi ngày.</p>
                                </div>
                                <div class="auth-role-check"><i class="fa-solid fa-check"></i></div>
                            </div>

                            <!-- Role 2: Seller / Merchant -->
                            <div class="auth-role-card ${stickyAccountType eq 'SELLER' ? 'selected' : ''}" 
                                 id="roleCardSeller" onclick="selectRole('SELLER')">
                                <div class="auth-role-icon-box role-icon-seller">
                                    <i class="fa-solid fa-store"></i>
                                </div>
                                <div class="auth-role-info">
                                    <div class="auth-role-header">
                                        <span class="auth-role-title">Quán ăn / Nhà hàng</span>
                                        <span class="auth-role-badge" style="background:#fef3c7; color:#b45309;">Đối tác kinh doanh</span>
                                    </div>
                                    <p class="auth-role-desc">Mở rộng thực khách, quản lý món ăn linh hoạt, tối ưu doanh thu và nhận đơn liền tay.</p>
                                </div>
                                <div class="auth-role-check"><i class="fa-solid fa-check"></i></div>
                            </div>

                            <!-- Role 3: Shipper -->
                            <div class="auth-role-card ${stickyAccountType eq 'SHIPPER' ? 'selected' : ''}" 
                                 id="roleCardShipper" onclick="selectRole('SHIPPER')">
                                <div class="auth-role-icon-box role-icon-shipper">
                                    <i class="fa-solid fa-motorcycle"></i>
                                </div>
                                <div class="auth-role-info">
                                    <div class="auth-role-header">
                                        <span class="auth-role-title">Tài xế giao hàng (Shipper)</span>
                                        <span class="auth-role-badge" style="background:#d1fae5; color:#065f46;">15.000đ / đơn</span>
                                    </div>
                                    <p class="auth-role-desc">Thu nhập hấp dẫn, tự do chủ động thời gian, bật/tắt nhận đơn giao hàng bất cứ lúc nào.</p>
                                </div>
                                <div class="auth-role-check"><i class="fa-solid fa-check"></i></div>
                            </div>
                        </div>

                        <div class="auth-step-nav-actions" style="justify-content: flex-end;">
                            <button type="button" class="auth-primary-submit-btn" style="max-width: 200px;" onclick="goToStep(2)">
                                <span>Tiếp tục</span>
                                <i class="fa-solid fa-arrow-right"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ==============================================
                         BƯỚC 2: NHẬP EMAIL (GMAIL) VÀ SỐ ĐIỆN THOẠI
                         ============================================== -->
                    <div class="auth-wizard-step" id="wizardStep2">
                        <p class="auth-step-instruction">
                            <i class="fa-solid fa-envelope-circle-check text-primary mr-1"></i>
                            Nhập địa chỉ Email (Gmail) để nhận mã xác thực OTP 6 số kích hoạt tài khoản:
                        </p>

                        <!-- Box 1: Email Input (Gmail) -->
                        <div class="auth-email-box">
                            <label class="auth-field-label" for="wizardEmailInput">Địa chỉ Email (Gmail) nhận mã OTP *</label>
                            <div class="auth-email-input-wrap">
                                <div class="auth-email-icon-box">
                                    <i class="fa-solid fa-envelope"></i>
                                </div>
                                <input type="email" id="wizardEmailInput" class="auth-email-field"
                                       placeholder="vidu@gmail.com"
                                       value="<c:out value='${stickyRegEmail}' />"
                                       autocomplete="email"
                                       oninput="clearStepError('step2Error')">
                                <button type="button" class="auth-email-suggestion-chip" onclick="appendEmailDomain('@gmail.com')" title="Điền nhanh đuôi @gmail.com">
                                    <span>+ @gmail.com</span>
                                </button>
                            </div>
                            <div class="auth-phone-hint">
                                <i class="fa-solid fa-shield-halved text-success"></i>
                                <span>Mã OTP 6 số sẽ được gửi trực tiếp đến hộp thư Gmail này (hiệu lực 5 phút).</span>
                            </div>
                        </div>

                        <!-- Box 2: Số điện thoại liên hệ -->
                        <div class="auth-phone-box" style="margin-top: 10px;">
                            <label class="auth-field-label" for="wizardPhoneInput">Số điện thoại liên hệ nhận món *</label>
                            <div class="auth-phone-input-wrap">
                                <div class="auth-phone-prefix">
                                    <span style="font-weight: 800; font-size: 0.74rem; background: #fee2e2; color: #dc2626; padding: 2px 5px; border-radius: 4px; line-height: 1;">VN</span>
                                    <span>+84</span>
                                </div>
                                <input type="tel" id="wizardPhoneInput" class="auth-phone-field" 
                                       placeholder="0912 345 678" 
                                       value="<c:out value='${stickyRegPhone}' />" 
                                       maxlength="11" 
                                       onkeypress="return event.charCode >= 48 && event.charCode <= 57"
                                       oninput="clearStepError('step2Error')">
                            </div>
                            <div class="auth-phone-hint">
                                <i class="fa-solid fa-phone text-primary"></i>
                                <span>Dùng để tài xế liên hệ khi giao hàng và xác minh đơn hàng.</span>
                            </div>
                        </div>

                        <!-- Lợi ích bảo mật qua Gmail -->
                        <div class="auth-phone-benefits">
                            <div class="auth-phone-benefit-item">
                                <i class="fa-solid fa-shield-halved text-success"></i>
                                <span>Mã OTP 6 số gửi tức thì qua Gmail, bảo mật 2 lớp an toàn</span>
                            </div>
                        </div>

                        <!-- Error alert nếu nhập sai -->
                        <div id="step2Error" class="auth-error-banner" style="display:none; margin-bottom: 12px;">
                            <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                            <div class="auth-error-msg" id="step2ErrorMsg"></div>
                        </div>

                        <div class="auth-step-nav-actions">
                            <button type="button" class="auth-btn-back" onclick="goToStep(1)">
                                <i class="fa-solid fa-arrow-left"></i>
                                <span>Quay lại</span>
                            </button>
                            <button type="button" class="auth-primary-submit-btn" id="btnSendOtp" onclick="handleSendOtpClick()">
                                <span>Gửi mã OTP qua Gmail</span>
                                <i class="fa-solid fa-paper-plane"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ==============================================
                         BƯỚC 3: XÁC THỰC MÃ OTP (6 SỐ QUA GMAIL)
                         ============================================== -->
                    <div class="auth-wizard-step" id="wizardStep3">
                        <div class="auth-otp-box">
                            <div class="auth-otp-phone-display">
                                <i class="fa-solid fa-paper-plane text-primary me-1"></i> Mã xác thực OTP 6 số đã được gửi tới: 
                                <strong class="auth-otp-phone-number text-danger" id="step3EmailDisplay">...</strong>
                                <a href="javascript:void(0)" onclick="goToStep(2)" class="auth-otp-edit-phone">
                                    <i class="fa-solid fa-pen"></i> Đổi email
                                </a>
                            </div>

                            <!-- Thông báo gửi thật thành công qua Gmail -->
                            <div class="real-email-notice-card" id="realEmailNoticeCard" style="display:none; align-items: flex-start; gap: 12px; background: #f0fdf4; border: 1.5px solid #86efac; border-radius: 12px; padding: 14px 16px; margin-bottom: 16px; text-align: left; box-shadow: 0 4px 12px rgba(34, 197, 94, 0.08);">
                                <div style="width: 38px; height: 38px; min-width: 38px; border-radius: 50%; background: #22c55e; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.15rem; margin-top: 2px;">
                                    <i class="fa-solid fa-envelope-circle-check"></i>
                                </div>
                                <div style="flex: 1;">
                                    <div style="font-weight: 700; color: #15803d; font-size: 0.9rem;">
                                        <i class="fa-solid fa-circle-check"></i> Đã gửi thư xác thực tới Gmail!
                                    </div>
                                    <div style="font-size: 0.8rem; color: #166534; margin-top: 3px; line-height: 1.45;">
                                        Mã OTP 6 số đã được chuyển đến hòm thư <strong id="realEmailTargetDisplay" style="color:#0f172a;"></strong>.<br>
                                        Vui lòng mở ứng dụng <strong>Gmail</strong>, kiểm tra <strong>Hộp thư đến</strong> hoặc mục <strong>Thư rác / Spam</strong> để lấy mã.
                                    </div>
                                    <div style="margin-top: 8px;">
                                        <a href="https://mail.google.com" target="_blank" rel="noopener noreferrer" class="btn btn-sm" style="display: inline-flex; align-items: center; gap: 6px; background: #16a34a; color: #ffffff; border-radius: 8px; font-weight: 600; font-size: 0.78rem; text-decoration: none; padding: 5px 12px; box-shadow: 0 2px 6px rgba(22, 163, 74, 0.25);">
                                            <i class="fa-solid fa-arrow-up-right-from-square"></i> Mở Gmail lấy mã OTP
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Toast mô phỏng Gmail Push Notification (chỉ hiển thị khi chạy chế độ Dev Sandbox cho cộng sự) -->
                            <div class="simulated-sms-banner" id="simulatedSmsToast" style="display:none;">
                                <div class="simulated-sms-icon" style="background: #ea4335; color: #fff;">
                                    <i class="fa-solid fa-code"></i>
                                </div>
                                <div class="simulated-sms-body">
                                    <div class="simulated-sms-header">
                                        <span class="simulated-sms-sender">
                                            <i class="fa-solid fa-laptop-code text-warning"></i> DEV SANDBOX (DÀNH CHO CỘNG SỰ TEST)
                                        </span>
                                        <span class="simulated-sms-time">Vừa tạo</span>
                                    </div>
                                    <div class="simulated-sms-text">
                                        Mã OTP kiểm thử: <strong id="simulatedOtpCode" style="color:#fbbf24; font-size:1.2rem; letter-spacing:3px;">------</strong> (Hiệu lực 5 phút).
                                    </div>
                                    <div style="font-size: 0.76rem; color: #cbd5e1; margin-top: 4px;">
                                        * Hệ thống đang chạy chế độ Sandbox do máy chưa cấu hình API gửi thật. Bạn có thể bấm nút bên dưới để test nhanh:
                                    </div>
                                    <button type="button" class="simulated-sms-fill-btn" onclick="fillQuickOtp()">
                                        <i class="fa-solid fa-bolt"></i>
                                        <span>Điền nhanh mã OTP</span>
                                    </button>
                                </div>
                            </div>

                            <p style="font-size: 0.84rem; color: #64748b; margin-bottom: 8px;">Nhập 6 chữ số mã xác thực:</p>

                            <!-- 6 Digit OTP Inputs -->
                            <div class="auth-otp-inputs" id="otpInputsContainer">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp1" inputmode="numeric" autocomplete="one-time-code" oninput="onOtpInput(1, event)" onkeydown="onOtpKeyDown(1, event)">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp2" inputmode="numeric" oninput="onOtpInput(2, event)" onkeydown="onOtpKeyDown(2, event)">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp3" inputmode="numeric" oninput="onOtpInput(3, event)" onkeydown="onOtpKeyDown(3, event)">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp4" inputmode="numeric" oninput="onOtpInput(4, event)" onkeydown="onOtpKeyDown(4, event)">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp5" inputmode="numeric" oninput="onOtpInput(5, event)" onkeydown="onOtpKeyDown(5, event)">
                                <input type="text" maxlength="1" class="auth-otp-digit" id="otp6" inputmode="numeric" oninput="onOtpInput(6, event)" onkeydown="onOtpKeyDown(6, event)">
                            </div>

                            <div class="auth-otp-resend-row">
                                <span id="otpCountdownWrap">Gửi lại mã sau <strong id="otpTimerText" class="auth-otp-timer-badge">60s</strong></span>
                                <button type="button" id="btnResendOtp" class="auth-otp-resend-btn" style="display:none;" onclick="handleSendOtpClick()">
                                    <i class="fa-solid fa-rotate-right mr-1"></i> Gửi lại mã qua Gmail
                                </button>
                            </div>

                            <!-- Step 3 Error alert -->
                            <div id="step3Error" class="auth-error-banner" style="display:none; text-align: left; margin-bottom: 8px;">
                                <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                                <div class="auth-error-msg" id="step3ErrorMsg"></div>
                            </div>
                        </div>

                        <div class="auth-step-nav-actions">
                            <button type="button" class="auth-btn-back" onclick="goToStep(2)">
                                <i class="fa-solid fa-arrow-left"></i>
                                <span>Quay lại</span>
                            </button>
                            <button type="button" class="auth-primary-submit-btn" id="btnVerifyOtp" onclick="handleVerifyOtpClick()">
                                <span>Xác thực OTP</span>
                                <i class="fa-solid fa-check"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ==============================================
                         BƯỚC 4: NHẬP THÔNG TIN CÁ NHÂN & HỒ SƠ
                         ============================================== -->
                    <div class="auth-wizard-step" id="wizardStep4">
                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; flex-shrink: 0;">
                            <span class="auth-step-instruction" style="margin-bottom: 0;">Điền thông tin tài khoản:</span>
                            <span class="auth-role-badge" id="step4RoleBadge" style="font-size: 0.74rem; padding: 3px 8px;">Khách hàng</span>
                        </div>

                        <!-- Thông tin Email & SĐT đã xác thực -->
                        <div class="auth-verified-credentials-strip">
                            <div class="verified-left">
                                <div class="verified-icon">
                                    <i class="fa-solid fa-check"></i>
                                </div>
                                <div class="verified-text">
                                    <div style="font-size:0.75rem; color:#15803d; font-weight:600;">Email kích hoạt OTP:</div>
                                    <strong style="font-size:0.9rem; color:#14532d;" id="step4VerifiedEmailDisplay"><c:out value="${not empty stickyRegEmail ? stickyRegEmail : 'chua_xac_thuc@gmail.com'}" /></strong>
                                </div>
                            </div>
                            <span class="verified-badge"><i class="fa-solid fa-shield-check"></i> Đã xác thực</span>
                        </div>

                        <div class="auth-step4-scroll-body">
                            <!-- 1. Cụm thông tin chung: Họ tên & Username -->
                            <div class="auth-fields-row-2">
                                <div class="auth-field-group">
                                    <label for="regFullName" class="auth-field-label" id="lblFullName">Họ và tên *</label>
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

                            <!-- 2. Cụm Mật khẩu & Xác nhận Mật khẩu -->
                            <div class="auth-fields-row-2">
                                <div class="auth-field-group">
                                    <label for="regPassword" class="auth-field-label">Mật khẩu *</label>
                                    <div class="auth-field-control">
                                        <span class="auth-field-icon"><i class="fa-solid fa-lock"></i></span>
                                        <input type="password" id="regPassword" name="password" class="auth-field-input" required placeholder="Tối thiểu 6 ký tự">
                                        <button type="button" class="auth-password-toggle-btn" onclick="togglePasswordVisibility('regPassword', this)" title="Ẩn/hiện">
                                            <i class="fa-regular fa-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label for="regConfirmPassword" class="auth-field-label">Xác nhận mật khẩu *</label>
                                    <div class="auth-field-control">
                                        <span class="auth-field-icon"><i class="fa-solid fa-shield-check"></i></span>
                                        <input type="password" id="regConfirmPassword" name="confirmPassword" class="auth-field-input" required placeholder="Nhập lại mật khẩu">
                                        <button type="button" class="auth-password-toggle-btn" onclick="togglePasswordVisibility('regConfirmPassword', this)" title="Ẩn/hiện">
                                            <i class="fa-regular fa-eye"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- 3. PHẦN RIÊNG: KHÁCH HÀNG (CUSTOMER) -->
                            <div id="step4CustomerFields" style="display: block;">
                                <div class="auth-field-group mb-3">
                                    <label class="auth-field-label">Địa chỉ giao hàng mặc định *</label>
                                    <div id="regCustomerVNAddressPicker"></div>
                                    <input type="hidden" id="customerAddress" value="<c:out value='${stickyRegAddress}' />" />
                                </div>

                                <div class="auth-field-group">
                                    <label class="auth-field-label">Ảnh đại diện <span style="font-weight: normal; color: #94a3b8;">(Không bắt buộc)</span></label>
                                    <div class="auth-avatar-dropzone" onclick="document.getElementById('avatarFileCustomer').click()">
                                        <input type="file" id="avatarFileCustomer" name="avatarFile" accept="image/*" style="display: none;" onchange="previewAvatar(this, 'customerAvatarPreview')">
                                        <div class="auth-avatar-circle-preview" id="customerAvatarPreview">
                                            <i class="fa-solid fa-camera"></i>
                                        </div>
                                        <div class="auth-avatar-info">
                                            <strong>Tải ảnh đại diện</strong>
                                            <span>Bấm để chọn ảnh từ thiết bị của bạn (JPG, PNG)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 4. PHẦN RIÊNG: SHIPPER (TÀI XẾ GIAO HÀNG) -->
                            <div id="step4ShipperFields" style="display: none;">
                                <div class="auth-field-group">
                                    <label for="shipperAddress" class="auth-field-label">Địa chỉ thường trú / Chỗ ở hiện tại *</label>
                                    <div class="auth-field-control">
                                        <span class="auth-field-icon"><i class="fa-solid fa-house-user"></i></span>
                                        <input type="text" id="shipperAddress" class="auth-field-input" 
                                               value="<c:out value='${stickyRegAddress}' />"
                                               placeholder="Địa chỉ cư trú của tài xế...">
                                    </div>
                                </div>

                                <div class="auth-fields-row-2">
                                    <div class="auth-field-group">
                                        <label for="licensePlate" class="auth-field-label">Biển số xe máy *</label>
                                        <div class="auth-field-control">
                                            <span class="auth-field-icon"><i class="fa-solid fa-motorcycle text-success"></i></span>
                                            <input type="text" id="licensePlate" name="licensePlate" class="auth-field-input"
                                                   value="<c:out value='${stickyLicensePlate}' />"
                                                   placeholder="Ví dụ: 59-X3 999.99">
                                        </div>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="vehicleType" class="auth-field-label">Loại phương tiện *</label>
                                        <div class="auth-field-control">
                                            <span class="auth-field-icon"><i class="fa-solid fa-gauge text-success"></i></span>
                                            <input type="text" id="vehicleType" name="vehicleType" class="auth-field-input"
                                                   value="<c:out value='${stickyVehicleType}' />"
                                                   placeholder="Ví dụ: Honda Vision, Wave, Air Blade...">
                                        </div>
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label class="auth-field-label" style="display: flex; align-items: center; justify-content: space-between;">
                                        <span>Tài liệu & Ảnh chụp xác thực hồ sơ *</span>
                                        <span style="font-size: 0.72rem; color: #10b981;"><i class="fa-solid fa-shield-halved mr-1"></i> Bắt buộc 4 ảnh</span>
                                    </label>
                                    
                                    <div class="auth-doc-upload-grid">
                                        <!-- 1. Ảnh mặt (làm avatar account) -->
                                        <div class="auth-doc-card" id="cardFacePhoto" onclick="document.getElementById('inputFacePhoto').click()">
                                            <input type="file" id="inputFacePhoto" name="facePhoto" accept="image/*" style="display: none;" onchange="previewDoc(this, 'imgFacePhoto', 'cardFacePhoto')">
                                            <div class="auth-doc-placeholder">
                                                <div class="auth-doc-icon"><i class="fa-solid fa-camera"></i></div>
                                                <div class="auth-doc-title">1. Ảnh khuôn mặt *</div>
                                                <div class="auth-doc-subtitle">Làm avatar</div>
                                            </div>
                                            <div class="auth-doc-preview-box">
                                                <img id="imgFacePhoto" class="auth-doc-preview-img" src="" alt="Ảnh mặt">
                                                <div class="auth-doc-preview-overlay"><span class="auth-doc-change-text">Đổi ảnh</span></div>
                                                <div class="auth-doc-badge-success"><i class="fa-solid fa-check"></i></div>
                                            </div>
                                        </div>

                                        <!-- 2. Ảnh CCCD mặt trước -->
                                        <div class="auth-doc-card" id="cardIdFront" onclick="document.getElementById('inputIdFront').click()">
                                            <input type="file" id="inputIdFront" name="idCardFront" accept="image/*" style="display: none;" onchange="previewDoc(this, 'imgIdFront', 'cardIdFront')">
                                            <div class="auth-doc-placeholder">
                                                <div class="auth-doc-icon"><i class="fa-solid fa-address-card"></i></div>
                                                <div class="auth-doc-title">2. CCCD mặt trước *</div>
                                                <div class="auth-doc-subtitle">Rõ nét, không lóa</div>
                                            </div>
                                            <div class="auth-doc-preview-box">
                                                <img id="imgIdFront" class="auth-doc-preview-img" src="" alt="CCCD mặt trước">
                                                <div class="auth-doc-preview-overlay"><span class="auth-doc-change-text">Đổi ảnh</span></div>
                                                <div class="auth-doc-badge-success"><i class="fa-solid fa-check"></i></div>
                                            </div>
                                        </div>

                                        <!-- 3. Ảnh CCCD mặt sau -->
                                        <div class="auth-doc-card" id="cardIdBack" onclick="document.getElementById('inputIdBack').click()">
                                            <input type="file" id="inputIdBack" name="idCardBack" accept="image/*" style="display: none;" onchange="previewDoc(this, 'imgIdBack', 'cardIdBack')">
                                            <div class="auth-doc-placeholder">
                                                <div class="auth-doc-icon"><i class="fa-solid fa-id-card-clip"></i></div>
                                                <div class="auth-doc-title">3. CCCD mặt sau *</div>
                                                <div class="auth-doc-subtitle">Rõ mã chip</div>
                                            </div>
                                            <div class="auth-doc-preview-box">
                                                <img id="imgIdBack" class="auth-doc-preview-img" src="" alt="CCCD mặt sau">
                                                <div class="auth-doc-preview-overlay"><span class="auth-doc-change-text">Đổi ảnh</span></div>
                                                <div class="auth-doc-badge-success"><i class="fa-solid fa-check"></i></div>
                                            </div>
                                        </div>

                                        <!-- 4. Giấy tờ xe / Cà vẹt -->
                                        <div class="auth-doc-card" id="cardVehicleDoc" onclick="document.getElementById('inputVehicleDoc').click()">
                                            <input type="file" id="inputVehicleDoc" name="vehicleDoc" accept="image/*" style="display: none;" onchange="previewDoc(this, 'imgVehicleDoc', 'cardVehicleDoc')">
                                            <div class="auth-doc-placeholder">
                                                <div class="auth-doc-icon"><i class="fa-solid fa-file-invoice"></i></div>
                                                <div class="auth-doc-title">4. Giấy tờ xe *</div>
                                                <div class="auth-doc-subtitle">Đăng ký xe</div>
                                            </div>
                                            <div class="auth-doc-preview-box">
                                                <img id="imgVehicleDoc" class="auth-doc-preview-img" src="" alt="Giấy tờ xe">
                                                <div class="auth-doc-preview-overlay"><span class="auth-doc-change-text">Đổi ảnh</span></div>
                                                <div class="auth-doc-badge-success"><i class="fa-solid fa-check"></i></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 5. PHẦN RIÊNG: QUÁN ĂN (SELLER / MERCHANT) -->
                            <div id="step4SellerFields" style="display: none;">
                                <div class="auth-field-group">
                                    <label for="restaurantName" class="auth-field-label">Tên quán ăn / Nhà hàng *</label>
                                    <div class="auth-field-control">
                                        <span class="auth-field-icon"><i class="fa-solid fa-utensils text-primary"></i></span>
                                        <input type="text" id="restaurantName" name="restaurantName" class="auth-field-input" 
                                               value="<c:out value='${stickyRestaurantName}' />"
                                               placeholder="Ví dụ: Bếp Việt Quán, Cơm Tấm Sài Gòn...">
                                    </div>
                                </div>

                                <div class="auth-field-group mb-3">
                                    <label class="auth-field-label">Địa chỉ nhà hàng / quán ăn *</label>
                                    <div id="regSellerVNAddressPicker"></div>
                                    <input type="hidden" id="sellerAddress" value="<c:out value='${stickyRegAddress}' />" />
                                </div>

                                <div class="auth-fields-row-2">
                                    <div class="auth-field-group">
                                        <label for="openTime" class="auth-field-label">Giờ mở cửa *</label>
                                        <div class="auth-field-control">
                                            <span class="auth-field-icon"><i class="fa-regular fa-clock"></i></span>
                                            <input type="time" id="openTime" name="openTime" class="auth-field-input" 
                                                   value="<c:out value='${not empty stickyOpenTime ? stickyOpenTime : \"07:00\"}' />">
                                        </div>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="closeTime" class="auth-field-label">Giờ đóng cửa *</label>
                                        <div class="auth-field-control">
                                            <span class="auth-field-icon"><i class="fa-solid fa-door-closed"></i></span>
                                            <input type="time" id="closeTime" name="closeTime" class="auth-field-input" 
                                                   value="<c:out value='${not empty stickyCloseTime ? stickyCloseTime : \"22:00\"}' />">
                                        </div>
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label for="restaurantDesc" class="auth-field-label">Mô tả quán ăn</label>
                                    <div class="auth-field-control">
                                        <span class="auth-field-icon"><i class="fa-solid fa-pen-nib"></i></span>
                                        <input type="text" id="restaurantDesc" name="restaurantDesc" class="auth-field-input"
                                               value="<c:out value='${stickyRestaurantDesc}' />"
                                               placeholder="Giới thiệu các món đặc sản, hương vị nổi bật...">
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label class="auth-field-label">
                                        <i class="fa-solid fa-user-tie text-primary me-1"></i>
                                        Ảnh đại diện của chủ quán ăn <span style="font-weight: normal; color: #94a3b8;">(Dùng cho hồ sơ cá nhân)</span>
                                    </label>
                                    <div class="auth-avatar-dropzone" onclick="document.getElementById('ownerAvatarInput').click()">
                                        <input type="file" id="ownerAvatarInput" name="ownerAvatar" accept="image/*" style="display: none;" onchange="previewAvatar(this, 'ownerAvatarPreview')">
                                        <div class="auth-avatar-circle-preview" id="ownerAvatarPreview">
                                            <i class="fa-solid fa-camera"></i>
                                        </div>
                                        <div class="auth-avatar-info">
                                            <strong>Tải ảnh chân dung / avatar chủ quán</strong>
                                            <span>Lưu vào hệ thống, hiển thị trên thông tin cá nhân và tài khoản quản trị</span>
                                        </div>
                                        <div class="auth-upload-btn-chip"><i class="fa-solid fa-arrow-up-from-bracket"></i> Chọn ảnh</div>
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label class="auth-field-label">
                                        <i class="fa-solid fa-store text-primary me-1"></i>
                                        Logo quán ăn <span style="font-weight: normal; color: #94a3b8;">(Đại diện quán ở kênh quản lý món)</span>
                                    </label>
                                    <div class="auth-avatar-dropzone" onclick="document.getElementById('restaurantLogoInput').click()">
                                        <input type="file" id="restaurantLogoInput" name="restaurantLogo" accept="image/*" style="display: none;" onchange="previewAvatar(this, 'sellerLogoPreview')">
                                        <div class="auth-avatar-circle-preview" id="sellerLogoPreview" style="border-radius: 14px;">
                                            <i class="fa-solid fa-utensils"></i>
                                        </div>
                                        <div class="auth-avatar-info">
                                            <strong>Tải logo quán ăn</strong>
                                            <span>Hiển thị làm ảnh đại diện thương hiệu quán ở kênh quản lý món ăn</span>
                                        </div>
                                        <div class="auth-upload-btn-chip"><i class="fa-solid fa-arrow-up-from-bracket"></i> Chọn logo</div>
                                    </div>
                                </div>

                                <div class="auth-field-group">
                                    <label class="auth-field-label">
                                        <i class="fa-solid fa-image text-primary me-1"></i>
                                        Ảnh banner quán <span style="font-weight: normal; color: #94a3b8;">(Làm banner hiển thị ở mọi trang)</span>
                                    </label>
                                    <div class="auth-avatar-dropzone auth-banner-dropzone" onclick="document.getElementById('restaurantBannerInput').click()">
                                        <input type="file" id="restaurantBannerInput" name="restaurantBanner" accept="image/*" style="display: none;" onchange="previewBanner(this, 'sellerBannerPreview')">
                                        <div class="auth-banner-rect-preview" id="sellerBannerPreview">
                                            <i class="fa-regular fa-image"></i>
                                        </div>
                                        <div class="auth-avatar-info">
                                            <strong>Tải ảnh banner / bìa quán</strong>
                                            <span>Làm banner chính của quán hiển thị ở trang chủ, chi tiết quán và đề xuất</span>
                                        </div>
                                        <div class="auth-upload-btn-chip"><i class="fa-solid fa-arrow-up-from-bracket"></i> Chọn banner</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Step 4 Error alert -->
                            <div id="step4Error" class="auth-error-banner" style="display:none; margin-bottom: 8px;">
                                <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                                <div class="auth-error-msg" id="step4ErrorMsg"></div>
                            </div>
                        </div>

                        <div class="auth-step-nav-actions">
                            <button type="button" class="auth-btn-back" onclick="goToStep(3)">
                                <i class="fa-solid fa-arrow-left"></i>
                                <span>Quay lại</span>
                            </button>
                            <button type="submit" class="auth-primary-submit-btn" id="btnSubmitRegister">
                                <span>Hoàn tất đăng ký</span>
                                <i class="fa-solid fa-arrow-right"></i>
                            </button>
                        </div>
                    </div>
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
</div>

<script src="${pageContext.request.contextPath}/assets/js/vn-address-picker.js"></script>
<script>
let currentStep = 1;
let selectedRole = '<c:out value="${not empty stickyAccountType ? stickyAccountType : 'CUSTOMER'}" />';
let lastSentOtp = '';
let otpCountdownTimer = null;

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
        if (desc) desc.innerText = 'Đăng ký tài khoản mới để gia nhập Utee';
    }
}

function selectRole(role) {
    selectedRole = role;
    document.getElementById('wizardAccountType').value = role;

    document.querySelectorAll('.auth-role-card').forEach(c => c.classList.remove('selected'));
    if (role === 'CUSTOMER') {
        document.getElementById('roleCardCustomer').classList.add('selected');
    } else if (role === 'SELLER') {
        document.getElementById('roleCardSeller').classList.add('selected');
    } else if (role === 'SHIPPER') {
        document.getElementById('roleCardShipper').classList.add('selected');
    }
    updateStep4RoleUI();
}

function updateStep4RoleUI() {
    const custDiv = document.getElementById('step4CustomerFields');
    const shipDiv = document.getElementById('step4ShipperFields');
    const sellDiv = document.getElementById('step4SellerFields');
    const badge = document.getElementById('step4RoleBadge');
    const lblFullName = document.getElementById('lblFullName');

    if (selectedRole === 'SELLER') {
        custDiv.style.display = 'none';
        shipDiv.style.display = 'none';
        sellDiv.style.display = 'block';
        if (badge) {
            badge.innerHTML = '<i class="fa-solid fa-store me-1"></i> Quán ăn / Nhà hàng';
            badge.style.background = '#fef3c7';
            badge.style.color = '#b45309';
        }
        if (lblFullName) lblFullName.innerText = 'Họ tên chủ quán *';
    } else if (selectedRole === 'SHIPPER') {
        custDiv.style.display = 'none';
        shipDiv.style.display = 'block';
        sellDiv.style.display = 'none';
        if (badge) {
            badge.innerHTML = '<i class="fa-solid fa-motorcycle me-1"></i> Tài xế Shipper';
            badge.style.background = '#d1fae5';
            badge.style.color = '#065f46';
        }
        if (lblFullName) lblFullName.innerText = 'Họ và tên tài xế *';
    } else {
        custDiv.style.display = 'block';
        shipDiv.style.display = 'none';
        sellDiv.style.display = 'none';
        if (badge) {
            badge.innerHTML = '<i class="fa-solid fa-user me-1"></i> Khách hàng';
            badge.style.background = '#eff6ff';
            badge.style.color = '#2563eb';
        }
        if (lblFullName) lblFullName.innerText = 'Họ và tên *';
    }
}

function goToStep(step) {
    // Hide all step views
    for (let i = 1; i <= 4; i++) {
        const stepEl = document.getElementById('wizardStep' + i);
        const indEl = document.getElementById('stepIndicator' + i);
        if (stepEl) stepEl.classList.remove('active');
        if (indEl) {
            indEl.classList.remove('active');
            if (i < step) {
                indEl.classList.add('completed');
            } else {
                indEl.classList.remove('completed');
            }
        }
    }

    currentStep = step;
    const targetStep = document.getElementById('wizardStep' + step);
    const targetInd = document.getElementById('stepIndicator' + step);
    if (targetStep) targetStep.classList.add('active');
    if (targetInd) targetInd.classList.add('active');

    // Update progress bar width: 0%, 33%, 66%, 100%
    const progressPercent = ((step - 1) / 3) * 100;
    const bar = document.getElementById('stepperProgressBar');
    if (bar) bar.style.width = progressPercent + '%';

    if (step === 3) {
        setTimeout(() => {
            const firstOtp = document.getElementById('otp1');
            if (firstOtp) firstOtp.focus();
        }, 150);
    } else if (step === 4) {
        updateStep4RoleUI();
    }
}

function clearStepError(errorId) {
    const el = document.getElementById(errorId);
    if (el) el.style.display = 'none';
}

function showStepError(errorId, msgId, message) {
    const el = document.getElementById(errorId);
    const msg = document.getElementById(msgId);
    if (msg) msg.innerText = message;
    if (el) el.style.display = 'flex';
}

function appendEmailDomain(domain) {
    const emailInput = document.getElementById('wizardEmailInput');
    if (!emailInput) return;
    let val = emailInput.value.trim();
    if (!val) {
        emailInput.value = 'user' + domain;
        emailInput.focus();
        return;
    }
    if (val.includes('@')) {
        val = val.substring(0, val.indexOf('@'));
    }
    emailInput.value = val + domain;
    clearStepError('step2Error');
    emailInput.focus();
}

// BƯỚC 2 -> 3: Gửi mã OTP qua Gmail
function handleSendOtpClick() {
    clearStepError('step2Error');
    clearStepError('step3Error');
    const emailInput = document.getElementById('wizardEmailInput');
    const phoneInput = document.getElementById('wizardPhoneInput');

    const email = emailInput ? emailInput.value.trim() : '';
    const phone = phoneInput ? phoneInput.value.trim() : '';

    if (!email) {
        showStepError('step2Error', 'step2ErrorMsg', 'Vui lòng nhập địa chỉ Email (Gmail) của bạn!');
        if (emailInput) emailInput.focus();
        return;
    }

    if (!/^[A-Za-z0-9+_.-]+@(.+)$/.test(email)) {
        showStepError('step2Error', 'step2ErrorMsg', 'Địa chỉ Email không hợp lệ! Vui lòng nhập đúng định dạng (ví dụ: vidu@gmail.com).');
        if (emailInput) emailInput.focus();
        return;
    }

    if (!phone) {
        showStepError('step2Error', 'step2ErrorMsg', 'Vui lòng nhập số điện thoại liên hệ của bạn!');
        if (phoneInput) phoneInput.focus();
        return;
    }

    if (!/^0[0-9]{9,10}$/.test(phone)) {
        showStepError('step2Error', 'step2ErrorMsg', 'Số điện thoại không hợp lệ! Vui lòng nhập 10-11 chữ số bắt đầu bằng số 0.');
        if (phoneInput) phoneInput.focus();
        return;
    }

    const btn = document.getElementById('btnSendOtp');
    const originalText = btn ? btn.innerHTML : '';
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang gửi mã qua Gmail...</span>';
    }

    fetch('${pageContext.request.contextPath}/auth?action=send_otp&email=' + encodeURIComponent(email) + '&phone=' + encodeURIComponent(phone))
        .then(response => response.json())
        .then(data => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            if (data.success) {
                lastSentOtp = data.otp || '';
                document.getElementById('wizardSubmittedEmail').value = email;
                document.getElementById('wizardSubmittedPhone').value = phone;

                const emailDisplay = document.getElementById('step3EmailDisplay');
                if (emailDisplay) emailDisplay.innerText = email;

                const step4EmailDisplay = document.getElementById('step4VerifiedEmailDisplay');
                if (step4EmailDisplay) step4EmailDisplay.innerText = email;
                
                // Xử lý hiển thị thông báo gửi email thật vs giả lập
                const smsBanner = document.getElementById('simulatedSmsToast');
                const smsCode = document.getElementById('simulatedOtpCode');
                const realBanner = document.getElementById('realEmailNoticeCard');
                const realTarget = document.getElementById('realEmailTargetDisplay');

                if (data.isReal) {
                    // GỬI THẬT TỪ GMAIL: Ẩn hoàn toàn toast lộ mã trên màn hình, chỉ dẫn mở Gmail
                    if (smsBanner) smsBanner.style.display = 'none';
                    if (realBanner) {
                        if (realTarget) realTarget.innerText = email;
                        realBanner.style.display = 'flex';
                    }
                } else if (data.otp) {
                    // Chế độ dev / fallback offline: hiển thị banner giả lập kèm nút điền nhanh
                    if (realBanner) realBanner.style.display = 'none';
                    if (smsBanner && smsCode) {
                        smsCode.innerText = lastSentOtp;
                        smsBanner.style.display = 'flex';
                    }
                } else {
                    if (smsBanner) smsBanner.style.display = 'none';
                    if (realBanner) {
                        if (realTarget) realTarget.innerText = email;
                        realBanner.style.display = 'flex';
                    }
                }

                // Reset OTP inputs
                for (let i = 1; i <= 6; i++) {
                    const inp = document.getElementById('otp' + i);
                    if (inp) {
                        inp.value = '';
                        inp.classList.remove('filled');
                    }
                }

                // Start countdown
                startOtpTimer(60);

                goToStep(3);
            } else {
                showStepError('step2Error', 'step2ErrorMsg', data.message || 'Không thể gửi mã OTP. Vui lòng kiểm tra lại!');
            }
        })
        .catch(err => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            showStepError('step2Error', 'step2ErrorMsg', 'Lỗi kết nối máy chủ khi gửi mã. Vui lòng thử lại!');
        });
}

function startOtpTimer(seconds) {
    if (otpCountdownTimer) clearInterval(otpCountdownTimer);
    let remain = seconds;
    const wrap = document.getElementById('otpCountdownWrap');
    const timerText = document.getElementById('otpTimerText');
    const btnResend = document.getElementById('btnResendOtp');

    if (wrap) wrap.style.display = 'inline';
    if (btnResend) btnResend.style.display = 'none';

    otpCountdownTimer = setInterval(() => {
        remain--;
        if (timerText) timerText.innerText = remain + 's';
        if (remain <= 0) {
            clearInterval(otpCountdownTimer);
            if (wrap) wrap.style.display = 'none';
            if (btnResend) btnResend.style.display = 'inline-flex';
        }
    }, 1000);
}

function fillQuickOtp() {
    if (!lastSentOtp || lastSentOtp.length !== 6) return;
    for (let i = 0; i < 6; i++) {
        const inp = document.getElementById('otp' + (i + 1));
        if (inp) {
            inp.value = lastSentOtp.charAt(i);
            inp.classList.add('filled');
        }
    }
    clearStepError('step3Error');
    // Auto verify
    handleVerifyOtpClick();
}

function onOtpInput(index, event) {
    const val = event.target.value;
    if (val.length > 0) {
        event.target.classList.add('filled');
        if (index < 6) {
            const nextInp = document.getElementById('otp' + (index + 1));
            if (nextInp) nextInp.focus();
        } else {
            // Reached last digit
            handleVerifyOtpClick();
        }
    } else {
        event.target.classList.remove('filled');
    }
}

function onOtpKeyDown(index, event) {
    if (event.key === 'Backspace' && !event.target.value && index > 1) {
        const prevInp = document.getElementById('otp' + (index - 1));
        if (prevInp) {
            prevInp.focus();
            prevInp.value = '';
            prevInp.classList.remove('filled');
        }
    }
}

// Paste support on OTP input container
document.addEventListener('DOMContentLoaded', () => {
    const otpContainer = document.getElementById('otpInputsContainer');
    if (otpContainer) {
        otpContainer.addEventListener('paste', (e) => {
            e.preventDefault();
            const pasteData = (e.clipboardData || window.clipboardData).getData('text').trim();
            const digits = pasteData.replace(/\D/g, '');
            if (digits.length >= 6) {
                for (let i = 0; i < 6; i++) {
                    const inp = document.getElementById('otp' + (i + 1));
                    if (inp) {
                        inp.value = digits.charAt(i);
                        inp.classList.add('filled');
                    }
                }
                handleVerifyOtpClick();
            }
        });
    }
});

// BƯỚC 3 -> 4: Xác thực OTP
function handleVerifyOtpClick() {
    clearStepError('step3Error');
    let enteredOtp = '';
    for (let i = 1; i <= 6; i++) {
        const inp = document.getElementById('otp' + i);
        if (inp) enteredOtp += inp.value.trim();
    }

    if (enteredOtp.length < 6) {
        showStepError('step3Error', 'step3ErrorMsg', 'Vui lòng nhập đủ 6 chữ số mã OTP!');
        return;
    }

    const btn = document.getElementById('btnVerifyOtp');
    const originalText = btn ? btn.innerHTML : '';
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang xác thực...</span>';
    }

    fetch('${pageContext.request.contextPath}/auth?action=verify_otp&otp=' + encodeURIComponent(enteredOtp))
        .then(response => response.json())
        .then(data => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            if (data.success) {
                if (data.email) {
                    const step4EmailDisplay = document.getElementById('step4VerifiedEmailDisplay');
                    if (step4EmailDisplay) step4EmailDisplay.innerText = data.email;
                    document.getElementById('wizardSubmittedEmail').value = data.email;
                }
                goToStep(4);
            } else {
                showStepError('step3Error', 'step3ErrorMsg', data.message || 'Mã OTP không chính xác!');
            }
        })
        .catch(err => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            showStepError('step3Error', 'step3ErrorMsg', 'Lỗi kiểm tra OTP. Vui lòng thử lại!');
        });
}

// Image preview helpers
function previewAvatar(input, previewContainerId) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const container = document.getElementById(previewContainerId);
            if (container) {
                container.innerHTML = '<img src="' + e.target.result + '" alt="Avatar">';
            }
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function previewBanner(input, previewContainerId) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const container = document.getElementById(previewContainerId);
            if (container) {
                container.innerHTML = '<img src="' + e.target.result + '" alt="Banner" style="width:100%;height:100%;object-fit:cover;border-radius:8px;">';
            }
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function previewDoc(input, imgId, cardId) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const img = document.getElementById(imgId);
            const card = document.getElementById(cardId);
            if (img) img.src = e.target.result;
            if (card) card.classList.add('has-file');
        };
        reader.readAsDataURL(input.files[0]);
    }
}

// Validate Form Bước 4 trước khi submit
function validateFinalRegisterForm() {
    clearStepError('step4Error');
    const fullName = document.getElementById('regFullName').value.trim();
    const username = document.getElementById('regUsername').value.trim();
    const password = document.getElementById('regPassword').value;
    const confirmPassword = document.getElementById('regConfirmPassword').value;

    const email = document.getElementById('wizardSubmittedEmail').value.trim();
    if (!email || !/^[A-Za-z0-9+_.-]+@(.+)$/.test(email)) {
        showStepError('step4Error', 'step4ErrorMsg', 'Địa chỉ email chưa được xác thực! Vui lòng quay lại Bước 2 để nhận mã OTP.');
        goToStep(2);
        return false;
    }

    if (!fullName || !username || !password || !confirmPassword) {
        showStepError('step4Error', 'step4ErrorMsg', 'Vui lòng điền đầy đủ các thông tin có dấu sao (*)!');
        return false;
    }

    if (password.length < 6) {
        showStepError('step4Error', 'step4ErrorMsg', 'Mật khẩu phải có tối thiểu 6 ký tự!');
        return false;
    }

    if (password !== confirmPassword) {
        showStepError('step4Error', 'step4ErrorMsg', 'Mật khẩu xác nhận không trùng khớp!');
        return false;
    }

    // Sync address input
    let addr = '';
    if (selectedRole === 'CUSTOMER') {
        addr = document.getElementById('customerAddress').value.trim();
        if (!addr) {
            showStepError('step4Error', 'step4ErrorMsg', 'Khách hàng vui lòng nhập địa chỉ giao hàng nhận món!');
            document.getElementById('customerAddress').focus();
            return false;
        }
    } else if (selectedRole === 'SHIPPER') {
        addr = document.getElementById('shipperAddress').value.trim();
        if (!addr) {
            showStepError('step4Error', 'step4ErrorMsg', 'Đối tác Shipper vui lòng nhập địa chỉ thường trú!');
            document.getElementById('shipperAddress').focus();
            return false;
        }

        const plate = document.getElementById('licensePlate').value.trim();
        const vtype = document.getElementById('vehicleType').value.trim();
        if (!plate || !vtype) {
            showStepError('step4Error', 'step4ErrorMsg', 'Đối tác Shipper vui lòng điền biển số xe và loại xe!');
            return false;
        }

        // Kiểm tra 4 tài liệu bắt buộc của Shipper
        const face = document.getElementById('inputFacePhoto').files;
        const front = document.getElementById('inputIdFront').files;
        const back = document.getElementById('inputIdBack').files;
        const doc = document.getElementById('inputVehicleDoc').files;

        if (!face || face.length === 0) {
            showStepError('step4Error', 'step4ErrorMsg', 'Tài xế bắt buộc phải chụp ảnh khuôn mặt (làm ảnh đại diện)!');
            return false;
        }
        if (!front || front.length === 0 || !back || back.length === 0) {
            showStepError('step4Error', 'step4ErrorMsg', 'Tài xế bắt buộc phải tải lên cả 2 mặt CCCD!');
            return false;
        }
        if (!doc || doc.length === 0) {
            showStepError('step4Error', 'step4ErrorMsg', 'Tài xế bắt buộc phải tải lên giấy tờ xe / cà vẹt xe!');
            return false;
        }
    } else if (selectedRole === 'SELLER') {
        addr = document.getElementById('sellerAddress').value.trim();
        const restName = document.getElementById('restaurantName').value.trim();
        if (!restName) {
            showStepError('step4Error', 'step4ErrorMsg', 'Chủ quán vui lòng nhập tên quán ăn / nhà hàng!');
            document.getElementById('restaurantName').focus();
            return false;
        }
        if (!addr) {
            showStepError('step4Error', 'step4ErrorMsg', 'Chủ quán vui lòng nhập địa chỉ quán ăn!');
            document.getElementById('sellerAddress').focus();
            return false;
        }
    }

    document.getElementById('wizardSubmittedAddress').value = addr;
    return true;
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
    applyQuickUser(user, pass, false);
}

// =========================================================================
// Quick Login Dropdown Menu Control Logic
// =========================================================================
let currentQuickRoleFilter = 'ALL';

function toggleQuickLoginDropdown(event) {
    if (event) event.stopPropagation();
    const dropdownBox = document.getElementById('quickLoginDropdownBox');
    const toggleBtn = document.getElementById('quickLoginDropdownToggle');
    if (!dropdownBox || !toggleBtn) return;

    const isVisible = dropdownBox.style.display === 'block';
    if (isVisible) {
        closeQuickDropdown();
    } else {
        openQuickDropdown();
    }
}

function openQuickDropdown() {
    const dropdownBox = document.getElementById('quickLoginDropdownBox');
    const toggleBtn = document.getElementById('quickLoginDropdownToggle');
    const wrap = document.getElementById('authQuickLoginWrap');
    if (!dropdownBox || !toggleBtn) return;

    // Smart positioning: if bottom is close to viewport bottom, drop up
    if (wrap) {
        const rect = wrap.getBoundingClientRect();
        const spaceBelow = window.innerHeight - rect.bottom;
        if (spaceBelow < 280) {
            dropdownBox.classList.add('drop-up');
        } else {
            dropdownBox.classList.remove('drop-up');
        }
    }

    dropdownBox.style.display = 'block';
    toggleBtn.classList.add('active');
    toggleBtn.setAttribute('aria-expanded', 'true');

    // Auto-focus search input
    const searchInput = document.getElementById('quickUserSearchInput');
    if (searchInput) {
        setTimeout(() => searchInput.focus(), 50);
    }
}

function closeQuickDropdown() {
    const dropdownBox = document.getElementById('quickLoginDropdownBox');
    const toggleBtn = document.getElementById('quickLoginDropdownToggle');
    if (dropdownBox) dropdownBox.style.display = 'none';
    if (toggleBtn) {
        toggleBtn.classList.remove('active');
        toggleBtn.setAttribute('aria-expanded', 'false');
    }
}

function handleQuickUserSearch(keyword) {
    keyword = (keyword || '').trim().toLowerCase();
    const clearBtn = document.getElementById('quickSearchClearBtn');
    if (clearBtn) {
        clearBtn.style.display = keyword ? 'block' : 'none';
    }

    const rows = document.querySelectorAll('#quickUsersScrollList .quick-user-row');
    let visibleCount = 0;

    rows.forEach(row => {
        const role = row.getAttribute('data-role');
        const username = row.getAttribute('data-username') || '';
        const name = row.getAttribute('data-name') || '';

        const roleMatch = (currentQuickRoleFilter === 'ALL' || role === currentQuickRoleFilter);
        const searchMatch = !keyword || username.includes(keyword) || name.includes(keyword);

        if (roleMatch && searchMatch) {
            row.style.display = 'flex';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });

    const noResult = document.getElementById('quickUserNoResult');
    if (noResult) {
        noResult.style.display = (visibleCount === 0) ? 'flex' : 'none';
    }
}

function clearQuickUserSearch() {
    const searchInput = document.getElementById('quickUserSearchInput');
    if (searchInput) {
        searchInput.value = '';
        searchInput.focus();
    }
    handleQuickUserSearch('');
}

function filterQuickRole(role, btn) {
    currentQuickRoleFilter = role;
    const tabs = document.querySelectorAll('.quick-role-tabs .quick-role-tab');
    tabs.forEach(t => t.classList.remove('active'));
    if (btn) btn.classList.add('active');

    const searchInput = document.getElementById('quickUserSearchInput');
    const keyword = searchInput ? searchInput.value : '';
    handleQuickUserSearch(keyword);
}

function applyQuickUser(username, password, autoSubmit) {
    const userField = document.getElementById('loginUsername');
    const passField = document.getElementById('loginPassword');
    const displaySpan = document.getElementById('quickToggleDisplay');

    if (userField && passField) {
        userField.value = username;
        passField.value = password;
        userField.focus();
    }

    if (displaySpan) {
        displaySpan.innerHTML = '<strong style="color:#0284c7">@' + username + '</strong> (Đã chọn - sẵn sàng đăng nhập)';
    }

    closeQuickDropdown();

    if (autoSubmit) {
        const form = document.getElementById('loginForm');
        if (form) {
            const submitBtn = form.querySelector('.auth-primary-submit-btn');
            if (submitBtn) {
                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-2"></i> Đang đăng nhập...';
                submitBtn.style.opacity = '0.85';
                submitBtn.disabled = true;
            }
            form.submit();
        }
    }
}

// Click outside or ESC key to dismiss Quick Login Dropdown
document.addEventListener('click', function(e) {
    const wrap = document.getElementById('authQuickLoginWrap');
    if (wrap && !wrap.contains(e.target)) {
        closeQuickDropdown();
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeQuickDropdown();
    }
});

    // Tự động chuyển sang tab Đăng ký nếu URL có hash #register hoặc đang có lỗi đăng ký
    <c:choose>  
        <c:when test="${activeTab eq 'registerTab'}">
            switchAuthTab('registerTab');
            <c:if test="${currentStep != null && currentStep == 4}">
                goToStep(4);
            </c:if>
        </c:when>
        <c:otherwise>
            if (window.location.hash === '#register') {
                switchAuthTab('registerTab');
            }
        </c:otherwise>
    </c:choose>

    // Khởi tạo VNAddressPicker cho đăng ký khách hàng & chủ quán
    if (typeof VNAddressPicker !== 'undefined') {
        if (document.getElementById('regCustomerVNAddressPicker')) {
            VNAddressPicker.init({
                container: 'regCustomerVNAddressPicker',
                targetInput: 'customerAddress',
                initialAddress: document.getElementById('customerAddress') ? document.getElementById('customerAddress').value : ''
            });
        }
        if (document.getElementById('regSellerVNAddressPicker')) {
            VNAddressPicker.init({
                container: 'regSellerVNAddressPicker',
                targetInput: 'sellerAddress',
                initialAddress: document.getElementById('sellerAddress') ? document.getElementById('sellerAddress').value : ''
            });
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

