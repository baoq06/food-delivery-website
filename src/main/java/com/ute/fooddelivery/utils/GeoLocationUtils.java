package com.ute.fooddelivery.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Tiện ích tính toán tọa độ địa lý, khoảng cách di chuyển, thời gian dự kiến và phí ship
 * Hỗ trợ công thức Haversine mặt cầu kết hợp OSRM Routing API với cơ chế dự phòng an toàn.
 */
public class GeoLocationUtils {

    // Bán kính Trái Đất trung bình (km)
    private static final double EARTH_RADIUS_KM = 6371.0;

    // Tọa độ mặc định: Trường ĐH Sư Phạm Kỹ Thuật TP.HCM (HCMUTE), 1 Võ Văn Ngân, TP. Thủ Đức
    public static final double DEFAULT_LAT = 10.8505;
    public static final double DEFAULT_LNG = 106.7719;

    // Danh bạ điểm mốc quen thuộc tại TP. Thủ Đức & TP.HCM phục vụ Geocoding offline nhanh
    private static final Map<String, double[]> KNOWN_LOCATIONS = new LinkedHashMap<>();

    static {
        KNOWN_LOCATIONS.put("hcmute", new double[]{10.8505, 106.7719});
        KNOWN_LOCATIONS.put("sư phạm kỹ thuật", new double[]{10.8505, 106.7719});
        KNOWN_LOCATIONS.put("võ văn ngân", new double[]{10.8505, 106.7719});
        KNOWN_LOCATIONS.put("ngã tư thủ đức", new double[]{10.8532, 106.7797});
        KNOWN_LOCATIONS.put("chợ thủ đức", new double[]{10.8546, 106.7583});
        KNOWN_LOCATIONS.put("kha vạn cân", new double[]{10.8530, 106.7550});
        KNOWN_LOCATIONS.put("vincom thủ đức", new double[]{10.8508, 106.7714});
        KNOWN_LOCATIONS.put("gigamall", new double[]{10.8286, 106.7231});
        KNOWN_LOCATIONS.put("phạm văn đồng", new double[]{10.8350, 106.7350});
        KNOWN_LOCATIONS.put("linh chiểu", new double[]{10.8540, 106.7650});
        KNOWN_LOCATIONS.put("linh trung", new double[]{10.8655, 106.7820});
        KNOWN_LOCATIONS.put("linh tây", new double[]{10.8600, 106.7570});
        KNOWN_LOCATIONS.put("tam phú", new double[]{10.8680, 106.7450});
        KNOWN_LOCATIONS.put("hiệp phú", new double[]{10.8450, 106.7810});
        KNOWN_LOCATIONS.put("tăng nhơn phú", new double[]{10.8350, 106.7880});
        KNOWN_LOCATIONS.put("quận 9", new double[]{10.8380, 106.7850});
        KNOWN_LOCATIONS.put("bình thạnh", new double[]{10.8012, 106.7118});
        KNOWN_LOCATIONS.put("hàng xanh", new double[]{10.8015, 106.7115});
        KNOWN_LOCATIONS.put("quận 1", new double[]{10.7721, 106.6983});
        KNOWN_LOCATIONS.put("quận 3", new double[]{10.7844, 106.6844});
        KNOWN_LOCATIONS.put("thảo điền", new double[]{10.8050, 106.7350});
        KNOWN_LOCATIONS.put("an phú", new double[]{10.7980, 106.7450});
        KNOWN_LOCATIONS.put("khu công nghệ cao", new double[]{10.8550, 106.7950});
        KNOWN_LOCATIONS.put("đại học quốc gia", new double[]{10.8750, 106.8010});
        KNOWN_LOCATIONS.put("làng đại học", new double[]{10.8750, 106.8010});
    }

    /**
     * Tính khoảng cách Haversine mặt cầu giữa 2 điểm tọa độ (km)
     */
    public static double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        if (lat1 == 0 && lon1 == 0) return 2.0;
        if (lat2 == 0 && lon2 == 0) return 2.0;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = EARTH_RADIUS_KM * c;

        // Làm tròn 1 chữ số thập phân
        return Math.round(distance * 10.0) / 10.0;
    }

    /**
     * Tính khoảng cách đường đi thực tế qua OSRM Routing API (có fallback sang Haversine)
     * @return khoảng cách tính theo km
     */
    public static double calculateRouteDistance(double lat1, double lon1, double lat2, double lon2) {
        double straightDistance = calculateHaversineDistance(lat1, lon1, lat2, lon2);
        
        // Thử gọi OSRM public API với timeout ngắn (1.2s)
        try {
            String urlStr = String.format(java.util.Locale.US,
                "http://router.project-osrm.org/route/v1/driving/%.6f,%.6f;%.6f,%.6f?overview=false",
                lon1, lat1, lon2, lat2);

            URL url = URI.create(urlStr).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(1200);
            conn.setReadTimeout(1200);
            conn.setRequestProperty("User-Agent", "UteeFoodDeliveryApp/1.0");

            if (conn.getResponseCode() == 200) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                    String json = sb.toString();
                    int distanceIdx = json.indexOf("\"distance\":");
                    if (distanceIdx != -1) {
                        int start = distanceIdx + 11;
                        int end = json.indexOf(",", start);
                        if (end == -1) end = json.indexOf("}", start);
                        if (end != -1) {
                            double distanceMeters = Double.parseDouble(json.substring(start, end).trim());
                            double distanceKm = Math.round((distanceMeters / 1000.0) * 10.0) / 10.0;
                            if (distanceKm > 0.1) {
                                return distanceKm;
                            }
                        }
                    }
                }
            }
        } catch (Exception ignored) {
            // Khi không có mạng ngoài hoặc OSRM timeout -> Dùng hệ số điều chỉnh đường cong đô thị (1.25x Haversine)
        }

        // Ước lượng khoảng cách đường xe máy thực tế = 1.25 * khoảng cách đường chim bay
        double urbanDistance = straightDistance * 1.25;
        return Math.max(0.5, Math.round(urbanDistance * 10.0) / 10.0);
    }

    /**
     * Tính tiền ship dựa trên khoảng cách (km)
     * - Dưới hoặc bằng 2.0 km: 15,000 đ
     * - Mỗi km tiếp theo: +5,000 đ / km
     */
    public static double calculateShippingFee(double distanceKm) {
        if (distanceKm <= 2.0) {
            return 15000.0;
        }
        double extraKm = Math.ceil(distanceKm - 2.0);
        return 15000.0 + (extraKm * 5000.0);
    }

    /**
     * Ước tính thời gian giao hàng (phút) = 15 phút chuẩn bị món + 3.5 phút/km di chuyển
     */
    public static int estimateDeliveryMinutes(double distanceKm) {
        int basePrepMinutes = 15;
        int travelMinutes = (int) Math.round(distanceKm * 3.5);
        return Math.max(15, basePrepMinutes + travelMinutes);
    }

    /**
     * Trích xuất tọa độ từ chuỗi địa chỉ (Geocoding hỗ trợ tiếng Việt)
     */
    public static double[] getCoordinatesForAddress(String address) {
        if (address == null || address.trim().isEmpty()) {
            return new double[]{DEFAULT_LAT, DEFAULT_LNG};
        }

        String lower = address.toLowerCase();

        for (Map.Entry<String, double[]> entry : KNOWN_LOCATIONS.entrySet()) {
            if (lower.contains(entry.getKey())) {
                return entry.getValue();
            }
        }

        // Tạo độ lệch ngẫu nhiên nhỏ trong bán kính 1.5km để các địa chỉ khác nhau có cự ly sinh động
        int hash = Math.abs(address.hashCode());
        double latOffset = ((hash % 100) - 50) * 0.0002;
        double lngOffset = (((hash / 100) % 100) - 50) * 0.0002;

        return new double[]{DEFAULT_LAT + latOffset, DEFAULT_LNG + lngOffset};
    }
}
