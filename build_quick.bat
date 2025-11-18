@echo off
REM Quick APK Build Script

echo ==========================================
echo   ShopMobile APK Builder
echo ==========================================
echo.

REM Set Flutter environment
set "FLUTTER_ROOT=C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter"
set "PATH=%FLUTTER_ROOT%\bin;%PATH%"
set "PUB_CACHE=%FLUTTER_ROOT%\.pub-cache"

REM Navigate to project
cd /d "%~dp0"
echo Project: %CD%
echo.

echo [1/4] Checking Flutter...
"%FLUTTER_ROOT%\bin\flutter.bat" --version
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found!
    pause
    exit /b 1
)
echo [OK] Flutter found
echo.

echo [2/4] Cleaning old build...
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
echo [OK] Cleaned
echo.

echo [3/4] Getting dependencies...
"%FLUTTER_ROOT%\bin\flutter.bat" pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

echo [4/4] Building APK...
echo This will take 3-5 minutes...
echo.
"%FLUTTER_ROOT%\bin\flutter.bat" build apk --release
if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   BUILD SUCCESS!
echo ==========================================
echo.
echo APK Location:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
echo.
echo Opening folder...
explorer build\app\outputs\flutter-apk
echo.
pause
