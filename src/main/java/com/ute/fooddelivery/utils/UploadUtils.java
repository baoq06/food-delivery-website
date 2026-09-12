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
            if (runtimeUploadDir != null) {
                File runtimeDir = new File(runtimeUploadDir);
                if (!runtimeDir.exists()) {
                    runtimeDir.mkdirs();
                }
                File runtimeFile = new File(runtimeDir, uniqueFileName);
                try (InputStream in = part.getInputStream()) {
                    Files.copy(in, runtimeFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            // 2. Lưu vào thư mục source của dự án (để không bị mất khi build lại)
            String sourcePath = "c:/food-delivery-website/src/main/webapp/assets/uploads/" + subFolder;
            File sourceDir = new File(sourcePath);
            if (!sourceDir.exists()) {
                sourceDir.mkdirs();
            }
            File sourceFile = new File(sourceDir, uniqueFileName);
            // Copy từ runtimeFile hoặc lưu trực tiếp
            if (runtimeUploadDir != null) {
                File runtimeFile = new File(runtimeUploadDir, uniqueFileName);
                if (runtimeFile.exists()) {
                    Files.copy(runtimeFile.toPath(), sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            return "/assets/uploads/" + subFolder + "/" + uniqueFileName;
        } catch (Exception e) {
            System.err.println("Lỗi khi lưu ảnh upload: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
