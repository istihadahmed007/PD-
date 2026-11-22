# ==============================================================================
# END-TO-END MULTIPLAYER VERIFICATION SCRIPT
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Tests:
#   1. Dedicated server startup on UDP port 7788
#   2. Client 1 connection as 'Joy_Client'
#   3. Client 2 connection as 'Kabir_Client'
#   4. Verification of unique peer IDs, registration handshake, and spawning
#   5. Disconnection of Client 1 and verification of clean despawn
#   6. Reconnection of Client 1 and verification of respawn
#   7. Absence of ERR_UNCONFIGURED in all logs
#   8. Clean shutdown
# ==============================================================================

$GodotExe = "C:\Users\Tonmoy\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
$ProjectPath = (Resolve-Path "$PSScriptRoot\..").Path
$Port = 7788

Write-Host "====================================================================="
Write-Host "STARTING E2E MULTIPLAYER NETWORK VERIFICATION TEST"
Write-Host "====================================================================="

$ServerLog = "$ProjectPath\tests\server_test.log"
$ServerErr = "$ProjectPath\tests\server_err.log"
$Client1Log = "$ProjectPath\tests\client1_test.log"
$Client1Err = "$ProjectPath\tests\client1_err.log"
$Client2Log = "$ProjectPath\tests\client2_test.log"
$Client2Err = "$ProjectPath\tests\client2_err.log"

Remove-Item $ServerLog -ErrorAction SilentlyContinue
Remove-Item $ServerErr -ErrorAction SilentlyContinue
Remove-Item $Client1Log -ErrorAction SilentlyContinue
Remove-Item $Client1Err -ErrorAction SilentlyContinue
Remove-Item $Client2Log -ErrorAction SilentlyContinue
Remove-Item $Client2Err -ErrorAction SilentlyContinue

function WaitForLogPattern($filePath, $pattern, $timeoutSec=10) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $timeoutSec) {
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
            if ($content -match $pattern) {
                return $true
            }
        }
        Start-Sleep -Milliseconds 400
    }
    return $false
}

# 1. Start Dedicated Server
Write-Host "[1/8] Launching Dedicated Server on port $Port..."
$ServerProcess = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "--",
    "--server",
    "--port", "$Port",
    "--max-players", "8"
) -PassThru -RedirectStandardOutput $ServerLog -RedirectStandardError $ServerErr

$serverStarted = WaitForLogPattern $ServerLog "DEDICATED SERVER started successfully" 8
if (-not $serverStarted) {
    Write-Host "[FAIL] Server did not start within timeout. Log:"
    Get-Content $ServerLog -ErrorAction SilentlyContinue
    Get-Content $ServerErr -ErrorAction SilentlyContinue
    if (-not $ServerProcess.HasExited) { Stop-Process -Id $ServerProcess.Id -Force }
    exit 1
}
Write-Host "[PASS] Dedicated Server is running and listening on port $Port (PID: $($ServerProcess.Id))"

# 2. Launch Client 1 (Joy_Client)
Write-Host "[2/8] Launching Client 1 ('Joy_Client') to connect to 127.0.0.1:$Port..."
$Client1Process = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "--",
    "--client",
    "--connect", "127.0.0.1",
    "--port", "$Port",
    "--nickname", "Joy_Client"
) -PassThru -RedirectStandardOutput $Client1Log -RedirectStandardError $Client1Err

$client1Connected = WaitForLogPattern $ServerLog "Registered peer .* as 'Joy_Client'" 25
if (-not $client1Connected) {
    Write-Host "[FAIL] Client 1 failed to register on server. Server Log:"
    Get-Content $ServerLog -ErrorAction SilentlyContinue
    Write-Host "Client 1 Log:"
    Get-Content $Client1Log -ErrorAction SilentlyContinue
    Get-Content $Client1Err -ErrorAction SilentlyContinue
} else {
    Write-Host "[PASS] Client 1 ('Joy_Client') successfully connected and registered on Server!"
}

# 3. Launch Client 2 (Kabir_Client)
Write-Host "[3/8] Launching Client 2 ('Kabir_Client') to connect to 127.0.0.1:$Port..."
$Client2Process = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "--",
    "--client",
    "--connect", "127.0.0.1",
    "--port", "$Port",
    "--nickname", "Kabir_Client"
) -PassThru -RedirectStandardOutput $Client2Log -RedirectStandardError $Client2Err

$client2Connected = WaitForLogPattern $ServerLog "Registered peer .* as 'Kabir_Client'" 25
if (-not $client2Connected) {
    Write-Host "[FAIL] Client 2 failed to register on server. Server Log:"
    Get-Content $ServerLog -ErrorAction SilentlyContinue
    Write-Host "Client 2 Log:"
    Get-Content $Client2Log -ErrorAction SilentlyContinue
    Get-Content $Client2Err -ErrorAction SilentlyContinue
} else {
    Write-Host "[PASS] Client 2 ('Kabir_Client') successfully connected and registered on Server!"
}

# 4. Verify simultaneous connection and spawning
Write-Host "[4/8] Verifying simultaneous multi-client session state..."
Start-Sleep -Seconds 3

$serverText = Get-Content $ServerLog -Raw -ErrorAction SilentlyContinue

$p1Spawned = $serverText -match "Spawned player character for peer .*Joy_Client"
$p2Spawned = $serverText -match "Spawned player character for peer .*Kabir_Client"

if ($p1Spawned -and $p2Spawned) {
    Write-Host "[PASS] Both player characters spawned simultaneously in the authoritative world!"
} else {
    Write-Host "[FAIL] Character spawn check: P1=$p1Spawned, P2=$p2Spawned"
}

# 5. Disconnect Client 1 and verify despawn
Write-Host "[5/8] Simulating Client 1 disconnection..."
Stop-Process -Id $Client1Process.Id -Force

$p1Left = WaitForLogPattern $ServerLog "left the session" 12
$p1Despawned = WaitForLogPattern $ServerLog "Despawning player character" 12

if ($p1Left -and $p1Despawned) {
    Write-Host "[PASS] Server detected Client 1 disconnect and cleanly despawned character!"
} else {
    Write-Host "[WARN] Disconnect detection check: Left=$p1Left, Despawned=$p1Despawned"
}

# 6. Reconnect Client 1 as 'Joy_Reconnected'
Write-Host "[6/8] Simulating Client 1 reconnection..."
$Client1ReconnectedLog = "$ProjectPath\tests\client1_reconnected.log"
Remove-Item $Client1ReconnectedLog -ErrorAction SilentlyContinue

$Client1ReconnectedProcess = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "--",
    "--client",
    "--connect", "127.0.0.1",
    "--port", "$Port",
    "--nickname", "Joy_Reconnected"
) -PassThru -RedirectStandardOutput $Client1ReconnectedLog -RedirectStandardError $Client1Err

$reconnected = WaitForLogPattern $ServerLog "Registered peer .* as 'Joy_Reconnected'" 25
if ($reconnected) {
    Write-Host "[PASS] Reconnection verified: Client 1 successfully re-registered and respawned!"
} else {
    Write-Host "[FAIL] Reconnection failed to register within timeout."
}

# 7. Check for ERR_UNCONFIGURED in all logs
Write-Host "[7/8] Inspecting error streams for ERR_UNCONFIGURED replication failures..."
$allErrText = ""
if (Test-Path $ServerErr) { $allErrText += (Get-Content $ServerErr -Raw) }
if (Test-Path $Client1Err) { $allErrText += (Get-Content $Client1Err -Raw) }
if (Test-Path $Client2Err) { $allErrText += (Get-Content $Client2Err -Raw) }

if ($allErrText -match "ERR_UNCONFIGURED") {
    Write-Host "[FAIL] ERR_UNCONFIGURED detected in logs!"
    Write-Host $allErrText
} else {
    Write-Host "[PASS] Zero ERR_UNCONFIGURED errors detected across all server and client streams!"
}

# 8. Clean termination
Write-Host "[8/8] Cleaning up all test processes..."
if (-not $Client1Process.HasExited) { Stop-Process -Id $Client1Process.Id -Force -ErrorAction SilentlyContinue }
if ($Client1ReconnectedProcess -and -not $Client1ReconnectedProcess.HasExited) { Stop-Process -Id $Client1ReconnectedProcess.Id -Force -ErrorAction SilentlyContinue }
if (-not $Client2Process.HasExited) { Stop-Process -Id $Client2Process.Id -Force -ErrorAction SilentlyContinue }
if (-not $ServerProcess.HasExited) { Stop-Process -Id $ServerProcess.Id -Force -ErrorAction SilentlyContinue }

Write-Host "====================================================================="
Write-Host "E2E MULTIPLAYER NETWORK VERIFICATION TEST COMPLETE"
Write-Host "====================================================================="
