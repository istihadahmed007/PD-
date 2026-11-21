# TECHNICAL ARCHITECTURE SPECIFICATION
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Architecture Document — Version 1.0**  
**Godot Target**: Godot 4.x Forward+ | GDScript 2.0 (Statically Typed)

---

## 1. Architectural Philosophy & Design Principles

To achieve the simulation depth of an open-world title while sustaining high frame rates on PC and modern consoles in Godot 4 Forward+, the game follows five foundational principles:

1. **Decoupled Event-Driven Core**: Systems communicate strictly through signals routed via a centralized `EventBus` singleton or explicit parent-child component contracts. Direct cross-node coupling (e.g. `get_parent().get_parent().do_something()`) is prohibited.
2. **Component-Based Composition**: Game entities (`Player`, `Vehicle`, `Pedestrian`, `Prop`) are composed of specialized, reusable components (`HealthComponent`, `LocomotionComponent`, `InteractionComponent`, `InventoryComponent`).
3. **Data-Driven Logic via Custom Resources**: Weapons, missions, vehicle configs, and dialogue scripts are defined as Godot `Resource` (`.tres`) files rather than hardcoded script branches.
4. **Distance-Based Level of Detail (LOD) & Multi-tier Simulation**: High-fidelity physics and complex AI run strictly within the player's immediate sensory radius (0–50m). Distant actors (50–300m) transition to simplified kinematic/spline movement; ultra-distant actors (>300m) enter virtualized macro-simulation pools.
5. **No External Network Dependencies**: All gameplay logic, world streaming, audio, and physics calculations are completely self-contained and local.

---

## 2. Global Autoload & Singleton Architecture

```
[Engine Init]
     │
     ├── Autoload: EventBus           (Global signal routing broker)
     ├── Autoload: GameManager        (Game states: OnFoot, Driving, Paused, Cutscene)
     ├── Autoload: AudioManager       (Buses, 3D sound spatialization, radio stations)
     ├── Autoload: FullScreenHandler  (Windowing and display toggle)
     └── Autoload: CameraMode         (F10 free-cam debug tool for developers)
```

### 2.1 EventBus (`autoloads/event_bus.gd`)
The backbone for inter-system communication. Defines standard signals:
- **Player Signals**: `player_spawned(player)`, `player_health_changed(current, max)`, `player_stamina_changed(current, max)`, `player_died()`.
- **Vehicle Signals**: `vehicle_entered(vehicle, seat)`, `vehicle_exited(vehicle)`, `vehicle_speed_changed(kmh)`, `vehicle_damaged(health)`.
- **Crime & Police Signals**: `crime_committed(crime_type, severity, location)`, `wanted_level_changed(new_stars)`, `police_pursuit_started()`, `police_pursuit_lost()`.
- **Economy Signals**: `money_changed(current_balance, delta_amount)`, `item_purchased(item_id, cost)`.
- **Interaction Signals**: `interaction_target_available(prompt_text, icon_key)`, `interaction_target_cleared()`.
- **World & Weather Signals**: `time_of_day_updated(hours, minutes)`, `weather_changed(weather_state)`.
- **Mission Signals**: `mission_started(mission_id)`, `mission_objective_updated(step_index, text)`, `mission_completed(mission_id, reward_bdt)`, `mission_failed(mission_id, reason)`.

### 2.2 GameManager (`autoloads/game_manager.gd`)
Maintains global game state and coordinates transitions:
```gdscript
enum GameState {
    ON_FOOT,
    IN_VEHICLE,
    PAUSED,
    IN_MENU,
    CUTSCENE,
    MINIGAME,
    DEAD
}
```
Controls mouse capture/release, active player controller handoffs, and world timescale modulation.

### 2.3 AudioManager (`autoloads/audio_manager.gd`)
Configured with dedicated audio buses:
- `Master` -> `Music` (Adaptive background score)
- `Master` -> `SFX` -> `Combat` (Gunfire, punches, impacts)
- `Master` -> `SFX` -> `Vehicles` (Engines, tires, horn)
- `Master` -> `SFX` -> `Environment` (Rain, thunder, river water)
- `Master` -> `Ambiance` (Dhaka street bustle, crowd murmurs, rickshaw bells)
- `Master` -> `Radio` (In-vehicle music stations with stereo spatialization)
- `Master` -> `Voice` (Bangla and English NPC lines, dialogue)

---

## 3. Modular System Architecture

### 3.1 PlayerSystem (`characters/player/`)
- **PlayerEntity (`player.gd`)**: `CharacterBody3D` serving as the root coordinate container and component coordinator.
- **Components**:
  - `LocomotionComponent`: Handles ground physics, sprinting, jogging, walking, crouching, sliding, and ground shapecasts.
  - `CombatComponent`: Manages weapon aiming, recoil, melee hitboxes, and ballistic projectile spawning.
  - `InteractionDetectorComponent`: Uses forward `RayCast3D` and proximity `Area3D` to find interactable props or vehicles.
  - `InventoryComponent`: Stores weapons, ammo, quest items, and equipment.
  - `HealthComponent`: Handles damage intake, armor reduction, invulnerability frames, and ragdoll triggering.

### 3.2 CameraSystem (`scripts/camera/`, `player/camera_controller.gd`)
- **CameraController**: Decoupled `Node3D` with `top_level = true`.
- **Virtual Camera States**:
  1. `ON_FOOT_EXPLORE`: Smooth spring arm (10m) following player ground elevation with lag.
  2. `ON_FOOT_AIM`: Over-the-shoulder pivot with lowered FOV (45°), tightened pitch clamp, and reticle raycast.
  3. `IN_VEHICLE`: High-altitude rear chase camera (spring length 7–12m based on vehicle size), auto-aligning with vehicle velocity vector, with speed-based FOV dilation.
  4. `CINEMATIC_DIALOGUE`: Low-angle or two-shot framing for mission cutscenes.

### 3.3 VehicleSystem (`vehicles/`)
- **BaseVehicle (`vehicles/base_vehicle.gd`)**:
  - Inherits `VehicleBody3D` (or physics `RigidBody3D` with custom raycast suspension).
  - Encapsulates:
    - Engine parameters (horsepower, top speed, gear ratios, braking force).
    - Steering mechanics (front wheel angles, steering assist, counter-steering).
    - Seat management (`VehicleSeat` with driver/passenger positions and exit markers).
    - Headlights (`SpotLight3D`), brake lights (`OmniLight3D`), and horn audio player.
    - Damage model (chassis deformation, engine smoke at <30% health, explosion on zero health).
- **Subclasses**:
  - `RickshawVehicle`: 3-wheel human-powered physics. Steered by handlebars; human pedaling force pulse curve.
  - `CngVehicle`: 3-wheel auto-rickshaw (Bajaj RE style). 2-stroke engine torque, narrow wheelbase with realistic lateral rollover risk on high-speed handbrake turns.
  - `BusVehicle`: Multi-ton rigid body, dual rear axles, air brake sounds, passenger capacity for 20+ NPCs.

### 3.4 PedestrianSystem (`characters/pedestrians/`)
- **PedestrianManager**:
  - Spawns and manages urban crowds within an annular ring (20m to 120m) around the player.
  - Uses `NavigationAgent3D` bound to sidewalk navigation meshes.
  - Implements a 3-tier LOD:
    - *LOD 0 (<25m)*: Full skeletal animation, facial shaders, detailed path avoidance, cloth physics.
    - *LOD 1 (25m–80m)*: Simplified animation tree, lower tick rate (20Hz), basic collision.
    - *LOD 2 (>80m)*: Vertex animation / static billboard or multi-mesh impostors.
- **States**: `WANDER`, `IDLE_TONG` (drinking tea, talking), `BARGAIN_SHOP`, `PANIC_FLEE`, `COWER`.

### 3.5 TrafficSystem (`scripts/traffic/`)
- **RoadNetwork**:
  - Graph-based node network of connected road splines (`RoadSegment3D` and `Intersection3D`).
  - Lanes store directionality, speed limits, and vehicle class allowances (e.g., rickshaw-prohibited flyovers vs alleyways).
- **TrafficVehicleController**:
  - Autonomous driving agent tracking spline waypoints.
  - Front-facing raycasts detect leading vehicles, pedestrians crossing, or red lights.
  - Emergent congestion: Impatient honking triggered when blocked for >3.0 seconds.

### 3.6 WorldSystem (`world/`)
- **ChunkStreamer**:
  - Open-world partitioned into a 2D coordinate grid of chunks (e.g., 256m x 256m).
  - Asynchronously loads/unloads chunks based on player position and viewing frustum.
  - Sub-scenes:
    - `TerrainChunk`: Visual mesh, collision, road geometry.
    - `PropsChunk`: Street lamps, shop signs, trash bins, tea stalls, bus stops.
    - `NavmeshChunk`: Baked navigation polygon for pedestrian AI.

### 3.7 PoliceSystem (`scripts/police/`)
- **Heat Escalation Ladder (Dhaka Metropolitan Police - DMP)**:
  - **★☆☆☆☆ (1 Star - Infraction / Petty Theft)**: Nearby patrol foot-officers / traffic police attempt arrest on sight.
  - **★★☆☆☆ (2 Stars - Assault / Rickshaw Carjacking)**: Patrol CNG units and police motorcycles pursue with sirens.
  - **★★★☆☆ (3 Stars - Gunfire / Murder)**: Police pickup trucks (Mahindra/Toyota pickups), aggressive PIT maneuvers, tactical squads armed with rifles.
  - **★★★★☆ (4 Stars - Mass Violence / Terrorism)**: DMP SWAT / Special Action units with heavy body armor and fortified roadblocks on major avenues.
  - **★★★★★ (5 Stars - State Emergency)**: Paramilitary Rapid Action Battalion (RAB) / Armed intervention, armored personnel carriers, persistent search helicopters with searchlights.
- **Cooldown & Evade Mechanics**: Circular search zone on minimap. Breaking line-of-sight and exiting zone for 30 seconds clears wanted level.

### 3.8 InteractionSystem (`scripts/interaction/`)
- **InteractableComponent (`Area3D`)**:
  - Exported fields: `prompt_text: String`, `prompt_action_name: String`, `interaction_time: float`.
  - Reusable across vehicles, doors, street food vendors (Tong), ATMs, and quest givers.
  - Automatically signals UI HUD when player enters/exits interaction cone.

### 3.9 EconomySystem (`data/economy_system.gd`)
- Currency: Bangladesh Taka (BDT / ৳).
- Stores wallet balance and bank balance.
- Replaces arcade coins with authentic item commerce:
  - Cha (Tea): ৳10
  - Singara / Samucha: ৳15
  - Rickshaw Fare: ৳30 - ৳100
  - CNG Meter Fare: ৳150 - ৳500
  - Weapons / Black Market Tools: ৳5,000 - ৳50,000

### 3.10 WeatherSystem (`environment/weather_system.gd`)
- Day/Night: 24-minute real-world cycle for full 24-hour game day.
- Lighting: Procedural sky material modulating sun angle, color temperature (warm golden hour, deep tropical blue night), and SDFGI ambient bounces.
- Monsoon Weather:
  - Rain particle precipitation.
  - Dynamic material property `wetness` passed to road shaders for mirror-like puddle reflections.
  - Volumetric fog density modulation.

### 3.11 SaveSystem (`data/save_system.gd`)
- Serializes complete game state to `user://savegame.json`.
- State payload includes: Player coordinates, health, inventory, equipped weapon, BDT wallet, game time, active mission state, unlocked city areas.

### 3.12 UI / HUD (`ui/hud/`)
- Responsive `CanvasLayer` designed for clean sandbox readability:
  - Top-Right: BDT Currency (`৳ 25,000`), active weapon icon, ammo count.
  - Bottom-Left: Circular GPS Minimap, health bar (green), stamina bar (blue), armor bar (white).
  - Top-Left: Wanted stars (flashing white/blue during active pursuit, grey during cooldown).
  - Center-Bottom: Interaction prompt banner (`[E] Ride Rickshaw`).
  - Center-Screen: Aim reticle (dynamic spread based on player movement/recoil).

---

## 4. Physics Collision Layer Map

Configured in `project.godot` to prevent collision interference:

| Layer # | Name | Description |
|---|---|---|
| **Layer 1** | `World_Static` | Terrain, buildings, roads, non-destructible architecture. |
| **Layer 2** | `Player` | Player CharacterBody3D capsule. |
| **Layer 3** | `Vehicles` | Drivable vehicles, chassis, tires, collision hulls. |
| **Layer 4** | `Pedestrians` | AI civilians and enemy characters. |
| **Layer 5** | `Props_Dynamic`| Destructible crates, street signs, chairs, trash cans. |
| **Layer 6** | `Projectiles` | Bullets, rockets, thrown grenades, melee hitboxes. |
| **Layer 7** | `Sensors_Interaction` | Interactable trigger volumes, detection areas. |
| **Layer 8** | `Sensors_Police`| Police line-of-sight, surveillance camera cones. |
| **Layer 9** | `Navigation_Obstacles`| Dynamic obstacles for Godot NavigationServer3D. |
| **Layer 10**| `Water` | Buriganga river, lakes, water volume triggers. |

---

## 5. Performance Budget & Forward+ Optimization

- **Target Framerate**: 60 FPS rock-solid at 1440p / 1080p on mid-range GPUs (GTX 1660 / RTX 2060 / RX 6600).
- **Draw Call Budget**: Maximum 1,200 draw calls per frame in dense urban settings.
- **Polygon Budget**: Under 2.5 million triangles visible in camera frustum simultaneously.
- **SDFGI**: Configured with 4 cascades, 0.5s update interval for smooth sun transitions without frame hitches.
- **Occlusion Culling**: Baked `OccluderInstance3D` meshes on all large buildings in Puran Dhaka and commercial high-rises.
