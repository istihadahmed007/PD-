# DTA: DHAKA THEFT AUTO (ঢাকা থেফট অটো)
### A Contemporary Bangladesh Open-World Crime Action Game
**Version**: 1.0.0 (Gold Master Production Release)  
**Engine**: Godot Engine 4.x Forward+ / Jolt 3D Physics  
**Platform**: Windows PC 64-bit  

---

## 🌟 ABOUT THE PROJECT

**Dhaka Theft Auto (DTA)** is an original, fully realized 3D open-world crime action game set in a fictionalized contemporary Bangladesh. Centered in the dynamic delta regions of the Padma and Buriganga rivers, DTA combines authentic cultural worldbuilding with responsive third-person character locomotion, advanced vehicle simulation, dynamic police heat response, living pedestrian and traffic AI, an authentic commercial economy in Bangladesh Taka (৳ BDT), a multi-region continuous world map, and an original crime-action narrative.

---

## 🎮 CORE FEATURES

- **Advanced Third-Person Locomotion**: 8-way directional character controller, sprinting, stamina management, stair step-up, coyote-time jump buffering, hard landing impact recovery, and over-the-shoulder aiming.
- **Authentic Vehicle Fleet & Simulation**: Realistic drivetrain, automatic 6-speed transmission, Ackermann steering, drifting, and tire smoke across Cycle Rickshaws, CNG Auto-Rickshaws, Local Buses, Sedans, SUVs, and Motorcycles.
- **Living Traffic & Pedestrian Ecosystem**: AI traffic with lane following, obstacle avoidance, priority junction resolution, 3-phase traffic lights, and reactive pedestrians that panic and flee from gunfire.
- **5-Star Police Heat & Evasion System**: Dynamic vision cones, non-teleporting police patrol cars, roadblock checkpoints with spike strips, tactical radar HUD, and interactive police stations (Thana).
- **Original Bangladesh Narrative**: A zero-plagiarism story following protagonist Joynal "Joy" Abedin as he defends his family against the predatory sand dredging cartel (*Balu Syndicate*). Features 3 full playable missions with cinematic dual-language (Bengali/English) letterbox dialogues.
- **Dynamic Economy & Safehouses**: Wallet cash, bank savings, 24/7 Rupali Bank ATMs, food stalls (Cha, Singara, Biryani), clothing shops (5 authentic outfits), auto garages (custom colors, ECU tuning, bullbar armor), safehouses with sleep saving, 16-slot inventory, and 3D physical item drops.
- **7 Interconnected Regions**: 512m streaming chunks covering Metropolitan Dhaka, Rajshahi Delta, Sylhet Tea Gardens, Chattogram Port, Cox's Bazar Coastal Highway, Sundarbans Mangrove Swamps, and Rural Agricultural Plains with distance-based LOD.
- **Professional PBR & Dynamic Weather**: Asphalt road shader with procedural FBM puddle accumulation and rain ripples, river/ocean water shader with Gerstner waves and depth absorption, wind foliage sway, 4-split CSM shadows, SSAO, SSR, volumetric fog, dynamic 24-hour day/night cycle, and 5 weather conditions (Sunny, Cloudy, Monsoon Rain, River Fog, Kalbaishakhi Thunderstorm with procedural lightning).
- **Comprehensive UI & Multi-Slot Save**: Cinematic Main Menu with original soundtrack, in-game Pause Menu (`[ESC]`), Settings modal (graphics, audio volume sliders, controls), Mission Log & Story Dossier (`[J]`), circular HUD Mini-Map radar, fullscreen World Map (`[M]`), and multi-slot Save/Load (Slots 1-3 + Autosave).

---

## 🕹️ DEFAULT KEYBOARD CONTROLS

| Key | On-Foot Action | In-Vehicle Action |
| :--- | :--- | :--- |
| **`W`, `A`, `S`, `D`** | Move Forward / Left / Back / Right | Throttle / Steer / Brake / Reverse |
| **`Shift`** | Sprint (Drains Stamina) | Speed Boost |
| **`Space`** | Jump (Buffered with Coyote Time) | Handbrake / Drift Slide |
| **`E`** | Interact (Vehicles, NPCs, ATMs, Shops) | Exit Vehicle |
| **`Right Click`** | Aim Camera / Reticle | — |
| **`Left Click`** | Melee Attack / Fire Weapon | — |
| **`H`** | — | Vehicle Horn |
| **`L`** | — | Vehicle Headlights |
| **`R`** | — | Cycle In-Car Radio Station |
| **`I` / `Tab`** | Open Backpack Inventory | Open Backpack Inventory |
| **`M`** | Open World Navigation Map | Open World Navigation Map |
| **`J`** | Open Mission Log & Dossier | Open Mission Log & Dossier |
| **`ESC`** | In-Game Pause Menu | In-Game Pause Menu |
| **`F3`** | Toggle Hardware Profiler Overlay | Toggle Hardware Profiler Overlay |

---

## 📂 PROJECT STRUCTURE

```
c:\Users\Tonmoy\Documents\DTA 0\
├── autoloads/               # Singleton controllers (GameManager, EventBus, AudioManager, CameraMode)
├── data/                    # Multi-slot SaveSystem & persistence schema
├── player/                  # Third-person character body, skin, camera controller
├── vehicles/                # BaseVehicle3D and 6 distinct vehicle types (Sedan, Rickshaw, CNG, Bus, SUV, Bike)
├── characters/              # Pedestrians, Police officers, questgivers
├── environment/             # Architecture, infrastructure, foliage, police stations, WeatherSystem
├── missions/                # MissionSystem, StoryMissions (Missions 01-03), Waypoint beacons
├── shaders/                 # PBR road wetness, realistic water, foliage wind
├── ui/                      # HUD, MiniMap, MainMenu, PauseMenu, SettingsModal, MissionLog, WorldMap
├── audio/                   # 100% synthesized 44.1kHz WAV soundscape (player, vehicles, city, weather, music)
├── docs/                    # Architecture guides, QA reports, credits, asset licenses
└── tests/                   # 9 playable diagnostic test harnesses
```

---

## 🚀 HOW TO PLAY

1. Open Godot Engine 4.x and import this folder.
2. Press **`F5`** to launch the game.
3. The game boots directly to the **Main Menu**. Click **New Game** to start your journey in Old Dhaka and the Buriganga delta!
