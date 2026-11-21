# DTA: DHAKA THEFT AUTO — ASSET LICENSE & INTELLECTUAL PROPERTY LEDGER
**Project**: *DTA: Dhaka Theft Auto*  
**Engine**: Godot Engine 4.x Forward+ / Jolt 3D Physics  
**Release Target**: Windows Desktop (x86_64)  
**Standard**: 100% Original, Procedural, Synthesized, or CC0 Licensed Assets  

---

## 1. STATEMENT OF ORIGINALITY & NON-INFRINGEMENT

*Dhaka Theft Auto* is an original open-world action-adventure game inspired by the geographical, cultural, and socio-economic landscape of contemporary Bangladesh. It contains **zero copied assets, dialogue, character models, code, or proprietary storylines** from *Grand Theft Auto (GTA)*, Rockstar Games, Take-Two Interactive, or any commercial third-party franchise.

All proprietary and procedural assets created for the project adhere to the following license structure:

| Asset Category | Origin / Generation Pipeline | License Status | Commercial Use Allowed |
| :--- | :--- | :--- | :--- |
| **Source Code (GDScript)** | Original game engineering written specifically for DTA | MIT License / Proprietary | Yes |
| **3D Meshes & CSG Geometry** | Procedural CSG and original parametric 3D meshes | CC0 1.0 Universal / Original | Yes |
| **PBR Shaders & Materials** | Original spatial shaders (`realistic_pbr_road.gdshader`, `realistic_water.gdshader`, `foliage_wind.gdshader`) | MIT License | Yes |
| **Audio & SFX** | Synthesized WAV audio suite (engines, horns, weather, footsteps, sirens, ambience) | CC0 1.0 Universal / Original | Yes |
| **Soundtrack & Radio Music** | Procedurally synthesized multi-track WAV music (`main_theme.wav`, `radio_padma_rock.wav`, etc.) | CC0 1.0 Universal / Original | Yes |
| **Character Portraits & 2D Art** | Original SVG/PNG procedural portraits and Bengali signboards | CC0 1.0 Universal / Original | Yes |

---

## 2. DETAILED ASSET BREAKDOWN

### 2.1 Audio Assets (`res://audio/`)
All audio files were synthesized at 44.1 kHz, 16-bit mono/stereo using pure mathematical frequency modulation, additive harmonic synthesis, formant filter models, and noise shaping.

- **Footsteps & Player Locomotion** (`audio/player/`):
  - `footstep_asphalt_1.wav` through `footstep_asphalt_4.wav`: Synthesized asphalt impact grit and low-frequency thumps.
  - `footstep_puddle_1.wav`, `footstep_puddle_2.wav`: Dual-resonance bubble pop and water surface slosh.
  - `jump_effort.wav`, `land_impact.wav`: Effort grunt and heavy physical body impact.
- **Environmental Ambience** (`audio/ambient/`):
  - 7 regional ambient beds (`ambient_dhaka_city.wav`, `ambient_padma_river.wav`, `ambient_sylhet_hills.wav`, `ambient_chattogram_port.wav`, `ambient_cox_ocean.wav`, `ambient_sundarbans_jungle.wav`, `ambient_rural_fields.wav`).
- **Vehicle Audio** (`audio/vehicles/`):
  - Procedural combustion loop synthesis for Sedan, Rickshaw, CNG Auto-Rickshaw, Local Bus, SUV, and Motorcycle.
  - 5 distinct horns: `horn_bike.wav`, `horn_bus_air.wav`, `horn_cng.wav`, `horn_sedan.wav`, `horn_suv.wav`.
  - Tire screeching and collision impact audio (`tire_skid.wav`, `vehicle_impact.wav`).
- **Weather Audio** (`audio/weather/`):
  - Heavy tropical downpour loop on asphalt/tin (`rain_monsoon_loop.wav`).
  - Sudden electrical lightning strikes and thunder rumbles (`thunder_strike_1.wav`, `thunder_strike_2.wav`).
  - Gusting storm monsoon winds (`wind_storm.wav`).
- **Original Soundtrack & Radio Stations** (`audio/music/`):
  - `main_theme.wav`: Driving synth-rock theme with traditional Bengali D-minor chord progression.
  - `radio_padma_rock.wav`: Distorted guitar overdrive and drum kit.
  - `dhaka_beats_hiphop.wav`: 808 sub-bass and syncopated dholak percussion.
  - `surma_folk.wav`: Traditional Dotara string plucks and acoustic river flute.

### 2.2 Textures & Graphic Assets (`res://assets/textures/`)
- Character portraits (`portrait_joy.png`, `portrait_kabir.png`, `portrait_nila.png`, `portrait_mahfuz.png`, `portrait_tariq.png`, `portrait_rahmat.png`): Custom digital character art.
- Commercial shop signboards (`bismillah_store_sign.png`, `mama_tong_sign.png`, `rupali_bank_sign.png`, `lalbagh_tailors_sign.png`, `bhai_bhai_workshop_sign.png`): Original typography using Bengali Unicode script.
- Police door decals (`police_door_decal.png`): Original Dhaka Metropolitan Police (DMP) delta emblem and bilingual insignias.

### 2.3 3D Character Controller Foundation
- Locomotion state machine and camera rig derived from GDQuest's open-source Godot 4 3D Third-Person Controller demo, licensed under the **MIT License**.
- Full character models, skins, physics controllers, vehicle mounts, and combat systems are original creations.

---

## 3. ENGINE & RUNTIME LIBRARIES

- **Godot Engine**: Copyright (c) 2014-present Godot Engine contributors. Licensed under the **MIT License**.
- **Godot Jolt (Physics Engine)**: Copyright (c) 2023-present Mihe and contributors. Licensed under the **MIT License**.
