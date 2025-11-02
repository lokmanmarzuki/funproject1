import { Cam } from 'onvif';
import * as fs from 'fs';
import * as path from 'path';
import fetch from 'node-fetch';
import { configManager, CameraConfig } from './config';

export interface SnapshotResult {
  success: boolean;
  imagePath?: string;
  streamUrl?: string;
  error?: string;
}

export class CCTVService {
  private static instance: CCTVService;
  private snapshotDir: string;

  private constructor() {
    const cctvConfig = configManager.getCCTVConfig();
    this.snapshotDir = cctvConfig.snapshotPath || './snapshots';
    this.ensureSnapshotDirectory();
  }

  public static getInstance(): CCTVService {
    if (!CCTVService.instance) {
      CCTVService.instance = new CCTVService();
    }
    return CCTVService.instance;
  }

  private ensureSnapshotDirectory(): void {
    if (!fs.existsSync(this.snapshotDir)) {
      fs.mkdirSync(this.snapshotDir, { recursive: true });
      console.log(`Created snapshot directory: ${this.snapshotDir}`);
    }
  }

  public async captureSnapshot(
    deviceName: string,
    eventId: number
  ): Promise<SnapshotResult> {
    const cctvConfig = configManager.getCCTVConfig();

    if (!cctvConfig.enabled || !cctvConfig.captureSnapshot) {
      return { 
        success: false, 
        error: 'CCTV capture is disabled' 
      };
    }

    const cameraConfig = configManager.getCameraConfig(deviceName);
    if (!cameraConfig) {
      console.log(`No camera configuration found for device: ${deviceName}`);
      return { 
        success: false, 
        error: `No camera configured for device: ${deviceName}` 
      };
    }

    try {
      // Try ONVIF first
      const result = await this.captureViaONVIF(cameraConfig, eventId);
      if (result.success) {
        return result;
      }

      // Fallback to HTTP snapshot
      console.log('ONVIF failed, trying HTTP snapshot...');
      return await this.captureViaHTTP(cameraConfig, eventId);
    } catch (error: any) {
      console.error('Snapshot capture error:', error.message);
      return { 
        success: false, 
        error: error.message,
        streamUrl: cameraConfig.streamUrl 
      };
    }
  }

  private captureViaONVIF(
    cameraConfig: CameraConfig,
    eventId: number
  ): Promise<SnapshotResult> {
    return new Promise((resolve) => {
      const cam = new Cam({
        hostname: cameraConfig.host,
        username: cameraConfig.username,
        password: cameraConfig.password,
        port: cameraConfig.port,
        timeout: 10000
      }, (err: Error) => {
        if (err) {
          resolve({ 
            success: false, 
            error: `ONVIF connection failed: ${err.message}`,
            streamUrl: cameraConfig.streamUrl 
          });
          return;
        }

        cam.getSnapshotUri((err: Error, snapshotUri: any) => {
          if (err || !snapshotUri || !snapshotUri.uri) {
            resolve({ 
              success: false, 
              error: 'Failed to get snapshot URI',
              streamUrl: cameraConfig.streamUrl 
            });
            return;
          }

          const timestamp = Date.now();
          const filename = `event_${eventId}_${timestamp}.jpg`;
          const imagePath = path.join(this.snapshotDir, filename);

          // Download snapshot
          this.downloadImage(snapshotUri.uri, imagePath, cameraConfig)
            .then(() => {
              console.log(`Snapshot saved: ${imagePath}`);
              resolve({ 
                success: true, 
                imagePath: filename,
                streamUrl: cameraConfig.streamUrl 
              });
            })
            .catch((error) => {
              resolve({ 
                success: false, 
                error: `Download failed: ${error.message}`,
                streamUrl: cameraConfig.streamUrl 
              });
            });
        });
      });
    });
  }

  private async captureViaHTTP(
    cameraConfig: CameraConfig,
    eventId: number
  ): Promise<SnapshotResult> {
    // Common HTTP snapshot URLs for IP cameras
    const snapshotUrls = [
      `http://${cameraConfig.host}:${cameraConfig.port}/cgi-bin/snapshot.cgi`,
      `http://${cameraConfig.host}:${cameraConfig.port}/snapshot.jpg`,
      `http://${cameraConfig.host}:${cameraConfig.port}/snap.jpg`,
      `http://${cameraConfig.host}:${cameraConfig.port}/image/jpeg.cgi`
    ];

    for (const url of snapshotUrls) {
      try {
        const timestamp = Date.now();
        const filename = `event_${eventId}_${timestamp}.jpg`;
        const imagePath = path.join(this.snapshotDir, filename);

        const auth = Buffer.from(`${cameraConfig.username}:${cameraConfig.password}`).toString('base64');
        
        const response = await fetch(url, {
          method: 'GET',
          headers: {
            'Authorization': `Basic ${auth}`
          },
          timeout: 5000
        });

        if (response.ok) {
          const buffer = await response.buffer();
          fs.writeFileSync(imagePath, buffer);
          console.log(`HTTP snapshot saved: ${imagePath}`);
          
          return { 
            success: true, 
            imagePath: filename,
            streamUrl: cameraConfig.streamUrl 
          };
        }
      } catch (error) {
        // Try next URL
        continue;
      }
    }

    return { 
      success: false, 
      error: 'All HTTP snapshot URLs failed',
      streamUrl: cameraConfig.streamUrl 
    };
  }

  private async downloadImage(
    uri: string,
    outputPath: string,
    cameraConfig: CameraConfig
  ): Promise<void> {
    const auth = Buffer.from(`${cameraConfig.username}:${cameraConfig.password}`).toString('base64');
    
    const response = await fetch(uri, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${auth}`
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const buffer = await response.buffer();
    fs.writeFileSync(outputPath, buffer);
  }

  public getStreamUrl(deviceName: string): string | undefined {
    const cameraConfig = configManager.getCameraConfig(deviceName);
    return cameraConfig?.streamUrl;
  }
}

export const cctvService = CCTVService.getInstance();
