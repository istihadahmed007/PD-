/**
 * DTA: Dhaka Theft Auto - Procedural 3D World Builder
 * Builds high-fidelity stylized Dhaka city in Three.js
 */

import * as THREE from 'three';
import {
  WORLD_HALF_SIZE,
  RIVER_Z_START,
  ROAD_SEGMENTS,
  POIS,
  DISTRICTS,
  generateWorldBuildings,
  type RoadSegment,
  type BuildingData
} from './worldData';

export interface WorldBuildResult {
  group: THREE.Group;
  colliders: THREE.Box3[];
  roadColliders: { minX: number; maxX: number; minZ: number; maxZ: number; elevation: number }[];
  riverMesh: THREE.Mesh;
  launchMeshes: THREE.Group[];
  update: (time: number) => void;
}

// Procedural Canvas Texture Generators for rich Dhaka aesthetics
function createBuildingTexture(style: BuildingData['style'], wallColor: string, accentColor?: string): THREE.CanvasTexture {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d')!;

  // Base wall fill
  ctx.fillStyle = wallColor;
  ctx.fillRect(0, 0, 256, 256);

  if (style === 'old_dhaka_brick') {
    // Weathered brick layers & ornate wooden balconies
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.25)';
    ctx.lineWidth = 1;
    for (let y = 0; y < 256; y += 16) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(256, y);
      ctx.stroke();
    }
    // Arched Mughal windows
    for (let y = 16; y < 240; y += 48) {
      for (let x = 16; x < 240; x += 40) {
        ctx.fillStyle = '#1A110B';
        ctx.fillRect(x, y + 10, 20, 26);
        ctx.beginPath();
        ctx.arc(x + 10, y + 10, 10, Math.PI, 0, false);
        ctx.fill();

        // Window frame
        ctx.strokeStyle = accentColor || '#FBBF24';
        ctx.lineWidth = 2;
        ctx.strokeRect(x, y + 10, 20, 26);
      }
    }
  } else if (style === 'modern_glass' || style === 'motijheel_tower') {
    // Glass curtain grid with illuminated office windows
    const cols = 8;
    const rows = 12;
    const cellW = 256 / cols;
    const cellH = 256 / rows;

    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        const isLit = (r * 7 + c * 11) % 3 === 0;
        ctx.fillStyle = isLit ? 'rgba(254, 240, 138, 0.85)' : 'rgba(30, 41, 59, 0.9)';
        ctx.fillRect(c * cellW + 3, r * cellH + 3, cellW - 6, cellH - 6);
        ctx.strokeStyle = accentColor || 'rgba(56, 189, 248, 0.5)';
        ctx.lineWidth = 1;
        ctx.strokeRect(c * cellW + 3, r * cellH + 3, cellW - 6, cellH - 6);
      }
    }
  } else if (style === 'market_stall') {
    // Corrugated tin siding
    ctx.strokeStyle = 'rgba(0,0,0,0.2)';
    ctx.lineWidth = 2;
    for (let x = 0; x < 256; x += 8) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, 256);
      ctx.stroke();
    }
    // Shop shutter doors
    ctx.fillStyle = '#3F3F46';
    ctx.fillRect(20, 120, 216, 130);
    ctx.strokeStyle = '#D4D4D8';
    ctx.lineWidth = 2;
    for (let y = 120; y < 250; y += 12) {
      ctx.beginPath();
      ctx.moveTo(20, y);
      ctx.lineTo(236, y);
      ctx.stroke();
    }
  } else {
    // Residential concrete & AC unit squares
    for (let y = 20; y < 240; y += 50) {
      for (let x = 20; x < 240; x += 45) {
        ctx.fillStyle = '#0F172A';
        ctx.fillRect(x, y, 24, 30);
        // AC unit box under window
        ctx.fillStyle = '#E2E8F0';
        ctx.fillRect(x + 2, y + 32, 20, 10);
      }
    }
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  return texture;
}

// Create 3D bilingual signboard
function createSignboardMesh(sign: NonNullable<BuildingData['signboard']>, width: number): THREE.Mesh {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 128;
  const ctx = canvas.getContext('2d')!;

  ctx.fillStyle = sign.bgColor;
  ctx.fillRect(0, 0, 512, 128);

  // Border
  ctx.strokeStyle = '#FCD34D';
  ctx.lineWidth = 6;
  ctx.strokeRect(4, 4, 504, 120);

  // Bengali title
  ctx.fillStyle = sign.textColor;
  ctx.font = 'bold 36px "Noto Sans Bengali", sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(sign.textBn, 256, 45);

  // English subtitle
  ctx.font = '600 20px "Chakra Petch", sans-serif';
  ctx.fillText(sign.textEn, 256, 92);

  const tex = new THREE.CanvasTexture(canvas);
  const geo = new THREE.PlaneGeometry(Math.min(width * 0.85, 30), 5);
  const mat = new THREE.MeshBasicMaterial({ map: tex, side: THREE.DoubleSide });
  return new THREE.Mesh(geo, mat);
}


export function buildDhakaWorld(scene: THREE.Scene): WorldBuildResult {
  const worldGroup = new THREE.Group();
  worldGroup.name = 'DhakaWorld';
  scene.add(worldGroup);

  const colliders: THREE.Box3[] = [];
  const roadColliders: { minX: number; maxX: number; minZ: number; maxZ: number; elevation: number }[] = [];
  const launchMeshes: THREE.Group[] = [];

  // =========================================================
  // 1. GROUND PLANE (Land & Riverbed)
  // =========================================================
  const groundGeo = new THREE.PlaneGeometry(WORLD_HALF_SIZE * 2, WORLD_HALF_SIZE * 2, 64, 64);
  const groundMat = new THREE.MeshStandardMaterial({
    color: 0x22262B,
    roughness: 0.95,
    metalness: 0.05,
    flatShading: true
  });
  const ground = new THREE.Mesh(groundGeo, groundMat);
  ground.rotation.x = -Math.PI / 2;
  ground.position.y = -0.05;
  ground.receiveShadow = true;
  worldGroup.add(ground);

  // =========================================================
  // 2. BURIGANGA RIVER & WATER
  // =========================================================
  const riverLengthZ = (WORLD_HALF_SIZE - RIVER_Z_START);
  const riverCenterZ = RIVER_Z_START + riverLengthZ / 2;
  const riverGeo = new THREE.PlaneGeometry(WORLD_HALF_SIZE * 2, riverLengthZ, 32, 16);
  const riverMat = new THREE.MeshStandardMaterial({
    color: 0x092C3E, // Muddy Buriganga deep teal/brown-blue
    roughness: 0.15,
    metalness: 0.75,
    transparent: true,
    opacity: 0.92
  });
  const riverMesh = new THREE.Mesh(riverGeo, riverMat);
  riverMesh.rotation.x = -Math.PI / 2;
  riverMesh.position.set(0, -0.2, riverCenterZ);
  worldGroup.add(riverMesh);

  // River Embankment Stone Wall
  const quayGeo = new THREE.BoxGeometry(WORLD_HALF_SIZE * 2, 3, 4);
  const quayMat = new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.9 });
  const quayWall = new THREE.Mesh(quayGeo, quayMat);
  quayWall.position.set(0, 0.5, RIVER_Z_START);
  worldGroup.add(quayWall);

  // =========================================================
  // 3. ICONIC SADARGHAT PASSENGER LAUNCHES (Steamboats)
  // =========================================================
  const launchPositions = [
    { x: -50, z: 490, name: 'MV MV Parabat 12' },
    { x: 120, z: 520, name: 'MV Sundarban 10' },
    { x: -280, z: 510, name: 'MV Kirtankhola 2' }
  ];

  launchPositions.forEach((pos) => {
    const launchGroup = new THREE.Group();
    launchGroup.position.set(pos.x, 0, pos.z);

    // Hull (bottom boat shape)
    const hullGeo = new THREE.BoxGeometry(70, 6, 20);
    const hullMat = new THREE.MeshStandardMaterial({ color: 0x0284C7, roughness: 0.7 });
    const hull = new THREE.Mesh(hullGeo, hullMat);
    hull.position.y = 1.5;
    hull.castShadow = true;
    launchGroup.add(hull);

    // Lower passenger deck
    const deck1Geo = new THREE.BoxGeometry(64, 4, 18);
    const deck1Mat = new THREE.MeshStandardMaterial({ color: 0xF8FAFC, roughness: 0.4 });
    const deck1 = new THREE.Mesh(deck1Geo, deck1Mat);
    deck1.position.y = 5.5;
    launchGroup.add(deck1);

    // Upper VIP deck & Bridge
    const deck2Geo = new THREE.BoxGeometry(50, 4, 15);
    const deck2Mat = new THREE.MeshStandardMaterial({ color: 0xF8FAFC, roughness: 0.4 });
    const deck2 = new THREE.Mesh(deck2Geo, deck2Mat);
    deck2.position.y = 9.5;
    launchGroup.add(deck2);

    // Chimney smoke stacks
    const funnelGeo = new THREE.CylinderGeometry(1.5, 1.8, 8, 12);
    const funnelMat = new THREE.MeshStandardMaterial({ color: 0xDC2626 });
    const funnel = new THREE.Mesh(funnelGeo, funnelMat);
    funnel.position.set(-6, 14, 0);
    launchGroup.add(funnel);

    // Mast & flags
    const mastGeo = new THREE.CylinderGeometry(0.3, 0.4, 14, 8);
    const mastMat = new THREE.MeshStandardMaterial({ color: 0xFACC15 });
    const mast = new THREE.Mesh(mastGeo, mastMat);
    mast.position.set(22, 16, 0);
    launchGroup.add(mast);

    worldGroup.add(launchGroup);
    launchMeshes.push(launchGroup);

    // Add Launch collider
    const launchBox = new THREE.Box3();
    launchBox.setFromCenterAndSize(new THREE.Vector3(pos.x, 6, pos.z), new THREE.Vector3(72, 14, 22));
    colliders.push(launchBox);
  });

  // =========================================================
  // 4. ROAD NETWORK & ELEVATED FLYOVERS
  // =========================================================
  const roadMat = new THREE.MeshStandardMaterial({
    color: 0x18181B, // Dark worn tarmac
    roughness: 0.9,
    metalness: 0.1
  });

  const curbMat = new THREE.MeshStandardMaterial({
    color: 0x52525B,
    roughness: 0.8
  });

  ROAD_SEGMENTS.forEach((road) => {
    const dx = road.endX - road.startX;
    const dz = road.endZ - road.startZ;
    const length = Math.sqrt(dx * dx + dz * dz);
    const angle = Math.atan2(dz, dx);
    const midX = (road.startX + road.endX) / 2;
    const midZ = (road.startZ + road.endZ) / 2;
    const elevation = road.elevation || 0;

    // Road surface mesh
    const roadMeshGeo = new THREE.PlaneGeometry(length, road.width);
    const roadMesh = new THREE.Mesh(roadMeshGeo, roadMat);
    roadMesh.rotation.x = -Math.PI / 2;
    roadMesh.rotation.z = -angle;
    roadMesh.position.set(midX, elevation + 0.02, midZ);
    roadMesh.receiveShadow = true;
    worldGroup.add(roadMesh);

    // Road Sidewalk / Curbs
    const sidewalkWidth = 2.5;
    [-road.width / 2 - sidewalkWidth / 2, road.width / 2 + sidewalkWidth / 2].forEach((offsetY) => {
      const curbGeo = new THREE.PlaneGeometry(length, sidewalkWidth);
      const curbMesh = new THREE.Mesh(curbGeo, curbMat);
      curbMesh.rotation.x = -Math.PI / 2;
      curbMesh.rotation.z = -angle;
      // Perpendicular displacement
      const perpX = -Math.sin(angle) * offsetY;
      const perpZ = Math.cos(angle) * offsetY;
      curbMesh.position.set(midX + perpX, elevation + 0.08, midZ + perpZ);
      worldGroup.add(curbMesh);
    });

    // Elevated Flyover / Bridge structure (pillars and guardrails)
    if (elevation > 0) {
      // Concrete deck box under the road plane
      const deckGeo = new THREE.BoxGeometry(length, 1.6, road.width + 1);
      const deckMat = new THREE.MeshStandardMaterial({ color: 0x3F3F46, roughness: 0.8 });
      const deck = new THREE.Mesh(deckGeo, deckMat);
      deck.position.set(midX, elevation - 0.8, midZ);
      deck.rotation.y = -angle;
      worldGroup.add(deck);

      // Support pillars every 40m
      const numPillars = Math.max(2, Math.floor(length / 40));
      for (let i = 0; i <= numPillars; i++) {
        const factor = i / numPillars;
        const px = road.startX + dx * factor;
        const pz = road.startZ + dz * factor;

        const pillarGeo = new THREE.CylinderGeometry(1.6, 2.0, elevation, 12);
        const pillarMat = new THREE.MeshStandardMaterial({ color: 0x71717A });
        const pillar = new THREE.Mesh(pillarGeo, pillarMat);
        pillar.position.set(px, elevation / 2, pz);
        pillar.castShadow = true;
        worldGroup.add(pillar);

        // Collider for pillar
        const col = new THREE.Box3();
        col.setFromCenterAndSize(new THREE.Vector3(px, elevation / 2, pz), new THREE.Vector3(4, elevation, 4));
        colliders.push(col);
      }
    }

    // Register road corridor for drivability & navigation
    const minX = Math.min(road.startX, road.endX) - road.width / 2;
    const maxX = Math.max(road.startX, road.endX) + road.width / 2;
    const minZ = Math.min(road.startZ, road.endZ) - road.width / 2;
    const maxZ = Math.max(road.startZ, road.endZ) + road.width / 2;
    roadColliders.push({ minX, maxX, minZ, maxZ, elevation });
  });

  // =========================================================
  // 5. SHAPLA CHATTAR MONUMENT (National Water Lily Fountain)
  // =========================================================
  const shaplaGroup = new THREE.Group();
  shaplaGroup.position.set(0, 0, 0);

  // Roundabout Grass Island
  const islandGeo = new THREE.CylinderGeometry(20, 20, 0.8, 32);
  const islandMat = new THREE.MeshStandardMaterial({ color: 0x15803D, roughness: 0.9 });
  const island = new THREE.Mesh(islandGeo, islandMat);
  island.position.y = 0.4;
  shaplaGroup.add(island);

  // Fountain pool rim
  const poolGeo = new THREE.CylinderGeometry(12, 13, 1.4, 24);
  const poolMat = new THREE.MeshStandardMaterial({ color: 0xE2E8F0, roughness: 0.4 });
  const pool = new THREE.Mesh(poolGeo, poolMat);
  pool.position.y = 1.0;
  shaplaGroup.add(pool);

  // Giant Shapla Petals (Sculpted Water Lily petals)
  const petalMat = new THREE.MeshStandardMaterial({ color: 0xF8FAFC, roughness: 0.3 });
  for (let i = 0; i < 8; i++) {
    const angle = (i / 8) * Math.PI * 2;
    const petalGeo = new THREE.ConeGeometry(2.5, 12, 6);
    const petal = new THREE.Mesh(petalGeo, petalMat);
    petal.position.set(Math.cos(angle) * 4, 7, Math.sin(angle) * 4);
    petal.rotation.z = Math.cos(angle) * 0.4;
    petal.rotation.x = -Math.sin(angle) * 0.4;
    shaplaGroup.add(petal);
  }

  // Central Spire
  const spireGeo = new THREE.CylinderGeometry(0.8, 1.2, 16, 8);
  const spireMat = new THREE.MeshStandardMaterial({ color: 0xFACC15, metalness: 0.6, roughness: 0.3 });
  const spire = new THREE.Mesh(spireGeo, spireMat);
  spire.position.y = 9;
  shaplaGroup.add(spire);

  worldGroup.add(shaplaGroup);

  // Shapla Collider
  const shaplaBox = new THREE.Box3();
  shaplaBox.setFromCenterAndSize(new THREE.Vector3(0, 8, 0), new THREE.Vector3(16, 16, 16));
  colliders.push(shaplaBox);

  // =========================================================
  // 6. BUILDINGS & DHAKA DISTRICT ARCHITECTURE
  // =========================================================
  const buildings = generateWorldBuildings();

  buildings.forEach((bldg) => {
    const bldgGroup = new THREE.Group();
    bldgGroup.position.set(bldg.x, 0, bldg.z);

    // Wall texture & material
    const texture = createBuildingTexture(bldg.style, bldg.wallColor, bldg.accentColor);
    texture.repeat.set(Math.max(1, Math.floor(bldg.width / 16)), Math.max(1, Math.floor(bldg.height / 14)));

    const mat = new THREE.MeshStandardMaterial({
      map: texture,
      roughness: bldg.style === 'modern_glass' ? 0.3 : 0.85,
      metalness: bldg.style === 'modern_glass' ? 0.6 : 0.1
    });

    const geo = new THREE.BoxGeometry(bldg.width, bldg.height, bldg.depth);
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.y = bldg.height / 2;
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    bldgGroup.add(mesh);

    // Roof details: Water tanks, AC units & antennas
    const roofY = bldg.height;
    const tankGeo = new THREE.CylinderGeometry(2, 2, 3.5, 12);
    const tankMat = new THREE.MeshStandardMaterial({ color: 0x1E3A8A }); // Classic blue PVC water tank
    const waterTank = new THREE.Mesh(tankGeo, tankMat);
    waterTank.position.set(bldg.width * 0.25, roofY + 1.75, bldg.depth * 0.2);
    bldgGroup.add(waterTank);

    if (bldg.height > 40) {
      // Skyscraper communication antenna
      const antGeo = new THREE.CylinderGeometry(0.2, 0.4, 14, 6);
      const antMat = new THREE.MeshStandardMaterial({ color: 0xDC2626 });
      const ant = new THREE.Mesh(antGeo, antMat);
      ant.position.set(0, roofY + 7, 0);
      bldgGroup.add(ant);
    }

    // Signboard if present
    if (bldg.signboard) {
      const signMesh = createSignboardMesh(bldg.signboard, bldg.width);
      signMesh.position.set(0, Math.min(bldg.height * 0.3, 12), bldg.depth / 2 + 0.3);
      bldgGroup.add(signMesh);
    }

    worldGroup.add(bldgGroup);

    // Add physical AABB collider
    const bldgBox = new THREE.Box3();
    bldgBox.setFromCenterAndSize(
      new THREE.Vector3(bldg.x, bldg.height / 2, bldg.z),
      new THREE.Vector3(bldg.width, bldg.height, bldg.depth)
    );
    colliders.push(bldgBox);
  });

  // =========================================================
  // 7. POI PHYSICAL FIXTURES (Tea Stalls, Police Station, Garage)
  // =========================================================
  POIS.forEach((poi) => {
    if (poi.type === 'tea_stall') {
      // Street Tong Cha Stall fixture
      const stallGroup = new THREE.Group();
      stallGroup.position.set(poi.x, 0, poi.z);

      // Wooden kiosk counter
      const kioskGeo = new THREE.BoxGeometry(6, 3.5, 4);
      const kioskMat = new THREE.MeshStandardMaterial({ color: 0x78350F });
      const kiosk = new THREE.Mesh(kioskGeo, kioskMat);
      kiosk.position.y = 1.75;
      stallGroup.add(kiosk);

      // Tin corrugated roof
      const roofGeo = new THREE.BoxGeometry(7.5, 0.4, 5.5);
      const roofMat = new THREE.MeshStandardMaterial({ color: 0x94A3B8 });
      const roof = new THREE.Mesh(roofGeo, roofMat);
      roof.position.y = 3.8;
      roof.rotation.x = 0.1;
      stallGroup.add(roof);

      worldGroup.add(stallGroup);

      const col = new THREE.Box3();
      col.setFromCenterAndSize(new THREE.Vector3(poi.x, 2, poi.z), new THREE.Vector3(7, 4, 5));
      colliders.push(col);
    } else if (poi.type === 'garage') {
      // Garage Repair Shed
      const shedGroup = new THREE.Group();
      shedGroup.position.set(poi.x, 0, poi.z);

      const shedGeo = new THREE.BoxGeometry(22, 9, 16);
      const shedMat = new THREE.MeshStandardMaterial({ color: 0x475569 });
      const shed = new THREE.Mesh(shedGeo, shedMat);
      shed.position.y = 4.5;
      shedGroup.add(shed);

      // Neon Tuning Sign
      const signCanvas = document.createElement('canvas');
      signCanvas.width = 256;
      signCanvas.height = 64;
      const sctx = signCanvas.getContext('2d')!;
      sctx.fillStyle = '#0F172A';
      sctx.fillRect(0, 0, 256, 64);
      sctx.fillStyle = '#10B981';
      sctx.font = 'bold 24px sans-serif';
      sctx.fillText('GARAGE • টিউনিং', 20, 40);
      const signTex = new THREE.CanvasTexture(signCanvas);
      const sMesh = new THREE.Mesh(new THREE.PlaneGeometry(12, 3), new THREE.MeshBasicMaterial({ map: signTex }));
      sMesh.position.set(0, 8, 8.2);
      shedGroup.add(sMesh);

      worldGroup.add(shedGroup);

      const col = new THREE.Box3();
      col.setFromCenterAndSize(new THREE.Vector3(poi.x, 4.5, poi.z), new THREE.Vector3(22, 9, 16));
      colliders.push(col);
    }
  });

  // World Boundary Colliders (Keep player inside world borders)
  const borderThickness = 20;
  const borderHeight = 60;
  const northBorder = new THREE.Box3();
  northBorder.setFromCenterAndSize(new THREE.Vector3(0, borderHeight / 2, -WORLD_HALF_SIZE), new THREE.Vector3(WORLD_HALF_SIZE * 2, borderHeight, borderThickness));
  colliders.push(northBorder);

  const southBorder = new THREE.Box3();
  southBorder.setFromCenterAndSize(new THREE.Vector3(0, borderHeight / 2, WORLD_HALF_SIZE), new THREE.Vector3(WORLD_HALF_SIZE * 2, borderHeight, borderThickness));
  colliders.push(southBorder);

  const westBorder = new THREE.Box3();
  westBorder.setFromCenterAndSize(new THREE.Vector3(-WORLD_HALF_SIZE, borderHeight / 2, 0), new THREE.Vector3(borderThickness, borderHeight, WORLD_HALF_SIZE * 2));
  colliders.push(westBorder);

  const eastBorder = new THREE.Box3();
  eastBorder.setFromCenterAndSize(new THREE.Vector3(WORLD_HALF_SIZE, borderHeight / 2, 0), new THREE.Vector3(borderThickness, borderHeight, WORLD_HALF_SIZE * 2));
  colliders.push(eastBorder);

  // Animation / update callback for dynamic river motion and boat bobbing
  const update = (time: number) => {
    // Subtle wave oscillation for passenger launches
    launchMeshes.forEach((launch, idx) => {
      launch.position.y = Math.sin(time * 1.5 + idx * 1.8) * 0.25;
      launch.rotation.z = Math.sin(time * 1.2 + idx * 2.1) * 0.02;
    });
  };

  return {
    group: worldGroup,
    colliders,
    roadColliders,
    riverMesh,
    launchMeshes,
    update
  };
}
