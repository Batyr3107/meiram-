@echo off
REM ============================================
REM ShopMobile - APK Build Script
REM ============================================

echo.
echo ==========================================
echo   ShopMobile - APK Builder
echo ==========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found in PATH!
    echo.
    echo Please install Flutter SDK:
    echo   1. Download: https://docs.flutter.dev/get-started/install/windows
    echo   2. Extract to: C:\src\flutter
    echo   3. Add to PATH: C:\src\flutter\bin
    echo   4. Run: flutter doctor
    echo.
    echo Or use package manager:
    echo   choco install flutter
    echo   OR
    echo   scoop install flutter
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter found
flutter --version
echo.

REM Check Java
if not defined JAVA_HOME (
    echo [WARNING] JAVA_HOME not set
    echo Setting JAVA_HOME to default location...
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
)
echo [OK] JAVA_HOME: %JAVA_HOME%
echo.

REM Navigate to project directory
cd /d "%~dp0"
echo [INFO] Project directory: %CD%
echo.

REM Clean previous build
echo [1/5] Cleaning previous build...
if exist build (
    rmdir /s /q build
    echo [OK] Build directory cleaned
) else (
    echo [OK] No previous build found
)
echo.

REM Get dependencies
echo [2/5] Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies!
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Analyze code
echo [3/5] Analyzing code...
call flutter analyze --no-fatal-infos
if %errorlevel% neq 0 (
    echo [WARNING] Code analysis found issues
    echo Continue anyway? (Y/N)
    choice /c YN /n
    if errorlevel 2 exit /b 1
)
echo [OK] Code analysis complete
echo.

REM Build release APK
echo [4/5] Building release APK...
echo This may take 3-5 minutes...
echo.
call flutter build apk --release
if %errorlevel% neq 0 (
    echo [ERROR] APK build failed!
    pause
    exit /b 1
)
echo [OK] APK built successfully
echo.

REM Check APK
echo [5/5] Checking APK...
set "APK_PATH=build\app\outputs\flutter-apk\app-release.apk"
if exist "%APK_PATH%" (
    echo [OK] APK found: %APK_PATH%
    echo.

    REM Get file size
    for %%A in ("%APK_PATH%") do (
        set "APK_SIZE=%%~zA"
    )

    REM Convert bytes to MB
    set /a "APK_SIZE_MB=%APK_SIZE% / 1048576"

    echo ==========================================
    echo   BUILD SUCCESSFUL!
    echo ==========================================
    echo.
    echo APK Location: %APK_PATH%
    echo APK Size:     ~%APK_SIZE_MB% MB
    echo.
    echo To install on device:
    echo   adb install "%APK_PATH%"
    echo.
    echo Or copy APK to device and install manually
    echo ==========================================
    echo.

    REM Copy to desktop (optional)
    set "DESKTOP=%USERPROFILE%\Desktop"
    echo Copy APK to Desktop? (Y/N)
    choice /c YN /n
    if errorlevel 1 if not errorlevel 2 (
        copy "%APK_PATH%" "%DESKTOP%\ShopMobile.apk"
        echo [OK] APK copied to Desktop
        echo.
    )

) else (
    echo [ERROR] APK not found!
    echo Expected location: %APK_PATH%
    pause
    exit /b 1
)

echo Build complete!
pause
