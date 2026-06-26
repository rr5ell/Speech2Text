# Build release APK and install to connected Android device.
# Usage:
#   .\scripts\build_and_install.ps1
#   .\scripts\build_and_install.ps1 -DeviceId R5CX223B2KM

param(
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$ApkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"

function Invoke-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & flutter @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "flutter $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
        }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
}

Write-Host ""
Write-Host "=== Speech_to_Text: Build and Install ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"
Write-Host ""

try {
    $null = Get-Command flutter -ErrorAction Stop
} catch {
    throw "flutter command not found. Please install Flutter and add it to PATH."
}

Write-Host "Step 1/3: Checking devices..." -ForegroundColor Yellow
Invoke-Flutter -Arguments @("devices")
Write-Host ""

Write-Host "Step 2/3: Building release APK (this may take a few minutes)..." -ForegroundColor Yellow
Invoke-Flutter -Arguments @("build", "apk", "--release")

if (-not (Test-Path $ApkPath)) {
    throw "Build finished but APK not found: $ApkPath"
}

$apkSizeMB = [math]::Round((Get-Item $ApkPath).Length / 1MB, 1)
Write-Host "APK ready: $ApkPath ($apkSizeMB MB)" -ForegroundColor Green
Write-Host ""

Write-Host "Step 3/3: Installing to device..." -ForegroundColor Yellow
if ($DeviceId) {
    Invoke-Flutter -Arguments @("install", "--release", "-d", $DeviceId)
} else {
    Invoke-Flutter -Arguments @("install", "--release")
}

Write-Host ""
Write-Host "Done! App installed and launched on your phone." -ForegroundColor Green
Write-Host ""
