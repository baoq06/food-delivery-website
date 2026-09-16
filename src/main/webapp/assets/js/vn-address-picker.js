/**
 * VNAddressPicker - Bộ chọn địa chỉ hành chính Việt Nam (Tỉnh/Thành -> Quận/Huyện -> Phường/Xã -> Chi tiết)
 * Tích hợp Open API chuẩn quốc gia: https://provinces.open-api.vn/api/
 * Hỗ trợ Cache Session, Offline Fallback, Auto-sync, và giao diện chuẩn UI/UX Pro Max.
 */
(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        define([], factory);
    } else if (typeof module === 'object' && module.exports) {
        module.exports = factory();
    } else {
        root.VNAddressPicker = factory();
    }
}(typeof self !== 'undefined' ? self : this, function () {
    'use strict';

    const API_BASE = 'https://provinces.open-api.vn/api';
    const CACHE_PREFIX = 'ute_vn_geo_';
    const CACHE_EXPIRE_MS = 24 * 60 * 60 * 1000; // 24 giờ

    // Dữ liệu dự phòng nhanh khi ngoại tuyến hoặc mạng gặp sự cố
    const FALLBACK_PROVINCES = [
        { code: 79, name: 'Thành phố Hồ Chí Minh', division_type: 'thành phố trung ương' },
        { code: 1, name: 'Thành phố Hà Nội', division_type: 'thành phố trung ương' },
        { code: 48, name: 'Thành phố Đà Nẵng', division_type: 'thành phố trung ương' },
        { code: 31, name: 'Thành phố Hải Phòng', division_type: 'thành phố trung ương' },
        { code: 92, name: 'Thành phố Cần Thơ', division_type: 'thành phố trung ương' },
        { code: 74, name: 'Tỉnh Bình Dương', division_type: 'tỉnh' },
        { code: 75, name: 'Tỉnh Đồng Nai', division_type: 'tỉnh' },
        { code: 77, name: 'Tỉnh Bà Rịa - Vũng Tàu', division_type: 'tỉnh' },
        { code: 80, name: 'Tỉnh Long An', division_type: 'tỉnh' },
        { code: 68, name: 'Tỉnh Lâm Đồng', division_type: 'tỉnh' },
        { code: 56, name: 'Tỉnh Khánh Hòa', division_type: 'tỉnh' },
        { code: 46, name: 'Tỉnh Thừa Thiên Huế', division_type: 'tỉnh' }
    ];

    const FALLBACK_DISTRICTS_HCM = [
        { code: 769, name: 'Thành phố Thủ Đức', province_code: 79 },
        { code: 760, name: 'Quận 1', province_code: 79 },
        { code: 770, name: 'Quận 3', province_code: 79 },
        { code: 773, name: 'Quận 4', province_code: 79 },
        { code: 774, name: 'Quận 5', province_code: 79 },
        { code: 775, name: 'Quận 6', province_code: 79 },
        { code: 778, name: 'Quận 7', province_code: 79 },
        { code: 776, name: 'Quận 8', province_code: 79 },
        { code: 771, name: 'Quận 10', province_code: 79 },
        { code: 772, name: 'Quận 11', province_code: 79 },
        { code: 761, name: 'Quận 12', province_code: 79 },
        { code: 764, name: 'Quận Gò Vấp', province_code: 79 },
        { code: 765, name: 'Quận Bình Thạnh', province_code: 79 },
        { code: 766, name: 'Quận Tân Bình', province_code: 79 },
        { code: 767, name: 'Quận Tân Phú', province_code: 79 },
        { code: 768, name: 'Quận Phú Nhuận', province_code: 79 },
        { code: 777, name: 'Quận Bình Tân', province_code: 79 }
    ];

    const FALLBACK_WARDS_THUDUC = [
        { code: 26815, name: 'Phường Linh Chiểu', district_code: 769 },
        { code: 26812, name: 'Phường Hiệp Bình Chánh', district_code: 769 },
        { code: 26809, name: 'Phường Hiệp Bình Phước', district_code: 769 },
        { code: 26818, name: 'Phường Linh Tây', district_code: 769 },
        { code: 26821, name: 'Phường Linh Đông', district_code: 769 },
        { code: 26824, name: 'Phường Bình Thọ', district_code: 769 },
        { code: 26827, name: 'Phường Trường Thọ', district_code: 769 },
        { code: 26839, name: 'Phường Hiệp Phú', district_code: 769 },
        { code: 26842, name: 'Phường Tăng Nhơn Phú A', district_code: 769 },
        { code: 26845, name: 'Phường Tăng Nhơn Phú B', district_code: 769 },
        { code: 27088, name: 'Phường Thảo Điền', district_code: 769 },
        { code: 27091, name: 'Phường An Phú', district_code: 769 }
    ];

    // Quản lý bộ nhớ đệm
    function getCache(key) {
        try {
            const raw = localStorage.getItem(CACHE_PREFIX + key);
            if (!raw) return null;
            const item = JSON.parse(raw);
            if (Date.now() - item.timestamp > CACHE_EXPIRE_MS) {
                localStorage.removeItem(CACHE_PREFIX + key);
                return null;
            }
            return item.data;
        } catch (e) {
            return null;
        }
    }

    function setCache(key, data) {
        try {
            localStorage.setItem(CACHE_PREFIX + key, JSON.stringify({
                timestamp: Date.now(),
                data: data
            }));
        } catch (e) {
            // Bộ nhớ đầy hoặc chế độ ẩn danh không cho phép
        }
    }

    // Các hàm nạp dữ liệu từ API
    async function fetchProvinces() {
        const cached = getCache('provinces');
        if (cached && Array.isArray(cached) && cached.length > 0) {
            return cached;
        }

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 6000);
            const res = await fetch(`${API_BASE}/?depth=1`, { signal: controller.signal });
            clearTimeout(timeoutId);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            if (Array.isArray(data) && data.length > 0) {
                setCache('provinces', data);
                return data;
            }
        } catch (err) {
            console.warn('[VNAddressPicker] Không thể kết nối API tỉnh thành, dùng danh sách dự phòng:', err.message);
        }
        return FALLBACK_PROVINCES;
    }

    async function fetchDistricts(provinceCode) {
        if (!provinceCode) return [];
        const cacheKey = `districts_${provinceCode}`;
        const cached = getCache(cacheKey);
        if (cached && Array.isArray(cached)) {
            return cached;
        }

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 6000);
            const res = await fetch(`${API_BASE}/p/${provinceCode}?depth=2`, { signal: controller.signal });
            clearTimeout(timeoutId);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            if (data && Array.isArray(data.districts)) {
                setCache(cacheKey, data.districts);
                return data.districts;
            }
        } catch (err) {
            console.warn(`[VNAddressPicker] Lỗi tải quận/huyện cho tỉnh ${provinceCode}:`, err.message);
        }

        if (provinceCode == 79) {
            return FALLBACK_DISTRICTS_HCM;
        }
        return [];
    }

    async function fetchWards(districtCode) {
        if (!districtCode) return [];
        const cacheKey = `wards_${districtCode}`;
        const cached = getCache(cacheKey);
        if (cached && Array.isArray(cached)) {
            return cached;
        }

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 6000);
            const res = await fetch(`${API_BASE}/d/${districtCode}?depth=2`, { signal: controller.signal });
            clearTimeout(timeoutId);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            if (data && Array.isArray(data.wards)) {
                setCache(cacheKey, data.wards);
                return data.wards;
            }
        } catch (err) {
            console.warn(`[VNAddressPicker] Lỗi tải phường/xã cho huyện ${districtCode}:`, err.message);
        }

        if (districtCode == 769) {
            return FALLBACK_WARDS_THUDUC;
        }
        return [];
    }

    /**
     * Khởi tạo bộ chọn địa chỉ trên một container
     */
    class PickerInstance {
        constructor(config) {
            this.container = typeof config.container === 'string' ? document.getElementById(config.container) : config.container;
            this.targetInput = typeof config.targetInput === 'string' ? document.getElementById(config.targetInput) : config.targetInput;
            this.initialAddress = (config.initialAddress || (this.targetInput ? this.targetInput.value : '') || '').trim();
            this.theme = config.theme || 'default'; // 'default', 'compact', 'modal'
            this.label = config.label || 'Địa chỉ hành chính';
            this.onChange = config.onChange || null;
            this.idPrefix = 'vn_addr_' + Math.random().toString(36).substring(2, 8);

            this.selectedProvince = null;
            this.selectedDistrict = null;
            this.selectedWard = null;
            this.streetDetail = '';
            this.isManualMode = false;

            this.render();
            this.initData();
        }

        render() {
            if (!this.container) return;

            this.container.innerHTML = `
                <div class="vn-address-picker-card" id="${this.idPrefix}_card">
                    <div class="vn-picker-header">
                        <div class="vn-picker-title">
                            <i class="fa-solid fa-map-location-dot vn-picker-icon"></i>
                            <span>Khu vực hành chính Việt Nam</span>
                        </div>
                        <button type="button" class="vn-toggle-manual-btn" id="${this.idPrefix}_toggleManual" title="Chuyển đổi cách nhập">
                            <i class="fa-solid fa-pen-to-square"></i>
                            <span id="${this.idPrefix}_toggleText">Nhập tự do</span>
                        </button>
                    </div>

                    <!-- Chế độ chọn liên hoàn 3 cấp (Cascading selects) -->
                    <div class="vn-cascading-section" id="${this.idPrefix}_cascadingSection">
                        <div class="vn-select-grid">
                            <!-- 1. Tỉnh / Thành phố -->
                            <div class="vn-field-item">
                                <label for="${this.idPrefix}_prov" class="vn-field-label">
                                    Tỉnh / Thành phố <span class="vn-req">*</span>
                                </label>
                                <div class="vn-select-wrapper">
                                    <select id="${this.idPrefix}_prov" class="vn-form-select">
                                        <option value="">-- Chọn Tỉnh / Thành --</option>
                                    </select>
                                    <i class="fa-solid fa-chevron-down vn-select-arrow"></i>
                                </div>
                            </div>

                            <!-- 2. Quận / Huyện -->
                            <div class="vn-field-item">
                                <label for="${this.idPrefix}_dist" class="vn-field-label">
                                    Quận / Huyện <span class="vn-req">*</span>
                                </label>
                                <div class="vn-select-wrapper">
                                    <select id="${this.idPrefix}_dist" class="vn-form-select" disabled>
                                        <option value="">-- Chọn Quận / Huyện --</option>
                                    </select>
                                    <i class="fa-solid fa-chevron-down vn-select-arrow"></i>
                                </div>
                            </div>

                            <!-- 3. Phường / Xã -->
                            <div class="vn-field-item">
                                <label for="${this.idPrefix}_ward" class="vn-field-label">
                                    Phường / Xã <span class="vn-req">*</span>
                                </label>
                                <div class="vn-select-wrapper">
                                    <select id="${this.idPrefix}_ward" class="vn-form-select" disabled>
                                        <option value="">-- Chọn Phường / Xã --</option>
                                    </select>
                                    <i class="fa-solid fa-chevron-down vn-select-arrow"></i>
                                </div>
                            </div>
                        </div>

                        <!-- 4. Số nhà, tên đường -->
                        <div class="vn-field-item vn-street-item">
                            <label for="${this.idPrefix}_street" class="vn-field-label">
                                Số nhà, tên đường, tòa nhà / căn hộ <span class="vn-req">*</span>
                            </label>
                            <div class="vn-input-wrapper">
                                <i class="fa-solid fa-house vn-input-icon"></i>
                                <input type="text" id="${this.idPrefix}_street" class="vn-form-input" 
                                       placeholder="Ví dụ: Số 01 Võ Văn Ngân, Chung cư Moonlight..." />
                            </div>
                        </div>
                    </div>

                    <!-- Chế độ nhập tự do nếu muốn -->
                    <div class="vn-manual-section" id="${this.idPrefix}_manualSection" style="display: none;">
                        <div class="vn-field-item">
                            <label for="${this.idPrefix}_manualInput" class="vn-field-label">
                                Địa chỉ nhập tự do <span class="vn-req">*</span>
                            </label>
                            <div class="vn-input-wrapper">
                                <i class="fa-solid fa-location-dot vn-input-icon"></i>
                                <input type="text" id="${this.idPrefix}_manualInput" class="vn-form-input" 
                                       placeholder="Nhập đầy đủ số nhà, đường, phường, quận, tỉnh..." />
                            </div>
                        </div>
                    </div>

                    <!-- Live Address Result Preview & Status -->
                    <div class="vn-picker-preview" id="${this.idPrefix}_previewBox">
                        <div class="vn-preview-tag">
                            <i class="fa-solid fa-check-circle text-success me-1"></i> Địa chỉ chuẩn hóa:
                        </div>
                        <div class="vn-preview-text" id="${this.idPrefix}_previewText">
                            ${this.initialAddress ? this.escapeHtml(this.initialAddress) : '<span class="vn-placeholder-hint">Chưa chọn đầy đủ thông tin khu vực</span>'}
                        </div>
                    </div>
                </div>
            `;

            this.bindEvents();
        }

        bindEvents() {
            this.provSelect = document.getElementById(`${this.idPrefix}_prov`);
            this.distSelect = document.getElementById(`${this.idPrefix}_dist`);
            this.wardSelect = document.getElementById(`${this.idPrefix}_ward`);
            this.streetInput = document.getElementById(`${this.idPrefix}_street`);
            this.manualInput = document.getElementById(`${this.idPrefix}_manualInput`);
            this.previewText = document.getElementById(`${this.idPrefix}_previewText`);
            this.toggleBtn = document.getElementById(`${this.idPrefix}_toggleManual`);
            this.toggleText = document.getElementById(`${this.idPrefix}_toggleText`);
            this.cascadingSection = document.getElementById(`${this.idPrefix}_cascadingSection`);
            this.manualSection = document.getElementById(`${this.idPrefix}_manualSection`);

            // Thay đổi Tỉnh/Thành
            this.provSelect.addEventListener('change', async (e) => {
                const provCode = e.target.value;
                const provName = e.target.options[e.target.selectedIndex]?.dataset?.name || '';
                this.selectedProvince = provCode ? { code: provCode, name: provName } : null;
                this.selectedDistrict = null;
                this.selectedWard = null;

                this.resetSelect(this.distSelect, '-- Chọn Quận / Huyện --');
                this.resetSelect(this.wardSelect, '-- Chọn Phường / Xã --');

                if (provCode) {
                    this.distSelect.disabled = true;
                    this.distSelect.innerHTML = '<option value="">Đang tải Quận/Huyện...</option>';
                    const districts = await fetchDistricts(provCode);
                    this.populateSelect(this.distSelect, districts, '-- Chọn Quận / Huyện --');
                    this.distSelect.disabled = false;
                }
                this.updateFullAddress();
            });

            // Thay đổi Quận/Huyện
            this.distSelect.addEventListener('change', async (e) => {
                const distCode = e.target.value;
                const distName = e.target.options[e.target.selectedIndex]?.dataset?.name || '';
                this.selectedDistrict = distCode ? { code: distCode, name: distName } : null;
                this.selectedWard = null;

                this.resetSelect(this.wardSelect, '-- Chọn Phường / Xã --');

                if (distCode) {
                    this.wardSelect.disabled = true;
                    this.wardSelect.innerHTML = '<option value="">Đang tải Phường/Xã...</option>';
                    const wards = await fetchWards(distCode);
                    this.populateSelect(this.wardSelect, wards, '-- Chọn Phường / Xã --');
                    this.wardSelect.disabled = false;
                }
                this.updateFullAddress();
            });

            // Thay đổi Phường/Xã
            this.wardSelect.addEventListener('change', (e) => {
                const wardCode = e.target.value;
                const wardName = e.target.options[e.target.selectedIndex]?.dataset?.name || '';
                this.selectedWard = wardCode ? { code: wardCode, name: wardName } : null;
                this.updateFullAddress();
            });

            // Nhập số nhà, tên đường
            this.streetInput.addEventListener('input', (e) => {
                this.streetDetail = e.target.value.trim();
                this.updateFullAddress();
            });

            // Nhập chế độ tự do
            this.manualInput.addEventListener('input', (e) => {
                if (this.isManualMode) {
                    const text = e.target.value.trim();
                    this.setFinalAddress(text);
                }
            });

            // Toggle chế độ thủ công / liên hoàn
            this.toggleBtn.addEventListener('click', () => {
                this.isManualMode = !this.isManualMode;
                if (this.isManualMode) {
                    this.cascadingSection.style.display = 'none';
                    this.manualSection.style.display = 'block';
                    this.toggleText.textContent = 'Chọn theo khu vực';
                    this.toggleBtn.classList.add('active');
                    this.manualInput.value = this.targetInput ? this.targetInput.value : this.streetDetail;
                    this.setFinalAddress(this.manualInput.value);
                } else {
                    this.cascadingSection.style.display = 'block';
                    this.manualSection.style.display = 'none';
                    this.toggleText.textContent = 'Nhập tự do';
                    this.toggleBtn.classList.remove('active');
                    this.updateFullAddress();
                }
            });
        }

        async initData() {
            // Tải danh sách tỉnh thành
            this.provSelect.innerHTML = '<option value="">Đang tải Tỉnh/Thành...</option>';
            const provinces = await fetchProvinces();
            this.populateSelect(this.provSelect, provinces, '-- Chọn Tỉnh / Thành --');

            // Phân tích địa chỉ ban đầu nếu có
            if (this.initialAddress) {
                await this.tryParseInitialAddress(this.initialAddress, provinces);
            }
        }

        populateSelect(selectEl, list, defaultText) {
            selectEl.innerHTML = `<option value="">${defaultText}</option>`;
            if (!Array.isArray(list)) return;
            list.forEach(item => {
                const opt = document.createElement('option');
                opt.value = item.code;
                opt.dataset.name = item.name;
                opt.textContent = item.name;
                selectEl.appendChild(opt);
            });
            selectEl.disabled = false;
        }

        resetSelect(selectEl, defaultText) {
            selectEl.innerHTML = `<option value="">${defaultText}</option>`;
            selectEl.disabled = true;
        }

        cleanGeoName(name) {
            if (!name) return '';
            return name.toLowerCase()
                .replace(/^(tỉnh|thành phố|tp\.|tp|quận|huyện|thị xã|thị trấn|phường|xã)\s+/i, '')
                .trim();
        }

        async tryParseInitialAddress(rawAddr, provinces) {
            const parts = rawAddr.split(',').map(s => s.trim()).filter(Boolean);
            if (parts.length >= 2) {
                // Thử khớp Tỉnh/Thành từ phần tử cuối
                const lastPart = parts[parts.length - 1];
                const cleanLast = this.cleanGeoName(lastPart);
                const matchedProv = provinces.find(p => 
                    p.name.toLowerCase().includes(cleanLast) || cleanLast.includes(this.cleanGeoName(p.name))
                );

                if (matchedProv) {
                    this.provSelect.value = matchedProv.code;
                    this.selectedProvince = { code: matchedProv.code, name: matchedProv.name };
                    
                    const districts = await fetchDistricts(matchedProv.code);
                    this.populateSelect(this.distSelect, districts, '-- Chọn Quận / Huyện --');

                    // Thử khớp Quận/Huyện từ phần tử kế cuối
                    if (parts.length >= 3) {
                        const distPart = parts[parts.length - 2];
                        const cleanDist = this.cleanGeoName(distPart);
                        const matchedDist = districts.find(d => 
                            d.name.toLowerCase().includes(cleanDist) || cleanDist.includes(this.cleanGeoName(d.name))
                        );

                        if (matchedDist) {
                            this.distSelect.value = matchedDist.code;
                            this.selectedDistrict = { code: matchedDist.code, name: matchedDist.name };

                            const wards = await fetchWards(matchedDist.code);
                            this.populateSelect(this.wardSelect, wards, '-- Chọn Phường / Xã --');

                            // Thử khớp Phường/Xã
                            if (parts.length >= 4) {
                                const wardPart = parts[parts.length - 3];
                                const cleanWard = this.cleanGeoName(wardPart);
                                const matchedWard = wards.find(w => 
                                    w.name.toLowerCase().includes(cleanWard) || cleanWard.includes(this.cleanGeoName(w.name))
                                );

                                if (matchedWard) {
                                    this.wardSelect.value = matchedWard.code;
                                    this.selectedWard = { code: matchedWard.code, name: matchedWard.name };
                                    
                                    // Phần còn lại phía trước là số nhà, đường
                                    const streetPart = parts.slice(0, parts.length - 3).join(', ');
                                    this.streetInput.value = streetPart;
                                    this.streetDetail = streetPart;
                                    this.updateFullAddress();
                                    return;
                                }
                            }
                        }
                    }
                }
            }

            // Nếu không thể phân tách chính xác, gán phần text vào số nhà/đường hoặc hiển thị nguyên bản
            this.streetInput.value = rawAddr;
            this.streetDetail = rawAddr;
            this.setFinalAddress(rawAddr);
        }

        updateFullAddress() {
            if (this.isManualMode) return;

            const segments = [];
            if (this.streetDetail) segments.push(this.streetDetail);
            if (this.selectedWard && this.selectedWard.name) segments.push(this.selectedWard.name);
            if (this.selectedDistrict && this.selectedDistrict.name) segments.push(this.selectedDistrict.name);
            if (this.selectedProvince && this.selectedProvince.name) segments.push(this.selectedProvince.name);

            const fullText = segments.join(', ');
            this.setFinalAddress(fullText);
        }

        setFinalAddress(text) {
            if (this.targetInput) {
                this.targetInput.value = text;
                // Kích hoạt sự kiện input/change để các listener khác (form validation, preview) nhận biết
                this.targetInput.dispatchEvent(new Event('input', { bubbles: true }));
                this.targetInput.dispatchEvent(new Event('change', { bubbles: true }));
            }

            if (this.previewText) {
                if (text && text.trim().length > 0) {
                    this.previewText.innerHTML = this.escapeHtml(text);
                    this.previewText.classList.remove('is-empty');
                } else {
                    this.previewText.innerHTML = '<span class="vn-placeholder-hint">Vui lòng chọn hoặc nhập địa chỉ đầy đủ</span>';
                    this.previewText.classList.add('is-empty');
                }
            }

            if (typeof this.onChange === 'function') {
                this.onChange({
                    fullAddress: text,
                    province: this.selectedProvince,
                    district: this.selectedDistrict,
                    ward: this.selectedWard,
                    street: this.streetDetail,
                    isManual: this.isManualMode
                });
            }
        }

        escapeHtml(str) {
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }
    }

    return {
        init: function (config) {
            return new PickerInstance(config);
        },
        fetchProvinces,
        fetchDistricts,
        fetchWards
    };
}));
