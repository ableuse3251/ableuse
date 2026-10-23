import React from 'react';
import { Formation, PlayerCard } from '../types';
import { CardUI } from './CardUI';
import { calculateCardChemistry } from '../services/chemistry';

interface PitchViewProps {
  formation: Formation;
  lineup: (PlayerCard | null)[];
  onSlotClick: (slotIndex: number) => void;
  selectedSlotIndex?: number | null;
  interactive?: boolean;
}

export const PitchView: React.FC<PitchViewProps> = ({
  formation,
  lineup,
  onSlotClick,
  selectedSlotIndex = null,
  interactive = true,
}) => {
  return (
    <div className="relative w-full max-w-2xl mx-auto aspect-[1/1.38] rounded-2xl overflow-hidden border-2 border-emerald-500/40 shadow-2xl bg-[#0d2818] select-none">
      {/* Turf grass stripes */}
      <div className="absolute inset-0 flex flex-col pointer-events-none opacity-40">
        {Array.from({ length: 8 }).map((_, i) => (
          <div
            key={i}
            className={`flex-1 ${i % 2 === 0 ? 'bg-emerald-900/30' : 'bg-transparent'}`}
          />
        ))}
      </div>

      {/* Field markings (Soccer pitch layout) */}
      <svg
        className="absolute inset-0 w-full h-full pointer-events-none"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 100 138"
        preserveAspectRatio="none"
      >
        {/* Outer boundary */}
        <rect
          x="3"
          y="3"
          width="94"
          height="132"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
          rx="1"
        />
        {/* Halfway line */}
        <line
          x1="3"
          y1="69"
          x2="97"
          y2="69"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        {/* Center circle */}
        <circle
          cx="50"
          cy="69"
          r="12"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        <circle cx="50" cy="69" r="0.8" fill="rgba(255,255,255,0.3)" />

        {/* Top penalty area (Opponent goal) */}
        <rect
          x="24"
          y="3"
          width="52"
          height="20"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        <rect
          x="36"
          y="3"
          width="28"
          height="7"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        <path
          d="M 40 23 A 10 10 0 0 0 60 23"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />

        {/* Bottom penalty area (Our goal) */}
        <rect
          x="24"
          y="115"
          width="52"
          height="20"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        <rect
          x="36"
          y="128"
          width="28"
          height="7"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
        <path
          d="M 40 115 A 10 10 0 0 1 60 115"
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth="0.8"
        />
      </svg>

      {/* Players / Slots overlay */}
      <div className="absolute inset-0 p-2">
        {formation.slots.map((slot, index) => {
          const card = lineup[index] || null;
          const isSelected = selectedSlotIndex === index;
          const chem = card ? calculateCardChemistry(card, lineup) : 0;

          // Convert slot x,y (0 to 1) into percentage positioning
          const leftPercent = slot.x * 100;
          const topPercent = slot.y * 100;

          return (
            <div
              key={index}
              style={{
                left: `${leftPercent}%`,
                top: `${topPercent}%`,
                transform: 'translate(-50%, -50%)',
              }}
              className="absolute z-10"
            >
              {card ? (
                <div className="group relative">
                  <CardUI
                    card={card}
                    size="sm"
                    chemistry={chem}
                    selected={isSelected}
                    onClick={() => interactive && onSlotClick(index)}
                  />
                  {interactive && (
                    <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-slate-900/90 border border-slate-700 text-[9px] font-bold text-slate-300 px-1.5 py-0.2 rounded shadow-md pointer-events-none">
                      {slot.position}
                    </div>
                  )}
                </div>
              ) : (
                <button
                  type="button"
                  onClick={() => interactive && onSlotClick(index)}
                  className={`flex flex-col items-center justify-center w-16 h-20 md:w-18 md:h-22 rounded-xl transition-all duration-200 border-2 cursor-pointer ${
                    isSelected
                      ? 'bg-yellow-500/30 border-yellow-400 shadow-[0_0_15px_rgba(250,204,21,0.6)] scale-105'
                      : 'bg-slate-950/60 border-dashed border-emerald-400/50 hover:border-emerald-300 hover:bg-slate-900/80 hover:scale-105'
                  }`}
                >
                  <span className="text-xl text-emerald-400 font-extrabold mb-0.5">+</span>
                  <span className="text-[11px] font-black text-emerald-200 uppercase tracking-wider">
                    {slot.position}
                  </span>
                  <span className="text-[8px] font-semibold text-slate-400">
                    СЛОТ {index + 1}
                  </span>
                </button>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
