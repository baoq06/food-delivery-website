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
            <!-- ==============================
                 FORM 2: ĐĂNG KÝ (REGISTER 4-STEP WIZARD)
                 ============================== -->
            <div id="registerTab" class="auth-tab-view">
                <!-- Stepper Progress Header -->
                <div class="auth-stepper" id="authStepper">
                    <div class="auth-stepper-progress-bg">
                        <div class="auth-stepper-progress-bar" id="stepperProgressBar"></div>
                    </div>
                    <div class="auth-stepper-step active" id="stepIndicator1">
                        <div class="auth-stepper-circle"><i class="fa-solid fa-user-tag"></i></div>
                        <span class="auth-stepper-title">1. Vai trò</span>
                    </div>
                    <div class="auth-stepper-step" id="stepIndicator2">
                        <div class="auth-stepper-circle"><i class="fa-solid fa-phone"></i></div>
                        <span class="auth-stepper-title">2. Số ĐT</span>
                    </div>
                    <div class="auth-stepper-step" id="stepIndicator3">
                        <div class="auth-stepper-circle"><i class="fa-solid fa-key"></i></div>
                        <span class="auth-stepper-title">3. OTP</span>
                    </div>
                    <div class="auth-stepper-step" id="stepIndicator4">
                        <div class="auth-stepper-circle"><i class="fa-solid fa-address-card"></i></div>
                        <span class="auth-stepper-title">4. Thông tin</span>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/auth" method="POST" enctype="multipart/form-data" class="auth-form-body" id="registerForm" onsubmit="return validateFinalRegisterForm()">
                    <input type="hidden" name="action" value="register">
                    <input type="hidden" name="redirect" value="<c:out value='${not empty param.redirect ? param.redirect : redirect}' />">
                    <input type="hidden" name="accountType" id="wizardAccountType" value="<c:out value='${not empty stickyAccountType ? stickyAccountType : \"CUSTOMER\"}' />">
                    <input type="hidden" name="phone" id="wizardSubmittedPhone" value="<c:out value='${stickyRegPhone}' />">
                    <input type="hidden" name="address" id="wizardSubmittedAddress" value="<c:out value='${stickyRegAddress}' />">

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
                                <div class="auth-role-icon-box">👤</div>
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
                                <div class="auth-role-icon-box">🏪</div>
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
                                <div class="auth-role-icon-box">🛵</div>
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
                         BƯỚC 2: NHẬP SỐ ĐIỆN THOẠI
                         ============================================== -->
                    <div class="auth-wizard-step" id="wizardStep2">
                        <p class="auth-step-instruction">
                            Nhập số điện thoại chính chủ của bạn. Hệ thống sẽ gửi một mã xác thực OTP 6 số qua SMS:
                        </p>

                        <div class="auth-phone-box">
                            <label class="auth-field-label" for="wizardPhoneInput">Số điện thoại di động *</label>
                            <div class="auth-phone-input-wrap">
                                <div class="auth-phone-prefix">
                                    <span>🇻🇳</span>
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
                                <i class="fa-solid fa-shield-halved text-success"></i>
                                <span>Dùng để xác thực danh tính và thông báo trạng thái đơn hàng.</span>
                            </div>
                        </div>

                        <!-- Step 2 Error alert if invalid phone -->
                        <div id="step2Error" class="auth-error-banner" style="display:none; margin-bottom: 16px;">
                            <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                            <div class="auth-error-msg" id="step2ErrorMsg"></div>
                        </div>

                        <div class="auth-step-nav-actions">
                            <button type="button" class="auth-btn-back" onclick="goToStep(1)">
                                <i class="fa-solid fa-arrow-left"></i>
                                <span>Quay lại</span>
                            </button>
                            <button type="button" class="auth-primary-submit-btn" id="btnSendOtp" onclick="handleSendOtpClick()">
                                <span>Gửi mã OTP qua SMS</span>
                                <i class="fa-solid fa-paper-plane"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ==============================================
                         BƯỚC 3: XÁC THỰC MÃ OTP (6 SỐ)
                         ============================================== -->
                    <div class="auth-wizard-step" id="wizardStep3">
                        <div class="auth-otp-box">
                            <div class="auth-otp-phone-display">
                                Mã xác thực OTP 6 số đã được gửi tới số: 
                                <span class="auth-otp-phone-number" id="step3PhoneDisplay">...</span>
                                <a href="javascript:void(0)" onclick="goToStep(2)" class="auth-otp-edit-phone">
                                    <i class="fa-solid fa-pen"></i> Đổi số
                                </a>
                            </div>

                            <!-- Simulated SMS Push Notification Toast for Demo/Testing -->
                            <div class="simulated-sms-banner" id="simulatedSmsToast" style="display:none;">
                                <div class="simulated-sms-icon"><i class="fa-solid fa-comment-sms"></i></div>
                                <div class="simulated-sms-body">
                                    <div class="simulated-sms-header">
                                        <span class="simulated-sms-sender"><i class="fa-solid fa-shield-check"></i> UTEE FOOD OTP</span>
                                        <span class="simulated-sms-time">Vừa xong</span>
                                    </div>
                                    <div class="simulated-sms-text">
                                        Mã OTP đăng ký của bạn là: <strong id="simulatedOtpCode" style="color:#fbbf24; font-size:1.15rem; letter-spacing:2px;">------</strong> (Hiệu lực 5 phút).
                                    </div>
                                    <button type="button" class="simulated-sms-fill-btn" onclick="fillQuickOtp()">
                                        <i class="fa-solid fa-bolt"></i>
                                        <span>Điền nhanh mã OTP</span>
                                    </button>
                                </div>
                            </div>

                            <p style="font-size: 0.88rem; color: #64748b; margin-bottom: 12px;">Nhập 6 chữ số:</p>

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
                                    <i class="fa-solid fa-rotate-right mr-1"></i> Gửi lại mã OTP
                                </button>
                            </div>

                            <!-- Step 3 Error alert -->
                            <div id="step3Error" class="auth-error-banner" style="display:none; text-align: left;">
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
                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px;">
                            <span class="auth-step-instruction" style="margin-bottom: 0;">Điền thông tin tài khoản:</span>
                            <span class="auth-role-badge" id="step4RoleBadge" style="font-size: 0.78rem; padding: 4px 10px;">Khách hàng</span>
                        </div>

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
                            <div class="auth-field-group">
                                <label for="customerAddress" class="auth-field-label">Địa chỉ giao hàng mặc định *</label>
                                <div class="auth-field-control">
                                    <span class="auth-field-icon"><i class="fa-solid fa-location-dot"></i></span>
                                    <input type="text" id="customerAddress" class="auth-field-input" 
                                           value="<c:out value='${stickyRegAddress}' />"
                                           placeholder="Số nhà, tên đường, phường/xã, quận/huyện...">
                                </div>
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
                                            <div class="auth-doc-subtitle">Làm ảnh đại diện</div>
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
                                            <div class="auth-doc-subtitle">Rõ mã vạch / chip</div>
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
                                            <div class="auth-doc-title">4. Giấy tờ / Cà vẹt xe *</div>
                                            <div class="auth-doc-subtitle">Chứng nhận đăng ký xe</div>
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

                            <div class="auth-field-group">
                                <label for="sellerAddress" class="auth-field-label">Địa chỉ nhà hàng / quán ăn *</label>
                                <div class="auth-field-control">
                                    <span class="auth-field-icon"><i class="fa-solid fa-map-location-dot"></i></span>
                                    <input type="text" id="sellerAddress" class="auth-field-input" 
                                           value="<c:out value='${stickyRegAddress}' />"
                                           placeholder="Số nhà, tên đường nơi quán ăn đặt trụ sở...">
                                </div>
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
                                <label class="auth-field-label">Logo / Ảnh quán ăn <span style="font-weight: normal; color: #94a3b8;">(Không bắt buộc)</span></label>
                                <div class="auth-avatar-dropzone" onclick="document.getElementById('restaurantLogoInput').click()">
                                    <input type="file" id="restaurantLogoInput" name="restaurantLogo" accept="image/*" style="display: none;" onchange="previewAvatar(this, 'sellerLogoPreview')">
                                    <div class="auth-avatar-circle-preview" id="sellerLogoPreview" style="border-radius: 12px;">
                                        <i class="fa-solid fa-store"></i>
                                    </div>
                                    <div class="auth-avatar-info">
                                        <strong>Tải ảnh / Logo quán ăn</strong>
                                        <span>Giúp khách hàng dễ dàng nhận diện thương hiệu của bạn</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Step 4 Error alert -->
                        <div id="step4Error" class="auth-error-banner" style="display:none;">
                            <div class="auth-error-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                            <div class="auth-error-msg" id="step4ErrorMsg"></div>
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
        if (desc) desc.innerText = '4 bước nhanh chóng để gia nhập Utee';
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
            badge.innerText = '🏪 Quán ăn / Nhà hàng';
            badge.style.background = '#fef3c7';
            badge.style.color = '#b45309';
        }
        if (lblFullName) lblFullName.innerText = 'Họ tên chủ quán *';
    } else if (selectedRole === 'SHIPPER') {
        custDiv.style.display = 'none';
        shipDiv.style.display = 'block';
        sellDiv.style.display = 'none';
        if (badge) {
            badge.innerText = '🛵 Tài xế Shipper';
            badge.style.background = '#d1fae5';
            badge.style.color = '#065f46';
        }
        if (lblFullName) lblFullName.innerText = 'Họ và tên tài xế *';
    } else {
        custDiv.style.display = 'block';
        shipDiv.style.display = 'none';
        sellDiv.style.display = 'none';
        if (badge) {
            badge.innerText = '👤 Khách hàng';
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

// BƯỚC 2 -> 3: Gửi mã OTP qua SMS
function handleSendOtpClick() {
    clearStepError('step2Error');
    clearStepError('step3Error');
    const phoneInput = document.getElementById('wizardPhoneInput');
    const phone = phoneInput ? phoneInput.value.trim() : '';

    if (!phone) {
        showStepError('step2Error', 'step2ErrorMsg', 'Vui lòng nhập số điện thoại của bạn!');
        phoneInput.focus();
        return;
    }

    if (!/^0[0-9]{9,10}$/.test(phone)) {
        showStepError('step2Error', 'step2ErrorMsg', 'Số điện thoại không hợp lệ! Vui lòng nhập 10-11 chữ số bắt đầu bằng số 0.');
        phoneInput.focus();
        return;
    }

    const btn = document.getElementById('btnSendOtp');
    const originalText = btn ? btn.innerHTML : '';
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang gửi mã...</span>';
    }

    fetch('${pageContext.request.contextPath}/auth?action=send_otp&phone=' + encodeURIComponent(phone))
        .then(response => response.json())
        .then(data => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            if (data.success) {
                lastSentOtp = data.otp || '';
                document.getElementById('wizardSubmittedPhone').value = phone;
                document.getElementById('step3PhoneDisplay').innerText = phone;
                
                // Hiển thị simulated SMS banner
                const smsBanner = document.getElementById('simulatedSmsToast');
                const smsCode = document.getElementById('simulatedOtpCode');
                if (smsBanner && smsCode) {
                    smsCode.innerText = lastSentOtp;
                    smsBanner.style.display = 'flex';
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
                showStepError('step2Error', 'step2ErrorMsg', data.message || 'Không thể gửi mã OTP. Vui lòng thử lại!');
            }
        })
        .catch(err => {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
            showStepError('step2Error', 'step2ErrorMsg', 'Lỗi kết nối máy chủ. Vui lòng thử lại!');
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
    const userField = document.getElementById('loginUsername');
    const passField = document.getElementById('loginPassword');
    if (userField && passField) {
        userField.value = user;
        passField.value = pass;
        userField.focus();
    }
}

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
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

