# Docker Installation Guide for Windows

This guide will walk you through installing Docker Desktop on Windows to run the EvokePass project.

## Prerequisites

- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- OR Windows 11 64-bit
- WSL 2 (Windows Subsystem for Linux) - will be installed automatically by Docker Desktop
- At least 4GB RAM (8GB recommended)
- BIOS virtualization enabled (VT-x/AMD-V)

## Step-by-Step Installation

### Step 1: Download Docker Desktop

1. **Visit the Docker Desktop download page:**
   - Go to: https://www.docker.com/products/docker-desktop/
   - OR direct download: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe

2. **Click "Download for Windows"**
   - The installer is approximately 500-600 MB

### Step 2: Install Docker Desktop

1. **Run the installer**
   - Double-click `Docker Desktop Installer.exe`
   - If prompted by User Account Control, click "Yes"

2. **Configuration options during installation:**
   - ✅ **Check** "Use WSL 2 instead of Hyper-V" (recommended)
   - ✅ **Check** "Add shortcut to desktop" (optional)

3. **Wait for installation to complete**
   - This may take 5-10 minutes
   - Docker will install WSL 2 if not already installed

4. **Restart your computer when prompted**
   - This is **required** for Docker to work properly

### Step 3: Start Docker Desktop

1. **Launch Docker Desktop**
   - Find Docker Desktop in Start Menu or desktop shortcut
   - Wait for Docker to start (you'll see a whale icon in system tray)
   - First startup may take 2-3 minutes

2. **Accept the Service Agreement**
   - Read and accept the Docker Subscription Service Agreement

3. **Skip the tutorial** (optional)
   - You can skip the Docker tutorial for now

4. **Verify Docker is running**
   - Look for the Docker whale icon in the system tray (bottom-right)
   - When it stops animating, Docker is ready

### Step 4: Verify Installation

Open PowerShell and run these commands:

```powershell
# Check Docker version
docker --version
# Should output: Docker version 24.x.x, build xxxxx

# Check Docker Compose version
docker-compose --version
# Should output: Docker Compose version v2.x.x

# Test Docker is working
docker run hello-world
```

If you see "Hello from Docker!" message, Docker is installed correctly! ✅

### Step 5: Configure Docker (Optional but Recommended)

1. **Open Docker Desktop Settings**
   - Click the Docker whale icon in system tray
   - Click "Settings" (gear icon)

2. **Resources Configuration**
   - Go to: Settings → Resources → Advanced
   - **CPUs**: Set to 2-4 (leave some for your OS)
   - **Memory**: Set to 4-8 GB (leave at least 4GB for your OS)
   - **Disk image size**: Default 60GB is usually fine
   - Click "Apply & Restart"

3. **File Sharing (if needed)**
   - Docker Desktop with WSL 2 automatically shares drives
   - If using Hyper-V, you may need to manually share drives

### Step 6: Configure Corporate Proxy (If Applicable)

If you're behind a corporate proxy, configure Docker to use it:

1. **Open Docker Desktop Settings**
   - Click Docker whale icon → Settings

2. **Go to: Resources → Proxies**
   - Enable "Manual proxy configuration"
   - HTTP Proxy: `http://your-proxy-server:port`
   - HTTPS Proxy: `http://your-proxy-server:port`
   - Click "Apply & Restart"

## Troubleshooting

### Issue: "WSL 2 installation is incomplete"

**Solution:**
1. Open PowerShell as Administrator
2. Run: `wsl --install`
3. Restart computer
4. Start Docker Desktop again

### Issue: "Docker Desktop failed to start"

**Solution:**
1. Check if virtualization is enabled in BIOS
   - Restart PC → Enter BIOS (usually F2, F10, or Del key)
   - Look for "Virtualization Technology" or "VT-x" or "AMD-V"
   - Enable it
   - Save and exit BIOS

2. Enable Hyper-V (if not using WSL 2)
   - Open PowerShell as Administrator:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   ```
   - Restart computer

### Issue: "Cannot connect to Docker daemon"

**Solution:**
1. Make sure Docker Desktop is running (check system tray)
2. Restart Docker Desktop
3. If still not working, restart your computer

### Issue: Docker is slow

**Solution:**
1. Allocate more resources in Docker Desktop Settings
2. Make sure you're using WSL 2 backend (faster than Hyper-V)
3. Clean up unused images and containers:
   ```powershell
   docker system prune -a
   ```

### Issue: "Access denied" errors

**Solution:**
1. Run Docker Desktop as Administrator (right-click → Run as administrator)
2. Add your user to the "docker-users" group:
   - Open Computer Management
   - Go to: Local Users and Groups → Groups
   - Double-click "docker-users"
   - Add your username
   - Log out and log back in

## Next Steps - Run EvokePass

Once Docker is installed and running, you can proceed to containerize and run your EvokePass project:

### Option 1: Using Docker Compose (Recommended)

```powershell
# Navigate to your project
cd c:\project\funproject

# Make sure config.json exists
if (!(Test-Path config.json)) {
    Copy-Item config.example.json config.json
    Write-Host "Created config.json - Please edit it with your settings"
}

# Build and start the containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

### Option 2: Manual Docker Commands

```powershell
# Navigate to your project
cd c:\project\funproject

# Build the image
docker build -t evokepass:latest .

# Run the container
docker run -d `
  --name evokepass `
  -p 3001:3001 `
  -p 3000:3000 `
  -v ${PWD}/config.json:/app/config.json:ro `
  -v ${PWD}/data:/app/data `
  -v ${PWD}/snapshots:/app/snapshots `
  --restart unless-stopped `
  evokepass:latest

# View logs
docker logs -f evokepass

# Stop container
docker stop evokepass
docker rm evokepass
```

### Access Your Application

Once running:
- **Web UI**: http://localhost:3000
- **TCP Server**: localhost:3001 (for access control events)

## Additional Resources

- **Docker Documentation**: https://docs.docker.com/desktop/windows/
- **Docker Getting Started**: https://docs.docker.com/get-started/
- **WSL 2 Setup**: https://docs.microsoft.com/en-us/windows/wsl/install
- **EvokePass Docker Guide**: See `DOCKER.md` in this project

## Common Docker Commands

```powershell
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List images
docker images

# View container logs
docker logs <container-name>

# Stop a container
docker stop <container-name>

# Remove a container
docker rm <container-name>

# Remove an image
docker rmi <image-name>

# Clean up everything (use with caution)
docker system prune -a

# Check Docker disk usage
docker system df
```

## Corporate/Enterprise Environments

If you're in a corporate environment with restrictions:

1. **Request Docker Desktop installation** from your IT department
2. **Provide proxy settings** if behind a corporate proxy
3. **Whitelist Docker repositories**:
   - docker.com
   - docker.io
   - registry-1.docker.io
   - hub.docker.com

4. **Alternative**: Use Docker in a Linux VM if Docker Desktop is restricted

## Summary Checklist

- [ ] Downloaded Docker Desktop
- [ ] Installed Docker Desktop
- [ ] Restarted computer
- [ ] Started Docker Desktop
- [ ] Verified installation with `docker --version`
- [ ] Tested with `docker run hello-world`
- [ ] Configured resources (CPU, Memory)
- [ ] Configured proxy (if applicable)
- [ ] Ready to run EvokePass with Docker!

---

**Need help?** Check the troubleshooting section above or visit the Docker documentation.
