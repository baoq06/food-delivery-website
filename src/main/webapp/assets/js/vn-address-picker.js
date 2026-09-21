/**
 * VNAddressPicker - Bộ chọn địa chỉ hành chính Việt Nam (Tỉnh/Thành -> Quận/Huyện -> Phường/Xã -> Chi tiết)
 * Tích hợp Open API chuẩn quốc gia: https://provinces.open-api.vn/api/
 * Hỗ trợ Cache Session, Offline Fallback, Auto-parse thông minh chống trùng lặp, và giao diện chuẩn UI/UX Pro Max.
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
        { code: 46, name: 'Tỉnh Thừa Thiên Huế', division_type: 'tỉnh' },
        { code: 82, name: 'Tỉnh Tiền Giang', division_type: 'tỉnh' }
    ];

    const FALLBACK_DISTRICTS_HCM = [
        { code: 760, name: 'Quận 1', province_code: 79 },
        { code: 769, name: 'Thành phố Thủ Đức', province_code: 79 },
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
        { code: 777, name: 'Quận Bình Tân', province_code: 79 },
        { code: 783, name: 'Huyện Củ Chi', province_code: 79 },
        { code: 784, name: 'Huyện Hóc Môn', province_code: 79 },
        { code: 785, name: 'Huyện Bình Chánh', province_code: 79 },
        { code: 786, name: 'Huyện Nhà Bè', province_code: 79 },
        { code: 787, name: 'Huyện Cần Giờ', province_code: 79 }
    ];

    const FALLBACK_WARDS_MAP = {
        // Quận 1
        760: [
            { code: 26734, name: 'Phường Bến Nghé', district_code: 760 },
            { code: 26737, name: 'Phường Bến Thành', district_code: 760 },
            { code: 26740, name: 'Phường Đa Kao', district_code: 760 },
            { code: 26743, name: 'Phường Tân Định', district_code: 760 },
            { code: 26746, name: 'Phường Cầu Ông Lãnh', district_code: 760 },
            { code: 26749, name: 'Phường Cô Giang', district_code: 760 },
            { code: 26752, name: 'Phường Cầu Kho', district_code: 760 },
            { code: 26755, name: 'Phường Nguyễn Cư Trinh', district_code: 760 },
            { code: 26758, name: 'Phường Phạm Ngũ Lão', district_code: 760 },
            { code: 26761, name: 'Phường Nguyễn Thái Bình', district_code: 760 }
        ],
        // Quận 3
        770: [
            { code: 26788, name: 'Phường Võ Thị Sáu', district_code: 770 },
            { code: 26785, name: 'Phường 1', district_code: 770 },
            { code: 26782, name: 'Phường 2', district_code: 770 },
            { code: 26779, name: 'Phường 3', district_code: 770 },
            { code: 26776, name: 'Phường 4', district_code: 770 },
            { code: 26773, name: 'Phường 5', district_code: 770 },
            { code: 26770, name: 'Phường 9', district_code: 770 },
            { code: 26767, name: 'Phường 10', district_code: 770 },
            { code: 26764, name: 'Phường 11', district_code: 770 },
            { code: 26791, name: 'Phường 12', district_code: 770 },
            { code: 26794, name: 'Phường 13', district_code: 770 },
            { code: 26797, name: 'Phường 14', district_code: 770 }
        ],
        // Bình Thạnh
        765: [
            { code: 26860, name: 'Phường 1', district_code: 765 },
            { code: 26863, name: 'Phường 2', district_code: 765 },
            { code: 26866, name: 'Phường 3', district_code: 765 },
            { code: 26869, name: 'Phường 5', district_code: 765 },
            { code: 26872, name: 'Phường 6', district_code: 765 },
            { code: 26875, name: 'Phường 7', district_code: 765 },
            { code: 26878, name: 'Phường 11', district_code: 765 },
            { code: 26881, name: 'Phường 12', district_code: 765 },
            { code: 26884, name: 'Phường 13', district_code: 765 },
            { code: 26887, name: 'Phường 14', district_code: 765 },
            { code: 26890, name: 'Phường 15', district_code: 765 },
            { code: 26893, name: 'Phường 17', district_code: 765 },
            { code: 26896, name: 'Phường 19', district_code: 765 },
            { code: 26899, name: 'Phường 21', district_code: 765 },
            { code: 26902, name: 'Phường 22', district_code: 765 },
            { code: 26905, name: 'Phường 24', district_code: 765 },
            { code: 26908, name: 'Phường 25', district_code: 765 },
            { code: 26911, name: 'Phường 26', district_code: 765 },
            { code: 26914, name: 'Phường 27', district_code: 765 },
            { code: 26917, name: 'Phường 28', district_code: 765 }
        ],
        // TP Thủ Đức
        769: [
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
        ]
    };

    // Bảng định danh bí danh và từ viết tắt hành chính phổ biến
    const PROVINCE_ALIASES = {
        79: ['hcm', 'tphcm', 'tp hcm', 'tp.hcm', 'tp. hcm', 'ho chi minh', 'hồ chí minh', 'sai gon', 'sài gòn', 'saigon', 'hcmc'],
        1: ['ha noi', 'hà nội', 'hn', 'tphn', 'tp hn', 'tp.hn', 'tp. hn'],
        48: ['da nang', 'đà nẵng', 'dn', 'đn', 'tp da nang', 'tp đà nẵng'],
        31: ['hai phong', 'hải phòng', 'hp', 'tp hai phong', 'tp hải phòng'],
        92: ['can tho', 'cần thơ', 'ct', 'tp can tho', 'tp cần thơ'],
        77: ['ba ria vung tau', 'bà rịa vũng tàu', 'ba ria - vung tau', 'bà rịa - vũng tàu', 'brvt', 'br-vt', 'vung tau', 'vũng tàu'],
        46: ['thua thien hue', 'thừa thiên huế', 'thua thien - hue', 'thừa thiên - huế', 'tt hue', 'tt huế', 'hue', 'huế']
    };

    function removeVietnameseTones(str) {
        if (!str) return '';
        return String(str).normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd').replace(/Đ/g, 'D');
    }

    function cleanGeoText(str) {
        if (!str) return '';
        let s = String(str).toLowerCase().trim();
        s = s.replace(/[.,\-_/]+/g, ' ').replace(/\s+/g, ' ').trim();
        // Bỏ các tiền tố hành chính phổ biến
        s = s.replace(/^(tỉnh|thành phố|thanh pho|tp|quận|quan|huyện|huyen|thị xã|thi xa|phường|phuong|xã|xa|thị trấn|thi tran|q|p|h|tx|tt)\s+/i, '');
        return s.trim();
    }

    function escapeRegex(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }

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
            // QuotaExceeded hoặc Private Mode
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
        if (cached && Array.isArray(cached) && cached.length > 0) {
            return cached;
        }

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 6000);
            const res = await fetch(`${API_BASE}/p/${provinceCode}?depth=2`, { signal: controller.signal });
            clearTimeout(timeoutId);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            if (data && Array.isArray(data.districts) && data.districts.length > 0) {
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
        if (cached && Array.isArray(cached) && cached.length > 0) {
            return cached;
        }

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 6000);
            const res = await fetch(`${API_BASE}/d/${districtCode}?depth=2`, { signal: controller.signal });
            clearTimeout(timeoutId);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            if (data && Array.isArray(data.wards) && data.wards.length > 0) {
                setCache(cacheKey, data.wards);
                return data.wards;
            }
        } catch (err) {
            console.warn(`[VNAddressPicker] Lỗi tải phường/xã cho huyện ${districtCode}:`, err.message);
        }

        if (FALLBACK_WARDS_MAP[districtCode]) {
            return FALLBACK_WARDS_MAP[districtCode];
        }
        return [];
    }

    // Các hàm đối sánh địa lý thông minh (Matching Engine)
    function matchProvince(text, provinces) {
        if (!text || !Array.isArray(provinces)) return null;
        const clean = cleanGeoText(text);
        const unaccent = removeVietnameseTones(clean);
        if (!clean) return null;

        // 1. Khớp từ viết tắt/bí danh đặc thù
        for (const prov of provinces) {
            const aliases = PROVINCE_ALIASES[prov.code];
            if (aliases && (aliases.includes(clean) || aliases.includes(unaccent))) {
                return prov;
            }
        }

        // 2. Khớp chính xác tên tỉnh/thành đã làm sạch
        for (const prov of provinces) {
            const provClean = cleanGeoText(prov.name);
            const provUnaccent = removeVietnameseTones(provClean);
            if (provClean === clean || provUnaccent === unaccent) {
                return prov;
            }
        }

        // 3. Khớp bao hàm (tối thiểu 3 ký tự để tránh nhầm)
        for (const prov of provinces) {
            const provClean = cleanGeoText(prov.name);
            const provUnaccent = removeVietnameseTones(provClean);
            if (clean.length >= 3 && (provClean.includes(clean) || clean.includes(provClean))) {
                return prov;
            }
            if (unaccent.length >= 3 && (provUnaccent.includes(unaccent) || unaccent.includes(provUnaccent))) {
                return prov;
            }
        }
        return null;
    }

    function matchDistrict(text, districts) {
        if (!text || !Array.isArray(districts)) return null;
        const clean = cleanGeoText(text);
        const unaccent = removeVietnameseTones(clean);
        if (!clean) return null;

        // Xử lý quận/huyện dạng số (Quận 1, Q.1, Q.10, Q12...)
        const numMatch = clean.match(/^\d+$/);
        if (numMatch) {
            const targetNum = parseInt(numMatch[0], 10);
            return districts.find(d => {
                const dClean = cleanGeoText(d.name);
                const dNum = dClean.match(/^\d+$/);
                if (dNum && parseInt(dNum[0], 10) === targetNum) return true;
                const distNumMatch = d.name.match(/\b(\d+)\b/);
                if (distNumMatch && parseInt(distNumMatch[1], 10) === targetNum) return true;
                return false;
            }) || null;
        }

        // Khớp chính xác tên
        for (const d of districts) {
            const dClean = cleanGeoText(d.name);
            const dUnaccent = removeVietnameseTones(dClean);
            if (dClean === clean || dUnaccent === unaccent) return d;
        }

        // Khớp bao hàm chuỗi chữ
        for (const d of districts) {
            const dClean = cleanGeoText(d.name);
            const dUnaccent = removeVietnameseTones(dClean);
            if (clean.length >= 3 && (dClean.includes(clean) || clean.includes(dClean))) return d;
            if (unaccent.length >= 3 && (dUnaccent.includes(unaccent) || unaccent.includes(dUnaccent))) return d;
        }
        return null;
    }

    function matchWard(text, wards) {
        if (!text || !Array.isArray(wards)) return null;
        const clean = cleanGeoText(text);
        const unaccent = removeVietnameseTones(clean);
        if (!clean) return null;

        // Xử lý phường dạng số (Phường 1, P.22, P.01...)
        const numMatch = clean.match(/^\d+$/);
        if (numMatch) {
            const targetNum = parseInt(numMatch[0], 10);
            return wards.find(w => {
                const wClean = cleanGeoText(w.name);
                const wNum = wClean.match(/^\d+$/);
                if (wNum && parseInt(wNum[0], 10) === targetNum) return true;
                const wardNumMatch = w.name.match(/\b(\d+)\b/);
                if (wardNumMatch && parseInt(wardNumMatch[1], 10) === targetNum) return true;
                return false;
            }) || null;
        }

        // Khớp chính xác tên
        for (const w of wards) {
            const wClean = cleanGeoText(w.name);
            const wUnaccent = removeVietnameseTones(wClean);
            if (wClean === clean || wUnaccent === unaccent) return w;
        }

        // Khớp bao hàm
        for (const w of wards) {
            const wClean = cleanGeoText(w.name);
            const wUnaccent = removeVietnameseTones(wClean);
            if (clean.length >= 3 && (wClean.includes(clean) || clean.includes(wClean))) return w;
            if (unaccent.length >= 3 && (wUnaccent.includes(unaccent) || unaccent.includes(wUnaccent))) return w;
        }
        return null;
    }

    function isMatchAny(text, list) {
        if (!text || !list) return false;
        const clean = cleanGeoText(text);
        const unaccent = removeVietnameseTones(clean);
        return list.some(item => {
            const c = cleanGeoText(item);
            const u = removeVietnameseTones(c);
            return c === clean || u === unaccent || (clean.length >= 3 && c.includes(clean));
        });
    }

    /**
     * Làm sạch phần số nhà, tên đường để chống lặp lại Phường, Quận, Tỉnh khi nối chuỗi
     */
    function cleanStreetAddress(streetStr, ward, district, province) {
        if (!streetStr) return '';
        let s = streetStr.trim();

        // 1. Phân tách theo dấu phẩy từ phải sang trái để loại bỏ các phân đoạn hành chính bị lẫn vào
        if (s.includes(',')) {
            let parts = s.split(',').map(item => item.trim()).filter(Boolean);
            while (parts.length > 0) {
                const last = parts[parts.length - 1];
                if (province && (matchProvince(last, [province]) || isMatchAny(last, [province.name]))) {
                    parts.pop();
                    continue;
                }
                if (district && (matchDistrict(last, [district]) || isMatchAny(last, [district.name]))) {
                    parts.pop();
                    continue;
                }
                if (ward && (matchWard(last, [ward]) || isMatchAny(last, [ward.name]))) {
                    parts.pop();
                    continue;
                }
                break;
            }
            s = parts.join(', ').trim();
        }

        // 2. Loại bỏ các hậu tố không dấu phẩy ở cuối chuỗi
        if (province && province.name) {
            const provPattern = new RegExp(`(?:,\\s*|\\s+)(?:thành phố|tỉnh|tp\\.?|)\\s*${escapeRegex(cleanGeoText(province.name))}\\s*$`, 'i');
            s = s.replace(provPattern, '').trim();
            if (province.code == 79) {
                s = s.replace(/(?:,\s*|\\s+)(?:tp\.?\s*hcm|tphcm|hcm|sài gòn|hồ chí minh)\s*$/i, '').trim();
            }
        }

        if (district && district.name) {
            const distClean = cleanGeoText(district.name);
            const distNum = distClean.match(/^\d+$/);
            if (distNum) {
                s = s.replace(new RegExp(`(?:,\\s*|\\s+)(?:quận|q\\.?)\\s*0?${distNum[0]}\\s*$`, 'i'), '').trim();
            } else {
                s = s.replace(new RegExp(`(?:,\\s*|\\s+)(?:quận|huyện|thị xã|tp\\.?|)\\s*${escapeRegex(distClean)}\\s*$`, 'i'), '').trim();
            }
        }

        if (ward && ward.name) {
            const wardClean = cleanGeoText(ward.name);
            const wardNum = wardClean.match(/^\d+$/);
            if (wardNum) {
                s = s.replace(new RegExp(`(?:,\\s*|\\s+)(?:phường|p\\.?|xã|x\\.?)\\s*0?${wardNum[0]}\\s*$`, 'i'), '').trim();
            } else {
                s = s.replace(new RegExp(`(?:,\\s*|\\s+)(?:phường|p\\.?|xã|x\\.?|thị trấn|tt\\.?|)\\s*${escapeRegex(wardClean)}\\s*$`, 'i'), '').trim();
            }
        }

        // Loại bỏ dấu phẩy thừa ở cuối nếu có
        s = s.replace(/[, \-]+$/, '').trim();
        return s;
    }

    /**
     * Khởi tạo bộ chọn địa chỉ trên một container
     */
    class PickerInstance {
        constructor(config) {
            this.container = typeof config.container === 'string' ? document.getElementById(config.container) : config.container;
            this.targetInput = typeof config.targetInput === 'string' ? document.getElementById(config.targetInput) : config.targetInput;
            this.initialAddress = (config.initialAddress || (this.targetInput ? this.targetInput.value : '') || '').trim();
            this.theme = config.theme || 'default';
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
                        <button type="button" class="vn-toggle-manual-btn" id="${this.idPrefix}_toggleManual" title="Chuyển đổi chế độ nhập" style="display: none !important;">
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
                                <button type="button" class="vn-input-clear" id="${this.idPrefix}_clearStreet" title="Xóa số nhà/đường" style="display: none;">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
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
                        <div class="vn-preview-header">
                            <div class="vn-preview-tag">
                                <i class="fa-solid fa-check-circle text-success me-1"></i> Địa chỉ chuẩn hóa:
                            </div>
                            <span class="vn-badge-synced" id="${this.idPrefix}_syncBadge" style="display: none;">
                                <i class="fa-solid fa-wand-magic-sparkles"></i> Đã đồng bộ địa chỉ
                            </span>
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
            this.clearStreetBtn = document.getElementById(`${this.idPrefix}_clearStreet`);
            this.manualInput = document.getElementById(`${this.idPrefix}_manualInput`);
            this.previewText = document.getElementById(`${this.idPrefix}_previewText`);
            this.syncBadge = document.getElementById(`${this.idPrefix}_syncBadge`);
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
                this.sanitizeAndUpdate();
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
                this.sanitizeAndUpdate();
            });

            // Thay đổi Phường/Xã
            this.wardSelect.addEventListener('change', (e) => {
                const wardCode = e.target.value;
                const wardName = e.target.options[e.target.selectedIndex]?.dataset?.name || '';
                this.selectedWard = wardCode ? { code: wardCode, name: wardName } : null;
                this.sanitizeAndUpdate();
            });

            // Nhập số nhà, tên đường
            this.streetInput.addEventListener('input', (e) => {
                this.streetDetail = e.target.value.trim();
                this.toggleClearBtn();
                this.updateFullAddress();
            });

            // Khi rời ô số nhà/đường, tự động loại bỏ các thành phần hành chính bị dán thừa
            this.streetInput.addEventListener('blur', () => {
                this.sanitizeAndUpdate();
            });

            // Nút xóa nhanh ô số nhà, tên đường
            if (this.clearStreetBtn) {
                this.clearStreetBtn.addEventListener('click', () => {
                    this.streetInput.value = '';
                    this.streetDetail = '';
                    this.toggleClearBtn();
                    this.updateFullAddress();
                    this.streetInput.focus();
                });
            }

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

        toggleClearBtn() {
            if (this.clearStreetBtn) {
                this.clearStreetBtn.style.display = (this.streetInput && this.streetInput.value.length > 0) ? 'flex' : 'none';
            }
        }

        async initData() {
            // Tải danh sách tỉnh thành
            this.provSelect.innerHTML = '<option value="">Đang tải Tỉnh/Thành...</option>';
            const provinces = await fetchProvinces();
            this.populateSelect(this.provSelect, provinces, '-- Chọn Tỉnh / Thành --');

            // Phân tích địa chỉ ban đầu nếu có sẵn trong tài khoản
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

        /**
         * Phân tích thông minh địa chỉ có sẵn từ cơ sở dữ liệu
         * Tự động nhận diện Tỉnh -> Huyện -> Xã, tách riêng số nhà/đường và ngăn chặn lặp từ triệt để.
         */
        async tryParseInitialAddress(rawAddr, provinces) {
            if (!rawAddr || typeof rawAddr !== 'string') return;
            const original = rawAddr.trim();

            let parts = [];
            if (original.includes(',')) {
                parts = original.split(',').map(s => s.trim()).filter(Boolean);
            } else {
                // Tách theo ranh giới từ khóa hành chính nếu không có dấu phẩy
                const kwRegex = /(?:,\s*|\s+(?=(?:phường|xã|thị trấn|p\.\s*|quận|huyện|thị xã|q\.\s*|thành phố|tỉnh|tp\.\s*)))/i;
                parts = original.split(kwRegex).map(s => s.trim()).filter(Boolean);
            }

            if (parts.length === 0) return;

            // Bỏ "Việt Nam" nếu xuất hiện ở cuối
            const lastSeg = parts[parts.length - 1].toLowerCase();
            if (lastSeg === 'việt nam' || lastSeg === 'viet nam' || lastSeg === 'vietnam') {
                parts.pop();
            }

            let matchedProv = null;
            let provIdx = -1;

            // 1. Quét tìm Tỉnh/Thành phố từ các phân đoạn phía sau
            for (let i = parts.length - 1; i >= 0; i--) {
                const found = matchProvince(parts[i], provinces);
                if (found) {
                    matchedProv = found;
                    provIdx = i;
                    break;
                }
            }

            if (matchedProv) {
                this.provSelect.value = matchedProv.code;
                this.selectedProvince = { code: matchedProv.code, name: matchedProv.name };

                const districts = await fetchDistricts(matchedProv.code);
                this.populateSelect(this.distSelect, districts, '-- Chọn Quận / Huyện --');

                let matchedDist = null;
                let distIdx = -1;

                // 2. Quét tìm Quận/Huyện ở bên trái của Tỉnh/Thành
                for (let i = provIdx - 1; i >= 0; i--) {
                    const found = matchDistrict(parts[i], districts);
                    if (found) {
                        matchedDist = found;
                        distIdx = i;
                        break;
                    }
                }

                if (matchedDist) {
                    this.distSelect.value = matchedDist.code;
                    this.selectedDistrict = { code: matchedDist.code, name: matchedDist.name };

                    const wards = await fetchWards(matchedDist.code);
                    this.populateSelect(this.wardSelect, wards, '-- Chọn Phường / Xã --');

                    let matchedWard = null;
                    let wardIdx = -1;

                    // 3. Quét tìm Phường/Xã ở bên trái của Quận/Huyện
                    for (let i = distIdx - 1; i >= 0; i--) {
                        const found = matchWard(parts[i], wards);
                        if (found) {
                            matchedWard = found;
                            wardIdx = i;
                            break;
                        }
                    }

                    if (matchedWard) {
                        this.wardSelect.value = matchedWard.code;
                        this.selectedWard = { code: matchedWard.code, name: matchedWard.name };
                    }

                    // 4. Các phân đoạn còn lại phía trước là Số nhà, tên đường
                    let streetParts = [];
                    if (wardIdx >= 0) {
                        streetParts = parts.slice(0, wardIdx);
                    } else if (distIdx >= 0) {
                        streetParts = parts.slice(0, distIdx);
                    } else {
                        streetParts = parts.slice(0, provIdx);
                    }

                    let cleanStreet = streetParts.join(', ').trim();
                    cleanStreet = cleanStreetAddress(cleanStreet, this.selectedWard, this.selectedDistrict, this.selectedProvince);

                    this.streetInput.value = cleanStreet;
                    this.streetDetail = cleanStreet;
                    this.toggleClearBtn();

                    if (this.syncBadge) {
                        this.syncBadge.style.display = 'inline-flex';
                    }

                    this.updateFullAddress();
                    return;
                }
            }

            // Nếu không thể phân tích theo cấp hành chính chuẩn (địa chỉ tự do hoặc đặc biệt),
            // đưa vào ô nhập tự do hoặc giữ nguyên để không làm hỏng dữ liệu người dùng
            this.streetInput.value = original;
            this.streetDetail = original;
            this.toggleClearBtn();
            this.setFinalAddress(original);
        }

        sanitizeAndUpdate() {
            if (this.isManualMode) return;
            // Tự động làm sạch số nhà/đường nếu bị dính tên phường, quận, tỉnh
            const cleaned = cleanStreetAddress(
                this.streetInput ? this.streetInput.value : this.streetDetail,
                this.selectedWard,
                this.selectedDistrict,
                this.selectedProvince
            );

            if (this.streetInput && this.streetInput.value !== cleaned) {
                this.streetInput.value = cleaned;
            }
            this.streetDetail = cleaned;
            this.toggleClearBtn();
            this.updateFullAddress();
        }

        updateFullAddress() {
            if (this.isManualMode) return;

            const segments = [];
            if (this.streetDetail && this.streetDetail.trim().length > 0) {
                segments.push(this.streetDetail.trim());
            }
            if (this.selectedWard && this.selectedWard.name) {
                segments.push(this.selectedWard.name.trim());
            }
            if (this.selectedDistrict && this.selectedDistrict.name) {
                segments.push(this.selectedDistrict.name.trim());
            }
            if (this.selectedProvince && this.selectedProvince.name) {
                segments.push(this.selectedProvince.name.trim());
            }

            const fullText = segments.join(', ');
            this.setFinalAddress(fullText);
        }

        setFinalAddress(text) {
            if (this.targetInput) {
                this.targetInput.value = text;
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
        fetchWards,
        cleanStreetAddress
    };
}));
