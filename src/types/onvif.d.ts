declare module 'onvif' {
  export class Cam {
    constructor(options: any, callback?: (err: any) => void);
    getStreamUri(options: any, callback: (err: any, stream: any) => void): void;
    getSnapshotUri(callback: (err: any, uri: any) => void): void;
  }
}
