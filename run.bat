@echo off
cd /d "%~dp0"
echo ============================================
echo       Campus Bus Live - Run Menu
echo ============================================
echo.
echo 1. Run on Chrome (Web) - DEFAULT
echo 2. Run on Windows
echo 3. Run on Android
echo 4. Run on iOS (Mac only)
echo 5. Get dependencies only
echo.
echo ============================================
set /p choice=Select option (1-5): 

if "%choice%"=="1" goto chrome
if "%choice%"=="2" goto windows
if "%choice%"=="3" goto android
if "%choice%"=="4" goto ios
if "%choice%"=="5" goto deps
if "%choice%"=="" goto chrome

echo Invalid option! Running Chrome...
goto chrome

:chrome
echo.
echo Starting Chrome (Web)...
call C:\flutter\bin\flutter.bat run -d chrome
goto end

:windows
echo.
echo Starting Windows...
call C:\flutter\bin\flutter.bat run -d windows
goto end

:android
echo.
echo Starting Android...
call C:\flutter\bin\flutter.bat run -d android
goto end

:ios
echo.
echo Starting iOS...
call C:\flutter\bin\flutter.bat run -d ios
goto end

:deps
echo.
echo Getting dependencies...
call C:\flutter\bin\flutter.bat pub get
goto end

:end
echo.
echo ============================================
echo Done! Press any key to exit...
echo ============================================
pause > nul