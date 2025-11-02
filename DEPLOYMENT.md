# EvokePass Deployment Guide

## Option 1: Windows Server Deployment (Recommended)

### Prerequisites
- Windows Server 2016/2019/2022
- Node.js LTS (v18 or later)
- Firewall ports 3000 and 3001 open
- Network access to CCTV cameras

### Step-by-Step Deployment

#### 1. Prepare the Server
```powershell
# Install Node.js (download from https://nodejs.org/)
# Verify installation
node --version
npm --version
```

#### 2. Transfer Files
Copy these files/folders to the server (e.g., `C:\EvokePass\`):
```
package.json
package-lock.json
tsconfig.json
config.json
dist/              (compiled JavaScript)
snapshots/         (create empty folder)
```

Or clone/copy entire project and rebuild:
```powershell
# Copy entire project
# Then on server:
cd C:\EvokePass
npm install
npm run build
```

#### 3. Configure for Production

Edit `config.json`:
```json
{
  "tcp": {
    "port": 3001,
    "host": "0.0.0.0"
  },
  "web": {
    "port": 3000,
    "host": "0.0.0.0"
  },
  "forwarding": {
    "enabled": true,
    "destinationHost": "192.168.1.100",
    "destinationPort": 4000,
    "protocol": "tcp",
    "retryAttempts": 3,
    "retryDelay": 1000
  },
  "filtering": {
    "enabled": true,
    "skipStaffNumbers": ["10-03", "ADMIN-01"],
    "skipEventTypes": []
  },
  "cctv": {
    "snapshotPath": "snapshots",
    "timeout": 10000
  }
}
```

#### 4. Configure Windows Firewall
```powershell
# Allow TCP port 3001 (TCP Server)
New-NetFirewallRule -DisplayName "EvokePass TCP Server" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow

# Allow TCP port 3000 (Web UI)
New-NetFirewallRule -DisplayName "EvokePass Web UI" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

#### 5. Run as Windows Service (Recommended)

**Option A: Using NSSM (Non-Sucking Service Manager)**

Download NSSM: https://nssm.cc/download

```powershell
# Install TCP Server Service
nssm install EvokePass-TCP "C:\Program Files\nodejs\node.exe" "C:\EvokePass\dist\tcp-server\index.js"
nssm set EvokePass-TCP AppDirectory "C:\EvokePass"
nssm set EvokePass-TCP DisplayName "EvokePass TCP Server"
nssm set EvokePass-TCP Description "EvokePass Access Control TCP Server"
nssm set EvokePass-TCP Start SERVICE_AUTO_START

# Install Web UI Service
nssm install EvokePass-Web "C:\Program Files\nodejs\node.exe" "C:\EvokePass\dist\web-ui\index.js"
nssm set EvokePass-Web AppDirectory "C:\EvokePass"
nssm set EvokePass-Web DisplayName "EvokePass Web UI"
nssm set EvokePass-Web Description "EvokePass Access Control Web UI"
nssm set EvokePass-Web Start SERVICE_AUTO_START

# Start services
nssm start EvokePass-TCP
nssm start EvokePass-Web

# Check status
nssm status EvokePass-TCP
nssm status EvokePass-Web
```

**Option B: Using PM2**

```powershell
# Install PM2 globally
npm install -g pm2
npm install -g pm2-windows-service

# Configure PM2 as Windows service
pm2-service-install

# Start applications
pm2 start dist/tcp-server/index.js --name evokepass-tcp
pm2 start dist/web-ui/index.js --name evokepass-web

# Save PM2 configuration
pm2 save

# View status
pm2 list
pm2 logs
```

#### 6. Verify Deployment
```powershell
# Check if services are listening
Get-NetTCPConnection -LocalPort 3000,3001 -State Listen

# Test TCP server (from another machine)
Test-NetConnection -ComputerName <server-ip> -Port 3001

# Access Web UI
# http://<server-ip>:3000
```

---

## Option 2: Linux Server Deployment

### Prerequisites
- Ubuntu 20.04/22.04 or similar
- Node.js v18+ and npm
- Nginx (optional, for reverse proxy)

### Deployment Steps

```bash
# 1. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Create deployment directory
sudo mkdir -p /opt/evokepass
sudo chown $USER:$USER /opt/evokepass

# 3. Transfer and build
cd /opt/evokepass
# Copy files or git clone
npm install
npm run build

# 4. Configure firewall
sudo ufw allow 3000/tcp
sudo ufw allow 3001/tcp

# 5. Create systemd services
sudo nano /etc/systemd/system/evokepass-tcp.service
```

```ini
[Unit]
Description=EvokePass TCP Server
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/opt/evokepass
ExecStart=/usr/bin/node /opt/evokepass/dist/tcp-server/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo nano /etc/systemd/system/evokepass-web.service
```

```ini
[Unit]
Description=EvokePass Web UI
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/opt/evokepass
ExecStart=/usr/bin/node /opt/evokepass/dist/web-ui/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable evokepass-tcp
sudo systemctl enable evokepass-web
sudo systemctl start evokepass-tcp
sudo systemctl start evokepass-web

# Check status
sudo systemctl status evokepass-tcp
sudo systemctl status evokepass-web

# View logs
sudo journalctl -u evokepass-tcp -f
sudo journalctl -u evokepass-web -f
```

---

## Option 3: Docker Deployment

### Create Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json tsconfig.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY src/ ./src/

# Build TypeScript
RUN npm run build

# Copy config
COPY config.json ./

# Create snapshots directory
RUN mkdir -p snapshots

# Expose ports
EXPOSE 3000 3001

# Start both services
CMD ["npm", "start"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  evokepass:
    build: .
    ports:
      - "3000:3000"
      - "3001:3001"
    volumes:
      - ./data.db:/app/data.db
      - ./snapshots:/app/snapshots
      - ./config.json:/app/config.json
    restart: unless-stopped
    environment:
      - NODE_ENV=production
```

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## Option 4: Azure/Cloud Deployment

### Azure VM (Windows)
1. Create Windows Server VM in Azure
2. Open NSG ports 3000, 3001
3. Follow Windows Server deployment steps above
4. Configure static public IP
5. Optional: Use Azure Application Gateway for SSL

### Azure Container Instances
```bash
# Build and push to ACR
az acr build --registry myregistry --image evokepass:latest .

# Deploy to ACI
az container create \
  --resource-group myResourceGroup \
  --name evokepass \
  --image myregistry.azurecr.io/evokepass:latest \
  --ports 3000 3001 \
  --dns-name-label evokepass
```

---

## Production Checklist

### Security
- [ ] Change default ports if exposed to internet
- [ ] Use reverse proxy (Nginx/IIS) with SSL certificate
- [ ] Implement authentication for web UI
- [ ] Restrict network access to CCTV cameras
- [ ] Set proper file permissions on data.db and config.json
- [ ] Regular backups of data.db

### Performance
- [ ] Monitor CPU and memory usage
- [ ] Set up log rotation
- [ ] Configure database vacuuming
- [ ] Implement snapshot cleanup policy (delete old images)

### Monitoring
- [ ] Set up health check endpoints
- [ ] Configure alerting for service failures
- [ ] Monitor disk space (SQLite db and snapshots grow over time)
- [ ] Track failed forwarding attempts

### Maintenance
- [ ] Schedule regular SQLite database backups
```powershell
# Backup script (Windows)
$date = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item "C:\EvokePass\data.db" "C:\EvokePass\backups\data_$date.db"
```

---

## Quick Commands Reference

### Windows Service Management (NSSM)
```powershell
nssm status EvokePass-TCP
nssm start EvokePass-TCP
nssm stop EvokePass-TCP
nssm restart EvokePass-TCP
nssm remove EvokePass-TCP confirm
```

### PM2 Management
```powershell
pm2 list                    # List all processes
pm2 logs evokepass-tcp      # View TCP server logs
pm2 logs evokepass-web      # View web UI logs
pm2 restart all             # Restart all
pm2 stop all                # Stop all
pm2 delete all              # Remove all
```

### Linux systemd Management
```bash
sudo systemctl status evokepass-tcp
sudo systemctl start evokepass-tcp
sudo systemctl stop evokepass-tcp
sudo systemctl restart evokepass-tcp
sudo journalctl -u evokepass-tcp -f
```

---

## Troubleshooting

### Service won't start
- Check Node.js is installed: `node --version`
- Verify file paths are correct
- Check port availability: `netstat -ano | findstr "3000\|3001"`
- Review service logs

### Cannot connect to cameras
- Verify network connectivity to camera IPs
- Check ONVIF credentials in door configuration
- Ensure cameras support ONVIF protocol
- Test from server: `Test-NetConnection -ComputerName <camera-ip> -Port 80`

### Database issues
- Ensure write permissions on data.db file
- Check disk space
- Backup and vacuum database if large

### High memory usage
- Review snapshot retention policy
- Implement cleanup script for old images
- Monitor SQLite database size
