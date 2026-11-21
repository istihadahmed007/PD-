# ASSET LICENSING & INTELLECTUAL PROPERTY REPORT
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Compliance & Legal Clearance Audit — Phase 00 Foundation**  
**Godot Target**: Godot 4.x Forward+

---

## 1. Executive Summary & Legal Framework

This report details the licensing obligations, intellectual property (IP) boundaries, and asset provenance of both the inherited reference code from GDQuest and the upcoming original assets for the Bangladesh Open-World Game.

**Core Findings**:
1. **GDQuest Source Code** is licensed under the permissive **MIT License**. It may be freely modified, refactored, extended, commercialized, and distributed, provided copyright notices are retained.
2. **GDQuest Art Assets (3D models, textures, animations)** are licensed under **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC-BY-NC-SA 4.0)**. 
   - **Crucial Restriction**: The NonCommercial clause legally prevents these art assets from being used in any commercial release, monetization scheme, or paid distribution. The ShareAlike clause requires any derivative art to be shared under the same license.
   - **Action**: All GDQuest art assets are strictly treated as **internal development placeholders** and must be 100% replaced with original assets before commercialization or public release.
3. **Third-Party Trademarks**: No assets, characters, audio tracks, brand names, or logos from Rockstar Games' *Grand Theft Auto (GTA)* franchise may be used. All branding, storylines, and assets will be 100% original, inspired by real-world Bangladesh culture, geography, and urban society.

---

## 2. Granular Asset Inventory & Provenance

### 2.1 Source Code, Scene Files & Shaders
- **Files**: All `.gd` scripts, `.tscn` scene files, `.tres` resources, and `.gdshader` files.
- **Copyright Holder**: © 2023-present GDQuest
- **License**: MIT License
- **Permitted Uses**: Commercial use, modification, distribution, private use, sublicensing.
- **Requirements**: Include original GDQuest copyright notice in third-party attribution documents.
- **Project Treatment**: Reused, refactored, and modularized as architectural scaffolding.

### 2.2 3D Models & Mesh Assets
| Asset Path | Description | Existing License | Production Action |
|---|---|---|---|
| `player/gdbot/gdbot.glb` | GDQuest Mascot Robot model & animations | CC-BY-NC-SA 4.0 | **PLACEHOLDER ONLY**. Replace with rigged Bengali protagonist character (custom outfit: Lungi / Kurta / Streetwear). |
| `enemies/beetle_bot/beetle_bot_fused.glb` | Four-legged mechanical beetle | CC-BY-NC-SA 4.0 | **PLACEHOLDER ONLY**. Replace with human NPC / rival gang member / stray animal models. |
| `enemies/bee_bot/bee_bot.glb` | Flying mechanical bee | CC-BY-NC-SA 4.0 | **PLACEHOLDER ONLY**. Replace with surveillance drone / rival vehicle / combatant. |
| `level/terrain.glb` | Stylized fantasy floating island | CC-BY-NC-SA 4.0 | **REPLACE IMMEDIATELY**. Replaced with modular CSG city blocks and Bangladesh terrain chunks. |
| `level/mushroom/mushroom.glb` | Fantasy bouncing mushroom | CC-BY-NC-SA 4.0 | **REPLACE**. Replaced with urban props (air conditioner units, dumpster lids, awnings). |
| `level/box/box.tscn` | Stylized wooden crate | CC-BY-NC-SA 4.0 | **REPLACE**. Replaced with corrugated iron tea-stall boxes, wooden vegetable crates. |
| `level/trees/` & `level/bushes/` | Stylized fantasy flora | CC-BY-NC-SA 4.0 | **REPLACE**. Replaced with Banyan (Bot Gach), Mango, Palm, and urban sidewalk trees. |

### 2.3 2D Textures & Materials
- `shared/textures/eye_mask.png`, `player/gdbot/texture/*`: CC-BY-NC-SA 4.0. Confined to testing scenes.
- `level/water/textures/caustic_texture.png`: Procedural noise / CC-BY-NC-SA. To be replaced with original procedural noise generator or CC0 texture.
- `level/gridbox_texture.png`: Prototyping grid texture. MIT / CC0 compliant; excellent for technical level blockouts.

### 2.4 Audio Assets
- `level/music/mountain.mp3`: CC-BY-NC-SA 4.0 / Freesound. Retained for sandbox debug; will be replaced by original Bangladesh urban soundscapes, Bengali folk/rock radio, and localized city ambiance.
- Sound FX (`poof`, `mechanical`, `lasershot`, `musket-explosion`, `step_grass`, `landing`): CC0 / CC-BY audio from Freesound.org. Clean for prototyping; will be supplemented with field-recorded Dhaka street sounds (rickshaw bells, CNG 2-stroke exhaust, crowd calls).

### 2.5 Typography & Fonts
- `menu/fonts/Montserrat-Bold.ttf`, `Montserrat-Medium.ttf`:
  - **License**: SIL Open Font License 1.1 (OFL)
  - **Permitted Uses**: Free commercial and non-commercial use, bundling with software.
  - **Status**: 100% compliant for production use. Bengali localization will integrate open-source Bengali fonts (e.g., *Noto Sans Bengali*, *Hind Siliguri*, or *Anek Bangla* under OFL).

---

## 3. Strict Intellectual Property & Trademark Protection Rules

To prevent any infringement or trademark disputes with Take-Two Interactive / Rockstar Games or local commercial entities:

1. **Title & Branding**:
   - The game shall NOT be titled "Grand Theft Auto", "GTA Bangladesh", or copy Rockstar's trademarked logo presentation (Pricedown font, distinct border styling).
   - Recommended Project Names:
     - *DTA: Dhaka Traffic Action*
     - *Project Sonar Bangla*
     - *Dhaka Underworld / Purono Dhaka*
     - *Bengal Reckoning*
2. **Original Characters & Storyline**:
   - All characters, narrative dialogue, crime syndicates, and political factions must be entirely fictional.
   - Inspiration will be drawn from authentic Dhaka urban folklore, rickshaw culture, riverfront trade, and university campus life.
3. **Law Enforcement Branding**:
   - Law enforcement units are styled after generic Bangladesh law enforcement (e.g., "Metropolitan Police", "City Patrol") with original fictional badge and decal designs.
4. **Vehicles & Fictional Brands**:
   - Real-world vehicle trademarks (Toyota, Bajaj, Mahindra, Scania) will NOT be used directly.
   - Fictional parody brands inspired by South Asian culture will be designed (e.g., *"Bijoy Motors"*, *"Padma Express"*, *"Sonar Chaka"* for rickshaws).
   - Commercial products (tea, biscuits, soft drinks) will feature original parodies (e.g., *"Taaza Cha"*, *"Boro Bhai Cola"*).

---

## 4. Phase-by-Phase Asset Replacement Protocol

```
[Phase 00: Foundation & Audit]
  └── Reference assets preserved in `reference_original/`
  └── Prototyping uses CSG primitives & placeholder mechanics

[Phase 01–03: Core Locomotion & Vehicles]
  └── Import CC0/Original 3D Blockouts for Rickshaw & CNG
  └── Replace GDBot with Rigged Human Base Mesh (Mixamo/MakeHuman or custom CC0)

[Phase 04–06: Urban Crowd & Traffic]
  └── Import original Bengali attire characters (Lungi, Panjabi, Saree, Salwar)
  └── Establish custom field audio library for Dhaka city sounds

[Phase 07–10: Final Art & Commercial Polish]
  └── 100% of CC-BY-NC-SA 4.0 assets eradicated from release branches
  └── Final legal clearance and attribution manifest generated
```

---

## 5. Compliance Certification

By segregating all third-party reference assets into `reference_original/` and implementing an architectural replacement pipeline, this project maintains clean-room separation between reusable open-source code (MIT) and restricted non-commercial art assets (CC-BY-NC-SA). The project is positioned for unencumbered development and future commercialization.
