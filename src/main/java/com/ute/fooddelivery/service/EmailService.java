package com.ute.fooddelivery.service;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.Properties;

public class EmailService {

    private static final Properties mailProps = new Properties();
    private static boolean configLoaded = false;
    private static final SecureRandom secureRandom = new SecureRandom();

    static {
        loadConfig();
    }

    private static synchronized void loadConfig() {
        if (configLoaded) return;
        // 1. Nạp từ classpath
        try (InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream("mail.properties")) {
            if (in != null) {
                mailProps.load(in);
            }
        } catch (Exception e) {
            System.err.println("[EmailService] Lỗi khi nạp mail.properties từ classpath: " + e.getMessage());
        }

        // 2. Nạp trực tiếp từ file vật lý trên đĩa (nếu có) để nhận ngay thay đổi khi người dùng lưu file mail.properties
        String[] possiblePaths = new String[] {
            "d:/WEBPROGRAMMING/food-delivery-website/src/main/resources/mail.properties",
            "src/main/resources/mail.properties"
        };
        for (String p : possiblePaths) {
            try {
                java.io.File f = new java.io.File(p);
                if (f.exists() && f.canRead()) {
                    try (java.io.FileInputStream fis = new java.io.FileInputStream(f)) {
                        Properties fileProps = new Properties();
                        fileProps.load(fis);
                        for (String key : fileProps.stringPropertyNames()) {
                            String val = fileProps.getProperty(key);
                            if (val != null && !val.trim().isEmpty()) {
                                mailProps.setProperty(key, val.trim());
                            }
                        }
                    }
                    break;
                }
            } catch (Exception ignored) {
            }
        }

        // Giá trị mặc định nếu file thiếu
        mailProps.putIfAbsent("mail.smtp.host", "smtp.gmail.com");
        mailProps.putIfAbsent("mail.smtp.port", "587");
        mailProps.putIfAbsent("mail.smtp.auth", "true");
        mailProps.putIfAbsent("mail.smtp.starttls.enable", "true");
        mailProps.putIfAbsent("mail.smtp.starttls.required", "true");
        mailProps.putIfAbsent("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        mailProps.putIfAbsent("mail.smtp.connectiontimeout", "8000");
        mailProps.putIfAbsent("mail.smtp.timeout", "8000");
        mailProps.putIfAbsent("mail.from.email", "uteefooddelivery@gmail.com");
        mailProps.putIfAbsent("mail.from.name", "Utee Food Delivery");

        // Ghi đè bằng biến môi trường nếu có
        // Ghi đè bằng biến môi trường nếu có
        String envResend = System.getenv("RESEND_API_KEY");
        if (envResend != null && !envResend.trim().isEmpty()) {
            mailProps.setProperty("resend.api.key", envResend.trim());
        }

        String envSmtpUser = System.getenv("MAIL_SMTP_USERNAME");
        if (envSmtpUser != null && !envSmtpUser.trim().isEmpty()) {
            mailProps.setProperty("mail.smtp.username", envSmtpUser.trim());
        }

        String envSmtpPass = System.getenv("MAIL_SMTP_PASSWORD");
        if (envSmtpPass != null && !envSmtpPass.trim().isEmpty()) {
            mailProps.setProperty("mail.smtp.password", envSmtpPass.trim());
        }

        configLoaded = true;
    }

    /**
     * Nạp lại cấu hình từ file mail.properties (giúp người dùng không cần restart server sau khi sửa file).
     */
    public static synchronized void reloadConfig() {
        configLoaded = false;
        loadConfig();
    }

    public static boolean isSmtpConfigured() {
        reloadConfig();
        String username = mailProps.getProperty("mail.smtp.username", "").trim();
        String password = mailProps.getProperty("mail.smtp.password", "").trim();
        return !username.isEmpty() && !username.toUpperCase().contains("YOUR_")
                && !password.isEmpty() && !password.toUpperCase().contains("YOUR_");
    }

    public static boolean isResendConfigured() {
        reloadConfig();
        String resendKey = mailProps.getProperty("resend.api.key", "").trim();
        return !resendKey.isEmpty() && !resendKey.toUpperCase().contains("YOUR_");
    }

    public static String getSenderEmail() {
        reloadConfig();
        if (isSmtpConfigured()) {
            return mailProps.getProperty("mail.from.email", mailProps.getProperty("mail.smtp.username")).trim();
        }
        return mailProps.getProperty("mail.from.email", "onboarding@resend.dev").trim();
    }

    /**
     * Sinh mã OTP 6 chữ số ngẫu nhiên bảo mật cao.
     */
    public static String generateOtp() {
        int code = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(code);
    }

    public static class SendEmailResult {
        private final boolean success;
        private final String message;
        private final boolean isRealSmtp;

        public SendEmailResult(boolean success, String message, boolean isRealSmtp) {
            this.success = success;
            this.message = message;
            this.isRealSmtp = isRealSmtp;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public boolean isRealSmtp() { return isRealSmtp; }
    }

    /**
     * Gửi email mã OTP xác thực tới địa chỉ Gmail của khách hàng.
     * Thứ tự ưu tiên:
     * 1. Gmail SMTP (nếu cấu hình mail.smtp.username & mail.smtp.password) -> gửi được tới mọi email bất kỳ.
     * 2. Resend REST API (nếu có resend.api.key).
     * 3. Dev Sandbox (mô phỏng, in ra console).
     *
     * @param toEmail Địa chỉ email người nhận (Gmail)
     * @param otpCode Mã OTP 6 số
     * @return SendEmailResult chứa trạng thái và thông báo
     */
    public SendEmailResult sendOtpEmail(String toEmail, String otpCode) {
        if (toEmail == null || toEmail.trim().isEmpty() || otpCode == null) {
            return new SendEmailResult(false, "Địa chỉ email hoặc mã OTP không hợp lệ!", false);
        }

        reloadConfig();
        final String cleanToEmail = toEmail.trim();
        final String fromName = mailProps.getProperty("mail.from.name", "Utee Food Delivery").trim();

        // Luôn in mã OTP ra console để quản trị viên / dev theo dõi
        printConsoleOtpBox(cleanToEmail, otpCode);

        final String htmlBody = buildOtpEmailHtml(cleanToEmail, otpCode);

        // 1. ƯU TIÊN GỬI QUA GMAIL SMTP (Gửi được đến mọi email bất kỳ)
        if (isSmtpConfigured()) {
            String smtpUser = mailProps.getProperty("mail.smtp.username", "").trim();
            String smtpPass = mailProps.getProperty("mail.smtp.password", "").trim();
            System.out.println(">> [EmailService] Đang gửi OTP qua Gmail SMTP (" + smtpUser + ") tới: " + cleanToEmail);
            return sendViaSmtp(smtpUser, smtpPass, fromName, cleanToEmail, otpCode, htmlBody);
        }

        // 2. GỬI QUA RESEND GLOBAL REST API
        String resendKey = mailProps.getProperty("resend.api.key", "").trim();
        if (!resendKey.isEmpty() && !resendKey.toUpperCase().contains("YOUR_")) {
            System.out.println(">> [EmailService] Đang gửi OTP qua Resend REST API tới: " + cleanToEmail);
            return sendViaResendApi(resendKey, fromName, cleanToEmail, otpCode, htmlBody);
        }

        // 3. CHẾ ĐỘ DEV SANDBOX DÀNH CHO CỘNG SỰ / LÀM NHÓM:
        // Khi cộng sự clone code về chưa cấu hình Resend API key hay SMTP, hệ thống tự động chạy chế độ Dev Sandbox
        // Vừa in mã OTP ra Console, vừa hiển thị nút điền nhanh trên web để cộng sự test đăng ký từ A-Z trơn tru.
        String msg = "[Dev Sandbox] Chưa cấu hình Gmail SMTP hoặc Resend API Key. Đang bật chế độ mô phỏng để cộng sự kiểm thử.";
        System.out.println(">> [EmailService] " + msg);
        return new SendEmailResult(true, msg, false);
    }

    /**
     * Gửi email thật qua Gmail SMTP Server.
     */
    private SendEmailResult sendViaSmtp(String username, String password, String fromName, String toEmail, String otpCode, String htmlBody) {
        try {
            Properties props = new Properties();
            props.putAll(mailProps);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            props.put("mail.smtp.host", mailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
            props.put("mail.smtp.port", mailProps.getProperty("mail.smtp.port", "587"));

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

            MimeMessage message = new MimeMessage(session);
            String fromEmail = mailProps.getProperty("mail.from.email", username).trim();
            message.setFrom(new InternetAddress(fromEmail, fromName, "UTF-8"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            message.setSubject("[UTEE FOOD] Mã OTP xác thực đăng ký: " + otpCode, "UTF-8");
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println(">> [Gmail SMTP] ✅ ĐÃ GỬI EMAIL THẬT THÀNH CÔNG TỚI: " + toEmail);
            return new SendEmailResult(true, "Mã xác thực OTP đã được gửi thật đến hộp thư Gmail (" + toEmail + ") qua Gmail SMTP. Vui lòng kiểm tra Hộp thư đến (hoặc Spam)!", true);
        } catch (Exception e) {
            System.err.println(">> [Gmail SMTP] ❌ Lỗi gửi email: " + e.getMessage());
            return new SendEmailResult(false, "Không thể gửi email qua Gmail SMTP: " + e.getMessage(), true);
        }
    }

    /**
     * Gửi email thật qua Resend Global REST API.
     */
    private SendEmailResult sendViaResendApi(String apiKey, String fromName, String toEmail, String otpCode, String htmlBody) {
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();

            // Resend yêu cầu sender dạng: "Utee Food Delivery <onboarding@resend.dev>"
            String sender = (fromName != null && !fromName.trim().isEmpty() ? fromName.trim() : "Utee Food Delivery")
                    + " <onboarding@resend.dev>";
            String jsonPayload = buildResendJson(sender, toEmail, otpCode, htmlBody);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.resend.com/emails"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Bearer " + apiKey.trim())
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            int status = response.statusCode();
            String resBody = response.body();

            if (status >= 200 && status < 300) {
                System.out.println(">> [Resend API] ✅ ĐÃ GỬI EMAIL THẬT THÀNH CÔNG TỚI: " + toEmail + " (HTTP " + status + ", Response: " + resBody + ")");
                return new SendEmailResult(true, "Mã xác thực OTP đã được gửi thật đến hộp thư Gmail (" + toEmail + ") qua Resend Global API. Vui lòng kiểm tra Hộp thư đến (hoặc Spam)!", true);
            } else {
                System.err.println(">> [Resend API] ❌ Lỗi từ Resend (HTTP " + status + "): " + resBody);
                String userMsg = "Resend API báo lỗi (" + status + "): ";
                if (resBody != null && resBody.contains("validation_error") && resBody.contains("onboarding@resend.dev")) {
                    userMsg += "Tài khoản Resend miễn phí chỉ cho phép gửi đến chính email bạn đã đăng ký Resend. Vui lòng đảm bảo email nhận là email bạn đăng ký Resend (" + toEmail + ")!";
                } else if (resBody != null && resBody.contains("api_key_invalid")) {
                    userMsg += "API Key Resend không hợp lệ. Vui lòng kiểm tra lại resend.api.key!";
                } else {
                    userMsg += (resBody != null ? resBody : "Lỗi gửi email");
                }
                return new SendEmailResult(false, userMsg, true);
            }
        } catch (Exception e) {
            System.err.println(">> [Resend API] ❌ Lỗi kết nối HTTP: " + e.getMessage());
            return new SendEmailResult(false, "Không thể kết nối tới Resend API: " + e.getMessage(), true);
        }
    }

    private String buildResendJson(String from, String toEmail, String otpCode, String htmlBody) {
        return "{"
                + "\"from\":\"" + escapeJson(from) + "\","
                + "\"to\":[\"" + escapeJson(toEmail) + "\"],"
                + "\"subject\":\"" + escapeJson("[UTEE FOOD] Mã OTP xác thực đăng ký: " + otpCode) + "\","
                + "\"html\":\"" + escapeJson(htmlBody) + "\""
                + "}";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    private void printConsoleOtpBox(String email, String otp) {
        System.out.println("\n==================================================================");
        System.out.println("🔥 [UTEE GMAIL OTP SERVICE] - YÊU CẦU MÃ XÁC THỰC ĐĂNG KÝ");
        System.out.println("📧 GỬI ĐẾN GMAIL : " + email);
        System.out.println("🔑 MÃ OTP 6 SỐ   : [ " + otp + " ] (Hiệu lực trong 5 phút)");
        System.out.println("==================================================================\n");
    }

    /**
     * Xây dựng giao diện email HTML hiện đại, chuẩn Responsive, màu cam đỏ thương hiệu Utee.
     */
    private String buildOtpEmailHtml(String recipientEmail, String otpCode) {
        return "<!DOCTYPE html>"
                + "<html lang='vi'>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
                + "<title>Mã xác thực OTP Utee Food</title>"
                + "</head>"
                + "<body style='margin: 0; padding: 0; background-color: #f1f5f9; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; color: #1e293b;'>"
                + "  <table width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color: #f1f5f9; padding: 40px 15px;'>"
                + "    <tr>"
                + "      <td align='center'>"
                + "        <table width='100%' border='0' cellspacing='0' cellpadding='0' style='max-width: 580px; background-color: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);'>"
                + "          <!-- Header Banner -->"
                + "          <tr>"
                + "            <td style='background: linear-gradient(135deg, #ea580c 0%, #f97316 50%, #fb923c 100%); padding: 36px 30px; text-align: center;'>"
                + "              <div style='font-size: 28px; font-weight: 900; letter-spacing: -0.5px; color: #ffffff; text-shadow: 0 2px 4px rgba(0,0,0,0.15);'>"
                + "                🍔 UTEE FOOD DELIVERY"
                + "              </div>"
                + "              <div style='font-size: 14px; font-weight: 500; color: #ffedd5; margin-top: 6px; letter-spacing: 0.5px;'>"
                + "                Món ngon tận nơi • Trọn vị từng bữa"
                + "              </div>"
                + "            </td>"
                + "          </tr>"
                + "          <!-- Body Content -->"
                + "          <tr>"
                + "            <td style='padding: 36px 32px; background-color: #ffffff;'>"
                + "              <h2 style='margin: 0 0 14px 0; font-size: 20px; font-weight: 700; color: #0f172a; text-align: center;'>"
                + "                Xác thực địa chỉ Email đăng ký"
                + "              </h2>"
                + "              <p style='margin: 0 0 20px 0; font-size: 15px; line-height: 1.6; color: #475569; text-align: center;'>"
                + "                Xin chào bạn! Chúng tôi đã nhận được yêu cầu đăng ký tài khoản tại <strong>Utee Food Delivery</strong> qua địa chỉ email: <span style='color: #ea580c; font-weight: 600;'>" + recipientEmail + "</span>."
                + "              </p>"
                + "              <p style='margin: 0 0 24px 0; font-size: 14px; line-height: 1.6; color: #64748b; text-align: center;'>"
                + "                Vui lòng sử dụng mã xác thực OTP 6 chữ số dưới đây để hoàn tất quá trình kích hoạt tài khoản của bạn:"
                + "              </p>"
                + "              <!-- OTP Box -->"
                + "              <div style='text-align: center; margin: 28px 0;'>"
                + "                <div style='display: inline-block; background: #fff7ed; border: 2px dashed #f97316; border-radius: 14px; padding: 18px 36px; box-shadow: 0 4px 12px rgba(249, 115, 22, 0.12);'>"
                + "                  <span style='font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #ea580c; font-family: monospace; line-height: 1;'>"
                +                      otpCode
                + "                  </span>"
                + "                </div>"
                + "              </div>"
                + "              <!-- Note / Warning -->"
                + "              <div style='background-color: #f8fafc; border-left: 4px solid #f97316; padding: 14px 18px; border-radius: 8px; margin: 24px 0;'>"
                + "                <p style='margin: 0; font-size: 13px; line-height: 1.5; color: #475569;'>"
                + "                  ⏱ <strong>Thời hạn hiệu lực:</strong> Mã OTP có giá trị trong vòng <strong>5 phút</strong>.<br>"
                + "                  🔒 <strong>Lưu ý bảo mật:</strong> Tuyệt đối không chia sẻ mã này với bất kỳ ai để đảm bảo an toàn tài khoản."
                + "                </p>"
                + "              </div>"
                + "              <p style='margin: 24px 0 0 0; font-size: 13px; color: #94a3b8; text-align: center; line-height: 1.5;'>"
                + "                Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này hoặc liên hệ hotline <strong style='color: #ea580c;'>1900 6868</strong> để được hỗ trợ kịp thời."
                + "              </p>"
                + "            </td>"
                + "          </tr>"
                + "          <!-- Footer -->"
                + "          <tr>"
                + "            <td style='background-color: #f8fafc; padding: 24px 30px; text-align: center; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8;'>"
                + "              <p style='margin: 0 0 6px 0; font-weight: 600; color: #64748b;'>© 2026 Utee Food Delivery Platform. All rights reserved.</p>"
                + "              <p style='margin: 0;'>Trường Đại học Sư phạm Kỹ thuật TP.HCM (HCMUTE) • Hotline: 1900 6868</p>"
                + "            </td>"
                + "          </tr>"
                + "        </table>"
                + "      </td>"
                + "    </tr>"
                + "  </table>"
                + "</body>"
                + "</html>";
    }
}
