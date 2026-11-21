# PART 01 — PLAYER CONTROLLER & CHARACTER SYSTEM ARCHITECTURE
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Technical Director & Character Architect Documentation**  
**Godot Target**: Godot 4.x Forward+ | GDScript 2.0 (Statically Typed)

---

## 1. Executive Summary

In Part 01, we rebuilt and modernized the player locomotion, independent camera, and character animation systems. The cartoon robot baseline from the GDQuest prototype has been superseded by a realistic contemporary Bangladeshi protagonist with natural humanoid proportions (~1.78m), contemporary Dhaka streetwear, an independent collision-avoiding follow camera, smooth stair step-up climbing, slope slip prevention, and fluid cross-faded animations across 13 distinct states.

---

## 2. Movement & Locomotion Architecture

### 2.1 Velocity Tiers & Acceleration
The locomotion controller in `player/player.gd` implements three distinct forward velocity tiers:

| Locomotion State | Target Speed | Input Requirement | Stamina Behavior | Animation Sync |
|---|---|---|---|---|
| **Idle** | 0.0 m/s | No input | Passive recovery (+16/s) | `idle` (breathing, weight shift) |
| **Walk** | 3.2 m/s | Light analog stick tilt or walk modifier | Passive recovery (+16/s) | `walk` (1.0s natural stride) |
| **Jog / Run** | 7.0 m/s | Standard WASD / Full analog stick tilt | Neutral / Slow recovery | `run` (0.7s athletic jog, forward tilt) |
| **Sprint** | 12.5 m/s | Holding Shift / Gamepad L3 | Depletes (-22/s) | `sprint` (0.52s aggressive 18° lean) |

Movement applies smooth vector lerping:
- **Acceleration**: `velocity.lerp(target_velocity, acceleration * delta)` (rate = 9.0)
- **Deceleration**: Natural gradual roll-off (rate = 11.0) with an anti-sliding deadzone below 0.8 m/s.
- **Directional Slerp**: Quaternionic slerping (`rotation_speed = 14.0`) smoothly rotates the character towards the velocity vector without snapping.

### 2.2 Stairs & Slopes Engine
1. **Stair Step-Up Algorithm**:
   Standard Godot `CharacterBody3D` snags on vertical stair risers (>0.1m). We implemented a 2-stage kinematic probe using `test_move()`:
   ```gdscript
   func _handle_stair_step_up(delta: float) -> void:
       if not is_on_floor() or _move_direction.length() < 0.1:
           return
       var horizontal_motion := Vector3(velocity.x, 0.0, velocity.z) * delta
       var collision := KinematicCollision3D.new()
       if test_move(global_transform, horizontal_motion, collision):
           var step_up_transform := global_transform.translated(Vector3(0, max_step_height, 0))
           if not test_move(step_up_transform, horizontal_motion):
               var down_collision := KinematicCollision3D.new()
               if test_move(step_up_transform.translated(horizontal_motion), Vector3(0, -max_step_height, 0), down_collision):
                   var step_lift := max_step_height + down_collision.get_travel().y
                   if step_lift > 0.02 and step_lift <= max_step_height:
                       global_position.y += step_lift
                       apply_floor_snap()
   ```
   This allows fluid ascent of stair risers up to `max_step_height = 0.35m` (e.g. Dhaka pedestrian overbridge stairs).
2. **Downward Stair Adhesion & Slopes**:
   - `floor_snap_length = 0.4m`: Character remains glued to stair steps and descending slopes without launching into unwanted falling states.
   - `floor_stop_on_slope = true`: Completely prevents sliding down steep slopes when standing idle.
   - `floor_constant_speed = true`: Maintains identical speed climbing up or down ramps.
   - `floor_max_angle = deg_to_rad(48.0)`: Up to 48° walkable inclines.

### 2.3 Jumping, Air Control & Impact Recovery
- **Jump Buffering**: Inputs pressed within 0.15s prior to touching the floor execute instantly upon landing.
- **Coyote Time**: Player can jump up to 0.12s after walking off a ledge.
- **Variable Jump Height**: Releasing jump early truncates vertical impulse; holding jump applies upward thrust up to apex.
- **Landing Recovery (Hard Landings)**:
  - If airborne for >0.85s or vertical velocity exceeds `-14.0 m/s`, landing triggers `hard_land`.
  - Player absorbs shock with deep knee flexion and ground touch for 0.45s, during which movement speed is temporarily reduced to 40% before springing back to full speed.

---

## 3. Independent Third-Person Camera Architecture

Located at `player/camera_controller.gd`:

```
CameraController (Node3D, top_level = true)
     │
     ├── Follow Smoothing (global_position.lerp(target, 18.0 * delta))
     ├── Ground Height Damping (eliminates curb/step camera bounce)
     │
     ├── CameraSpringArm (SpringArm3D with SphereShape3D radius 0.22m)
     │        └── CameraThirdPersonPivot (Marker3D, orbit distance)
     │
     ├── CameraOverShoulderPivot (Marker3D, right shoulder aim offset)
     │
     └── PlayerCamera (Camera3D)
              └── CameraRayCast (100m aim line-of-sight probe)
```

### Key Camera Innovations:
1. **Dual-Pivot Continuous Slerp**:
   Instead of snapping between third-person orbit and over-the-shoulder aiming, the camera interpolates position, rotation, and offsets continuously using `interpolate_with()` based on `_aim_blend`:
   $$\text{Transform}_{\text{cam}} = \text{Transform}_{\text{orbit}} \cdot (1 - \alpha) + \text{Transform}_{\text{shoulder}} \cdot \alpha \quad (\alpha \in [0, 1])$$
2. **Sphere-Cast Collision Avoidance**:
   Replaced the raycast with `SphereShape3D` (`radius = 0.22m`, `margin = 0.15m`) inside `SpringArm3D`. Prevents camera clipping into narrow alley walls, door frames, and building corners.
3. **Dynamic Speed-Based FOV**:
   - Aiming: **48.0°** (telephoto tactical precision)
   - Exploring / Walking / Jogging: **72.0°** (natural human field of view)
   - Sprinting: **82.0°** (dynamic visual speed sensation)
4. **Independent Smoothing**:
   Camera position follows player with `18.0 * delta` lag; vertical height tracks ground elevation with `10.0 * delta` damping to completely eliminate stair stepping vibration.

---

## 4. Visual Direction & Character Rig

### 4.1 Proportions & Cultural Identity
- **Height**: 1.78 meters (Capsule height: 1.8m, radius: 0.35m).
- **Attire (Contemporary Dhaka Streetwear)**:
  - Dark Navy Blue Casual Jacket with leather collar detail (`Mat_Jacket`).
  - Contemporary Indigo Denim Jeans (`Mat_Jeans`).
  - Modern Street Sneakers with white/dark accents (`Mat_Sneakers`).
  - South Asian skin tone (`Mat_Skin`) with realistic warm undertones.
  - Contemporary styled dark textured crop haircut (`Mat_Hair`).
- **Zero Cartoon Styling**: Anatomically correct humanoid bone hierarchy with natural joint offsets.

### 4.2 Animation State Library (`characters/player/humanoid_character_skin.tscn`)
Configured with an `AnimationPlayer` using default cross-fade blend time of **0.15s** to guarantee zero animation popping:

1. `idle`: Subtle rhythmic breathing (chest translation 0.015m, 2.4s cycle), subtle weight shifts.
2. `walk`: 1.0s loop calibrated for 3.2 m/s; alternating leg swing, counter-arm swinging, footstep audio triggers at 0.25s and 0.75s.
3. `run`: 0.7s loop calibrated for 7.0 m/s; forward torso tilt, bent arm pumping, footstep triggers at 0.18s and 0.52s.
4. `sprint`: 0.52s loop calibrated for 12.5 m/s; athletic 18° forward lean, high knee drive, footstep triggers at 0.13s and 0.39s.
5. `jump_air`: Airborne hang pose with balanced outstretched arms.
6. `fall`: Downward descent pose with trailing legs.
7. `land`: 0.35s knee shock absorption and rebound.
8. `hard_land`: 0.65s deep impact compression with ground touch recovery.
9. `turn_left` & `turn_right`: 0.3s hip pivot and foot repositioning.
10. `interact`: 0.55s right arm extension to touch/press objects.
11. `enter_vehicle`: 0.75s door reach, body turn, and seated positioning.
12. `exit_vehicle`: 0.75s standing up out of driver seat onto ground.

---

## 5. Dedicated Verification Environment (`tests/test_character_locomotion.tscn`)

The dedicated test suite includes 6 diagnostic stations and a live telemetry HUD:

1. **Speed Calibration Lanes**: Flat asphalt lanes with 10m, 25m, and 50m line markers to measure exact velocities.
2. **Stairs Course**:
   - Gentle Stairs: 4 steps, 0.15m risers.
   - Standard Dhaka Overbridge: 8 steps, 0.22m risers.
   - Steep Stairs: 6 steps, 0.30m risers.
3. **Slope Course**:
   - 15° Gentle incline.
   - 30° Moderate ramp.
   - 45° Steep incline.
4. **Ledge & Drop Chamber**:
   - 1.5m Ledge: Standard jump and soft landing.
   - 5.0m Rooftop Drop: Triggers hard landing recovery with knee compression and temporary deceleration.
5. **Narrow Alleyway**: 1.8m wide, 4.0m tall brick walls with a 90° corner to test camera obstruction clearance without clipping.
6. **Live Telemetry HUD**: Real-time display of horizontal/vertical velocity, active locomotion state, stamina, ground slope angle, and camera FOV.

---

## 6. Changed & Created File Index

| File Path | Action | Description |
|---|---|---|
| `characters/player/humanoid_character_skin.gd` | **CREATED** | Master humanoid character skin controller with 13 locomotion states, turn lean, and footstep triggers. |
| `characters/player/humanoid_character_skin.tscn` | **CREATED** | 3D contemporary Bangladeshi humanoid mesh, materials, and 13 keyframed animations. |
| `player/player.gd` | **MODIFIED** | Upgraded with walk/jog/sprint tiers, stamina, 2-stage stair step-up, slopes, variable jump, and landing recovery. |
| `player/player.tscn` | **MODIFIED** | Linked to `humanoid_character_skin.tscn` as active character skin. |
| `player/camera_controller.gd` | **MODIFIED** | Upgraded with continuous slerp blending, sphere-cast collision avoidance, dynamic FOV, and ground damping. |
| `tests/test_character_locomotion.gd` | **CREATED** | Controller script for locomotion telemetry, objective tracking, and diagnostics. |
| `tests/test_character_locomotion.tscn` | **CREATED** | Dedicated playable test environment with stairs, slopes, drop ledges, narrow alleys, and telemetry overlay. |
| `project.godot` | **MODIFIED** | Configured `test_character_locomotion.tscn` as main scene and registered input bindings. |
| `docs/player_controller_architecture.md` | **CREATED** | Complete Part 01 technical architecture documentation. |
