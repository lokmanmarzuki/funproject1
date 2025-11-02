# Docker Proxy Configuration Script for Intel Network
# This script configures Docker Desktop to use Intel's corporate proxy

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Docker Proxy Configuration" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$proxyServer = "proxy-dmz.intel.com:912"
$dockerConfigPath = "$env:USERPROFILE\.docker"
$dockerConfigFile = "$dockerConfigPath\config.json"

Write-Host "Detected proxy: $proxyServer" -ForegroundColor Green
Write-Host ""

# Create .docker directory if it doesn't exist
if (!(Test-Path $dockerConfigPath)) {
    New-Item -ItemType Directory -Path $dockerConfigPath -Force | Out-Null
    Write-Host "Created Docker config directory: $dockerConfigPath" -ForegroundColor Yellow
}

# Read existing config or create new one
if (Test-Path $dockerConfigFile) {
    Write-Host "Reading existing Docker config..." -ForegroundColor Yellow
    $config = Get-Content $dockerConfigFile -Raw | ConvertFrom-Json
} else {
    Write-Host "Creating new Docker config..." -ForegroundColor Yellow
    $config = @{
        proxies = @{
            default = @{}
        }
    }
}

# Ensure the structure exists
if (!$config.proxies) {
    $config | Add-Member -MemberType NoteProperty -Name "proxies" -Value @{ default = @{} } -Force
}
if (!$config.proxies.default) {
    $config.proxies | Add-Member -MemberType NoteProperty -Name "default" -Value @{} -Force
}

# Set proxy configuration
$config.proxies.default = @{
    httpProxy = "http://$proxyServer"
    httpsProxy = "http://$proxyServer"
    noProxy = "localhost,127.0.0.1"
}

# Save configuration
$config | ConvertTo-Json -Depth 10 | Set-Content $dockerConfigFile
Write-Host ""
Write-Host "✅ Docker proxy configuration saved to: $dockerConfigFile" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  HTTP Proxy:  http://$proxyServer" -ForegroundColor White
Write-Host "  HTTPS Proxy: http://$proxyServer" -ForegroundColor White
Write-Host "  No Proxy:    localhost,127.0.0.1" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: You must restart Docker Desktop for changes to take effect!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Steps:" -ForegroundColor Cyan
Write-Host "  1. Right-click Docker whale icon in system tray" -ForegroundColor White
Write-Host "  2. Click 'Quit Docker Desktop'" -ForegroundColor White
Write-Host "  3. Start Docker Desktop again" -ForegroundColor White
Write-Host "  4. Wait for Docker to fully start" -ForegroundColor White
Write-Host "  5. Try: docker-compose up -d" -ForegroundColor White
Write-Host ""

# Alternative: Also set environment variables for Docker CLI
Write-Host "Setting environment variables for current session..." -ForegroundColor Yellow
$env:HTTP_PROXY = "http://$proxyServer"
$env:HTTPS_PROXY = "http://$proxyServer"
$env:NO_PROXY = "localhost,127.0.0.1"

Write-Host "✅ Environment variables set for current PowerShell session" -ForegroundColor Green
Write-Host ""
Write-Host "To make environment variables permanent (optional):" -ForegroundColor Cyan
Write-Host "  [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', 'http://$proxyServer', 'User')" -ForegroundColor Gray
Write-Host "  [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', 'http://$proxyServer', 'User')" -ForegroundColor Gray
Write-Host ""
