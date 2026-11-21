# DTA: DHAKA THEFT AUTO — INSTALLATION & USER GUIDE
**Platform**: Windows PC (Windows 10 / Windows 11 64-bit)  
**Version**: 1.0.0 (Gold Master Release)  
**Engine**: Godot Engine 4.x Forward+ / Jolt Physics  

---

## 1. SYSTEM REQUIREMENTS

### Minimum Specifications (Low Preset, 720p / 1080p 30-60 FPS)
- **OS**: Windows 10 64-bit (Version 1909 or higher)
- **Processor**: Intel Core i3-6100 / AMD Ryzen 3 1200
- **Memory**: 8 GB RAM
- **Graphics**: Intel Iris Xe Graphics / NVIDIA GeForce GTX 750 Ti / AMD Radeon RX 550
- **DirectX / Vulkan**: Vulkan 1.2 compatible GPU
- **Storage**: 2 GB available space

### Recommended Specifications (High / Ultra Preset, 1080p / 1440p 60 FPS)
- **OS**: Windows 10 / 11 64-bit
- **Processor**: Intel Core i5-10400 / AMD Ryzen 5 3600
- **Memory**: 16 GB RAM
- **Graphics**: NVIDIA GeForce GTX 1660 Super / RTX 2060 / AMD Radeon RX 5600 XT (6 GB VRAM)
- **DirectX / Vulkan**: Vulkan 1.2+ hardware support
- **Storage**: 4 GB available SSD space

---

## 2. INSTALLATION & LAUNCH INSTRUCTIONS

### Running from Pre-Configured Godot 4 Editor
1. Install **Godot Engine 4.x (Standard 64-bit with .NET or Standard C++)**.
2. Open Godot Engine and click **Import**.
3. Browse to the root project folder containing `project.godot`.
4. Click **Import & Edit**.
5. Press **`F5`** or click the **Play** button in the top-right corner to launch the game.
   The game will immediately boot into the cinematic **Main Menu** (`ui/menu/main_menu.tscn`).

### Running the Windows Standalone Binary
1. Open the project in Godot 4.
2. Navigate to **Project -> Export...**.
3. Select the **Windows Desktop** preset (`export_presets.cfg` is pre-configured).
4. Click **Export Project** and select output path `builds/windows/DhakaTheftAuto.exe`.
5. Launch `DhakaTheftAuto.exe` directly from Windows Explorer.

---

## 3. DEFAULT CONTROLS & KEYBOARD MAPPINGS

### Character Locomotion (On-Foot)
| Key / Input | Action |
| :--- | :--- |
| **`W`, `A`, `S`, `D`** | Move Character (Forward, Left, Backward, Right) |
| **`Shift` (Hold)** | Sprint (Drains stamina) |
| **`Space`** | Jump (Buffers input with coyote-time) |
| **`Right Mouse Button` (Hold)** | Aim Camera / Over-the-Shoulder Reticle |
| **`Left Mouse Button`** | Melee Attack / Fire Weapon |
| **`E`** | Interact (Enter vehicles, speak to NPCs, use ATMs, shop doors) |

### Vehicle Operation (Driving)
| Key / Input | Action |
| :--- | :--- |
| **`W`** | Throttle / Accelerate Forward |
| **`S`** | Foot Brake / Reverse (Automatic transmission) |
| **`A`, `D`** | Steer Left / Right |
| **`Space`** | Handbrake (Triggers drift skid smoke and slides) |
| **`E`** | Exit Vehicle |
| **`H`** | Sound Vehicle Horn |
| **`L`** | Toggle Headlights |
| **`R`** | Cycle In-Car Radio Station |

### Interface & Menus
| Key / Input | Action |
| :--- | :--- |
| **`ESC`** | In-Game Pause Menu / Back / Close Modals |
| **`I` / `Tab`** | Open 16-Slot Backpack Inventory |
| **`M`** | Open Fullscreen World Navigation Map (GPS & Fast Travel) |
| **`J`** | Open Mission Log & Narrative Dossier |
| **`F3`** | Toggle Real-Time Hardware Performance Profiler Overlay |

---

## 4. MULTI-SLOT SAVE & LOAD PERSISTENCE

The game supports 3 manual save slots plus an automated autosave slot:
- **Slot 1**: `user://dta_save_slot_1.json` (Also synchronizes to default `user://dta_savegame.json`)
- **Slot 2**: `user://dta_save_slot_2.json`
- **Slot 3**: `user://dta_save_slot_3.json`
- **Autosave**: `user://dta_save_autosave.json`

To save your progress:
1. Press **`ESC`** during gameplay to open the **Pause Menu**.
2. Click **Save Game...** and select **Slot 1**, **Slot 2**, or **Slot 3**.
3. All player coordinates, pocket cash (৳ BDT), bank savings, inventory slots, owned safehouses, vehicle custom paint/mods, active mission objectives, and world clock/weather are serialized immediately.
4. Sleeping in an owned safehouse (e.g. *Buriganga Riverview Flat*) advances the clock 6 hours, restores 100% health/stamina, and triggers an automatic game save.

---

## 5. GRAPHICS & PERFORMANCE TUNING

If experiencing framerate drops on integrated laptop graphics:
1. Press **`ESC`** and open **Settings... -> Graphics**.
2. Change **Graphics Preset** from `High` to `Medium` or `Low`.
   - **Low**: Disables SSAO, SSR, and Volumetric Fog; sets shadow mode to Orthogonal 70m.
   - **Medium**: Enables SSAO and Volumetric Fog; uses 2-split parallel CSM shadows (120m).
   - **High / Ultra**: Full PBR open-world standard with 4-split CSM shadows (160m), 32-step Screen-Space Reflections, and SSAO.
3. Set **Framerate Limit** to `60 FPS` to prevent GPU overheating.
