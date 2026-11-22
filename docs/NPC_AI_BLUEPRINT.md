# NPC & TRAFFIC AI BLUEPRINT: GTA BANGLADESH
## Pedestrian Behaviors, Traffic Network & Police Pursuit Simulation

---

### 1. Pedestrian Artificial Intelligence Architecture

```
                                ┌─────────────────────────┐
                                │      Idle / Social      │
                                │ (Stands, Chats, Phones) │
                                └────────────┬────────────┘
                                             │
                        ┌────────────────────┴────────────────────┐
                        ▼                                         ▼
                 ┌─────────────┐                           ┌─────────────┐
                 │ Walk Route  │                           │ React Alert │
                 │ (Sidewalks) │                           │ (Gun/Crash) │
                 └──────┬──────┘                           └──────┬──────┘
                        │                                         │
                        │                                         ▼
                        │                                  ┌─────────────┐
                        │                                  │ Flee Panic  │
                        │                                  │ (Sprint Away│
                        │                                  └──────┬──────┘
                        │                                         │
                        ▼                                         ▼
                 ┌───────────────────────────────────────────────────────┐
                 │                Ragdoll / Impact State                 │
                 │                 (Vehicle Collisions)                  │
                 └───────────────────────────────────────────────────────┘
```

#### Pedestrian Archetypes:
1. **Old Dhaka Residents**: Elder shopkeepers in Lungi and Kurta, street tea drinkers.
2. **Students & Commuters**: Modern attire, smartphones, backpacks, conversational clusters.
3. **Street Vendors**: Chotpoti carts, newspaper sellers, flower vendors at traffic lights.
4. **Police Officers**: Thana guards and highway patrol with batons and holstered sidearms.

---

### 2. Urban Traffic Flow Simulation

- **Spline Road Graphs**: Pre-computed road nodes connected by 3D curve paths indicating lane direction, speed limit (`30 km/h` in alleys, `60 km/h` on avenues, `90 km/h` on highways), and turn options.
- **Sensor Rays**: Each AI vehicle projects forward detection rays (`12m` at speed, `4m` at idle) to check for:
  - Lead vehicles (matches speed and maintains 3m bumper spacing).
  - Crossing pedestrians (applies emergency brake).
  - Red traffic lights (brings vehicle to a stop behind crosswalk line).
- **Traffic Junction Resolution**:
  - Automated 3-phase traffic signals: `Green` (40s), `Yellow` (4s), `Red` (44s).
  - Unsignaled junctions resolve through yield priorities (buses > sedans > CNGs > rickshaws).

---

### 3. Police Pursuit & Heat Escalation Model

```
[Wanted Level] ──► [Patrol Units] ──► [Search Cone] ──► [Escalation Action]
     ★             1 Foot Patrol         50m Cone         Verbal warning, fine
     ★★            2 Sedans              120m Cone        Siren pursuit, pit maneuver
     ★★★           4 Sedans + SUV        200m Cone        Roadblocks, tactical ramming
     ★★★★          SWAT Pickups          280m Cone        Spike strips, high-caliber fire
     ★★★★★         Heavy Armored Units   360m Radius      Full military / RAB-style lockdown
```

- **Line-of-Sight Evasion**: When the player escapes all active police cones, stars begin blinking. If the player remains hidden for 25 seconds, heat drops to 0.
- **Non-Teleporting Spawners**: Police units spawn along the road graph outside camera view frustum and navigate organically to the crime location.
