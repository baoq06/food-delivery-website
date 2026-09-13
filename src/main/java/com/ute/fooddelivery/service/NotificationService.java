package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.NotificationDAO;
import com.ute.fooddelivery.model.Notification;

import java.text.NumberFormat;
import java.util.Locale;

public class NotificationService {
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final Locale vnLocale = new Locale("vi", "VN");

    private String formatMoney(double amount) {
        return NumberFormat.getInstance(vnLocale).format(amount) + "đ";
    }

    public void notifyNewOrderToMerchant(int merchantUserId, int orderId, String customerName, double amount) {
        if (merchantUserId <= 0) return;
        Notification notif = new Notification(
            merchantUserId,
            orderId,
            "🛎️ Có đơn hàng mới #DH-" + orderId,
            "Khách hàng " + customerName + " vừa đặt đơn trị giá " + formatMoney(amount) + ". Vui lòng chọn tài xế shipper khả dụng để giao đơn!",
            "ORDER_NEW",
            "/merchant/orders?status=PENDING"
        );
        notificationDAO.createNotification(notif);
    }

    public void notifyOrderAssignedToShipper(int shipperUserId, int orderId, double amount, String address) {
        if (shipperUserId <= 0) return;
        Notification notif = new Notification(
            shipperUserId,
            orderId,
            "🏍️ Bạn có cuốc xe mới #DH-" + orderId + "!",
            "Quán ăn vừa gán đơn hàng trị giá " + formatMoney(amount) + " đến '" + address + "' cho bạn. Hãy bấm nhận cuốc xe ngay!",
            "ORDER_ASSIGNED",
            "/shipper/dashboard"
        );
        notificationDAO.createNotification(notif);
    }

    public void notifyShipperAccepted(Integer merchantUserId, Integer customerUserId, int orderId, String driverName, String driverPhone) {
        if (merchantUserId != null && merchantUserId > 0) {
            Notification notifMerchant = new Notification(
                merchantUserId,
                orderId,
                "✅ Tài xế đã nhận đơn #DH-" + orderId,
                "Tài xế " + driverName + " (" + driverPhone + ") đã đồng ý giao đơn này. Bạn có thể bắt đầu chế biến món ăn!",
                "SHIPPER_ACCEPTED",
                "/merchant/orders"
            );
            notificationDAO.createNotification(notifMerchant);
        }

        if (customerUserId != null && customerUserId > 0) {
            Notification notifCustomer = new Notification(
                customerUserId,
                orderId,
                "🏍️ Tài xế đã nhận đơn #DH-" + orderId,
                "Tài xế " + driverName + " (" + driverPhone + ") sẽ giao đơn hàng của bạn. Quán đang chuẩn bị món ăn!",
                "SHIPPER_ACCEPTED",
                "/profile?tab=orders"
            );
            notificationDAO.createNotification(notifCustomer);
        }
    }

    public void notifyShipperDeclinedToMerchant(Integer merchantUserId, int orderId, String driverName) {
        if (merchantUserId != null && merchantUserId > 0) {
            Notification notif = new Notification(
                merchantUserId,
                orderId,
                "⚠️ Tài xế đã từ chối nhận đơn #DH-" + orderId,
                "Tài xế " + driverName + " đã từ chối nhận cuốc xe này. Vui lòng gán tài xế khác cho đơn hàng!",
                "ORDER_CANCELLED",
                "/merchant/orders?status=PENDING"
            );
            notificationDAO.createNotification(notif);
        }
    }

    public void notifyOrderShipping(Integer customerUserId, Integer shipperUserId, int orderId) {
        if (customerUserId != null && customerUserId > 0) {
            Notification notif = new Notification(
                customerUserId,
                orderId,
                "🍳 Quán đang chế biến & giao đơn #DH-" + orderId,
                "Món ăn của bạn đang được quán chuẩn bị và giao cho tài xế vận chuyển đến bạn!",
                "ORDER_SHIPPING",
                "/profile?tab=orders"
            );
            notificationDAO.createNotification(notif);
        }

        if (shipperUserId != null && shipperUserId > 0) {
            Notification notif = new Notification(
                shipperUserId,
                orderId,
                "📦 Đơn #DH-" + orderId + " đang được quán chế biến",
                "Quán ăn đã bắt đầu nấu và bàn giao món ăn. Bạn hãy sẵn sàng di chuyển giao hàng nhé!",
                "ORDER_SHIPPING",
                "/shipper/dashboard"
            );
            notificationDAO.createNotification(notif);
        }
    }

    public void notifyShipperDelivered(Integer customerUserId, Integer merchantUserId, int orderId, String driverName) {
        if (customerUserId != null && customerUserId > 0) {
            Notification notif = new Notification(
                customerUserId,
                orderId,
                "📦 Tài xế báo đã giao đơn #DH-" + orderId,
                "Tài xế " + driverName + " báo đã giao hàng đến bạn. Vui lòng kiểm tra và bấm 'Đã nhận được hàng'!",
                "SHIPPER_DELIVERED",
                "/profile?tab=orders"
            );
            notificationDAO.createNotification(notif);
        }

        if (merchantUserId != null && merchantUserId > 0) {
            Notification notif = new Notification(
                merchantUserId,
                orderId,
                "📍 Tài xế đã giao xong đơn #DH-" + orderId,
                "Tài xế " + driverName + " đã hoàn tất chặng giao hàng đến khách.",
                "SHIPPER_DELIVERED",
                "/merchant/orders"
            );
            notificationDAO.createNotification(notif);
        }
    }

    public void notifyCustomerConfirmed(Integer shipperUserId, Integer merchantUserId, int orderId, String customerName) {
        if (shipperUserId != null && shipperUserId > 0) {
            Notification notif = new Notification(
                shipperUserId,
                orderId,
                "🌟 Khách hàng đã nhận đơn #DH-" + orderId,
                "Khách hàng " + customerName + " đã bấm xác nhận đã nhận được món ăn an toàn!",
                "CUSTOMER_CONFIRMED",
                "/shipper/dashboard"
            );
            notificationDAO.createNotification(notif);
        }

        if (merchantUserId != null && merchantUserId > 0) {
            Notification notif = new Notification(
                merchantUserId,
                orderId,
                "🌟 Khách hàng đã nhận đơn #DH-" + orderId,
                "Khách hàng " + customerName + " đã xác nhận đã nhận được món ăn.",
                "CUSTOMER_CONFIRMED",
                "/merchant/orders"
            );
            notificationDAO.createNotification(notif);
        }
    }

    public void notifyMerchantCompleted(Integer customerUserId, Integer shipperUserId, int orderId) {
        if (customerUserId != null && customerUserId > 0) {
            Notification notif = new Notification(
                customerUserId,
                orderId,
                "🎉 Đơn hàng #DH-" + orderId + " hoàn tất!",
                "Cảm ơn bạn đã thưởng thức ẩm thực tại Utee Delivery! Hãy để lại đánh giá để quán phục vụ tốt hơn nhé.",
                "ORDER_COMPLETED",
                "/profile?tab=orders"
            );
            notificationDAO.createNotification(notif);
        }

        if (shipperUserId != null && shipperUserId > 0) {
            Notification notif = new Notification(
                shipperUserId,
                orderId,
                "💰 Chuyến xe #DH-" + orderId + " đã hoàn tất thành công!",
                "Chủ cửa hàng đã duyệt hoàn tất đơn hàng. Thù lao giao hàng đã được cập nhật vào ví của bạn!",
                "ORDER_COMPLETED",
                "/shipper/dashboard?tab=history"
            );
            notificationDAO.createNotification(notif);
        }
    }

    public void notifyOrderCancelled(Integer customerUserId, Integer shipperUserId, Integer merchantUserId, int orderId, String reason) {
        String msg = "Đơn hàng #DH-" + orderId + " đã bị hủy. Lý do: " + (reason != null ? reason : "Không xác định");
        if (customerUserId != null && customerUserId > 0) {
            notificationDAO.createNotification(new Notification(customerUserId, orderId, "❌ Đơn hàng #DH-" + orderId + " đã bị hủy", msg, "ORDER_CANCELLED", "/profile?tab=orders"));
        }
        if (shipperUserId != null && shipperUserId > 0) {
            notificationDAO.createNotification(new Notification(shipperUserId, orderId, "❌ Đơn hàng #DH-" + orderId + " đã bị hủy", msg, "ORDER_CANCELLED", "/shipper/dashboard"));
        }
        if (merchantUserId != null && merchantUserId > 0) {
            notificationDAO.createNotification(new Notification(merchantUserId, orderId, "❌ Đơn hàng #DH-" + orderId + " đã bị hủy", msg, "ORDER_CANCELLED", "/merchant/orders"));
        }
    }
}
