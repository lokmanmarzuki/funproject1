# Test Docker connectivity after proxy configuration

Write-Host "Testing Docker connectivity..." -ForegroundColor Cyan
Write-Host ""

# Test Docker version
Write-Host "1. Testing Docker version..." -ForegroundColor Yellow
docker --version

Write-Host ""

# Test Docker pull
Write-Host "2. Testing Docker pull (small image)..." -ForegroundColor Yellow
docker pull hello-world

Write-Host ""

# Test Docker run
Write-Host "3. Testing Docker run..." -ForegroundColor Yellow
docker run --rm hello-world

Write-Host ""
Write-Host "✅ If you see 'Hello from Docker!' above, proxy is working!" -ForegroundColor Green
Write-Host ""
Write-Host "Now you can build your EvokePass project:" -ForegroundColor Cyan
Write-Host "  docker-compose up -d" -ForegroundColor White
