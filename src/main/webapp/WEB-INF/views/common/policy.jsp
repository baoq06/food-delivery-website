<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Chính Sách & Hỗ Trợ - Utee Express" />
</jsp:include>

<style>
    /* Policy & Support Hub Styles (UI/UX Pro Max) */
    .policy-hero-banner {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        color: #ffffff;
        padding: 40px 0 36px 0;
        margin-bottom: 32px;
        position: relative;
        overflow: hidden;
    }
    .policy-hero-banner::after {
        content: '';
        position: absolute;
        bottom: -50px;
        right: -50px;
        width: 250px;
        height: 250px;
        background: radial-gradient(circle, rgba(240, 84, 84, 0.15) 0%, transparent 70%);
        border-radius: 50%;
        pointer-events: none;
    }
    .policy-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.88rem;
        color: #94a3b8;
        margin-bottom: 10px;
    }
    .policy-breadcrumb a {
        color: #cbd5e1;
        text-decoration: none;
        transition: color 0.2s ease;
    }
    .policy-breadcrumb a:hover {
        color: #f05454;
    }
    .policy-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(240, 84, 84, 0.15);
        color: #ff8a8a;
        border: 1px solid rgba(240, 84, 84, 0.3);
        padding: 4px 12px;
        border-radius: 50px;
        font-size: 0.8rem;
        font-weight: 700;
        margin-bottom: 12px;
    }
    .policy-hero-title {
        font-size: 2rem;
        font-weight: 900;
        margin: 0 0 8px 0;
        letter-spacing: -0.5px;
    }
    .policy-hero-sub {
        font-size: 0.96rem;
        color: #94a3b8;
        max-width: 650px;
        margin: 0;
        line-height: 1.5;
    }

    /* Policy Main Layout */
    .policy-container {
        max-width: 1200px;
        margin: 0 auto 60px auto;
    }
    .policy-grid {
        display: grid;
        grid-template-columns: 310px 1fr;
        gap: 30px;
        align-items: flex-start;
    }

    /* Sidebar Navigation Card */
    .policy-sidebar {
        position: sticky;
        top: 90px;
        background: #ffffff;
        border-radius: 20px;
        border: 1px solid #fee2e2;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .policy-sidebar-title {
        font-size: 0.82rem;
        font-weight: 800;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 8px 12px 6px 12px;
        margin: 0;
    }
    .policy-nav-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 14px;
        border-radius: 14px;
        color: #475569;
        text-decoration: none;
        font-size: 0.92rem;
        font-weight: 700;
        transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid transparent;
        cursor: pointer;
    }
    .policy-nav-item:hover {
        background: #fff5f5;
        color: #f05454;
        border-color: #fecaca;
        transform: translateX(3px);
    }
    .policy-nav-item.active {
        background: #f05454;
        color: #ffffff;
        border-color: #f05454;
        box-shadow: 0 6px 16px rgba(240, 84, 84, 0.25);
    }
    .policy-nav-icon {
        width: 32px;
        height: 32px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f8fafc;
        color: #f05454;
        font-size: 1rem;
        flex-shrink: 0;
        transition: all 0.2s ease;
    }
    .policy-nav-item.active .policy-nav-icon {
        background: rgba(255, 255, 255, 0.22);
        color: #ffffff;
    }
    .policy-nav-arrow {
        margin-left: auto;
        font-size: 0.75rem;
        opacity: 0.6;
    }

    /* Sidebar Support Card */
    .policy-support-box {
        margin-top: 14px;
        padding: 16px;
        background: #f8fafc;
        border-radius: 16px;
        border: 1px dashed #cbd5e1;
        text-align: center;
    }
    .policy-support-icon {
        font-size: 1.8rem;
        color: #f05454;
        margin-bottom: 6px;
    }
    .policy-support-title {
        font-size: 0.9rem;
        font-weight: 800;
        color: #1e293b;
        margin: 0 0 4px 0;
    }
    .policy-support-text {
        font-size: 0.78rem;
        color: #64748b;
        margin: 0 0 10px 0;
    }
    .btn-policy-hotline {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        width: 100%;
        padding: 8px;
        border-radius: 50px;
        background: #10ac84;
        color: #ffffff;
        font-size: 0.82rem;
        font-weight: 700;
        text-decoration: none;
        transition: background 0.2s ease;
    }
    .btn-policy-hotline:hover {
        background: #0d8d6c;
        color: #ffffff;
    }

    /* Content Area */
    .policy-content-card {
        background: #ffffff;
        border-radius: 20px;
        border: 1px solid #fee2e2;
        box-shadow: 0 4px 24px rgba(0, 0, 0, 0.03);
        padding: 36px 40px;
        min-height: 550px;
    }
    .policy-tab-pane {
        display: none;
        animation: fadeInTab 0.3s ease;
    }
    .policy-tab-pane.active {
        display: block;
    }
    @keyframes fadeInTab {
        from { opacity: 0; transform: translateY(6px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Typography & Sub-elements inside Policy Content */
    .policy-header-row {
        display: flex;
        align-items: center;
        gap: 16px;
        padding-bottom: 20px;
        border-bottom: 1.5px solid #f1f5f9;
        margin-bottom: 24px;
    }
    .policy-header-icon {
        width: 52px;
        height: 52px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.6rem;
        background: #fff5f5;
        color: #f05454;
        border: 1.5px solid #fed7d7;
        flex-shrink: 0;
    }
    .policy-title {
        font-size: 1.55rem;
        font-weight: 900;
        color: #1e293b;
        margin: 0 0 4px 0;
        letter-spacing: -0.3px;
    }
    .policy-updated {
        font-size: 0.8rem;
        color: #94a3b8;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    /* Content Blocks */
    .policy-section-title {
        font-size: 1.15rem;
        font-weight: 800;
        color: #1e293b;
        margin: 28px 0 12px 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .policy-section-title i {
        color: #f05454;
        font-size: 1rem;
    }
    .policy-paragraph {
        font-size: 0.95rem;
        color: #475569;
        line-height: 1.7;
        margin-bottom: 14px;
    }

    /* Highlight Info Alert Box */
    .policy-callout {
        background: #f8fafc;
        border-left: 4px solid #f05454;
        border-radius: 0 14px 14px 0;
        padding: 16px 20px;
        margin: 18px 0;
    }
    .policy-callout.success {
        background: #f0fdf4;
        border-left-color: #10ac84;
    }
    .policy-callout.warning {
        background: #fffbeb;
        border-left-color: #f59e0b;
    }
    .policy-callout-title {
        font-size: 0.92rem;
        font-weight: 800;
        color: #1e293b;
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .policy-callout p {
        font-size: 0.88rem;
        color: #475569;
        line-height: 1.55;
        margin: 0;
    }

    /* Step Timeline / Cards */
    .policy-steps-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 14px;
        margin: 20px 0;
    }
    .policy-step-card {
        background: #fdfbfa;
        border: 1px solid #fee2e2;
        border-radius: 14px;
        padding: 16px;
        position: relative;
        transition: transform 0.2s ease;
    }
    .policy-step-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(240, 84, 84, 0.08);
    }
    .policy-step-num {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #f05454;
        color: #ffffff;
        font-weight: 800;
        font-size: 0.88rem;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
    }
    .policy-step-title {
        font-size: 0.92rem;
        font-weight: 800;
        color: #1e293b;
        margin-bottom: 6px;
    }
    .policy-step-desc {
        font-size: 0.83rem;
        color: #64748b;
        line-height: 1.5;
        margin: 0;
    }

    /* Comparison / Data Table */
    .policy-table-wrap {
        overflow-x: auto;
        margin: 18px 0;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
    }
    .policy-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.88rem;
        text-align: left;
    }
    .policy-table th {
        background: #f8fafc;
        color: #1e293b;
        font-weight: 800;
        padding: 12px 16px;
        border-bottom: 1px solid #e2e8f0;
    }
    .policy-table td {
        padding: 12px 16px;
        border-bottom: 1px solid #f1f5f9;
        color: #475569;
    }
    .policy-table tr:last-child td {
        border-bottom: none;
    }
    .policy-table tr:hover td {
        background: #fffafa;
    }

    /* FAQ Accordion */
    .policy-faq-list {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-top: 16px;
    }
    .policy-faq-item {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        overflow: hidden;
        transition: all 0.2s ease;
    }
    .policy-faq-question {
        padding: 14px 18px;
        font-size: 0.92rem;
        font-weight: 700;
        color: #1e293b;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: space-between;
        user-select: none;
    }
    .policy-faq-question:hover {
        color: #f05454;
    }
    .policy-faq-icon {
        font-size: 0.8rem;
        color: #94a3b8;
        transition: transform 0.2s ease;
    }
    .policy-faq-item.open .policy-faq-icon {
        transform: rotate(180deg);
        color: #f05454;
    }
    .policy-faq-answer {
        display: none;
        padding: 0 18px 16px 18px;
        font-size: 0.88rem;
        color: #475569;
        line-height: 1.6;
        border-top: 1px dashed #e2e8f0;
        padding-top: 12px;
    }
    .policy-faq-item.open .policy-faq-answer {
        display: block;
    }

    /* Responsive */
    @media (max-width: 900px) {
        .policy-grid {
            grid-template-columns: 1fr;
            gap: 20px;
        }
        .policy-sidebar {
            position: static;
            flex-direction: row;
            overflow-x: auto;
            white-space: nowrap;
            padding: 10px;
            scrollbar-width: none;
        }
        .policy-sidebar::-webkit-scrollbar {
            display: none;
        }
        .policy-sidebar-title,
        .policy-support-box,
        .policy-nav-arrow {
            display: none;
        }
        .policy-nav-item {
            flex-shrink: 0;
            padding: 8px 14px;
            font-size: 0.85rem;
        }
        .policy-content-card {
            padding: 24px 20px;
        }
        .policy-hero-title {
            font-size: 1.55rem;
        }
    }

    /* Dark Mode Support */
    [data-theme="dark"] .policy-sidebar,
    [data-theme="dark"] .policy-content-card,
    [data-theme="dark"] .policy-faq-item {
        background: #1e293b !important;
        border-color: #334155 !important;
        color: #f1f5f9 !important;
    }
    [data-theme="dark"] .policy-title,
    [data-theme="dark"] .policy-section-title,
    [data-theme="dark"] .policy-support-title,
    [data-theme="dark"] .policy-faq-question,
    [data-theme="dark"] .policy-step-title,
    [data-theme="dark"] .policy-table th {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .policy-paragraph,
    [data-theme="dark"] .policy-faq-answer,
    [data-theme="dark"] .policy-support-text,
    [data-theme="dark"] .policy-step-desc,
    [data-theme="dark"] .policy-table td,
    [data-theme="dark"] .policy-callout p {
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .policy-nav-item {
        color: #94a3b8;
    }
    [data-theme="dark"] .policy-nav-item:hover {
        background: #243248;
        color: #ff8a8a;
    }
    [data-theme="dark"] .policy-nav-item.active {
        background: #f05454;
        color: #ffffff;
    }
    [data-theme="dark"] .policy-support-box,
    [data-theme="dark"] .policy-callout,
    [data-theme="dark"] .policy-step-card,
    [data-theme="dark"] .policy-table th {
        background: #0f172a !important;
        border-color: #334155 !important;
    }
</style>

<!-- Hero Banner -->
<div class="policy-hero-banner">
    <div class="container">
        <div class="policy-breadcrumb">
            <a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right" style="font-size: 0.72rem;"></i>
            <span>Chính sách &amp; Hỗ trợ</span>
        </div>
        <div class="policy-badge">
            <i class="fa-solid fa-shield-halved"></i> Trung Tâm Hỗ Trợ &amp; Điều Khoản Khách Hàng
        </div>
        <h1 class="policy-hero-title">Chính Sách &amp; Hỗ Trợ Dịch Vụ Utee</h1>
        <p class="policy-hero-sub">
            Cam kết minh bạch 100%, bảo vệ quyền lợi người tiêu dùng và đảm bảo chất lượng giao nhận món ăn nóng hổi, chuẩn vị.
        </p>
    </div>
</div>

<div class="container policy-container">
    <div class="policy-grid">
        <!-- Sidebar Menu Tabs -->
        <aside class="policy-sidebar">
            <div class="policy-sidebar-title">Danh Mục Chính Sách</div>

            <a class="policy-nav-item ${activeTab eq 'delivery' ? 'active' : ''}" onclick="switchPolicyTab('delivery', this)">
                <div class="policy-nav-icon"><i class="fa-solid fa-bolt"></i></div>
                <span>Giao hàng 30 phút</span>
                <i class="fa-solid fa-chevron-right policy-nav-arrow"></i>
            </a>

            <a class="policy-nav-item ${activeTab eq 'food-quality' ? 'active' : ''}" onclick="switchPolicyTab('food-quality', this)">
                <div class="policy-nav-icon"><i class="fa-solid fa-fire-flame-curved"></i></div>
                <span>Cam kết món ăn nóng hổi</span>
                <i class="fa-solid fa-chevron-right policy-nav-arrow"></i>
            </a>

            <a class="policy-nav-item ${activeTab eq 'payment-refund' ? 'active' : ''}" onclick="switchPolicyTab('payment-refund', this)">
                <div class="policy-nav-icon"><i class="fa-solid fa-money-bill-transfer"></i></div>
                <span>Thanh toán &amp; Hoàn tiền</span>
                <i class="fa-solid fa-chevron-right policy-nav-arrow"></i>
            </a>

            <a class="policy-nav-item ${activeTab eq 'privacy' ? 'active' : ''}" onclick="switchPolicyTab('privacy', this)">
                <div class="policy-nav-icon"><i class="fa-solid fa-user-shield"></i></div>
                <span>Bảo mật thông tin</span>
                <i class="fa-solid fa-chevron-right policy-nav-arrow"></i>
            </a>

            <a class="policy-nav-item ${activeTab eq 'guide' ? 'active' : ''}" onclick="switchPolicyTab('guide', this)">
                <div class="policy-nav-icon"><i class="fa-solid fa-book-open-reader"></i></div>
                <span>Hướng dẫn đặt món</span>
                <i class="fa-solid fa-chevron-right policy-nav-arrow"></i>
            </a>

            <!-- Quick Support Widget -->
            <div class="policy-support-box">
                <i class="fa-solid fa-headset policy-support-icon"></i>
                <div class="policy-support-title">Bạn Cần Trợ Giúp Thêm?</div>
                <p class="policy-support-text">Tổng đài viên CSKH sẵn sàng phục vụ 24/7</p>
                <a href="tel:19006868" class="btn-policy-hotline">
                    <i class="fa-solid fa-phone"></i> 1900 6868 (Miễn phí)
                </a>
            </div>
        </aside>

        <!-- Content Card Panes -->
        <main class="policy-content-card">

            <!-- TAB 1: Chính sách giao hàng 30 phút -->
            <div class="policy-tab-pane ${activeTab eq 'delivery' ? 'active' : ''}" id="tab-delivery">
                <div class="policy-header-row">
                    <div class="policy-header-icon"><i class="fa-solid fa-bolt"></i></div>
                    <div>
                        <h2 class="policy-title">Chính Sách Giao Hàng Siêu Tốc 30 Phút</h2>
                        <div class="policy-updated"><i class="fa-regular fa-calendar-check"></i> Cập nhật mới nhất: Tháng 10/2026 • Áp dụng toàn sàn Utee</div>
                    </div>
                </div>

                <div class="policy-callout">
                    <div class="policy-callout-title"><i class="fa-solid fa-circle-check text-success"></i> Cam Kết Vàng Từ Utee</div>
                    <p>Utee cam kết giao đơn hàng đến tận tay bạn trong vòng <strong>30 phút</strong> đối với các đơn hàng có khoảng cách dưới 5km. Nếu tài xế giao trễ quá thời gian cam kết do lỗi vận hành, bạn sẽ được tặng ngay <strong>Voucher 30.000đ</strong> cho đơn kế tiếp!</p>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-route"></i> 1. Quy trình giao nhận tiêu chuẩn 30 phút</h3>
                <p class="policy-paragraph">
                    Để đảm bảo thời gian 30 phút kỷ lục, hệ thống điều phối Utee Smart AI tự động phân bổ và tối ưu hóa từng giây trong quy trình:
                </p>

                <div class="policy-steps-grid">
                    <div class="policy-step-card">
                        <div class="policy-step-num">01</div>
                        <div class="policy-step-title">Quán nhận đơn (1-3p)</div>
                        <p class="policy-step-desc">Quán ăn nhận đơn qua hệ thống POS tự động và tiến hành chế biến ngay.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num">02</div>
                        <div class="policy-step-title">Gán shipper gần nhất (2p)</div>
                        <p class="policy-step-desc">Thuật toán định vị gán đơn cho tài xế đang ở gần quán trong bán kính dưới 1km.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num">03</div>
                        <div class="policy-step-title">Bàn giao &amp; Vận chuyển (15-20p)</div>
                        <p class="policy-step-desc">Shipper nhận món nóng hổi trong túi giữ nhiệt và di chuyển tuyến đường tối ưu.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num">04</div>
                        <div class="policy-step-title">Giao tận cửa (2-3p)</div>
                        <p class="policy-step-desc">Tài xế liên hệ bạn nhận món, kiểm tra gói hàng và hoàn tất đơn an toàn.</p>
                    </div>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-map-location-dot"></i> 2. Phạm vi áp dụng &amp; Bảng cước vận chuyển</h3>
                <div class="policy-table-wrap">
                    <table class="policy-table">
                        <thead>
                            <tr>
                                <th>Khoảng cách</th>
                                <th>Thời gian giao dự kiến</th>
                                <th>Phí ship tiêu chuẩn</th>
                                <th>Chính sách Ưu đãi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>0 - 3 km</strong></td>
                                <td>20 - 25 phút</td>
                                <td>15.000 đ</td>
                                <td><span class="badge" style="background:#e6f9ed;color:#10ac84;font-weight:bold;">FREESHIP đơn từ 99K</span></td>
                            </tr>
                            <tr>
                                <td><strong>3 - 5 km</strong></td>
                                <td>25 - 30 phút</td>
                                <td>20.000 đ</td>
                                <td>Áp dụng mã giảm 15K</td>
                            </tr>
                            <tr>
                                <td><strong>5 - 10 km</strong></td>
                                <td>30 - 45 phút</td>
                                <td>25.000 đ - 35.000 đ</td>
                                <td>Hỗ trợ mã cước xa</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-triangle-exclamation"></i> 3. Các trường hợp miễn trừ thời gian 30 phút</h3>
                <p class="policy-paragraph">Thời gian giao hàng có thể kéo dài hơn 30 phút trong các trường hợp khách quan bất khả kháng:</p>
                <ul class="policy-paragraph" style="padding-left: 20px;">
                    <li>Thời tiết cực đoan: Mưa bão lớn, ngập lụt nghiêm trọng trên tuyến đường giao nhận.</li>
                    <li>Sự cố giao thông: Kẹt xe diện rộng do tai nạn hoặc phân luồng của cơ quan chức năng.</li>
                    <li>Khách hàng cung cấp sai địa chỉ, số điện thoại hoặc không nghe máy khi tài xế liên hệ tới nơi (quá 3 cuộc gọi trong 10 phút).</li>
                    <li>Quán ăn có lượng đơn quá tải đột biến vào giờ cao điểm đã có thông báo trước trên App.</li>
                </ul>

                <h3 class="policy-section-title"><i class="fa-solid fa-circle-question"></i> Câu hỏi thường gặp về Giao hàng 30 phút</h3>
                <div class="policy-faq-list">
                    <div class="policy-faq-item open">
                        <div class="policy-faq-question" onclick="toggleFaq(this)">
                            <span>Nếu shipper giao trễ hơn 30 phút tôi cần làm gì để nhận đền bù?</span>
                            <i class="fa-solid fa-chevron-down policy-faq-icon"></i>
                        </div>
                        <div class="policy-faq-answer">
                            Bạn chỉ cần nhấn vào chi tiết đơn hàng trong mục <strong>Đơn hàng của tôi</strong> và chọn <strong>Báo cáo giao trễ</strong>. Hệ thống sẽ kiểm tra đối chiếu mốc thời gian GPS và tự động gửi mã Voucher bù cước vào Kho Voucher của bạn trong vòng 5 phút.
                        </div>
                    </div>
                    <div class="policy-faq-item">
                        <div class="policy-faq-question" onclick="toggleFaq(this)">
                            <span>Tôi có thể xem vị trí tài xế đang giao trên bản đồ không?</span>
                            <i class="fa-solid fa-chevron-down policy-faq-icon"></i>
                        </div>
                        <div class="policy-faq-answer">
                            Có. Sau khi tài xế bấm "Nhận đơn", bạn có thể theo dõi tọa độ di chuyển thời gian thực của tài xế và nhận thông báo khi tài xế chuẩn bị đến nơi.
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB 2: Cam kết món ăn nóng hổi -->
            <div class="policy-tab-pane ${activeTab eq 'food-quality' ? 'active' : ''}" id="tab-food-quality">
                <div class="policy-header-row">
                    <div class="policy-header-icon"><i class="fa-solid fa-fire-flame-curved"></i></div>
                    <div>
                        <h2 class="policy-title">Cam Kết Món Ăn Nóng Hổi &amp; Chuẩn Vị</h2>
                        <div class="policy-updated"><i class="fa-regular fa-calendar-check"></i> Tiêu chuẩn chất lượng ẩm thực Utee HotFresh Guarantee</div>
                    </div>
                </div>

                <div class="policy-callout success">
                    <div class="policy-callout-title"><i class="fa-solid fa-shield-heart text-success"></i> Cam Kết Hương Vị &amp; Vệ Sinh An Toàn 100%</div>
                    <p>Tất cả đối tác quán ăn trên Utee đều được xác thực giấy phép Vệ sinh an toàn thực phẩm. Utee cam kết <strong>đổi món mới hoặc hoàn tiền 100%</strong> nếu món ăn khi nhận bị nguội lạnh, đổ vỡ, thiếu món hoặc không đúng chất lượng cam kết!</p>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-temperature-arrow-up"></i> 1. Tiêu chuẩn túi giữ nhiệt Thermal-Shield 3 lớp</h3>
                <p class="policy-paragraph">
                    100% tài xế Shipper hoạt động trên sàn Utee bắt buộc phải trang bị <strong>Thùng / Túi giữ nhiệt chuyên dụng 3 lớp bạc cách nhiệt</strong>:
                </p>
                <ul class="policy-paragraph" style="padding-left: 20px;">
                    <li><strong>Lớp ngoài:</strong> Vải Oxford chống nước và cản gió 100%.</li>
                    <li><strong>Lớp giữa:</strong> Đệm mút EPE dày 8mm hấp thụ chấn động, chống xóc đổ món khi xe chạy.</li>
                    <li><strong>Lớp trong cùng:</strong> Màng nhôm tráng bạc giữ nhiệt duy trì nhiệt độ món ăn trên <strong>60°C</strong> trong suốt hành trình 45 phút.</li>
                    <li><strong>Ngăn đá riêng biệt:</strong> Đối với đồ uống hoặc trà sữa có đá, shipper sử dụng vách ngăn giữ lạnh riêng biệt để không làm tan đá nhanh hoặc ảnh hưởng đến món ăn nóng.</li>
                </ul>

                <h3 class="policy-section-title"><i class="fa-solid fa-box-open"></i> 2. Quy cách đóng gói và Tem niêm phong an toàn</h3>
                <div class="policy-steps-grid">
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-tape"></i></div>
                        <div class="policy-step-title">Tem niêm phong Utee Seal</div>
                        <p class="policy-step-desc">Mọi hộp thức ăn đều được dán tem niêm phong chống mở nắp trước khi bàn giao cho tài xế.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-bowl-food"></i></div>
                        <div class="policy-step-title">Hộp sinh học chịu nhiệt</div>
                        <p class="policy-step-desc">Sử dụng hộp bã mía / hộp nhựa PP nguyên sinh chịu nhiệt an toàn, không sinh mùi độc hại.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-truck-ramp-box"></i></div>
                        <div class="policy-step-title">Tách riêng nước sốt &amp; soup</div>
                        <p class="policy-step-desc">Nước súp, nước chấm, topping giòn được đóng gói riêng biệt để giữ trọn vẹn kết cấu món ăn.</p>
                    </div>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-rotate-left"></i> 3. Chính sách 1 Đổi 1 hoặc Hoàn Tiền ngay lập tức</h3>
                <p class="policy-paragraph">Bạn hoàn toàn có quyền từ chối nhận hoặc yêu cầu đền bù nếu gặp các tình trạng sau:</p>
                <div class="policy-table-wrap">
                    <table class="policy-table">
                        <thead>
                            <tr>
                                <th>Tình trạng món ăn</th>
                                <th>Phương án xử lý</th>
                                <th>Thời gian giải quyết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Món ăn bị nguội ngắt dưới 40°C</td>
                                <td>Gửi Voucher đền bù 50% - 100% hoặc đổi món</td>
                                <td>Xử lý trong 15 phút</td>
                            </tr>
                            <tr>
                                <td>Món ăn bị đổ vỡ, tràn nắp hơn 30%</td>
                                <td><strong>Hoàn tiền 100%</strong> giá trị món bị hỏng</td>
                                <td>Xử lý trong 15 phút</td>
                            </tr>
                            <tr>
                                <td>Giao sai món, thiếu món so với đơn đặt</td>
                                <td>Hoàn tiền món thiếu + Voucher xin lỗi</td>
                                <td>Ngay lập tức</td>
                            </tr>
                            <tr>
                                <td>Món ăn có mùi lạ, không đạt vệ sinh</td>
                                <td><strong>Hoàn tiền 100% toàn bộ đơn</strong> + Kiểm tra quán</td>
                                <td>Ưu tiên cao nhất</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-circle-question"></i> Câu hỏi thường gặp về Chất lượng món ăn</h3>
                <div class="policy-faq-list">
                    <div class="policy-faq-item open">
                        <div class="policy-faq-question" onclick="toggleFaq(this)">
                            <span>Tôi cần làm gì khi mở hộp thấy món ăn bị đổ hoặc không đúng?</span>
                            <i class="fa-solid fa-chevron-down policy-faq-icon"></i>
                        </div>
                        <div class="policy-faq-answer">
                            Vui lòng chụp ảnh tình trạng món ăn và phiếu giao hàng, sau đó liên hệ Hotline <strong>1900 6868</strong> hoặc bấm <strong>Khiếu nại đơn hàng</strong> trong app. Đội ngũ CSKH sẽ kiểm tra và thực hiện hoàn tiền hoặc giao bù món mới ngay lập tức.
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB 3: Quy định thanh toán & hoàn tiền -->
            <div class="policy-tab-pane ${activeTab eq 'payment-refund' ? 'active' : ''}" id="tab-payment-refund">
                <div class="policy-header-row">
                    <div class="policy-header-icon"><i class="fa-solid fa-money-bill-transfer"></i></div>
                    <div>
                        <h2 class="policy-title">Quy Định Thanh Toán &amp; Chính Sách Hoàn Tiền</h2>
                        <div class="policy-updated"><i class="fa-regular fa-calendar-check"></i> Áp dụng cho mọi giao dịch đặt món trên Utee</div>
                    </div>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-credit-card"></i> 1. Các phương thức thanh toán hỗ trợ</h3>
                <p class="policy-paragraph">Utee cung cấp đa dạng cổng thanh toán tiện lợi và bảo mật chuẩn quốc tế:</p>
                <div class="policy-steps-grid">
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-money-bill-wave"></i></div>
                        <div class="policy-step-title">Tiền mặt (COD)</div>
                        <p class="policy-step-desc">Thanh toán trực tiếp cho tài xế shipper khi bạn nhận và kiểm tra món ăn thành công.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-qrcode"></i></div>
                        <div class="policy-step-title">VNPAY-QR / Ví MoMo</div>
                        <p class="policy-step-desc">Quét mã QR qua ứng dụng ngân hàng hoặc ví điện tử chỉ trong 3 giây.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-brands fa-cc-visa"></i></div>
                        <div class="policy-step-title">Thẻ ATM / Visa / Master</div>
                        <p class="policy-step-desc">Bảo mật chuẩn PCI-DSS mã hóa 256-bit qua cổng thanh toán liên kết ngân hàng.</p>
                    </div>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-ban"></i> 2. Quy định hủy đơn hàng</h3>
                <div class="policy-callout warning">
                    <div class="policy-callout-title"><i class="fa-solid fa-clock"></i> Khung thời gian hủy đơn miễn phí</div>
                    <p>Khách hàng được <strong>HỦY ĐƠN MIỄN PHÍ 100%</strong> trong vòng <strong>3 phút</strong> đầu tiên kể từ lúc đặt hàng hoặc trước khi Quán ăn bấm "Bắt đầu nấu món".</p>
                </div>
                <ul class="policy-paragraph" style="padding-left: 20px;">
                    <li><strong>Hủy trước khi quán nấu:</strong> Hủy ngay lập tức trên app, tiền thanh toán trực tuyến (nếu có) sẽ được hoàn tự động 100%.</li>
                    <li><strong>Hủy sau khi quán đã nấu xong:</strong> Vì lý do tránh lãng phí thức ăn của đối tác, bạn không thể tự ý hủy đơn trên app. Vui lòng gọi tổng đài 1900 6868 để được nhân viên hỗ trợ xem xét từng trường hợp cụ thể.</li>
                </ul>

                <h3 class="policy-section-title"><i class="fa-solid fa-hand-holding-dollar"></i> 3. Thời gian và quy trình hoàn tiền</h3>
                <div class="policy-table-wrap">
                    <table class="policy-table">
                        <thead>
                            <tr>
                                <th>Kênh thanh toán</th>
                                <th>Thời gian tiền về tài khoản</th>
                                <th>Chi phí hoàn tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>Ví MoMo / ZaloPay</strong></td>
                                <td>Ngay lập tức đến 2 giờ</td>
                                <td>Miễn phí 100%</td>
                            </tr>
                            <tr>
                                <td><strong>Cổng VNPAY / Thẻ ATM nội địa</strong></td>
                                <td>Trong vòng 24 - 48 giờ làm việc</td>
                                <td>Miễn phí 100%</td>
                            </tr>
                            <tr>
                                <td><strong>Thẻ Quốc tế Visa / Mastercard</strong></td>
                                <td>3 - 7 ngày làm việc (tùy ngân hàng phát hành)</td>
                                <td>Miễn phí 100%</td>
                            </tr>
                            <tr>
                                <td><strong>Đơn COD (đã trả tiền mặt)</strong></td>
                                <td>Hoàn qua chuyển khoản hoặc Voucher tương đương ngay</td>
                                <td>Miễn phí 100%</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 4: Bảo mật thông tin khách hàng -->
            <div class="policy-tab-pane ${activeTab eq 'privacy' ? 'active' : ''}" id="tab-privacy">
                <div class="policy-header-row">
                    <div class="policy-header-icon"><i class="fa-solid fa-user-shield"></i></div>
                    <div>
                        <h2 class="policy-title">Chính Sách Bảo Mật Thông Tin Khách Hàng</h2>
                        <div class="policy-updated"><i class="fa-regular fa-calendar-check"></i> Tuân thủ Nghị định 13/2023/NĐ-CP về Bảo vệ dữ liệu cá nhân</div>
                    </div>
                </div>

                <div class="policy-callout success">
                    <div class="policy-callout-title"><i class="fa-solid fa-lock"></i> Tôn Trọng Quyền Riêng Tư Của Bạn</div>
                    <p>Utee cam kết bảo mật tuyệt đối mọi thông tin cá nhân của bạn. Chúng tôi <strong>không bao giờ bán, cho thuê hoặc chia sẻ</strong> dữ liệu của bạn cho bất kỳ bên thứ ba nào vì mục đích quảng cáo trái phép.</p>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-database"></i> 1. Thông tin Utee thu thập</h3>
                <p class="policy-paragraph">Khi bạn tạo tài khoản và đặt món tại Utee, chúng tôi thu thập các thông tin cần thiết sau:</p>
                <ul class="policy-paragraph" style="padding-left: 20px;">
                    <li><strong>Thông tin định danh:</strong> Họ và tên, số điện thoại, địa chỉ email.</li>
                    <li><strong>Thông tin giao nhận:</strong> Địa chỉ giao hàng, ghi chú địa chỉ, lịch sử đơn hàng.</li>
                    <li><strong>Dữ liệu kỹ thuật:</strong> Địa chỉ IP, loại trình duyệt nhằm phát hiện và ngăn chặn gian lận mã giảm giá.</li>
                </ul>

                <h3 class="policy-section-title"><i class="fa-solid fa-shield-virus"></i> 2. Các biện pháp bảo vệ dữ liệu công nghệ cao</h3>
                <div class="policy-steps-grid">
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-key"></i></div>
                        <div class="policy-step-title">Mã hóa mật khẩu BCrypt</div>
                        <p class="policy-step-desc">Mật khẩu được băm mã hóa một chiều không thể giải ngược ngay cả với kỹ sư hệ thống.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-mask"></i></div>
                        <div class="policy-step-title">Ẩn số điện thoại ảo</div>
                        <p class="policy-step-desc">Tài xế shipper chỉ liên lạc qua hệ thống tổng đài mặt nạ để bảo vệ số điện thoại thật của bạn.</p>
                    </div>
                    <div class="policy-step-card">
                        <div class="policy-step-num"><i class="fa-solid fa-lock"></i></div>
                        <div class="policy-step-title">Giao thức SSL/TLS 256-bit</div>
                        <p class="policy-step-desc">Mọi dữ liệu truyền tải giữa thiết bị của bạn và máy chủ Utee đều được mã hóa chuẩn HTTPS.</p>
                    </div>
                </div>

                <h3 class="policy-section-title"><i class="fa-solid fa-user-gear"></i> 3. Quyền hạn của bạn đối với dữ liệu cá nhân</h3>
                <p class="policy-paragraph">
                    Bạn có toàn quyền truy cập, chỉnh sửa thông tin cá nhân trong mục <strong>Tài khoản của tôi</strong> hoặc gửi yêu cầu xóa vĩnh viễn tài khoản và lịch sử dữ liệu bằng cách liên hệ với chúng tôi qua email <code>privacy@utee.vn</code>.
                </p>
            </div>

            <!-- TAB 5: Hướng dẫn đặt món tại Utee -->
            <div class="policy-tab-pane ${activeTab eq 'guide' ? 'active' : ''}" id="tab-guide">
                <div class="policy-header-row">
                    <div class="policy-header-icon"><i class="fa-solid fa-book-open-reader"></i></div>
                    <div>
                        <h2 class="policy-title">Hướng Dẫn Đặt Món Nhanh Tại Utee</h2>
                        <div class="policy-updated"><i class="fa-regular fa-circle-play"></i> 5 Bước đơn giản để thưởng thức món ngon nóng hổi</div>
                    </div>
                </div>

                <p class="policy-paragraph">Chưa bao giờ việc thưởng thức món ngon lại dễ dàng và tiện lợi đến thế. Hãy làm theo 5 bước đơn giản dưới đây:</p>

                <div class="policy-steps-grid" style="grid-template-columns: 1fr;">
                    <div class="policy-step-card" style="display: flex; gap: 16px; align-items: flex-start;">
                        <div class="policy-step-num" style="min-width: 38px; height: 38px; font-size: 1rem;">1</div>
                        <div>
                            <div class="policy-step-title" style="font-size: 1.05rem;">Khám phá thực đơn &amp; Tìm món ăn yêu thích</div>
                            <p class="policy-step-desc">Sử dụng thanh tìm kiếm thông minh hoặc lướt xem các danh mục món ngon: Cơm trưa, Trà sữa, Bún phở, Pizza, Ăn vặt... Xem ảnh thật, bảng giá và đánh giá từ cộng đồng.</p>
                        </div>
                    </div>

                    <div class="policy-step-card" style="display: flex; gap: 16px; align-items: flex-start;">
                        <div class="policy-step-num" style="min-width: 38px; height: 38px; font-size: 1rem;">2</div>
                        <div>
                            <div class="policy-step-title" style="font-size: 1.05rem;">Chọn món, tùy chỉnh khẩu phần &amp; Thêm vào giỏ</div>
                            <p class="policy-step-desc">Nhấn vào món ăn để chọn số lượng, thêm ghi chú (Ví dụ: <em>"Ít cay, không lấy hành, 50% đường ít đá"</em>) và bấm nút <strong>Thêm vào giỏ hàng</strong>.</p>
                        </div>
                    </div>

                    <div class="policy-step-card" style="display: flex; gap: 16px; align-items: flex-start;">
                        <div class="policy-step-num" style="min-width: 38px; height: 38px; font-size: 1rem;">3</div>
                        <div>
                            <div class="policy-step-title" style="font-size: 1.05rem;">Áp dụng Mã giảm giá &amp; Ưu đãi Freeship</div>
                            <p class="policy-step-desc">Mở Giỏ hàng, nhập mã khuyến mãi (như <strong>UTEE15</strong>) hoặc chọn voucher Freeship trong danh sách mã khả dụng để tiết kiệm tối đa chi phí.</p>
                        </div>
                    </div>

                    <div class="policy-step-card" style="display: flex; gap: 16px; align-items: flex-start;">
                        <div class="policy-step-num" style="min-width: 38px; height: 38px; font-size: 1rem;">4</div>
                        <div>
                            <div class="policy-step-title" style="font-size: 1.05rem;">Kiểm tra địa chỉ &amp; Chọn phương thức thanh toán</div>
                            <p class="policy-step-desc">Xác nhận địa chỉ nhận món chính xác, chọn thanh toán bằng Tiền mặt (COD) hoặc Chuyển khoản QR, sau đó nhấn <strong>Xác nhận đặt đơn</strong>.</p>
                        </div>
                    </div>

                    <div class="policy-step-card" style="display: flex; gap: 16px; align-items: flex-start;">
                        <div class="policy-step-num" style="min-width: 38px; height: 38px; font-size: 1rem;">5</div>
                        <div>
                            <div class="policy-step-title" style="font-size: 1.05rem;">Theo dõi đơn hàng &amp; Nhận món nóng hổi</div>
                            <p class="policy-step-desc">Theo dõi thông báo cập nhật trực tiếp: Quán nấu -> Tài xế nhận -> Đang giao. Khi tài xế đến nơi, nhận món ăn nóng hổi và để lại đánh giá 5 sao cho quán nhé!</p>
                        </div>
                    </div>
                </div>

                <div style="text-align: center; margin-top: 30px;">
                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary" style="border-radius: 50px; padding: 12px 32px; font-weight: 800; font-size: 1rem; box-shadow: 0 6px 20px rgba(240, 84, 84, 0.3);">
                        <i class="fa-solid fa-utensils me-2"></i> Khám Phá Thực Đơn &amp; Đặt Món Ngay
                    </a>
                </div>
            </div>

        </main>
    </div>
</div>

<script>
function switchPolicyTab(tabId, navEl) {
    // Cập nhật URL mà không cần reload trang
    var url = new URL(window.location.href);
    url.searchParams.set('tab', tabId);
    window.history.pushState({}, '', url);

    // Active Sidebar Nav Link
    document.querySelectorAll('.policy-nav-item').forEach(function(item) {
        item.classList.remove('active');
    });
    if (navEl) {
        navEl.classList.add('active');
    }

    // Active Tab Pane
    document.querySelectorAll('.policy-tab-pane').forEach(function(pane) {
        pane.classList.remove('active');
    });
    var targetPane = document.getElementById('tab-' + tabId);
    if (targetPane) {
        targetPane.classList.add('active');
    }

    // Cuộn mượt đến đầu khung nội dung trên mobile
    if (window.innerWidth < 900) {
        var contentCard = document.querySelector('.policy-content-card');
        if (contentCard) {
            contentCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }
}

function toggleFaq(el) {
    var parent = el.closest('.policy-faq-item');
    if (parent) {
        parent.classList.toggle('open');
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
