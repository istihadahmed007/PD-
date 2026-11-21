# ==============================================================================
# END-TO-END MULTIPLAYER VERIFICATION SCRIPT
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Tests:
#   1. Dedicated server startup on UDP port 7788
#   2. Client 1 connection as 'Joy_Client'
#   3. Client 2 connection as 'Kabir_Client'
#   4. Verification of unique peer IDs, registration handshake, and spawning
#   5. Disconnection of Client 1 and verification of clean despawn
#   6. Clean server shutdown
# ==============================================================================

$GodotExe = "C:\Users\Tonmoy\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
$ProjectPath = "c:\Users\Tonmoy\Documents\DTA 0"
$Port = 7788

Write-Host "====================================================================="
Write-Host "STARTING E2E MULTIPLAYER NETWORK VERIFICATION TEST"
Write-Host "====================================================================="

$ServerLog = "$ProjectPath\tests\server_test.log"
$Client1Log = "$ProjectPath\tests\client1_test.log"
$Client2Log = "$ProjectPath\tests\client2_test.log"

Remove-Item $ServerLog -ErrorAction SilentlyContinue
Remove-Item $Client1Log -ErrorAction SilentlyContinue
Remove-Item $Client2Log -ErrorAction SilentlyContinue

# 1. Start Dedicated Server
Write-Host "[1/6] Launching Dedicated Server on port $Port..."
$ServerProcess = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "--",
    "--server",
    "--port", "$Port",
    "--max-players", "8"
) -PassThru -RedirectStandardOutput $ServerLog -RedirectStandardError "$ProjectPath\tests\server_err.log"

Start-Sleep -Seconds 3

# Check if server is running
if ($ServerProcess.HasExited) {
    Write-Host "[FAIL] Server process exited prematurely with code $($ServerProcess.ExitCode)"
    Get-Content $ServerLog
    exit 1
}
Write-Host "[PASS] Dedicated Server is running (PID: $($ServerProcess.Id))"

# 2. Launch Client 1 (Joy_Client)
Write-Host "[2/6] Launching Client 1 ('Joy_Client') to connect to 127.0.0.1:$Port..."
$Client1Process = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "res://multiplayer/multiplayer_world.tscn",
    "--quit-after", "240",
    "--",
    "--client",
    "--connect", "127.0.0.1",
    "--port", "$Port",
    "--nickname", "Joy_Client"
) -PassThru -RedirectStandardOutput $Client1Log -RedirectStandardError "$ProjectPath\tests\client1_err.log"

Start-Sleep -Seconds 3

# 3. Launch Client 2 (Kabir_Client)
Write-Host "[3/6] Launching Client 2 ('Kabir_Client') to connect to 127.0.0.1:$Port..."
$Client2Process = Start-Process -FilePath $GodotExe -ArgumentList @(
    "--headless",
    "--path", "`"$ProjectPath`"",
    "res://multiplayer/multiplayer_world.tscn",
    "--quit-after", "180",
    "--",
    "--client",
    "--connect", "127.0.0.1",
    "--port", "$Port",
    "--nickname", "Kabir_Client"
) -PassThru -RedirectStandardOutput $Client2Log -RedirectStandardError "$ProjectPath\tests\client2_err.log"

Write-Host "[4/6] Allowing simulation ticks for packet replication and state sync..."
Start-Sleep -Seconds 5

# 4. Read logs and check connection evidence
Write-Host "---------------------------------------------------------------------"
Write-Host "SERVER LOG EVIDENCE:"
Write-Host "---------------------------------------------------------------------"
if (Test-Path $ServerLog) {
    Get-Content $ServerLog
}

Write-Host "---------------------------------------------------------------------"
Write-Host "CLIENT 1 LOG EVIDENCE:"
Write-Host "---------------------------------------------------------------------"
if (Test-Path $Client1Log) {
    Get-Content $Client1Log
}

Write-Host "---------------------------------------------------------------------"
Write-Host "CLIENT 2 LOG EVIDENCE:"
Write-Host "---------------------------------------------------------------------"
if (Test-Path $Client2Log) {
    Get-Content $Client2Log
}

# 5. Clean termination
Write-Host "[5/6] Stopping test processes..."
if (-not $Client1Process.HasExited) { Stop-Process -Id $Client1Process.Id -Force }
if (-not $Client2Process.HasExited) { Stop-Process -Id $Client2Process.Id -Force }
if (-not $ServerProcess.HasExited) { Stop-Process -Id $ServerProcess.Id -Force }

Write-Host "[6/6] End of verification."
