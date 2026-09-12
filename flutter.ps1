$ErrorActionPreference = "SilentlyContinue"

# Set UTF-8 output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Find flutter path
$flutterPath = "C:\flutter\bin\flutter.bat"

if (-not (Test-Path $flutterPath)) {
    # Try to find flutter in PATH
    $flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterPath) {
        $flutterPath = $flutterPath.Source
    }
}

if (-not (Test-Path $flutterPath)) {
    Write-Host "Flutter not found! Please install Flutter SDK." -ForegroundColor Red
    Write-Host "Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found Flutter at: $flutterPath" -ForegroundColor Green
Write-Host ""

# Get available devices
Write-Host "Checking available devices..." -ForegroundColor Cyan
& $flutterPath devices 2>&1 | ForEach-Object { Write-Host $_ }

Write-Host ""
Write-Host "Available options:" -ForegroundColor Yellow
Write-Host "  1 - Run on Chrome (Web)" 
Write-Host "  2 - Run on Windows"
Write-Host "  3 - Run on Android"
Write-Host "  4 - Run on iOS (Mac only)"
Write-Host "  5 - Just get dependencies"
Write-Host ""

$choice = Read-Host "Enter choice (1-5) [default: 1]"

if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

Write-Host ""
Write-Host "Running..." -ForegroundColor Green

switch ($choice) {
    "1" { & $flutterPath run -d chrome }
    "2" { & $flutterPath run -d windows }
    "3" { & $flutterPath run -d android }
    "4" { & $flutterPath run -d ios }
    "5" { & $flutterPath pub get }
    default { 
        Write-Host "Invalid choice, running on Chrome..." -ForegroundColor Yellow
        & $flutterPath run -d chrome 
    }
}