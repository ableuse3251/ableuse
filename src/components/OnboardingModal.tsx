import React, { useState } from 'react';

interface OnboardingModalProps {
  onComplete: () => void;
}

const STEPS = [
  {
    icon: '🏆',
    title: 'ДОБРО ПОЖАЛОВАТЬ В FC DRAFT!',
    lines: [
      'Ты — тренер и менеджер футбольного клуба.',
      'Собирай команду мечты, открывай паки с игроками и выигрывай матчи, чтобы заработать монеты.',
      '',
      'Всё начинается с драфта — выбери 11 игроков, которые станут основой твоего клуба.',
    ],
  },
  {
    icon: '🎯',
    title: 'ДРАФТ',
    lines: [
      'На главном экране нажми «Драфт».',
      'Ты будешь выбирать игроков по очереди, а после выбора 11 футболистов команда будет добавлена в твой клуб.',
      '',
      'Следи за позициями, рейтингом игроков и сыгранностью (клуб, лига, нация)!',
    ],
  },
  {
    icon: '👥',
    title: 'СОСТАВ',
    lines: [
      'В разделе «Мой состав» ты видишь всех игроков клуба.',
      'Расставляй стартовые 11 и выбирай запасных.',
      'Схема (например, 4-4-2) влияет на расстановку и химию команды.',
      '',
      'Между экранами можно свободно переключаться.',
    ],
  },
  {
    icon: '🛒',
    title: 'МАГАЗИН',
    lines: [
      'Открывай ЗОЛОТЫЕ ПАКИ в магазине за 500 монет.',
      'Внутри — случайный игрок: от BRONZE до ELITE.',
      'Чем выше редкость, тем сильнее и ценнее карточка.',
      '',
      'Монеты зарабатываются за матчи и с наград клуба.',
    ],
  },
  {
    icon: '⚽',
    title: 'МАТЧИ',
    lines: [
      'Нажми «Матч», когда соберёшь 11 игроков.',
      'Матч симулируется автоматически: голы, жёлтые карточки, опасные моменты.',
      '',
      'За победу — 500 монет, за ничью — 300, за поражение — 200. Без проигрыша не бывает побед!',
    ],
  },
  {
    icon: '🚀',
    title: 'ВСЁ ГОТОВО!',
    lines: [
      'Ты узнал основы. Удачи в построении команды мечты!',
      '',
      'Настройки (звук, сброс прогресса) доступны по кнопке ⚙️ на главном экране.',
      '',
      'Приятной игры!',
    ],
  },
];

export const OnboardingModal: React.FC<OnboardingModalProps> = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState<number>(0);
  const step = STEPS[currentStep];

  const handleNext = () => {
    if (currentStep >= STEPS.length - 1) {
      onComplete();
    } else {
      setCurrentStep((s) => s + 1);
    }
  };

  const handlePrev = () => {
    if (currentStep > 0) {
      setCurrentStep((s) => s - 1);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md select-none">
      <div className="relative w-full max-w-lg p-6 rounded-3xl bg-gradient-to-b from-[#0e1626] to-[#060a12] border-2 border-amber-400/50 shadow-2xl flex flex-col text-center">
        {/* Step Badge */}
        <div className="text-[11px] font-black text-amber-400 uppercase tracking-widest mb-1">
          ШАГ {currentStep + 1} ИЗ {STEPS.length} • УЧЕБНИК
        </div>

        {/* Step Icon */}
        <div className="w-20 h-20 rounded-2xl bg-amber-500/15 border-2 border-amber-400/40 flex items-center justify-center text-4xl mx-auto my-3 shadow-[0_0_20px_rgba(245,158,11,0.2)]">
          {step.icon}
        </div>

        <h3 className="text-xl font-black text-white mb-4 tracking-wide">{step.title}</h3>

        {/* Text lines */}
        <div className="min-h-[160px] flex flex-col justify-center bg-slate-900/60 rounded-2xl p-4 border border-white/5 mb-5 text-left text-xs leading-relaxed text-slate-300">
          {step.lines.map((line, idx) => (
            <p key={idx} className={line === '' ? 'h-2' : 'mb-1'}>
              {line}
            </p>
          ))}
        </div>

        {/* Dot indicators */}
        <div className="flex items-center justify-center gap-1.5 mb-5">
          {STEPS.map((_, idx) => (
            <div
              key={idx}
              className={`h-2 rounded-full transition-all ${
                idx === currentStep ? 'w-6 bg-amber-400 shadow-md' : 'w-2 bg-slate-700'
              }`}
            />
          ))}
        </div>

        {/* Navigation Buttons */}
        <div className="flex items-center gap-2.5">
          <button
            type="button"
            onClick={handlePrev}
            disabled={currentStep === 0}
            className="py-3 px-4 rounded-xl bg-slate-800 text-slate-300 text-xs font-bold disabled:opacity-30 cursor-pointer hover:bg-slate-700"
          >
            ← Назад
          </button>

          <button
            type="button"
            onClick={handleNext}
            className="flex-1 py-3 px-4 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-slate-950 text-xs font-black uppercase tracking-wider hover:brightness-110 active:scale-98 shadow-md cursor-pointer"
          >
            {currentStep >= STEPS.length - 1 ? 'НАЧАТЬ ИГРУ 🚀' : 'Далее →'}
          </button>

          <button
            type="button"
            onClick={onComplete}
            className="py-3 px-3 rounded-xl bg-slate-900 text-slate-400 text-xs font-semibold hover:text-white cursor-pointer"
          >
            Пропустить
          </button>
        </div>
      </div>
    </div>
  );
};
