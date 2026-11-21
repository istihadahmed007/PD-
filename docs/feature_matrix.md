# EXISTING VERSUS MISSING FEATURE MATRIX
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Architecture Specification**  
**Godot Target**: Godot 4.x Forward+ / GDScript

---

## 1. System Matrix Overview

| Subsystem | Existing in GDQuest Reference | Target Bangladesh Open-World Feature Set | Gap Severity | Engineering Effort | Adaptation Strategy |
|---|---|---|---|---|---|
| **1. PlayerSystem** | Basic walk/run, jump, double boost, melee attack, basic shoot, coin drop on damage. | Sprint with stamina, crouch, stealth, slide, cover system, vaulting/mantling, swimming, vehicle enter/exit, inventory, ragdoll physics. | **HIGH** | Medium-High | Deconstruct `player.gd` into component architecture; preserve base velocity lerp & ground shapecast; add state machine for sandbox movement. |
| **2. CameraSystem** | Dual pivot: Third-Person (SpringArm3D) and Over-the-Shoulder aiming. | Vehicle follow camera with speed lag, cinematic mission framing, dynamic FOV transitions, collision-aware screen shake, conversational dialogue camera. | **MEDIUM** | Medium | Retain existing `CameraController`; introduce `CameraVirtualManager` to blend between Player, Vehicle, Aim, and Cutscene virtual cameras. |
| **3. VehicleSystem** | **NONE** | Bangladesh-specific vehicles: Cycle-Rickshaw (pedal/weight physics), CNG Auto-Rickshaw (3-wheel rollover physics), Local Bus (heavy diesel handling), Motorcycles, Cars. Boarding/hijacking animations, horn, headlights, passenger seats. | **CRITICAL** | High | Implement modular `VehicleSystem` based on `VehicleBody3D` / Raycast suspension; seat management (`VehicleSeat`) and player transition state. |
| **4. PedestrianSystem** | 2 hostile robotic AI agents (`BeeBot`, `BeetleBot`) with direct sensory detection. | High-density urban crowds (Dhaka street life): tea stall patrons, hawkers, students, office workers, rickshaw pullers. Ambient chatter in Bengali, wandering behavior, panic/flee states on gunfire/vehicular accidents. | **CRITICAL** | High | Build LOD crowd manager using multi-mesh instances for distant crowds and optimized `CharacterBody3D` navigation agents for nearby pedestrians. |
| **5. TrafficSystem** | **NONE** | Dense Dhaka traffic simulation: Road spline networks, lane following, intersection traffic lights, jam logic, honking cascades, vehicle spawning/despawning streaming rings around player. | **CRITICAL** | Very High | Implement spatial waypoint graph (`RoadNetwork3D`), lane agents, obstacle raycasts, and distance-based LOD pooling. |
| **6. WorldSystem** | Single static small island mesh (`terrain.glb`) and CSG block sandbox. | Seamless open-world streaming grid: Puran Dhaka (dense alleys, heritage balconies), Gulshan/Banani (modern corporate glass, wide avenues), Sadarghat riverfront (Buriganga launch terminal), flyovers, street markets. Occlusion culling, collision streaming, LODs. | **CRITICAL** | High | Develop chunk streaming loader (`WorldSystem`) with spatial grid indexing, async background threaded loading, and hierarchical LODs. |
| **7. MissionSystem** | **NONE** | Dynamic narrative quests: story missions, side jobs (rickshaw passenger delivery, parcel courier, gang heists), multi-stage objectives, fail/success states, GPS mini-map pathfinding. | **CRITICAL** | Medium-High | Implement resource-driven `MissionResource` and finite state machine (`MissionSystem`) connected to the global `EventBus`. |
| **8. PoliceSystem** | **NONE** | Wanted Heat Level (0 to 5 Stars): Dhaka Metropolitan Police (DMP) response. Patrol CNGs, police pickup trucks, roadblocks, SWAT/RAB equivalent units, search radiuses, arrest vs lethal response protocols. | **CRITICAL** | High | Build crime listener and heat coordinator (`PoliceSystem`) calculating threat escalation and police squad dispatching. |
| **9. InteractionSystem** | Implicit physics contact and area overlaps (`MeleeAttackArea`, `CoinArea`). | Contextual interaction system: raycast/trigger zone prompt displaying action prompt (`[E] Ride Rickshaw`, `[E] Order Cha at Tong`, `[E] Talk`, `[E] Open Gate`). | **HIGH** | Medium | Create reusable `InteractableComponent` and player raycast prompter with unified UI hints. |
| **10. EconomySystem** | Arcade coin pickup incrementing integer and dropping on damage. | Bangladesh Taka (BDT ৳) cash and banking system: physical wallet cash, ATM balances, pricing for street food (Singara, Cha), vehicle repairs, weapons, apparel, bribe payments. | **MEDIUM** | Low-Medium | Expand coin logic into `EconomySystem` supporting BDT currency formatting, transactions, and persistent wallet state. |
| **11. WeatherSystem** | Static sky material (`blue_sky.tres`), directional light, static water shader. | Dynamic 24-Hour Day/Night cycle, tropical monsoon weather (downpours, lightning, thunder audio, street puddles/wetness shaders, morning river haze). | **HIGH** | Medium | Build `WeatherSystem` modulating `DirectionalLight3D`, `WorldEnvironment`, and road shader parameters (`rain_intensity`). |
| **12. SaveSystem** | **NONE** | Robust save/load pipeline: serializing player stats, coordinates, inventory, current vehicle, BDT balance, world state, completed mission flags to JSON / encrypted binary. | **HIGH** | Medium | Build file-based `SaveSystem` with automated auto-save slots and version migration. |
| **13. AudioSystem** | 5 direct sound files (`step`, `land`, `shoot`, `defeat`, 1 music track). | Full open-world soundscape: Dhaka ambient layer (horns, crows, street vendors, rickshaw bells), 3D vehicle engines/horns, dynamic radio stations, Bengali voice lines, adaptive combat/exploration score. | **HIGH** | Medium-High | Establish Godot AudioBus hierarchy (`Master`, `Music`, `SFX`, `Vehicles`, `Radio`, `Ambiance`, `Voice`) with spatial audio emitters. |
| **14. UI/HUD** | Minimal reticle, weapon indicator, 3D viewport coin counter, pause menu. | Modern sandbox HUD: Minimap GPS with dynamic blips/waypoints, health/stamina bars, BDT cash readout, wanted star rating, contextual prompt bar, smartphone UI menu. | **HIGH** | Medium | Build modular responsive `CanvasLayer` HUD hooked directly to `EventBus` signals. |

---

## 2. Detailed Technical Gap Analysis

### 2.1 Player & Locomotion
- *Current State*: Character moves at single speed (8.0 m/s), jumps, and punches.
- *Required State*:
  - **Walking Speed**: 3.5 m/s (ambient street strolling).
  - **Jogging Speed**: 7.0 m/s (standard exploration).
  - **Sprinting Speed**: 10.5 m/s (drains stamina over time).
  - **Crouch Speed**: 2.5 m/s (lowers collision capsule height, enables stealth).
  - **Cover Mechanics**: Snapping to wall surfaces or parked vehicles.
  - **Vehicle Transition**: Mounting/dismounting animations, camera handoff, input scheme switching.

### 2.2 Vehicle System (Zero Existing Codebase)
- *Required Vehicle Classes*:
  1. **Cycle-Rickshaw**:
     - 3 wheels (1 front steerable, 2 rear drive).
     - Low top speed (~20-25 km/h), high initial pedaling inertia, sensitive tipping center of mass.
     - Custom rickshaw bell audio (`tring tring`).
  2. **CNG Auto-Rickshaw (Baby Taxi)**:
     - 3-wheeler with high center of gravity and distinctive 2-stroke engine sound.
     - Fast acceleration, agile narrow-alley turning, roll danger at sharp turns.
     - Metal passenger grille doors.
  3. **Local Passenger Bus (Murir Tin / Dhaka City Bus)**:
     - Heavy multi-ton momentum, wide turning radius, high ramming force.
     - Exterior denting/damage modeling, side-boarding passengers.
  4. **Standard Sedan / Police Pickup**:
     - 4-wheel suspension with responsive drift physics.

### 2.3 Pedestrian Crowd Dynamics
- *Current State*: Purely aggressive robotic enemies that wander toward player upon proximity.
- *Required State*:
  - Civilians mind their own business: sitting on plastic stools at tea stalls, walking along sidewalks, crossing at zebra crossings.
  - Panic behaviors: On gunfire, nearby NPCs duck, scream, or sprint away from threat position.
  - Ambient reactions: Reacting to player bumping into them, honking, or vehicle near-misses.

### 2.4 Traffic Simulation
- *Current State*: Zero vehicular traffic.
- *Required State*:
  - Directed cyclic graphs representing Dhaka roads, flyovers, and alleyways.
  - Mixed traffic flow (bicycles, rickshaws, CNGs, private cars, public buses) sharing lanes.
  - Emergent congestion: slow rickshaws causing queues, honking behavior triggered by blocked raycasts.

### 2.5 Audio & Cultural Immersion
- *Current State*: Cartoonish robot SFX and western orchestral fantasy music.
- *Required State*:
  - Street audio captures authentic Bangladesh atmosphere: ambient sound of tea spoons hitting glass cups, street vendors shouting ("Chai garam!", "Mama shoren!"), vehicle horns, river ferry sirens at Sadarghat.
  - Radio stations broadcasting authentic local genres (Bengali pop, rock, folk, bhatiali, hip-hop).

---

## 3. Engineering Priorities & Implementation Milestones

### Completed Milestones (Phases 00, 01, 02)
- [x] **Phase 00 Foundation**: Autoload architecture (`EventBus`, `GameManager`, `AudioManager`), clean 15-directory structure, comprehensive architecture docs, and foundational subsystem scripts (`VehicleSystem`, `PoliceSystem`, `EconomySystem`, `PedestrianAgent`, `InteractionSystem`, `WeatherSystem`).
- [x] **Phase 01 Player Locomotion & Character**: Humanoid character skin with realistic 1.78m human proportions and Dhaka streetwear; 13 blended animations; 3-tier speeds (Walk 3.2 m/s, Jog 7.0 m/s, Sprint 12.5 m/s with stamina); 2-stage kinematic stair step-up; slope snapping; spring arm sphere-shape collision avoidance; aiming shoulder cam; dedicated test scene and telemetry HUD.
- [x] **Phase 02 Bangladesh Open-World Environment**: 400m × 400m district (`district_01_padma_buriganga.tscn`) containing all 10 required landmarks:
  1. Residential neighbourhood (concrete flats, balconies, water tanks, tin-roof houses, boundary walls)
  2. Commercial market (*Bazaar* with rollup shutters and 3 authentic Bangla signboards)
  3. Main road (2-lane asphalt spine, yellow center stripe, footpaths, curbs, open drains)
  4. Narrow side streets (*Goli* with brick paving and high walls)
  5. Small river or canal (*Khal* with water caustic/depth shader and stepped river ghat)
  6. Local bridge (2-lane reinforced concrete girder bridge spanning the canal)
  7. Police station compound (*Thana / Fari* with antenna mast, DMP branding, parking yard)
  8. Vehicle repair workshop (*Bhai Bhai Auto Workshop* with canopy, tire piles, grease pad)
  9. Roadside tea stall (*Tong* with wooden bench, kettle, and stamina restoration interaction)
  10. CNG & Bus stand (passenger shelter, benches, route signboard, and driveable cycle rickshaw)
- [x] **Visual Culture Assets**: Authentic Pillow-rendered 1024×256 Bangla typography signboards with `Nirmala.ttf` font.
- [x] **Environment Infrastructure**: Concrete electric utility poles, overhead wiring lines, streetlights with active SpotLight3D nodes, Bot Gach banyan trees, and coconut palms.
- [x] **Phase 03 Bangladesh Vehicle System**: Modular physics-based `VehicleBody3D` + `VehicleWheel3D` architecture:
  - 8 Authentic Bangladesh Vehicles:
    1. Private Sedan (*Shonar Toron Sedan*)
    2. SUV (*Meghna Explorer 4x4*)
    3. Commuter Motorcycle (*Bikrom 150R*) with dynamic turn lean
    4. CNG Auto-Rickshaw (*Dhaka Green Baby Taxi*) with 3-wheel rollover physics
    5. Traditional Pedal Rickshaw (*Lalbagh Cycle Rickshaw*)
    6. Local City Bus (*Dhaka Nagar Paribahan / Murir Tin*) with heavy momentum & air horn
    7. Pickup Truck (*Padma Utility Pickup*)
    8. Delivery Van (*Chander Gari Delivery Van*)
  - 5-Speed Automatic Transmission with realistic RPM curves and shift delays.
  - Speed-sensitive steering interpolation & handbrake drifting.
  - Multi-view vehicle follow camera (`VehicleCamera3D`) with Chase Far, Chase Close, Hood, and Look-Behind modes.
  - Collision damage with contact reporting, metallic impact audio, and smoke/fire particle states.
  - Animated driver door opening with latch sounds and spatial raycast safe exit solver.
  - Dedicated diagnostic test track scene (`test_vehicle_physics.tscn`) with drag strip, speed breakers, 15°/30° slopes, and live telemetry HUD.
- [x] **Phase 04 Living Bangladesh City Simulation**: Dynamic urban crowd and mixed traffic ecosystem:
  - 5 Demographic Bangladeshi Pedestrian Archetypes: Chacha Panjabi (Tupi/Lungi), Student Youth (Jeans/T-shirt), Hawker Laborer (Vest/Lungi/Gamcha), Office Babu (Formal Shirt/Slacks), and Female Citizen (Salwar Kameez/Dupatta).
  - Pedestrian FSM: Footpath wandering, shop browsing, tea stall seating, zebra street crossings, vehicle proximity dodges with voice shouts, and panic fleeing.
  - Mixed Traffic Ecosystem: 35% CNG Auto-Rickshaws, 25% Sedans, 15% Motorcycles, 10% Local Buses, 10% Rickshaws, 5% Pickups/SUVs/Vans.
  - Road Network Waypoint Graph (`RoadNetwork3D`): 4 directional lanes, speed limits, stop lines.
  - Autonomous AI Driver (`TrafficVehicleAgent`): Waypoint lane tracking, forward raycast obstacle detection, safe following distance ($3.5\text{m}$), congestion detection, Dhaka *honk cascade*, and overtaking slow rickshaws.
  - 4-Phase Traffic Light Intersection (`TrafficLightController`): North-South vs East-West green/yellow/red phases with overhead gantry and SpotLights.
  - Configurable Density Controls: Live population density ($0.0 - 1.0$) and traffic density ($0.0 - 1.0$) with streaming ring spawner.
  - Dedicated Interactive Test Scene: `test_city_simulation.tscn` with live telemetry dashboard.
- [x] **Phase 05 Police & Wanted Heat System**: Authentic Dhaka Metropolitan Police (DMP) law enforcement ecosystem:
  - **Crime Detection & Classification**: Automatic detection of Brandishing, Firearm Discharge, Pedestrian Assault, Vehicle Theft, Hit & Run, Police Assault, and Thana Trespassing.
  - **Emergent Witness Reporting**: Pedestrians observe crimes via visual/sound range, scream in Bengali, and dial 999 with a 3.5s countdown and 3D floating call badge; interruptible by suspect actions.
  - **5-Star Wanted Progression**:
    - ★ (1 Star): On-foot traffic police attempt arrest with batons (৳ 500 fine).
    - ★★ (2 Stars): DMP Patrol cruisers mobilize with sirens and interceptor pursuit (৳ 1,500 bail).
    - ★★★ (3 Stars): Lethal force authorized, 9mm sidearms drawn, PIT maneuvers and ramming bumpers.
    - ★★★★ (4 Stars): DMP SWAT / CRT deployment, tactical roadblocks with tire spike strips.
    - ★★★★★ (5 Stars): Maximum tactical lockdown, heavy armed encirclement.
  - **Sensory Perception & Non-Teleporting AI**: `PoliceVisionSensor` with dynamic FOV ($115^\circ - 135^\circ$), day/night lighting sensitivity, and physics raycast occlusion; units navigate along road graphs and off-screen nodes without teleportation.
  - **Search Area & Evasion Cooldown**: Dynamic search radius centered on last known position; cooldown timer ticks 2x faster when fleeing outside search perimeter.
  - **Police Patrol Vehicles**: DMP Patrol Sedan with navy/white livery, official Bengali door decals, alternating red/blue lightbar, and procedural sirens (`siren_wail`, `siren_yelp`).
  - **Police Checkpoints**: Fortified roadblock barricades with hazard blinkers, armed guards, and active spike strips with tire blowout physics.
  - **Police Station (Thana) Gameplay**: Interactive front desk (duty officer surrender and fines), impound yard vehicle recovery, and secured armory with trespassing alarms.
  - **Tactical Radar HUD**: 5-star animated heat display, evasion countdown gauge, status toast, and real-time 360° radar with search zone boundary visualization.
  - **Playable Test Scenario**: `tests/test_police_system.tscn` with live telemetry dashboard, crime triggers [1-5], surrender [C], and teleport shortcuts [T, B].
- [x] **Phase 06/08 Original Bangladesh Story & Mission System**: Fully scripted original crime-action narrative engine:
  - **Zero Plagiarism Lore Bible**: Authentic socio-economic struggle in the Padma-Buriganga river delta focusing on the illegal sand dredging cartel (*Balu Syndicate*), river launch pilots, dockland mechanics, and compromised civic structures.
  - **Fully Realized Character Ensemble**:
    - *Protagonist*: Joynal "Joy" Abedin (former river launch pilot, master diesel mechanic).
    - *Family*: Mother Rahela Begum, Sister Sumaiya Abedin (BUET engineering scholar), Late Father Captain Farid Abedin.
    - *Antagonist*: Chairman Afsarul "Balu" Huq (sand dredging tycoon & land-grabbing kingpin).
    - *Enforcers*: Ghashi Tariq (river enforcer commanding dredging crews and shakedown rackets).
    - *Supporting Allies*: Kabir "Ustad" Mollah (Bhai Bhai Auto Workshop owner), Nila Chowdhury (investigative journalist for *Dainik Prerona*).
    - *Law Enforcement*: Sub-Inspector Mahfuzur Rahman (Padma/Lalbagh Thana).
    - *Community & Merchants*: Gaffar Bhai (Bismillah General Store), Kalu Miah (Tea stall Tong), Rahmat Chacha (Rickshaw puller fleet elder).
  - **Mission System Engine**:
    - Multi-stage step mechanics: `GOTO`, `TALK`, `DRIVE`, `DELIVER`, `CHASE`, `DEFEND`, `INVESTIGATE`.
    - Checkpoint recovery with player respawn, vehicle repair, and objective rewind.
    - Real-time countdown timers and fragile cargo health degradation monitoring.
    - Full persistence via `SaveSystem` serializing completed missions, active quest step, wallet BDT, and coordinates.
  - **3D Visual Waypoint Beacon**: Pulsing ground ring, 22m vertical light beam, bobbing pointer arrow, and dynamic distance labels.
  - **Cinematic Dual-Language Dialogue UI**: Screen-bottom letterbox with character portrait badges, authentic Bengali typography, italic English subtitle translations, and synthesized audio blips.
  - **Three Playable Story Missions**:
    1. *Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)* (Delivery & fragile cargo driving across Canal Bridge; ৳1,500 BDT).
    2. *Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)* (Infiltration, dossier theft, and 1-Star heat evasion; ৳2,800 BDT).
    3. *Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)* (High-speed pursuit, PIT maneuvers, ramming enforcer pickup; ৳4,500 BDT).
  - **Playable Test Harness & District Integration**: `tests/test_story_missions.tscn` with interactive HUD [1-3, N, R, F, K, L, T] and open-world questgiver triggers in `district_01_padma_buriganga.tscn`.
- [x] **Phase 07 Bangladesh Game Economy & Interaction System [COMPLETED]**:
  - **Dual Currency & Banking**: Pocket cash (`wallet_bdt`) and digital savings (`bank_bdt`); 24/7 Rupali Bank ATM kiosk for fast deposits, withdrawals, and digital ledger tracking.
  - **Zero Decorative Buttons**: Every button in every UI modal is wired to functional GDScript logic with audio feedback and transaction logging.
  - **Fictional Commercial Brands**:
    - *Mama Tong Cha Stall*: Food and drink purchases (Cha, Singara, Samucha, Speed Energy Drink, Kacchi Biryani) that restore actual player health, stamina, and stamina regeneration.
    - *Bismillah General Store*: Groceries, first aid medical kits (+75 HP), and portable vehicle toolkits (+60 HP).
    - *Lalbagh Tailors & Desi Fashion*: 5 authentic outfits (Dhaka Casual, Classic White Panjabi, Corporate Office Shirt, Rickshaw Puller Lungi, Tactical Night Windbreaker) with real-time 3D character mesh material updates.
    - *Bhai Bhai Auto Workshop*: Vehicle garage bay supporting 100% repairs (clearing smoke/fire), 6 custom polyurethane paint colors with live vehicle preview, Stage 1 ECU engine tuning (+25% torque), and reinforced steel bullbar armor (+50% HP).
    - *Padma Housing Ltd.*: Purchasable residential safehouses (*Buriganga Riverview Flat*, *Old Dhaka Tin Unit*) with resting/sleeping (advances world clock 6 hrs, restores 100% HP & stamina, auto-saves game), wardrobe, and stash box.
  - **16-Slot Inventory System & 3D Pickups**: Stacking inventory (`InventorySystem`) with item consumption, inspection pane, and dropping 3D physical pickups (`ItemPickup3D`) that bob and rotate in the world.
  - **Save/Load Persistence**: Version 2 schema in `SaveSystem` serializing wallet, bank, transaction history, inventory slots, owned properties, equipped outfit, and vehicle upgrades.
  - **Playable Diagnostic Scenario**: `tests/test_economy_system.tscn` with interactive HUD [1-4, B, G, I, K, L, ESC] and full integration into `district_01_padma_buriganga.tscn`.
- [x] **Phase 08 Open World Expansion & 7 Geographical Regions [COMPLETED]**:
  - **Seven Interconnected Geographical Regions**:
    1. *Metropolitan Dhaka* (Cell `(0, 0)`): High-density urban center, commercial markets, thana, workshop, canals.
    2. *Rajshahi & Padma Delta* (Cell `(-2, 0)`): Wide silt riverbeds, sandbars, brick kilns, mango orchards, and the Grand Padma Truss Bridge.
    3. *Sylhet Tea Gardens & Wetlands* (Cell `(1, 1)`): Terraced emerald hills, tea bushes, colonial wooden bungalow, and Haor wetlands.
    4. *Chattogram Maritime Port* (Cell `(1, -1)`): Industrial cargo aprons, container stacks, gantry cranes, and Karnaphuli river harbor.
    5. *Cox's Bazar Coastal Strip* (Cell `(1, -2)`): Golden sandy beach, cliff-side Marine Drive highway, tourist resort hotels, coconut palms, ocean surf.
    6. *Sundarbans Mangrove Delta* (Cell `(-1, -1)`): Tidal mudflats, stilt root mangrove trees, winding tidal creeks, timber boardwalks.
    7. *Rural Agricultural Floodplains* (Cell `(-1, 0)`): Expansive golden paddy and jute fields, thatched mud huts, village banyan trees.
  - **Modular 512m World Tiles**: Standardized `WorldTile` class with continuous terrain, standardized highway boundary ports (16m), and riverway ports.
  - **Threaded Background Streaming**: `ChunkStreamer` using `ResourceLoader.load_threaded_request()` for hitch-free background loading in a $3\times 3$ active window.
  - **Three-Tier Distance-Based LOD**: LOD0 (<250m full detail & collision), LOD1 (250m-600m medium detail), LOD2 (>600m low-poly terrain silhouette with collision disabled).
  - **Fictional National Highway Network**: NH-1 (Padma Expressway), NH-2 (Sylhet Hill Express), NH-3 (Grand Coastal Highway & Marine Drive).
  - **Regional Biome & Audio Manager**: `RegionalBiomeManager` dynamically crossfading 7 synthesized regional ambient tracks and tweening `WorldEnvironment` lighting and volumetric fog.
  - **Interactive World Navigation Map**: Fullscreen cartographic map `WorldMapUI.tscn` toggled with `[M]`, featuring live GPS coordinates, regional labeling, and fast-travel debug shortcuts.
  - **Playable Diagnostic Scenario**: `tests/test_world_expansion.tscn` with interactive telemetry HUD [1-7, M, C, K, L].
- [x] **Phase 09 Visual Quality & World Optimization [COMPLETED]**:
  - **Realistic PBR Shaders**:
    - *Asphalt Road & Monsoon Puddle Shader* (`realistic_pbr_road.gdshader`): Asphalt texture with yellow highway markings, dynamic wetness darkening (25%), roughness reduction ($0.85 \to 0.08$), FBM procedural puddle pooling, and rain ripple perturbation.
    - *River & Ocean Water Shader* (`realistic_water.gdshader`): Gerstner dual-octave wave displacement, depth color absorption from turquoise delta to deep silt, Schlick-GGX fresnel reflections, and normal chop.
    - *Wind Foliage Shader* (`foliage_wind.gdshader`): Height-weighted wind sway and backlight subsurface scattering (SSS) for palms, banyans, tea bushes, and paddy crops.
  - **High-Quality Lighting & Shadows**:
    - 4-split Parallel Split Shadow Maps (CSM) with 160m draw distance, smooth split blending, and soft shadow filtering.
    - Screen-Space Ambient Occlusion (SSAO) with 1.5m radius and 2.0 intensity.
    - Screen-Space Reflections (SSR) with 32 ray-march steps.
    - Atmospheric Volumetric Fog with per-weather density scaling.
  - **5 Dynamic Weather Conditions**:
    - *Sunny (রোদ)*, *Cloudy (মেঘলা)*, *Monsoon Rain (বর্ষা)*, *River Fog (কুয়াশা)*, and *Thunderstorm (কালবৈশাখী)*.
    - Dedicated GPU particle rain emitter (1,600 droplets/sec) and synthesized weather audio suite (`rain_monsoon_loop.wav`, `wind_storm.wav`, `thunder_strike_1.wav`, `thunder_strike_2.wav`).
    - Procedural thunderstorm lightning strikes surging directional light to 4.0x with randomized thunder playback.
  - **Dynamic 24-Hour Day/Night Cycle & Civic Lighting**:
    - Solar & lunar celestial elevation/azimuth simulation with continuous color temperature shifts (Dawn amber, Midday sun, Sunset crimson, Night moonlight).
    - Zero-overhead automated streetlight and porch light switching via scene groups (`"streetlights"`, `"building_lights"`).
    - Time-dependent pedestrian and traffic density modulation (35% peds, 40% vehicles at night) saving CPU/GPU cycles for night illumination.
  - **In-Game Hardware Profiler & Benchmark Dashboard**:
    - CanvasLayer 16 overlay (`PerformanceProfiler.tscn`) toggled with `[F3]`.
    - Live hardware metrics: Framerate (FPS), frame time (ms), static memory (MB), clock time, weather state, road wetness %, and active entity counts.
    - Zero-decorative buttons: Interactive Quality Presets (Low, Medium, High), Weather triggers (Sunny, Cloudy, Rain, Fog, Storm), and Time controls (Dawn, Noon, Sunset, Night, Speed toggle).
  - **Playable Diagnostic Scenario & District Integration**:
    - Dedicated test harness `tests/test_visual_and_weather.tscn` [1-5, 6-9, Q, C, K, L, F3].
    - Seamlessly integrated into primary open-world map `scenes/districts/district_01_padma_buriganga.tscn`.
- [x] **Phase 10 Final Game Systems & Windows Release [COMPLETED]**:
  - **Complete User Interface Ecosystem**:
    - *Cinematic Main Menu* (`ui/menu/main_menu.tscn`): Title logo with Bengali typography, New Game, Continue, Slot Picker, Settings modal, Credits panel, and original soundtrack playback.
    - *In-Game Pause Menu* (`ui/menu/pause_menu.tscn`): Triggered with `[ESC]`, pausing game loop and providing Resume, Slot Saving/Loading, Mission Log, World Map, Settings, and Quit.
    - *Settings & Graphics Modal* (`ui/menu/settings_modal.tscn`): Interactive configuration for Quality Presets (Low, Medium, High), Window Mode (Windowed/Fullscreen), Framerate Limit (30, 60, Unlimited), SSAO, SSR, Volumetric Fog, Audio Mixing sliders (Master, Music, SFX, Ambiance), and Mouse Look Sensitivity.
    - *Tactical Mini-Map Radar* (`ui/minimap/minimap.tscn`): Bottom-left circular radar with player compass heading, dynamic mission waypoint clamping, police search zone radius, nearby vehicles, and POIs.
    - *Mission Log & History Modal* (`ui/mission_ui/mission_log_modal.tscn`): Active quest tracker, completed missions archive with narrative summaries, and character lore dossiers.
    - *HUD Polish*: Integrated MiniMap, health/stamina bars, speedometer, wanted stars, interaction banner, and mission toasts.
  - **Multi-Slot Persistence & Settings Architecture**:
    - `SaveSystem` version 3 supporting Slots 1-3 plus Autosave and Settings serialization.
    - Preserves 3D coordinates, rotation, wallet cash, bank savings, transaction ledger, 16-slot inventory, owned vehicles & customizations, mission progress, and world clock/weather.
  - **Synthesized Audio Suite & Original Soundtrack**:
    - Player locomotion audio (asphalt footsteps 1-4, puddle splash footsteps 1-2, jump effort, landing impact).
    - Authentic Bengali NPC voice callouts (`bengali_callout_1` to `4`).
    - 4 original music tracks (`main_theme.wav`, `radio_padma_rock.wav`, `dhaka_beats_hiphop.wav`, `surma_folk.wav`).
    - Footstep stride audio synchronization in `player/player.gd`.
  - **Windows Desktop Release Preparation**:
    - `export_presets.cfg` configured for Windows Desktop x86_64 (`DhakaTheftAuto.exe`).
    - Complete intellectual property ledger (`docs/asset_licenses.md`) certifying 100% original, synthesized, or CC0 assets.
    - Full project credits (`docs/credits.md`) and installation guide (`docs/installation_and_user_guide.md`).
    - Final QA Report (`docs/final_qa_report.md`): 12/12 subsystems passed (104 scenes, 444 external resources, 103 GDScript files, 0 errors).
