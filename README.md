# DTA: Dhaka Theft Auto (ঢাকা থেফট অটো)

[![React](https://img.shields.io/badge/React-18.3-61DAFB?logo=react&logoColor=white)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.4-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Three.js](https://img.shields.io/badge/Three.js-r165-black?logo=threedotjs&logoColor=white)](https://threejs.org/)
[![Vite](https://img.shields.io/badge/Vite-5.3-646CFF?logo=vite&logoColor=white)](https://vitejs.dev/)

**Dhaka Theft Auto (DTA)** is an open-world 3D browser action game authentically set across the vibrant, bustling metropolis of Dhaka, Bangladesh. Built with **React**, **TypeScript**, and **Three.js**, it features a **2.5x expanded open-world city (1,500m × 1,500m)**, interactive vehicles including iconic green CNG auto-rickshaws, AI traffic, elevated flyovers, Buriganga riverfront passenger launches, tactical radar minimap, and dynamic crime-action missions.

---

## 🌟 Key Features

### 1. 2.5x Expanded Dhaka Open World (1,500m × 1,500m)
Traverse a seamlessly connected open-world city featuring authentic Dhaka districts:
- **Old Dhaka / Chawkbazar (চকবাজার / পুরান ঢাকা):** Historic red-brick townhouses, narrow Mughal lanes, traditional biryani kitchens, and bakarkhani shops.
- **Shapla Crossing (শাপলা চত্বর):** Central roundabout dominated by the monumental national water-lily fountain sculpture.
- **Motijheel Financial District (মতিঝিল বাণিজ্যিক এলাকা):** Corporate skyscraper canyons, Bangladesh Bank vault tower, and Sonali Bank headquarters.
- **Kawran Bazar & Elevated Flyover (কাওরান বাজার ও ফ্লাইওভার):** Bustling wholesale commodity market crowned by an elevated expressway flyover.
- **Gulshan & Banani Diplomatic Enclave (গুলশান ও বনানী):** Luxury glass high-rises, upscale avenues, modern shopping arcades, and penthouse safehouses.
- **Dhanmondi Residential Zone (ধানমন্ডি):** Tree-lined avenues, residential apartments, and lakeside tea stalls.
- **Sadarghat & Buriganga Riverfront (সদরঘাট ও বুড়িগঙ্গা):** Legend-steeped river port with multi-deck passenger steam launches, cargo docks, and the Babubazar bridge.

### 2. Vehicle Driving Physics & Fleet
- **CNG Auto-Rickshaw (Bajaj RE 3-Wheeler):** Agile steering, emerald green chassis, yellow hood, rear safety grill, and authentic registration plate (`ঢাকা মেট্রো-থ ১১-৪২০`).
- **Dhaka Yellow Cab & Private Sedans:** Smooth highway cruising, balanced suspension, and road drift.
- **High-Speed Sports Coupe:** Fast acceleration and precision drift handling.
- **Traditional Cycle Rickshaw:** Classic three-wheeled rickshaw with folk-art painted canopy hood and metallic bell chime.

### 3. Dynamic Gameplay & Missions
- **Interactive Vehicle Hijacking / Driving:** Seamlessly enter and exit any vehicle on the street (`[E]` or `[F]`).
- **Storyline Missions:**
  - *Operation: Chawkbazar Feast:* Deliver fresh royal Biryani crates from Old Dhaka to Gulshan VIP Lounge.
  - *Buriganga River Express:* Retrieve contraband electronics from Sadarghat Launch Terminal #4 and deliver them to Motijheel Bank Vault.
  - *Kawran Bazar Heat Evasion:* Sprint onto the elevated flyover at full throttle to escape Kotwali Police.
- **Passenger Fare / Ride-Sharing Side-Hustle:** Press `[T]` to pick up passenger fares across Dhaka and earn Bangladesh Taka (৳ BDT).
- **Police Heat / Wanted Level:** Dynamic wanted stars (★) with Kotwali DMP Police alert responses.

### 4. Audio Engine (Web Audio API)
- Real-time procedural audio synthesis:
  - Dynamic RPM-responsive engine audio.
  - Authentic CNG double honk (`"Pee-Peep!"`).
  - Deep melodic bus air horns.
  - High-pitch metallic rickshaw bell (`"Tring-Tring"`).
  - Mission rewards and cash jingles.

### 5. Tactical Radar Minimap & Cinematic HUD
- Dual-mode minimap: Compact corner radar and full expanded city map (`[M]` or toggle button).
- Live HUD displaying Speedometer (KM/H), Health (HP), Cash (৳ BDT), Wanted Stars (★), District Entry Banners, and Mission Trackers.

---

## 🕹️ Controls Guide

| Action | Control Key |
| :--- | :--- |
| **Move / Accelerate** | `W` or `Up Arrow` |
| **Reverse / Brake** | `S` or `Down Arrow` |
| **Steer / Strafe** | `A` / `D` or `Left` / `Right Arrow` |
| **Sprint (On Foot)** | `Left Shift` |
| **Jump (Foot) / Handbrake (Vehicle)** | `Space` |
| **Enter / Exit Vehicle** | `E` or `F` |
| **Honk Horn / Rickshaw Bell** | `H` |
| **Start Next Mission** | `M` |
| **Hail Passenger Fare (Taxi Job)** | `T` |
| **Camera Orbit Look** | `Mouse Movement` (Click to lock) |

---

## 🚀 Quick Start (Development)

### Prerequisites
- [Node.js](https://nodejs.org/) (v18.0.0 or higher recommended)
- `npm`

### Installation & Launch
```bash
# Clone the repository
git clone https://github.com/istihadahmed007/PD-.git
cd PD-

# Install dependencies
npm install

# Start local development server
npm run dev
```

Visit `http://localhost:3000` in your browser.

### Production Build
```bash
npm run build
```
Compiled production files will be generated in `dist/`.

---

## 📁 Project Architecture

```
PD-/
├── index.html                   # HTML entry point with Bengali typography
├── package.json                 # Dependencies & scripts
├── tsconfig.json                # TypeScript compiler configuration
├── vite.config.ts               # Vite bundler settings
├── tailwind.config.js           # Tailwind CSS design system
├── src/
│   ├── main.tsx                 # React DOM bootstrap
│   ├── App.tsx                  # Core application orchestrator
│   ├── index.css                # Global styles & visual glows
│   ├── components/
│   │   ├── HUD.tsx              # Speedo, Health, Cash (৳), Wanted stars
│   │   ├── Minimap.tsx          # 2D canvas tactical radar & map
│   │   ├── TitleScreen.tsx      # Cinematic intro title screen
│   │   └── ControlsOverlay.tsx  # Game controls reference modal
│   └── game/
│       ├── worldData.ts         # Districts, roads, buildings, POIs, missions
│       ├── worldBuilder.ts      # Three.js 3D procedural world generator
│       ├── physics.ts           # Movement, vehicle dynamics, AABB colliders
│       ├── engine.ts            # Three.js render loop, camera, AI traffic
│       └── audio.ts             # Web Audio API procedural sound engine
└── dist/                        # Production build
```

---

## 📜 License
Original Bangladesh open-world game created for Dhaka Theft Auto.
