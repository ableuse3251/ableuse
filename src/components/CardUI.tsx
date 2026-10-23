import React from 'react';
import { PlayerCard } from '../types';

interface CardUIProps {
  card: PlayerCard;
  chemistry?: number; // 0 to 3 diamonds
  size?: 'sm' | 'md' | 'lg';
  onClick?: () => void;
  selected?: boolean;
}

export const CardUI: React.FC<CardUIProps> = ({
  card,
  chemistry,
  size = 'md',
  onClick,
  selected = false,
}) => {
  const getRarityStyles = () => {
    switch (card.rarity) {
      case 'ELITE':
        return {
          cardBg: 'bg-gradient-to-b from-indigo-950 via-purple-900 to-slate-950',
          border: 'border-2 border-cyan-400 shadow-[0_0_15px_rgba(34,211,238,0.4)]',
          badgeBg: 'bg-cyan-500/20 text-cyan-200 border-cyan-400/40',
          ratingColor: 'text-cyan-300',
          accentText: 'text-cyan-300',
          glow: 'shadow-cyan-500/30',
        };
      case 'GOLD':
        return {
          cardBg: 'bg-gradient-to-b from-amber-700 via-yellow-600 to-amber-950',
          border: 'border-2 border-yellow-300 shadow-[0_0_12px_rgba(253,224,71,0.35)]',
          badgeBg: 'bg-yellow-400/25 text-yellow-100 border-yellow-300/50',
          ratingColor: 'text-yellow-200',
          accentText: 'text-yellow-200',
          glow: 'shadow-yellow-500/30',
        };
      case 'SILVER':
        return {
          cardBg: 'bg-gradient-to-b from-slate-600 via-slate-700 to-slate-900',
          border: 'border-2 border-slate-300 shadow-[0_0_10px_rgba(203,213,225,0.3)]',
          badgeBg: 'bg-slate-400/20 text-slate-100 border-slate-300/40',
          ratingColor: 'text-slate-100',
          accentText: 'text-slate-200',
          glow: 'shadow-slate-400/20',
        };
      case 'BRONZE':
      default:
        return {
          cardBg: 'bg-gradient-to-b from-amber-900 via-amber-950 to-stone-950',
          border: 'border-2 border-amber-700/80 shadow-[0_0_8px_rgba(180,83,9,0.25)]',
          badgeBg: 'bg-amber-800/30 text-amber-200 border-amber-600/40',
          ratingColor: 'text-amber-300',
          accentText: 'text-amber-300',
          glow: 'shadow-amber-900/20',
        };
    }
  };

  const style = getRarityStyles();

  if (size === 'sm') {
    return (
      <div
        onClick={onClick}
        className={`relative flex flex-col items-center justify-between rounded-xl p-1.5 transition-all duration-150 cursor-pointer select-none ${
          style.cardBg
        } ${style.border} ${
          selected ? 'ring-2 ring-yellow-400 scale-105' : 'hover:scale-102 hover:brightness-110'
        } w-20 h-28 shadow-lg`}
      >
        <div className="flex w-full items-start justify-between leading-none px-0.5">
          <div className="flex flex-col items-center">
            <span className={`text-sm font-black tracking-tighter ${style.ratingColor}`}>
              {card.rating}
            </span>
            <span className="text-[10px] font-bold text-slate-200 tracking-wider">
              {card.position}
            </span>
          </div>
          <span className="text-[9px] font-semibold text-slate-300 truncate max-w-[42px] text-right">
            {card.club.split(' ')[0]}
          </span>
        </div>

        <div className="flex flex-col items-center justify-center my-auto">
          <div className="w-8 h-8 rounded-full bg-slate-800/60 border border-white/10 flex items-center justify-center text-sm shadow-inner">
            ⚽
          </div>
          <span className="text-[11px] font-extrabold text-white truncate max-w-[70px] text-center mt-1 drop-shadow-sm">
            {card.player_name}
          </span>
        </div>

        {chemistry !== undefined && (
          <div className="flex items-center gap-0.5 mt-0.5">
            {[0, 1, 2].map((idx) => (
              <div
                key={idx}
                className={`w-1.5 h-1.5 rotate-45 border ${
                  idx < chemistry
                    ? 'bg-emerald-400 border-emerald-300 shadow-[0_0_4px_#34d399]'
                    : 'bg-slate-800/80 border-slate-600/50'
                }`}
              />
            ))}
          </div>
        )}
      </div>
    );
  }

  return (
    <div
      onClick={onClick}
      className={`relative flex flex-col justify-between rounded-2xl p-3 transition-all duration-200 cursor-pointer select-none ${
        style.cardBg
      } ${style.border} ${
        selected ? 'ring-4 ring-yellow-400 scale-105' : 'hover:scale-[1.03] hover:brightness-110'
      } ${size === 'lg' ? 'w-56 h-80' : 'w-44 h-64'} shadow-xl`}
    >
      {/* Top Header: Rating & Position + Nation/Club */}
      <div className="flex justify-between items-start">
        <div className="flex flex-col items-center">
          <span className={`text-2xl font-black tracking-tight ${style.ratingColor}`}>
            {card.rating}
          </span>
          <span className="text-xs font-bold uppercase tracking-wider text-slate-100">
            {card.position}
          </span>
        </div>

        <div className="flex flex-col items-end gap-1">
          <span className="text-[10px] font-semibold text-slate-200 bg-black/40 px-1.5 py-0.5 rounded border border-white/10 max-w-[90px] truncate">
            {card.nation}
          </span>
          <span className="text-[10px] font-medium text-amber-200 bg-black/40 px-1.5 py-0.5 rounded border border-white/10 max-w-[90px] truncate">
            {card.club}
          </span>
        </div>
      </div>

      {/* Central Portrait & Name */}
      <div className="flex flex-col items-center my-auto">
        <div className="w-16 h-16 rounded-full bg-slate-950/60 border-2 border-white/15 flex items-center justify-center text-3xl shadow-inner mb-2">
          ⚽
        </div>
        <div className="text-center">
          <div className="text-sm font-black text-white tracking-wide truncate max-w-[140px] drop-shadow-md">
            {card.player_name}
          </div>
          <div className="text-[10px] text-slate-300/80 font-medium tracking-tight">
            {card.league_name}
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="w-full bg-black/40 rounded-xl p-2 border border-white/10 backdrop-blur-xs">
        <div className="grid grid-cols-3 gap-x-2 gap-y-1 text-center font-bold">
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.pace}</span>
            <span className="text-[9px] text-slate-400">PAC</span>
          </div>
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.shooting}</span>
            <span className="text-[9px] text-slate-400">SHO</span>
          </div>
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.passing}</span>
            <span className="text-[9px] text-slate-400">PAS</span>
          </div>
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.dribbling}</span>
            <span className="text-[9px] text-slate-400">DRI</span>
          </div>
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.defending}</span>
            <span className="text-[9px] text-slate-400">DEF</span>
          </div>
          <div className="flex flex-col">
            <span className="text-[11px] text-white leading-tight">{card.physical}</span>
            <span className="text-[9px] text-slate-400">PHY</span>
          </div>
        </div>
      </div>

      {/* Chemistry indicator if provided */}
      {chemistry !== undefined && (
        <div className="flex items-center justify-center gap-1.5 mt-1.5">
          {[0, 1, 2].map((idx) => (
            <div
              key={idx}
              className={`w-2 h-2 rotate-45 border ${
                idx < chemistry
                  ? 'bg-emerald-400 border-emerald-300 shadow-[0_0_6px_#34d399]'
                  : 'bg-slate-900/80 border-slate-600/50'
              }`}
            />
          ))}
        </div>
      )}
    </div>
  );
};
