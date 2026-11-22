$GodotExe = "C:\Users\Tonmoy\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
$scenes = @(
    "tests/test_police_system.tscn",
    "tests/test_vehicle_physics.tscn",
    "tests/test_city_simulation.tscn",
    "tests/test_economy_system.tscn",
    "tests/test_visual_and_weather.tscn",
    "tests/test_world_expansion.tscn",
    "tests/test_multiplayer_locomotion_sync.tscn"
)

$allPassed = $true
foreach ($sc in $scenes) {
    Write-Host "========================================"
    Write-Host "RUNNING SCENE: $sc"
    Write-Host "========================================"
    $p = Start-Process -FilePath $GodotExe -ArgumentList @("--headless", "--path", ".", "--quit-after", "60", $sc) -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -eq 0) {
        Write-Host "RESULT: PASS (ExitCode 0) for $sc"
    } else {
        Write-Host "RESULT: FAIL (ExitCode $($p.ExitCode)) for $sc"
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Host "ALL 7 TEST SCENES PASSED 100%!"
    exit 0
} else {
    Write-Host "SOME TEST SCENES FAILED."
    exit 1
}
