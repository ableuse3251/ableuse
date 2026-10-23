import React, { useState } from 'react';
import { CardRarity, PlayerCard } from '../types';
import { openPack } from '../services/storage';
import { CardUI } from './CardUI';
import { ArrowLeft, Sparkles } from 'lucide-react';
import confetti from 'canvas-confetti';

interface StoreScreenProps {
  coins: number;
  onBuyPack: (cost: number, card: PlayerCard) => boolean;
  onBack: () => void;
}

const PACK_PRICE = 500;

export const StoreScreen: React.FC<StoreScreenProps> = ({
  coins,
  onBuyPack,
  onBack,
}) => {
  const [isOpening, setIsOpening] = useState<boolean>(false);
  const [revealedCard, setRevealedCard] = useState<PlayerCard | null>(null);
  const [revealedRarity, setRevealedRarity] = useState<CardRarity | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleOpenPack = () => {
    setErrorMessage(null);
    if (coins < PACK_PRICE) {
      setErrorMessage(`❌ Недостаточно монет! Нужно: ${PACK_PRICE} монет.`);
      return;
    }

    setIsOpening(true);
    setRevealedCard(null);

    // Dramatic opening sequence
    setTimeout(() => {
      const { card, rarity } = openPack();
      const success = onBuyPack(PACK_PRICE, card);

      if (success) {
        setRevealedCard(card);
        setRevealedRarity(rarity);

        // Confetti for good pulls!
        if (rarity === 'ELITE' || rarity === 'GOLD') {
          confetti({
            particleCount: rarity === 'ELITE' ? 120 : 60,
            spread: 80,
            origin: { y: 0.6 },
          });
        }
      } else {
        setErrorMessage('❌ Не удалось списать монеты.');
      }

      setIsOpening(false);
    }, 1200);
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
          Домой
        </button>

        <h2 className="text-lg font-black tracking-wider text-amber-300">МАГАЗИН ПАКОВ</h2>

        <div className="flex items-center gap-1 text-sm font-black text-amber-300 bg-slate-900/80 px-3 py-1.5 rounded-xl border border-amber-500/30">
          🪙 {coins.toLocaleString()} МОНЕТ
        </div>
      </header>

      {/* Main Pack Opening Area */}
      <main className="flex-1 flex flex-col items-center justify-center p-4 max-w-xl mx-auto w-full">
        {revealedCard ? (
          /* Revealed Card Display */
          <div className="w-full p-6 rounded-3xl bg-[#090e1a] border-2 border-amber-400/50 shadow-2xl flex flex-col items-center text-center animate-fade-in">
            <span className="text-sm font-black text-emerald-400 uppercase tracking-widest mb-1">
              🎉 ВЫ ВЫТАЩИЛИ ИГРОКА!
            </span>
            <div className="text-xs text-slate-400 mb-5">
              Редкость: <strong className="text-amber-300">{revealedCard.rarity}</strong>
            </div>

            <div className="mb-6 transform hover:scale-105 transition-transform">
              <CardUI card={revealedCard} size="lg" />
            </div>

            <div className="w-full bg-emerald-950/40 border border-emerald-500/30 rounded-xl p-3 mb-5 text-xs text-emerald-300 font-bold">
              ✅ Игрок добавлен в «Мой клуб»!
            </div>

            <div className="flex gap-3 w-full">
              <button
                type="button"
                onClick={handleOpenPack}
                disabled={coins < PACK_PRICE || isOpening}
                className="flex-1 py-3 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-slate-950 font-black text-xs uppercase shadow-lg hover:brightness-110 disabled:opacity-50 cursor-pointer"
              >
                Открыть ещё (500 🪙)
              </button>
              <button
                type="button"
                onClick={() => setRevealedCard(null)}
                className="py-3 px-5 rounded-xl bg-slate-800 text-slate-300 font-bold text-xs hover:text-white cursor-pointer"
              >
                К паку
              </button>
            </div>
          </div>
        ) : (
          /* Standard Gold Pack Stand */
          <div className="w-full p-6 rounded-3xl bg-gradient-to-b from-[#0f172a] via-[#090d16] to-[#04070e] border-2 border-amber-400/40 shadow-2xl flex flex-col items-center text-center">
            {/* Animated Pack Box */}
            <div className={`relative mb-4 ${isOpening ? 'animate-bounce' : ''}`}>
              <div className="w-32 h-44 rounded-2xl bg-gradient-to-b from-amber-500 via-yellow-600 to-amber-950 border-4 border-yellow-300 flex flex-col items-center justify-center p-3 shadow-[0_0_30px_rgba(245,158,11,0.35)] relative overflow-hidden group">
                {/* Pack foil shimmer */}
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full duration-1000 transition-transform" />
                <span className="text-5xl mb-2">📦</span>
                <span className="text-xs font-black text-slate-950 bg-yellow-300 px-2 py-0.5 rounded tracking-widest uppercase">
                  GOLD PACK
                </span>
                <span className="text-[10px] font-bold text-amber-200 mt-1">FC 2027</span>
              </div>
            </div>

            <h3 className="text-2xl font-black text-amber-300 mb-1">ЗОЛОТОЙ ПАК</h3>
            <p className="text-xs text-slate-300 mb-3">
              1 случайный игрок из базы мирового футбола
            </p>

            {/* Price Badge */}
            <div className="flex items-center gap-1.5 text-base font-black text-amber-400 bg-amber-500/15 border border-amber-400/30 px-4 py-1.5 rounded-full mb-4">
              💰 500 МОНЕТ
            </div>

            {/* Probabilities table */}
            <div className="w-full bg-slate-900/80 border border-white/5 rounded-2xl p-3 mb-5">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest block mb-2">
                ВЕРОЯТНОСТИ ВЫПАДЕНИЯ
              </span>
              <div className="grid grid-cols-4 gap-2 text-center text-xs">
                <div className="bg-amber-950/50 border border-amber-800/40 rounded-xl p-1.5">
                  <div className="text-[10px] font-bold text-amber-400">BRONZE</div>
                  <div className="font-black text-white">55%</div>
                </div>
                <div className="bg-slate-800/50 border border-slate-600/40 rounded-xl p-1.5">
                  <div className="text-[10px] font-bold text-slate-300">SILVER</div>
                  <div className="font-black text-white">30%</div>
                </div>
                <div className="bg-yellow-950/50 border border-yellow-600/40 rounded-xl p-1.5">
                  <div className="text-[10px] font-bold text-yellow-300">GOLD</div>
                  <div className="font-black text-white">12%</div>
                </div>
                <div className="bg-indigo-950/50 border border-cyan-500/40 rounded-xl p-1.5">
                  <div className="text-[10px] font-bold text-cyan-300">ELITE</div>
                  <div className="font-black text-white">3%</div>
                </div>
              </div>
            </div>

            {errorMessage && (
              <div className="w-full text-xs text-rose-300 bg-rose-950/50 border border-rose-500/40 rounded-xl p-2.5 mb-4 font-bold">
                {errorMessage}
              </div>
            )}

            {/* Open Button */}
            <button
              type="button"
              onClick={handleOpenPack}
              disabled={isOpening}
              className={`w-full py-4 rounded-xl font-black text-sm uppercase tracking-wider flex items-center justify-center gap-2 shadow-lg transition-all cursor-pointer ${
                coins >= PACK_PRICE
                  ? 'bg-gradient-to-r from-amber-500 via-yellow-400 to-amber-500 text-slate-950 hover:brightness-110 active:scale-98 shadow-[0_4px_20px_rgba(245,158,11,0.4)]'
                  : 'bg-slate-800 text-slate-500 border border-slate-700 cursor-not-allowed'
              }`}
            >
              {isOpening ? (
                <>
                  <Sparkles className="w-4 h-4 animate-spin" />
                  ОТКРЫТИЕ ПАКА...
                </>
              ) : (
                <>
                  <span>📦</span>
                  ОТКРЫТЬ ПАК (500 🪙)
                </>
              )}
            </button>
          </div>
        )}
      </main>
    </div>
  );
};
