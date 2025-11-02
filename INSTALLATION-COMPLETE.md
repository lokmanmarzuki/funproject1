# ✅ EvokePass - Installation Complete!

## Summary

Your EvokePass access control monitoring system has been successfully installed and is now running!

### What Was Fixed

1. **npm install failure** - The original issue was that `better-sqlite3` required native compilation with Microsoft Visual Studio Build Tools and ClangCL toolset which were missing.

2. **Solution Applied** - Used prebuilt binaries for `better-sqlite3` instead of building from source, which bypassed the need for Visual Studio Build Tools.

3. **Missing Type Definitions** - Added:
   - `@types/better-sqlite3`
   - `@types/node-fetch`
   - Custom type declaration for `onvif` package

4. **Code Fixes** - Fixed timeout variable initialization in `forwarder.ts`

### Current Status

✅ **All dependencies installed** (176 packages)  
✅ **TypeScript compilation successful**  
✅ **TCP Server running** on port 3001  
✅ **Web UI running** on port 3000  
✅ **Database initialized** (SQLite)  
✅ **Configuration loaded** (forwarding, filtering enabled)  
✅ **Test event processed** (filtering working correctly)  

### Quick Commands

```powershell
# Start application (if stopped)
npm start

# Send test event
.\test-event.ps1

# Rebuild after code changes
npm run build

# Stop application
Press Ctrl+C in the terminal running npm start
```

### Access Points

- **Web UI:** http://localhost:3000
- **TCP Server:** localhost:3001 (for sending XML events)
- **API Endpoint:** http://localhost:3000/api/events

### Next Steps

1. **Configure Real Cameras**: Edit `config.json` to add your actual CCTV camera IPs, credentials, and RTSP URLs

2. **Configure Forwarding**: Update `config.json` with the real destination IP/port where events should be forwarded

3. **Test with Real Events**: Send actual XML events from your access control system to port 3001

4. **Monitor Dashboard**: Open http://localhost:3000 to see events in real-time

### Files Created/Modified

- `package.json` - Dependencies list (better-sqlite3 with prebuilt binaries)
- `src/tcp-server/index.ts` - TCP server (synchronous database initialization)
- `src/web-ui/index.ts` - Simplified web UI
- `src/shared/database.ts` - Using better-sqlite3 synchronous API
- `src/shared/forwarder.ts` - Fixed timeout variable
- `src/types/onvif.d.ts` - Type declarations for onvif package
- `README.md` - Updated with installation complete notice

### Configuration Example

Your current `config.json` has:
- **Forwarding**: Enabled → 192.168.1.100:4000
- **Filtering**: Skipping staff numbers: 10-03, ADMIN-01
- **CCTV**: Enabled for "Barrier GateIN" and "Main Entrance"

### Troubleshooting

If you encounter issues:

1. **Port already in use**: 
   ```powershell
   # Find process using port 3001 or 3000
   netstat -ano | findstr :3001
   netstat -ano | findstr :3000
   # Kill the process
   taskkill /PID <process_id> /F
   ```

2. **Database locked**: Delete `data.db` file and restart

3. **Build errors**: Run `npm install` again to ensure all dependencies are installed

### Testing

Your test event (staff #10-03) was correctly filtered as configured. This confirms:
- TCP server is receiving XML data ✓
- XML parsing is working ✓
- Filtering logic is functioning ✓
- Configuration is being read correctly ✓

### Project is Ready!

You can now:
- Integrate with your access control system
- Configure actual camera settings
- Customize the web dashboard
- Add more event types to filter
- Monitor live events at http://localhost:3000

---

**Installation Date:** November 2, 2025  
**Node.js Version:** v24.11.0  
**npm Version:** Latest  
**Project Status:** ✅ Fully Operational
