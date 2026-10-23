import React, { useState } from 'react';
import { Formation, PlayerCard } from '../types';
import { FORMATIONS } from '../data/formationsData';
import { calculateTeamChemistry } from '../services/chemistry';
import { PitchView } from './PitchView';
import { CardUI } from './CardUI';
import { ArrowLeft, ChevronDown, Plus, Trash2, ArrowUpDown, Info } from 'lucide-react';

interface SquadScreenProps {
  clubCards: PlayerCard[];
  startingLineup: (PlayerCard | null)[];
  substitutes: PlayerCard[];
  formationName: string;
  onUpdateLineup: (newLineup: (PlayerCard | null)[], newSubs: PlayerCard[]) => void;
  onUpdateFormation: (newFormation: string) => void;
  onViewPlayerDetails: (player: PlayerCard) => void;
  onBack: () => void;
}

export const SquadScreen: React.FC<SquadScreenProps> = ({
  clubCards,
  startingLineup,
  substitutes,
  formationName,
  onUpdateLineup,
  onUpdateFormation,
  onViewPlayerDetails,
  onBack,
}) => {
  const [selectedSlotIndex, setSelectedSlotIndex] = useState<number | null>(null);
  const [isChoosingFormation, setIsChoosingFormation] = useState<boolean>(false);
  const [isSelectingPlayerForSlot, setIsSelectingPlayerForSlot] = useState<number | null>(null);
  const [isSelectingPlayerForSub, setIsSelectingPlayerForSub] = useState<boolean>(false);
  const [activeCardActionSlot, setActiveCardActionSlot] = useState<number | null>(null);

  const activeFormation: Formation = FORMATIONS[formationName] || FORMATIONS['4-4-2'];
  const teamChemistry = calculateTeamChemistry(startingLineup);

  const validLineupPlayers = startingLineup.filter((p): p is PlayerCard => p !== null);
  const avgRating =
    validLineupPlayers.length > 0
      ? Math.round(
          validLineupPlayers.reduce((acc, p) => acc + p.rating, 0) / validLineupPlayers.length
        )
      : 0;

  const handleSlotClick = (slotIndex: number) => {
    const card = startingLineup[slotIndex];
    if (card) {
      setActiveCardActionSlot(slotIndex);
    } else {
      setIsSelectingPlayerForSlot(slotIndex);
    }
  };

  const handleAssignPlayerToSlot = (player: PlayerCard) => {
    if (isSelectingPlayerForSlot === null) return;
    const slotIdx = isSelectingPlayerForSlot;

    // Remove player from lineup if already in another slot
    const newLineup = startingLineup.map((p, idx) => (idx === slotIdx ? player : p?.id === player.id ? null : p));
    // Remove from substitutes if was there
    const newSubs = substitutes.filter((p) => p.id !== player.id);

    onUpdateLineup(newLineup, newSubs);
    setIsSelectingPlayerForSlot(null);
  };

  const handleAddPlayerToSubs = (player: PlayerCard) => {
    if (substitutes.some((p) => p.id === player.id)) return;
    // Remove from starting lineup if was there
    const newLineup = startingLineup.map((p) => (p?.id === player.id ? null : p));
    const newSubs = [...substitutes, player];

    onUpdateLineup(newLineup, newSubs);
    setIsSelectingPlayerForSub(false);
  };

  const handleRemoveFromLineup = (slotIndex: number) => {
    const card = startingLineup[slotIndex];
    if (!card) return;

    const newLineup = [...startingLineup];
    newLineup[slotIndex] = null;
    // Add to substitutes
    const newSubs = substitutes.some((p) => p.id === card.id) ? substitutes : [...substitutes, card];

    onUpdateLineup(newLineup, newSubs);
    setActiveCardActionSlot(null);
  };

  const handleRemoveFromSubs = (player: PlayerCard) => {
    const newSubs = substitutes.filter((p) => p.id !== player.id);
    onUpdateLineup(startingLineup, newSubs);
  };

  // Available players for selection (not currently in lineup)
  const availablePlayersForSlot = clubCards;

  return (
    <div className="flex flex-col min-h-screen bg-[#030712] text-slate-100 select-none pb-16">
      {/* Top Header Bar */}
      <header className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-[#0a0f1d]/95 backdrop-blur-md border-b border-amber-500/20 shadow-lg">
        <button
          type="button"
          onClick={onBack}
          className="flex items-center gap-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800/80 px-3 py-1.5 rounded-xl border border-slate-700 cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          Домой
        </button>

        <div className="flex items-center gap-3">
          {/* Stats Badges */}
          <div className="flex flex-col items-end leading-tight text-right">
            <span className="text-[10px] font-bold text-emerald-400">
              Сыгранность: <strong className="text-white text-xs">{teamChemistry} / 33</strong>
            </span>
            <span className="text-[10px] font-bold text-amber-400">
              Сила: <strong className="text-white text-xs">{avgRating} OVR</strong>
            </span>
          </div>

          {/* Formation Picker Button */}
          <button
            type="button"
            onClick={() => setIsChoosingFormation(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-gradient-to-r from-emerald-800 to-teal-900 border border-emerald-400/40 text-xs font-black text-emerald-200 cursor-pointer hover:brightness-110 shadow-md"
          >
            Схема: {formationName}
            <ChevronDown className="w-3.5 h-3.5" />
          </button>
        </div>
      </header>

      {/* Main Pitch Content */}
      <main className="flex-1 flex flex-col items-center p-3 max-w-3xl mx-auto w-full">
        {/* Tactical Pitch with Starting 11 */}
        <div className="w-full mb-4">
          <PitchView
            formation={activeFormation}
            lineup={startingLineup}
            onSlotClick={handleSlotClick}
            selectedSlotIndex={selectedSlotIndex}
          />
        </div>

        {/* Substitutes / Bench Section */}
        <div className="w-full rounded-2xl bg-[#090e1a] border border-amber-500/30 p-3 shadow-lg">
          <div className="flex items-center justify-between mb-2 px-1">
            <div className="flex items-center gap-2">
              <span className="text-xs font-black text-amber-300 uppercase tracking-wider">
                Запасные ({substitutes.length})
              </span>
            </div>
            <button
              type="button"
              onClick={() => setIsSelectingPlayerForSub(true)}
              className="flex items-center gap-1 text-[11px] font-bold text-emerald-300 bg-emerald-950/70 hover:bg-emerald-900/80 px-2.5 py-1 rounded-lg border border-emerald-500/40 cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" />
              В запас
            </button>
          </div>

          <div className="flex items-center gap-2 overflow-x-auto pb-2 pt-1 px-1">
            {substitutes.length === 0 ? (
              <div className="text-xs text-slate-500 italic py-4 text-center w-full">
                Запасные отсутствуют. Нажмите «В запас», чтобы добавить игроков.
              </div>
            ) : (
              substitutes.map((player) => (
                <div key={player.id} className="relative group shrink-0">
                  <CardUI
                    card={player}
                    size="sm"
                    onClick={() => onViewPlayerDetails(player)}
                  />
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      handleRemoveFromSubs(player);
                    }}
                    className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-red-600 text-white flex items-center justify-center text-xs opacity-80 hover:opacity-100 cursor-pointer shadow-md"
                    title="Удалить из запаса"
                  >
                    ×
                  </button>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Action Popup for Slot Player (Replace, Remove, Details) */}
        {activeCardActionSlot !== null && startingLineup[activeCardActionSlot] && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-xs">
            <div className="w-full max-w-xs p-5 rounded-3xl bg-[#090d18] border-2 border-amber-400/50 shadow-2xl flex flex-col items-center">
              <div className="text-center mb-4">
                <span className="text-[10px] text-amber-400 font-bold uppercase block mb-1">
                  Слот {activeCardActionSlot + 1} • {activeFormation.slots[activeCardActionSlot]?.position}
                </span>
                <h4 className="text-base font-black text-white">
                  {startingLineup[activeCardActionSlot]?.player_name}
                </h4>
                <span className="text-xs text-slate-400">
                  {startingLineup[activeCardActionSlot]?.rating} OVR • {startingLineup[activeCardActionSlot]?.club}
                </span>
              </div>

              <div className="flex flex-col gap-2 w-full">
                <button
                  type="button"
                  onClick={() => {
                    const slot = activeCardActionSlot;
                    setActiveCardActionSlot(null);
                    setIsSelectingPlayerForSlot(slot);
                  }}
                  className="w-full py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-black text-xs flex items-center justify-center gap-1.5 shadow cursor-pointer"
                >
                  <ArrowUpDown className="w-4 h-4" />
                  🔄 Заменить игрока
                </button>

                <button
                  type="button"
                  onClick={() => {
                    const card = startingLineup[activeCardActionSlot];
                    if (card) {
                      setActiveCardActionSlot(null);
                      onViewPlayerDetails(card);
                    }
                  }}
                  className="w-full py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 font-bold text-xs flex items-center justify-center gap-1.5 cursor-pointer"
                >
                  <Info className="w-4 h-4" />
                  ℹ️ Подробнее
                </button>

                <button
                  type="button"
                  onClick={() => handleRemoveFromLineup(activeCardActionSlot)}
                  className="w-full py-2.5 rounded-xl bg-rose-900/80 hover:bg-rose-800 text-rose-200 font-bold text-xs flex items-center justify-center gap-1.5 cursor-pointer"
                >
                  <Trash2 className="w-4 h-4" />
                  ❌ Убрать из состава
                </button>

                <button
                  type="button"
                  onClick={() => setActiveCardActionSlot(null)}
                  className="w-full py-2 rounded-xl bg-slate-900 text-slate-400 font-semibold text-xs mt-1 hover:text-white cursor-pointer"
                >
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Player Selector Modal for Slot or Bench */}
        {(isSelectingPlayerForSlot !== null || isSelectingPlayerForSub) && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
            <div className="w-full max-w-3xl max-h-[85vh] p-5 rounded-3xl bg-[#090d18] border-2 border-amber-400/40 shadow-2xl flex flex-col">
              <div className="flex items-center justify-between pb-3 border-b border-white/10 mb-4">
                <div>
                  <h3 className="text-lg font-black text-white">ВЫБЕРИТЕ ИГРОКА</h3>
                  <span className="text-xs text-slate-400">
                    {isSelectingPlayerForSlot !== null
                      ? `Для позиции: ${activeFormation.slots[isSelectingPlayerForSlot]?.position}`
                      : 'Добавление в запас'}
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    setIsSelectingPlayerForSlot(null);
                    setIsSelectingPlayerForSub(false);
                  }}
                  className="text-slate-400 hover:text-white text-sm font-bold bg-slate-800 px-3 py-1.5 rounded-xl cursor-pointer"
                >
                  Закрыть
                </button>
              </div>

              <div className="flex-1 overflow-y-auto pr-1">
                {availablePlayersForSlot.length === 0 ? (
                  <div className="text-center py-12 text-slate-400">
                    В вашем клубе пока нет игроков. Откройте пак в магазине!
                  </div>
                ) : (
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    {availablePlayersForSlot.map((player) => (
                      <div key={player.id} className="flex justify-center">
                        <CardUI
                          card={player}
                          size="sm"
                          onClick={() => {
                            if (isSelectingPlayerForSlot !== null) {
                              handleAssignPlayerToSlot(player);
                            } else if (isSelectingPlayerForSub) {
                              handleAddPlayerToSubs(player);
                            }
                          }}
                        />
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Formation Selection Overlay */}
        {isChoosingFormation && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
            <div className="w-full max-w-xl p-6 rounded-3xl bg-[#090d18] border-2 border-amber-400/40 shadow-2xl flex flex-col items-center">
              <h3 className="text-xl font-black text-amber-300 mb-1">ВЫБЕРИТЕ СХЕМУ</h3>
              <p className="text-xs text-slate-400 mb-5">
                Смена схемы изменит расположение позиций игроков на поле
              </p>

              <div className="grid grid-cols-3 sm:grid-cols-4 gap-2.5 w-full mb-6">
                {Object.keys(FORMATIONS).map((formName) => (
                  <button
                    key={formName}
                    type="button"
                    onClick={() => {
                      onUpdateFormation(formName);
                      setIsChoosingFormation(false);
                    }}
                    className={`py-3 px-2 rounded-xl text-xs font-black border transition-all cursor-pointer ${
                      formationName === formName
                        ? 'bg-amber-500/25 border-amber-400 text-amber-200 shadow-md'
                        : 'bg-slate-900 border-slate-700 text-slate-300 hover:bg-slate-800'
                    }`}
                  >
                    {formName}
                  </button>
                ))}
              </div>

              <button
                type="button"
                onClick={() => setIsChoosingFormation(false)}
                className="text-xs font-bold text-slate-400 hover:text-white bg-slate-800 px-4 py-2 rounded-xl border border-slate-700 cursor-pointer"
              >
                Закрыть
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
