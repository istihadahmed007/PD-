/**
 * DTA: Dhaka Theft Auto - World Data Specification
 * 2.5x Expanded Open World Dhaka Geometry & Systems
 */

export const WORLD_HALF_SIZE = 750; // Total world is 1500m x 1500m (2.5x expansion from 300m)
export const RIVER_Z_START = 420;   // Buriganga River starts at Z=420 extending to south boundary (Z=750)

export interface District {
  id: string;
  nameEn: string;
  nameBn: string;
  description: string;
  bounds: { minX: number; maxX: number; minZ: number; maxZ: number };
  theme: 'heritage' | 'commercial' | 'financial' | 'modern' | 'riverfront' | 'residential' | 'market';
  primaryColor: string;
}

export interface RoadSegment {
  id: string;
  name: string;
  type: 'arterial' | 'secondary' | 'alley' | 'flyover' | 'bridge';
  startX: number;
  startZ: number;
  endX: number;
  endZ: number;
  width: number;
  elevation?: number; // For flyovers & bridges
  lanes: number;
  speedLimit: number;
}

export interface BuildingData {
  id: string;
  districtId: string;
  x: number;
  z: number;
  width: number;
  depth: number;
  height: number;
  rotation?: number;
  style: 'old_dhaka_brick' | 'modern_glass' | 'motijheel_tower' | 'market_stall' | 'residential_tin' | 'embassy' | 'warehouse';
  wallColor: string;
  accentColor?: string;
  signboard?: {
    textBn: string;
    textEn: string;
    bgColor: string;
    textColor: string;
  };
}

export interface POI {
  id: string;
  districtId: string;
  nameEn: string;
  nameBn: string;
  type: 'monument' | 'garage' | 'tea_stall' | 'police_thana' | 'launch_terminal' | 'market' | 'bank' | 'safehouse';
  x: number;
  z: number;
  radius: number;
  description: string;
  interactAction?: string;
}

export interface TrafficWaypoint {
  x: number;
  y: number;
  z: number;
}

export interface TrafficRoute {
  id: string;
  name: string;
  type: 'arterial' | 'ring' | 'flyover' | 'local';
  loop: boolean;
  waypoints: TrafficWaypoint[];
  vehicleTypes: ('cng' | 'car' | 'rickshaw' | 'bus')[];
}

export interface Mission {
  id: string;
  titleEn: string;
  titleBn: string;
  description: string;
  giver: string;
  rewardBdt: number;
  repPoints: number;
  pickupPOIId: string;
  dropoffPOIId: string;
  timeLimitSec?: number;
  difficulty: 'Easy' | 'Medium' | 'Hard';
}

export interface FareDestination {
  id: string;
  nameEn: string;
  nameBn: string;
  districtId: string;
  x: number;
  z: number;
  tipMultiplier: number;
}

// -------------------------------------------------------------
// DISTRICTS DEFINITIONS (English + Bangla)
// -------------------------------------------------------------
export const DISTRICTS: District[] = [
  {
    id: 'old_dhaka',
    nameEn: 'Old Dhaka (Chawkbazar)',
    nameBn: 'পুরান ঢাকা (চকবাজার)',
    description: 'Historic dense lanes, traditional Mughal spice markets, ancient red-brick townhouses, and royal Biryani houses.',
    bounds: { minX: -550, maxX: -100, minZ: 100, maxZ: 420 },
    theme: 'heritage',
    primaryColor: '#B45309'
  },
  {
    id: 'shapla_square',
    nameEn: 'Shapla Crossing',
    nameBn: 'শাপলা চত্বর',
    description: 'Iconic roundabout centered around the giant water-lily monument, connecting commercial arteries.',
    bounds: { minX: -100, maxX: 150, minZ: -100, maxZ: 150 },
    theme: 'commercial',
    primaryColor: '#059669'
  },
  {
    id: 'motijheel',
    nameEn: 'Motijheel Financial District',
    nameBn: 'মতিঝিল বাণিজ্যিক এলাকা',
    description: 'The economic nerve center of Bangladesh: skyscraper banking headquarters, finance towers, and corporate avenues.',
    bounds: { minX: 150, maxX: 600, minZ: -150, maxZ: 250 },
    theme: 'financial',
    primaryColor: '#2563EB'
  },
  {
    id: 'kawran_bazar',
    nameEn: 'Kawran Bazar & Flyover',
    nameBn: 'কাওরান বাজার ও ফ্লাইওভার',
    description: 'The mega wholesale commodity market crowned by an elevated expressway flyover filled with bustling cargo traffic.',
    bounds: { minX: -250, maxX: 150, minZ: -450, maxZ: -100 },
    theme: 'market',
    primaryColor: '#D97706'
  },
  {
    id: 'gulshan',
    nameEn: 'Gulshan & Banani Diplomatic Enclave',
    nameBn: 'গুলশান ও বনানী কূটনৈতিক এলাকা',
    description: 'Upscale modern zone with glittering glass facades, rooftop restaurants, luxury vehicle showrooms, and wide avenues.',
    bounds: { minX: -100, maxX: 600, minZ: -750, maxZ: -350 },
    theme: 'modern',
    primaryColor: '#7C3AED'
  },
  {
    id: 'dhanmondi',
    nameEn: 'Dhanmondi Residential Zone',
    nameBn: 'ধানমন্ডি আবাসিক এলাকা',
    description: 'Lush residential neighborhoods, vibrant lakeside tea stalls, educational schools, and lively alleyways.',
    bounds: { minX: -650, maxX: -250, minZ: -450, maxZ: 100 },
    theme: 'residential',
    primaryColor: '#0D9488'
  },
  {
    id: 'sadarghat',
    nameEn: 'Sadarghat & Buriganga Riverfront',
    nameBn: 'সদরঘাট ও বুড়িগঙ্গা রিভারফ্রন্ট',
    description: 'The legendary river port filled with passenger launches, country boats, timber docks, cargo cranes, and waterside trade.',
    bounds: { minX: -650, maxX: 600, minZ: 420, maxZ: 750 },
    theme: 'riverfront',
    primaryColor: '#0284C7'
  }
];

// -------------------------------------------------------------
// CONNECTED ROAD HIERARCHY
// -------------------------------------------------------------
export const ROAD_SEGMENTS: RoadSegment[] = [
  // 1. Central VIP Avenue (Gulshan -> Kawran Bazar -> Shapla Square)
  {
    id: 'vip_avenue_north',
    name: 'VIP Boulevard North (Gulshan - Kawran)',
    type: 'arterial',
    startX: 0,
    startZ: -720,
    endX: 0,
    endZ: -250,
    width: 22,
    lanes: 4,
    speedLimit: 60
  },
  {
    id: 'vip_avenue_central',
    name: 'VIP Boulevard Central (Kawran - Shapla)',
    type: 'arterial',
    startX: 0,
    startZ: -250,
    endX: 0,
    endZ: 0,
    width: 24,
    lanes: 4,
    speedLimit: 55
  },
  {
    id: 'vip_avenue_south',
    name: 'Bangabandhu Avenue (Shapla - Sadarghat Link)',
    type: 'arterial',
    startX: 0,
    startZ: 0,
    endX: 0,
    endZ: 420,
    width: 22,
    lanes: 4,
    speedLimit: 50
  },

  // 2. East-West Motijheel Financial Expressway
  {
    id: 'motijheel_expressway_west',
    name: 'Motijheel Central Ave (Shapla to Central Motijheel)',
    type: 'arterial',
    startX: 0,
    startZ: 0,
    endX: 350,
    endZ: 0,
    width: 20,
    lanes: 4,
    speedLimit: 50
  },
  {
    id: 'motijheel_expressway_east',
    name: 'Dilkusha Commercial Outer Way',
    type: 'arterial',
    startX: 350,
    startZ: 0,
    endX: 620,
    endZ: 0,
    width: 18,
    lanes: 4,
    speedLimit: 50
  },

  // 3. East Arterial (Gulshan to Motijheel connector)
  {
    id: 'progoti_sarani',
    name: 'Pragoti Sarani Eastern Trunk',
    type: 'arterial',
    startX: 350,
    startZ: -700,
    endX: 350,
    endZ: 350,
    width: 20,
    lanes: 4,
    speedLimit: 55
  },

  // 4. West Arterial (Mirpur Road through Dhanmondi to Old Dhaka)
  {
    id: 'mirpur_road_north',
    name: 'Mirpur Trunk Road',
    type: 'arterial',
    startX: -400,
    startZ: -700,
    endX: -400,
    endZ: -100,
    width: 20,
    lanes: 4,
    speedLimit: 55
  },
  {
    id: 'mirpur_road_south',
    name: 'Dhanmondi-Old Dhaka Link',
    type: 'arterial',
    startX: -400,
    startZ: -100,
    endX: -400,
    endZ: 420,
    width: 18,
    lanes: 4,
    speedLimit: 45
  },

  // 5. Kawran Bazar Ring & Cross Roads
  {
    id: 'kawran_cross_road',
    name: 'Kazi Nazrul Islam Crossway',
    type: 'secondary',
    startX: -400,
    startZ: -250,
    endX: 350,
    endZ: -250,
    width: 16,
    lanes: 2,
    speedLimit: 40
  },

  // 6. Elevated Flyover (Kawran Bazar to Moghbazar interchange)
  {
    id: 'moghbazar_flyover_deck',
    name: 'Moghbazar-Kawran Elevated Flyover',
    type: 'flyover',
    startX: -150,
    startZ: -380,
    endX: 180,
    endZ: -150,
    width: 14,
    elevation: 10,
    lanes: 2,
    speedLimit: 70
  },

  // 7. Old Dhaka Narrow Street Network
  {
    id: 'chawkbazar_spine',
    name: 'Chawkbazar Royal Historic Lane',
    type: 'secondary',
    startX: -400,
    startZ: 220,
    endX: 0,
    endZ: 220,
    width: 14,
    lanes: 2,
    speedLimit: 30
  },
  {
    id: 'shakhari_bazar_alley',
    name: 'Shakhari Bazar Heritage Alley',
    type: 'alley',
    startX: -250,
    startZ: 100,
    endX: -250,
    endZ: 380,
    width: 9,
    lanes: 1,
    speedLimit: 25
  },
  {
    id: 'lalbagh_approach',
    name: 'Lalbagh Fort Approach Road',
    type: 'secondary',
    startX: -550,
    startZ: 300,
    endX: -400,
    endZ: 300,
    width: 13,
    lanes: 2,
    speedLimit: 35
  },

  // 8. Riverfront Promenade & Sadarghat Terminal Road
  {
    id: 'buriganga_promenade',
    name: 'Buriganga Riverfront Embankment Road',
    type: 'arterial',
    startX: -600,
    startZ: 420,
    endX: 600,
    endZ: 420,
    width: 20,
    lanes: 4,
    speedLimit: 45
  },

  // 9. Sadarghat Babubazar Bridge crossing Buriganga
  {
    id: 'babubazar_bridge',
    name: 'Babubazar Buriganga Bridge',
    type: 'bridge',
    startX: -120,
    startZ: 420,
    endX: -120,
    endZ: 700,
    width: 16,
    elevation: 8,
    lanes: 2,
    speedLimit: 60
  },

  // 10. Gulshan Diplomatic Avenues
  {
    id: 'gulshan_avenue_1',
    name: 'Gulshan North Avenue 1',
    type: 'secondary',
    startX: -100,
    startZ: -550,
    endX: 550,
    endZ: -550,
    width: 18,
    lanes: 4,
    speedLimit: 50
  },
  {
    id: 'banani_road_11',
    name: 'Banani Road 11 Boutique Strip',
    type: 'secondary',
    startX: 180,
    startZ: -720,
    endX: 180,
    endZ: -400,
    width: 16,
    lanes: 2,
    speedLimit: 40
  }
];

// -------------------------------------------------------------
// POINTS OF INTEREST (POIs)
// -------------------------------------------------------------
export const POIS: POI[] = [
  {
    id: 'shapla_monument',
    districtId: 'shapla_square',
    nameEn: 'Shapla Chattar Monument',
    nameBn: 'শাপলা চত্বর ভাস্কর্য',
    type: 'monument',
    x: 0,
    z: 0,
    radius: 18,
    description: 'The monumental national water lily fountain marking Dhaka core intersection.',
    interactAction: 'Admire Landmark'
  },
  {
    id: 'dmp_thana',
    districtId: 'old_dhaka',
    nameEn: 'DMP Police Headquarters',
    nameBn: 'ডিএমপি কোতোয়ালী থানা',
    type: 'police_thana',
    x: -180,
    z: 90,
    radius: 20,
    description: 'Kotwali Police Station with patrol cruisers parked out front.',
    interactAction: 'Pay Bribe / Clear Heat'
  },
  {
    id: 'old_dhaka_biryani',
    districtId: 'old_dhaka',
    nameEn: 'Haji Biryani Royal Kitchen',
    nameBn: 'হাজী বিরিয়ানি (চকবাজার)',
    type: 'tea_stall',
    x: -250,
    z: 220,
    radius: 15,
    description: 'Legendary fragrant mutton biryani pot simmering since 1939.',
    interactAction: 'Eat & Restore Health'
  },
  {
    id: 'karwan_garage',
    districtId: 'kawran_bazar',
    nameEn: 'Ustad Karim Auto Tuning & Garage',
    nameBn: 'ওস্তাদ করিম মেকানিক গ্যারেজ',
    type: 'garage',
    x: -80,
    z: -280,
    radius: 22,
    description: 'Premier tuning garage specializing in turbo CNG engines and custom spray paint.',
    interactAction: 'Repair & Tune Vehicle'
  },
  {
    id: 'sadarghat_terminal',
    districtId: 'sadarghat',
    nameEn: 'Sadarghat Launch Terminal #4',
    nameBn: 'সদরঘাট লঞ্চ টার্মিনাল ৪ নং ঘাট',
    type: 'launch_terminal',
    x: 40,
    z: 440,
    radius: 30,
    description: 'Giant multi-deck triple propeller river passenger steamers departing for Barisal and Bhola.',
    interactAction: 'Board Riverboat'
  },
  {
    id: 'cha_stall_motijheel',
    districtId: 'motijheel',
    nameEn: 'Mama Special Tong Cha Stall',
    nameBn: 'মামার স্পেশাল টংয়ের চা',
    type: 'tea_stall',
    x: 220,
    z: -30,
    radius: 12,
    description: 'Steaming ginger milk tea, condensed milk tins, and street banter.',
    interactAction: 'Have Malai Cha'
  },
  {
    id: 'gulshan_club_safehouse',
    districtId: 'gulshan',
    nameEn: 'Gulshan Penthouse Safehouse',
    nameBn: 'গুলশান পেন্টহাউস সেফহাউস',
    type: 'safehouse',
    x: 320,
    z: -560,
    radius: 25,
    description: 'High-security penthouse suite with underground parking.',
    interactAction: 'Save Game & Rest'
  },
  {
    id: 'bangladesh_bank_hq',
    districtId: 'motijheel',
    nameEn: 'Bangladesh Bank Vault Tower',
    nameBn: 'বাংলাদেশ ব্যাংক কেন্দ্রীয় ভবন',
    type: 'bank',
    x: 420,
    z: 60,
    radius: 35,
    description: 'Fortified central reserve bank tower guarded by armored vehicles.',
    interactAction: 'Check Vault'
  }
];

// -------------------------------------------------------------
// DTA MISSIONS
// -------------------------------------------------------------
export const MISSIONS: Mission[] = [
  {
    id: 'm1_biryani_run',
    titleEn: 'Operation: Chawkbazar Feast',
    titleBn: 'মিশন ১: চকবাজার বিরিয়ানি ডেলিভারি',
    description: 'Ustad Karim urgently needs 5 giant degs of authentic royal kacchi delivered from Chawkbazar to Gulshan VIP Lounge before the banquet ends. Avoid police checkpoints!',
    giver: 'Ustad Karim (Garage Master)',
    rewardBdt: 8500,
    repPoints: 50,
    pickupPOIId: 'old_dhaka_biryani',
    dropoffPOIId: 'gulshan_club_safehouse',
    timeLimitSec: 130,
    difficulty: 'Easy'
  },
  {
    id: 'm2_launch_contraband',
    titleEn: 'Buriganga River Express',
    titleBn: 'মিশন ২: সদরঘাট মালামাল চালান',
    description: 'A launch from Chandpur just berthed at Sadarghat Terminal with precious imported electronics. Retrieve the crate and sprint to Motijheel Bank Vault without totaling your ride.',
    giver: 'Launch Master Selim',
    rewardBdt: 18000,
    repPoints: 120,
    pickupPOIId: 'sadarghat_terminal',
    dropoffPOIId: 'bangladesh_bank_hq',
    timeLimitSec: 160,
    difficulty: 'Medium'
  },
  {
    id: 'm3_flyover_escape',
    titleEn: 'Kawran Bazar Heat Evasion',
    titleBn: 'মিশন ৩: কাওরান বাজার ফ্লাইওভার পলায়ন',
    description: 'Kotwali Police have spotted your tuned green CNG. Race onto the Kawran Bazar elevated flyover at full throttle to lose the wanted stars and ditch the tail at Karim Auto Garage!',
    giver: 'Anonymous Informant',
    rewardBdt: 32000,
    repPoints: 250,
    pickupPOIId: 'dmp_thana',
    dropoffPOIId: 'karwan_garage',
    timeLimitSec: 90,
    difficulty: 'Hard'
  }
];

// -------------------------------------------------------------
// TAXI / CNG FARE DESTINATIONS
// -------------------------------------------------------------
export const FARE_DESTINATIONS: FareDestination[] = [
  { id: 'f_chawk', nameEn: 'Chawkbazar Spice Market', nameBn: 'চকবাজার মোড়', districtId: 'old_dhaka', x: -250, z: 220, tipMultiplier: 1.2 },
  { id: 'f_shapla', nameEn: 'Shapla Chattar North Gate', nameBn: 'শাপলা চত্বর উত্তর', districtId: 'shapla_square', x: 20, z: -30, tipMultiplier: 1.0 },
  { id: 'f_gulshan', nameEn: 'Gulshan 2 Circle Avenue', nameBn: 'গুলশান ২ নম্বর গোলচত্বর', districtId: 'gulshan', x: 300, z: -550, tipMultiplier: 2.0 },
  { id: 'f_sadar', nameEn: 'Sadarghat Passenger Steamer Ghat', nameBn: 'সদরঘাট লঞ্চ ঘাট', districtId: 'sadarghat', x: 60, z: 450, tipMultiplier: 1.4 },
  { id: 'f_motijheel', nameEn: 'Motijheel Commercial Arcade', nameBn: 'মতিঝিল ব্যাংক পাড়া', districtId: 'motijheel', x: 380, z: 30, tipMultiplier: 1.5 },
  { id: 'f_kawran', nameEn: 'Kawran Wholesale Produce Depot', nameBn: 'কাওরান বাজার কাঁচামাল আড়ৎ', districtId: 'kawran_bazar', x: -120, z: -250, tipMultiplier: 1.1 }
];

// -------------------------------------------------------------
// AI TRAFFIC ROUTES (Loops & Waypoint Networks)
// -------------------------------------------------------------
export const TRAFFIC_ROUTES: TrafficRoute[] = [
  // 1. VIP Arterial Loop
  {
    id: 'route_vip_arterial',
    name: 'VIP Main Central Spine',
    type: 'arterial',
    loop: true,
    vehicleTypes: ['cng', 'car', 'bus'],
    waypoints: [
      { x: 5, y: 0, z: -680 },
      { x: 5, y: 0, z: -300 },
      { x: 5, y: 0, z: 0 },
      { x: 5, y: 0, z: 380 },
      { x: -5, y: 0, z: 380 },
      { x: -5, y: 0, z: 0 },
      { x: -5, y: 0, z: -300 },
      { x: -5, y: 0, z: -680 }
    ]
  },
  // 2. Motijheel Business Loop
  {
    id: 'route_motijheel',
    name: 'Motijheel Skyscraper Ring',
    type: 'ring',
    loop: true,
    vehicleTypes: ['car', 'cng'],
    waypoints: [
      { x: 20, y: 0, z: -5 },
      { x: 340, y: 0, z: -5 },
      { x: 580, y: 0, z: -5 },
      { x: 580, y: 0, z: 200 },
      { x: 350, y: 0, z: 200 },
      { x: 20, y: 0, z: 120 }
    ]
  },
  // 3. Old Dhaka Heritage Route (CNGs and Rickshaws dominate)
  {
    id: 'route_old_dhaka',
    name: 'Chawkbazar Traditional Circuit',
    type: 'local',
    loop: true,
    vehicleTypes: ['cng', 'rickshaw'],
    waypoints: [
      { x: -10, y: 0, z: 220 },
      { x: -245, y: 0, z: 220 },
      { x: -390, y: 0, z: 220 },
      { x: -390, y: 0, z: 390 },
      { x: -15, y: 0, z: 390 }
    ]
  },
  // 4. Kawran Bazar Elevated Flyover Fast Transit
  {
    id: 'route_flyover',
    name: 'Elevated Flyover Express',
    type: 'flyover',
    loop: false,
    vehicleTypes: ['car', 'cng'],
    waypoints: [
      { x: -140, y: 10, z: -370 },
      { x: -30, y: 10, z: -270 },
      { x: 80, y: 10, z: -200 },
      { x: 170, y: 10, z: -160 }
    ]
  },
  // 5. Buriganga Riverfront Parkway
  {
    id: 'route_riverfront',
    name: 'Buriganga Embankment Route',
    type: 'arterial',
    loop: true,
    vehicleTypes: ['bus', 'cng', 'car'],
    waypoints: [
      { x: -550, y: 0, z: 415 },
      { x: -100, y: 0, z: 415 },
      { x: 100, y: 0, z: 415 },
      { x: 550, y: 0, z: 415 },
      { x: 550, y: 0, z: 425 },
      { x: 100, y: 0, z: 425 },
      { x: -550, y: 0, z: 425 }
    ]
  }
];

// -------------------------------------------------------------
// DIVERSE CITY BUILDINGS GENERATOR
// Produces 200+ distinct buildings organized by Dhaka district
// -------------------------------------------------------------
export function generateWorldBuildings(): BuildingData[] {
  const buildings: BuildingData[] = [];

  // 1. MOTIJHEEL FINANCIAL DISTRICT (Highrises & Skyscrapers, 35m to 120m tall)
  const motijheelColors = ['#1E293B', '#334155', '#475569', '#0F172A', '#1E3A8A', '#0369A1', '#374151'];
  for (let x = 120; x <= 560; x += 75) {
    for (let z = -140; z <= 220; z += 65) {
      // Don't collide with main road at Z=0 or X=350
      if (Math.abs(z) < 18 || Math.abs(x - 350) < 18) continue;

      const height = 45 + Math.floor(((x * 7 + z * 13) % 75));
      const width = 38 + ((x + z) % 15);
      const depth = 35 + ((x * z) % 15);
      const color = motijheelColors[(Math.abs(x + z)) % motijheelColors.length];

      buildings.push({
        id: `bldg_motijheel_${x}_${z}`,
        districtId: 'motijheel',
        x,
        z,
        width,
        depth,
        height,
        style: 'motijheel_tower',
        wallColor: color,
        accentColor: '#38BDF8',
        signboard: (x % 150 === 0) ? {
          textBn: 'বাংলাদেশ সোনালী ব্যাংক টাওয়ার',
          textEn: 'Sonali Bank Corporate Tower',
          bgColor: '#0284C7',
          textColor: '#FFFFFF'
        } : undefined
      });
    }
  }

  // 2. OLD DHAKA / CHAWKBAZAR (Dense red-brick, narrow heritage, 10m to 28m)
  const oldDhakaColors = ['#991B1B', '#7F1D1D', '#B45309', '#92400E', '#78350F', '#854D0E', '#A16207'];
  for (let x = -520; x <= -60; x += 45) {
    for (let z = 120; z <= 400; z += 40) {
      if (Math.abs(z - 220) < 14 || Math.abs(x + 400) < 14 || Math.abs(x + 250) < 10) continue;

      const height = 12 + Math.floor(((x * 3 + z * 5) % 18));
      const width = 24 + ((x + z) % 10);
      const depth = 22 + ((x * z) % 8);
      const color = oldDhakaColors[(Math.abs(x + z)) % oldDhakaColors.length];

      buildings.push({
        id: `bldg_old_dhaka_${x}_${z}`,
        districtId: 'old_dhaka',
        x,
        z,
        width,
        depth,
        height,
        style: 'old_dhaka_brick',
        wallColor: color,
        accentColor: '#FBBF24',
        signboard: (z % 80 === 0) ? {
          textBn: 'হাজী বিরিয়ানি ও বাকরখানি ভান্ডার',
          textEn: 'Royal Bakarkhani & Sweetmeat Depot',
          bgColor: '#991B1B',
          textColor: '#FDE047'
        } : undefined
      });
    }
  }

  // 3. GULSHAN & BANANI DIPLOMATIC (Modern glass, luxury malls, 25m to 65m)
  const gulshanColors = ['#F8FAFC', '#E2E8F0', '#CBD5E1', '#0284C7', '#0EA5E9', '#6366F1', '#4F46E5'];
  for (let x = -70; x <= 560; x += 65) {
    for (let z = -720; z <= -360; z += 65) {
      if (Math.abs(x) < 18 || Math.abs(x - 180) < 14 || Math.abs(x - 350) < 18 || Math.abs(z + 550) < 16) continue;

      const height = 30 + Math.floor(((x * 9 + z * 7) % 45));
      const width = 36 + ((x + z) % 14);
      const depth = 34 + ((x * z) % 12);
      const color = gulshanColors[(Math.abs(x + z)) % gulshanColors.length];

      buildings.push({
        id: `bldg_gulshan_${x}_${z}`,
        districtId: 'gulshan',
        x,
        z,
        width,
        depth,
        height,
        style: 'modern_glass',
        wallColor: color,
        accentColor: '#A855F7',
        signboard: (x % 130 === 0) ? {
          textBn: 'গুলশান গ্র্যান্ড প্লাজা শপিং কমপ্লেক্স',
          textEn: 'Gulshan Grand Luxury Arcade',
          bgColor: '#0F172A',
          textColor: '#38BDF8'
        } : undefined
      });
    }
  }

  // 4. KAWRAN BAZAR WHOLESALE & WAREHOUSES (10m to 30m, tin roofs, market stalls)
  const marketColors = ['#64748B', '#71717A', '#52525B', '#475569', '#78716C', '#A8A29E'];
  for (let x = -240; x <= 130; x += 45) {
    for (let z = -430; z <= -120; z += 45) {
      if (Math.abs(x) < 18 || Math.abs(z + 250) < 15) continue;

      const height = 8 + Math.floor(((x * 5 + z * 3) % 20));
      const width = 28 + ((x + z) % 8);
      const depth = 26 + ((x * z) % 8);
      const color = marketColors[(Math.abs(x + z)) % marketColors.length];

      buildings.push({
        id: `bldg_kawran_${x}_${z}`,
        districtId: 'kawran_bazar',
        x,
        z,
        width,
        depth,
        height,
        style: 'market_stall',
        wallColor: color,
        accentColor: '#F59E0B',
        signboard: (x % 90 === 0) ? {
          textBn: 'কাওরান বাজার পাইকারি আড়ৎ',
          textEn: 'Kawran Wholesale Veg & Fish Depot',
          bgColor: '#15803D',
          textColor: '#FEF08A'
        } : undefined
      });
    }
  }

  // 5. DHANMONDI RESIDENTIAL (18m to 38m)
  const dhanmondiColors = ['#D1D5DB', '#E5E7EB', '#F3F4F6', '#9CA3AF', '#6B7280'];
  for (let x = -620; x <= -260; x += 60) {
    for (let z = -430; z <= 80; z += 55) {
      if (Math.abs(x + 400) < 18 || Math.abs(z + 250) < 14) continue;

      const height = 20 + Math.floor(((x * 7 + z * 3) % 25));
      const width = 32 + ((x + z) % 10);
      const depth = 30 + ((x * z) % 10);
      const color = dhanmondiColors[(Math.abs(x + z)) % dhanmondiColors.length];

      buildings.push({
        id: `bldg_dhanmondi_${x}_${z}`,
        districtId: 'dhanmondi',
        x,
        z,
        width,
        depth,
        height,
        style: 'residential_tin',
        wallColor: color,
        accentColor: '#10B981'
      });
    }
  }

  // 6. BURIGANGA RIVERFRONT WAREHOUSES & DOCK STRUCTURES (Z: 420 to 520)
  for (let x = -550; x <= 550; x += 80) {
    const z = 470;
    if (Math.abs(x + 120) < 25) continue; // Babubazar bridge approach

    buildings.push({
      id: `dock_warehouse_${x}`,
      districtId: 'sadarghat',
      x,
      z,
      width: 44,
      depth: 26,
      height: 14,
      style: 'warehouse',
      wallColor: '#475569',
      accentColor: '#0284C7',
      signboard: {
        textBn: 'সদরঘাট মাল খালাসী ডক ও গুদাম',
        textEn: 'Buriganga Cargo Pier & Customs Warehouse',
        bgColor: '#1E293B',
        textColor: '#38BDF8'
      }
    });
  }

  return buildings;
}
