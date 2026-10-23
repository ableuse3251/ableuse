import React, { useState, useEffect, useRef } from 'react';
import { MatchEvent, MatchSimulationResult, PlayerCard } from '../types';
import { simulateMatch } from '../services/matchSimulator';
import { ArrowLeft, Play, FastForward, Trophy, Users, ShieldAlert } from 'lucide-react';
import confetti from 'canvas-confetti';

interface MatchScreenProps {
  team: (PlayerCard | null)[];
  onRewardCoins: (amount: number) => void;
  onNavigateToSquad: () => void;
  onBack: () => void;
}

export const MatchScreen: React.FC<MatchScreenProps> = ({
  team,
  onRewardCoins,
  onNavigateToSquad,
  onBack,
}) => {
  const validPlayers = team.filter((p): p is PlayerCard => p !== null);
  const hasFullSquad = validPlayers.length >= 11;

  // Match simulation state
  const [matchResult, setMatchResult] = useState<MatchSimulationResult | null>(null);
  const [currentMinute, setCurrentMinute] = useState<number>(0);
  const [matchStarted, setMatchStarted] = useState<boolean>(false);
  const [matchFinished, setMatchFinished] = useState<boolean>(false);
  const [showingSummary, setShowingSummary] = useState<boolean>(false);
  const [homeScore, setHomeScore] = useState<number>(0);
  const [awayScore, setAwayScore] = useState<number>(0);
  const [activeEvent, setActiveEvent] = useState<MatchEvent | null>(null);
  const [pastEvents, setPastEvents] = useState<MatchEvent[]>([]);

  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Initialize match result when entering with 11 players
  useEffect(() => {
    if (hasFullSquad && !matchResult) {
      const res = simulateMatch(team, 80);
      setMatchResult(res);
    }
  }, [hasFullSquad, team, matchResult]);

  // Clean up timer on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, []);

  const handleStartMatch = (speedMs: number = 70) => {
    if (!matchResult || matchStarted) return;
    setMatchStarted(true);

    timerRef.current = setInterval(() => {
      setCurrentMinute((prevMinute) => {
        const nextMinute = prevMinute + 1;

        // Process any events occurring up to nextMinute
        const eventsUpToNow = matchResult.events.filter((e) => e.minute === nextMinute);
        if (eventsUpToNow.length > 0) {
          const lastEvent = eventsUpToNow[eventsUpToNow.length - 1];
          setActiveEvent(lastEvent);
          setPastEvents((prev) => [...prev, ...eventsUpToNow]);

          for (const ev of eventsUpToNow) {
            if (ev.type === 'goal') {
              if (ev.is_user) {
                setHomeScore((h) => h + 1);
              } else {
                setAwayScore((a) => a + 1);
              }
            }
          }
        }

        if (nextMinute >= 90) {
          if (timerRef.current) clearInterval(timerRef.current);
          setMatchFinished(true);
          // Award coins
          const won = matchResult.won;
          const draw = matchResult.draw;
          const reward = won ? 500 : draw ? 300 : 200;
          onRewardCoins(reward);

          if (won) {
            confetti({
              particleCount: 100,
              spread: 70,
              origin: { y: 0.6 },
            });
          }
          return 90;
        }

        return nextMinute;
      });
    }, speedMs);
  };

  const handleInstantFinish = () => {
    if (!matchResult) return;
    if (timerRef.current) clearInterval(timerRef.current);

    setCurrentMinute(90);
    setHomeScore(matchResult.user_goals);
    setAwayScore(matchResult.opponent_goals);
    setPastEvents(matchResult.events);
    setActiveEvent(matchResult.events[matchResult.events.length - 1] || null);
    setMatchFinished(true);

    const won = matchResult.won;
    const draw = matchResult.draw;
    const reward = won ? 500 : draw ? 300 : 200;
    onRewardCoins(reward);

    if (won) {
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
      });
    }
  };

  if (!hasFullSquad) {
    return (
      <div className="flex flex-col min-h-screen bg-[#030712] text-slate-100 items-center justify-center p-6 text-center select-none">
        <div className="w-24 h-24 rounded-full bg-amber-500/20 border-2 border-amber-400 flex items-center justify-center text-5xl mb-4 shadow-xl">
          ⚠️
        </div>
        <h2 className="text-2xl font-black text-amber-300 mb-2">СНАЧАЛА СОБЕРИ СОСТАВ!</h2>
        <p className="text-sm text-slate-400 max-w-sm mb-6">
          В вашем стартовом составе сейчас {validPlayers.length} из 11 игроков. Для участия в матче
          требуется полная команда из 11 футболистов.
        </p>

        <div className="flex flex-col sm:flex-row gap-3 w-full max-w-xs">
          <button
            type="button"
            onClick={onNavigateToSquad}
            className="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-500 text-white font-black text-sm flex items-center justify-center gap-2 shadow-lg cursor-pointer"
          >
            <Users className="w-4 h-4" />
            Мой состав
          </button>
          <button
            type="button"
            onClick={onBack}
            className="w-full py-3 px-4 rounded-xl bg-slate-800 text-slate-300 font-bold text-sm cursor-pointer hover:bg-slate-700"
          >
            В меню
          </button>
        </div>
      </div>
    );
  }

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

        <h2 className="text-lg font-black tracking-wider text-amber-300">MATCH DAY</h2>

        <div className="text-xs font-bold text-slate-400">
          Минута: <span className="text-emerald-400 font-black">{currentMinute}'</span>
        </div>
      </header>

      {/* Main Stadium Scoreboard */}
      <main className="flex-1 flex flex-col items-center p-4 max-w-2xl mx-auto w-full">
        {/* Scoreboard Panel */}
        <div className="w-full rounded-3xl p-6 bg-gradient-to-b from-[#0f172a] via-[#090e1a] to-[#04060d] border-2 border-amber-400/40 shadow-2xl mb-4">
          {/* Teams Header */}
          <div className="flex items-center justify-between text-center mb-4">
            <div className="flex-1 text-right pr-4">
              <span className="text-base font-black text-amber-300 block truncate">
                ВАША КОМАНДА
              </span>
              <span className="text-xs text-slate-400">
                Рейтинг: {matchResult?.avg_rating || 80}
              </span>
            </div>

            <div className="w-10 h-10 rounded-full bg-slate-800 border border-slate-600 flex items-center justify-center text-xs font-black text-slate-300">
              VS
            </div>

            <div className="flex-1 text-left pl-4">
              <span className="text-base font-black text-rose-300 block truncate">
                СОПЕРНИК
              </span>
              <span className="text-xs text-slate-400">
                Рейтинг: {matchResult?.opponent_strength || 80}
              </span>
            </div>
          </div>

          {/* Large Live Score Display */}
          <div className="flex items-center justify-center gap-6 py-4 my-2 border-y border-white/10 bg-black/30 rounded-2xl">
            <span className="text-6xl font-black text-white tracking-tighter drop-shadow-lg">
              {homeScore}
            </span>
            <span className="text-3xl font-black text-slate-500">:</span>
            <span className="text-6xl font-black text-white tracking-tighter drop-shadow-lg">
              {awayScore}
            </span>
          </div>

          {/* Time & Progress Bar */}
          <div className="mt-4">
            <div className="flex justify-between text-xs font-black mb-1.5">
              <span className="text-emerald-400">{currentMinute}'</span>
              <span className="text-slate-400">90'</span>
            </div>
            <div className="w-full h-2 rounded-full bg-slate-800 overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-emerald-500 to-teal-400 transition-all duration-100"
                style={{ width: `${(currentMinute / 90) * 100}%` }}
              />
            </div>
          </div>
        </div>

        {/* Live Match Commentary Box */}
        <div className="w-full rounded-2xl bg-[#090e1a] border border-white/10 p-4 mb-4 min-h-[100px] flex flex-col justify-center text-center shadow-lg">
          {matchFinished ? (
            <div className="animate-fade-in">
              <div className="text-xl font-black mb-1">
                {homeScore > awayScore ? (
                  <span className="text-emerald-400">🏆 ПОБЕДА! (+500 🪙)</span>
                ) : homeScore === awayScore ? (
                  <span className="text-amber-400">🤝 НИЧЬЯ (+300 🪙)</span>
                ) : (
                  <span className="text-rose-400">ПОРАЖЕНИЕ (+200 🪙)</span>
                )}
              </div>
              <p className="text-xs text-slate-400">Матч завершён. Награда начислена!</p>
            </div>
          ) : activeEvent ? (
            <div className="text-sm font-black text-slate-200 animate-pulse">
              {activeEvent.text}
            </div>
          ) : (
            <div className="text-xs text-slate-400">
              {matchStarted ? 'Следим за ходом матча...' : 'Команды готовы к выходу на поле.'}
            </div>
          )}
        </div>

        {/* Match Action Controls */}
        <div className="w-full flex gap-3 mb-6">
          {!matchStarted && (
            <button
              type="button"
              onClick={() => handleStartMatch(70)}
              className="flex-1 py-4 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-500 hover:from-emerald-500 hover:to-teal-400 text-white font-black text-sm uppercase tracking-wider flex items-center justify-center gap-2 shadow-lg cursor-pointer"
            >
              <Play className="w-4 h-4 fill-white" />
              НАЧАТЬ МАТЧ
            </button>
          )}

          {matchStarted && !matchFinished && (
            <>
              <button
                type="button"
                onClick={handleInstantFinish}
                className="flex-1 py-3.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-amber-300 font-black text-xs uppercase flex items-center justify-center gap-2 border border-amber-400/30 cursor-pointer"
              >
                <FastForward className="w-4 h-4" />
                БЫСТРЫЙ ИТОГ
              </button>
            </>
          )}

          {matchFinished && (
            <button
              type="button"
              onClick={() => setShowingSummary(!showingSummary)}
              className="flex-1 py-3.5 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-slate-950 font-black text-xs uppercase shadow-lg hover:brightness-110 cursor-pointer"
            >
              {showingSummary ? 'Скрыть итоги' : 'ПОДРОБНЫЕ ИТОГИ МАТЧА'}
            </button>
          )}
        </div>

        {/* Past Events / Timeline Log */}
        {pastEvents.length > 0 && (
          <div className="w-full rounded-2xl bg-slate-900/60 border border-white/5 p-4 max-h-64 overflow-y-auto">
            <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest mb-3">
              ХРОНОЛОГИЯ МАТЧА
            </h4>
            <div className="space-y-2">
              {[...pastEvents].reverse().map((ev, i) => (
                <div
                  key={i}
                  className={`flex items-center gap-2 text-xs p-2 rounded-xl ${
                    ev.type === 'goal'
                      ? 'bg-amber-500/15 border border-amber-400/30 text-amber-200'
                      : 'bg-black/20 text-slate-300'
                  }`}
                >
                  <span className="font-black text-slate-400 min-w-[28px]">{ev.minute}'</span>
                  <span className="font-medium">{ev.text}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Detailed Summary Modal */}
        {showingSummary && matchResult && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
            <div className="w-full max-w-md p-6 rounded-3xl bg-[#090d18] border-2 border-amber-400/40 shadow-2xl flex flex-col">
              <h3 className="text-xl font-black text-center text-amber-300 mb-4">
                ИТОГИ МАТЧА
              </h3>

              <div className="space-y-3 bg-slate-900/80 rounded-2xl p-4 border border-white/5 mb-6 text-xs">
                <div className="flex justify-between py-1 border-b border-white/5">
                  <span className="text-slate-400">Счёт:</span>
                  <span className="font-black text-white text-sm">
                    {matchResult.user_goals} - {matchResult.opponent_goals}
                  </span>
                </div>
                <div className="flex justify-between py-1 border-b border-white/5">
                  <span className="text-slate-400">Сыгранность команды:</span>
                  <span className="font-bold text-emerald-400">{matchResult.chemistry} / 33</span>
                </div>
                <div className="flex justify-between py-1 border-b border-white/5">
                  <span className="text-slate-400">Бонус сыгранности:</span>
                  <span className="font-bold text-emerald-300">+{matchResult.chemistry_bonus}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-white/5">
                  <span className="text-slate-400">Эффективная сила:</span>
                  <span className="font-bold text-amber-300">{matchResult.effective_power}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-white/5">
                  <span className="text-slate-400">Сила соперника:</span>
                  <span className="font-bold text-rose-300">{matchResult.opponent_strength}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-400">Награда:</span>
                  <span className="font-black text-amber-300 text-sm">
                    {matchResult.won ? '+500 🪙' : matchResult.draw ? '+300 🪙' : '+200 🪙'}
                  </span>
                </div>
              </div>

              <button
                type="button"
                onClick={() => setShowingSummary(false)}
                className="w-full py-3 rounded-xl bg-slate-800 text-slate-200 font-black text-xs hover:bg-slate-700 cursor-pointer"
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
