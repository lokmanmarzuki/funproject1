# Test XML event with CARDNO field
$xmlEvent = @"
<Event>
  <ETYPE>1</ETYPE>
  <TRDESC>Access Granted</TRDESC>
  <STAFFNAME>SIVAVENAYAKAM A/L VELAYUTHAM</STAFFNAME>
  <STAFFNO>20-05</STAFFNO>
  <CARDNO>12345678</CARDNO>
  <DEVNAME>Barrier GateIN</DEVNAME>
  <TRDATE>20251102</TRDATE>
  <TRTIME>143000</TRTIME>
</Event>
"@

Write-Host "Sending test event to TCP server at localhost:3001..." -ForegroundColor Yellow
Write-Host "Event: Access Granted for SIVAVENAYAKAM A/L VELAYUTHAM (Card: 12345678)" -ForegroundColor Cyan

$client = New-Object System.Net.Sockets.TcpClient
try {
    $client.Connect("localhost", 3001)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    
    $writer.WriteLine($xmlEvent)
    $writer.Flush()
    
    Write-Host "Event sent successfully!" -ForegroundColor Green
    Write-Host "Check the dashboard at http://localhost:3000" -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 500
}
catch {
    Write-Host "Failed to send event: $_" -ForegroundColor Red
}
finally {
    $writer.Close()
    $stream.Close()
    $client.Close()
}
