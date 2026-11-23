/**
 * DTA: Dhaka Theft Auto - Cinematic Heads-Up Display (HUD)
 * Speedometer, Health, Cash (৳), Wanted Stars, District Banner & Mission Trackers
 */

import React from 'react';
import type { GameHUDState } from '../game/engine';
import { Heart, DollarSign, Gauge, ShieldAlert, Award, Clock, Navigation } from 'lucide-react';

interface HUDProps {
  hudState: GameHUDState;
}

export const HUD: React.FC<HUDProps> = ({ hudState }) => {
  return (
    <div className="absolute inset-0 pointer-events-none z-20 flex flex-col justify-between p-6">
      {/* =========================================================
          TOP BAR: Cash, Wanted Level & Clock
         ========================================================= */}
      <div className="flex items-start justify-between w-full">
        {/* Left: District Entry Announcement Banner */}
        <div className="hud-panel px-4 py-2 rounded-xl flex flex-col gap-0.5 max-w-sm">
          <div className="text-xs uppercase tracking-widest text-amber-400 font-bold">
            {hudState.currentDistrict.nameEn}
          </div>
          <div className="text-lg font-bold font-bengali text-white text-glow">
            {hudState.currentDistrict.nameBn}
          </div>
        </div>

        {/* Center: Wanted Stars (★ ★ ★ ★ ★) */}
        <div className="flex flex-col items-center">
          <div className="flex items-center gap-1.5 bg-black/70 px-4 py-1.5 rounded-full border border-red-500/30">
            {[1, 2, 3, 4, 5].map((star) => (
              <span
                key={star}
                className={`text-xl transition-all duration-300 ${
                  star <= hudState.wantedStars
                    ? 'text-yellow-400 drop-shadow-[0_0_8px_rgba(250,204,21,0.9)] animate-pulse'
                    : 'text-zinc-600'
                }`}
              >
                ★
              </span>
            ))}
          </div>
          {hudState.wantedStars > 0 && (
            <div className="mt-1 flex items-center gap-1 text-[11px] font-bold text-red-400 tracking-wider uppercase animate-bounce">
              <ShieldAlert className="w-3.5 h-3.5" /> Kotwali Police Alert
            </div>
          )}
        </div>

        {/* Right: Cash Counter (BDT ৳) & Game Clock */}
        <div className="flex items-center gap-4">
          <div className="hud-panel px-4 py-2 rounded-xl flex items-center gap-2">
            <span className="text-emerald-400 font-bengali text-2xl font-bold">৳</span>
            <span className="text-2xl font-black text-emerald-400 tracking-wide font-mono">
              {hudState.cashBdt.toLocaleString()}
            </span>
          </div>

          <div className="hud-panel px-3 py-2 rounded-xl flex items-center gap-1.5 text-slate-300 font-mono text-sm">
            <Clock className="w-4 h-4 text-amber-400" />
            <span>{hudState.timeOfDay}</span>
          </div>
        </div>
      </div>

      {/* =========================================================
          CENTER: Interactive Action Prompts
         ========================================================= */}
      {hudState.nearbyInteractText && (
        <div className="self-center mb-8">
          <div className="hud-panel px-6 py-2.5 rounded-full border border-amber-400/40 text-amber-300 font-bold text-sm tracking-wide shadow-lg flex items-center gap-2 animate-pulse">
            <span className="w-2 h-2 rounded-full bg-amber-400" />
            <span>{hudState.nearbyInteractText}</span>
          </div>
        </div>
      )}

      {/* =========================================================
          RIGHT: Active Mission / Taxi Fare Tracker
         ========================================================= */}
      <div className="absolute right-6 top-24 flex flex-col gap-3 max-w-sm">
        {/* Story Mission Card */}
        {hudState.activeMission && (
          <div className="hud-panel p-4 rounded-xl border-l-4 border-l-amber-500 flex flex-col gap-2">
            <div className="flex items-center justify-between text-xs font-bold text-amber-400 uppercase tracking-wider">
              <div className="flex items-center gap-1.5">
                <Award className="w-4 h-4" />
                <span>মিশন / Mission</span>
              </div>
              {hudState.missionTimeLeft !== null && (
                <span className="text-red-400 font-mono text-sm">{hudState.missionTimeLeft}s</span>
              )}
            </div>

            <div className="font-bold text-base text-white font-bengali">
              {hudState.activeMission.titleBn}
            </div>

            <p className="text-xs text-slate-300 leading-relaxed">
              {hudState.activeMission.description}
            </p>

            <div className="flex items-center justify-between text-xs text-emerald-400 font-mono pt-1 border-t border-slate-700/50">
              <span>Reward: ৳{hudState.activeMission.rewardBdt.toLocaleString()}</span>
              <span className="text-amber-300">+{hudState.activeMission.repPoints} REP</span>
            </div>
          </div>
        )}

        {/* Taxi Fare Ride Card */}
        {hudState.activeFare && (
          <div className="hud-panel p-3.5 rounded-xl border-l-4 border-l-emerald-500 flex flex-col gap-1.5">
            <div className="flex items-center justify-between text-xs font-bold text-emerald-400 uppercase tracking-wider">
              <div className="flex items-center gap-1">
                <Navigation className="w-3.5 h-3.5" />
                <span>ভাড়া / Passenger Fare</span>
              </div>
              <span className="font-mono text-amber-400 font-bold">৳{hudState.activeFare.fareBdt}</span>
            </div>

            <div className="text-sm font-bold text-white font-bengali">
              গন্তব্য: {hudState.activeFare.destination.nameBn}
            </div>

            <div className="text-xs text-slate-400 font-mono">
              Distance: {hudState.activeFare.distanceMeters}m
            </div>
          </div>
        )}
      </div>

      {/* =========================================================
          BOTTOM RIGHT: Speedometer & Health Gauge
         ========================================================= */}
      <div className="flex items-end justify-end w-full">
        <div className="flex items-center gap-5">
          {/* Health Bar */}
          <div className="hud-panel px-4 py-2.5 rounded-xl flex items-center gap-3">
            <Heart className="w-5 h-5 text-red-500 fill-red-500 animate-pulse" />
            <div className="flex flex-col gap-1">
              <div className="w-28 h-2.5 bg-slate-800 rounded-full overflow-hidden border border-slate-700">
                <div
                  className="h-full bg-gradient-to-r from-red-600 to-emerald-500 transition-all duration-200"
                  style={{ width: `${hudState.health}%` }}
                />
              </div>
              <span className="text-[10px] font-mono text-slate-400 uppercase">HP {hudState.health}%</span>
            </div>
          </div>

          {/* Speedometer (visible when in vehicle or running) */}
          <div className="hud-panel px-5 py-3 rounded-2xl flex flex-col items-center justify-center min-w-[130px]">
            <div className="flex items-baseline gap-1">
              <span className="text-4xl font-black font-mono text-white tracking-tighter">
                {hudState.speedKmh}
              </span>
              <span className="text-xs font-bold text-amber-400 uppercase">KM/H</span>
            </div>
            <div className="text-[10px] uppercase font-bold text-slate-400 tracking-wider mt-0.5">
              {hudState.isInVehicle ? hudState.vehicleType?.toUpperCase() : 'ON FOOT'}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
