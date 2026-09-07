$tomcatDir = "C:\Users\Admin\apache-tomcat-11.0.25\apache-tomcat-11.0.25" # <--- SỬA ĐƯỜNG DẪN TOMCAT CỦA BẠN Ở ĐÂY
$projectName = "food-delivery-website"

Write-Host "1. Bien dich du an bang Maven (Skip Tests)..." -ForegroundColor Cyan
mvn clean package -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "Loi bien dich Maven. Huy bo." -ForegroundColor Red
    exit
}

Write-Host "2. Xoa ban deploy cu trong Tomcat..." -ForegroundColor Cyan
$webappsDir = Join-Path $tomcatDir "webapps"
$targetWar = Join-Path $webappsDir "$projectName.war"
$targetDir = Join-Path $webappsDir $projectName

if (Test-Path $targetDir) {
    Remove-Item -Recurse -Force $targetDir
}
if (Test-Path $targetWar) {
    Remove-Item -Force $targetWar
}

Write-Host "3. Copy file WAR moi vao Tomcat..." -ForegroundColor Cyan
$sourceWar = Join-Path "target" "$projectName.war"
if (Test-Path $sourceWar) {
    Copy-Item $sourceWar -Destination $webappsDir
} else {
    Write-Host "Khong tim thay file WAR du da build thanh cong!" -ForegroundColor Red
    exit
}

Write-Host "4. Khoi dong vu tru Tomcat 11..." -ForegroundColor Cyan
$startupScript = Join-Path $tomcatDir "bin\startup.bat"
if (Test-Path $startupScript) {
    Start-Process "cmd.exe" -ArgumentList "/c `"$startupScript`""
    Write-Host "Tuyet voi! He thong dang duoc khoi dong tren cua so rieng biet." -ForegroundColor Green
    Write-Host "Truy cap vao: http://localhost:8080/$projectName" -ForegroundColor Yellow
} else {
    Write-Host "LOI: Khong tim thay file startup.bat. Hay kiem tra lai duong dan TomcatDir o dong 1 nhe!" -ForegroundColor Red
}
