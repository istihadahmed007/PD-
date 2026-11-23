/**
 * DTA: Dhaka Theft Auto - Main Application Orchestrator
 */

import React, { useEffect, useRef, useState } from 'react';
import { DhakaGameEngine, type GameHUDState } from './game/engine';
import { DISTRICTS } from './game/worldData';
import { soundEngine } from './game/audio';
import { HUD } from './components/HUD';
import { Minimap } from './components/Minimap';
import { TitleScreen } from './components/TitleScreen';
import { ControlsOverlay } from './components/ControlsOverlay';

export const App: React.FC = () => {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const engineRef = useRef<DhakaGameEngine | null>(null);

  const [gameStarted, setGameStarted] = useState<boolean>(false);
  const [showControls, setShowControls] = useState<boolean>(false);
  const [isMuted, setIsMuted] = useState<boolean>(false);

  // HUD and Player Tracking State
  const [hudState, setHudState] = useState<GameHUDState>({
    health: 100,
    cashBdt: 1500,
    wantedStars: 0,
    currentDistrict: DISTRICTS[1], // Shapla Crossing default
    isInVehicle: false,
    vehicleType: null,
    speedKmh: 0,
    activeMission: null,
    missionProgress: null,
    missionTimeLeft: null,
    activeFare: null,
    nearbyInteractText: null,
    timeOfDay: '14:30'
  });

  const [playerCoord, setPlayerCoord] = useState<{ x: number; z: number; heading: number }>({
    x: 15,
    z: 15,
    heading: 0
  });

  // Initialize Three.js Game Engine
  useEffect(() => {
    if (!containerRef.current) return;

    const engine = new DhakaGameEngine(containerRef.current, (newHUD) => {
      setHudState(newHUD);

      const pos = engine.getCurrentPosition();
      const heading = engine.getPlayerHeading();
      setPlayerCoord({ x: pos.x, z: pos.z, heading });
    });

    engineRef.current = engine;
    engine.start();

    return () => {
      engine.destroy();
      engineRef.current = null;
    };
  }, []);

  const handleStartGame = () => {
    setGameStarted(true);
    soundEngine.playRickshawBell();
  };

  const handleToggleMute = () => {
    const next = !isMuted;
    setIsMuted(next);
    soundEngine.setMuted(next);
  };

  return (
    <div className="relative w-screen h-screen overflow-hidden bg-black select-none">
      {/* 3D WebGL Canvas Viewport */}
      <div ref={containerRef} className="absolute inset-0 w-full h-full cursor-crosshair" />

      {/* Title Screen Overlay */}
      {!gameStarted && (
        <TitleScreen
          onStartGame={handleStartGame}
          onOpenControls={() => setShowControls(true)}
          isMuted={isMuted}
          onToggleMute={handleToggleMute}
        />
      )}

      {/* In-Game HUD & Minimap */}
      {gameStarted && (
        <>
          <HUD hudState={hudState} />
          <Minimap
            playerX={playerCoord.x}
            playerZ={playerCoord.z}
            playerHeading={playerCoord.heading}
            currentDistrict={hudState.currentDistrict}
            missionDropoffPOIId={hudState.activeMission?.dropoffPOIId}
            fareDest={hudState.activeFare?.destination}
          />
        </>
      )}

      {/* Controls & Help Modal */}
      {showControls && <ControlsOverlay onClose={() => setShowControls(false)} />}
    </div>
  );
};
export default App;
