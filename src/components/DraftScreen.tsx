import React, { useState } from 'react';
import { Formation, PlayerCard, PositionCategory } from '../types';
import { FORMATIONS } from '../data/formationsData';
import { generateDraftChoices } from '../services/storage';
import { calculateTeamChemistry } from '../services/chemistry';
import { PitchView } from './PitchView';
import { CardUI } from './CardUI';
import { ArrowLeft, Sparkles, Trophy, CheckCircle2, RotateCcw } from 'lucide-react';
import confetti from 'canvas-confetti';

interface DraftScreenProps {
  coins: number;
  onFinishDraft: (draftLineup: PlayerCard[], formationName: string) => void;
  onBack: () => void;
}

export const DraftScreen: React.FC<DraftScreenProps> = ({
  coins,
  onFinishDraft,
  onBack,
}) => {
  // Formation choice state (if not chosen yet)
  const [selectedFormationName, setSelectedFormationName] = useState<string>('4-4-2');
  const [isChoosingFormation, setIsChoosingFormation] = useState<boolean>(true);

  // Draft lineup (11 slots)
  const [draftLineup, setDraftLineup] = useState<(PlayerCard | null)[]>(
    new Array(11).fill(null)
  );

  // Active slot choice modal
  const [activeSlotIndex, setActiveSlotIndex] = useState<number | null>(null);
  const [draftChoices, setDraftChoices] = useState<PlayerCard[]>([]);
  const [draftCompleted, setDraftCompleted] = useState<boolean>(false);

  const activeFormation = FORMATIONS[selectedFormationName] || FORMATIONS['4-4-2'];
  const teamChemistry = calculateTeamChemistry(draftLineup);

  const handleStartWithFormation = (formationName: string) => {
    setSelectedFormationName(formationName);
    setIsChoosingFormation(false);
    setDraftLineup(new Array(11).fill(null));
  };

  const handleSlotClick = (slotIndex: number) => {
    if (draftLineup[slotIndex]) return; // Already picked for this slot

    const slot = activeFormation.slots[slotIndex];
    let posCategory: PositionCategory = 'MID';
    const pos = (slot.position || '').toUpperCase();
    if (pos.includes('GK')) posCategory = 'GK';
    else if (pos.includes('DEF') || pos.includes('CB') || pos.includes('LB') || pos.includes('RB')) posCategory = 'DEF';
    else if (pos.includes('FWD') || pos.includes('ST') || pos.includes('LW') || pos.includes('RW') || pos.includes('CF')) posCategory = 'FWD';
    else posCategory = 'MID';

    const choices = generateDraftChoices(posCategory, 5);
    setActiveSlotIndex(slotIndex);
    setDraftChoices(choices);
  };

  const handleSelectPlayer = (player: PlayerCard) => {
    if (activeSlotIndex === null) return;

    const newLineup = [...draftLineup];
    newLineup[activeSlotIndex] = player;
    setDraftLineup(newLineup);
    setActiveSlotIndex(null);
    setDraftChoices([]);

    // Check if draft is finished
    const filledCount = newLineup.filter((p) => p !== null).length;
    if (filledCount >= activeFormation.slots.length) {
      setDraftCompleted(true);
      confetti({
        particleCount: 80,
        spread: 70,
        origin: { y: 0.6 },
      });
    }
  };

  const handleCompleteDraft = () => {
    const validCards = draftLineup.filter((p): p is PlayerCard => p !== null);
    onFinishDraft(validCards, selectedFormationName);
  };

  const handleResetDraft = () => {
    setIsChoosingFormation(true);
    setDraftLineup(new Array(11).fill(null));
    setDraftCompleted(false);
    setActiveSlotIndex(null);
  };

  return (
    <div className="flex flex-col min-h-screen bg-[#030712] text-slate-100 select-none pb-12">
      {/* Top Header Bar */}
      <header className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-[#0a0f1d]/95 backdrop-blur-md border-b border-amber-500/20 shadow-lg">
        <button
          type="button"
          onClick={onBack}
          className="flex items-center gap-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800/80 px-3 py-1.5 rounded-xl border border-slate-700 cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          В меню
        </button>

        <div className="flex items-center gap-4">
          {/* Chemistry Counter */}
          <div className="flex items-center gap-1.5 bg-slate-900/90 px-3 py-1 rounded-xl border border-emerald-500/30">
            <span className="text-xs font-bold text-emerald-400">Сыгранность:</span>
            <span className="text-sm font-black text-emerald-300">
              {teamChemistry} / 33
            </span>
          </div>

          {/* Scheme / Formation Badge */}
          <div className="hidden sm:flex items-center gap-1.5 bg-slate-900/90 px-3 py-1 rounded-xl border border-amber-500/30">
            <span className="text-xs font-bold text-slate-400">Схема:</span>
            <span className="text-xs font-black text-amber-300">{selectedFormationName}</span>
          </div>

          {/* Coins */}
          <div className="flex items-center gap-1 text-sm font-black text-amber-300 bg-slate-900/80 px-2.5 py-1 rounded-xl border border-white/5">
            🪙 {coins.toLocaleString()}
          </div>
        </div>
      </header>

      {/* Main Drafting Area */}
      <main className="flex-1 flex flex-col items-center p-4 max-w-4xl mx-auto w-full">
        {/* Step 1: Formation Selection Modal */}
        {isChoosingFormation ? (
          <div className="w-full max-w-xl my-auto p-6 rounded-3xl bg-[#0a0f1e] border-2 border-amber-400/40 shadow-2xl flex flex-col items-center text-center">
            <div className="w-16 h-16 rounded-2xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-3xl mb-3">
              🎯
            </div>
            <h2 className="text-2xl font-black text-amber-300 tracking-wide mb-1">
              ВЫБЕРИТЕ СХЕМУ ДРАФТА
            </h2>
            <p className="text-xs text-slate-400 mb-6">
              Тактическая схема определяет позиции ваших 11 игроков на футбольном поле.
            </p>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 w-full mb-6">
              {Object.keys(FORMATIONS).map((formName) => (
                <button
                  key={formName}
                  type="button"
                  onClick={() => handleStartWithFormation(formName)}
                  className={`py-3.5 px-3 rounded-2xl border text-sm font-black transition-all cursor-pointer ${
                    selectedFormationName === formName
                      ? 'bg-amber-500/25 border-amber-400 text-amber-200 shadow-[0_0_15px_rgba(245,158,11,0.3)]'
                      : 'bg-slate-900/80 border-slate-700 text-slate-300 hover:border-amber-400/50 hover:bg-slate-800'
                  }`}
                >
                  {formName}
                </button>
              ))}
            </div>

            <button
              type="button"
              onClick={() => handleStartWithFormation(selectedFormationName)}
              className="w-full py-3.5 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-slate-950 font-black text-sm tracking-wider shadow-lg hover:brightness-110 active:scale-98 transition-all cursor-pointer"
            >
              ПОДТВЕРДИТЬ СХЕМУ {selectedFormationName}
            </button>
          </div>
        ) : (
          <div className="w-full flex flex-col items-center">
            {/* Draft Controls Subbar */}
            <div className="w-full flex items-center justify-between mb-3 px-1">
              <div className="flex items-center gap-2">
                <span className="text-xs font-semibold text-slate-400">
                  Выбрано игроков:
                </span>
                <span className="text-xs font-black text-amber-300">
                  {draftLineup.filter((p) => p !== null).length} / 11
                </span>
              </div>

              <button
                type="button"
                onClick={handleResetDraft}
                className="flex items-center gap-1 text-[11px] font-bold text-slate-400 hover:text-white bg-slate-900/80 px-2.5 py-1 rounded-lg border border-slate-700 cursor-pointer"
              >
                <RotateCcw className="w-3.5 h-3.5" />
                Сбросить драфт
              </button>
            </div>

            {/* Tactical Pitch with Draft Slots */}
            <PitchView
              formation={activeFormation}
              lineup={draftLineup}
              onSlotClick={handleSlotClick}
              selectedSlotIndex={activeSlotIndex}
            />
          </div>
        )}

        {/* Player Draft Choice Modal (5 Options) */}
        {activeSlotIndex !== null && draftChoices.length > 0 && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md">
            <div className="relative w-full max-w-4xl p-6 rounded-3xl bg-[#090d18] border-2 border-amber-400/50 shadow-2xl flex flex-col items-center">
              <div className="text-center mb-5">
                <div className="inline-block px-3 py-1 rounded-full bg-amber-500/20 border border-amber-400/40 text-amber-300 text-xs font-black uppercase mb-1">
                  ПОЗИЦИЯ: {activeFormation.slots[activeSlotIndex]?.position} (СЛОТ {activeSlotIndex + 1})
                </div>
                <h3 className="text-xl font-black text-white">ВЫБЕРИТЕ ИГРОКА</h3>
                <p className="text-xs text-slate-400">
                  Оценивайте рейтинг, сыгранность (клуб, лига, нация) и характеристики
                </p>
              </div>

              {/* 5 Cards Row */}
              <div className="flex flex-wrap items-center justify-center gap-4 w-full mb-6">
                {draftChoices.map((card) => (
                  <div key={card.id} className="transition-transform hover:scale-105">
                    <CardUI card={card} size="md" onClick={() => handleSelectPlayer(card)} />
                  </div>
                ))}
              </div>

              <button
                type="button"
                onClick={() => setActiveSlotIndex(null)}
                className="text-xs font-bold text-slate-400 hover:text-white bg-slate-800 px-4 py-2 rounded-xl border border-slate-700 cursor-pointer"
              >
                Отмена
              </button>
            </div>
          </div>
        )}

        {/* Draft Completed Congratulation Modal */}
        {draftCompleted && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
            <div className="w-full max-w-md p-6 rounded-3xl bg-gradient-to-b from-[#0f172a] to-[#050811] border-2 border-emerald-400 shadow-2xl flex flex-col items-center text-center">
              <div className="w-20 h-20 rounded-full bg-emerald-500/20 border-2 border-emerald-400 flex items-center justify-center text-4xl mb-4">
                🎉
              </div>
              <h3 className="text-2xl font-black text-emerald-300 mb-1">ДРАФТ ЗАВЕРШЁН!</h3>
              <p className="text-xs text-slate-300 mb-4">
                Команда сформирована! 11 игроков готовы к выходу на поле и добавлены в твой клуб.
              </p>

              <div className="w-full bg-slate-900/80 border border-white/5 rounded-2xl p-4 mb-6 text-left space-y-2">
                <div className="flex justify-between items-center text-xs">
                  <span className="text-slate-400 font-semibold">Схема:</span>
                  <span className="font-bold text-amber-300">{selectedFormationName}</span>
                </div>
                <div className="flex justify-between items-center text-xs">
                  <span className="text-slate-400 font-semibold">Итоговая сыгранность:</span>
                  <span className="font-bold text-emerald-300">{teamChemistry} / 33</span>
                </div>
                <div className="flex justify-between items-center text-xs">
                  <span className="text-slate-400 font-semibold">Средний рейтинг:</span>
                  <span className="font-bold text-white">
                    {Math.round(
                      draftLineup.filter((p): p is PlayerCard => p !== null).reduce((a, b) => a + b.rating, 0) / 11
                    )} OVR
                  </span>
                </div>
              </div>

              <div className="flex flex-col gap-2.5 w-full">
                <button
                  type="button"
                  onClick={handleCompleteDraft}
                  className="w-full py-3.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 text-slate-950 font-black text-sm tracking-wide shadow-lg hover:brightness-110 active:scale-98 cursor-pointer"
                >
                  СОХРАНИТЬ И СЫГРАТЬ МАТЧ →
                </button>
                <button
                  type="button"
                  onClick={onBack}
                  className="w-full py-2.5 rounded-xl bg-slate-800 text-slate-300 font-bold text-xs hover:bg-slate-700 cursor-pointer"
                >
                  Вернуться в главное меню
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
