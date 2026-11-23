/**
 * DTA: Dhaka Theft Auto - Controls & Gameplay Guide Overlay
 */

import React from 'react';
import { X, Keyboard, Car, User, Navigation } from 'lucide-react';

interface ControlsOverlayProps {
  onClose: () => void;
}

export const ControlsOverlay: React.FC<ControlsOverlayProps> = ({ onClose }) => {
  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 select-none">
      <div className="hud-panel max-w-xl w-full p-6 rounded-2xl border border-white/20 shadow-2xl flex flex-col gap-5">
        <div className="flex items-center justify-between border-b border-slate-700/60 pb-3">
          <div className="flex items-center gap-2 text-amber-400 font-bold text-lg">
            <Keyboard className="w-5 h-5" />
            <span>GAME CONTROLS • খেলার নিয়ম ও কন্ট্রোলস</span>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg bg-slate-800 text-slate-300 hover:bg-slate-700 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
          {/* On Foot Controls */}
          <div className="p-3.5 bg-slate-900/80 rounded-xl border border-slate-800 flex flex-col gap-2.5">
            <div className="flex items-center gap-1.5 font-bold text-emerald-400 uppercase tracking-wider text-[11px]">
              <User className="w-4 h-4" />
              <span>হেঁটে চলা (On Foot)</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">হাঁটা / মুভমেন্ট</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">W, A, S, D</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">দৌড়ানো (Sprint)</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">Shift</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">লাফানো (Jump)</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">Space</span>
            </div>
            <div className="flex justify-between py-1">
              <span className="text-slate-400">ক্যামেরা ঘোরানো</span>
              <span className="font-mono text-amber-400 font-bold">Mouse Look</span>
            </div>
          </div>

          {/* Driving Controls */}
          <div className="p-3.5 bg-slate-900/80 rounded-xl border border-slate-800 flex flex-col gap-2.5">
            <div className="flex items-center gap-1.5 font-bold text-amber-400 uppercase tracking-wider text-[11px]">
              <Car className="w-4 h-4" />
              <span>গাড়ি ও সিএনজি চালানো (Driving)</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">গাড়িতে ওঠা / নামা</span>
              <span className="font-mono text-emerald-400 font-bold bg-slate-800 px-2 py-0.5 rounded">E বা F</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">এক্সিলেটর / ব্রেক</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">W / S</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">ডানে / বামে মোড়</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">A / D</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-800">
              <span className="text-slate-400">হ্যান্ডব্রেক / ড্রিফট</span>
              <span className="font-mono text-white font-bold bg-slate-800 px-2 py-0.5 rounded">Space</span>
            </div>
            <div className="flex justify-between py-1">
              <span className="text-slate-400">হর্ন বাজানো (Honk)</span>
              <span className="font-mono text-yellow-400 font-bold bg-slate-800 px-2 py-0.5 rounded">H</span>
            </div>
          </div>
        </div>

        {/* Missions & Gameplay */}
        <div className="p-3 bg-amber-950/30 rounded-xl border border-amber-500/30 flex items-center justify-between text-xs text-amber-200">
          <div className="flex items-center gap-2">
            <Navigation className="w-4 h-4 text-amber-400" />
            <span>মিশন শুরু করতে <b className="text-white bg-slate-800 px-1.5 py-0.5 rounded">[M]</b> চাপুন • ট্যাক্সি ভাড়া পেতে <b className="text-white bg-slate-800 px-1.5 py-0.5 rounded">[T]</b> চাপুন</span>
          </div>
        </div>

        <button
          onClick={onClose}
          className="w-full py-2.5 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold rounded-xl transition shadow-lg text-sm"
        >
          বুঝেছি / Let's Play
        </button>
      </div>
    </div>
  );
};
