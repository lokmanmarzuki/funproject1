# PowerShell script to send test XML event to EvokePass TCP server

$xml = @"
<?xml version="1.0"?>
<Event>
  <ETYPE>0</ETYPE>
  <TRDESC>Antipassback Violation</TRDESC>
  <STAFFNAME>SIVAVENAYAKAM A/L VELAYUTHAM</STAFFNAME>
  <STAFFNO>10-04</STAFFNO>
  <DEVNAME>Barrier GateIN</DEVNAME>
  <TRDATE>20250923</TRDATE>
  <TRTIME>195306</TRTIME>
</Event>
"@

Write-Host "Sending XML event to TCP server on localhost:3001..." -ForegroundColor Cyan

try {
    $client = New-Object System.Net.Sockets.TcpClient("localhost", 3001)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $reader = New-Object System.IO.StreamReader($stream)
    
    $writer.WriteLine($xml)
    $writer.Flush()
    
    # Wait for response
    Start-Sleep -Milliseconds 500
    if ($stream.DataAvailable) {
        $response = $reader.ReadLine()
        Write-Host "Response: $response" -ForegroundColor Green
    }
    
    $writer.Close()
    $reader.Close()
    $stream.Close()
    $client.Close()
    
    Write-Host "Event sent successfully!" -ForegroundColor Green
    Write-Host "Check http://localhost:3000 to view the event" -ForegroundColor Yellow
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Make sure the TCP server is running (npm start)" -ForegroundColor Yellow
}
