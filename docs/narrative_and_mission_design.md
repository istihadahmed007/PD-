# ORIGINAL BANGLADESH NARRATIVE AND MISSION SYSTEM SPECIFICATION
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Module**: Narrative Lore Bible, Story Characters, Mission Engine & Scenario Script  
**Godot Target**: Godot 4.x Forward+ | Jolt Physics 3D | GDScript 2.0 (Statically Typed)

---

## 1. Executive Summary & Narrative Philosophy

The mission and narrative design for *Project Sonar Bangla* establishes an **original contemporary crime-action thriller** set in a fictionalized Bangladesh metropolitan and riverine delta.

### Core Pillars
1. **Zero Plagiarism / No GTA Tropes**: The storyline is free from generic Western mafia caricatures or GTA stereotypes. It is grounded in the distinct socio-economic realities of contemporary Bangladesh:
   - Illegal river sand dredging (*Balu Syndicate*) eroding riverbanks and villages.
   - River launch transport dynamics, inland water freight, and cargo quays.
   - Informal urban economies: auto repair workshops, rickshaw garages, roadside tea stalls (*tong*), and bustling wholesale bazaars.
   - The friction between honest investigative journalism, compromised local politicians, and pragmatic police officers.
2. **Dual-Language Cultural Immersion**: All dialogue lines are scripted with authentic Bengali colloquial dialogue paired directly with natural English subtitle translations.
3. **Decoupled Mission Engine**: Quests are driven by modular `MissionResource` definitions processed through an asynchronous state machine (`MissionSystem`), integrated seamlessly with `EventBus`, `SaveSystem`, vehicle physics, and police response systems.

```
                    ┌──────────────────────────┐
                    │    MissionResource       │
                    │ (Steps, Targets, Timers) │
                    └────────────┬─────────────┘
                                 │
                                 ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  MissionTrigger  ├───►│  MissionSystem   ├───►│ MissionWaypoint  │
│  (Questgiver 3D) │    │  (State Machine) │    │ Beacon (Visual)  │
└──────────────────┘    └────────┬─────────┘    └──────────────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           ▼                     ▼                     ▼
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│MissionDialogueUI │   │    EventBus      │   │    SaveSystem    │
│(Cinematic Box)   │   │  (Signal Hub)    │   │ (State Autosave) │
└──────────────────┘   └──────────────────┘   └──────────────────┘
```

---

## 2. World Lore & Setting Architecture

### 2.1 The Setting: Padma-Buriganga Basin (*Shonar Nagar*)
The narrative unfolds across a high-contrast territory reflecting the real delta landscape of Bangladesh:

- **Shonar Nagar (Old City & Downtown Corridor)**:
  - Dense, labyrinthine brick-and-mortar alleys (*golis*), overhanging residential balconies, rooftop water tanks, tangled overhead electric wiring, and street-level commercial rolling shutters.
  - Multi-lane asphalt avenues flanked by open storm drains, concrete footpaths, pedestrian foot-overbridges, and roadside tea stalls (*tong*).
- **Buriganga Stepped Ghat & Launch Terminal**:
  - Sadarghat-inspired riverfront featuring multi-deck passenger launch ferries, wooden country boats (*dingi*), rusted steel barges, cargo loading quays, and stepped brick ghats.
- **Padma Riverbanks & Char Lands**:
  - Unregulated river sandbars (*chars*) where illegal hydraulic dredgers pump river sand 24 hours a day. The riverbanks constantly suffer erosion (*nodivangon*), displacing rural farming families.
- **Canal Bridge & Industrial Border**:
  - A two-lane reinforced concrete girder bridge spanning the murky tidal canal, connecting the auto-workshop alley with the commercial wholesale market and sand logistics depots.

---

## 3. Character Bible

### 3.1 Main Protagonist: Joynal "Joy" Abedin (জয়নাল আবেদীন)
- **Role**: Playable Protagonist.
- **Background**:
  - Former assistant pilot and master diesel mechanic on Buriganga passenger launch lines (*MV Meghna Star*).
  - Grew up in Sadarghat and the river dockyards. Known for uncanny vehicle reflexes—whether maneuvering a 3-wheel CNG through bumper-to-bumper traffic or piloting launch engines against swollen monsoon currents.
  - Returns to the city after his father's mysterious drowning on the Meghna River to support his mother and put his younger sister through engineering university.
- **Personality**: Grounded, sharp-witted, fiercely loyal to family and neighborhood elders, reluctant to enter underworld violence but driven by the search for truth.

### 3.2 Family & Background
- **Mother — Rahela Begum (রাহেলা বেগম)**:
  - Strong-willed matriarch coping with rheumatoid arthritis. Refuses syndicate blood money or charity, managing the family home with dignity.
- **Sister — Sumaiya Abedin (সুমাইয়া আবেদীন)**:
  - Top-ranking civil and water-resource engineering student at BUET.
  - Her academic research on riverbed erosion and satellite tracking of illicit dredging unintentionally makes her a target for the sand syndicate.
- **Late Father — Captain Farid Abedin (ক্যাপ্টেন ফরিদ আবেদীন)**:
  - Decorated river launch master with 30 years on the Padma-Meghna routes.
  - Officially died in a "tragic midnight ferry collision." In reality, he refused to alter his shipping logs when Chairman Afsarul Huq's unauthorized suction dredgers caused a disastrous riverbank collapse.

### 3.3 Main Antagonist: Chairman Afsarul "Balu" Huq (চেয়ারম্যান আফসারুল হক)
- **Role**: Central Antagonist.
- **Profile**:
  - Multi-millionaire sand baron, port council chairman, and real-estate mogul.
  - Controls the city's construction raw materials, hydraulic sand dredgers, and inland river routes.
  - Projects a philanthropic public image while deploying private enforcer squads to silence journalists, intimidate river dockers, and bribe municipal authorities.

### 3.4 Key Enforcers & Antagonists
- **Ghashi Tariq (ঘাসি তারিক)**:
  - Huq's chief river syndicate enforcer. Controls illegal sand pumping barges, extortion rackets across Sadarghat launch workers, and strong-arm debt collectors.
  - Drives an armored black utility pickup and commands heavy speedboats along the Buriganga.

### 3.5 Supporting Allies & Mission Givers
- **Kabir "Ustad" Mollah (কবির ওস্তাদ)**:
  - Owner and master technician at *Bhai Bhai Auto Workshop*.
  - Former comrade of Joy's late father; veteran automotive tuner who can fix any Japanese engine, motorcycle, or CNG auto-rickshaw. Acts as Joy's mentor, father figure, and initial questgiver.
- **Nila Chowdhury (নীলা চৌধুরী)**:
  - Investigative field journalist for the independent daily *Dainik Prerona*.
  - Intrepid, armed with a DSLR camera and encrypted voice recorder. Investigating the financial ties between the dredging syndicate and municipal corruption; allies with Joy to unearth Captain Farid's final voyage logs.

### 3.6 Law Enforcement & Police Contacts
- **Sub-Inspector Mahfuzur Rahman (এসআই মাহফুজুর রহমান)**:
  - Duty officer stationed at Padma/Lalbagh Thana.
  - Realistic depiction of law enforcement: not purely corrupt nor superheroic. Aware of political interference from Chairman Huq, he secretly leverages Joy to deliver evidence that bypasses compromised senior superintendents.

### 3.7 Local Community & Business Characters
- **Gaffar Bhai (গাফফার ভাই)**:
  - Owner of *Bismillah General Store & Electrical Supplies* in Commercial Bazaar. Acts as a neighborhood parts dealer and fence.
- **Kalu Miah (কালু মিয়া)**:
  - Veteran proprietor of the roadside *Tong* tea stall. Knows every vehicle, rumor, and police patrol route passing through the junction.
- **Rahmat Chacha (রহমত চাচা)**:
  - Elder representative of the local Rickshaw Pullers' Welfare Union (*Lalbagh Samity*). Veteran community eye witness who observes illicit nocturnal movements along the river ghats.

---

## 4. Mission System Technical Architecture

The mission framework is implemented in `missions/` and `ui/mission_ui/`:

### 4.1 Step Types & Mechanics (`MissionResource.gd`)
Missions consist of structured sequential steps supporting multiple gameplay mechanics:
1. `GOTO`: Travel on foot or by vehicle to a 3D coordinate within `target_radius`.
2. `TALK`: Contextual conversation with an NPC; triggers dual-language letterbox dialogue and pauses movement.
3. `DRIVE`: Board a designated vehicle class or target vehicle instance.
4. `DELIVER`: Transport items/cargo from point A to B. Supports `fragile_cargo` (vehicle health degradation beyond 45% fails cargo) and timed countdowns (`time_limit`).
5. `CHASE`: Pursue a fleeing target vehicle or enforcer; maintain proximity ($< 80\text{m}$) or disable target.
6. `DEFEND`: Protect an NPC or stationary objective against attacking squads for a duration or until assailants are neutralized.
7. `INVESTIGATE`: Search a designated perimeter, collect physical evidence, or photograph suspicious assets without raising 2+ Wanted Stars.

### 4.2 Mission State Machine (`MissionSystem.gd`)
Managed by the `MissionSystem` node:
- **`STATE_IDLE`**: Free-roaming open world; questgiver triggers active.
- **`STATE_ACTIVE`**: Step objectives displayed on HUD; 3D waypoint beacon spawned; active timer ticking.
- **`STATE_DIALOGUE`**: Camera and player input focused on cinematic letterbox; audio typewriter blip playing for each line.
- **`STATE_CHECKPOINT`**: Reached a safety milestone; player position and vehicle state serialized.
- **`STATE_COMPLETED`**: Fanfare audio played; reward BDT ৳ and XP credited to `GameManager.wallet_bdt`; quest registered in `completed_mission_ids`; auto-save triggered via `SaveSystem`.
- **`STATE_FAILED`**: Somber audio played; screen displays retry option (`[R] Retry Checkpoint` or `[ESC] Abandon`). Restores player health, respawns player at last checkpoint, and repairs vehicle.

### 4.3 3D Visual Waypoint Beacon (`MissionWaypointBeacon.tscn`)
- Ground-level pulsating cyan/gold energy ring ($4\text{m}$ diameter) with unshaded billboard glow.
- Vertical semi-transparent light beam ($22\text{m}$ tall) visible from long distances across the skyline.
- Floating bobbing pointer arrow with 360° billboard orientation.
- Real-time dynamic distance label (`[ 124m ] Objective Name`) updated every frame relative to active player/camera.
- Integrated `Area3D` detecting both walking player capsules and vehicle bodies.

### 4.4 Cinematic Dual-Language Dialogue UI (`MissionDialogueUI.tscn`)
- Screen-bottom cinematic letterbox (darkened glass panel with Bengali floral accent borders).
- Speaker portrait badge (`res://assets/textures/characters/portrait_<name>.png`).
- Speaker title and localized role tag (e.g. *Kabir Ustad — Master Mechanic*).
- **Dual-Language Typography**:
  - Primary Bangla Line: Large bold font rendering authentic colloquial Bengali phrasing.
  - Subtitle English Line: Italicized gold/white English translation for global accessibility.
- Audio Blip: Synthesized radio click (`audio/missions/dialogue_blip.wav`) triggered on each dialogue advance.
- Input Advance: `[Space]` or `[E]` key advance, with an option to skip completed lines.

---

## 5. Playable Story Missions Specification

### 5.1 Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)
- **ID**: `m01_shadows_and_sparkplugs`
- **Type**: Driving & Delivery (High Stakes).
- **Giver**: Kabir Ustad at *Bhai Bhai Auto Workshop* (`Vector3(-48.0, 0.2, 96.0)`).
- **Rewards**: ৳ 1,500 BDT Cash, 350 XP.
- **Failure Conditions**:
  - Player dies or gets arrested.
  - Timer exceeds 160.0 seconds during cargo transport.
  - Vehicle sustains severe collision damage ($> 55\%$ damage destroys fragile carburetors).
- **Scripted Steps**:
  1. `TALK`: Speak with Kabir Ustad inside the workshop.
     - *Kabir*: "Joy, baper motoi gari chalanor haat tor! Ei CNG-tar engine tuning shesh. Kintu Bismillah Store-er Gaffar Bhai imported carburetor parts cheyechhe." / *"Joy, you have your father's gifted hands behind the wheel! This CNG engine tuning is complete. But Gaffar Bhai at Bismillah Store needs these imported carburetor parts urgently."*
     - *Joy*: "Chinta koiren na Ustad. Khub shotorko bhabe Canal Bridge paar kore diye ashbo." / *"Don't worry Ustad. I will cross the Canal Bridge with extreme care and deliver them intact."*
  2. `DRIVE`: Board the tuned green CNG Auto-Rickshaw parked at the workshop apron (`Vector3(-44.0, 0.45, 92.0)`).
  3. `DELIVER`: Navigate through traffic, cross the two-lane concrete Canal Bridge, and reach Commercial Bazaar (`Vector3(-45.0, 0.2, -42.2)`) within 160 seconds.
  4. `TALK`: Deliver parts to Gaffar Bhai in front of Bismillah General Store.
     - *Gaffar*: "Shabash Joynal! Huq Syndicate-er dhandabaj-ra rastay ghurchhe, tader chokhe na porei tui maal niye ashli. Ei ne tor 1500 taka." / *"Bravo Joynal! Huq Syndicate goons are scouting the streets, yet you slipped past their eyes. Here is your 1500 Taka payment."*
  5. `GOTO`: Return to Bhai Bhai Auto Workshop and deliver the payment to Kabir Ustad to conclude Chapter 1.

---

### 5.2 Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)
- **ID**: `m02_eyes_of_the_buriganga`
- **Type**: Investigation, Stealth & Police Evasion.
- **Giver**: Nila Chowdhury at Buriganga Stepped Ghat (`Vector3(35.0, 0.2, 28.0)`).
- **Rewards**: ৳ 2,800 BDT Cash, 600 XP.
- **Failure Conditions**:
  - Player dies or gets arrested.
  - Player raises Wanted Level above 2 Stars during investigation.
  - Dossier lost or player spotted inside the restricted Thana courtyard before obtaining files.
- **Scripted Steps**:
  1. `TALK`: Rendezvous with investigative journalist Nila Chowdhury at the river ghat.
     - *Nila*: "Joynal, tomar baba Captain Farid er launch dubir ghotona kono sadharan durghotona chhilo na. Chairman Afsarul Huq er balu dredger gulo nodir par dhashe diyechhilo." / *"Joynal, your father Captain Farid's launch sinking was no mere accident. Chairman Afsarul Huq's sand dredgers caused that catastrophic riverbank collapse."*
     - *Joy*: "Ami jantam! Baper launch kokhono chora-te atke jete pare na! Kintu proman kothay, Nila?" / *"I knew it! My father's vessel would never beach on a sandbar! But where is the evidence, Nila?"*
     - *Nila*: "Padma Thana-r SI Mahfuz ekta secret inquiry report toiri korechhe. Thana compound theke sheta amader retrieve korte hobe." / *"SI Mahfuz at Padma Thana prepared a confidential inquiry report. We need to retrieve that file from the Thana compound."*
  2. `GOTO`: Infiltrate the perimeter of Padma Police Station (`Vector3(98.0, 0.2, -48.0)`).
  3. `INVESTIGATE`: Approach the rear officer annex veranda and secure the encrypted dredging inquiry dossier (`Vector3(104.0, 0.2, -54.0)`).
  4. `EVADE`: An alert is raised (1 Star Wanted Heat). Evade police vision sensors and escape the 120m search radius without getting detained.
  5. `TALK`: Deliver the confidential dossier to Nila waiting safely near the bridge overlook (`Vector3(15.0, 0.2, 5.0)`).
     - *Nila*: "Dossier ta peye gechhi! Eikhane Afsarul Huq er be-aini dredging coordinate gulo ache. Ebar shob samne ashbe!" / *"I have the dossier! It contains all illegal dredging GPS coordinates linked directly to Afsarul Huq. The truth will finally come to light!"*

---

### 5.3 Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)
- **ID**: `m03_smoke_over_padma`
- **Type**: High-Speed Vehicle Pursuit, Ramming & Combat Rescue.
- **Giver**: SI Mahfuzur Rahman at Police Station Porch (`Vector3(92.0, 0.2, -36.0)`).
- **Rewards**: ৳ 4,500 BDT Cash, 1,000 XP.
- **Failure Conditions**:
  - Player dies or vehicle explodes.
  - Fleeing enforcer reaches extraction zone ($> 300\text{m}$ separation).
  - Target vehicle fails to be intercepted within 240 seconds.
- **Scripted Steps**:
  1. `TALK`: Meet SI Mahfuzur Rahman at the precinct front steps.
     - *Mahfuz*: "Joynal, Chairman Huq er mukhyo gunda Ghashi Tariq shunte peyechhe Nila report peye gechhe! Tar armed squad Nilar car chase korchhe Padma Bridge connector-e!" / *"Joynal, Chairman Huq's chief enforcer Ghashi Tariq learned that Nila obtained the report! His armed pickup squad is pursuing Nila's car toward the Padma Bridge connector!"*
     - *Joy*: "Tar mane Nila bipode! Ami ekhoni jacchi! Tariq re ajke thamaite hoibo!" / *"That means Nila is in mortal danger! I am leaving right now! Tariq must be stopped today!"*
  2. `DRIVE`: Board the tuned Pursuit Sedan stationed at the thana parking yard (`Vector3(88.0, 0.45, -28.0)`).
  3. `CHASE`: Pursue Ghashi Tariq's reinforced black utility pickup across the main avenue and canal highway.
  4. `DEFEND`: Perform PIT maneuvers and tactical ramming to neutralize the enforcer's vehicle before he forces Nila off the canal embankment.
  5. `TALK`: Regroup with Nila and SI Mahfuz beside the smoking wreckage.
     - *Mahfuz*: "Shabash chhele! Tariq er telephone ar encrypted hard drive amader haate. Afsarul Huq er syndicate-er din shesh." / *"Brilliant driving! Tariq's phone and encrypted drive are in our custody. The days of Afsarul Huq's syndicate are numbered."*
     - *Joy*: "Baper attah ajke shanti pabe. Kintu Huq-er pother sesh dekhe chharbo." / *"My father's soul will find peace today. But I won't stop until Huq's entire empire falls."*

---

## 6. Playable Test Scenario & Diagnostic Controls

The complete story mission engine is verified via dedicated diagnostic harness:  
**Scene**: [test_story_missions.tscn](file:///c:/Users/Tonmoy/Documents/DTA%200/tests/test_story_missions.tscn)  
**Script**: [test_story_missions.gd](file:///c:/Users/Tonmoy/Documents/DTA%200/tests/test_story_missions.gd)

### 6.1 Keyboard Controls & Shortcuts
| Hotkey | Function | Behavior |
|---|---|---|
| **[1]** | Launch Mission 01 | Starts *Shadows & Spark Plugs* (Delivery) |
| **[2]** | Launch Mission 02 | Starts *Eyes of the Buriganga* (Investigation) |
| **[3]** | Launch Mission 03 | Starts *Smoke Over Padma* (Pursuit & Ramming) |
| **[N]** | Advance Step Cheat | Automatically validates current step condition and advances |
| **[R]** | Retry Checkpoint | Simulates checkpoint retry, restoring player health and vehicle |
| **[F]** | Trigger Mission Fail | Forces immediate mission failure to test somber audio and UI |
| **[K]** | Quick Save | Serializes player, wallet, heat, and mission state to JSON slot |
| **[L]** | Quick Load | Restores world state, completed quests, and coordinates |
| **[T]** | Teleport to Beacon | Teleports player/vehicle directly to the active 3D objective beacon |
| **[Space / E]** | Advance Dialogue | Advances cinematic dual-language dialogue letterbox |

### 6.2 Live Telemetry HUD
The diagnostic overlay provides real-time readouts:
- **Active Mission & Type**: Current title, category (DELIVERY, INVESTIGATION, CHASE).
- **Step Counter**: Current step index out of total steps with full English objective text.
- **Active Timer**: Real-time countdown for timed deliveries and chases.
- **Fragile Cargo Health**: Live percentage health monitoring of cargo vehicle.
- **Active Waypoint**: 3D coordinates and distance in meters to target beacon.
- **Recent Dialogue**: Speaker name, localized line, and English translation.
- **Completed Missions**: Array of all persisted mission IDs recorded in `SaveSystem`.
- **Wallet & Heat**: Current BDT ৳ balance and wanted stars.

---

## 7. Open-World District 01 Integration

All 3 story mission questgiver triggers are permanently integrated into the open-world district scene:  
**Scene**: [district_01_padma_buriganga.tscn](file:///c:/Users/Tonmoy/Documents/DTA%200/scenes/districts/district_01_padma_buriganga.tscn)  
**Script**: [district_01_padma_buriganga.gd](file:///c:/Users/Tonmoy/Documents/DTA%200/scenes/districts/district_01_padma_buriganga.gd)

- **Kabir Ustad's Workshop Trigger**: Placed at `Vector3(-48.0, 0.2, 96.0)` inside *Bhai Bhai Auto Workshop*.
- **Nila Chowdhury's Ghat Trigger**: Placed at `Vector3(35.0, 0.2, 28.0)` overlooking the Buriganga river stepped landing.
- **SI Mahfuz's Precinct Trigger**: Placed at `Vector3(92.0, 0.2, -36.0)` on the front porch of Padma/Lalbagh Police Station.
- **Dynamic Auto-Launch**: When entering District 01 for the first time without prior saved progress, Mission 01 is automatically initiated, guiding the player into the core narrative arc seamlessly.
