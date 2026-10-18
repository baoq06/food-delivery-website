package com.ute.fooddelivery.utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public class UploadUtils {

    /**
     * Lưu trữ tệp tin upload từ Part an toàn vào cả thư mục source và thư mục runtime webapps.
     *
     * @param part Part nhận từ form multipart
     * @param subFolder Thư mục con (ví dụ: "avatars", "drivers", "restaurants")
     * @param req HttpServletRequest để lấy đường dẫn thực tế
     * @return Đường dẫn URL tương đối (ví dụ: "/assets/uploads/avatars/abc.jpg") hoặc null nếu không có file
     */
    public static String saveUploadedFile(Part part, String subFolder, HttpServletRequest req) {
        if (part == null || part.getSize() <= 0) {
            return null;
        }

        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            return null;
        }

        // Làm sạch tên file và lấy đuôi mở rộng
        String cleanName = new File(submittedFileName).getName().replaceAll("[^a-zA-Z0-9._-]", "_");
        String extension = "";
        int dotIndex = cleanName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = cleanName.substring(dotIndex).toLowerCase();
        } else {
            extension = ".jpg";
        }

        // Đảm bảo đuôi file là ảnh hợp lệ
        if (!extension.matches("^\\.(jpg|jpeg|png|webp|gif)$")) {
            extension = ".jpg";
        }

        String uniqueFileName = UUID.randomUUID().toString().replace("-", "") + extension;

        try {
            // 1. Lưu vào thư mục thực thi của webapp (Tomcat)
            String runtimeUploadDir = req.getServletContext().getRealPath("/assets/uploads/" + subFolder);
            File runtimeFile = null;
            if (runtimeUploadDir != null) {
                File runtimeDir = new File(runtimeUploadDir);
                if (!runtimeDir.exists()) {
                    runtimeDir.mkdirs();
                }
                runtimeFile = new File(runtimeDir, uniqueFileName);
                try (InputStream in = part.getInputStream()) {
                    Files.copy(in, runtimeFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            // 2. Lưu vào thư mục lưu trữ lâu dài (source directory hoặc UPLOAD_DIR cấu hình bên ngoài)
            // để không bị mất dữ liệu khi build lại hoặc redeploy.
            File persistentDir = resolvePersistentUploadDir(req, subFolder);
            if (persistentDir != null) {
                if (!persistentDir.exists()) {
                    persistentDir.mkdirs();
                }
                File persistentFile = new File(persistentDir, uniqueFileName);
                if (runtimeFile != null && runtimeFile.exists()) {
                    Files.copy(runtimeFile.toPath(), persistentFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                } else {
                    try (InputStream in = part.getInputStream()) {
                        Files.copy(in, persistentFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                }
            }

            return "/assets/uploads/" + subFolder + "/" + uniqueFileName;
        } catch (Exception e) {
            System.err.println("Lỗi khi lưu ảnh upload: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Xác định thư mục lưu trữ lâu dài (thư mục upload cấu hình ngoài qua UPLOAD_DIR hoặc
     * thư mục source 'src/main/webapp/assets/uploads' của dự án trong môi trường phát triển).
     * Tuyệt đối không gán cứng ký tự ổ đĩa (c:/, d:/...).
     *
     * @param req HttpServletRequest để lấy context realPath
     * @param subFolder Thư mục con
     * @return File đối tượng thư mục đích, hoặc null nếu không xác định được
     */
    public static File resolvePersistentUploadDir(HttpServletRequest req, String subFolder) {
        String cleanSub = (subFolder != null && !subFolder.trim().isEmpty()) ? subFolder.trim() : "";

        // 1. Kiểm tra cấu hình UPLOAD_DIR từ System Property hoặc Biến môi trường
        String customUploadDir = System.getProperty("upload.dir");
        if (customUploadDir == null || customUploadDir.trim().isEmpty()) {
            customUploadDir = System.getProperty("UPLOAD_DIR");
        }
        if (customUploadDir == null || customUploadDir.trim().isEmpty()) {
            customUploadDir = System.getenv("UPLOAD_DIR");
        }
        if (customUploadDir != null && !customUploadDir.trim().isEmpty()) {
            File baseDir = new File(customUploadDir.trim());
            return cleanSub.isEmpty() ? baseDir : new File(baseDir, cleanSub);
        }

        // 2. Xác định động thư mục source từ realPath của servlet context
        if (req != null && req.getServletContext() != null) {
            String realPath = req.getServletContext().getRealPath("");
            if (realPath == null) {
                realPath = req.getServletContext().getRealPath("/");
            }
            if (realPath != null) {
                File current = new File(realPath);
                // Duyệt ngược lên các thư mục cha (ví dụ: target/food-delivery-website -> target -> project root)
                for (int i = 0; i < 5 && current != null; i++) {
                    File srcDir = new File(current, "src/main/webapp/assets/uploads");
                    if (srcDir.exists() && srcDir.isDirectory()) {
                        return cleanSub.isEmpty() ? srcDir : new File(srcDir, cleanSub);
                    }
                    current = current.getParentFile();
                }
            }
        }

        // 3. Fallback: Duyệt từ thư mục làm việc hiện tại (user.dir)
        String userDir = System.getProperty("user.dir");
        if (userDir != null) {
            File current = new File(userDir);
            for (int i = 0; i < 5 && current != null; i++) {
                File srcDir = new File(current, "src/main/webapp/assets/uploads");
                if (srcDir.exists() && srcDir.isDirectory()) {
                    return cleanSub.isEmpty() ? srcDir : new File(srcDir, cleanSub);
                }
                current = current.getParentFile();
            }
        }

        return null;
    }
}
