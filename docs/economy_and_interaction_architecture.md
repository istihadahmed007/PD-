# BANGLADESH GAME ECONOMY AND INTERACTION ARCHITECTURE
**Project**: Bangladesh Open-World Action Game (Codename: *DTA: Dhaka Theft Auto / Project Sonar Bangla*)  
**Module**: In-Game Economy, Banking, Shops, Garages, Wardrobes, Safehouses, Inventory & Physical Pickups  
**Godot Target**: Godot 4.x Forward+ | Jolt Physics 3D | GDScript 2.0 (Statically Typed)

---

## 1. Architectural Overview & Philosophy

The **Bangladesh Economy & Interaction System** creates a functional, closed-loop financial and commerce ecosystem rooted in contemporary Bangladesh urban life.

### 1.1 Core Principles
1. **Functional Gameplay Impact**: Every transaction directly affects gameplay. Consuming food restores health and stamina; garage tuning increases vehicle engine torque and top speed; clothing changes the 3D character mesh appearance; safehouses allow resting, time-advancement, and persistent game saves.
2. **Zero Decorative Buttons**: Every button in every UI modal is wired to live signal handlers and executes authentic game logic with audio feedback, transaction logging, and state serialization.
3. **Dual Currency Architecture (Cash vs. Bank)**:
   - **Pocket Cash (`wallet_bdt`)**: Physical Bangladesh Taka (৳) carried on foot. Used for street tong purchases, parts dealers, and bribes. Dropped when taking massive damage or wasted.
   - **Rupali Bank Savings (`bank_bdt`)**: Protected digital savings accessible through 24/7 ATMs and mobile banking (*bKash / Nagad* parody). Immune to death loss and used for high-value real estate purchases.
4. **Full Persistence**: All wallet balances, bank accounts, transaction ledgers, inventory contents, owned properties, equipped outfits, and vehicle modifications serialize cleanly into `user://dta_savegame.json` and restore on game load.

```
                    ┌──────────────────────────┐
                    │       GameManager        │
                    │ (Wallet, Bank, Ledger)   │
                    └────────────┬─────────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           ▼                     ▼                     ▼
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│ InventorySystem  │   │   BaseVehicle3D  │   │ HumanoidSkin3D   │
│(16 Slots, Pickups│   │(Repair,Tune,Paint│   │ (Outfits/Colors) │
└──────────┬───────┘   └─────────┬────────┘   └─────────┬────────┘
           │                     │                      │
           └─────────────────────┼──────────────────────┘
                                 ▼
                    ┌──────────────────────────┐
                    │   EconomyUIController    │
                    │(Shop,Garage,ATM,Wardrobe)│
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │        SaveSystem        │
                    │ (JSON State Persistence) │
                    └──────────────────────────┘
```

---

## 2. Fictional Brands and Commercial Directory

| Fictional Brand | Category | Offerings & Gameplay Functions |
|---|---|---|
| **Mama Tong Cha Stall (মামা টং)** | Street Beverage & Food | Spiced milk tea (Cha), hot Singara, Samucha, and Speed energy drink for instant stamina and health recovery. |
| **Bismillah General Store (বিসমিল্লাহ স্টোর)** | Grocery & Utility | First aid medical kits, portable vehicle toolkits, provisions, and contraband fences. |
| **Bhai Bhai Auto Workshop (ভাই ভাই অটো)** | Vehicle Garage & Tuning | Body repair, custom polyurethane spray painting, Stage 1 ECU tuning, and reinforced steel bullbars. |
| **Lalbagh Tailors & Desi Fashion (লালবাগ)** | Clothing Boutique | Urban casual wear, traditional silk Panjabis, formal office shirts, rickshaw puller lungis, and night tactical gear. |
| **Padma Housing Ltd. (পদ্মা হাউজিং)** | Real Estate & Housing | Purchasable residential apartments and safehouses with beds, wardrobes, and private item stashes. |
| **Rupali Bank ATM (রূপালী ব্যাংক এটিএম)** | Digital Banking & ATM | 24/7 fast cash deposits, cash withdrawals, balance statements, and transaction ledger. |

---

## 3. Financial Subsystems & Banking

### 3.1 Currency System (Bangladesh Taka ৳)
Managed via `data/economy_system.gd` and `autoloads/game_manager.gd`:
- Currency formatting implements authentic South Asian thousand and lakh delimiters:
  - `৳ 10` (Cha)
  - `৳ 1,500` (Carburetor delivery reward)
  - `৳ 25,000` (Buriganga Safehouse Flat)
  - `৳ 1,50,000` (Luxury vehicle purchase)

### 3.2 Rupali Bank & ATM Services
Interactive 3D ATM kiosks (`scripts/economy/atm_terminal.tscn`) placed across markets and stations:
- **Cash Deposit**: Move money from pocket wallet into bank account (`deposit_to_bank(amount)`).
- **Cash Withdrawal**: Withdraw money from bank account into wallet (`withdraw_from_bank(amount)`).
- **Preset Fast Buttons**: `[৳ 500]`, `[৳ 2,000]`, `[৳ 5,000]`, and `[All]`.
- **Audio Feedback**: Synthesized electronic dual-tone chime (`atm_beep.wav`) and mechanical register ding (`cash_register.wav`).

### 3.3 Digital Transaction Ledger
Every financial event is recorded in a circular ledger (up to 50 entries):
```json
{
  "id": 14,
  "time": "14:30",
  "type": "PURCHASE",
  "description": "Bhai Bhai Workshop: Stage 1 ECU Tuning",
  "amount": -3500,
  "wallet_balance": 1500,
  "bank_balance": 25000
}
```
Viewable dynamically in the ATM user interface and saved in player progress.

---

## 4. Consumables, Food and Drink

All food and drink items have immediate, quantifiable gameplay effects:

| Item | Price | Effect Type | Gameplay Value |
|---|---|---|---|
| **Spiced Milk Tea (দুধ চা)** | ৳ 10 | Stamina Boost | +40 Stamina; triggers rapid stamina regeneration. |
| **Hot Spiced Singara (সিঙ্গারা)** | ৳ 15 | Health Recovery | +25 HP health restore. |
| **Crispy Samucha (সমুচা)** | ৳ 15 | Health Recovery | +25 HP health restore. |
| **Speed Energy Drink (স্পিড)** | ৳ 35 | Sprint Endurance | +80 Stamina; doubles sprint duration for 30s. |
| **Old Dhaka Kacchi Biryani (কাচ্চি)** | ৳ 180 | Full Restore | 100% Health and 100% Stamina restoration. |
| **First Aid Medical Kit (মেডকিট)** | ৳ 450 | Advanced Healing | +75 HP portable field healing. |
| **Vehicle Tool Kit (টুলবক্স)** | ৳ 650 | Field Repair | +60 HP portable vehicle repair without needing a garage. |

---

## 5. Vehicle Garages & Customization

The garage system is hosted at *Bhai Bhai Auto Workshop* and operates on any parked vehicle:

### 5.1 Full Body & Engine Repair (৳ 500)
- Restores vehicle health to `max_health` (100 HP stock, 180 HP armored).
- Extinguishes engine smoke (`GPUParticles3D`) and fire particles.
- Resets tire puncture status and aligns suspension.
- Plays metallic ratchet audio (`wrench_ratchet.wav`).

### 5.2 Polyurethane Spray Painting (৳ 1,200)
Players can choose from 6 authentic colors with instant live preview:
- **Dhaka Green**: `Color(0.08, 0.45, 0.22)`
- **Crimson Red**: `Color(0.72, 0.12, 0.15)`
- **Midnight Black**: `Color(0.08, 0.09, 0.10)`
- **Pearl White**: `Color(0.92, 0.93, 0.95)`
- **Sky Blue**: `Color(0.15, 0.45, 0.78)`
- **Amber Yellow**: `Color(0.88, 0.65, 0.12)`

### 5.3 Stage 1 ECU Performance Tuning (৳ 3,500)
- Multiplies `max_engine_force` by $1.25\times$ (+25% torque).
- Increases `base_max_speed_kmh` by $1.15\times$ (+15% top speed).
- Improves acceleration out of corners and hill climbing.

### 5.4 Reinforced Steel Bullbar & Armor (৳ 4,500)
- Upgrades `max_health` from 100 to 180 HP (+80% durability).
- Reduces collision impact damage taken during high-speed chases.

---

## 6. Clothing Shops and Wardrobe Customization

*Lalbagh Tailors & Desi Fashion* provides 5 distinct character attire presets that dynamically modify the 3D player mesh materials:

| Outfit Name | Cost | Visual Aesthetic & Materials |
|---|---|---|
| **Dhaka Street Casual** | ৳ 0 (Default) | Navy blue graphic tee, dark stone-wash jeans, white sneakers. |
| **Classic White Panjabi & Payjama** | ৳ 850 | Crisp white cotton-silk panjabi, loose payjama, black leather sandals. |
| **Corporate Office Shirt & Slacks** | ৳ 1,400 | Tailored sky-blue button-down dress shirt, charcoal slacks, black oxford shoes. |
| **Rickshaw Puller Vest & Lungi** | ৳ 350 | Working-class ribbed cotton vest, green checkered lungi, brown strap sandals. |
| **Tactical Night Windbreaker** | ৳ 3,200 | Matte black reinforced ripstop windbreaker, dark tactical cargo pants, combat boots. |

Purchased outfits can be freely swapped at any owned safehouse wardrobe.

---

## 7. Real Estate Properties and Safehouses

Marketed by fictional agency *Padma Housing Ltd.*:

### 7.1 Available Properties
1. **Buriganga Riverview Flat (2nd Floor)** (`safehouse_buriganga`):
   - **Cost**: ৳ 25,000 (payable via Cash or Bank transfer).
   - **Location**: Sadarghat launch terminal riverfront (`Vector3(35.0, 0.2, 45.0)`).
   - **Features**: Master bed, clothing wardrobe, and safe haven protection.
2. **Old Dhaka Tin-Roof Unit** (`safehouse_old_dhaka`):
   - **Cost**: ৳ 8,500.
   - **Location**: Lalbagh alley settlement (`Vector3(-72.0, 0.2, 115.0)`).
   - **Features**: Affordable starter home, sleeping cot, and auto-save point.

### 7.2 Safehouse Amenities
- **Sleep & Rest**: Advances world time by 6 hours, restores 100% player health and stamina, and automatically triggers game serialization via `SaveSystem`.
- **Wanted Level Evaporator**: Entering an owned safehouse clears up to 2 Wanted Stars.
- **Wardrobe**: Instant access to clothing customization.

---

## 8. Inventory System and 3D Ground Pickups

### 8.1 16-Slot Backpack (`data/inventory_system.gd`)
- Fixed 16-slot grid.
- Stacking logic up to item `max_stack` (3 to 20 units).
- **Use Action**: Directly applies item effects (HP heal, stamina refill, car repair, or cash grant).
- **Drop Action**: Removes item(s) from inventory and spawns a physical 3D pickup entity at the player's feet.

### 8.2 Interactive 3D Ground Pickups (`scripts/economy/item_pickup_3d.tscn`)
- Dynamic 3D entity featuring continuous bobbing motion ($0.12\text{m}$ amplitude) and $1.5\text{ rad/s}$ axial rotation.
- Visual category color tinting:
  - Food & Beverage: Warm Amber
  - Utilities & Tools: Cyan / Blue
  - Valuables & Money: Emerald Green
  - Clothing: Magenta / Violet
- Proximity detection sphere (Layer 7) triggering `[E] Pick up <Item Name> x<Qty>`.
- Audio confirmation (`item_pickup.wav`).

---

## 9. Reusable Interaction & UI Component Architecture

All economy interactions utilize modular components:

```
┌─────────────────────────────────────────────────────────────┐
│                       Interactable                          │
│  (Area3D, Layer 7 Interaction, Layer 2 Detection)           │
├─────────────────────────────────────────────────────────────┤
│  - prompt_text: "Browse Mama Tong Cha Stall"                │
│  - action_input: "interact" (Key [E])                       │
│  - Signal: interacted(user: Node)                           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   EconomyUIController                       │
│  (CanvasLayer 12, Master Modal & Mouse Mode Coordinator)    │
├─────────────────────────────────────────────────────────────┤
│  - ShopModal      : Buy/sell consumables and tools          │
│  - GarageModal    : Vehicle health, repair, paint, tune     │
│  - AtmModal       : Fast deposit, withdraw, transaction log │
│  - ClothingModal  : Dynamic outfit purchasing & equipping   │
│  - InventoryModal : 16-slot backpack inspection & drops     │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. Playable Diagnostic Scenario & Hotkeys

**Scene**: [tests/test_economy_system.tscn](file:///c:/Users/Tonmoy/Documents/DTA%200/tests/test_economy_system.tscn)  
**Script**: [tests/test_economy_system.gd](file:///c:/Users/Tonmoy/Documents/DTA%200/tests/test_economy_system.gd)

### Keyboard Shortcuts
| Hotkey | Function | Action |
|---|---|---|
| **[E]** | Interact | Contextual interaction with any shop, ATM, garage, or ground pickup |
| **[I / Tab]** | Inventory | Toggle 16-slot backpack interface |
| **[B]** | Quick ATM | Opens Rupali Bank ATM modal anywhere |
| **[G]** | Quick Garage | Opens Bhai Bhai Auto Workshop modal for target vehicle |
| **[1]** | Quick Snack | Consumes Singara from bag (+25 HP) |
| **[2]** | Quick Cha | Consumes milk tea from bag (+Stamina) |
| **[3]** | Cash Cheat | Injects ৳ 5,000 cash into player wallet |
| **[4]** | Damage Vehicle | Applies 35 HP damage to test sedan (tests garage repair) |
| **[K]** | Quick Save | Serializes complete state to `user://dta_savegame.json` |
| **[L]** | Quick Load | Restores wallet, bank, inventory, properties, outfit, and location |
| **[ESC]** | Close Menu | Closes any active modal and restores mouse capture |
