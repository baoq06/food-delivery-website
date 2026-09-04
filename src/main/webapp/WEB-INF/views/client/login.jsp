<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Đăng Nhập & Đăng Ký - VinDelivery" />
</jsp:include>

<div class="auth-page-wrapper">
    <div class="auth-card-modern">
        <!-- Auth Header with Logo -->
        <div class="auth-header">
            <div class="auth-logo">
                <span class="logo-icon"><i class="fa-solid fa-utensils"></i></span>
                <span class="logo-text">Vin<span>Delivery</span></span>
            </div>
            <p class="auth-tagline">Đăng nhập để nhận ngay voucher giảm 30k cho đơn hàng đầu tiên cùng VinDelivery!</p>
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

                <button type="submit" class="btn btn-primary btn-block btn-lg mt-3">
                    Đăng Ký Tài Khoản Mới <i class="fa-solid fa-check"></i>
                </button>
            </form>
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
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
