@echo off
REM ============================================================
REM 构建 Release APK 并安装到已连接的 Android 手机
REM
REM 方式一（推荐）：直接双击本文件 build_and_install.bat
REM
REM 方式二：在项目根目录打开 PowerShell，执行：
REM   .\scripts\build_and_install.ps1
REM   .\scripts\build_and_install.ps1 -DeviceId R5CX223B2KM   （指定设备）
REM
REM 使用前：手机 USB 连接电脑，并开启 USB 调试
REM ============================================================
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build_and_install.ps1" %*
if errorlevel 1 (
    echo.
    echo Build or install failed.
    pause
    exit /b 1
)
echo.
pause
