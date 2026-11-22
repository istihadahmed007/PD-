# MISSION SYSTEM BLUEPRINT: GTA BANGLADESH
## Story Missions, Side Activities & Mission Director Architecture

---

### 1. Narrative Context & Story Arc

**Protagonist**: Joynal "Joy" Abedin — A skilled mechanic and driver living in Old Dhaka, caught between the corrupt *Balu Syndicate* (illegal river sand dredging cartel) and the defense of his family and neighborhood.

#### Story Chapter 1: Old Dhaka Underground (Missions 01 – 05)

1. **Mission 01: Shadows and Sparkplugs (ছায়া ও স্পার্কপ্লাগ)**
   - *Giver*: Kabir Ustad (Senior Workshop Mentor)
   - *Objective*: Retrieve stolen ECU diagnostic parts from an alley warehouse in Lalbagh; evade rival syndicate scouts; return to Kabir's garage.
   - *Reward*: ৳15,000 + Kabir Garage ECU tuning access.

2. **Mission 02: Buriganga Midnight Run (বুড়িগঙ্গা মিডনাইট রান)**
   - *Giver*: Mahfuz Bhai (Riverfront Logistics Boss)
   - *Objective*: Hijack a syndicate cargo truck at Sadarghat terminal; navigate through heavy nighttime traffic; deliver to safe storage before police roadblock.
   - *Reward*: ৳25,000 + Safehouse unlock in Lalbagh.

3. **Mission 03: The Dredger Cartel (বালু সিন্ডিকেট)**
   - *Giver*: Tariq (Investigative Journalist Contact)
   - *Objective*: Infiltrate sand extraction barge on Buriganga riverbank; plant GPS bug; escape pursuit across the river bridge on a high-speed motorcycle.
   - *Reward*: ৳40,000 + 150cc Commuter Bike delivery unlock.

4. **Mission 04: Hostile Repossession (দখলদার উচ্ছেদ)**
   - *Giver*: Nila (Joy's Sister / Community Organizer)
   - *Objective*: Stop cartel heavies from intimidating local tea stall owners; melee combat challenge; chase down fleeing syndicate van across Old Dhaka alleys.
   - *Reward*: ৳35,000 + Community Respect (10% discount across all tong stalls).

5. **Mission 05: The Thana Lockdown (থানা লকডাউন)**
   - *Giver*: Inspector Rahmat (Conflicted Police Detective)
   - *Objective*: Break into corrupt commissioner's evidence locker at Lalbagh Thana; retrieve cartel ledgers; escape with 3-star wanted level using tactical back alleys.
   - *Reward*: ৳60,000 + Police radar jammer perk.

---

### 2. Mission Director Technical Architecture

```
                    ┌─────────────────────────┐
                    │   Mission Trigger Area  │
                    │   (3D Beacon + Prompt)  │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Mission State Node   │
                    │  (Objectives, Stages)   │
                    └────────────┬────────────┘
                                 │
            ┌────────────────────┼────────────────────┐
            ▼                    ▼                    ▼
     ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
     │  Dialogue   │      │ Checkpoint  │      │ Failure     │
     │  Subtitles  │      │ Coordinates │      │ Conditions  │
     └─────────────┘      └─────────────┘      └─────────────┘
```

- **Checkpoint System**: Automatically serializes player coordinates, health, and inventory state at key mission transitions.
- **Dynamic Failure Listeners**:
  - Target VIP killed or destroyed.
  - Player arrested or wasted.
  - Mission timer elapsed.
- **Fail Recovery**: Quick retry from last checkpoint without reloading the entire scene.
