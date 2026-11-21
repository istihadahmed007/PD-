# DISTRICT 01: LALBAGH-BURIGANGA RIVERFRONT & BAZAAR DISTRICT
## Open-World District Architecture & Environmental Design Specification

**Project**: *DTA: Dhaka Theft Auto* (Project Sonar Bangla)  
**Engine & Pipeline**: Godot Engine 4.7 Forward+ / GDScript  
**Scene Path**: [district_01_padma_buriganga.tscn](file:///c:/Users/Tonmoy/Documents/DTA%200/scenes/districts/district_01_padma_buriganga.tscn)  
**Controller Path**: [district_01_padma_buriganga.gd](file:///c:/Users/Tonmoy/Documents/DTA%200/scenes/districts/district_01_padma_buriganga.gd)  
**Playable Footprint**: 400m × 400m (160,000 m²)  

---

## 1. GEOGRAPHICAL REFERENCE & CULTURAL GROUNDING

District 01 is an original, historically resonant open-world space reflecting the authentic topography, dense urban morphology, and social cadence of contemporary urban Bangladesh. Unlike generic Western open-world grids, it captures the living intersection between high-density concrete city life and alluvial riverbank culture:

1. **Old Dhaka (Puran Dhaka & Lalbagh)**:
   - Extremely tight, meandering brick-paved alleys (*Goli*) enclosed by high boundary walls and weathered plaster.
   - Chaotic verticality: overhead electrical wiring bundles, rooftop plastic water tanks, wall-mounted air conditioner compressors, and roadside drainage trenches.
   - Ground-floor commercial vitality: grocery shops (*Mudir Dokan*), pharmacies, sweetmeat confectioneries (*Mishtir Dokan*), and vibrant corrugated iron/canvas tea stalls (*Tong Dokan*).
2. **Rajshahi & Padma Riverbank (Padma Par)**:
   - Alluvial canal and river branches (*Khal*) acting as working economic arteries.
   - Reinforced concrete revetments and traditional paved river ghats (*Paka Ghat*) where boats dock, clothes are washed, and pedestrians gather under shade trees.
   - Dense groves of indigenous Coconut Palms (*Narikel Gach*) and sprawling Banyan trees (*Bot Gach*) with hanging aerial roots providing natural canopy.
3. **Civic & Mechanical Fabric**:
   - Local Police Station (*Thana / Police Fari*) characterized by colonial/post-colonial two-story administrative brick architecture, blue-and-white Dhaka Metropolitan Police aesthetic, high radio transmission masts, and enclosed compound security yards.
   - Informal vehicle workshops (*Bhai Bhai Auto Workshop*) with grease-stained concrete floors, corrugated iron (*Dhewtin*) canopies, tire pyramids, and oil drums.
   - Intermodal transit stops (*CNG & Bus Stand*) where cycle rickshaws, auto-rickshaws, and mini-buses congregate.

---

## 2. 400M × 400M MASTER DISTRICT ZONING & COORDINATE GRID

The district is bounded within $X \in [-200, +200]\,\text{m}$ and $Z \in [-200, +200]\,\text{m}$ with the origin $(0, 0, 0)$ situated at the central intersection just north of the canal bridge:

```
                          Z = -200 (North Perimeter)
       [-150, -150]                                     [+100, -150]
   ┌─────────────────────────────────────────────────────────────────┐
   │ [RESIDENTIAL NEIGHBOURHOOD]       │ [CIVIC SECTOR]              │
   │  - 3x 3-Story Concrete Flats      │  - Police Station Compound  │
   │  - 3x Tin-Roof Brick Houses       │    (Administrative HQ,      │
   │  - Narrow Brick Goli (Width 3.5m) │     Security Perimeter Wall,│
   │  - Boundary Walls & Courtyards    │     Radio Antenna Tower)    │
   │                                   │                             │
   │───────────────────────[BAZAAR AVENUE]───────────────────────────│ Z = -38m
   │ [COMMERCIAL BAZAAR]               │ [TRANSIT TERMINAL]          │
   │  - Commercial Market Row 1 & 2    │  - Bus & CNG Stand Shelter  │
   │  - Bangla Signboard Shops         │  - Passenger Benches        │
   │  - Bismillah Tea Stall (Tong)     │  - Parked Cycle Rickshaw    │
   │  - Ancient Shaded Banyan Tree     │  - Player Sidewalk Spawn    │
───┼───────────────────────────────────┼─────────────────────────────┼─── Z = 0
   │ [RIVERFRONT & GHAT]               │ [CANAL INFRASTRUCTURE]      │
   │  - Paka Ghat Step Descent         │  - 2-Lane Girder Bridge     │
   │  - Ghat Banyan Tree & Palms       │    (Width 12m, Span 38m)    │
   │                                   │  - Retaining Revetment Walls│
   │~~~~~~~~~~~~~~~~~[CANAL / KHAL (Z = +28 to +72)]~~~~~~~~~~~~~~~~~│ Y = -1.2m
   │                                   │                             │
   │ [SOUTHERN WORKSHOP SECTOR]        │ [RIVERSIDE MEADOW & EXPANS] │
   │  - Bhai Bhai Auto Workshop        │  - Silt Floodplain Ground   │
   │  - Open Repair Canopy & Tires     │  - Coconut Palm Groves      │
   │  - Southern Main Road Corridor    │  - Unpaved Utility Paths    │
   └─────────────────────────────────────────────────────────────────┘
                          Z = +200 (South Perimeter)
```

---

## 3. THE 10 MANDATORY LANDMARKS: SPECIFICATIONS & FEATURES

| # | Landmark | Scene Asset | World Coordinates | Architectural & Gameplay Features |
|---|---|---|---|---|
| 1 | **Residential Neighbourhood** | `residential_flats.tscn`<br>`tin_roof_house.tscn` | $X \in [-150, -65]$<br>$Z \in [-170, -70]$ | 3-story concrete flats with recessed balconies, metal safety grills, rooftop water reservoirs, AC compressor units; traditional tin-roof houses with brick plinths, open verandas, pitched corrugated iron roofs, enclosed by 2.4m brick boundary walls. |
| 2 | **Commercial Market** | `commercial_market.tscn` | $X = -48, Z = -48$<br>$X = -76, Z = -48$ | Multi-unit commercial strip with operational metal roll-up shutters, striped rain awnings, concrete display plinths, and high-resolution Bangla signboards: *Ma Babar Doa Store*, *New Dhaka Pharmacy*, *Rajshahi Mishtanno Bhandar*. |
| 3 | **Main Road (2-Lane)** | Built into district master | $X = 0$<br>$Z \in [-200, +200]$ | 8m wide asphalt spine with yellow center divider stripe, flanked by 2.4m elevated concrete footpaths (curb height 0.18m), open stormwater drainage channels, and crossing culverts. |
| 4 | **Narrow Side Streets (*Goli*)** | Built into district master | $X = -95$<br>$Z \in [-170, -38]$ | 4.0m wide herringbone brick paving flanked by tall red-brick boundary walls, utility poles, overhead electrical lines, and corner blind-spots ideal for on-foot evasion. |
| 5 | **Canal / River (*Khal*)** | `water_surface.tscn` | $X \in [-200, +200]$<br>$Z \in [+28, +72]$ | 400m × 44m waterway depressed at $Y = -1.2\,\text{m}$ (bed at $Y = -3.2\,\text{m}$) with concrete revetment walls, water caustic shader, depth-based tinting, and a brick river ghat with stepped water access at $X = -38, Z = +28$. |
| 6 | **Local Bridge** | `canal_bridge.tscn` | $X = 0, Z = +50$ | Heavy reinforced-concrete 2-lane girder bridge spanning 38m across the canal, featuring 8m roadway, dual 1.8m pedestrian sidewalks, concrete safety railings, and massive cylindrical support piers anchored in the riverbed. |
| 7 | **Police Station (*Thana*)** | `police_station.tscn` | $X = +75, Z = -105$ | Two-story administrative compound with central entrance portico, red-and-white steel communications antenna mast (16m), high perimeter security walls, official bilingual signboard (*Thana Police Fari*), and vehicle parking yard. |
| 8 | **Auto Workshop** | `auto_workshop.tscn` | $X = -48, Z = +96$ | Open-bay mechanics garage (*Bhai Bhai Auto Workshop*) with corrugated iron canopy, grease-stained concrete pad, stacked rubber tire pyramids, blue industrial oil drums, and repair tools. |
| 9 | **Roadside Tea Stall (*Tong*)** | `tea_stall_tong.tscn` | $X = -11.5, Z = -31$ | Authentic wooden plank roadside counter, blue polyethylene rain tarp canopy, customer seating benches, boiling aluminum kettle, Bangla signboard (*Bismillah Tea Stall*), and interactable trigger [E] that debits ৳ 10 to instantly replenish 100% player stamina. |
| 10 | **CNG & Bus Terminal** | `cng_bus_stand.tscn` | $X = +42, Z = -18$ | Covered passenger waiting terminal with corrugated steel canopy, passenger concrete benches, asphalt turnaround apron, official route signboard (*Padma-Buriganga CNG & Bus Stand*), and a parked driveable Cycle Rickshaw (`rickshaw.tscn`). |

---

## 4. AUTHENTIC BANGLA SIGNBOARD CATALOG & TYPOGRAPHY

To guarantee cultural fidelity and avoid generic low-quality texture generation, all signboards were pre-rendered at 1024×256 pixels with the Windows Bengali font `Nirmala.ttf` (`NirmalaB.ttf`) utilizing authentic Bangladeshi commercial graphic design conventions:

```
+-------------------------------------------------------------+
|               [ sign_police.png ]                           |
|       ঢাকা মেট্রোপলিটন পুলিশ (DMP)                          |
|         থানা পুলিশ ফাঁড়ি                                   |
|   "আইন শৃঙ্খলা বজায় রাখুন, শান্তিতে থাকুন"                 |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|             [ sign_tea_stall.png ]                          |
|                 বিসমিল্লাহ                                  |
|            টি স্টল ও ক্যাফে                                 |
|    "এখানে উন্নত মানের রং চা, দুধ চা ও বিস্কুট পাওয়া যায়"    |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|              [ sign_grocery.png ]                           |
|              মা বাবার দোয়া স্টোর                           |
|             জেনারেল ও ভ্যারাইটিজ স্টোর                      |
|       "এখানে যাবতীয় নিত্যপ্রয়োজনীয় পণ্য সুলভ মূল্যে"     |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|             [ sign_pharmacy.png ]                           |
|               নিউ ঢাকা ফার্মেসি                             |
|          ঔষধের নির্ভরযোগ্য প্রতিষ্ঠান                      |
|     "এখানে দেশি-বিদেশি সকল প্রকার ওষুধ খুচরা ও পাইকারি"     |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|             [ sign_workshop.png ]                           |
|           ভাই ভাই অটো ওয়ার্কশপ                             |
|     সিএনজি, মোটরসাইকেল ও গাড়ি মেরামত করা হয়                |
|     "অভিজ্ঞ মেকানিক দ্বারা নিখুঁত কাজ করা হয়"              |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|             [ sign_cng_stand.png ]                          |
|     পদ্মা-বুড়িগঙ্গা সিএনজি ও বাস স্ট্যান্ড                 |
|             আন্তঃজেলা যোগাযোগ টার্মিনাল                     |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
|             [ sign_sweetmeat.png ]                          |
|           রাজশাহী মিষ্টান্ন ভাণ্ডার                        |
|             খাঁটি ছানার মিষ্টি ও দধি                        |
|       "রসমালাই, চমচম, ছানার জিলাপি ও স্পেশাল ক্ষীর"         |
+-------------------------------------------------------------+
```

---

## 5. INFRASTRUCTURE, UTILITIES & BOTANICAL ELEMENTS

### 5.1 Overhead Electric Utilities
- **Poles (`electric_pole.tscn`)**: 8.5m reinforced concrete utility poles placed at 35m–45m intervals along both the Main Road and Bazaar Avenue. Features galvanized steel crossarms, high-voltage cylindrical transformer units, and multi-line electrical cable connections.
- **Urban Density Feel**: Eliminates the sterile "clean" look of typical Western game cities, providing the iconic tangled overhead skyline characteristic of Dhaka and Rajshahi.

### 5.2 Nighttime Illumination & Streetlighting
- **Streetlights (`streetlight.tscn`)**: 6.5m curved tubular galvanized steel posts equipped with directional luminaire hoods and active `SpotLight3D` nodes (range 18m, angle 55°, energy 2.5). Positioned along pedestrian sidewalks to cast realistic nocturnal light pools on asphalt and puddles.

### 5.3 Drainage & Hydrology
- **Open Storm Drains**: 0.8m wide, 0.5m deep exposed brick/concrete drainage trenches flanking the main roadways. Concrete slab crossings connect pedestrian walkways to roadside building thresholds, accurately replicating Bangladesh urban drainage engineering.
- **Canal Water Simulation**: The 400m water plane utilizes an optimized vertex-wave shader (`water_shader.gdshader`) with dual animated noise octaves, depth attenuation coloring (transitioning from emerald green in shallows to murky Buriganga silt in depths), caustic reflection maps, and an underlying `Area3D` physics volume (collision layer 512) for vehicle and player buoyancy/splash hooks.

### 5.4 Botanical Assets
- **Bot Gach (Banyan Trees, `banyan_tree.tscn`)**: Features a massive textured central trunk (radius 0.8m), angled aerial support roots (*Jhurimul*), and a broad, dense double-sphere foliage canopy (width 9m) offering respite from tropical sun. Positioned prominently at the roadside tea stall and the canal river ghat.
- **Narikel Gach (Coconut Palms, `coconut_palm.tscn`)**: 8.5m slender segmented trunks with natural wind curve and multi-directional fan fronds lining the canal revetments and private residential plots.

---

## 6. INTEGRATION WITH PLAYER, VEHICLES & QUESTS

1. **Player Locomotion**:
   - The player spawns safely at $(X = -5.5, Y = 0.2, Z = -22)$ on the West sidewalk of the Main Road, directly adjacent to the Commercial Bazaar, with the Bismillah Tea Stall and Bridge in immediate field of view.
   - Smooth 2-stage stair stepping handles curb mounting (0.18m) and river ghat stepped descent without physics stutter.
2. **Interactive Economy**:
   - Approaching the Bismillah Tea Stall triggers an interaction prompt on the HUD: `"Order Cha at Tong (৳ 10)"` [Press E].
   - Consuming tea deducts ৳ 10 from the player's wallet via `GameManager.spend_money(10)` and restores 100% stamina via `EventBus.player_stamina_changed`.
3. **Vehicle System**:
   - An authentic cycle rickshaw is parked at the CNG stand $(X = 36, Z = -12)$. The player can approach, mount, and pedal across the district with responsive steering, bell ringing, and authentic passenger physics.
4. **District Mission System**:
   - `scenes/districts/district_01_padma_buriganga.gd` initializes exploration quest `m01_explore_district` on `_ready()`, guiding the player across all 10 landmarks with live HUD toasts and objective tracker updates.

---

## 7. PERFORMANCE & RENDERING BUDGET (FORWARD+)

- **CSG & Mesh Hierarchy**: All buildings, terrain blocks, and roads are pre-configured with explicit static collision hulls (`collision_layer = 1`, `collision_mask = 31`).
- **Shader Complexity**: Standard PBR materials (`StandardMaterial3D`) utilize roughness and metallic maps with low albedo texture bandwidth; water and wetness shaders execute in vertex/fragment with single-pass depth sampling.
- **Shadow Distances**: `directional_shadow_max_distance = 250.0m` ensures crisp high-resolution character and vehicle shadows in the active 400m perimeter without dropping frames below 60 FPS.
