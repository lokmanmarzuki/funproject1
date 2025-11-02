# Quick Build Script - Automatically handles proxy
# Usage: .\build.ps1 [proxy|no-proxy]
# If no parameter, detects network and decides automatically

param(
    [Parameter(Position=0)]
    [ValidateSet("proxy", "no-proxy", "")]
    [string]$Mode = ""
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "EvokePass Docker Build" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# If mode not specified, try to auto-detect
if ($Mode -eq "") {
    Write-Host "Auto-detecting network environment..." -ForegroundColor Yellow
    
    # Try to ping corporate proxy to see if we're on corporate network
    $pingResult = Test-Connection -ComputerName "proxy-dmz.company.com" -Count 1 -Quiet -ErrorAction SilentlyContinue
    
    if ($pingResult) {
        Write-Host "✓ Corporate network detected" -ForegroundColor Green
        $Mode = "proxy"
    } else {
        Write-Host "✓ External network detected" -ForegroundColor Green
        $Mode = "no-proxy"
    }
    Write-Host ""
}

# Configure proxy based on mode
if ($Mode -eq "proxy") {
    Write-Host "Using corporate proxy: proxy-dmz.company.com:912" -ForegroundColor Cyan
    $env:HTTP_PROXY = "http://proxy-dmz.company.com:912"
    $env:HTTPS_PROXY = "http://proxy-dmz.company.com:912"
} else {
    Write-Host "Building without proxy" -ForegroundColor Cyan
    $env:HTTP_PROXY = ""
    $env:HTTPS_PROXY = ""
}

Write-Host ""
Write-Host "Building Docker container..." -ForegroundColor Yellow
Write-Host ""

# Build and start
docker-compose down
docker-compose up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "✓ Build Successful!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access the dashboard: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "TCP server listening on: localhost:3001" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Test with: .\test-event.ps1" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Red
    Write-Host "✗ Build Failed" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    if ($Mode -eq "no-proxy") {
        Write-Host "Tip: If you're on corporate network, try: .\build.ps1 proxy" -ForegroundColor Yellow
    } else {
        Write-Host "Tip: If you're outside corporate network, try: .\build.ps1 no-proxy" -ForegroundColor Yellow
    }
}
