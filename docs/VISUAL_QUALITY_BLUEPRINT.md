# VISUAL QUALITY & PERFORMANCE BLUEPRINT: GTA BANGLADESH
## PBR Shaders, Lighting, Dynamic Weather & Target Hardware Scaling

---

### 1. Visual Standard & Atmosphere

GTA Bangladesh captures the dense, humid, and visually rich atmosphere of contemporary Bangladesh:
- **Atmospheric Palette**: Warm tropical daylight, rich golden-hour sunsets, dense monsoonal cloudbursts with Kalbaishakhi procedural lightning, neon and fluorescent street signage at night.
- **Surface Realism**: Weathered brick textures, peeling posters, algae stains on river walls, corrugated tin roofs, asphalt with oil slicks and rain puddles.

---

### 2. Shaders & Material Architecture

1. **PBR Road & Wetness Shader (`shaders/road_asphalt_pbr.gdshader`)**:
   - Albedo asphalt texture blended with procedural Fractal Brownian Motion (FBM) puddle masks.
   - Puddle depth absorption and dynamic rain ripple normal maps.
   - Smoothness/Roughness parameter inversely modulated by weather wetness intensity.
2. **Realistic River & Delta Water Shader (`shaders/buriganga_water_pbr.gdshader`)**:
   - 3-wave Gerstner wave displacement for natural river surface movement.
   - Depth-based water coloration (silt-rich tea-brown to deep green Buriganga tones).
   - Foam accumulation along riverbanks and boat hulls.
3. **Foliage Wind Sway Shader (`shaders/foliage_wind_pbr.gdshader`)**:
   - Vertex displacement for coconut palms, banyan trees, and river reeds responding to global wind speed.

---

### 3. Hardware Scaling & Performance Budget

Target: Consistent **60 FPS** on varied hardware tiers:

| Hardware Tier | Target Specs | Resolution / Renderer | Graphic Settings |
| :--- | :--- | :--- | :--- |
| **Low / Integrated** | Intel HD Graphics 4000, 8GB RAM | 1280×720 (GL Compatibility) | Orthogonal shadows, SSR off, volumetric fog off, 150m draw distance |
| **Mid / Mainstream** | GTX 1060 / RX 580, 16GB RAM | 1920×1080 (Compatibility / Forward+) | 2-split CSM shadows, SSAO enabled, 350m draw distance |
| **High / Enthusiast**| RTX 3060+ / RX 6700+, 16GB+ RAM | 2560×1440+ (Forward+) | 4-split CSM, Full SSR, Volumetric fog, 700m draw distance |
