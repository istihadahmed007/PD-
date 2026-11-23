/**
 * DTA: Dhaka Theft Auto - Real-Time Minimap & Tactical Radar
 * Scaled 2D canvas displaying 1500m x 1500m Dhaka road network, Buriganga river, districts & beacons
 */

import React, { useRef, useEffect, useState } from 'react';
import {
  WORLD_HALF_SIZE,
  RIVER_Z_START,
  ROAD_SEGMENTS,
  DISTRICTS,
  POIS,
  type District,
  type POI
} from '../game/worldData';
import { Map, Maximize2, Minimize2, Compass } from 'lucide-react';

interface MinimapProps {
  playerX: number;
  playerZ: number;
  playerHeading: number;
  currentDistrict: District;
  missionDropoffPOIId?: string | null;
  fareDest?: { x: number; z: number; nameBn: string } | null;
}

export const Minimap: React.FC<MinimapProps> = ({
  playerX,
  playerZ,
  playerHeading,
  currentDistrict,
  missionDropoffPOIId,
  fareDest
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [isExpanded, setIsExpanded] = useState<boolean>(false);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const size = isExpanded ? 500 : 210;
    canvas.width = size;
    canvas.height = size;

    // Background terrain
    ctx.fillStyle = '#0F172A';
    ctx.fillRect(0, 0, size, size);

    // Coordinate conversion function
    // World space: [-WORLD_HALF_SIZE, WORLD_HALF_SIZE]
    const worldToCanvas = (wx: number, wz: number): { x: number; y: number } => {
      if (isExpanded) {
        // Full overview map
        const normX = (wx + WORLD_HALF_SIZE) / (WORLD_HALF_SIZE * 2);
        const normZ = (wz + WORLD_HALF_SIZE) / (WORLD_HALF_SIZE * 2);
        return {
          x: normX * size,
          y: normZ * size
        };
      } else {
        // Rotating/centered tactical radar around player
        const range = 240; // 240m radar radius
        const relX = (wx - playerX) / range;
        const relZ = (wz - playerZ) / range;
        return {
          x: size / 2 + relX * (size / 2),
          y: size / 2 + relZ * (size / 2)
        };
      }
    };

    // 1. Draw Buriganga River
    const riverStart = worldToCanvas(-WORLD_HALF_SIZE, RIVER_Z_START);
    const riverEnd = worldToCanvas(WORLD_HALF_SIZE, WORLD_HALF_SIZE);
    ctx.fillStyle = '#0369A1'; // Deep river blue
    if (isExpanded) {
      ctx.fillRect(0, riverStart.y, size, size - riverStart.y);
    } else {
      // In local radar
      const riverLocalY = worldToCanvas(0, RIVER_Z_START).y;
      if (riverLocalY < size) {
        ctx.fillRect(0, Math.max(0, riverLocalY), size, size);
      }
    }

    // 2. Draw District Boundary Shading (in expanded mode)
    if (isExpanded) {
      DISTRICTS.forEach((d) => {
        const minPt = worldToCanvas(d.bounds.minX, d.bounds.minZ);
        const maxPt = worldToCanvas(d.bounds.maxX, d.bounds.maxZ);
        ctx.strokeStyle = d.primaryColor;
        ctx.lineWidth = 1;
        ctx.setLineDash([4, 4]);
        ctx.strokeRect(minPt.x, minPt.y, maxPt.x - minPt.x, maxPt.y - minPt.y);
        ctx.setLineDash([]);

        // District Label
        ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
        ctx.font = 'bold 9px "Noto Sans Bengali", sans-serif';
        ctx.fillText(d.nameBn, minPt.x + 6, minPt.y + 14);
      });
    }

    // 3. Draw Road Network
    ROAD_SEGMENTS.forEach((road) => {
      const p1 = worldToCanvas(road.startX, road.startZ);
      const p2 = worldToCanvas(road.endX, road.endZ);

      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);

      if (road.type === 'flyover') {
        ctx.strokeStyle = '#A855F7'; // Purple flyover
        ctx.lineWidth = isExpanded ? 4 : 5;
        ctx.setLineDash([6, 3]);
        ctx.stroke();
        ctx.setLineDash([]);
      } else if (road.type === 'bridge') {
        ctx.strokeStyle = '#F59E0B'; // Amber bridge
        ctx.lineWidth = isExpanded ? 4 : 5;
        ctx.stroke();
      } else if (road.type === 'arterial') {
        ctx.strokeStyle = '#E2E8F0'; // White main avenue
        ctx.lineWidth = isExpanded ? 3.5 : 4.5;
        ctx.stroke();
      } else if (road.type === 'secondary') {
        ctx.strokeStyle = '#94A3B8'; // Secondary road
        ctx.lineWidth = isExpanded ? 2.5 : 3;
        ctx.stroke();
      } else {
        ctx.strokeStyle = '#64748B'; // Narrow alley
        ctx.lineWidth = isExpanded ? 1.5 : 2;
        ctx.stroke();
      }
    });

    // 4. Draw POIs
    POIS.forEach((poi) => {
      const pt = worldToCanvas(poi.x, poi.z);
      if (pt.x >= 0 && pt.x <= size && pt.y >= 0 && pt.y <= size) {
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, isExpanded ? 4 : 5, 0, Math.PI * 2);

        if (poi.type === 'monument') ctx.fillStyle = '#10B981'; // Green for Shapla
        else if (poi.type === 'police_thana') ctx.fillStyle = '#EF4444'; // Red police
        else if (poi.type === 'garage') ctx.fillStyle = '#F59E0B'; // Yellow garage
        else if (poi.type === 'launch_terminal') ctx.fillStyle = '#06B6D4'; // Cyan terminal
        else ctx.fillStyle = '#A855F7';

        ctx.fill();
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 1;
        ctx.stroke();
      }
    });

    // 5. Draw Active Mission Beacon
    if (missionDropoffPOIId) {
      const dropPOI = POIS.find((p) => p.id === missionDropoffPOIId);
      if (dropPOI) {
        const pt = worldToCanvas(dropPOI.x, dropPOI.z);
        // Pulsing yellow beacon ring
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, 8, 0, Math.PI * 2);
        ctx.strokeStyle = '#FACC15';
        ctx.lineWidth = 3;
        ctx.stroke();

        ctx.beginPath();
        ctx.arc(pt.x, pt.y, 3, 0, Math.PI * 2);
        ctx.fillStyle = '#FACC15';
        ctx.fill();
      }
    }

    // 6. Draw Active Fare Dropoff Beacon
    if (fareDest) {
      const pt = worldToCanvas(fareDest.x, fareDest.z);
      ctx.beginPath();
      ctx.arc(pt.x, pt.y, 8, 0, Math.PI * 2);
      ctx.strokeStyle = '#22C55E';
      ctx.lineWidth = 3;
      ctx.stroke();
    }

    // 7. Draw Player Marker
    const playerCanvasPt = worldToCanvas(playerX, playerZ);
    ctx.save();
    ctx.translate(playerCanvasPt.x, playerCanvasPt.y);
    ctx.rotate(playerHeading);

    // Directional Player Chevron Arrow
    ctx.beginPath();
    ctx.moveTo(0, -9);
    ctx.lineTo(6, 7);
    ctx.lineTo(0, 4);
    ctx.lineTo(-6, 7);
    ctx.closePath();
    ctx.fillStyle = '#38BDF8'; // Bright cyan GPS marker
    ctx.fill();
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.restore();

    // Radar circular border in compact mode
    if (!isExpanded) {
      ctx.strokeStyle = 'rgba(56, 189, 248, 0.4)';
      ctx.lineWidth = 2;
      ctx.strokeRect(0, 0, size, size);
    }
  }, [playerX, playerZ, playerHeading, currentDistrict, isExpanded, missionDropoffPOIId, fareDest]);

  return (
    <div
      className={`absolute transition-all duration-300 z-30 select-none ${
        isExpanded
          ? 'top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[516px] h-[540px]'
          : 'bottom-6 left-6 w-[218px] h-[246px]'
      }`}
    >
      <div className="hud-panel p-2 rounded-xl flex flex-col h-full shadow-2xl border border-white/20">
        {/* Minimap Top Header */}
        <div className="flex items-center justify-between px-2 py-1 mb-1 text-xs">
          <div className="flex items-center gap-1.5 font-bold text-amber-400">
            <Compass className="w-4 h-4 animate-spin-slow" />
            <span className="font-bengali truncate max-w-[130px]">{currentDistrict.nameBn}</span>
          </div>
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="p-1 rounded bg-slate-800/80 hover:bg-slate-700 text-slate-300 transition-colors"
            title={isExpanded ? 'Minimize Radar' : 'Expand City Map'}
          >
            {isExpanded ? <Minimize2 className="w-3.5 h-3.5" /> : <Maximize2 className="w-3.5 h-3.5" />}
          </button>
        </div>

        {/* Map Canvas */}
        <div className="relative flex-1 rounded-lg overflow-hidden border border-slate-700 bg-slate-950 flex items-center justify-center">
          <canvas ref={canvasRef} className="block rounded-lg" />

          {/* Compass Rose */}
          <div className="absolute top-2 right-2 text-[10px] font-bold text-red-500 bg-black/60 px-1 rounded pointer-events-none">
            N
          </div>
        </div>

        {/* Bottom Legend */}
        {isExpanded && (
          <div className="flex items-center justify-between text-[11px] text-slate-300 px-2 pt-2 border-t border-slate-700/60 mt-1">
            <span className="text-emerald-400">● শাপলা চত্বর</span>
            <span className="text-red-400">● ডিএমপি থানা</span>
            <span className="text-amber-400">● গ্যারেজ</span>
            <span className="text-cyan-400">● সদরঘাট</span>
          </div>
        )}
      </div>
    </div>
  );
};
