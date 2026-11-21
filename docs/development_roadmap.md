# BANGLADESH OPEN-WORLD GAME: DEVELOPMENT ROADMAP
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Technical Roadmap: Phase 00 to Gold Master Release**  
**Godot Target**: Godot 4.x Forward+ | GDScript 2.0 (Statically Typed)

---

## 1. Roadmap Architecture & Milestone Overview

```
Phase 00 ──► Phase 01 ──► Phase 02 ──► Phase 03 ──► Phase 04 ──► Phase 05
Audit &       Player &     Bangladesh    World &      Crowd &      Traffic &
Foundation   Camera Mod    Vehicles      Weather      Pedestrians  Road Graph
  (Done)

Phase 06 ──► Phase 07 ──► Phase 08 ──► Phase 09 ──► Phase 10 ──► GOLD
Police &     Economy &    Missions &   Audio &      Optimization  RELEASE
Heat System  Weapons      Phone OS     Radio        & Packaging
```

---

## 2. Phase-by-Phase Technical Breakdown

### PHASE 00: REPOSITORY AUDIT & ARCHITECTURAL FOUNDATION (CURRENT)
- **Objective**: Complete exhaustive audit of GDQuest reference repository, preserve untouched backup, establish modular folder hierarchy, document architecture, and build a verified working sandbox test scene.
- **Key Deliverables**:
  - [x] Complete GDQuest repository clone and structural inspection.
  - [x] Untouched reference preserved at `reference_original/godot-4-3d-third-person-controller/`.
  - [x] Comprehensive 5-part documentation in `docs/`.
  - [x] Modular folder structure (`scenes/`, `scripts/`, `characters/`, `vehicles/`, `environment/`, `world/`, `missions/`, `audio/`, `shaders/`, `ui/`, `data/`, `autoloads/`, `tests/`, `docs/`).
  - [x] Core Autoload singletons (`EventBus`, `GameManager`, `AudioManager`).
  - [x] Working integrated sandbox test scene (`tests/test_sandbox.tscn`).
- **Success Criteria**: Project opens without errors in Godot 4.x; player moves, jumps, aims, shoots; HUD displays live BDT currency and wanted rating; test vehicle and interaction zones trigger properly.

---

### PHASE 01: ADVANCED PLAYER LOCOMOTION, CAMERA & INTERACTION SYSTEM
- **Objective**: Refactor monolithic player into modular components; implement full sandbox locomotion (Sprint, Crouch, Cover, Vault, Swim) and contextual interaction raycasting.
- **Key Tasks**:
  - Implement `PlayerLocomotionComponent` with stamina consumption and dynamic capsule scaling.
  - Implement `CoverComponent` allowing character to snap to low walls, barricades, and vehicle doors.
  - Implement `VaultComponent` using forward raycast probes to mantle over fences, tea-stall benches, and road dividers.
  - Implement `InteractionSystem`: Forward sphere-cast detecting `InteractableComponent` with UI tooltip cues.
  - Extend `CameraController` with dynamic FOV transitions (Sprint = 85°, Crouch = 65°, Aim = 45°) and trauma-based camera shake.
- **Test Milestone**: `tests/test_locomotion.tscn` demonstrating parkour over Dhaka alley obstacles, vaulting over a roadside divider, and stamina depletion.

---

### PHASE 02: BANGLADESH VEHICLE PHYSICS & MOUNTING MECHANICS
- **Objective**: Build authentic vehicle physics for Bangladesh's signature transportation: Cycle-Rickshaw, CNG Auto-Rickshaw, and Local Passenger Bus.
- **Key Tasks**:
  - `BaseVehicle` architecture with driver/passenger seat management, headlight toggles, and health deformation.
  - **Cycle-Rickshaw**: Custom 3-wheel human-powered physics. Steered front fork, rear solid axle, inertia on starting pedaling, bell ringing (`tring tring`).
  - **CNG Auto-Rickshaw (Baby Taxi)**: 3-wheeler suspension with narrow track width, authentic rollover center-of-mass, 2-stroke engine torque curve, metal door interaction.
  - **Local Bus (Murir Tin)**: Heavy multi-ton momentum, air brake lag, passenger boarding side-door.
  - Seamless boarding/unboarding: Player animates into vehicle seat, camera transitions to vehicle chase mode, inputs remap to vehicle driving.
- **Test Milestone**: `tests/test_vehicles.tscn` with drivable Rickshaw and CNG navigating a slalom course and obstacle ramp.

---

### PHASE 03: OPEN-WORLD STREAMING, 7 GEOGRAPHICAL REGIONS & WEATHER [COMPLETED]
- **Objective**: Build the dynamic environment engine, 7 interconnected Bangladesh regions, 512m chunk-based streaming, and weather system.
- **Key Deliverables & Tasks**:
  - [x] `WorldSystem`: Master open-world coordinator managing 512m streaming cells and active viewing windows.
  - [x] `ChunkStreamer`: Asynchronous background asset loader using `ResourceLoader.load_threaded_request()` for hitch-free streaming.
  - [x] `WorldTile`: Base 512m modular tile supporting 3-tier distance LODs (LOD0 <250m, LOD1 250m-600m, LOD2 >600m), occlusion culling, and standardized road ports.
  - [x] Seven Interconnected Geographical Regions (Built and validated one by one):
    1. *Region 1: Metropolitan Dhaka (Cell 0, 0)*: Shonar Nagar urban core, bazaars, thana, workshop, canals.
    2. *Region 2: Rajshahi & Padma Delta (Cell -2, 0)*: Sandbars, brick kilns, mango orchards, Padma Truss Bridge.
    3. *Region 3: Sylhet Tea Gardens & Wetlands (Cell 1, 1)*: Undulating emerald hills, tea estate bungalow, tea bushes, Haor wetlands.
    4. *Region 4: Chattogram Maritime Port (Cell 1, -1)*: Container terminal stacks, gantry cranes, harbor channels.
    5. *Region 5: Cox's Bazar Coastal Strip (Cell 1, -2)*: Sandy ocean beach, Marine Drive cliff highway, resort hotels, coconut palms.
    6. *Region 6: Sundarbans Mangrove Delta (Cell -1, -1)*: Tidal mudflats, stilt root mangrove forest, winding creeks, timber boardwalk.
    7. *Region 7: Rural Agricultural Floodplains (Cell -1, 0)*: Expansive paddy/jute fields, mud thatched huts, banyan trees.
  - [x] Fictional Transport Network: NH-1 (Padma Expressway), NH-2 (Sylhet Express), NH-3 (Grand Coastal Highway & Marine Drive).
  - [x] `RegionalBiomeManager`: Dynamic `WorldEnvironment` lighting/volumetric fog tweening and crossfading 7 synthesized regional ambient tracks.
  - [x] `WorldMapUI`: Interactive cartographic navigation map toggled via `[M]` with GPS locator and fast-travel debugging.
  - [x] Playable Diagnostic Scenario: `tests/test_world_expansion.tscn` with live telemetry dashboard.

---

### PHASE 04: PEDESTRIAN CROWD SIMULATION & DHAKA STREET LIFE
- **Objective**: Populate the urban environment with authentic, emergent crowd behaviors.
- **Key Tasks**:
  - `PedestrianSystem`: Spawning and despawning pedestrian agents around player viewing cone.
  - 3-tier LOD system to sustain 100+ visible pedestrians at 60 FPS:
    - *LOD 0 (<25m)*: Full pathfinding, obstacle avoidance, micro-expressions.
    - *LOD 1 (25-80m)*: Simplified animation tree, low-frequency navigation checks.
    - *LOD 2 (>80m)*: Kinematic waypoint sliding or multi-mesh impostors.
  - Diverse archetypes: Street vendors (Jhalmuri / Cha hawkers), shoppers, office commuters, students, rickshaw pullers resting on seats.
  - Emergent reactions: Reacting to honking, panicking on gunfire, screaming and fleeing during vehicle crashes.
- **Test Milestone**: `tests/test_crowd.tscn` with 80 pedestrians navigating a crowded marketplace sidewalk with proper collision avoidance.

---

### PHASE 05: TRAFFIC SYSTEM & ROAD NODE NETWORK
- **Objective**: Engineer a realistic multi-lane traffic simulation capable of replicating Dhaka's dense vehicular flow and gridlocks.
- **Key Tasks**:
  - `RoadNetwork3D`: Graph consisting of road nodes, curved Bézier splines, lane definitions, and intersection controllers.
  - Traffic AI: Autonomous vehicle agents tracking spline lanes with front-facing obstacle detection raycasts.
  - Mixed-Traffic Dynamics: Slow cycle-rickshaws sharing lanes with speedy CNGs and heavy buses; overtaking logic on open avenues.
  - Jam & Honking Mechanics: Cascading honk sound system triggered when vehicles are immobilized at blocked intersections.
- **Test Milestone**: `tests/test_traffic.tscn` demonstrating a 4-way intersection with functional traffic lights, lane queuing, and emergent jam behaviors.

---

### PHASE 05/06: POLICE HEAT SYSTEM & URBAN LAW ENFORCEMENT [COMPLETED]
- **Objective**: Implement law enforcement AI featuring the Dhaka Metropolitan Police (DMP) and escalating heat levels.
- **Key Deliverables**:
  - [x] `PoliceSystem`: Master heat coordinator (1-5 stars), dynamic search radius, and evasion cooldown.
  - [x] `CrimeDetector`: Classifies theft, brandishing, gun discharge, assault, hit-and-run, and trespassing.
  - [x] `WitnessComponent`: Civilian NPCs observe crimes, scream in Bengali, and dial 999 with 3.5s delay.
  - [x] `PoliceVisionSensor`: Raycast line-of-sight perception with day/night vision cones and wall occlusion.
  - [x] `PoliceOfficer`: On-foot constable with DMP uniform, peaked cap, whistle audio, baton arrest, and sidearms.
  - [x] `PolicePatrolSedan` & `PoliceVehicleAgent`: Cruisers with DMP livery, red/blue lightbar, sirens, and pursuit AI.
  - [x] `PoliceCheckpoint`: Roadblock barricades, warning gantry, hazard flashers, and tire spike strips.
  - [x] `PoliceStationController`: Lalbagh Thana front desk (surrender/fines), impound yard, and armory trespass.
  - [x] `PoliceRadarHUD`: Animated 5-star heat rating, evasion countdown gauge, and 360° circular radar.
  - [x] Verified playable test scenario (`tests/test_police_system.tscn`) and full integration into `district_01_padma_buriganga.tscn`.

---

### PHASE 07: ECONOMY SYSTEM, STREET COMMERCE & INTERACTION [COMPLETED]
- **Objective**: Establish the Bangladesh Taka (BDT ৳) economy, street shops, banking, garages, safehouses, wardrobe, and inventory.
- **Key Deliverables & Tasks**:
  - [x] `EconomySystem`: Currency formatting, pricing matrix, and commerce catalogs.
  - [x] Dual Currency Architecture: Pocket cash (`wallet_bdt`), savings (`bank_bdt`), and 50-entry transaction history ledger.
  - [x] Rupali Bank ATM Terminal (`AtmTerminal.tscn` & `AtmModal.tscn`): 24/7 fast cash deposits, cash withdrawals, and digital ledger table.
  - [x] Food & Drink Purchases: Mama Tong Cha Stall with real item consumption effects (+HP, +Stamina, stamina boost).
  - [x] Vehicle Garage & Customization: Bhai Bhai Auto Workshop with vehicle repairs (clearing smoke/fire), 6 custom polyurethane paint jobs with live vehicle preview, Stage 1 ECU tuning (+25% torque, +15% top speed), and reinforced steel bullbar armor (+50% HP).
  - [x] Clothing Boutique & Wardrobe: Lalbagh Tailors with 5 authentic urban outfits dynamically updating character 3D mesh materials.
  - [x] Real Estate Properties & Safehouses: Padma Housing Ltd. with purchasable safehouses, sleeping/resting (advances time 6 hours, heals 100% HP & stamina, auto-saves game), wardrobe, and wanted star dissipation.
  - [x] 16-Slot Inventory System (`InventorySystem.gd` & `InventoryModal.tscn`): Item inspection, consumption, and dropping 3D ground pickups (`ItemPickup3D.tscn`) in the world.
  - [x] Save/Load Persistence: `SaveSystem` Version 2 serializing wallet, bank, transactions, inventory slots, properties, outfits, and vehicle modifications.
  - [x] Dedicated Playable Test Scenario: `tests/test_economy_system.tscn` with live telemetry dashboard, shortcuts [1-4, B, G, I, K, L], and full integration into `district_01_padma_buriganga.tscn`.

---

### PHASE 08: NARRATIVE MISSION SYSTEM & IN-GAME SMARTPHONE OS [CORE MISSIONS COMPLETED]
- **Objective**: Build the quest orchestration engine, story missions, and modern sandbox player smartphone interface.
- **Key Deliverables & Tasks**:
  - [x] `MissionResource`: Data-driven quest definitions with steps (`GOTO`, `TALK`, `DRIVE`, `DELIVER`, `CHASE`, `DEFEND`, `INVESTIGATE`), fragile cargo checks, and dual-language dialogues.
  - [x] `MissionSystem`: State machine tracking stages, branch points, checkpoint saves, player respawns, and BDT/XP rewards.
  - [x] `MissionWaypointBeacon`: 3D vertical beam, pulsing ground ring, bobbing arrow, and dynamic distance labels.
  - [x] `MissionDialogueUI`: Cinematic letterbox UI featuring character portrait badges, authentic Bengali dialogue, and English subtitle translations.
  - [x] `StoryMissions`: Repository containing the first 3 full playable story missions:
    1. *Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)* (Delivery, Canal Bridge crossing, fragile cargo).
    2. *Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)* (Thana infiltration, dredging dossier theft, police evasion).
    3. *Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)* (High-speed pursuit, PIT maneuvers, enforcer ramming, journalist rescue).
  - [x] Verified playable test harness (`tests/test_story_missions.tscn`) and open-world triggers in `district_01_padma_buriganga.tscn`.
  - [x] Full integration with `SaveSystem` and `EventBus`.
  - Side Job Generators (Upcoming Phase):
    - *Rickshaw Puller*: Pick up pedestrians and pedal them to destination waypoints before timer expires.
    - *CNG Express*: High-speed passenger runs through congested traffic.
    - *Delivery Courier*: Navigating narrow alleys to deliver packages.
  - In-Game Smartphone (UI Layer) (Upcoming Phase):
    - Slide-up phone interface toggled by `M` or `D-Pad Up`.
    - Apps: Contacts (Mission givers), GPS Map, Banking (bKash/Nagad parody app for money transfers), Camera, Music Player.
- **Test Milestone**: `tests/test_story_missions.tscn` demonstrating multi-stage story missions initiated via questgiver triggers, involving vehicle driving, stealth investigation, police evasion, vehicle chase, and extraction.

---

### PHASE 09: VISUAL QUALITY, DYNAMIC WEATHER & WORLD OPTIMIZATION [COMPLETED]
- **Objective**: Improve the open world to a professional visual standard with realistic PBR shaders, dynamic 24-hour lighting, 5 weather systems, automated civic lighting, and PC hardware scalability presets.
- **Key Deliverables & Tasks**:
  - [x] `realistic_pbr_road.gdshader`: Asphalt shader with painted markings, dynamic wetness darkening (25%), roughness reduction ($0.85 \to 0.08$), FBM procedural puddle accumulation, and rain surface ripples.
  - [x] `realistic_water.gdshader`: Gerstner dual-octave wave displacement, depth color absorption (turquoise to deep silt), and Schlick-GGX fresnel reflections.
  - [x] `foliage_wind.gdshader`: Wind sway vertex displacement and backlight subsurface scattering (SSS) transmission.
  - [x] `WeatherSystem`: Dynamic 24-hour cycle (Dawn, Midday, Sunset, Night) with solar/lunar trajectory, automated streetlight and porch light group toggling, and 5 weather conditions (Sunny, Cloudy, Monsoon Rain, Fog, Thunderstorm).
  - [x] Synthesized audio suite (`rain_monsoon_loop.wav`, `wind_storm.wav`, `thunder_strike_1.wav`, `thunder_strike_2.wav`) and GPU particle rain emitter (1,600 particles).
  - [x] Stochastic lightning flash system surging directional light to 4.0x with randomized thunder strike playback.
  - [x] In-game hardware profiler dashboard (`PerformanceProfiler`, `[F3]` toggle) with real-time FPS, frame time (ms), RAM usage, road wetness %, and interactive Low/Med/High quality, weather, and time controls.
  - [x] Playable diagnostic scenario `tests/test_visual_and_weather.tscn` [1-5, 6-9, Q, C, K, L, F3] and integration into `district_01_padma_buriganga.tscn`.
- **Test Milestone**: `tests/test_visual_and_weather.tscn` maintaining 60 FPS across Low, Medium, and High graphics presets under heavy monsoon rain and night streetlighting.

---

### PHASE 10: FINAL GAME SYSTEMS, AUDIO SOUNDSCAPE & LOCALIZATION [COMPLETED]
- **Objective**: Complete all user interfaces, audio synthesis, radio stations, footsteps, multi-slot save persistence, and dual-language localization.
- **Key Deliverables & Tasks**:
  - [x] Full UI Suite: Main Menu (`ui/menu/main_menu.tscn`), Pause Menu (`ui/menu/pause_menu.tscn`), Settings Modal (`ui/menu/settings_modal.tscn`), Mission Log & Dossier (`ui/mission_ui/mission_log_modal.tscn`), and Mini-map Radar (`ui/minimap/minimap.tscn`).
  - [x] Multi-Slot Save Persistence: `SaveSystem` v3 supporting Slots 1-3, Autosave, Player position/rotation, Money, Inventory, Owned vehicles, Mission progress, World state, and Settings.
  - [x] Synthesized Audio Suite: 16 WAV files covering player footsteps (asphalt 1-4, puddles 1-2, jump, land), Bengali NPC voice callouts (1-4), and 4 original soundtracks (`main_theme.wav`, `radio_padma_rock.wav`, `dhaka_beats_hiphop.wav`, `surma_folk.wav`).
  - [x] Footstep Locomotion Integration: Distance stride counter in `player/player.gd` triggering asphalt and puddle footstep sounds.
  - [x] In-Vehicle Radio: 4 operational stations connected to `AudioManager` (`Radio Padma`, `Dhaka Beats`, `Surma Folk`, `Kotha FM`).

---

### PHASE 11: QUALITY ASSURANCE, WINDOWS EXPORT & GOLD MASTER PACKAGING [COMPLETED]
- **Objective**: Rigorous automated QA verification, memory leak audits, Windows Desktop export preset, and release documentation.
- **Key Deliverables & Tasks**:
  - [x] Master QA Automation Suite: `scripts/tools/run_master_qa_suite.py` verifying 12 core subsystems with 100% pass rate.
  - [x] Windows Desktop Export Preset: Pre-configured `export_presets.cfg` for Forward+ x86_64 standalone executable (`DhakaTheftAuto.exe`).
  - [x] Asset License Ledger: `docs/asset_licenses.md` certifying 100% original, synthesized, or CC0 assets.
  - [x] Complete Project Credits: `docs/credits.md` detailing architecture, engineering, and attributions.
  - [x] Installation & User Guide: `docs/installation_and_user_guide.md` and `README.md` covering system requirements, controls, and launch instructions.
  - [x] Final QA Report: `docs/final_qa_report.md` recording 0 broken references across 104 scenes and 103 GDScript files.
- **Deliverable**: Gold Master Release (v1.0.0) of DTA: Dhaka Theft Auto.
