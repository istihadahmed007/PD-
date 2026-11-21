# POLICE AND WANTED SYSTEM ARCHITECTURE (PART 05)
**Project**: Bangladesh Open-World Action Game (*DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Module**: Urban Law Enforcement, Heat Progression, Witness Reporting & Pursuit AI  
**Target Engine**: Godot 4.x Forward+ | Jolt Physics 3D | GDScript 2.0 (Statically Typed)

---

## 1. Executive Summary & Design Philosophy

Part 05 engineers an original, emergent crime-and-response system modeled after authentic urban law enforcement in Bangladesh: the **Dhaka Metropolitan Police (DMP / ঢাকা মেট্রোপলিটন পুলিশ)**, assisted by specialized **Crisis Response Teams (CRT / সোয়াত)** and traffic constables.

### Core Architectural Principles:
1. **Zero Artificial Teleportation**: Police units physically exist in the simulation. Units are either pre-stationed at Thana compounds, actively patrolling the road network, or dynamically spawned outside the player's direct camera frustum ($>60\text{m}$ along road network nodes) and navigate using navigation agents and vehicle AI.
2. **Emergent Civilian Witnessing & 999 Hotline**: Crimes committed out of sight of police do not immediately trigger wanted stars. Nearby civilians evaluate line-of-sight and auditory radius, panic, scream in Bengali, and dial **999** (Bangladesh National Emergency Hotline) with an interactive 3.5s countdown. Suspects can interrupt or flee before dispatch occurs.
3. **Line-of-Sight Sensory Perception**: Police units employ physics raycasting and dynamic horizontal FOV cones ($115^\circ - 135^\circ$, up to $42\text{m}$ day, $26\text{m}$ night). Static buildings, alleys, and terrain break line of sight, transitioning pursuit into an active search area.
4. **Adaptive Contextual Strategy**: Law enforcement responds based on crime severity and terrain. Narrow residential alleyways (*Goli*) deploy on-foot officers or agile motorcycles with batons; high-speed avenues deploy cruiser interceptors, roadblocks, and tire spike strips.

---

## 2. System Architecture & Class Hierarchy

```
                                  ┌────────────────────────┐
                                  │   GameManager / EventBus│
                                  └───────────┬────────────┘
                                              │
                   ┌──────────────────────────┴──────────────────────────┐
                   ▼                                                     ▼
        ┌─────────────────────┐                               ┌──────────────────────┐
        │    PoliceSystem     │◄──────────────────────────────┤    CrimeDetector     │
        │ (Heat Orchestrator) │                               │ (Action Monitoring)  │
        └──────────┬──────────┘                               └──────────┬───────────┘
                   │                                                     │
         ┌─────────┴──────────────┬──────────────────┐                   ▼
         ▼                        ▼                  ▼         ┌─────────────────────┐
┌─────────────────┐      ┌─────────────────┐ ┌───────────────┐ │  WitnessComponent   │
│  PoliceOfficer  │      │PoliceVehicleAgent│ │PoliceCheckpnt │ │(999 Emergency Delay)│
│ (Foot AI Agent) │      │  (Pursuit AI)   │ │ (Spike Strip) │ └─────────────────────┘
└────────┬────────┘      └────────┬────────┘ └───────────────┘
         │                        │
         └───────────┬────────────┘
                     ▼
         ┌───────────────────────┐
         │  PoliceVisionSensor   │
         │(Raycast Line-of-Sight)│
         └───────────────────────┘
```

### Module Roster:
| Class | File Path | Base Class | Responsibilities |
|---|---|---|---|
| `PoliceSystem` | `scripts/police/police_system.gd` | `Node` | Master wanted star controller (0-5), search circle tracking, global LOS aggregation, evasion cooldown timing, and navigation dispatching. |
| `CrimeDetector` | `scripts/police/crime_detector.gd` | `Node` | Classifies player crimes (Brandishing, Gunfire, Theft, Assault, Hit & Run, Trespass); handles direct police view vs witness 999 routing. |
| `WitnessComponent` | `scripts/police/witness_component.gd` | `Node3D` | Attached to pedestrian NPCs; detects crimes, plays Bengali shouts, displays floating 3D dial indicator, and reports to DMP Dispatch after 3.5s. |
| `PoliceVisionSensor` | `scripts/police/police_vision_sensor.gd` | `Node3D` | 3D perception component evaluating FOV angles, distance falloff, time-of-day visibility, and physics raycast occlusion against world geometry. |
| `PoliceOfficer` | `scripts/police/police_officer.gd` | `CharacterBody3D` | On-foot DMP Constable/Sub-Inspector with uniform mesh, peaked cap, whistle audio, baton non-lethal arrest (1-2★), and firearm shooting (3-5★). |
| `PoliceVehicleAgent` | `scripts/police/police_vehicle_agent.gd` | `Node` | Autonomous driver AI for cruisers: road network cruising, siren toggle, flashing lightbar, high-speed chase, PIT maneuvers, and roadblock boxing. |
| `PolicePatrolSedan` | `vehicles/police/police_sedan.gd` | `BaseVehicle3D` | DMP Police Patrol Cruiser with navy/white livery, official Bengali door decals, rooftop red/blue lightbar, and interceptor physics. |
| `PoliceCheckpoint` | `scripts/police/police_checkpoint.gd` | `Node3D` | Roadblock infrastructure with reflective striped barricades, DMP warning signs, hazard flashers, armed guards, and active tire spike strips. |
| `PoliceStationController` | `scripts/police/police_station_controller.gd` | `Node3D` | Interactive Thana compound: Duty Officer desk (surrender, fines, bail), impound yard vehicle recovery, and armory trespassing alarms. |
| `PoliceRadarHUD` | `ui/police_radar/police_radar_hud.gd` | `Control` | Tactical HUD displaying animated 5-star heat rating, evasion countdown, status toast, and real-time circular radar with search perimeter. |

---

## 3. Crime Taxonomy & Escalation Matrix

| Crime Identifier | Severity (Stars) | Direct Police Reaction | Civilian Witness Reaction | Escalation Threshold |
|---|---|---|---|---|
| `BRANDISHING_WEAPON` | ★ (1 Star) | Verbal warning, baton drawn, arrest attempt | Shock, backing away, 999 call | Continuous aiming for $>3.0\text{s}$ |
| `ASSAULT_CIVILIAN` | ★ (1 Star) | Immediate foot pursuit, baton charge | Panic, screaming, 999 call | Striking pedestrian with melee |
| `THEFT_PETTY` / `VEHICLE_THEFT` | ★★ (2 Stars) | Cruiser pursuit dispatched with sirens | Yelling ("চোর! পুলিশ ডাকো!"), 999 call | Stealing parked or traffic vehicles |
| `FIREARM_DISCHARGE` | ★★ (2 Stars) | Units converge with sidearms drawn | Widespread panic fleeing, instant 999 call | Gunfire heard within $48\text{m}$ radius |
| `VEHICLE_HIT_AND_RUN` | ★★★ (3 Stars) | High-speed cruiser pursuit, ramming | Severe panic, emergency ambulance calls | Colliding with pedestrians $>18\text{km/h}$ |
| `ASSAULT_POLICE` | ★★★ (3 Stars) | Officers draw firearms, open fire | Complete evacuation of street section | Hitting or damaging police units |
| `POLICE_FACILITY_TRESPASS` | ★★ (2 Stars) | Thana station lockdown, guards attack | Duty desk officers draw batons | Entering restricted armory zone |

---

## 4. 5-Tier Wanted Progression

```
[★☆☆☆☆] Level 1: Investigation & Non-Lethal Subdue
  ├── Responding Units: On-foot DMP Traffic Constables
  ├── Armament: Bamboo Lathi (Batons), Brass whistles
  └── Tactics: Approach suspect, demand surrender, non-lethal arrest [৳ 500 fine]

[★★☆☆☆] Level 2: Mobilization & Cruiser Pursuit
  ├── Responding Units: DMP Patrol Sedans & Foot Patrols
  ├── Armament: Patrol cruisers with sirens & lightbars, batons
  └── Tactics: Intercept fleeing suspects, road boxing, bail settlement [৳ 1,500 bail]

[★★★☆☆] Level 3: Lethal Force Authorized
  ├── Responding Units: Multiple DMP Patrol Cruisers & Armed Officers
  ├── Armament: 9mm Service Pistols, heavy steel ram bumpers
  └── Tactics: High-speed pursuit, PIT maneuvers, shooting at suspect and tires

[★★★★☆] Level 4: CRT Tactical Lockdown
  ├── Responding Units: DMP Crisis Response Team (CRT / SWAT)
  ├── Armament: Tactical carbines/SMGs, reinforced roadblocks
  └── Tactics: Fortified checkpoints on bridges, active tire spike strips

[★★★★★] Level 5: Maximum Urban Lockdown
  ├── Responding Units: Paramilitary & Citywide Tactical Taskforce
  ├── Armament: High-caliber automatic rifles, aggressive encirclement
  └── Tactics: Simultaneous multi-angle ramming, full perimeter blockade
```

---

## 5. Line-of-Sight, Search Areas & Evasion Dynamics

### Sensory Computation:
`PoliceVisionSensor` executes raycast checks at $0.15\text{s}$ intervals:
- **FOV Cone**: $\theta \le 57.5^\circ$ (Half-angle of $115^\circ$ FOV). Within $4.5\text{m}$, proximity awareness triggers regardless of heading.
- **Occlusion Testing**: Physics ray cast towards target chest ($y + 1.2\text{m}$). Raycast queries mask Layers 1 (World Static), 2 (Player), and 3 (Vehicles). If static geometry intercepts the ray, LOS is broken.
- **Lighting Scaling**: Effective sensory range drops from $40\text{m}$ (daylight) to $26\text{m}$ (night hours 19:00 - 06:00).

### Search Areas & Cooldown Mechanics:
```
           [Line of Sight Lost]
                     │
                     ▼
       ┌───────────────────────────┐
       │ Search Area Established:  │
       │ Center = Last Known Pos   │
       │ Radius = 25m + (Stars×26m)│
       └─────────────┬─────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
Inside Search Radius      Outside Search Radius
   Cooldown: 1.0x            Cooldown: 2.0x (Accelerated)
        │                         │
        └────────────┬────────────┘
                     ▼
          [Cooldown Reaches Zero]
                     │
                     ▼
         Wanted Level Decrements (★-1)
                     │
         (Stars == 0 -> Heat Cleared!)
```

- If **ANY** police unit regains line of sight during cooldown, evasion is instantly aborted, the timer resets to $0.0\text{s}$, and active pursuit resumes!

---

## 6. Police Station Interactions (Lalbagh Thana)

The Lalbagh Police Thana (`environment/architecture/police_station.tscn`) provides complete interactive open-world gameplay:
1. **Duty Officer Front Desk (`DutyDesk`)**:
   - `[E] Speak with Duty Officer (অফিসার ইন চার্জ)`
   - At 0 Stars: Atmospheric dialogue and 999 safety advisory.
   - At 1 Star: Option to peacefully surrender and pay ৳ 500 fine to clear record.
   - At 2 Stars: Pay ৳ 1,500 legal bail and fine.
   - At 3+ Stars: Armed felon warning! Desk officer sounds station alarm; all station units immediately engage suspect.
2. **Impound Yard (`ImpoundYard`)**:
   - `[E] Retrieve Impounded Vehicle (৳ 250)`
   - Retrieves or unlocks confiscated vehicles from the secure compound yard.
3. **Restricted Armory Zone (`RestrictedZone`)**:
   - Secured wing marked with `sign_restricted_armory.png`.
   - Entering triggers `facility_trespass_detected`, gives 2 wanted stars for trespassing, and alerts station guards.

---

## 7. Police Checkpoint & Roadblock Architecture

Deployed at canal bridges and major arterial choke points:
- **Barricades**: Concrete and steel barriers with diagonal hazard stripes (`checkpoint_barrier_stripes.png`).
- **Gantry Signboard**: Reflective overhead signboard ("ডিএমপি পুলিশ চেকপোস্ট — থামুন").
- **Hazard Strobes**: Alternating amber and crimson warning lights.
- **Dynamic Tire Spike Strip (`SpikeStripArea`)**:
  - Activates when Wanted Level $\ge 3$.
  - When suspect vehicle drives over spikes:
    - Audio triggers `spike_puncture.wav`.
    - Max speed is severely capped ($24\text{km/h}$).
    - Steering authority is reduced by $60\%$.
    - Destabilizing rotational torque impulse is applied, causing tire skidding.
    - Checkpoint guards open fire.

---

## 8. Playable Test Scenario (`tests/test_police_system.tscn`)

The dedicated diagnostic test scene allows comprehensive interactive verification of all police subsystems:

### Keyboard Diagnostic Controls:
| Key | Action | Subsystem Tested |
|---|---|---|
| `[1]` | Commit Minor Theft | 1-Star wanted level, foot officer approach |
| `[2]` | Brandish Weapon in Public | 1-Star public panic, witness warning |
| `[3]` | Firearm Discharge | 2-Star gun sound propagation, 999 witness call |
| `[4]` | Vehicular Hit & Run | 3-Star vehicular crime, cruiser high-speed pursuit |
| `[5]` | Assault DMP Police | 4-5 Star maximum tactical lockdown, armed response |
| `[C]` | Clear Wanted Level | Peaceful surrender / complete heat reset |
| `[T]` | Teleport to Police Thana | Front desk surrender, bail, impound, armory trespass |
| `[B]` | Teleport to Canal Bridge Checkpoint | Roadblock barricade, spike strip puncture |
| `[E]` | Interact / Board Vehicles | Mounting sedan, talking to duty officer |
| `[Shift]` | Sprint | Evasion locomotion, stamina expenditure |
| `[Right Click]` | Aim Weapon | Brandishing detection, over-the-shoulder camera |
| `[Left Click]` | Shoot Pistol | Gunshot projectile, firearm crime detection |

### Live Telemetry Dashboard:
- Real-time heat star rating (★ / ☆).
- Pursuit State (`PEACEFUL`, `PURSUIT`, `SEARCHING_EVADING`, `ARRESTED`).
- Line-of-sight status (`SPOTTED` vs `HIDDEN`).
- Evasion cooldown timer and required time.
- Search zone radius and suspect distance from center.
- Distance to nearest police officer and nearest cruiser.
- Recent crime event and 999 witness reporting log.
