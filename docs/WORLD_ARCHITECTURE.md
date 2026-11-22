# WORLD ARCHITECTURE BLUEPRINT: GTA BANGLADESH
## Regional Geography, Streaming, Density & Environmental Design

---

### 1. Macro-World Geography & Regional Biomes

GTA Bangladesh is modeled as a continuous, streaming landmass reflecting the geographic, urban, and ecological diversity of Bangladesh:

| Region | Biome & Architectural Theme | Key Landmarks & Visual Identity |
| :--- | :--- | :--- |
| **District 01: Metropolitan Old Dhaka** | Dense urban, historic Mughal architecture, narrow alleys | Buriganga Riverfront, Lalbagh Fort, Tong stalls, Sadarghat ferry terminal, tangled overhead electrical wires |
| **District 02: Rajshahi Delta** | Wide alluvial plains, silk workshops, mango orchards | Padma River bridge, ancient zamindar estates, sand dredging sandbars (*Balu Ghat*) |
| **District 03: Sylhet Tea Gardens** | Rolling hills, mist, tea plantation estates, winding roads | Surma valley highlands, brick colonial bungalows, serpentine mountain curves |
| **District 04: Chattogram Port** | Industrial shipping, maritime cargo, shipyard graveyards | Gantry cranes, container terminals, coastal cargo vessels, naval dockyards |
| **District 05: Cox's Bazar Highway** | Coastal marine highway, sandy beaches, seaside resorts | World's longest continuous natural beach, salt flats, fishing trawler harbors |
| **District 06: Sundarbans Mangroves** | Dense tidal mangrove swamps, river deltas, wooden jetties | Narrow boat waterways, wildlife reserves, remote smuggler outposts |
| **District 07: Rural Agricultural Plains** | Paddy fields, rural bazaars, brick kilns, unpaved dirt roads | Haat-bazaars, tube wells, cattle farms, village mosques |

---

### 2. District 01: Old Dhaka Master Layout

The primary urban anchor is **District 01 (Lalbagh-Buriganga)**, designed for dense, vertical, and atmospheric open-world gameplay:

```
                       [ NORTH: Sadarghat Commercial Avenue ]
                                         │
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                │                                │
  [ Tong Tea Stalls ]             [ Main Traffic Arteries ]      [ Auto Repair Workshop ]
  (Bismillah Cha)                 (CNG & Bus Lanes)              (Kabir Ustad Garage)
        │                                │                                │
        ├────────────────────────────────┼────────────────────────────────┤
        │                                │                                │
  [ Residential Alleys ]          [ Central Police Thana ]       [ Rupali Bank ATM ]
  (Multi-story Brick/Concrete)    (Checkpoints & Radar)          (Financial Safezone)
        │                                │                                │
        └────────────────────────────────┼────────────────────────────────┘
                                         │
                      [ SOUTH: Buriganga Riverfront & Docks ]
```

---

### 3. Spatial Chunk Streaming Architecture

- **Chunk Grid**: 512m × 512m streaming chunks.
- **Active Bubble**:
  - **Inner Ring (Radius 0 - 300m)**: LOD0 (Full high-resolution meshes, active physics colliders, dynamic traffic & NPC spawning).
  - **Middle Ring (Radius 300m - 700m)**: LOD1 (Simplified meshes, non-ticking static props, low-frequency traffic proxies).
  - **Outer Ring (Radius 700m+)**: LOD2 / Imposters (Horizon silhouettes, distant terrain elevation).
- **Asynchronous Chunk Pipeline**:
  - `ChunkStreamer` monitors camera coordinates.
  - Background loader loads `.tscn` chunks in worker threads via `ResourceLoader.load_threaded_request()`.
  - Garbage collection frees distant chunks to keep RAM under 2.5 GB.
