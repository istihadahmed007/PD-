# GAMEPLAY SYSTEMS BLUEPRINT: GTA BANGLADESH
## AAA Character Locomotion, Interaction, Combat & Inventory Design

---

### 1. Player Character Locomotion Architecture

```
                    ┌─────────────────────────┐
                    │      Input Vector       │
                    │   (WASD / Gamepad Stick)│
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Camera-Relative Heading │
                    └────────────┬────────────┘
                                 │
            ┌────────────────────┼────────────────────┐
            ▼                    ▼                    ▼
     ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
     │    Walk     │      │     Run     │      │   Sprint    │
     │  (2.2 m/s)  │      │  (4.8 m/s)  │      │  (7.8 m/s)  │
     └─────────────┘      └─────────────┘      └──────┬──────┘
                                                      │ (Stamina Drain)
                                                      ▼
                                               ┌─────────────┐
                                               │   Stamina   │
                                               │  Depleted   │
                                               └─────────────┘
```

#### Key Movement Parameters:
- **Walk Speed**: `2.2 m/s` (Realistic urban pedestrian pace)
- **Run Speed**: `4.8 m/s` (Jogging/steady travel)
- **Sprint Speed**: `7.8 m/s` (Full athletic sprint, consumes 22.0 stamina/sec)
- **Crouch Speed**: `1.6 m/s` (Low profile, stealth, reduced police detection radius)
- **Jump Velocity**: `6.5 m/s` (Buffered with 0.15s Coyote Time)
- **Hard Landing Impact**: Velocity thresholds above `-12.0 m/s` trigger recovery delay (`0.35s`)
- **Stair Step-Up**: Raycast-assisted step climbing (up to `0.35m` curbs and steps without jumping)

---

### 2. Combat & Aiming Mechanics

1. **Aim Mode (`Right-Click`)**:
   - Camera pulls over right shoulder (shoulder peek toggle with `[V]`).
   - FOV narrows to `58°` with precision mouse sensitivity dampening.
   - Reticle transitions to high-contrast targeting dot.
2. **Melee Attack (`Left-Click`)**:
   - 3-hit combo sequence (Jab, Cross, Kick) with physical hit detection via forward SphereCast3D.
   - Impacts apply impulse force to dynamic props and trigger stagger on pedestrian NPCs.
3. **Weapon Handling**:
   - Weapon wheel selection or cycling (`[1] Unarmed`, `[2] Melee Wrench/Bat`, `[3] Pistol/Revolver`, `[4] Submachine Gun`).
   - Recoil climb with procedural camera shake and dispersion cone expansion.

---

### 3. Inventory & Economy System

- **Backpack Storage**: 16-slot grid holding consumable food (Singara, Cha, Biryani), tools, quest items, and cash rolls.
- **Health System**:
  - Max Health: `100.0 HP`
  - Health Regen: Recovers up to `50.0 HP` automatically when out of combat; full recovery requires tea stall food, pharmacy medicine, or safehouse sleep.
- **Stamina System**:
  - Max Stamina: `100.0 SP`
  - Consumed by sprinting and jumping; rapid recovery while walking or resting.

---

### 4. Interactive World Triggers

- **ATM Terminals (Rupali Bank 24/7)**: Deposit wallet cash into protected bank account; withdraw cash for street purchases.
- **Tong / Tea Stalls**: Buy hot Cha (৳20) and Singara (৳30) to restore stamina and health.
- **Auto Garages (Kabir Workshop)**: Vehicle repairs, custom paint jobs, ECU tuning for increased top speed.
- **Clothing Shops**: Switch between authentic Bangladesh outfits (Dhaka Casual, Panjabi Festive, Street Rebel, Formal Kurta, Syndicate Tracksuit).
