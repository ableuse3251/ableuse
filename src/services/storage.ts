import { CardRarity, PlayerCard, PositionCategory, SaveData } from '../types';
import { PLAYERS_DATABASE } from '../data/playersData';

const STORAGE_KEY = 'fc_draft_ut_save_v1';
const DEFAULT_COINS = 1000;

function getStarterPlayers(): PlayerCard[] {
  // Return a balanced set of 11 starter players so new users have a squad ready
  const starters: PlayerCard[] = [
    PLAYERS_DATABASE.find((p) => p.id === 'kelleher_74')!,
    PLAYERS_DATABASE.find((p) => p.id === 'fort_70')!,
    PLAYERS_DATABASE.find((p) => p.id === 'quansah_74')!,
    PLAYERS_DATABASE.find((p) => p.id === 'cubarsi_75')!,
    PLAYERS_DATABASE.find((p) => p.id === 'chambers_69')!,
    PLAYERS_DATABASE.find((p) => p.id === 'miley_72')!,
    PLAYERS_DATABASE.find((p) => p.id === 'paz_72')!,
    PLAYERS_DATABASE.find((p) => p.id === 'baturina_74')!,
    PLAYERS_DATABASE.find((p) => p.id === 'mainoo_77')!,
    PLAYERS_DATABASE.find((p) => p.id === 'bob_73')!,
    PLAYERS_DATABASE.find((p) => p.id === 'tel_74')!,
  ].filter(Boolean);

  return starters;
}

export function getDefaultSaveData(): SaveData {
  const starters = getStarterPlayers();
  return {
    save_version: 1,
    coins: DEFAULT_COINS,
    club_cards: [...starters],
    starting_lineup: [...starters],
    substitutes: [],
    formation: '4-4-2',
    onboarding_completed: false,
    master_volume: 1.0,
  };
}

export function loadGame(): SaveData {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      const defaultData = getDefaultSaveData();
      saveGame(defaultData);
      return defaultData;
    }
    const parsed = JSON.parse(raw) as Partial<SaveData>;
    const defaultData = getDefaultSaveData();

    return {
      save_version: 1,
      coins: typeof parsed.coins === 'number' ? Math.max(0, parsed.coins) : defaultData.coins,
      club_cards: Array.isArray(parsed.club_cards) && parsed.club_cards.length > 0 ? parsed.club_cards : defaultData.club_cards,
      starting_lineup: Array.isArray(parsed.starting_lineup) && parsed.starting_lineup.length > 0 ? parsed.starting_lineup : defaultData.starting_lineup,
      substitutes: Array.isArray(parsed.substitutes) ? parsed.substitutes : [],
      formation: typeof parsed.formation === 'string' && parsed.formation ? parsed.formation : '4-4-2',
      onboarding_completed: Boolean(parsed.onboarding_completed),
      master_volume: typeof parsed.master_volume === 'number' ? parsed.master_volume : 1.0,
    };
  } catch (e) {
    console.error('Failed to load game save:', e);
    const defaultData = getDefaultSaveData();
    saveGame(defaultData);
    return defaultData;
  }
}

export function saveGame(data: SaveData): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch (e) {
    console.error('Failed to save game:', e);
  }
}

export function resetGameProgress(): SaveData {
  const defaultData = getDefaultSaveData();
  saveGame(defaultData);
  return defaultData;
}

// Pack Purchase Logic (matching PackPurchaseLogic.gd)
export function rollRarity(): CardRarity {
  const roll = Math.random() * 100.0;
  // BRONZE 55% • SILVER 30% • GOLD 12% • ELITE 3%
  if (roll < 55.0) return 'BRONZE';
  if (roll < 85.0) return 'SILVER';
  if (roll < 97.0) return 'GOLD';
  return 'ELITE';
}

export function openPack(): { card: PlayerCard; rarity: CardRarity } {
  const targetRarity = rollRarity();
  let pool = PLAYERS_DATABASE.filter((p) => p.rarity === targetRarity);
  if (pool.length === 0) {
    pool = PLAYERS_DATABASE;
  }
  const card = pool[Math.floor(Math.random() * pool.length)];
  return { card, rarity: targetRarity };
}

// Draft Choice Generator (matching CardDatabase.gd)
export function generateDraftChoices(category: PositionCategory, count: number = 5): PlayerCard[] {
  let pool = PLAYERS_DATABASE.filter((p) => p.position === category);
  if (pool.length === 0) {
    pool = PLAYERS_DATABASE;
  }

  // Shuffle pool
  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  const choices: PlayerCard[] = [];
  const usedIds = new Set<string>();

  for (const candidate of shuffled) {
    if (choices.length >= count) break;
    if (usedIds.has(candidate.id)) continue;

    // Weight by rating rarity
    let chance = 1.0;
    if (candidate.rating >= 90) chance = 0.16;
    else if (candidate.rating >= 87) chance = 0.30;
    else if (candidate.rating >= 84) chance = 0.50;
    else if (candidate.rating >= 80) chance = 0.75;

    if (Math.random() <= chance) {
      usedIds.add(candidate.id);
      choices.push(candidate);
    }
  }

  // Fallback to fill up to count if needed
  if (choices.length < count) {
    for (const candidate of shuffled) {
      if (choices.length >= count) break;
      if (!usedIds.has(candidate.id)) {
        usedIds.add(candidate.id);
        choices.push(candidate);
      }
    }
  }

  return choices;
}
