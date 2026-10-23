import React from 'react';
import { PlayerCard } from '../types';
import { CardUI } from './CardUI';
import { X, Star, Shield, Trophy } from 'lucide-react';

interface PlayerDetailsModalProps {
  player: PlayerCard | null;
  onClose: () => void;
}

export const PlayerDetailsModal: React.FC<PlayerDetailsModalProps> = ({ player, onClose }) => {
  if (!player) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
      <div className="relative w-full max-w-lg p-6 rounded-3xl bg-[#090e1a] border-2 border-amber-400/40 shadow-2xl flex flex-col max-h-[90vh] overflow-y-auto">
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-4 right-4 w-9 h-9 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center cursor-pointer shadow-md"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header / Title */}
        <div className="text-center mb-6">
          <span className="text-xs font-bold text-amber-400 uppercase tracking-widest block mb-1">
            Карточка игрока
          </span>
          <h3 className="text-2xl font-black text-white">{player.player_name}</h3>
          <p className="text-xs text-slate-400">{player.long_name || player.player_name}</p>
        </div>

        {/* Center Card Display */}
        <div className="flex justify-center mb-6">
          <CardUI card={player} size="lg" />
        </div>

        {/* Detailed Stats Breakdown */}
        <div className="space-y-3 w-full bg-slate-900/80 rounded-2xl p-4 border border-white/5">
          <div className="grid grid-cols-2 gap-3 text-xs">
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Клуб:</span>
              <span className="font-bold text-amber-300">{player.club}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Лига:</span>
              <span className="font-bold text-white">{player.league_name}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Нация:</span>
              <span className="font-bold text-white">{player.nation}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Редкость:</span>
              <span className="font-bold text-amber-400">{player.rarity}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Позиция:</span>
              <span className="font-bold text-emerald-400">{player.positions || player.position}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-white/5">
              <span className="text-slate-400">Слабая нога:</span>
              <span className="font-bold text-yellow-300">
                {'★'.repeat(player.weak_foot || 3)}
              </span>
            </div>
          </div>

          {/* Key Attributes Progress Bars */}
          <div className="pt-2 space-y-2">
            {[
              { label: 'Скорость (PAC)', val: player.pace, color: 'bg-emerald-500' },
              { label: 'Удары (SHO)', val: player.shooting, color: 'bg-amber-500' },
              { label: 'Передачи (PAS)', val: player.passing, color: 'bg-blue-500' },
              { label: 'Дриблинг (DRI)', val: player.dribbling, color: 'bg-purple-500' },
              { label: 'Защита (DEF)', val: player.defending, color: 'bg-rose-500' },
              { label: 'Физика (PHY)', val: player.physical, color: 'bg-orange-500' },
            ].map((stat) => (
              <div key={stat.label} className="text-xs">
                <div className="flex justify-between text-[11px] font-semibold text-slate-300 mb-0.5">
                  <span>{stat.label}</span>
                  <span className="font-bold text-white">{stat.val}</span>
                </div>
                <div className="w-full h-1.5 rounded-full bg-slate-800 overflow-hidden">
                  <div
                    className={`h-full ${stat.color}`}
                    style={{ width: `${Math.min(stat.val, 100)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
