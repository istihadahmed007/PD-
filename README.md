# DTA: DHAKA THEFT AUTO (ঢাকা থেফট অটো)
### Contemporary Bangladesh Open-World Crime Action Game
**Version**: 1.2.0 (Playable Vertical Slice & Production Master)  
**Engine**: Godot Engine 4.7.2 (Forward+ / GL Compatibility) • Jolt 3D Physics  
**Platforms**: Windows PC (x64) • Live Web Browser (WASM / WebGL2) • Dedicated ENet Multiplayer (2–16 Players)  
**Repository**: [https://github.com/istihadahmed007/PD-](https://github.com/istihadahmed007/PD-)

---

## 🌟 ABOUT THE PROJECT

**Dhaka Theft Auto (DTA)** is an original, culturally grounded 3D open-world crime action game set in a fictionalized contemporary Bangladesh. Centered in the historic, vibrant delta district of Lalbagh and the Buriganga riverfront, DTA blends authentic Dhaka urban architecture with responsive third-person locomotion, authentic Bangladeshi vehicles (Cycle Rickshaws, Green CNG Auto-Rickshaws, Local Buses, Sedans), dynamic police pursuit escalation, interactive roadside economy (Tea Stalls, ATMs, Safehouses), and an original crime-action storyline following protagonist Joynal "Joy" Abedin as he defends his family and community against the predatory sand dredging cartel (*Balu Syndicate*).

---

## 🎮 PLAYABLE VERTICAL SLICE

The repository contains a fully playable, self-contained vertical slice set in **Old Dhaka District 01 (Padma-Buriganga)**:
- **Neighborhood Environment**: Handcrafted Old Dhaka streets featuring modular buildings, corrugated tin roofs, roadside open drains, electric poles with overhead tangled wires, Bengali neon signboards (*Bhai Bhai Auto Workshop*, *Bismillah General Store*, *Lalbagh Police Thana*), tea stall tongs, and a functioning river canal bridge.
- **Narrative Story Mission 01**: *Shadows & Spark Plugs (ছায়া ও চালক)* — Meet Kabir Ustad at Bhai Bhai Auto Workshop, mount the tuned Green CNG auto-rickshaw, transport fragile carburetor parts across the Canal Bridge to Gaffar Bhai's bazaar shop under a time limit, collect ৳ 1,500 BDT payment, and safely return to the workshop.
- **Story Missions 02 to 05**: Sequentially unlockable investigative quests, convoy chases, and thana infiltrations with journalist Nila Chowdhury and SI Mahfuz.
- **Responsive Controls**: Natural walking (3.2 m/s), jogging (7.0 m/s), sprinting (12.5 m/s) with stamina drain, stair step-up (0.35m clearance), coyote-time jump buffering, hard landing impact recovery, and over-the-shoulder aiming.
- **Authentic Vehicle Fleet**: Realistic drivetrain, automatic transmission, suspension bounce, and authentic audio across Cycle Rickshaws, CNGs, Sedans, DMP Police Cruisers, and Buses.
- **In-Game Guidance**: Dynamic on-screen controls hint bar, persistent objective tracker with live distance-to-beacon readouts, letterbox dialogue with character portraits (Joy, Kabir, Nila, Mahfuz), and interactive pause menu with checkpoint restart.

---

## 🕹️ GAME CONTROLS

### On-Foot Locomotion & Actions
| Action | Key / Input | Notes |
| :--- | :--- | :--- |
| **Move / Walk / Jog** | `W`, `A`, `S`, `D` | 8-way directional camera-oriented movement |
| **Sprint** | `Left Shift` | High-intensity sprint (12.5 m/s, drains stamina) |
| **Jump / Vault** | `Spacebar` | Buffered jump with coyote-time ground window |
| **Interact / Talk / Board** | `E` | Mount vehicles, talk to questgivers, buy tea |
| **Crouch / Stealth** | `C` | Lowers profile and collision capsule |
| **Aim Mode** | `Right Mouse Button` | Smooth over-the-shoulder camera zoom (FOV 48°) |
| **Attack / Fire / Dialogue** | `Left Mouse Button` | Melee strike / Fire weapon / Advance dialogue |
| **Swap Weapon / Grenade** | `Tab` | Switch between blaster and grenade launcher |
| **Mission Log & Dossier** | `J` | Review active objectives and story dialogues |
| **World Navigation Map** | `M` | Fullscreen district navigation map |
| **In-Game Pause Menu** | `Escape` | Pause, resume, save/load, or restart checkpoint |

### Vehicle Driving (Rickshaw, CNG, Sedan, Bus)
| Action | Key / Input | Notes |
| :--- | :--- | :--- |
| **Accelerate / Throttle** | `W` | Automatic forward transmission with RPM audio |
| **Brake / Reverse** | `S` | Smooth hydraulic braking and reverse gear |
| **Steer Left / Right** | `A` / `D` | Ackermann steering geometry with tire friction |
| **Handbrake / Drift Slide** | `Spacebar` | Locks rear wheels for tight Old Dhaka corners |
| **Dismount / Exit** | `E` | Safely dismounts vehicle and returns to foot |
| **Dhaka City Horn** | `H` | Authentic vehicle horn sound |
| **Toggle Headlights** | `L` | Dual forward projection spot lamps |

---

## 🚀 HOW TO LAUNCH & PLAY

### Method 1: Desktop One-Click Launcher (Recommended for Windows)
Double-click `Launch_DTA_Game.bat` in the project root folder. It automatically discovers your Godot 4.7 engine or standalone build and launches the game in GL Compatibility / OpenGL3 mode.

Alternatively, open Godot Engine 4.7.x, import this folder, and press **`F5`** (or run `main.tscn`).

### Method 2: Standalone Windows Executable
Navigate to `builds/windows/DhakaTheftAuto_Standalone_x64/` and run `Play_Game.bat` (or execute `DhakaTheftAuto.exe` directly).

### Method 3: Browser Preview (WebAssembly / WebGL2)
1. Double-click `Preview_Web_In_Browser.bat` (or run `node scripts/preview_server.js` in a terminal).
2. The local web server starts on `http://localhost:8080/` with required Cross-Origin Isolation headers (`COOP: same-origin`, `COEP: require-corp`).
3. Click **"⚡ BROWSER PREVIEW (WASM)"** or visit `http://localhost:8080/play/` directly in any modern desktop browser (Chrome, Edge, Firefox).

### Method 4: Dedicated Multiplayer Server
Start a headless authoritative server instance on UDP port 7788:
```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --server --port 7788 --max-players 8
```
Connect up to 8–16 simultaneous clients with:
```powershell
Godot_v4.7.2-stable_win64_console.exe --path . -- --client --connect 127.0.0.1 --port 7788 --nickname Joy_Player
```

---

## 🧪 AUTOMATED VERIFICATION & TEST SUITES

The codebase includes genuine, reproducible automated test harnesses:

1. **End-to-End Multiplayer Network Test**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File tests/run_e2e_network_test.ps1
   ```
   *Verifies dedicated server startup, 2 simultaneous client connections, peer registration, synchronized spawning, clean client despawn on disconnect, and reconnect without `ERR_UNCONFIGURED` errors (8/8 PASS).*

2. **Full Sub-System Diagnostic Suite**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File tests/run_all_test_scenes.ps1
   ```
   *Executes all 7 diagnostic scenes headlessly (`test_police_system.tscn`, `test_vehicle_physics.tscn`, `test_city_simulation.tscn`, `test_economy_system.tscn`, `test_visual_and_weather.tscn`, `test_world_expansion.tscn`, `test_multiplayer_locomotion_sync.tscn`), confirming zero crashes (Exit Code 0).*

3. **Master QA Static & Asset Integrity Audit**:
   ```powershell
   python scripts/tools/run_master_qa_suite.py
   ```
   *Audits 194 scenes, 787 external resources, 186 GDScript files, 17 audio assets, save schemas, and export presets (15/15 PASS).*

4. **Web Build Generator**:
   ```bash
   node scripts/build_vercel.js
   ```
   *Compiles and synchronizes 22 assets, PCK, and WASM binaries to `dist/` and `.vercel/output/static/`.*

---

## 📂 PROJECT DIRECTORY STRUCTURE

```
PD-/
├── assets/                  # Authentic Bengali signboards, character portraits, PBR textures
├── audio/                   # 100% original synthesized 44.1kHz WAV soundscapes & soundtrack
├── autoloads/               # Singletons: GameManager, EventBus, AudioManager, CameraMode, SaveSystem
├── builds/                  # Windows x64 standalone release & WebAssembly export packages
├── characters/              # Humanoid player skin, pedestrians, DMP police officers
├── data/                    # Multi-slot SaveSystem schema & JSON persistence
├── environment/             # Old Dhaka architecture, canal bridges, tea stalls, electric poles
├── missions/                # MissionSystem, StoryMissions (01-05), WaypointBeacons, Triggers
├── multiplayer/             # NetworkManager, NetworkPlayer (authoritative sync), MultiplayerWorld
├── player/                  # CharacterBody3D controller, SpringArm3D dual-pivot camera
├── public/                  # Web portal & WebAssembly browser client distribution
├── scenes/districts/        # District 01 (Padma-Buriganga) master open-world scene
├── scripts/tools/           # Automated QA scripts, scene verifiers, Vercel build bundler
├── tests/                   # Automated E2E network test & 7 sub-system diagnostic test scenes
├── ui/                      # HUD (objective tracker, controls guide), MainMenu, PauseMenu, Minimap
├── vehicles/                # BaseVehicle3D, Rickshaw, CNG Auto-Rickshaw, Sedan, Bus, SUV, Bike
└── world/                   # WorldSystem, ChunkStreamer (dynamic actor protection), TrafficSystem
```
