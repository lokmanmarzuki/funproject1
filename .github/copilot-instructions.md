- [x] Verify that the copilot-instructions.md file in the .github directory is created.
- [x] Clarify Project Requirements - TypeScript/Node.js multi-module project
- [x] Scaffold the Project - Created TCP server and Web UI modules
- [x] Customize the Project - Implemented both modules with XML parsing and access control event display
- [x] Install Required Extensions - No specific extensions required
- [x] Compile the Project - TypeScript configuration ready
- [x] Create and Run Task - npm scripts configured
- [x] Launch the Project - Ready to start with npm commands
- [x] Ensure Documentation is Complete - README.md updated with XML format

## Project: EvokePass - Access Control Monitoring System

Multi-module system with:
- Module 1: TCP server (port 3001) - receives XML access control events and stores in SQLite
- Module 2: Web UI (port 3000) - displays events with visual indicators for violations

### Features
- ✅ Event Forwarding - Forward events to another destination IP/port (TCP or HTTP)
- ✅ Staff Filtering - Skip/filter events by staff number
- ✅ Event Type Filtering - Skip events by type code
- ✅ CCTV Integration - Capture snapshots from ONVIF cameras automatically
- ✅ Live Stream Links - Direct links to view camera streams
- ✅ Auto-retry - Configurable retry mechanism for forwarding
- ✅ JSON Configuration - Easy configuration via config.json

### XML Event Format
The system processes access control events in XML format:
- ETYPE: Event type code
- TRDESC: Transaction description (e.g., "Antipassback Violation", "Access Granted")
- STAFFNAME: Employee/staff full name
- STAFFNO: Staff number/ID
- DEVNAME: Device name (e.g., "Barrier GateIN")
- TRDATE: Transaction date (YYYYMMDD)
- TRTIME: Transaction time (HHMMSS)

### Configuration (config.json)
Edit config.json to:
- Set destination IP and port for forwarding
- Enable/disable forwarding
- Add staff numbers to filter/skip
- Configure retry attempts and timeouts
- Choose TCP or HTTP forwarding protocol
- Configure CCTV cameras by device name
- Set ONVIF credentials and stream URLs

## Next Steps

### ⚠️ CRITICAL: Node.js is NOT installed!

**You must install Node.js before you can run this project.**

**Step-by-step installation:**

1. **Download Node.js**
   - Visit: https://nodejs.org/
   - Download the LTS version (Long Term Support)
   - Choose the Windows Installer (.msi)

2. **Install Node.js**
   - Run the downloaded .msi file
   - Follow the installation wizard
   - ✅ Ensure "Add to PATH" is checked
   - Complete the installation

3. **RESTART VS Code**
   - This is REQUIRED for PATH changes to take effect
   - Close VS Code completely
   - Reopen VS Code

4. **Verify Installation**
   - Open a new PowerShell terminal in VS Code
   - Type: `node --version`
   - Type: `npm --version`
   - Both should show version numbers

5. **Configure Proxy (if behind corporate proxy):**
   - If `npm install` fails due to proxy, see **PROXY-SETUP.md**
   - Configure npm proxy settings:
     ```powershell
     npm config set proxy http://your-proxy:port
     npm config set https-proxy http://your-proxy:port
     npm config set strict-ssl false  # Only if needed
     ```

6. **Then proceed with project setup:**
   ```powershell
   npm install              # Install dependencies
   npm run build            # Compile TypeScript
   # Edit config.json to configure cameras, forwarding, filtering
   npm start                # Start both modules
   .\test-event.ps1         # Send test event
   ```

See README.md for complete documentation.
See PROXY-SETUP.md if npm install fails due to proxy.
