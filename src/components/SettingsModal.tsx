import React, { useState } from 'react';
import { X, Volume2, BookOpen, Trash2, AlertTriangle } from 'lucide-react';

interface SettingsModalProps {
  volume: number;
  onVolumeChange: (vol: number) => void;
  onReplayTutorial: () => void;
  onResetProgress: () => void;
  onClose: () => void;
}

export const SettingsModal: React.FC<SettingsModalProps> = ({
  volume,
  onVolumeChange,
  onReplayTutorial,
  onResetProgress,
  onClose,
}) => {
  const [confirmingReset, setConfirmingReset] = useState<boolean>(false);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm select-none">
      <div className="relative w-full max-w-md p-6 rounded-3xl bg-[#0a0f1d] border-2 border-amber-400/40 shadow-2xl flex flex-col">
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-4 right-4 w-9 h-9 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center cursor-pointer shadow-md"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header */}
        <div className="text-center mb-6">
          <h3 className="text-2xl font-black text-amber-300 tracking-wide mb-1">
            ⚙️ НАСТРОЙКИ
          </h3>
          <p className="text-xs text-slate-400">Настрой свой клуб под себя</p>
        </div>

        {confirmingReset ? (
          /* Reset confirmation dialog */
          <div className="w-full bg-rose-950/40 border-2 border-rose-500/50 rounded-2xl p-5 text-center flex flex-col items-center">
            <div className="w-14 h-14 rounded-full bg-rose-500/20 text-rose-400 flex items-center justify-center mb-3">
              <AlertTriangle className="w-8 h-8" />
            </div>
            <h4 className="text-base font-black text-rose-300 mb-2">СБРОСИТЬ ПРОГРЕСС?</h4>
            <p className="text-xs text-slate-300 mb-5 leading-relaxed">
              Все собранные игроки, стартовый состав, монеты и настройки будут удалены.
              Это действие невозможно отменить.
            </p>

            <div className="flex gap-3 w-full">
              <button
                type="button"
                onClick={() => setConfirmingReset(false)}
                className="flex-1 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold cursor-pointer"
              >
                Отмена
              </button>
              <button
                type="button"
                onClick={() => {
                  onResetProgress();
                  setConfirmingReset(false);
                  onClose();
                }}
                className="flex-1 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-500 text-white text-xs font-black cursor-pointer shadow-lg"
              >
                Сбросить
              </button>
            </div>
          </div>
        ) : (
          /* Normal settings options */
          <div className="space-y-4">
            {/* Volume control */}
            <div className="bg-slate-900/80 rounded-2xl p-4 border border-white/5">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2 text-sm font-bold text-white">
                  <Volume2 className="w-4 h-4 text-amber-400" />
                  <span>Громкость звука</span>
                </div>
                <span className="text-xs font-black text-amber-300">
                  {Math.round(volume * 100)}%
                </span>
              </div>
              <input
                type="range"
                min="0"
                max="1"
                step="0.05"
                value={volume}
                onChange={(e) => onVolumeChange(parseFloat(e.target.value))}
                className="w-full accent-amber-400 cursor-pointer"
              />
              <span className="text-[10px] text-slate-500 block mt-1">
                0% — выключить звук, 100% — максимум
              </span>
            </div>

            {/* Replay Tutorial */}
            <button
              type="button"
              onClick={() => {
                onClose();
                onReplayTutorial();
              }}
              className="w-full p-4 rounded-2xl bg-slate-900/80 hover:bg-slate-800/80 border border-white/5 flex items-center justify-between cursor-pointer transition-all"
            >
              <div className="flex items-center gap-2.5 text-left">
                <BookOpen className="w-4 h-4 text-sky-400" />
                <div>
                  <div className="text-xs font-black text-white">Повторить обучение</div>
                  <div className="text-[10px] text-slate-400">Покажет учебник игры заново</div>
                </div>
              </div>
              <span className="text-xs text-slate-400 font-bold">→</span>
            </button>

            {/* Reset progress dangerous zone */}
            <div className="pt-2">
              <button
                type="button"
                onClick={() => setConfirmingReset(true)}
                className="w-full p-3.5 rounded-2xl bg-rose-950/30 hover:bg-rose-950/50 border border-rose-500/40 text-rose-300 text-xs font-black flex items-center justify-center gap-2 cursor-pointer transition-all"
              >
                <Trash2 className="w-4 h-4" />
                🗑️ СБРОСИТЬ ВЕСЬ ПРОГРЕСС
              </button>
              <span className="text-[10px] text-slate-500 block text-center mt-1">
                Клуб, состав, монеты — всё будет удалено
              </span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
