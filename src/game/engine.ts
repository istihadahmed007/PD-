/**
 * DTA: Dhaka Theft Auto - Core Three.js Game Engine & Systems
 */

import * as THREE from 'three';
import {
  WORLD_HALF_SIZE,
  RIVER_Z_START,
  DISTRICTS,
  POIS,
  MISSIONS,
  FARE_DESTINATIONS,
  TRAFFIC_ROUTES,
  type District,
  type POI,
  type Mission,
  type FareDestination
} from './worldData';
import { buildDhakaWorld, type WorldBuildResult } from './worldBuilder';
import {
  PhysicsEngine,
  type PlayerPhysicsState,
  type VehicleInstance,
  type VehicleType,
  VEHICLE_CONFIGS
} from './physics';
import { soundEngine } from './audio';

export interface GameHUDState {
  health: number;
  cashBdt: number;
  wantedStars: number;
  currentDistrict: District;
  isInVehicle: boolean;
  vehicleType: VehicleType | null;
  speedKmh: number;
  activeMission: Mission | null;
  missionProgress: string | null;
  missionTimeLeft: number | null;
  activeFare: {
    destination: FareDestination;
    fareBdt: number;
    distanceMeters: number;
  } | null;
  nearbyInteractText: string | null;
  timeOfDay: string;
}

export interface InputState {
  forward: number;
  strafe: number;
  sprint: boolean;
  jump: boolean;
  throttle: number;
  steer: number;
  handbrake: boolean;
  horn: boolean;
}

export class DhakaGameEngine {
  private container: HTMLElement;
  private scene: THREE.Scene;
  private camera: THREE.PerspectiveCamera;
  private renderer: THREE.WebGLRenderer;
  private clock: THREE.Clock;

  // Systems
  private world: WorldBuildResult | null = null;
  private physics: PhysicsEngine | null = null;

  // Player & Vehicles
  private playerMesh: THREE.Group;
  private playerState: PlayerPhysicsState;
  private vehicles: VehicleInstance[] = [];
  private activeVehicle: VehicleInstance | null = null;

  // AI Traffic
  private trafficVehicles: {
    mesh: THREE.Group;
    routeIndex: number;
    waypointIndex: number;
    speed: number;
  }[] = [];

  // Lighting & Day/Night
  private sunLight: THREE.DirectionalLight;
  private ambientLight: THREE.AmbientLight;
  private gameTime: number = 14.5; // Starts at 2:30 PM (Dhaka golden afternoon)

  // Camera Orbit Controls
  private cameraYaw: number = 0;
  private cameraPitch: number = 0.25;
  private isPointerLocked: boolean = false;

  // Input
  private inputs: InputState = {
    forward: 0,
    strafe: 0,
    sprint: false,
    jump: false,
    throttle: 0,
    steer: 0,
    handbrake: false,
    horn: false
  };

  // Missions & Gameplay state
  private cashBdt: number = 1500;
  private health: number = 100;
  private wantedStars: number = 0;
  private activeMission: Mission | null = null;
  private missionTimeRemaining: number = 0;
  private activeFare: {
    destination: FareDestination;
    fareBdt: number;
    distanceMeters: number;
  } | null = null;

  // HUD Callback
  private onHUDUpdate: ((state: GameHUDState) => void) | null = null;
  private animFrameId: number = 0;
  private isRunning: boolean = false;

  constructor(container: HTMLElement, onHUDUpdate?: (state: GameHUDState) => void) {
    this.container = container;
    this.onHUDUpdate = onHUDUpdate || null;

    // 1. Scene & Atmosphere
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0xF09A50); // Warm Dhaka sky
    this.scene.fog = new THREE.FogExp2(0xE8B888, 0.0016); // Dhaka atmospheric warm haze

    // 2. Camera
    const aspect = container.clientWidth / container.clientHeight;
    this.camera = new THREE.PerspectiveCamera(65, aspect, 0.5, 2000);

    // 3. Renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
    this.renderer.setSize(container.clientWidth, container.clientHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.05;
    this.container.appendChild(this.renderer.domElement);

    this.clock = new THREE.Clock();

    // 4. Lighting
    this.ambientLight = new THREE.AmbientLight(0xFFE8D6, 0.85);
    this.scene.add(this.ambientLight);

    this.sunLight = new THREE.DirectionalLight(0xFFE4B5, 1.6);
    this.sunLight.position.set(300, 600, 200);
    this.sunLight.castShadow = true;
    this.sunLight.shadow.mapSize.width = 2048;
    this.sunLight.shadow.mapSize.height = 2048;
    this.sunLight.shadow.camera.near = 10;
    this.sunLight.shadow.camera.far = 1200;
    const shadowD = 350;
    this.sunLight.shadow.camera.left = -shadowD;
    this.sunLight.shadow.camera.right = shadowD;
    this.sunLight.shadow.camera.top = shadowD;
    this.sunLight.shadow.camera.bottom = -shadowD;
    this.scene.add(this.sunLight);

    // 5. Initialize Player
    this.playerMesh = this.createPlayerMesh();
    this.scene.add(this.playerMesh);

    this.playerState = {
      position: new THREE.Vector3(15, 0, 15), // Starts right at Shapla Chattar plaza
      velocity: new THREE.Vector3(),
      rotationY: 0,
      isGrounded: true,
      isInVehicle: false,
      currentVehicleId: null,
      speed: 0
    };

    // 6. Build World Geometry
    this.world = buildDhakaWorld(this.scene);
    this.physics = new PhysicsEngine(this.world.colliders, this.world.roadColliders);

    // 7. Spawn Vehicles & AI Traffic
    this.spawnInitialVehicles();
    this.spawnAITraffic();

    // 8. Event Listeners
    this.setupEventListeners();
  }

  // Create stylized Player 3D Mesh (Dhaka casual kurta & jeans)
  private createPlayerMesh(): THREE.Group {
    const group = new THREE.Group();

    // Torso (Bengali Panjabi / Kurta)
    const torsoGeo = new THREE.CylinderGeometry(0.38, 0.42, 0.9, 12);
    const torsoMat = new THREE.MeshStandardMaterial({ color: 0x059669 }); // Emerald green
    const torso = new THREE.Mesh(torsoGeo, torsoMat);
    torso.position.y = 1.05;
    torso.castShadow = true;
    group.add(torso);

    // Head
    const headGeo = new THREE.SphereGeometry(0.24, 12, 12);
    const headMat = new THREE.MeshStandardMaterial({ color: 0x8D5B4C }); // Warm South Asian complexion
    const head = new THREE.Mesh(headGeo, headMat);
    head.position.y = 1.68;
    head.castShadow = true;
    group.add(head);

    // Hair
    const hairGeo = new THREE.SphereGeometry(0.25, 8, 8);
    const hairMat = new THREE.MeshStandardMaterial({ color: 0x18181B });
    const hair = new THREE.Mesh(hairGeo, hairMat);
    hair.position.set(0, 1.76, -0.04);
    group.add(hair);

    // Legs / Pants
    const legGeo = new THREE.CylinderGeometry(0.14, 0.12, 0.75, 8);
    const legMat = new THREE.MeshStandardMaterial({ color: 0x1E293B }); // Dark denim
    const leftLeg = new THREE.Mesh(legGeo, legMat);
    leftLeg.position.set(-0.16, 0.38, 0);
    leftLeg.castShadow = true;
    group.add(leftLeg);

    const rightLeg = new THREE.Mesh(legGeo, legMat);
    rightLeg.position.set(0.16, 0.38, 0);
    rightLeg.castShadow = true;
    group.add(rightLeg);

    return group;
  }

  // 3D Procedural Dhaka Vehicle Meshes
  private createVehicleMesh(type: VehicleType, colorHex: number): THREE.Group {
    const group = new THREE.Group();

    if (type === 'cng') {
      // Iconic Dhaka Green CNG Auto-Rickshaw (Bajaj RE 3-wheeler)
      const bodyGeo = new THREE.BoxGeometry(2.0, 1.4, 2.6);
      const bodyMat = new THREE.MeshStandardMaterial({ color: 0x059669, roughness: 0.5 }); // Emerald Dhaka CNG green
      const body = new THREE.Mesh(bodyGeo, bodyMat);
      body.position.set(0, 0.9, -0.2);
      body.castShadow = true;
      group.add(body);

      // Yellow top hood
      const roofGeo = new THREE.BoxGeometry(1.9, 0.2, 2.7);
      const roofMat = new THREE.MeshStandardMaterial({ color: 0xFACC15 });
      const roof = new THREE.Mesh(roofGeo, roofMat);
      roof.position.set(0, 1.65, -0.2);
      group.add(roof);

      // Black metal safety cage grills
      const cageGeo = new THREE.CylinderGeometry(0.04, 0.04, 0.9, 6);
      const cageMat = new THREE.MeshStandardMaterial({ color: 0x18181B });
      [-0.95, 0.95].forEach((gx) => {
        const grill = new THREE.Mesh(cageGeo, cageMat);
        grill.position.set(gx, 1.1, 0.2);
        group.add(grill);
      });

      // Front single steering fork & wheel
      const frontWheelGeo = new THREE.CylinderGeometry(0.4, 0.4, 0.3, 12);
      const wheelMat = new THREE.MeshStandardMaterial({ color: 0x18181B });
      const frontWheel = new THREE.Mesh(frontWheelGeo, wheelMat);
      frontWheel.rotation.z = Math.PI / 2;
      frontWheel.position.set(0, 0.4, 1.3);
      group.add(frontWheel);

      // Rear wheels
      [-0.9, 0.9].forEach((wx) => {
        const rw = new THREE.Mesh(frontWheelGeo, wheelMat);
        rw.rotation.z = Math.PI / 2;
        rw.position.set(wx, 0.4, -0.8);
        group.add(rw);
      });

      // Bengali CNG meter & registration plate ("ঢাকা মেট্রো-থ ১১-৪২০")
      const plateCanvas = document.createElement('canvas');
      plateCanvas.width = 128;
      plateCanvas.height = 64;
      const pctx = plateCanvas.getContext('2d')!;
      pctx.fillStyle = '#059669';
      pctx.fillRect(0, 0, 128, 64);
      pctx.fillStyle = '#FFFFFF';
      pctx.font = 'bold 18px sans-serif';
      pctx.fillText('ঢাকা মেট্রো-থ', 10, 26);
      pctx.fillText('১১-৪২০', 25, 52);
      const plateTex = new THREE.CanvasTexture(plateCanvas);
      const plate = new THREE.Mesh(new THREE.PlaneGeometry(0.8, 0.4), new THREE.MeshBasicMaterial({ map: plateTex }));
      plate.position.set(0, 0.8, -1.52);
      plate.rotation.y = Math.PI;
      group.add(plate);

    } else if (type === 'car' || type === 'sports') {
      // Sleek Sedan / Sports Coupe
      const config = VEHICLE_CONFIGS[type];
      const bodyGeo = new THREE.BoxGeometry(config.width, 0.9, config.length);
      const bodyMat = new THREE.MeshStandardMaterial({ color: colorHex, metalness: 0.6, roughness: 0.3 });
      const body = new THREE.Mesh(bodyGeo, bodyMat);
      body.position.set(0, 0.65, 0);
      body.castShadow = true;
      group.add(body);

      // Cabin / Glass windshield
      const cabinGeo = new THREE.BoxGeometry(config.width * 0.85, 0.7, config.length * 0.5);
      const cabinMat = new THREE.MeshStandardMaterial({ color: 0x0F172A, roughness: 0.1, metalness: 0.8 });
      const cabin = new THREE.Mesh(cabinGeo, cabinMat);
      cabin.position.set(0, 1.3, -0.2);
      group.add(cabin);

      // 4 Wheels
      const wheelGeo = new THREE.CylinderGeometry(0.42, 0.42, 0.35, 12);
      const wheelMat = new THREE.MeshStandardMaterial({ color: 0x18181B });
      [
        { x: -config.width / 2, z: config.length * 0.3 },
        { x: config.width / 2, z: config.length * 0.3 },
        { x: -config.width / 2, z: -config.length * 0.3 },
        { x: config.width / 2, z: -config.length * 0.3 }
      ].forEach((wp) => {
        const w = new THREE.Mesh(wheelGeo, wheelMat);
        w.rotation.z = Math.PI / 2;
        w.position.set(wp.x, 0.42, wp.z);
        group.add(w);
      });

      // Headlights
      const lightGeo = new THREE.BoxGeometry(0.4, 0.2, 0.1);
      const lightMat = new THREE.MeshBasicMaterial({ color: 0xFEF08A });
      [-0.8, 0.8].forEach((lx) => {
        const light = new THREE.Mesh(lightGeo, lightMat);
        light.position.set(lx, 0.7, config.length / 2 + 0.02);
        group.add(light);
      });

    } else {
      // Cycle Rickshaw (Dhaka Rickshaw with folk art painting hood)
      const frameGeo = new THREE.BoxGeometry(1.6, 0.8, 2.4);
      const frameMat = new THREE.MeshStandardMaterial({ color: 0xDC2626 });
      const frame = new THREE.Mesh(frameGeo, frameMat);
      frame.position.set(0, 0.6, -0.2);
      group.add(frame);

      // Folk art painted canopy hood
      const hoodGeo = new THREE.CylinderGeometry(0.85, 0.9, 1.4, 12, 1, false, 0, Math.PI);
      const hoodMat = new THREE.MeshStandardMaterial({ color: 0xF59E0B });
      const hood = new THREE.Mesh(hoodGeo, hoodMat);
      hood.rotation.z = Math.PI / 2;
      hood.position.set(0, 1.4, -0.4);
      group.add(hood);

      // Large spoked rear wheels
      const rWheelGeo = new THREE.CylinderGeometry(0.55, 0.55, 0.12, 16);
      const rWheelMat = new THREE.MeshStandardMaterial({ color: 0xE2E8F0, metalness: 0.8 });
      [-0.85, 0.85].forEach((rx) => {
        const rw = new THREE.Mesh(rWheelGeo, rWheelMat);
        rw.rotation.z = Math.PI / 2;
        rw.position.set(rx, 0.55, -0.5);
        group.add(rw);
      });
    }

    return group;
  }

  // Spawn initial playable and parked vehicles throughout the city
  private spawnInitialVehicles() {
    const spawns: { id: string; type: VehicleType; color: number; x: number; z: number; rotY: number }[] = [
      { id: 'v_cng_shapla', type: 'cng', color: 0x059669, x: 18, z: -12, rotY: 0 },
      { id: 'v_taxi_shapla', type: 'car', color: 0xFACC15, x: -18, z: 20, rotY: Math.PI / 2 },
      { id: 'v_sports_gulshan', type: 'sports', color: 0xDC2626, x: 200, z: -540, rotY: Math.PI },
      { id: 'v_cng_olddhaka', type: 'cng', color: 0x059669, x: -240, z: 210, rotY: -Math.PI / 2 },
      { id: 'v_rickshaw_motijheel', type: 'rickshaw', color: 0x2563EB, x: 340, z: 20, rotY: 0 },
      { id: 'v_cng_sadarghat', type: 'cng', color: 0x059669, x: 10, z: 410, rotY: Math.PI }
    ];

    spawns.forEach((s) => {
      const mesh = this.createVehicleMesh(s.type, s.color);
      mesh.position.set(s.x, 0, s.z);
      mesh.rotation.y = s.rotY;
      this.scene.add(mesh);

      this.vehicles.push({
        id: s.id,
        type: s.type,
        mesh,
        position: new THREE.Vector3(s.x, 0, s.z),
        rotationY: s.rotY,
        speed: 0,
        steerAngle: 0,
        elevation: 0,
        health: 100
      });
    });
  }

  // Spawn AI traffic agents on arterial loops
  private spawnAITraffic() {
    const trafficConfigs = [
      { routeIdx: 0, wpIdx: 0, type: 'cng' as VehicleType, color: 0x059669, speed: 22 },
      { routeIdx: 0, wpIdx: 3, type: 'car' as VehicleType, color: 0x3B82F6, speed: 28 },
      { routeIdx: 1, wpIdx: 1, type: 'car' as VehicleType, color: 0x10B981, speed: 26 },
      { routeIdx: 2, wpIdx: 2, type: 'cng' as VehicleType, color: 0x059669, speed: 20 },
      { routeIdx: 4, wpIdx: 1, type: 'cng' as VehicleType, color: 0x059669, speed: 24 }
    ];

    trafficConfigs.forEach((cfg) => {
      const route = TRAFFIC_ROUTES[cfg.routeIdx];
      if (!route || !route.waypoints.length) return;

      const wp = route.waypoints[cfg.wpIdx % route.waypoints.length];
      const mesh = this.createVehicleMesh(cfg.type, cfg.color);
      mesh.position.set(wp.x, wp.y, wp.z);
      this.scene.add(mesh);

      this.trafficVehicles.push({
        mesh,
        routeIndex: cfg.routeIdx,
        waypointIndex: cfg.wpIdx,
        speed: cfg.speed
      });
    });
  }

  // Setup Mouse, PointerLock & Keyboard listeners
  private setupEventListeners() {
    const canvas = this.renderer.domElement;

    // Pointer lock for immersive camera look
    canvas.addEventListener('click', () => {
      if (!this.isPointerLocked) {
        canvas.requestPointerLock();
      }
    });

    document.addEventListener('pointerlockchange', () => {
      this.isPointerLocked = document.pointerLockElement === canvas;
    });

    document.addEventListener('mousemove', (e) => {
      if (!this.isPointerLocked) return;
      const sensitivity = 0.0022;
      this.cameraYaw -= e.movementX * sensitivity;
      this.cameraPitch = Math.max(0.05, Math.min(1.2, this.cameraPitch + e.movementY * sensitivity));
    });

    // Keyboard controls
    const keyMap: Record<string, boolean> = {};

    window.addEventListener('keydown', (e) => {
      keyMap[e.code] = true;
      this.processKeys(keyMap);

      // Vehicle Horn (H)
      if (e.code === 'KeyH') {
        if (this.playerState.isInVehicle && this.activeVehicle) {
          if (this.activeVehicle.type === 'cng') soundEngine.playCNGHorn();
          else if (this.activeVehicle.type === 'rickshaw') soundEngine.playRickshawBell();
          else soundEngine.playBusHorn();
        }
      }

      // Enter / Exit Vehicle (F or E)
      if (e.code === 'KeyF' || e.code === 'KeyE') {
        this.toggleVehicleInteraction();
      }

      // Start Next Mission (M)
      if (e.code === 'KeyM') {
        this.triggerNextMission();
      }

      // Hail Fare / Taxi Job (T)
      if (e.code === 'KeyT') {
        this.hailRandomFare();
      }
    });

    window.addEventListener('keyup', (e) => {
      keyMap[e.code] = false;
      this.processKeys(keyMap);
    });

    // Window resize
    window.addEventListener('resize', () => {
      if (!this.container) return;
      const w = this.container.clientWidth;
      const h = this.container.clientHeight;
      this.camera.aspect = w / h;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(w, h);
    });
  }

  private processKeys(keys: Record<string, boolean>) {
    // Movement / Throttle
    const w = keys['KeyW'] || keys['ArrowUp'];
    const s = keys['KeyS'] || keys['ArrowDown'];
    const a = keys['KeyA'] || keys['ArrowLeft'];
    const d = keys['KeyD'] || keys['ArrowRight'];

    this.inputs.forward = (w ? 1 : 0) - (s ? 1 : 0);
    this.inputs.strafe = (d ? 1 : 0) - (a ? 1 : 0);
    this.inputs.sprint = !!keys['ShiftLeft'] || !!keys['ShiftRight'];
    this.inputs.jump = !!keys['Space'];

    this.inputs.throttle = (w ? 1 : 0) - (s ? 1 : 0);
    this.inputs.steer = (a ? 1 : 0) - (d ? 1 : 0);
    this.inputs.handbrake = !!keys['Space'];
  }

  // Toggle Enter / Exit nearest vehicle
  private toggleVehicleInteraction() {
    if (this.playerState.isInVehicle) {
      // Exit vehicle: place player right beside the driver door
      if (this.activeVehicle) {
        const exitOffset = new THREE.Vector3(-2.2, 0, 0).applyAxisAngle(new THREE.Vector3(0, 1, 0), this.activeVehicle.rotationY);
        this.playerState.position.copy(this.activeVehicle.position).add(exitOffset);
        this.playerState.position.y = this.activeVehicle.elevation;
        this.playerMesh.visible = true;
        this.playerState.isInVehicle = false;
        this.playerState.currentVehicleId = null;
        this.activeVehicle = null;
        soundEngine.updateEngine(0, 50, false);
      }
    } else {
      // Find closest vehicle within 4.5 meters
      let closest: VehicleInstance | null = null;
      let minDist = 4.5;

      for (const v of this.vehicles) {
        const dist = this.playerState.position.distanceTo(v.position);
        if (dist < minDist) {
          minDist = dist;
          closest = v;
        }
      }

      if (closest) {
        this.playerState.isInVehicle = true;
        this.playerState.currentVehicleId = closest.id;
        this.activeVehicle = closest;
        this.playerMesh.visible = false; // Player is inside chassis
        if (closest.type === 'cng') soundEngine.playCNGHorn();
      }
    }
  }

  // Trigger Story Mission
  public triggerNextMission() {
    if (this.activeMission) return;
    const mission = MISSIONS[0]; // Start "The Old Dhaka Run"
    this.activeMission = mission;
    this.missionTimeRemaining = mission.timeLimitSec || 120;
    soundEngine.playCashEarned();
  }

  // Dynamic passenger fare hail
  public hailRandomFare() {
    if (this.activeFare) return;
    const dest = FARE_DESTINATIONS[Math.floor(Math.random() * FARE_DESTINATIONS.length)];
    const dist = this.getCurrentPosition().distanceTo(new THREE.Vector3(dest.x, 0, dest.z));
    const fare = Math.floor(150 + (dist * 1.5) * dest.tipMultiplier);

    this.activeFare = {
      destination: dest,
      fareBdt: fare,
      distanceMeters: Math.floor(dist)
    };
    soundEngine.playRickshawBell();
  }

  // Determine which district player is inside
  public getCurrentDistrict(): District {
    const pos = this.getCurrentPosition();
    for (const d of DISTRICTS) {
      if (
        pos.x >= d.bounds.minX &&
        pos.x <= d.bounds.maxX &&
        pos.z >= d.bounds.minZ &&
        pos.z <= d.bounds.maxZ
      ) {
        return d;
      }
    }
    return DISTRICTS[0]; // Default Old Dhaka
  }

  public getCurrentPosition(): THREE.Vector3 {
    return this.playerState.isInVehicle && this.activeVehicle
      ? this.activeVehicle.position
      : this.playerState.position;
  }

  public getPlayerHeading(): number {
    return this.playerState.isInVehicle && this.activeVehicle
      ? this.activeVehicle.rotationY
      : this.playerState.rotationY;
  }

  // Main Simulation Loop
  public start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.clock.start();

    const animate = () => {
      if (!this.isRunning) return;
      this.animFrameId = requestAnimationFrame(animate);

      const delta = Math.min(this.clock.getDelta(), 0.1);
      const elapsedTime = this.clock.getElapsedTime();

      this.updatePhysics(delta);
      this.updateAITraffic(delta);
      this.updateCamera(delta);
      this.updateMissionsAndFares(delta);
      this.updateEnvironment(delta);

      if (this.world) {
        this.world.update(elapsedTime);
      }

      this.renderer.render(this.scene, this.camera);
      this.emitHUDState();
    };

    animate();
  }

  public stop() {
    this.isRunning = false;
    cancelAnimationFrame(this.animFrameId);
  }

  // Update Physics (Player on foot OR vehicle driving)
  private updatePhysics(delta: number) {
    if (!this.physics) return;

    if (this.playerState.isInVehicle && this.activeVehicle) {
      this.physics.updateVehicle(this.activeVehicle, this.inputs, delta);
      // Synchronize player position with vehicle
      this.playerState.position.copy(this.activeVehicle.position);
      soundEngine.updateEngine(
        this.activeVehicle.speed,
        VEHICLE_CONFIGS[this.activeVehicle.type].maxSpeed,
        true
      );
    } else {
      this.physics.updatePlayerMovement(this.playerState, this.inputs, this.cameraYaw, delta);
      this.playerMesh.position.copy(this.playerState.position);
      this.playerMesh.rotation.y = this.playerState.rotationY;
      soundEngine.updateEngine(0, 50, false);
    }
  }

  // Update AI Traffic along route waypoints
  private updateAITraffic(delta: number) {
    this.trafficVehicles.forEach((agent) => {
      const route = TRAFFIC_ROUTES[agent.routeIndex];
      if (!route || !route.waypoints.length) return;

      const targetWp = route.waypoints[agent.waypointIndex];
      const targetVec = new THREE.Vector3(targetWp.x, targetWp.y, targetWp.z);
      const toTarget = targetVec.clone().sub(agent.mesh.position);
      const dist = toTarget.length();

      if (dist < 4.0) {
        // Next waypoint
        agent.waypointIndex = (agent.waypointIndex + 1) % route.waypoints.length;
      } else {
        toTarget.normalize();
        const targetRotY = Math.atan2(toTarget.x, toTarget.z);
        agent.mesh.rotation.y = THREE.MathUtils.lerp(agent.mesh.rotation.y, targetRotY, delta * 4);
        agent.mesh.position.addScaledVector(toTarget, agent.speed * delta);
      }
    });
  }

  // Smooth third-person follow camera
  private updateCamera(delta: number) {
    const targetPos = this.getCurrentPosition();

    if (this.playerState.isInVehicle && this.activeVehicle) {
      // Dynamic vehicle chase cam
      const distance = 9.5;
      const height = 3.8;
      const forwardX = Math.sin(this.activeVehicle.rotationY);
      const forwardZ = Math.cos(this.activeVehicle.rotationY);

      const desiredCamPos = new THREE.Vector3(
        targetPos.x - forwardX * distance,
        targetPos.y + height,
        targetPos.z - forwardZ * distance
      );

      this.camera.position.lerp(desiredCamPos, delta * 6);
      this.camera.lookAt(targetPos.x, targetPos.y + 1.2, targetPos.z);
    } else {
      // Third-person orbit on foot
      const distance = 4.8;
      const height = 2.0;

      const camX = targetPos.x + Math.sin(this.cameraYaw) * Math.cos(this.cameraPitch) * distance;
      const camY = targetPos.y + height + Math.sin(this.cameraPitch) * distance;
      const camZ = targetPos.z + Math.cos(this.cameraYaw) * Math.cos(this.cameraPitch) * distance;

      this.camera.position.set(camX, camY, camZ);
      this.camera.lookAt(targetPos.x, targetPos.y + 1.4, targetPos.z);
    }
  }

  // Mission & Taxi Fare Evaluation
  private updateMissionsAndFares(delta: number) {
    const pos = this.getCurrentPosition();

    // 1. Mission Progress Check
    if (this.activeMission) {
      this.missionTimeRemaining = Math.max(0, this.missionTimeRemaining - delta);
      const dropPOI = POIS.find((p) => p.id === this.activeMission?.dropoffPOIId);

      if (dropPOI) {
        const distToDrop = pos.distanceTo(new THREE.Vector3(dropPOI.x, 0, dropPOI.z));
        if (distToDrop <= dropPOI.radius + 5) {
          // Mission Success!
          this.cashBdt += this.activeMission.rewardBdt;
          soundEngine.playMissionComplete();
          this.activeMission = null;
        }
      }

      if (this.missionTimeRemaining <= 0) {
        // Mission Failed timeout
        this.activeMission = null;
      }
    }

    // 2. Active Taxi / CNG Fare Check
    if (this.activeFare) {
      const destVec = new THREE.Vector3(this.activeFare.destination.x, 0, this.activeFare.destination.z);
      const dist = pos.distanceTo(destVec);
      this.activeFare.distanceMeters = Math.floor(dist);

      if (dist < 18) {
        // Passenger arrived!
        this.cashBdt += this.activeFare.fareBdt;
        soundEngine.playCashEarned();
        this.activeFare = null;
      }
    }
  }

  // Dynamic Day/Night & Lighting
  private updateEnvironment(delta: number) {
    // Advance time smoothly (1 real minute = 1 game hour)
    this.gameTime = (this.gameTime + (delta / 60)) % 24;

    // Sun angle calculation
    const sunAngle = ((this.gameTime - 6) / 12) * Math.PI;
    const sunY = Math.sin(sunAngle) * 500;
    const sunX = Math.cos(sunAngle) * 600;

    this.sunLight.position.set(sunX, Math.max(20, sunY), 200);

    if (this.gameTime >= 6 && this.gameTime < 18) {
      // Daytime / Golden hour
      this.ambientLight.intensity = 0.85;
      this.sunLight.intensity = 1.6;
    } else {
      // Dhaka Night atmosphere with neon glow
      this.ambientLight.intensity = 0.25;
      this.sunLight.intensity = 0.15;
    }
  }

  // Dispatch live game metrics to React HUD
  private emitHUDState() {
    if (!this.onHUDUpdate) return;

    const currentPos = this.getCurrentPosition();
    let interactText: string | null = null;

    if (!this.playerState.isInVehicle) {
      // Check nearest vehicle
      for (const v of this.vehicles) {
        if (currentPos.distanceTo(v.position) < 3.8) {
          interactText = `Press [E / F] to Drive ${v.type.toUpperCase()}`;
          break;
        }
      }

      // Check nearest POI
      if (!interactText) {
        for (const poi of POIS) {
          if (currentPos.distanceTo(new THREE.Vector3(poi.x, 0, poi.z)) < poi.radius) {
            interactText = `${poi.nameBn} • ${poi.interactAction || 'Interact'}`;
            break;
          }
        }
      }
    } else {
      interactText = 'Press [E / F] to Exit • [H] Honk Horn';
    }

    const speedKmh = this.playerState.isInVehicle && this.activeVehicle
      ? Math.round(Math.abs(this.activeVehicle.speed) * 2.8)
      : Math.round(this.playerState.speed * 2.5);

    const hours = Math.floor(this.gameTime);
    const mins = Math.floor((this.gameTime % 1) * 60);
    const timeFormatted = `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;

    this.onHUDUpdate({
      health: this.health,
      cashBdt: this.cashBdt,
      wantedStars: this.wantedStars,
      currentDistrict: this.getCurrentDistrict(),
      isInVehicle: this.playerState.isInVehicle,
      vehicleType: this.activeVehicle ? this.activeVehicle.type : null,
      speedKmh,
      activeMission: this.activeMission,
      missionProgress: this.activeMission ? `Deliver to: ${this.activeMission.dropoffPOIId}` : null,
      missionTimeLeft: this.activeMission ? Math.ceil(this.missionTimeRemaining) : null,
      activeFare: this.activeFare,
      nearbyInteractText: interactText,
      timeOfDay: timeFormatted
    });
  }

  public getMapEntities() {
    return {
      playerPosition: this.getCurrentPosition(),
      playerHeading: this.getPlayerHeading(),
      vehicles: this.vehicles.map((v) => ({ x: v.position.x, z: v.position.z, type: v.type })),
      pois: POIS,
      activeMission: this.activeMission,
      activeFare: this.activeFare
    };
  }

  public destroy() {
    this.stop();
    window.removeEventListener('resize', () => {});
    if (this.renderer.domElement.parentElement) {
      this.renderer.domElement.parentElement.removeChild(this.renderer.domElement);
    }
    this.renderer.dispose();
  }
}
