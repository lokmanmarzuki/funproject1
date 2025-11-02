# Docker No Proxy Setup - For use outside corporate network
# This script removes proxy settings for Docker operations

Write-Host "Removing proxy settings for Docker..." -ForegroundColor Green

# Clear proxy environment variables for current session
$env:HTTP_PROXY = ""
$env:HTTPS_PROXY = ""
$env:NO_PROXY = ""

Write-Host "✓ Proxy environment variables cleared" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run: docker-compose up -d --build" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: This only affects the current PowerShell session." -ForegroundColor Yellow
