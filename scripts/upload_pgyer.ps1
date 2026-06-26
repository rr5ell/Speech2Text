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

$apiDomains = @('api.pgyer.com', 'api.xcxwo.com', 'api.pgyeraapp.com')
$selectedDomain = $null

foreach ($domain in $apiDomains) {
    try {
        $testUrl = "https://$domain/apiv2/app/getCOSToken"
        $null = Invoke-WebRequest -Uri $testUrl -Method POST -Body @{ _api_key = $ApiKey } -TimeoutSec 10
        $selectedDomain = $domain
        break
    } catch {
        continue
    }
}

if (-not $selectedDomain) {
    throw 'Unable to reach PGYER API domains.'
}

Write-Host "Using API domain: $selectedDomain"

$tokenBody = @{
    _api_key = $ApiKey
    buildType = 'apk'
    buildInstallType = '1'
    buildUpdateDescription = $UpdateDescription
}

$tokenResp = Invoke-RestMethod -Uri "https://$selectedDomain/apiv2/app/getCOSToken" -Method POST -Body $tokenBody
if ($tokenResp.code -ne 0) {
    throw "Failed to get upload token: $($tokenResp.message)"
}

$data = $tokenResp.data
Write-Host 'Upload token obtained. Uploading APK...'

$fileName = [IO.Path]::GetFileName($ApkPath)
$boundary = [Guid]::NewGuid().ToString()
$LF = "`r`n"
$fileBytes = [IO.File]::ReadAllBytes($ApkPath)

$bodyStart = (
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"key`"$LF$LF$($data.key)$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"signature`"$LF$LF$($data.signature)$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"x-cos-security-token`"$LF$LF$($data.'x-cos-security-token')$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"x-cos-meta-file-name`"$LF$LF$fileName$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"$LF" +
    "Content-Type: application/vnd.android.package-archive$LF$LF"
)
$bodyEnd = "$LF--$boundary--$LF"
$bodyBytes = [Text.Encoding]::UTF8.GetBytes($bodyStart) + $fileBytes + [Text.Encoding]::UTF8.GetBytes($bodyEnd)

$uploadResp = Invoke-WebRequest -Uri $data.endpoint -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyBytes -TimeoutSec 3600
if ($uploadResp.StatusCode -ne 204) {
    throw "Upload failed with HTTP $($uploadResp.StatusCode)"
}

Write-Host 'APK uploaded. Waiting for build processing...'

$webDomain = $selectedDomain -replace '^api\.', ''
for ($i = 1; $i -le 120; $i++) {
    Start-Sleep -Seconds 2
    $info = Invoke-RestMethod -Uri "https://$selectedDomain/apiv2/app/buildInfo" -Method POST -Body @{
        _api_key = $ApiKey
        buildKey = $data.key
    }
    if ($info.code -eq 0) {
        $url = "https://$webDomain/$($info.data.buildShortcutUrl)"
        Write-Host ''
        Write-Host 'Upload completed!'
        Write-Host "App: $($info.data.buildName)"
        Write-Host "Version: $($info.data.buildVersion) ($($info.data.buildVersionNo))"
        Write-Host "URL: $url"
        return
    }
}

throw 'Build processing timed out.'
