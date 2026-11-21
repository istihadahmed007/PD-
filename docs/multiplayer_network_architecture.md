# BANGLADESH ONLINE MULTIPLAYER GAME: NETWORK ARCHITECTURE
**Project:** DTA: Dhaka Theft Auto (ঢাকা থেফট অটো)  
**Phase:** Phase 1 — Working Online Multiplayer Foundation  
**Engine:** Godot Engine 4.7.2 (Forward+ / Headless Support)  
**Protocol:** UDP via Native ENet Multi-channel Peer-to-Peer / Client-Server  

---

## 1. Executive Summary

Phase 1 establishes a production-ready, server-authoritative online multiplayer foundation for the Bangladesh-inspired 3D open-world game. Bypassing unnecessary open-world distractions (missions, police AI, heavy traffic), Phase 1 concentrates strictly on network reliability, authoritative physics simulation, deterministic character replication, remote movement interpolation, and client-server synchronization.

```
                              ┌─────────────────────────────────────────┐
                              │       GODOT 4 DEDICATED SERVER          │
                              │     ENetMultiplayerPeer (Port 7777)     │
                              │  - Authoritative Physics (move_and_slide)│
                              │  - Input Validation & Anti-Spoofing     │
                              │  - MultiplayerSpawner & Synchronizer    │
                              └──────────────────┬──────────────────────┘
                                                 │
                     ┌───────────────────────────┴───────────────────────────┐
                     │                                                       │
        UDP Unreliable Ordered Inputs                           UDP Unreliable Ordered Inputs
     UDP Reliable Handshakes & Rosters                       UDP Reliable Handshakes & Rosters
                     │                                                       │
                     ▼                                                       ▼
       ┌───────────────────────────┐                           ┌───────────────────────────┐
       │     CLIENT 1 ("Joy")      │                           │    CLIENT 2 ("Kabir")     │
       │  - Local Camera Controller│                           │  - Local Camera Controller│
       │  - Mouse Orbit Rig        │                           │  - Mouse Orbit Rig        │
       │  - Remote Kabir Lerp Sync │                           │  - Remote Joy Lerp Sync   │
       │  - 3D Billboard Labels    │                           │  - 3D Billboard Labels    │
       └───────────────────────────┘                           └───────────────────────────┘
```

---

## 2. Core Network Stack & Godot Native Multiplayer

The system uses Godot 4's native high-level multiplayer networking primitives:

### 2.1 ENetMultiplayerPeer
- **Transport Layer:** UDP (User Datagram Protocol), providing lightweight, connection-oriented packet delivery with low overhead and zero head-of-line blocking across channels.
- **Dedicated Server:** Bound via `server_peer.create_server(port, max_clients)`. Runs completely GPU-free and display-free with `--headless`.
- **Client Socket:** Initiated via `client_peer.create_client(ip, port)`. Handles auto-reconnect, packet reordering, and connection timeouts.

### 2.2 MultiplayerAPI & SceneMultiplayer
- Managed by `NetworkManager` autoload (`res://multiplayer/network_manager.gd`).
- Tracks connection lifecycle signals:
  - `peer_connected(id: int)`
  - `peer_disconnected(id: int)`
  - `connected_to_server()`
  - `connection_failed()`
  - `server_disconnected()`

### 2.3 MultiplayerSpawner
- Configured in `res://multiplayer/multiplayer_world.tscn`:
  - `spawn_path`: `NodePath("../SpawnedPlayers")`
  - `_spawnable_scenes`: `["res://multiplayer/network_player.tscn"]`
- When a client connects and completes the registration handshake, the server instantiates `network_player.tscn` with `node.name = str(peer_id)` and adds it with `players_container.add_child(player, true)`.
- `MultiplayerSpawner` automatically serializes and replicates the player instance to all connected peers and late joiners.
- When a peer leaves, the server removes the node; `MultiplayerSpawner` automatically despawns the node on all clients.

### 2.4 MultiplayerSynchronizer
- Programmatically attached to each `NetworkPlayer` via `SceneReplicationConfig`:
  - `sync_position` (Vector3): Replicated `ALWAYS` on physics ticks.
  - `sync_rotation_y` (float): Replicated `ALWAYS` for smooth heading.
  - `sync_velocity` (Vector3): Replicated `ALWAYS` for animation blending.
  - `sync_locomotion_state` (int): Replicated `ALWAYS` (Idle, Walk, Run, Sprint, Jump, Fall, Land).
  - `player_nickname` (String): Replicated `ON_CHANGE` on spawn.
  - `player_peer_id` (int): Replicated `ON_CHANGE` on spawn.
- Authority is pinned to Server (`synchronizer.set_multiplayer_authority(1)`).

---

## 3. Server-Authoritative Gameplay & Anti-Cheat Validation

### 3.1 Input Transmission
- Clients never calculate their own authoritative world position.
- Instead, each client samples user inputs in `_physics_process(delta)`:
  - Direction vector: `Input.get_vector("move_left", "move_right", "move_up", "move_down")`
  - Sprint state: `Input.is_action_pressed("sprint")`
  - Jump trigger: `Input.is_action_just_pressed("jump")`
  - Camera Yaw: `_cam_yaw` (float, orientation of third-person follow rig)
- Sent via **Unreliable Ordered** RPC:
  ```gdscript
  @rpc("any_peer", "call_remote", "unreliable_ordered")
  func c2s_send_input(input_vec: Vector2, sprint: bool, jump: bool, cam_yaw: float) -> void
  ```

### 3.2 Server Validation
1. **Sender Identification:** Checks `multiplayer.get_remote_sender_id() == player_peer_id`. Malicious clients cannot send input commands on behalf of other peers.
2. **Input Clamping:** `input_vec = input_vec.limit_length(1.0)`. Prevents speed hacks via over-unity diagonal vectors.
3. **World-Space Projection:** Server translates `input_vec` relative to `cam_yaw`:
   $$\vec{d} = (\cos\theta \cdot x - \sin\theta \cdot y) \hat{i} + (-\sin\theta \cdot x - \cos\theta \cdot y) \hat{k}$$
4. **Collision & Stepping:** Server calls `move_and_slide()` against the level terrain collision layer.

---

## 4. Camera Isolation & Remote Interpolation

### 4.1 Strict Camera Isolation
- `NetworkPlayer` checks ownership: `is_local_player = (player_peer_id == multiplayer.get_unique_id())`.
- **Local Player:**
  - Instantiates `CameraRig` (`SpringArm3D` + `Camera3D`).
  - `PlayerCamera.current = true`.
  - Captures mouse with `Input.MOUSE_MODE_CAPTURED`.
  - ESC key toggles between cursor and camera capture.
- **Remote Player:**
  - `CameraRig` is destroyed immediately (`camera_rig.queue_free()`).
  - `PlayerCamera.current = false`.
  - Mouse input is ignored.
  - **Guarantee:** A player can never control another player's camera or movement.

### 4.2 Jitter Elimination (Remote Interpolation)
- On remote clients, character position is smoothly blended towards authoritative state:
  $$\vec{p}_{t} = \text{lerp}(\vec{p}_{t}, \vec{p}_{\text{sync}}, \min(1.0, 18.0 \cdot \Delta t))$$
  $$\theta_{t} = \text{lerp\_angle}(\theta_{t}, \theta_{\text{sync}}, \min(1.0, 18.0 \cdot \Delta t))$$
- On local clients, smooth reconciliation is applied:
  - If drift $< 3.0\text{ m}$: Smooth lerp at $16.0 \cdot \Delta t$.
  - If drift $\ge 3.0\text{ m}$: Hard snap to server position.

---

## 5. Playable Neighbourhood Map

- **Scene:** `res://multiplayer/neighbourhood_map.tscn`
- **Area:** Compact $80\text{ m} \times 70\text{ m}$ urban district.
- **Components:**
  - Concrete East-West main street with yellow center line.
  - North-South cross junction.
  - Concrete sidewalks with raised curbs.
  - Residential Buildings: Multi-story flats with balconies and rooftop water tanks.
  - Local shops with authentic Bangla signboards:
    - *মামা টং চা দোকান* (Mama Tong Tea Stall with blue canopy, wooden counter, customer benches).
    - *বিসমিল্লাহ জেনারেল স্টোর* (Bismillah General Store).
    - *ফার্মেসী* (Pharmacy).
    - *মিষ্টান্ন ভাণ্ডার* (Sweetmeat shop).
    - *ভাই ভাই অটো ওয়ার্কশপ* (Auto Workshop).
    - *সিএনজি স্ট্যান্ড* (CNG Rickshaw Stand).
  - Streetlights with localized illumination.
  - Banyan trees (*Ficus benghalensis*) and Coconut palms.
  - 8 designated spawn points spread along street markers.
  - Complete StaticBody3D collision meshes on Layer 1/2.
