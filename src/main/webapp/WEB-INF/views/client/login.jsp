<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Đăng Nhập & Đăng Ký - Utee" />
    <jsp:param name="isAuthPage" value="true" />
</jsp:include>

<div class="auth-page-wrapper">
    <div class="auth-card-modern">
        <!-- Auth Header with Logo -->
        <div class="auth-header">
            <a href="${pageContext.request.contextPath}/home" class="auth-logo-link" title="Utee">
                <img src="${pageContext.request.contextPath}/assets/images/logo/logo-dark-transparent.png" alt="Utee" class="auth-logo-img">
            </a>
            <p class="auth-tagline">Đăng nhập để nhận ngay voucher giảm 30k cho đơn hàng đầu tiên cùng Utee!</p>
        </div>

        <!-- Auth Tabs -->
        <div class="auth-tabs">
            <button type="button" class="auth-tab-btn active" onclick="switchAuthTab('loginTab')">
                <i class="fa-solid fa-right-to-bracket"></i> Đăng Nhập
            </button>
            <button type="button" class="auth-tab-btn" onclick="switchAuthTab('registerTab')">
                <i class="fa-solid fa-user-plus"></i> Đăng Ký
            </button>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert-box-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <!-- Form 1: Đăng Nhập -->
        <div id="loginTab" class="auth-tab-content active">
            <form action="${pageContext.request.contextPath}/auth" method="POST" class="auth-form">
                <input type="hidden" name="action" value="login">
                
                <div class="form-group-icon">
                    <label for="loginUsername">Tên đăng nhập</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-user"></i>
                        <input type="text" id="loginUsername" name="username" class="form-control" required 
                               value="<c:out value='${not empty stickyUsername ? stickyUsername : (not empty cookieUsername ? cookieUsername : \"\")}' />"
                               placeholder="Nhập username (ví dụ: admin, user1...)">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label for="loginPassword">Mật khẩu</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-lock"></i>
                        <input type="password" id="loginPassword" name="password" class="form-control" required placeholder="Nhập mật khẩu...">
                    </div>
                </div>

                <div class="auth-helpers">
                    <label class="remember-checkbox">
                        <input type="checkbox" name="remember" ${(not empty stickyRemember and stickyRemember) or (empty stickyUsername and not empty cookieRemember and cookieRemember) ? 'checked' : ''}>
                        <span>Ghi nhớ đăng nhập</span>
                    </label>
                    <a href="#" class="forgot-link">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg mt-3">
                    Đăng Nhập Ngay <i class="fa-solid fa-arrow-right"></i>
                </button>
            </form>

            <div class="demo-account-hint">
                <p><strong>💡 Tài khoản mẫu để thử nghiệm:</strong></p>
                <p>• Admin: <code>admin</code> / <code>123456</code> (Quyền Quản trị viên)</p>
                <p>• Khách: <code>customer</code> / <code>123456</code> (Khách đặt món)</p>
            </div>
        </div>

        <!-- Form 2: Đăng Ký -->
        <div id="registerTab" class="auth-tab-content">
            <form action="${pageContext.request.contextPath}/auth" method="POST" class="auth-form">
                <input type="hidden" name="action" value="register">
                
                <div class="form-group-icon">
                    <label for="regFullName">Họ và tên của bạn *</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-id-card"></i>
                        <input type="text" id="regFullName" name="fullName" class="form-control" required 
                               value="<c:out value='${stickyRegFullName}' />"
                               placeholder="Nguyễn Văn A">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label for="regUsername">Tên đăng nhập mới *</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-user"></i>
                        <input type="text" id="regUsername" name="username" class="form-control" required 
                               value="<c:out value='${stickyRegUsername}' />"
                               placeholder="Chọn tên đăng nhập...">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label for="regPassword">Mật khẩu * (Tối thiểu 6 ký tự)</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-lock"></i>
                        <input type="password" id="regPassword" name="password" class="form-control" required placeholder="Tạo mật khẩu an toàn...">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label for="regPhone">Số điện thoại *</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-phone"></i>
                        <input type="tel" id="regPhone" name="phone" class="form-control" required 
                               value="<c:out value='${stickyRegPhone}' />"
                               placeholder="0912345678">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label for="regAddress">Địa chỉ nhận món *</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-location-dot"></i>
                        <input type="text" id="regAddress" name="address" class="form-control" required 
                               value="<c:out value='${stickyRegAddress}' />"
                               placeholder="Số nhà, tên đường...">
                    </div>
                </div>

                <div class="form-group-icon">
                    <label>Loại tài khoản đăng ký *</label>
                    <div class="account-type-toggle-group" style="display: flex; gap: 12px; margin-top: 6px; flex-wrap: wrap;">
                        <label class="account-type-card ${empty stickyAccountType || stickyAccountType eq 'CUSTOMER' ? 'selected' : ''}" style="flex: 1; border: 1px solid #ddd; padding: 10px 14px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s;">
                            <input type="radio" name="accountType" id="typeCustomer" value="CUSTOMER" ${empty stickyAccountType || stickyAccountType eq 'CUSTOMER' ? 'checked' : ''} onchange="toggleSellerFields()" />
                            <div>
                                <strong style="display:block; font-size: 0.95rem;">👤 Khách Hàng</strong>
                                <span style="font-size: 0.8rem; color: #666;">Đặt món giao tận nơi</span>
                            </div>
                        </label>
                        <label class="account-type-card ${stickyAccountType eq 'SELLER' ? 'selected' : ''}" style="flex: 1; border: 1px solid #ddd; padding: 10px 14px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s;">
                            <input type="radio" name="accountType" id="typeSeller" value="SELLER" ${stickyAccountType eq 'SELLER' ? 'checked' : ''} onchange="toggleSellerFields()" />
                            <div>
                                <strong style="display:block; font-size: 0.95rem;">🏪 Chủ Quán Ăn</strong>
                                <span style="font-size: 0.8rem; color: #666;">Bán hàng online</span>
                            </div>
                        </label>
                        <label class="account-type-card ${stickyAccountType eq 'SHIPPER' ? 'selected' : ''}" style="flex: 1; border: 1px solid #ddd; padding: 10px 14px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s;">
                            <input type="radio" name="accountType" id="typeShipper" value="SHIPPER" ${stickyAccountType eq 'SHIPPER' ? 'checked' : ''} onchange="toggleSellerFields()" />
                            <div>
                                <strong style="display:block; font-size: 0.95rem;">🛵 Shipper</strong>
                                <span style="font-size: 0.8rem; color: #666;">Giao nhận đơn hàng</span>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="form-group-icon" id="sellerFields" style="display: ${stickyAccountType eq 'SELLER' ? 'block' : 'none'}; background: #fff8f5; border: 1px dashed #ff4757; padding: 12px; border-radius: 8px; margin-top: 10px;">
                    <label for="restaurantName" class="text-primary font-weight-bold">Tên quán ăn / Nhà hàng của bạn *</label>
                    <div class="input-with-icon">
                        <i class="fa-solid fa-store text-primary"></i>
                        <input type="text" id="restaurantName" name="restaurantName" class="form-control" 
                               value="<c:out value='${stickyRestaurantName}' />"
                               placeholder="Ví dụ: Bếp Việt Quán, Cơm Tấm Sài Gòn...">
                    </div>
                </div>

<<<<<<< Updated upstream
                <button type="submit" class="btn btn-primary btn-block btn-lg mt-3">
                    Đăng Ký Tài Khoản Mới <i class="fa-solid fa-check"></i>
                </button>
            </form>
=======
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
                                <i class="fa-solid fa-shield-halved text-success"></i>
                                <span>Dùng để xác thực danh tính và thông báo trạng thái đơn hàng.</span>
                            </div>
                        </div>

                        <!-- Step 2 Benefit Highlights to maintain consistent visual height -->
                        <div class="auth-phone-benefits">
                            <div class="auth-phone-benefit-item">
                                <i class="fa-solid fa-circle-check"></i>
                                <span>Xác thực OTP tức thì hoàn toàn miễn phí qua tin nhắn SMS</span>
                            </div>
                            <div class="auth-phone-benefit-item">
                                <i class="fa-solid fa-lock"></i>
                                <span>Bảo vệ tài khoản với công nghệ bảo mật 2 lớp hiện đại</span>
                            </div>
                            <div class="auth-phone-benefit-item">
                                <i class="fa-solid fa-bell"></i>
                                <span>Nhận cập nhật lộ trình giao hàng thời gian thực</span>
                            </div>
                        </div>

                        <!-- Step 2 Error alert if invalid phone -->
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

                            <p style="font-size: 0.84rem; color: #64748b; margin-bottom: 8px;">Nhập 6 chữ số:</p>

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
                                <div class="auth-field-group mb-3">
                                    <label class="auth-field-label">Địa chỉ thường trú / Chỗ ở hiện tại *</label>
                                    <div id="regShipperVNAddressPicker"></div>
                                    <input type="hidden" id="shipperAddress" value="<c:out value='${stickyRegAddress}' />" />
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
>>>>>>> Stashed changes
        </div>
    </div>
</div>

<script>
function switchAuthTab(tabId) {
    document.querySelectorAll('.auth-tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.auth-tab-content').forEach(content => content.classList.remove('active'));

    if (tabId === 'loginTab') {
        document.querySelectorAll('.auth-tab-btn')[0].classList.add('active');
        document.getElementById('loginTab').classList.add('active');
    } else {
        document.querySelectorAll('.auth-tab-btn')[1].classList.add('active');
        document.getElementById('registerTab').classList.add('active');
    }
}

// Tự động chuyển sang tab register nếu URL có hash #register hoặc do sticky form lỗi đăng ký
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

<<<<<<< Updated upstream
function toggleSellerFields() {
    const isSeller = document.getElementById('typeSeller').checked;
    const isShipper = document.getElementById('typeShipper').checked;
    const sellerBox = document.getElementById('sellerFields');
    const restNameInput = document.getElementById('restaurantName');
    const cards = document.querySelectorAll('.account-type-card');

    cards.forEach(c => c.classList.remove('selected'));
    if (isSeller) {
        cards[1].classList.add('selected');
        sellerBox.style.display = 'block';
        restNameInput.required = true;
    } else if (isShipper) {
        cards[2].classList.add('selected');
        sellerBox.style.display = 'none';
        restNameInput.required = false;
    } else {
        cards[0].classList.add('selected');
        sellerBox.style.display = 'none';
        restNameInput.required = false;
=======
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
        if (document.getElementById('regShipperVNAddressPicker')) {
            VNAddressPicker.init({
                container: 'regShipperVNAddressPicker',
                targetInput: 'shipperAddress',
                initialAddress: document.getElementById('shipperAddress') ? document.getElementById('shipperAddress').value : ''
            });
        }
>>>>>>> Stashed changes
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
