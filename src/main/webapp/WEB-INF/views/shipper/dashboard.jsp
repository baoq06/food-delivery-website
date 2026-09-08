<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Kênh Tài Xế - Bảng tin" />
</jsp:include>

<style>
    .dashboard-layout { display: flex; gap: 24px; flex-wrap: wrap; }
    .dashboard-sidebar { flex: 0 0 280px; }
    .dashboard-main { flex: 1; min-width: 0; }
    .card { background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 24px; }
    .card-header { padding: 16px 20px; font-weight: 700; font-size: 1.1rem; }
    .bg-warning { background-color: #ffc107; color: #000; }
    .card-body { padding: 20px; }
    .list-group { display: flex; flex-direction: column; }
    .list-group-item { padding: 12px 20px; border-bottom: 1px solid #eee; text-decoration: none; color: #333; display: block; }
    .list-group-item.active { background-color: #fff3cd; color: #856404; font-weight: bold; border-left: 4px solid #ffc107; }
    .list-group-item:hover:not(.active) { background-color: #f8f9fa; }
    .status-panel { padding: 20px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; }
</style>

<div class="container mt-4 mb-5" style="margin-top: 40px; margin-bottom: 60px;">
    <div class="dashboard-layout">
        <!-- Sidebar Tài Xế -->
        <div class="dashboard-sidebar">
            <div class="card">
                <div class="card-header bg-warning text-center">
                    <h5 class="mb-0" style="margin: 0;"><i class="fa-solid fa-motorcycle"></i> Đối Tác Giao Hàng</h5>
                </div>
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/shipper/dashboard" class="list-group-item active">
                        <i class="fa-solid fa-house me-2"></i> Bảng điều khiển
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history" class="list-group-item">
                        <i class="fa-solid fa-clock-rotate-left me-2"></i> Lịch sử giao hàng
                    </a>
                </div>
                
                <c:if test="${not empty wallet}">
                <!-- THỐNG KÊ DOANH THU TÀI XẾ -->
                <div style="padding: 15px; border-top: 1px solid #eee; background: #fafafa;">
                    <h6 style="color: #6c757d; font-size: 0.9em; text-transform: uppercase;">Ví Tài Xế (Hôm Nay)</h6>
                    <h3 style="color: #28a745; margin-bottom: 5px;">
                        <fmt:formatNumber value="${wallet.todayEarnings}" pattern="#,###" /> đ
                    </h3>
                    <p style="margin: 0; font-size: 0.9em; color: #555;">Đã chạy: <strong>${wallet.todayTrips} cuốc</strong></p>
                    
                    <div style="margin-top: 15px;">
                        <h6 style="color: #6c757d; font-size: 0.9em; text-transform: uppercase;">Tổng Thu Nhập Tháng</h6>
                        <h4 style="color: #007bff; margin-bottom: 5px;"><fmt:formatNumber value="${wallet.totalEarnings}" pattern="#,###" /> đ</h4>
                        <p style="margin: 0; font-size: 0.9em; color: #555;">Tổng cộng: <strong>${wallet.totalTrips} cuốc</strong></p>
                    </div>
                </div>
                </c:if>
            </div>
        </div>

        <!-- Main Content -->
        <div class="dashboard-main">
            <div class="card">
                <div class="card-body">
                    <h2 class="mb-4" style="margin-bottom: 20px;">Chào mừng tài xế, <span class="text-primary">${sessionScope.currentUser.fullName}</span>!</h2>

                    <!-- Driver Status Panel -->
                    <div class="status-panel" style="background-color: #fff9e6; border: 1px solid #ffeeba;">
                        <div>
                            <h3 class="mb-2" style="font-size: 1.2rem; margin-bottom: 8px;">Trạng thái nhận đơn</h3>
                            <c:choose>
                                <c:when test="${not empty driver and driver.status eq 'AVAILABLE'}">
                                    <p class="text-success" style="font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-check"></i> <strong>ĐANG BẬT ỨNG DỤNG (TRỰC TUYẾN)</strong></p>
                                    <p class="text-muted" style="margin: 0;">Hệ thống sẽ tự động ghép đơn hàng cho bạn ở khu vực lân cận.</p>
                                </c:when>
                                <c:when test="${not empty driver and driver.status eq 'BUSY'}">
                                    <p class="text-danger" style="font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-play"></i> <strong>ĐANG GIAO ĐƠN</strong></p>
                                    <p class="text-muted" style="margin: 0;">Bạn đang trong quá trình thực hiện giao đơn hàng. Vui lòng hoàn tất đơn hiện tại.</p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-secondary" style="color: #6c757d; font-size: 1.1rem; margin-bottom: 4px;"><i class="fa-solid fa-circle-minus"></i> <strong>ĐANG TẮT ỨNG DỤNG (NGỌAI TUYẾN)</strong></p>
                                    <p class="text-muted" style="margin: 0;">Bạn đang không nhận đơn. Hiện tại bạn có thể đặt đồ ăn như khách hàng!</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="text-end">
                            <c:if test="${driver.status ne 'BUSY'}">
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <button type="submit" class="btn ${driver.status eq 'AVAILABLE' ? 'btn-danger' : 'btn-primary'} btn-lg" style="border-radius: 50px; font-weight: 600; padding: 12px 30px; font-size: 1.1rem;">
                                        <i class="fa-solid fa-power-off me-1"></i> ${driver.status eq 'AVAILABLE' ? 'TẮT ỨNG DỤNG' : 'BẬT MÁY NHẬN ĐƠN'}
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>

                    <!-- Cuốc gần đây (Mô phỏng chức năng) -->
                    <c:choose>
                        <c:when test="${not empty activeOrder}">
                            <!-- CHI TIẾT ĐƠN HÀNG ĐANG GIAO & VÒNG ĐỜI -->
                            <h4 style="margin-top: 30px; margin-bottom: 16px;"><i class="fa-solid fa-route" style="color: #007bff;"></i> Đơn Hàng Đang Thực Hiện (#${activeOrder.id})</h4>
                            <div style="border: 1px solid #cce5ff; border-radius: 12px; overflow: hidden; background: #f8fbff; margin-bottom: 20px;">
                                <div style="display: flex; flex-wrap: wrap;">
                                    <div style="flex: 1; min-width: 300px; padding: 20px;">
                                        <p style="margin-bottom: 8px;"><strong>Khách hàng:</strong> ${activeOrder.customerName}</p>
                                        <p style="margin-bottom: 8px;"><strong>Điện thoại:</strong> <a href="tel:${activeOrder.phone}">${activeOrder.phone}</a></p>
                                        <p style="margin-bottom: 8px;"><strong>Giao tới:</strong> ${activeOrder.address}</p>
                                        <p style="margin-bottom: 8px;"><strong>Tiền thu Khách (COD):</strong> 
                                            <span style="color: #dc3545; font-weight: bold; font-size: 1.1em;">
                                                <fmt:formatNumber value="${activeOrder.totalAmount}" pattern="#,###" /> đ
                                            </span>
                                        </p>
                                        
                                        <hr style="border-top: 1px dashed #ccc;">
                                        
                                        <!-- ORDER LIFECYCLE BUTTONS -->
                                        <p style="margin-bottom: 15px; font-weight: 600;">Cập nhật lộ trình (Real-time):</p>
                                        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                                            <!-- Cập nhật trạng thái: ĐÃ LẤY MÓN -->
                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                                <input type="hidden" name="action" value="updateOrder">
                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                <input type="hidden" name="status" value="SHIPPING">
                                                <button type="submit" class="btn btn-outline-primary" onclick="alert('Trạng thái đã được cập nhật với khách hàng!');">
                                                    <i class="fa-solid fa-box"></i> Đã lấy món
                                                </button>
                                            </form>

                                            <!-- Cập nhật trạng thái: HOÀN THÀNH (DELIVERED) -->
                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                                <input type="hidden" name="action" value="updateOrder">
                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                <input type="hidden" name="status" value="DELIVERED">
                                                <button type="submit" class="btn btn-success" onclick="return confirm('Xác nhận đã giao hàng và nhận tiền thành công?');">
                                                    <i class="fa-solid fa-check"></i> Hoàn Thành
                                                </button>
                                            </form>
                                            
                                            <!-- Cập nhật trạng thái: BOM HÀNG (CANCELLED) -->
                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                                <input type="hidden" name="action" value="updateOrder">
                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                <input type="hidden" name="status" value="CANCELLED">
                                                <button type="submit" class="btn btn-outline-danger" onclick="return confirm('Báo cáo khách boom hàng? Điểm tín nhiệm của khách sẽ bị trừ!');">
                                                    <i class="fa-solid fa-ban"></i> Bom Hàng
                                                </button>
                                            </form>
                                        </div>
                                    </div>

                                    <!-- GOOGLE MAPS / LEAFLET MAP REALTIME LOCATION -->
                                    <div style="flex: 1; min-width: 300px; padding: 20px; border-left: 1px solid #cce5ff;">
                                        <h5 style="margin-bottom: 12px; font-size: 1rem;"><i class="fa-solid fa-location-dot" style="color: #dc3545;"></i> Bản đồ chỉ đường (Định vị GPS)</h5>
                                        <!-- Leaflet CSS & JS injected natively here -->
                                        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                                        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                                        
                                        <div id="mapTracker" style="width: 100%; height: 200px; border-radius: 8px; background: #e9ecef; position: relative;">
                                            <!-- Fallback text -->
                                            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: #6c757d;">
                                                Đang tải dữ liệu GPS...
                                            </div>
                                        </div>
                                        
                                        <script>
                                            // Chạy script map sau khi DOM map xuất hiện
                                            setTimeout(function() {
                                                // Default viewport HCM
                                                var map = L.map('mapTracker').setView([10.762622, 106.660172], 13);
                                                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                    attribution: '© Map Data (Utee Navigation)'
                                                }).addTo(map);

                                                var driverMarker = null;

                                                // Lấy định vị Real-time bằng HTML5 Geolocation API
                                                if (navigator.geolocation) {
                                                    navigator.geolocation.watchPosition(function(position) {
                                                        var lat = position.coords.latitude;
                                                        var lng = position.coords.longitude;
                                                        
                                                        if (driverMarker === null) {
                                                            // Tạo marker xe máy
                                                            var redIcon = L.icon({
                                                                iconUrl: 'https://cdn-icons-png.flaticon.com/512/7592/7592236.png',
                                                                iconSize: [40, 40],
                                                            });
                                                            driverMarker = L.marker([lat, lng], {icon: redIcon}).addTo(map);
                                                            driverMarker.bindPopup("<b>Vị trí tài xế (Bạn)</b><br>Đang cập nhật...").openPopup();
                                                            map.setView([lat, lng], 15);
                                                        } else {
                                                            driverMarker.setLatLng([lat, lng]);
                                                        }
                                                    }, function(error) {
                                                        console.warn("Lỗi định vị GPS: " + error.message);
                                                    }, {
                                                        enableHighAccuracy: true,
                                                        maximumAge: 5000
                                                    });
                                                }
                                            }, 500);
                                        </script>
                                        <p style="font-size: 0.85em; color: #6c757d; margin-top: 10px; margin-bottom: 0;">*Yêu cầu trình duyệt cấp quyền Vị Trí (Location) để dẫn đường.</p>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:when test="${driver.status eq 'AVAILABLE'}">
                            <!-- TÌM ĐƠN HÀNG MỚI -->
                            <h4 style="margin-top: 30px; margin-bottom: 16px;">Đăng ký nhận đơn quanh đây</h4>
                            
                            <!-- Smart Dispatch radar -->
                            <div id="radarScan" style="background: #e0f7fa; color: #006064; padding: 30px 20px; text-align: center; border-radius: 12px; border: 1px dashed #b2ebf2; margin-bottom: 20px;">
                                <div class="spinner-grow text-info" role="status" style="width: 3rem; height: 3rem;"></div>
                                <h5 class="mt-3">Hệ thống đang phát tín hiệu rada...</h5>
                                <p id="radarStatus">Đứng yên vùng có nhiều nhà hàng để dễ trúng cuốc xe!</p>
                            </div>
                            
                            <!-- New Order Popup Box (Hidden default) -->
                            <div id="orderPopup" style="display: none; border: 2px solid #ffc107; background: #fffde7; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 20px; animation: pulse 1s infinite alternate;">
                                <h4 style="color: #d32f2f; margin-bottom: 15px;"><i class="fa-solid fa-bell fa-shake"></i> Bạn có đơn hàng mới!</h4>
                                <p style="font-size: 1.1em; margin-bottom: 5px;"><strong>Mã đơn:</strong> <span id="pOrderId"></span></p>
                                <p style="font-size: 1.1em; margin-bottom: 5px;"><strong>Khách hàng:</strong> <span id="pCustomer"></span></p>
                                <p style="font-size: 1.1em; margin-bottom: 5px;"><strong>Giao tới:</strong> <span id="pAddress"></span></p>
                                <p style="font-size: 1.1em; margin-bottom: 15px;"><strong>Tổng phí:</strong> <span id="pAmount" style="color: #28a745; font-weight: bold;"></span> đ</p>
                                
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET">
                                    <input type="hidden" name="action" value="acceptOrder">
                                    <input type="hidden" name="orderId" id="fOrderId" value="">
                                    <button type="submit" class="btn btn-warning btn-lg btn-block" style="font-weight: 700; width: 100%;">🔥 BẤM NHẬN CUỐC NGAY</button>
                                </form>
                            </div>

                            <style>
                                @keyframes pulse {
                                    from { box-shadow: 0 0 10px #ffc107; transform: scale(1); }
                                    to { box-shadow: 0 0 20px #ff9800; transform: scale(1.02); }
                                }
                            </style>

                            <script>
                                document.addEventListener("DOMContentLoaded", function() {
                                    let isDisplayingOrder = false;

                                    setInterval(function() {
                                        if (isDisplayingOrder) return; // Nếu đang hiện đơn thì ngưng quét

                                        fetch('${pageContext.request.contextPath}/shipper/api/dispatch')
                                            .then(response => response.json())
                                            .then(data => {
                                                if(data.status === 'found') {
                                                    isDisplayingOrder = true;
                                                    // Đã tìm thấy đơn
                                                    document.getElementById('radarScan').style.display = 'none';
                                                    document.getElementById('orderPopup').style.display = 'block';

                                                    // Điền thông tin đơn
                                                    document.getElementById('pOrderId').innerText = '#' + data.orderId;
                                                    document.getElementById('pCustomer').innerText = data.customer;
                                                    document.getElementById('pAddress').innerText = data.address;
                                                    document.getElementById('pAmount').innerText = new Intl.NumberFormat('vi-VN').format(data.amount);
                                                    document.getElementById('fOrderId').value = data.orderId;

                                                    // Tự động phát âm thanh chuông báo
                                                    let audio = new Audio('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3');
                                                    audio.play().catch(e => console.log('Auto-play blocked'));
                                                }
                                            })
                                            .catch(error => console.error('Lỗi dispatch:', error));
                                    }, 4000); // Quét mỗi 4 giây
                                });
                            </script>
                        </c:when>
                    </c:choose>

                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
