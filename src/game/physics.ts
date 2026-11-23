/**
 * DTA: Dhaka Theft Auto - Movement, Vehicle & Collision Physics
 */

import * as THREE from 'three';
import { WORLD_HALF_SIZE, RIVER_Z_START } from './worldData';

export type VehicleType = 'cng' | 'car' | 'sports' | 'rickshaw';

export interface VehicleConfig {
  maxSpeed: number;
  accel: number;
  brakeDecel: number;
  reverseSpeed: number;
  turnSpeed: number;
  width: number;
  length: number;
  height: number;
}

export const VEHICLE_CONFIGS: Record<VehicleType, VehicleConfig> = {
  cng: {
    maxSpeed: 38,
    accel: 28,
    brakeDecel: 36,
    reverseSpeed: 15,
    turnSpeed: 2.8,
    width: 2.2,
    length: 3.4,
    height: 2.2
  },
  car: {
    maxSpeed: 52,
    accel: 32,
    brakeDecel: 42,
    reverseSpeed: 20,
    turnSpeed: 2.2,
    width: 2.4,
    length: 4.8,
    height: 1.8
  },
  sports: {
    maxSpeed: 75,
    accel: 50,
    brakeDecel: 60,
    reverseSpeed: 25,
    turnSpeed: 2.5,
    width: 2.5,
    length: 4.6,
    height: 1.5
  },
  rickshaw: {
    maxSpeed: 20,
    accel: 15,
    brakeDecel: 25,
    reverseSpeed: 8,
    turnSpeed: 3.2,
    width: 1.8,
    length: 2.6,
    height: 2.0
  }
};

export interface PlayerPhysicsState {
  position: THREE.Vector3;
  velocity: THREE.Vector3;
  rotationY: number;
  isGrounded: boolean;
  isInVehicle: boolean;
  currentVehicleId: string | null;
  speed: number;
}

export interface VehicleInstance {
  id: string;
  type: VehicleType;
  mesh: THREE.Group;
  position: THREE.Vector3;
  rotationY: number;
  speed: number;
  steerAngle: number;
  elevation: number;
  health: number;
}

export class PhysicsEngine {
  private colliders: THREE.Box3[] = [];
  private roadColliders: { minX: number; maxX: number; minZ: number; maxZ: number; elevation: number }[] = [];

  constructor(
    colliders: THREE.Box3[],
    roadColliders: { minX: number; maxX: number; minZ: number; maxZ: number; elevation: number }[]
  ) {
    this.colliders = colliders;
    this.roadColliders = roadColliders;
  }

  public setColliders(
    colliders: THREE.Box3[],
    roadColliders: { minX: number; maxX: number; minZ: number; maxZ: number; elevation: number }[]
  ) {
    this.colliders = colliders;
    this.roadColliders = roadColliders;
  }

  // Get ground elevation at (x, z) accounting for flyovers and bridges
  public getElevationAt(x: number, z: number): number {
    for (const road of this.roadColliders) {
      if (road.elevation > 0) {
        if (x >= road.minX && x <= road.maxX && z >= road.minZ && z <= road.maxZ) {
          return road.elevation;
        }
      }
    }
    return 0; // Default ground plane
  }

  // Check if position is currently over the Buriganga river without a bridge
  public isOverRiver(x: number, z: number, y: number): boolean {
    if (z >= RIVER_Z_START) {
      // If on babubazar bridge (elevation >= 7), not in river
      const elevation = this.getElevationAt(x, z);
      if (elevation >= 6 && y >= 6) {
        return false;
      }
      return true;
    }
    return false;
  }

  // AABB Check against all world colliders
  public checkCollision(box: THREE.Box3): boolean {
    for (let i = 0; i < this.colliders.length; i++) {
      if (box.intersectsBox(this.colliders[i])) {
        return true;
      }
    }
    return false;
  }

  // Foot movement update with sliding collision resolution
  public updatePlayerMovement(
    state: PlayerPhysicsState,
    input: { forward: number; strafe: number; sprint: boolean; jump: boolean },
    cameraYaw: number,
    delta: number
  ) {
    if (state.isInVehicle) return;

    const baseSpeed = input.sprint ? 11.5 : 5.8;
    const targetElevation = this.getElevationAt(state.position.x, state.position.z);

    // Calculate move vector relative to camera yaw
    const forwardX = -Math.sin(cameraYaw);
    const forwardZ = -Math.cos(cameraYaw);
    const rightX = -Math.cos(cameraYaw);
    const rightZ = Math.sin(cameraYaw);

    const moveX = forwardX * input.forward + rightX * input.strafe;
    const moveZ = forwardZ * input.forward + rightZ * input.strafe;
    const moveLen = Math.sqrt(moveX * moveX + moveZ * moveZ);

    if (moveLen > 0.001) {
      const normX = moveX / moveLen;
      const normZ = moveZ / moveLen;
      const targetSpeed = baseSpeed;
      state.speed = THREE.MathUtils.lerp(state.speed, targetSpeed, delta * 10);

      // Facing direction
      state.rotationY = Math.atan2(normX, normZ);

      // Try X movement with collision check
      const deltaX = normX * state.speed * delta;
      const nextX = state.position.x + deltaX;
      const playerBoxX = new THREE.Box3();
      playerBoxX.setFromCenterAndSize(
        new THREE.Vector3(nextX, state.position.y + 1.0, state.position.z),
        new THREE.Vector3(0.9, 1.9, 0.9)
      );

      // Clamp within world bounds & river safety
      const safeRiverX = !this.isOverRiver(nextX, state.position.z, state.position.y);
      if (!this.checkCollision(playerBoxX) && Math.abs(nextX) < WORLD_HALF_SIZE - 2 && safeRiverX) {
        state.position.x = nextX;
      }

      // Try Z movement with collision check
      const deltaZ = normZ * state.speed * delta;
      const nextZ = state.position.z + deltaZ;
      const playerBoxZ = new THREE.Box3();
      playerBoxZ.setFromCenterAndSize(
        new THREE.Vector3(state.position.x, state.position.y + 1.0, nextZ),
        new THREE.Vector3(0.9, 1.9, 0.9)
      );

      const safeRiverZ = !this.isOverRiver(state.position.x, nextZ, state.position.y);
      if (!this.checkCollision(playerBoxZ) && Math.abs(nextZ) < WORLD_HALF_SIZE - 2 && safeRiverZ) {
        state.position.z = nextZ;
      }
    } else {
      state.speed = THREE.MathUtils.lerp(state.speed, 0, delta * 12);
    }

    // Ground elevation snapping / smoothing
    state.position.y = THREE.MathUtils.lerp(state.position.y, targetElevation, delta * 12);
  }

  // Vehicle driving physics update
  public updateVehicle(
    vehicle: VehicleInstance,
    input: { throttle: number; steer: number; handbrake: boolean },
    delta: number
  ) {
    const config = VEHICLE_CONFIGS[vehicle.type];

    // Acceleration & Braking
    if (input.throttle > 0) {
      if (vehicle.speed < 0) {
        // Braking while going backward
        vehicle.speed += config.brakeDecel * delta;
      } else {
        vehicle.speed = Math.min(config.maxSpeed, vehicle.speed + config.accel * delta * input.throttle);
      }
    } else if (input.throttle < 0) {
      if (vehicle.speed > 0) {
        // Braking while going forward
        vehicle.speed -= config.brakeDecel * delta;
      } else {
        // Reverse
        vehicle.speed = Math.max(-config.reverseSpeed, vehicle.speed - config.accel * 0.7 * delta);
      }
    } else {
      // Natural rolling friction
      if (vehicle.speed > 0) {
        vehicle.speed = Math.max(0, vehicle.speed - 12 * delta);
      } else if (vehicle.speed < 0) {
        vehicle.speed = Math.min(0, vehicle.speed + 12 * delta);
      }
    }

    if (input.handbrake) {
      if (vehicle.speed > 0) {
        vehicle.speed = Math.max(0, vehicle.speed - config.brakeDecel * 1.8 * delta);
      } else if (vehicle.speed < 0) {
        vehicle.speed = Math.min(0, vehicle.speed + config.brakeDecel * 1.8 * delta);
      }
    }

    // Steering proportional to speed
    if (Math.abs(vehicle.speed) > 0.5) {
      const speedFactor = Math.min(1.0, Math.abs(vehicle.speed) / 10);
      const direction = vehicle.speed >= 0 ? 1 : -1;
      vehicle.rotationY += input.steer * config.turnSpeed * direction * speedFactor * delta;
    }

    // Compute velocity
    const headingX = Math.sin(vehicle.rotationY);
    const headingZ = Math.cos(vehicle.rotationY);
    const deltaX = headingX * vehicle.speed * delta;
    const deltaZ = headingZ * vehicle.speed * delta;

    const nextX = vehicle.position.x + deltaX;
    const nextZ = vehicle.position.z + deltaZ;

    // Elevation handling for ramps & bridges
    const targetElevation = this.getElevationAt(nextX, nextZ);
    vehicle.elevation = THREE.MathUtils.lerp(vehicle.elevation, targetElevation, delta * 8);

    // Collision check
    const vehicleBox = new THREE.Box3();
    vehicleBox.setFromCenterAndSize(
      new THREE.Vector3(nextX, vehicle.elevation + config.height / 2, nextZ),
      new THREE.Vector3(config.width, config.height, config.length)
    );

    const safeRiver = !this.isOverRiver(nextX, nextZ, vehicle.elevation);
    const withinBounds = Math.abs(nextX) < WORLD_HALF_SIZE - 4 && Math.abs(nextZ) < WORLD_HALF_SIZE - 4;

    if (!this.checkCollision(vehicleBox) && withinBounds && safeRiver) {
      vehicle.position.x = nextX;
      vehicle.position.z = nextZ;
      vehicle.position.y = vehicle.elevation;
    } else {
      // Collision impact: rebound speed
      vehicle.speed = -vehicle.speed * 0.35;
      vehicle.health = Math.max(0, vehicle.health - 2);
    }

    // Update 3D mesh
    vehicle.mesh.position.copy(vehicle.position);
    vehicle.mesh.rotation.y = vehicle.rotationY;

    // Subtle chassis roll during sharp turns
    const rollAngle = -input.steer * (vehicle.speed / config.maxSpeed) * 0.08;
    vehicle.mesh.rotation.z = THREE.MathUtils.lerp(vehicle.mesh.rotation.z, rollAngle, delta * 10);
  }
}
