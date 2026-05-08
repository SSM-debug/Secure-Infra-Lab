# Secure-Infra-Lab — Host Verification Script
# Run from Windows: .\scripts\verify_host.ps1

$PASS = 0
$FAIL = 0

function Check {
    param($desc, $result, $expected)
    if ($result -match $expected) {
        Write-Host "PASS: $desc" -ForegroundColor Green
        $script:PASS++
    } else {
        Write-Host "FAIL: $desc (got: $result)" -ForegroundColor Red
        $script:FAIL++
    }
}

Write-Host "=============================="
Write-Host " Secure-Infra-Lab Verify Host"
Write-Host "=============================="

# Test 1 — nginx svarar via port forwarding
$r = try { (Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 5).StatusCode } catch { "failed" }
Check "nginx responds on localhost:8080" $r "200"

# Test 2 & 3 — Round-robin — båda servrarna svarar
$r1 = try { (Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing).Content } catch { "failed" }
$r2 = try { (Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing).Content } catch { "failed" }
$combined = "$r1 $r2"
Check "Round-robin includes Server 1" $combined "Server 1"
Check "Round-robin includes Server 2" $combined "Server 2"

# Test 4 — /visit fungerar
$r = try { (Invoke-WebRequest -Uri "http://localhost:8080/visit" -UseBasicParsing).Content } catch { "failed" }
Check "/visit registers a visit" $r "Visit registered"

# Test 5 — Cockpit svarar på port 9090
$tcp = New-Object System.Net.Sockets.TcpClient
$result = $tcp.ConnectAsync("127.0.0.1", 9090).Wait(3000)
Check "Cockpit responding on port 9090" $(if($result){"200"}else{"failed"}) "200"

# Test 6 — database port EJ nåbar från Windows
$r = try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.ConnectAsync("192.168.56.14", 5432).Wait(2000)
    if ($tcp.Connected) { "connected" } else { "blocked" }
} catch { "blocked" }
Check "database:5432 blocked from host" $r "blocked"

Write-Host "=============================="
Write-Host " Results: PASS=$PASS FAIL=$FAIL"
Write-Host "=============================="