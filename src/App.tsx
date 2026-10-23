import React, { useState, useEffect } from 'react';
import { PlayerCard, SaveData } from './types';
import { loadGame, saveGame, resetGameProgress } from './services/storage';
import { HomeScreen } from './components/HomeScreen';
import { ClubScreen } from './components/ClubScreen';
import { SquadScreen } from './components/SquadScreen';
import { DraftScreen } from './components/DraftScreen';
import { StoreScreen } from './components/StoreScreen';
import { MatchScreen } from './components/MatchScreen';
import { PlayerDetailsModal } from './components/PlayerDetailsModal';
import { SettingsModal } from './components/SettingsModal';
import { OnboardingModal } from './components/OnboardingModal';

// Audio SFX synthesis using Web Audio API
class SoundFx {
  private ctx: AudioContext | null = null;
  public volume: number = 1.0;

  private initCtx() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (AudioCtx) this.ctx = new AudioCtx();
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playCoin() {
    if (this.volume <= 0.01) return;
    try {
      this.initCtx();
      if (!this.ctx) return;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(987.77, this.ctx.currentTime); // B5
      osc.frequency.exponentialRampToValueAtTime(1318.51, this.ctx.currentTime + 0.08); // E6
      gain.gain.setValueAtTime(0.2 * this.volume, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.35);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.35);
    } catch {
      // Ignore audio failure
    }
  }

  playWhistle() {
    if (this.volume <= 0.01) return;
    try {
      this.initCtx();
      if (!this.ctx) return;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(2200, this.ctx.currentTime);
      osc.frequency.setValueAtTime(2600, this.ctx.currentTime + 0.1);
      gain.gain.setValueAtTime(0.15 * this.volume, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.4);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.4);
    } catch {
      // Ignore audio failure
    }
  }
}

const sfx = new SoundFx();

export const App: React.FC = () => {
  const [saveData, setSaveData] = useState<SaveData>(() => loadGame());
  const [currentScreen, setCurrentScreen] = useState<'home' | 'club' | 'squad' | 'draft' | 'store' | 'match'>('home');
  const [inspectedPlayer, setInspectedPlayer] = useState<PlayerCard | null>(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState<boolean>(false);
  const [isOnboardingOpen, setIsOnboardingOpen] = useState<boolean>(false);

  // Sync volume with sfx instance
  useEffect(() => {
    sfx.volume = saveData.master_volume;
  }, [saveData.master_volume]);

  // Save game whenever state changes
  useEffect(() => {
    saveGame(saveData);
  }, [saveData]);

  // First time check for onboarding
  useEffect(() => {
    if (!saveData.onboarding_completed) {
      setIsOnboardingOpen(true);
    }
  }, [saveData.onboarding_completed]);

  const handleRewardCoins = (amount: number) => {
    sfx.playCoin();
    setSaveData((prev) => ({
      ...prev,
      coins: prev.coins + amount,
    }));
  };

  const handleBuyPack = (cost: number, newCard: PlayerCard): boolean => {
    if (saveData.coins < cost) return false;
    sfx.playCoin();

    setSaveData((prev) => {
      // Add card to club if not already present
      const alreadyHas = prev.club_cards.some((c) => c.id === newCard.id);
      const updatedClub = alreadyHas ? prev.club_cards : [...prev.club_cards, newCard];

      return {
        ...prev,
        coins: prev.coins - cost,
        club_cards: updatedClub,
      };
    });
    return true;
  };

  const handleFinishDraft = (draftLineup: PlayerCard[], formationName: string) => {
    sfx.playWhistle();
    setSaveData((prev) => {
      // Merge all draft cards into club collection
      const existingIds = new Set(prev.club_cards.map((c) => c.id));
      const newCardsToAdd = draftLineup.filter((c) => !existingIds.has(c.id));
      const updatedClub = [...prev.club_cards, ...newCardsToAdd];

      return {
        ...prev,
        starting_lineup: draftLineup,
        substitutes: [],
        formation: formationName,
        club_cards: updatedClub,
      };
    });

    setCurrentScreen('match');
  };

  const handleUpdateLineup = (newLineup: (PlayerCard | null)[], newSubs: PlayerCard[]) => {
    setSaveData((prev) => ({
      ...prev,
      starting_lineup: newLineup,
      substitutes: newSubs,
    }));
  };

  const handleUpdateFormation = (newFormation: string) => {
    setSaveData((prev) => ({
      ...prev,
      formation: newFormation,
    }));
  };

  const handleResetProgress = () => {
    const fresh = resetGameProgress();
    setSaveData(fresh);
    setCurrentScreen('home');
  };

  const handleVolumeChange = (vol: number) => {
    sfx.volume = vol;
    setSaveData((prev) => ({
      ...prev,
      master_volume: vol,
    }));
  };

  const handleOnboardingComplete = () => {
    setIsOnboardingOpen(false);
    setSaveData((prev) => ({
      ...prev,
      onboarding_completed: true,
    }));
  };

  return (
    <div className="min-h-screen bg-[#05080f] text-slate-100 flex flex-col font-sans">
      {/* Active Screen Router */}
      {currentScreen === 'home' && (
        <HomeScreen
          coins={saveData.coins}
          clubCards={saveData.club_cards}
          startingLineup={saveData.starting_lineup}
          onNavigate={(screen) => setCurrentScreen(screen)}
          onOpenSettings={() => setIsSettingsOpen(true)}
        />
      )}

      {currentScreen === 'club' && (
        <ClubScreen
          clubCards={saveData.club_cards}
          onViewPlayerDetails={(p) => setInspectedPlayer(p)}
          onNavigateToStore={() => setCurrentScreen('store')}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {currentScreen === 'squad' && (
        <SquadScreen
          clubCards={saveData.club_cards}
          startingLineup={saveData.starting_lineup}
          substitutes={saveData.substitutes}
          formationName={saveData.formation}
          onUpdateLineup={handleUpdateLineup}
          onUpdateFormation={handleUpdateFormation}
          onViewPlayerDetails={(p) => setInspectedPlayer(p)}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {currentScreen === 'draft' && (
        <DraftScreen
          coins={saveData.coins}
          onFinishDraft={handleFinishDraft}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {currentScreen === 'store' && (
        <StoreScreen
          coins={saveData.coins}
          onBuyPack={handleBuyPack}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {currentScreen === 'match' && (
        <MatchScreen
          team={saveData.starting_lineup}
          onRewardCoins={handleRewardCoins}
          onNavigateToSquad={() => setCurrentScreen('squad')}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {/* Modals and Overlays */}
      <PlayerDetailsModal
        player={inspectedPlayer}
        onClose={() => setInspectedPlayer(null)}
      />

      {isSettingsOpen && (
        <SettingsModal
          volume={saveData.master_volume}
          onVolumeChange={handleVolumeChange}
          onReplayTutorial={() => setIsOnboardingOpen(true)}
          onResetProgress={handleResetProgress}
          onClose={() => setIsSettingsOpen(false)}
        />
      )}

      {isOnboardingOpen && (
        <OnboardingModal onComplete={handleOnboardingComplete} />
      )}
    </div>
  );
};
