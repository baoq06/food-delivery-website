<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
</main>
<footer class="footer">
    <div class="footer-top">
        <div class="container footer-grid">
            <!-- Col 1: About -->
            <div class="footer-col">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo footer-logo">
                    <span class="logo-icon"><i class="fa-solid fa-utensils"></i></span>
                    <span class="logo-text">Food<span>Zone</span></span>
                </a>
                <p class="footer-desc">
                    Hệ thống đặt món ăn trực tuyến nhanh chóng, tiện lợi với hàng ngàn món ăn nóng hổi từ các đầu bếp uy tín hàng đầu.
                </p>
                <div class="footer-socials">
                    <a href="#" class="social-btn"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="#" class="social-btn"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#" class="social-btn"><i class="fa-brands fa-tiktok"></i></a>
                    <a href="#" class="social-btn"><i class="fa-brands fa-youtube"></i></a>
                </div>
            </div>

            <!-- Col 2: Quick Links -->
            <div class="footer-col">
                <h4 class="footer-title">Khám Phá</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-angle-right"></i> Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/foods"><i class="fa-solid fa-angle-right"></i> Thực đơn đa dạng</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart"><i class="fa-solid fa-angle-right"></i> Giỏ hàng của bạn</a></li>
                    <li><a href="${pageContext.request.contextPath}/foods?cat=1"><i class="fa-solid fa-angle-right"></i> Thức ăn nhanh</a></li>
                    <li><a href="${pageContext.request.contextPath}/foods?cat=3"><i class="fa-solid fa-angle-right"></i> Đồ uống & Trà sữa</a></li>
                </ul>
            </div>

            <!-- Col 3: Policy & Support -->
            <div class="footer-col">
                <h4 class="footer-title">Chính Sách & Hỗ Trợ</h4>
                <ul class="footer-links">
                    <li><a href="#"><i class="fa-solid fa-angle-right"></i> Chính sách giao hàng</a></li>
                    <li><a href="#"><i class="fa-solid fa-angle-right"></i> Cam kết chất lượng an toàn</a></li>
                    <li><a href="#"><i class="fa-solid fa-angle-right"></i> Quy định thanh toán & hoàn tiền</a></li>
                    <li><a href="#"><i class="fa-solid fa-angle-right"></i> Bảo mật thông tin khách hàng</a></li>
                    <li><a href="#"><i class="fa-solid fa-angle-right"></i> Hướng dẫn đặt món</a></li>
                </ul>
            </div>

            <!-- Col 4: Contact -->
            <div class="footer-col">
                <h4 class="footer-title">Liên Hệ Với Chúng Tôi</h4>
                <ul class="footer-contact">
                    <li><i class="fa-solid fa-location-dot"></i> <span>Số 01 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh</span></li>
                    <li><i class="fa-solid fa-phone"></i> <span>Hotline: <strong>1900 6886</strong> (24/7)</span></li>
                    <li><i class="fa-solid fa-envelope"></i> <span>hotro@foodzone.vn</span></li>
                    <li><i class="fa-solid fa-clock"></i> <span>Mở cửa: 07:00 - 23:00 tất cả các ngày</span></li>
                </ul>
                <div class="payment-methods">
                    <span class="pay-badge"><i class="fa-brands fa-cc-visa"></i> Visa</span>
                    <span class="pay-badge"><i class="fa-brands fa-cc-mastercard"></i> Master</span>
                    <span class="pay-badge"><i class="fa-solid fa-money-bill-wave"></i> Tiền mặt</span>
                </div>
            </div>
        </div>
    </div>
    
    <div class="footer-bottom">
        <div class="container footer-bottom-content">
            <p>&copy; 2026 FoodZone - Nền tảng đặt đồ ăn trực tuyến. Thiết kế cho đồ án Lập trình Web.</p>
            <p class="footer-tagline">Giao nhanh 30 phút • Món ngon nóng hổi • Đảm bảo vệ sinh</p>
        </div>
    </div>
</footer>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
