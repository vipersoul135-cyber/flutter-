@echo off
setlocal enabledelayedexpansion

REM Find flutter installation
set "FLUTTER_PATH="
if exist "C:\flutter\bin\flutter.bat" (
    set "FLUTTER_PATH=C:\flutter\bin\flutter.bat"
) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "FLUTTER_PATH=%USERPROFILE%\flutter\bin\flutter.bat"
) else (
    REM Try to find in PATH
    for /f "delims=" %%i in ('where flutter 2^>nul') do (
        set "FLUTTER_PATH=%%i"
        goto :found
    )
    :found
)

if "%FLUTTER_PATH%"=="" (
    echo ERROR: Flutter not found!
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo ============================================
echo   Campus Bus Live - Flutter App
echo ============================================
echo.
echo Using Flutter from: %FLUTTER_PATH%
echo.

REM First, get dependencies
echo Getting dependencies...
call "%FLUTTER_PATH%" pub get
if errorlevel 1 (
    echo.
    echo ERROR: Failed to get dependencies!
    echo Please check your internet connection and try again.
    pause
    exit /b 1
)
echo Dependencies installed successfully!
echo.

REM Check arguments
if "%1"=="" (
    echo ============================================
    echo   Select Run Option
    echo ============================================
    echo.
    echo   1 - Chrome (Web)  [DEFAULT]
    echo   2 - Windows
    echo   3 - Android
    echo   4 - iOS (Mac only)
    echo   5 - Get dependencies only
    echo.
    set /p choice="Enter choice (1-5): "
    
    if "!choice!"=="1" set "DEVICE=chrome"
    if "!choice!"=="2" set "DEVICE=windows"
    if "!choice!"=="3" set "DEVICE=android"
    if "!choice!"=="4" set "DEVICE=ios"
    if "!choice!"=="5" (
        echo.
        echo Dependencies already up to date!
        pause
        exit /b 0
    )
    if "!choice!"=="" set "DEVICE=chrome"
    
    echo.
    echo ============================================
    echo   Running on !DEVICE!...
    echo ============================================
    echo.
    call "%FLUTTER_PATH%" run -d !DEVICE!
) else (
    REM Pass through all arguments to flutter
    call "%FLUTTER_PATH%" %*
)

echo.
echo ============================================
echo   Done!
echo ============================================
pause