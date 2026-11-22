# VEHICLE SYSTEM BLUEPRINT: GTA BANGLADESH
## Realistic Vehicle Drivetrain, Handling Physics & Bangladesh Vehicle Fleet

---

### 1. Vehicle Physics Simulation Architecture

GTA Bangladesh uses a customized raycast suspension and physics simulation architecture on top of Godot's physics engine:

```
                          ┌───────────────────────┐
                          │   Throttle / Brake    │
                          │   Steer Input [WASD]  │
                          └───────────┬───────────┘
                                      │
                                      ▼
                          ┌───────────────────────┐
                          │   Engine Torque Curve │
                          │   6-Speed Automatic   │
                          └───────────┬───────────┘
                                      │
                 ┌────────────────────┴────────────────────┐
                 ▼                                         ▼
      ┌─────────────────────┐                   ┌─────────────────────┐
      │   Front Axle        │                   │    Rear Axle        │
      │   Ackermann Steer   │                   │    Drive Differential│
      │   Suspension Spring │                   │    Traction & Drift │
      └─────────────────────┘                   └─────────────────────┘
                 │                                         │
                 └────────────────────┬────────────────────┘
                                      ▼
                          ┌───────────────────────┐
                          │   Weight Transfer &   │
                          │   Body Roll / Pitch   │
                          └───────────────────────┘
```

#### Physical Forces Modeled:
1. **Suspension Travel**: Raycast-based spring and damper simulation (spring length: `0.35m - 0.55m`, stiffness: `40.0 - 90.0`, damping: `3.5 - 8.0`).
2. **Tire Friction Model**:
   - Lateral friction curve modeled for realistic grip loss during hard steering or handbrake pulls.
   - Wetness modifier: Rain reduces friction coefficients by `35%`, increasing stopping distance and drift slip.
3. **Transmission Simulation**:
   - 6-speed automatic transmission with realistic gear ratios and automatic upshift/downshift based on RPM.
   - Reverse gear with dedicated reverse lighting and backup beeper for commercial trucks and buses.

---

### 2. Authentic Bangladesh Vehicle Roster

| Vehicle Type | Mass (kg) | Top Speed | Handling Characteristics & Audio Identity |
| :--- | :--- | :--- | :--- |
| **Cycle Rickshaw** | `140 kg` | `24 km/h` | Lightweight, high agility in narrow alleys, rhythmic bell ding, human pedaling effort |
| **CNG Auto-Rickshaw** | `380 kg` | `68 km/h` | 3-wheel configuration, low center-of-mass to prevent rollover, distinctive 2-stroke engine buzz |
| **Local Murir Tin Bus** | `7,200 kg` | `82 km/h` | High inertia, slow acceleration, hydraulic air horn blasts, colorful painted metal body |
| **Urban Private Sedan** | `1,450 kg` | `155 km/h` | Balanced grip, responsive braking, comfortable cruising on major avenues |
| **Police Patrol Sedan** | `1,580 kg` | `175 km/h` | High-torque engine, bullbar armor ramming power, multi-tone wail siren and strobe lights |
| **150cc Commuter Bike** | `135 kg` | `125 km/h` | High acceleration, counter-steering lean angles, lane-filtering through traffic jams |
| **Delta Pickup Truck** | `2,200 kg` | `130 km/h` | Rugged all-terrain suspension, flatbed cargo capacity, high torque in muddy roads |

---

### 3. In-Car Interaction & Controls

- **`[E]`**: Enter / Exit vehicle (with seat transition and camera blend).
- **`[Space]`**: Handbrake / Drift slide.
- **`[H]`**: Vehicle Horn (distinctive horns: Cycle bell, CNG beep, Bus air horn, Police siren).
- **`[L]`**: Headlights toggle (Low Beam / High Beam / Off).
- **`[R]`**: In-Car Radio Station tuner (Dhaka FM 90.4, Buriganga Beats, News 24, Radio Shadhin).
- **`[V]`**: Camera view cycle (Close Chase, Far Chase, Hood/Cockpit Cam).
