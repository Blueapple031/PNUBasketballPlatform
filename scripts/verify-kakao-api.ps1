# /api/auth/kakao endpoint connection check
# Usage: .\scripts\verify-kakao-api.ps1 [baseUrl]

param(
    [string]$BaseUrl = "https://ddalba.duckdns.org"
)

$kakaoEndpoint = "$BaseUrl/api/auth/kakao"
$healthEndpoint = "$BaseUrl/api/health"

Write-Host "=== API Connection Check ===" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host ""

# 1. Health check
Write-Host "1. Health ($healthEndpoint)" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri $healthEndpoint -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "   Status: $($health.StatusCode) OK" -ForegroundColor Green
}
catch {
    Write-Host "   FAIL: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 2. Kakao login endpoint
Write-Host "2. Kakao Login ($kakaoEndpoint)" -ForegroundColor Yellow
try {
    $body = '{"accessToken":"dummy_token_for_test"}'
    $kakao = Invoke-WebRequest -Uri $kakaoEndpoint -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 10
    Write-Host "   Status: $($kakao.StatusCode)" -ForegroundColor Green
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   Status: $statusCode"
    if ($statusCode -eq 502) {
        Write-Host "   502 = Nginx cannot reach backend. Check server nginx config." -ForegroundColor Red
    }
    elseif ($statusCode -eq 401 -or $statusCode -eq 400) {
        Write-Host "   Endpoint reachable. 401/400 = token validation fail (OK)" -ForegroundColor Green
    }
}
Write-Host ""
