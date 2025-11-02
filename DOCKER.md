# Docker Deployment Guide for EvokePass

This guide explains how to package and run the EvokePass Access Control Monitoring System using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, but recommended)

## Quick Start with Docker Compose (Recommended)

### 1. Configure Your Application

First, create your `config.json` file based on `config.example.json`:

```bash
cp config.example.json config.json
```

Edit `config.json` to configure your cameras, forwarding, and filtering settings.

### 2. Build and Run

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### 3. Access the Application

- **Web UI**: http://localhost:3000
- **TCP Server**: localhost:3001

## Manual Docker Commands

If you prefer not to use Docker Compose:

### Build the Image

```bash
docker build -t evokepass:latest .
```

### Run the Container

```bash
docker run -d \
  --name evokepass \
  -p 3001:3001 \
  -p 3000:3000 \
  -v ./config.json:/app/config.json:ro \
  -v ./data:/app/data \
  -v ./snapshots:/app/snapshots \
  -e TZ=Asia/Kuala_Lumpur \
  --restart unless-stopped \
  evokepass:latest
```

### View Logs

```bash
docker logs -f evokepass
```

### Stop the Container

```bash
docker stop evokepass
docker rm evokepass
```

## Volume Mounts Explained

- **`./config.json:/app/config.json:ro`** - Your configuration file (read-only)
- **`./data:/app/data`** - SQLite database persistence
- **`./snapshots:/app/snapshots`** - CCTV snapshot storage

## Environment Variables

You can customize the container behavior with environment variables:

```yaml
environment:
  - NODE_ENV=production
  - TZ=Asia/Kuala_Lumpur  # Your timezone
```

## Health Check

The Docker image includes a health check that verifies the Web UI is responding:

```bash
# Check container health
docker ps

# Manual health check
curl http://localhost:3000/health
```

## Networking

### Connecting to Cameras (ONVIF)

Ensure your Docker container can reach your ONVIF cameras:

1. **Bridge Mode (default)**: Works for most setups. The container can reach any network your host can reach.

2. **Host Mode**: If you have issues, try host networking:
   ```yaml
   network_mode: "host"
   ```

### Receiving TCP Events

The TCP server listens on port 3001. Ensure your access control system can reach:
- `<your-docker-host-ip>:3001`

## Updating the Application

### With Docker Compose

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build
```

### Manual Update

```bash
# Stop and remove old container
docker stop evokepass
docker rm evokepass

# Rebuild image
docker build -t evokepass:latest .

# Run new container
docker run -d ... (same command as above)
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs

# Check if ports are already in use
netstat -ano | findstr :3000
netstat -ano | findstr :3001
```

### Can't Connect to Cameras

1. Check network connectivity from container:
   ```bash
   docker exec -it evokepass ping <camera-ip>
   ```

2. Verify ONVIF credentials in `config.json`

3. Try host networking mode if bridge mode doesn't work

### Database Issues

If you encounter database corruption:

```bash
# Stop container
docker-compose down

# Backup and remove database
mv data/events.db data/events.db.backup

# Restart container (will create new database)
docker-compose up -d
```

## Production Deployment

### Use Docker Compose Override

Create `docker-compose.override.yml` for production settings:

```yaml
version: '3.8'

services:
  evokepass:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "5"
```

### Behind a Reverse Proxy (nginx)

```nginx
server {
    listen 80;
    server_name evokepass.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Enable HTTPS

Use a reverse proxy with SSL/TLS (nginx + Let's Encrypt) or place the container behind a load balancer with SSL termination.

## Backup Strategy

### Database Backup

```bash
# Create backup
docker exec evokepass sqlite3 /app/data/events.db ".backup '/app/data/backup.db'"

# Copy backup out of container
docker cp evokepass:/app/data/backup.db ./backup-$(date +%Y%m%d).db
```

### Automated Backups

Add to crontab:

```bash
# Daily backup at 2 AM
0 2 * * * docker exec evokepass sqlite3 /app/data/events.db ".backup '/app/data/backup.db'" && docker cp evokepass:/app/data/backup.db /backups/evokepass-$(date +\%Y\%m\%d).db
```

## Multi-Container Setup (Advanced)

For high availability, you can separate the TCP server and Web UI:

```yaml
version: '3.8'

services:
  tcp-server:
    build: .
    command: npm run start:tcp
    ports:
      - "3001:3001"
    volumes:
      - ./config.json:/app/config.json:ro
      - db-data:/app/data
      - ./snapshots:/app/snapshots

  web-ui:
    build: .
    command: npm run start:web
    ports:
      - "3000:3000"
    volumes:
      - ./config.json:/app/config.json:ro
      - db-data:/app/data
    depends_on:
      - tcp-server

volumes:
  db-data:
```

## Security Considerations

1. **Read-only config**: Mount `config.json` as read-only (`:ro`)
2. **Non-root user**: Consider adding a non-root user in the Dockerfile
3. **Network isolation**: Use Docker networks to isolate containers
4. **Secrets management**: For production, use Docker secrets instead of config files
5. **Regular updates**: Keep base image and dependencies updated

## Monitoring

### Check Resource Usage

```bash
docker stats evokepass
```

### Log Monitoring

```bash
# Follow logs
docker-compose logs -f

# Search logs
docker-compose logs | grep "error"
```

### Integration with Monitoring Tools

The health check endpoint can be monitored by tools like:
- Prometheus
- Grafana
- Uptime Kuma
- Nagios

Example Prometheus scrape config:
```yaml
scrape_configs:
  - job_name: 'evokepass'
    static_configs:
      - targets: ['localhost:3000']
```
