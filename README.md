# EvokePass

> ✅ **Installation Complete!** The project is successfully installed and running. Both TCP server (port 3001) and Web UI (port 3000) are operational.

Multi-module access control monitoring system with TCP server and Web UI for receiving, filtering, forwarding, and displaying security events.

## Features

- ✅ **TCP Server** - Receives XML access control events on port 3001
- ✅ **Event Forwarding** - Forward events to another destination (TCP/HTTP)
- ✅ **Staff Filtering** - Skip/filter events by staff number or event type
- ✅ **CCTV Integration** - Capture snapshots from ONVIF cameras
- ✅ **Live Stream Links** - Direct links to camera streams for each event
- ✅ **Web Dashboard** - Real-time monitoring with visual indicators and images
- ✅ **SQLite Storage** - Persistent event storage with snapshot paths
- ✅ **Auto-retry** - Configurable retry mechanism for forwarding
- ✅ **Configuration** - JSON-based configuration system

## Project Structure

```
evokepass/
├── src/
│   ├── tcp-server/       # Module 1: TCP server on port 3001
│   │   └── index.ts      # Receives XML events via TCP and stores in DB
│   ├── web-ui/           # Module 2: Web interface
│   │   └── index.ts      # Displays access control events from database
│   └── shared/
│       ├── database.ts   # Shared database manager
│       ├── config.ts     # Configuration manager
│       └── forwarder.ts  # Event forwarding logic
├── dist/                 # Compiled JavaScript output
├── config.json           # Configuration file
├── package.json
├── tsconfig.json
└── README.md
```

## Configuration

The system uses `config.json` for configuration. Edit this file to customize behavior:

```json
{
  "forwarding": {
    "enabled": true,
    "destinationHost": "192.168.1.100",
    "destinationPort": 4000,
    "protocol": "tcp",
    "timeout": 5000,
    "retryAttempts": 3
  },
  "filtering": {
    "enabled": true,
    "skipStaffNumbers": ["10-03", "ADMIN-01"],
    "skipEventTypes": []
  },
  "cctv": {
    "enabled": true,
    "captureSnapshot": true,
    "snapshotPath": "./snapshots",
    "cameras": {
      "Barrier GateIN": {
        "host": "192.168.1.10",
        "port": 80,
        "username": "admin",
        "password": "admin123",
        "streamUrl": "rtsp://192.168.1.10:554/stream1"
      },
      "Main Entrance": {
        "host": "192.168.1.11",
        "port": 80,
        "username": "admin",
        "password": "admin123",
        "streamUrl": "rtsp://192.168.1.11:554/stream1"
      }
    }
  },
  "logging": {
    "logForwarding": true,
    "logFiltering": true
  }
}
```

### Configuration Options

**Forwarding Settings:**
- `enabled` - Enable/disable event forwarding
- `destinationHost` - IP address of destination server
- `destinationPort` - Port number of destination server
- `protocol` - `"tcp"` or `"http"` for forwarding method
- `timeout` - Connection timeout in milliseconds
- `retryAttempts` - Number of retry attempts on failure

**Filtering Settings:**
- `enabled` - Enable/disable filtering
- `skipStaffNumbers` - Array of staff numbers to skip (won't be stored or forwarded)
- `skipEventTypes` - Array of event type codes to skip

**Logging Settings:**
- `logForwarding` - Log forwarding activities
- `logFiltering` - Log filtering actions

**CCTV Settings:**
- `enabled` - Enable/disable CCTV integration
- `captureSnapshot` - Automatically capture snapshots on events
- `snapshotPath` - Directory to store snapshot images
- `cameras` - Camera configurations by device name:
  - `host` - Camera IP address
  - `port` - Camera port (usually 80)
  - `username` - Camera login username
  - `password` - Camera login password
  - `streamUrl` - RTSP stream URL for live viewing

**Note:** Camera device names must match the `DEVNAME` field in XML events

## Prerequisites

Before running this project, you must install Node.js:

### ⚠️ IMPORTANT: Install Node.js First

**Node.js is required but NOT currently installed on your system.**

1. **Download Node.js:**
   - Go to https://nodejs.org/
   - Download the **LTS version** (recommended)
   - For Windows: Download the `.msi` installer

2. **Install Node.js:**
   - Run the downloaded installer
   - Accept the license agreement
   - Use default installation settings
   - ✅ Make sure "Add to PATH" is checked
   - Complete the installation

3. **Verify Installation:**
   - **RESTART VS Code** (important!)
   - Open a new PowerShell terminal
   - Run: `node --version` (should show v18.x.x or higher)
   - Run: `npm --version` (should show version number)

## Installation

### Local Development

After Node.js is installed and VS Code is restarted:

1. **Install dependencies:**
   ```powershell
   npm install
   ```

2. **Build the project:**
   ```powershell
   npm run build
   ```

### Docker Deployment (Recommended)

**Quick Build (Auto-detects Network):**
```powershell
.\build.ps1
```

The script automatically detects if you're on corporate network and applies proxy settings if needed.

**Manual Build Options:**

When **on corporate network** (requires proxy):
```powershell
.\build.ps1 proxy
# Or manually:
$env:HTTP_PROXY="http://proxy-dmz.company.com:912"
$env:HTTPS_PROXY="http://proxy-dmz.company.com:912"
docker-compose up -d --build
```

When **outside corporate network** (no proxy):
```powershell
.\build.ps1 no-proxy
# Or manually:
docker-compose up -d --build
```

**Manage Container:**
```powershell
# View logs
docker logs evokepass --tail 50

# Stop container
docker-compose down

# Restart
docker-compose restart
```

Access the dashboard at **http://localhost:3000** after deployment.

## Usage

### Option 1: Run Both Modules Together (Recommended)

```bash
npm start
```

This starts both the TCP server and Web UI simultaneously.

### Option 2: Run Modules Separately

**Terminal 1 - TCP Server:**
```bash
npm run start:tcp
```

**Terminal 2 - Web UI:**
```bash
npm run start:web
```

### Development Mode (with auto-reload)

```bash
npm run dev
```

Or run individually:
```bash
npm run dev:tcp    # TCP server only
npm run dev:web    # Web UI only
```

## Modules

### Module 1: TCP Server (Port 3001)

- Listens for incoming TCP connections on port 3001
- Receives XML access control event data
- Parses and validates XML format
- **Filters events** based on staff number or event type
- Stores accepted events in SQLite database
- **Forwards events** to configured destination
- Returns acknowledgment to sender (including skip status)

**Event Processing Flow:**
1. Receive XML event
2. Parse and validate
3. Check against filters (skip if matched)
4. Store in database
5. **Capture CCTV snapshot** (if camera configured)
6. Forward to destination (if enabled)
7. Send acknowledgment

**XML Event Format:**
```xml
<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Antipassback Violation</TRDESC>
  <STAFFNAME>SIVAVENAYAKAM A/L VELAYUTHAM</STAFFNAME>
  <STAFFNO>10-03</STAFFNO>
  <DEVNAME>Barrier GateIN</DEVNAME>
  <TRDATE>20250923</TRDATE>
  <TRTIME>145306</TRTIME>
</Event>
```

**Send data example using PowerShell:**
```powershell
# Using Test-NetConnection or custom script
$xml = @"
<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Antipassback Violation</TRDESC>
  <STAFFNAME>SIVAVENAYAKAM A/L VELAYUTHAM</STAFFNAME>
  <STAFFNO>10-03</STAFFNO>
  <DEVNAME>Barrier GateIN</DEVNAME>
  <TRDATE>20250923</TRDATE>
  <TRTIME>145306</TRTIME>
</Event>
"@

$client = New-Object System.Net.Sockets.TcpClient("localhost", 3001)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.WriteLine($xml)
$writer.Flush()
$client.Close()
```

**Using Node.js:**
```javascript
const net = require('net');
const xml = `<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Access Granted</TRDESC>
  <STAFFNAME>John Doe</STAFFNAME>
  <STAFFNO>10-03</STAFFNO>
  <DEVNAME>Main Entrance</DEVNAME>
  <TRDATE>20251102</TRDATE>
  <TRTIME>143000</TRTIME>
</Event>`;

const client = net.connect({ port: 3001 }, () => {
  client.write(xml);
  client.end();
});
```

### Module 2: Web UI (Port 3000)

- Web interface at `http://localhost:3000`
- Displays all access control events from database
- **Shows CCTV snapshots** for each event
- **Live stream links** - Click to open camera stream
- Visual indicators for violations vs normal events
- Auto-refreshes every 5 seconds
- Formatted display with:
  - CCTV snapshot image
  - Event type and description
  - Staff name and ID
  - Device name
  - Date and time
  - Link to live CCTV stream
- REST API endpoints:
  - `GET /api/events` - Get recent events (limit 100)
  - `GET /api/events/all` - Get all events
  - `GET /snapshots/:filename` - Serve snapshot images

## Database

- Uses SQLite database (`data.db`)
- Stores access control event data with timestamps
- Shared between both modules
- Schema:
  ```sql
  CREATE TABLE events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    etype TEXT NOT NULL,
    trdesc TEXT NOT NULL,
    staffname TEXT NOT NULL,
    staffno TEXT NOT NULL,
    devname TEXT NOT NULL,
    trdate TEXT NOT NULL,
    trtime TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    raw_xml TEXT
  );
  ```

## Scripts

- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Run both modules (production)
- `npm run start:tcp` - Run TCP server only
- `npm run start:web` - Run Web UI only
- `npm run dev` - Run both modules in development mode
- `npm run dev:tcp` - Run TCP server in development mode
- `npm run dev:web` - Run Web UI in development mode

## Testing the System

### 1. Start both modules:
```powershell
npm start
```

You'll see the configuration status on startup:
```
TCP server listening on port 3001
Waiting for XML event data...
Forwarding: ENABLED
  Destination: 192.168.1.100:4000
Filtering: ENABLED
  Skipping staff numbers: 10-03, ADMIN-01
```

### 2. Send test XML event to TCP server (PowerShell):
```powershell
$xml = @"
<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Access Granted</TRDESC>
  <STAFFNAME>John Doe</STAFFNAME>
  <STAFFNO>EMP-001</STAFFNO>
  <DEVNAME>Main Entrance</DEVNAME>
  <TRDATE>20251102</TRDATE>
  <TRTIME>143000</TRTIME>
</Event>
"@

$client = New-Object System.Net.Sockets.TcpClient("localhost", 3001)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.WriteLine($xml)
$writer.Flush()
$client.Close()
```

Or use the provided test script:
```powershell
.\test-event.ps1
```

### 3. Test Filtering:
Send an event with a filtered staff number (e.g., "10-03"):
```powershell
# This event will be skipped (not stored or forwarded)
$xml = @"
<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Antipassback Violation</TRDESC>
  <STAFFNAME>SIVAVENAYAKAM A/L VELAYUTHAM</STAFFNAME>
  <STAFFNO>10-03</STAFFNO>
  <DEVNAME>Barrier GateIN</DEVNAME>
  <TRDATE>20250923</TRDATE>
  <TRTIME>145306</TRTIME>
</Event>
"@
# Send using same method as above
```

Server response for filtered event:
```json
{"status":"skipped","reason":"Staff number filtered","staffno":"10-03"}
```

### 4. View events in browser:
- Open `http://localhost:3000`
- You should see the access control events displayed in the dashboard
- Violations will be highlighted in red
- Filtered events won't appear (they're not stored)

## Use Cases

### Scenario 1: Filter Specific Staff Members
Edit `config.json` to skip events from certain staff:
```json
{
  "filtering": {
    "enabled": true,
    "skipStaffNumbers": ["ADMIN-01", "SECURITY-01", "MAINT-05"]
  }
}
```
Events from these staff won't be stored in the database or forwarded.

### Scenario 2: Forward to Multiple Destinations
To forward events to another system for processing:
```json
{
  "forwarding": {
    "enabled": true,
    "destinationHost": "10.0.0.50",
    "destinationPort": 5000,
    "protocol": "tcp",
    "retryAttempts": 3
  }
}
```

### Scenario 3: HTTP API Integration
Forward events via HTTP POST:
```json
{
  "forwarding": {
    "enabled": true,
    "destinationHost": "api.example.com",
    "destinationPort": 443,
    "protocol": "http"
  }
}
```

## Viewing RTSP Camera Streams

The dashboard displays **📹 Live** buttons for events that have associated camera stream URLs. RTSP (Real Time Streaming Protocol) streams cannot be viewed directly in web browsers and require a media player.

### How to View RTSP Streams:

**Option 1: VLC Media Player (Recommended)**
1. Download VLC from https://www.videolan.org/
2. Click the **📹 Live** button in the dashboard
3. Copy the RTSP URL (e.g., `rtsp://192.168.1.10:554/stream1`)
4. Open VLC → Media → Open Network Stream
5. Paste the RTSP URL and click Play

**Option 2: FFmpeg (Command Line)**
```powershell
ffplay rtsp://192.168.1.10:554/stream1
```

**Option 3: Windows Media Player**
- Some RTSP streams may work with File → Open URL

### Testing Camera Snapshots:

The Door Config page includes a **📸 Test** button for each configured camera:
1. Go to `http://localhost:3000/config/doors`
2. Click **📸 Test** next to any door/camera
3. The system will attempt to capture a snapshot and open it
4. Check the alert message for stream URL and snapshot status

### Camera Configuration:

Configure cameras in the Door Config page or `config.json`:
- **Camera IP**: IP address of the ONVIF/RTSP camera
- **Port**: Usually 80 for ONVIF, 554 for RTSP
- **Username/Password**: Camera credentials
- **Stream URL**: Full RTSP URL (e.g., `rtsp://192.168.1.10:554/stream1`)
- **ONVIF Enabled**: Enable for automatic snapshot capture

**Note:** Stream URLs are stored with each event and displayed in the dashboard for quick access to live camera feeds.

## Troubleshooting

- **Port already in use:** Make sure ports 3000 and 3001 are available
- **npm command not found:** Install Node.js from https://nodejs.org/
- **Connection refused:** Ensure the TCP server is running before sending data
- **XML parsing error:** Ensure XML is well-formed and contains all required fields
- **Database locked:** Only one process can write at a time; this is normal for SQLite
- **Forwarding fails:** Check destination IP/port is reachable and accepting connections
- **Events not filtered:** Verify `config.json` has correct staff numbers and filtering is enabled
- **Config not loading:** Ensure `config.json` is valid JSON and in the project root directory

## API Endpoints

**Web UI Server (Port 3000):**
- `GET /` - Web dashboard
- `GET /api/events?limit=100` - Get recent events (default 100)
- `GET /api/events/all` - Get all events

**TCP Server (Port 3001):**
- Accepts XML event data
- Returns JSON acknowledgment:
  ```json
  {"status":"success","id":1,"event":"Access Granted","forwarded":true}
  {"status":"skipped","reason":"Staff number filtered","staffno":"10-03"}
  {"status":"error","message":"Invalid XML format"}
  ```

## License

ISC
