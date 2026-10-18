package com.ute.fooddelivery;

import com.ute.fooddelivery.service.EmailService;
import com.ute.fooddelivery.service.UserService;
import org.junit.Assert;
import org.junit.Test;

public class EmailOtpRegistrationTest {

    @Test
    public void testGenerateOtpFormatAndRandomness() {
        for (int i = 0; i < 50; i++) {
            String otp = EmailService.generateOtp();
            Assert.assertNotNull("OTP không được null", otp);
            Assert.assertEquals("OTP phải có đúng 6 chữ số", 6, otp.length());
            Assert.assertTrue("OTP phải toàn ký tự số", otp.matches("^[0-9]{6}$"));
            int num = Integer.parseInt(otp);
            Assert.assertTrue("OTP phải nằm trong khoảng 100000 - 999999", num >= 100000 && num <= 999999);
        }
    }

    @Test
    public void testEmailServiceGracefulFallback() {
        EmailService service = new EmailService();
        String testOtp = EmailService.generateOtp();
        
        // Kiểm thử gửi email an toàn không throw exception
        EmailService.SendEmailResult result = service.sendOtpEmail("kiettran130806@gmail.com", testOtp);
        Assert.assertNotNull("Kết quả gửi email không được null", result);
    }

    @Test
    public void testIsEmailExistsLogic() {
        UserService userService = new UserService();
        Assert.assertFalse("Email null không được tính là tồn tại", userService.isEmailExists(null));
        Assert.assertFalse("Email rỗng không được tính là tồn tại", userService.isEmailExists("   "));
        Assert.assertFalse("Email ngẫu nhiên không tồn tại trong DB", 
                userService.isEmailExists("random_non_existent_" + System.currentTimeMillis() + "@gmail.com"));
    }
}
