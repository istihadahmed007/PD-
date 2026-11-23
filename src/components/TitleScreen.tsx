/**
 * DTA: Dhaka Theft Auto - Cinematic Title Screen
 */

import React from 'react';
import { Play, HelpCircle, Volume2, VolumeX, Shield, Compass } from 'lucide-react';

interface TitleScreenProps {
  onStartGame: () => void;
  onOpenControls: () => void;
  isMuted: boolean;
  onToggleMute: () => void;
}

export const TitleScreen: React.FC<TitleScreenProps> = ({
  onStartGame,
  onOpenControls,
  isMuted,
  onToggleMute
}) => {
  return (
    <div className="fixed inset-0 z-40 flex flex-col justify-between p-8 select-none bg-gradient-to-t from-black via-slate-950/80 to-transparent">
      {/* Top Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded-full bg-emerald-500 animate-ping" />
          <span className="text-xs font-mono tracking-widest text-emerald-400 font-bold uppercase">
            BANGLADESH OPEN-WORLD PLATFORM • 2.5X EXPANDED CITY
          </span>
        </div>

        <button
          onClick={onToggleMute}
          className="hud-panel p-2.5 rounded-full text-slate-300 hover:text-white transition"
          title={isMuted ? 'Unmute Sound' : 'Mute Sound'}
        >
          {isMuted ? <VolumeX className="w-5 h-5 text-red-400" /> : <Volume2 className="w-5 h-5 text-emerald-400" />}
        </button>
      </div>

      {/* Main Cinematic Title Branding */}
      <div className="max-w-2xl flex flex-col gap-3">
        <div className="inline-flex items-center gap-2 text-amber-400 font-bold tracking-widest uppercase text-sm">
          <span>ORIGINAL BANGLADESH CRIME-ACTION</span>
        </div>

        <h1 className="text-6xl md:text-7xl font-black text-transparent bg-clip-text bg-gradient-to-r from-amber-400 via-emerald-400 to-teal-300 tracking-tight leading-none">
          DHAKA THEFT AUTO
        </h1>

        <div className="text-2xl md:text-3xl font-bold font-bengali text-white text-glow">
          ঢাকা থেফট অটো — ডিটিএ
        </div>

        <p className="text-slate-300 text-sm md:text-base leading-relaxed max-w-xl">
          পুরান ঢাকা, শাপলা চত্বর, কাওরান বাজার ফ্লাইওভার, গুলশান এবং বুড়িগঙ্গা রিভারফ্রন্টের এক বিশাল উন্মুক্ত শহরের রোমাঞ্চকর জগৎ। চালান সিএনজি, গাড়ি ও রিকশা, সম্পূর্ণ করুন রোমহর্ষক মিশন!
        </p>

        {/* Action Buttons */}
        <div className="flex items-center gap-4 pt-4">
          <button
            onClick={onStartGame}
            className="px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-black font-black text-lg rounded-2xl transition shadow-[0_0_30px_rgba(16,185,129,0.5)] flex items-center gap-3 transform hover:scale-105 active:scale-95"
          >
            <Play className="w-6 h-6 fill-black" />
            <span>PLAY NOW • খেলা শুরু</span>
          </button>

          <button
            onClick={onOpenControls}
            className="hud-panel px-6 py-4 rounded-2xl text-slate-200 hover:text-white hover:bg-slate-800/80 transition flex items-center gap-2 font-bold text-sm"
          >
            <HelpCircle className="w-5 h-5 text-amber-400" />
            <span>CONTROLS • নিয়ম</span>
          </button>
        </div>
      </div>

      {/* District Badges Highlights */}
      <div className="flex flex-wrap items-center gap-3 text-xs">
        <div className="hud-panel px-3 py-1.5 rounded-lg flex items-center gap-1.5 text-slate-300">
          <span className="w-2 h-2 rounded-full bg-amber-500" />
          <span>পুরান ঢাকা / চকবাজার</span>
        </div>
        <div className="hud-panel px-3 py-1.5 rounded-lg flex items-center gap-1.5 text-slate-300">
          <span className="w-2 h-2 rounded-full bg-emerald-500" />
          <span>শাপলা চত্বর</span>
        </div>
        <div className="hud-panel px-3 py-1.5 rounded-lg flex items-center gap-1.5 text-slate-300">
          <span className="w-2 h-2 rounded-full bg-blue-500" />
          <span>মতিঝিল বাণিজ্যিক এলাকা</span>
        </div>
        <div className="hud-panel px-3 py-1.5 rounded-lg flex items-center gap-1.5 text-slate-300">
          <span className="w-2 h-2 rounded-full bg-purple-500" />
          <span>কাওরান বাজার ফ্লাইওভার</span>
        </div>
        <div className="hud-panel px-3 py-1.5 rounded-lg flex items-center gap-1.5 text-slate-300">
          <span className="w-2 h-2 rounded-full bg-cyan-500" />
          <span>সদরঘাট ও বুড়িগঙ্গা</span>
        </div>
      </div>
    </div>
  );
};
