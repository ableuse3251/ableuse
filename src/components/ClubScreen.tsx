import React, { useState } from 'react';
import { PlayerCard, PositionCategory } from '../types';
import { CardUI } from './CardUI';
import { ArrowLeft, Search, Filter } from 'lucide-react';

interface ClubScreenProps {
  clubCards: PlayerCard[];
  onViewPlayerDetails: (player: PlayerCard) => void;
  onNavigateToStore: () => void;
  onBack: () => void;
}

export const ClubScreen: React.FC<ClubScreenProps> = ({
  clubCards,
  onViewPlayerDetails,
  onNavigateToStore,
  onBack,
}) => {
  const [filterPosition, setFilterPosition] = useState<string>('ALL');
  const [filterRarity, setFilterRarity] = useState<string>('ALL');
  const [searchQuery, setSearchQuery] = useState<string>('');

  const filteredCards = clubCards.filter((card) => {
    if (filterPosition !== 'ALL' && card.position !== filterPosition) {
      return false;
    }
    if (filterRarity !== 'ALL' && card.rarity !== filterRarity) {
      return false;
    }
    if (searchQuery.trim() !== '') {
      const q = searchQuery.toLowerCase();
      const name = (card.player_name || '').toLowerCase();
      const club = (card.club || '').toLowerCase();
      const nation = (card.nation || '').toLowerCase();
      return name.includes(q) || club.includes(q) || nation.includes(q);
    }
    return true;
  });

  return (
    <div className="flex flex-col min-h-screen bg-[#030712] text-slate-100 select-none pb-12">
      {/* Top Header Bar */}
      <header className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-[#0a0f1d]/95 backdrop-blur-md border-b border-amber-500/20 shadow-lg">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onBack}
            className="flex items-center gap-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800/80 px-3 py-1.5 rounded-xl border border-slate-700 cursor-pointer"
          >
            <ArrowLeft className="w-4 h-4" />
            Домой
          </button>
          <h2 className="text-lg font-black tracking-wider text-amber-300">МОЯ КОЛЛЕКЦИЯ</h2>
        </div>

        <div className="text-xs font-bold text-slate-400">
          Игроков: <span className="text-amber-300 font-black">{clubCards.length}</span>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex flex-col p-4 max-w-5xl mx-auto w-full">
        {/* Filter Controls Bar */}
        <div className="flex flex-col sm:flex-row gap-2.5 mb-6">
          {/* Search Box */}
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Поиск игрока, клуба или страны..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-9 pr-3 py-2 text-xs text-white placeholder-slate-500 focus:outline-hidden focus:border-amber-400"
            />
          </div>

          {/* Position Filter Tabs */}
          <div className="flex items-center gap-1 bg-slate-900/90 p-1 rounded-xl border border-slate-800 overflow-x-auto">
            {['ALL', 'FWD', 'MID', 'DEF', 'GK'].map((pos) => (
              <button
                key={pos}
                type="button"
                onClick={() => setFilterPosition(pos)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                  filterPosition === pos
                    ? 'bg-amber-500 text-slate-950 font-black shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {pos === 'ALL' ? 'Все' : pos}
              </button>
            ))}
          </div>

          {/* Rarity Filter */}
          <div className="flex items-center gap-1 bg-slate-900/90 p-1 rounded-xl border border-slate-800">
            {['ALL', 'ELITE', 'GOLD', 'SILVER', 'BRONZE'].map((rarity) => (
              <button
                key={rarity}
                type="button"
                onClick={() => setFilterRarity(rarity)}
                className={`px-2 py-1.5 rounded-lg text-[10px] font-black transition-all cursor-pointer ${
                  filterRarity === rarity
                    ? 'bg-amber-400/30 text-amber-200 border border-amber-400/50'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {rarity === 'ALL' ? 'Редкость' : rarity}
              </button>
            ))}
          </div>
        </div>

        {/* Card Grid */}
        {filteredCards.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center p-8 text-center my-auto">
            <span className="text-5xl mb-3">📦</span>
            <h3 className="text-lg font-black text-white mb-1">Игроков не найдено</h3>
            <p className="text-xs text-slate-400 max-w-sm mb-4">
              {clubCards.length === 0
                ? 'В вашем клубе пока нет игроков. Откройте пак в магазине, чтобы получить первого футболиста!'
                : 'По выбранным фильтрам игроки не найдены. Попробуйте сбросить фильтры.'}
            </p>
            {clubCards.length === 0 && (
              <button
                type="button"
                onClick={onNavigateToStore}
                className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-slate-950 font-black text-xs shadow-lg hover:brightness-110 cursor-pointer"
              >
                Перейти в магазин →
              </button>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 justify-items-center">
            {filteredCards.map((card) => (
              <div key={card.id} className="transition-transform hover:scale-105">
                <CardUI
                  card={card}
                  size="md"
                  onClick={() => onViewPlayerDetails(card)}
                />
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
};
