# Скрипт для проверки статуса сборки APK
$flutterPath = "C:\Users\JusanUser\Downloads\flutter_windows_3.29.0-stable\flutter\bin"
$projectPath = "C:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master"
$apkPath = "$projectPath\build\app\outputs\flutter-apk\app-release.apk"

Write-Host "Проверяю статус сборки APK..." -ForegroundColor Cyan
Write-Host ""

# Проверяем, запущен ли процесс сборки
$gradleProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*gradle*" }
$flutterProcess = Get-Process -Name "dart" -ErrorAction SilentlyContinue

if ($gradleProcess -or $flutterProcess) {
    Write-Host "Сборка в процессе..." -ForegroundColor Yellow
    Write-Host "Подождите, это может занять 3-5 минут..."
} else {
    Write-Host "Процесс сборки не найден" -ForegroundColor Yellow
}

Write-Host ""

# Проверяем наличие APK
if (Test-Path $apkPath) {
    $file = Get-Item $apkPath
    $sizeMB = [math]::Round($file.Length / 1MB, 2)
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APK УСПЕШНО СОБРАН!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Путь: $apkPath" -ForegroundColor White
    Write-Host "Размер: $sizeMB MB" -ForegroundColor White
    Write-Host "Дата: $($file.LastWriteTime)" -ForegroundColor White
    Write-Host ""
    Write-Host "APK готов к установке!" -ForegroundColor Green
} else {
    Write-Host "APK ещё не готов" -ForegroundColor Yellow
    Write-Host "Путь: $apkPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Проверьте логи сборки или запустите сборку заново:" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release" -ForegroundColor Cyan
}

Write-Host ""

