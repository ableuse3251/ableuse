import React from 'react';
import { PlayerCard } from '../types';
import { Settings, Shield, Trophy, Users, Sparkles, ShoppingBag, Play } from 'lucide-react';

interface HomeScreenProps {
  coins: number;
  clubCards: PlayerCard[];
  startingLineup: (PlayerCard | null)[];
  onNavigate: (screen: 'home' | 'club' | 'squad' | 'draft' | 'store' | 'match') => void;
  onOpenSettings: () => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  coins,
  clubCards,
  startingLineup,
  onNavigate,
  onOpenSettings,
}) => {
  // Calculate average rating of starting lineup or club
  const validLineup = startingLineup.filter((p): p is PlayerCard => p !== null);
  const avgRating =
    validLineup.length > 0
      ? Math.round(validLineup.reduce((acc, p) => acc + p.rating, 0) / validLineup.length)
      : clubCards.length > 0
      ? Math.round(clubCards.reduce((acc, p) => acc + p.rating, 0) / clubCards.length)
      : 75;

  const isReadyForMatch = validLineup.length >= 11;

  return (
    <div className="flex flex-col min-h-screen bg-[#030712] text-slate-100 select-none pb-24">
      {/* Top Header Bar */}
      <header className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-[#0a0f1d]/95 backdrop-blur-md border-b border-amber-500/20 shadow-lg">
        <div className="flex items-center gap-2.5">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-amber-500 to-yellow-300 flex items-center justify-center text-slate-950 font-black text-xl shadow-[0_0_12px_rgba(245,158,11,0.4)]">
            ⚽
          </div>
          <div>
            <h1 className="text-lg font-black tracking-wider text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-yellow-200 to-amber-400">
              FC DRAFT
            </h1>
            <span className="text-[10px] font-semibold text-slate-400 uppercase tracking-widest block">
              Ultimate Team 2027
            </span>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {/* Coins Badge */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-slate-900/90 border border-amber-400/30 text-amber-300 shadow-inner">
            <span className="text-base">🪙</span>
            <span className="font-black text-sm tracking-wide">{coins.toLocaleString()}</span>
          </div>

          {/* Settings Button */}
          <button
            type="button"
            onClick={onOpenSettings}
            className="w-10 h-10 rounded-xl bg-slate-800/80 hover:bg-slate-700/80 border border-slate-700 flex items-center justify-center text-slate-300 hover:text-white transition-all cursor-pointer"
            title="Настройки"
          >
            <Settings className="w-5 h-5" />
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col items-center justify-center px-4 py-6 max-w-xl mx-auto w-full">
        {/* Center Club Emblem Card */}
        <div className="w-full relative rounded-3xl p-6 bg-gradient-to-b from-[#0f172a] via-[#090d16] to-[#04070e] border-2 border-amber-400/40 shadow-[0_10px_35px_rgba(0,0,0,0.8)] overflow-hidden">
          {/* Subtle glowing ambient circles */}
          <div className="absolute -top-16 -right-16 w-44 h-44 rounded-full bg-amber-500/10 blur-3xl pointer-events-none" />
          <div className="absolute -bottom-16 -left-16 w-44 h-44 rounded-full bg-emerald-500/10 blur-3xl pointer-events-none" />

          <div className="relative flex flex-col items-center text-center">
            {/* Club Trophy Emblem */}
            <div className="relative mb-3">
              <div className="w-24 h-24 rounded-2xl bg-gradient-to-b from-amber-400/20 to-yellow-600/5 border-2 border-amber-400/50 flex items-center justify-center text-5xl shadow-[0_0_25px_rgba(251,191,36,0.25)]">
                🏆
              </div>
              <div className="absolute -bottom-2 -right-2 bg-emerald-600 text-[10px] font-black px-2 py-0.5 rounded-full border border-emerald-300 text-white shadow-md">
                LVL 1
              </div>
            </div>

            <h2 className="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-amber-200 via-yellow-300 to-amber-400 tracking-wide mb-1">
              FC DRAFT CLUB
            </h2>
            <p className="text-xs text-slate-400 font-medium mb-5">
              Основан в 2027 • Футбольный клуб
            </p>

            {/* Club Statistics Grid */}
            <div className="grid grid-cols-2 gap-3 w-full mb-5">
              <div className="bg-slate-900/70 border border-white/5 rounded-2xl p-3 flex flex-col items-center">
                <span className="text-xs text-slate-400 font-semibold mb-1">Рейтинг клуба</span>
                <span className="text-2xl font-black text-amber-300">{avgRating}</span>
                <span className="text-[10px] text-slate-500">Сила состава</span>
              </div>
              <div className="bg-slate-900/70 border border-white/5 rounded-2xl p-3 flex flex-col items-center">
                <span className="text-xs text-slate-400 font-semibold mb-1">В коллекции</span>
                <span className="text-2xl font-black text-sky-300">{clubCards.length}</span>
                <span className="text-[10px] text-slate-500">Футболистов</span>
              </div>
            </div>

            {/* Status indicator */}
            <div className="w-full flex items-center justify-between px-4 py-2.5 rounded-xl bg-slate-900/60 border border-white/5 mb-4">
              <div className="flex items-center gap-2">
                <div
                  className={`w-2.5 h-2.5 rounded-full ${
                    isReadyForMatch ? 'bg-emerald-400 shadow-[0_0_8px_#34d399]' : 'bg-amber-400'
                  }`}
                />
                <span className="text-xs font-bold text-slate-300">
                  {isReadyForMatch ? 'Готов к матчу (11/11)' : `В старте: ${validLineup.length}/11`}
                </span>
              </div>
              <button
                type="button"
                onClick={() => onNavigate('squad')}
                className="text-xs text-amber-400 hover:text-amber-300 font-bold hover:underline cursor-pointer"
              >
                Настроить →
              </button>
            </div>

            {/* Main Action buttons */}
            <div className="grid grid-cols-2 gap-3 w-full">
              <button
                type="button"
                onClick={() => onNavigate('draft')}
                className="py-3 px-4 rounded-xl bg-gradient-to-r from-amber-600 to-amber-500 hover:from-amber-500 hover:to-amber-400 text-slate-950 font-black text-sm flex items-center justify-center gap-2 shadow-[0_4px_15px_rgba(245,158,11,0.3)] transition-all cursor-pointer active:scale-95"
              >
                <Sparkles className="w-4 h-4" />
                НАЧАТЬ ДРАФТ
              </button>
              <button
                type="button"
                onClick={() => onNavigate('match')}
                className="py-3 px-4 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-500 hover:from-emerald-500 hover:to-teal-400 text-white font-black text-sm flex items-center justify-center gap-2 shadow-[0_4px_15px_rgba(16,185,129,0.3)] transition-all cursor-pointer active:scale-95"
              >
                <Play className="w-4 h-4 fill-white" />
                СЫГРАТЬ МАТЧ
              </button>
            </div>
          </div>
        </div>

        {/* Store promo banner */}
        <div
          onClick={() => onNavigate('store')}
          className="w-full mt-4 p-4 rounded-2xl bg-gradient-to-r from-yellow-950/40 via-amber-900/30 to-slate-900/60 border border-yellow-500/30 flex items-center justify-between cursor-pointer hover:border-yellow-400/60 transition-all shadow-md group"
        >
          <div className="flex items-center gap-3">
            <span className="text-3xl group-hover:scale-110 transition-transform">📦</span>
            <div>
              <div className="text-sm font-black text-yellow-300">ЗОЛОТОЙ ПАК В МАГАЗИНЕ</div>
              <div className="text-xs text-slate-400">Открывай паки за 500 монет и улучшай клуб</div>
            </div>
          </div>
          <span className="text-xs font-bold text-amber-300 bg-amber-500/20 px-3 py-1.5 rounded-lg border border-amber-400/30">
            500 🪙
          </span>
        </div>
      </main>

      {/* Bottom Navigation Bar */}
      <nav className="fixed bottom-0 left-0 right-0 z-30 bg-[#080d19]/95 backdrop-blur-md border-t border-amber-500/30 px-3 py-2 shadow-2xl">
        <div className="max-w-md mx-auto grid grid-cols-5 gap-1.5">
          <button
            type="button"
            onClick={() => onNavigate('club')}
            className="flex flex-col items-center justify-center py-1.5 px-1 rounded-xl hover:bg-slate-800/60 text-slate-400 hover:text-amber-300 transition-all cursor-pointer"
          >
            <Shield className="w-5 h-5 mb-1" />
            <span className="text-[10px] font-bold">Коллекция</span>
          </button>

          <button
            type="button"
            onClick={() => onNavigate('squad')}
            className="flex flex-col items-center justify-center py-1.5 px-1 rounded-xl hover:bg-slate-800/60 text-slate-400 hover:text-amber-300 transition-all cursor-pointer"
          >
            <Users className="w-5 h-5 mb-1" />
            <span className="text-[10px] font-bold">Мой состав</span>
          </button>

          <button
            type="button"
            onClick={() => onNavigate('draft')}
            className="flex flex-col items-center justify-center py-1.5 px-1 rounded-xl bg-amber-500/15 border border-amber-400/40 text-amber-300 transition-all cursor-pointer shadow-inner"
          >
            <Sparkles className="w-5 h-5 mb-1" />
            <span className="text-[10px] font-black">Драфт</span>
          </button>

          <button
            type="button"
            onClick={() => onNavigate('store')}
            className="flex flex-col items-center justify-center py-1.5 px-1 rounded-xl hover:bg-slate-800/60 text-slate-400 hover:text-amber-300 transition-all cursor-pointer"
          >
            <ShoppingBag className="w-5 h-5 mb-1" />
            <span className="text-[10px] font-bold">Магазин</span>
          </button>

          <button
            type="button"
            onClick={() => onNavigate('match')}
            className="flex flex-col items-center justify-center py-1.5 px-1 rounded-xl hover:bg-slate-800/60 text-slate-400 hover:text-emerald-400 transition-all cursor-pointer"
          >
            <Trophy className="w-5 h-5 mb-1" />
            <span className="text-[10px] font-bold">Матч</span>
          </button>
        </div>
      </nav>
    </div>
  );
};
