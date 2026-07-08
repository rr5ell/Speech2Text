param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey,

    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [string]$UpdateDescription = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ApkPath)) {
    throw "APK not found: $ApkPath"
}

$apiHosts = @(
    'https://www.pgyer.com/apiv2/app',
    'https://www.xcxwo.com/apiv2/app',
    'https://www.pgyerapp.com/apiv2/app'
)
$selectedDomain = $null
$selectedHost = $null

foreach ($host in $apiHosts) {
    try {
        $testUrl = "$host/getCOSToken"
        $null = Invoke-WebRequest -Uri $testUrl -Method POST -Body @{ _api_key = $ApiKey } -TimeoutSec 10
        $selectedHost = $host
        $selectedDomain = ([Uri]$host).Host
        break
    } catch {
        continue
    }
}

if (-not $selectedHost) {
    throw 'Unable to reach PGYER API domains.'
}

Write-Host "Using API host: $selectedHost"

$tokenBody = @{
    _api_key = $ApiKey
    buildType = 'android'
    buildInstallType = '1'
    buildUpdateDescription = $UpdateDescription
}

$tokenResp = Invoke-RestMethod -Uri "$selectedHost/getCOSToken" -Method POST -Body $tokenBody
if ($tokenResp.code -ne 0) {
    throw "Failed to get upload token: $($tokenResp.message)"
}

$data = $tokenResp.data
$uploadParams = $data.params
if (-not $uploadParams) {
    $uploadParams = $data
}
Write-Host 'Upload token obtained. Uploading APK...'

$fileName = [IO.Path]::GetFileName($ApkPath)
$curlArgs = @('-sS', '-i', '-X', 'POST', $data.endpoint)
foreach ($prop in $uploadParams.PSObject.Properties) {
    $curlArgs += @('--form-string', "$($prop.Name)=$($prop.Value)")
}
$curlArgs += @('--form-string', "x-cos-meta-file-name=$fileName")
$curlArgs += @('-F', "file=@$ApkPath;type=application/vnd.android.package-archive")

$uploadResp = & curl.exe @curlArgs
$statusLines = $uploadResp | Where-Object { $_ -match '^HTTP/' }
$lastStatus = $statusLines | Select-Object -Last 1
if ($lastStatus -notmatch ' 204 ') {
    throw "Upload failed: $($uploadResp -join [Environment]::NewLine)"
}

Write-Host 'APK uploaded. Waiting for build processing...'

for ($i = 1; $i -le 120; $i++) {
    Start-Sleep -Seconds 2
    $info = Invoke-RestMethod -Uri "$selectedHost/buildInfo" -Method POST -Body @{
        _api_key = $ApiKey
        buildKey = $data.key
    }
    if ($info.code -eq 0) {
        $shortcut = $info.data.buildShortcutUrl
        if (-not $shortcut) {
            $shortcut = $info.data.buildKey
        }
        $url = "https://www.pgyer.com/$shortcut"
        Write-Host ''
        Write-Host 'Upload completed!'
        Write-Host "App: $($info.data.buildName)"
        Write-Host "Version: $($info.data.buildVersion) ($($info.data.buildVersionNo))"
        Write-Host "URL: $url"
        return
    }
}

throw 'Build processing timed out.'
