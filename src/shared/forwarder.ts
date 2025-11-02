import * as net from 'net';
import * as http from 'http';
import { configManager } from './config';

export interface ForwardingResult {
  success: boolean;
  message?: string;
  error?: string;
}

export class EventForwarder {
  private static instance: EventForwarder;

  private constructor() {}

  public static getInstance(): EventForwarder {
    if (!EventForwarder.instance) {
      EventForwarder.instance = new EventForwarder();
    }
    return EventForwarder.instance;
  }

  public async forwardEvent(xmlData: string): Promise<ForwardingResult> {
    const config = configManager.getForwardingConfig();
    const logging = configManager.getLoggingConfig();

    if (!config.enabled) {
      return { success: true, message: 'Forwarding disabled' };
    }

    if (config.protocol === 'tcp') {
      return this.forwardViaTCP(xmlData, config, logging);
    } else {
      return this.forwardViaHTTP(xmlData, config, logging);
    }
  }

  private forwardViaTCP(
    xmlData: string,
    config: any,
    logging: any
  ): Promise<ForwardingResult> {
    return new Promise((resolve) => {
      let attempts = 0;
      const maxAttempts = config.retryAttempts || 1;

      const attemptConnection = () => {
        attempts++;
        
        const client = new net.Socket();
        let timeoutId: NodeJS.Timeout | undefined = undefined;

        client.setTimeout(config.timeout || 5000);

        client.connect(config.destinationPort, config.destinationHost, () => {
          if (logging.logForwarding) {
            console.log(`Forwarding event to ${config.destinationHost}:${config.destinationPort}`);
          }
          client.write(xmlData);
          client.end();
        });

        client.on('data', (data) => {
          if (logging.logForwarding) {
            console.log('Forwarding response:', data.toString());
          }
        });

        client.on('close', () => {
          if (timeoutId) clearTimeout(timeoutId);
          resolve({ success: true, message: 'Event forwarded successfully' });
        });

        client.on('timeout', () => {
          client.destroy();
          if (attempts < maxAttempts) {
            console.log(`Forwarding timeout, retrying... (${attempts}/${maxAttempts})`);
            setTimeout(attemptConnection, 1000);
          } else {
            resolve({ 
              success: false, 
              error: `Forwarding timeout after ${attempts} attempts` 
            });
          }
        });

        client.on('error', (err: Error) => {
          client.destroy();
          if (attempts < maxAttempts) {
            console.log(`Forwarding error: ${err.message}, retrying... (${attempts}/${maxAttempts})`);
            setTimeout(attemptConnection, 1000);
          } else {
            resolve({ 
              success: false, 
              error: `Forwarding failed after ${attempts} attempts: ${err.message}` 
            });
          }
        });
      };

      attemptConnection();
    });
  }

  private forwardViaHTTP(
    xmlData: string,
    config: any,
    logging: any
  ): Promise<ForwardingResult> {
    return new Promise((resolve) => {
      const postData = xmlData;

      const options = {
        hostname: config.destinationHost,
        port: config.destinationPort,
        path: '/events',
        method: 'POST',
        headers: {
          'Content-Type': 'application/xml',
          'Content-Length': Buffer.byteLength(postData)
        },
        timeout: config.timeout || 5000
      };

      const req = http.request(options, (res) => {
        let responseData = '';

        res.on('data', (chunk) => {
          responseData += chunk;
        });

        res.on('end', () => {
          if (logging.logForwarding) {
            console.log(`HTTP forwarding response: ${res.statusCode}`);
          }
          resolve({ 
            success: res.statusCode! >= 200 && res.statusCode! < 300,
            message: `HTTP ${res.statusCode}: ${responseData}` 
          });
        });
      });

      req.on('error', (err: Error) => {
        resolve({ success: false, error: `HTTP forwarding error: ${err.message}` });
      });

      req.on('timeout', () => {
        req.destroy();
        resolve({ success: false, error: 'HTTP forwarding timeout' });
      });

      req.write(postData);
      req.end();
    });
  }
}

export const eventForwarder = EventForwarder.getInstance();
