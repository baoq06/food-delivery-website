package com.ute.fooddelivery;

import com.ute.fooddelivery.utils.UploadUtils;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class UploadUtilsTest {

    private String originalUploadDir;

    @Before
    public void setUp() {
        originalUploadDir = System.getProperty("upload.dir");
        System.clearProperty("upload.dir");
        System.clearProperty("UPLOAD_DIR");
    }

    @After
    public void tearDown() {
        if (originalUploadDir != null) {
            System.setProperty("upload.dir", originalUploadDir);
        } else {
            System.clearProperty("upload.dir");
        }
        System.clearProperty("UPLOAD_DIR");
    }

    private HttpServletRequest createMockRequest(final String realPath) {
        final ServletContext servletContext = (ServletContext) Proxy.newProxyInstance(
                ServletContext.class.getClassLoader(),
                new Class<?>[]{ServletContext.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        if ("getRealPath".equals(method.getName())) {
                            return realPath;
                        }
                        return null;
                    }
                }
        );

        return (HttpServletRequest) Proxy.newProxyInstance(
                HttpServletRequest.class.getClassLoader(),
                new Class<?>[]{HttpServletRequest.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        if ("getServletContext".equals(method.getName())) {
                            return servletContext;
                        }
                        return null;
                    }
                }
        );
    }

    @Test
    public void testResolvePersistentUploadDirWithSystemProperty() {
        File customDir = new File(System.getProperty("java.io.tmpdir"), "custom_uploads_test");
        System.setProperty("upload.dir", customDir.getAbsolutePath());

        File resolved = UploadUtils.resolvePersistentUploadDir(null, "avatars");
        Assert.assertNotNull(resolved);
        Assert.assertEquals(new File(customDir, "avatars").getAbsolutePath(), resolved.getAbsolutePath());
    }

    @Test
    public void testResolvePersistentUploadDirFromTargetRealPath() {
        // Giả lập môi trường khi chạy runtime tại target/food-delivery-website
        File targetDir = new File("target/food-delivery-website").getAbsoluteFile();
        HttpServletRequest req = createMockRequest(targetDir.getAbsolutePath());

        File resolved = UploadUtils.resolvePersistentUploadDir(req, "restaurants");
        Assert.assertNotNull("Phải tự động tìm ra thư mục source từ realPath", resolved);
        
        File expected = new File("src/main/webapp/assets/uploads/restaurants").getAbsoluteFile();
        Assert.assertEquals(expected.getAbsolutePath(), resolved.getAbsolutePath());
        Assert.assertTrue("Thư mục cha của thư mục uploads phải tồn tại", resolved.getParentFile().exists());
    }

    @Test
    public void testResolvePersistentUploadDirFallbackUserDir() {
        // Giả lập req null hoặc getRealPath trả về null
        HttpServletRequest req = createMockRequest(null);

        File resolved = UploadUtils.resolvePersistentUploadDir(req, "drivers");
        Assert.assertNotNull("Phải fallback tìm từ user.dir", resolved);

        File expected = new File("src/main/webapp/assets/uploads/drivers").getAbsoluteFile();
        Assert.assertEquals(expected.getAbsolutePath(), resolved.getAbsolutePath());
    }
}
