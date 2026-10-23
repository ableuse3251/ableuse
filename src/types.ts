export type PositionCategory = 'GK' | 'DEF' | 'MID' | 'FWD';

export type CardRarity = 'BRONZE' | 'SILVER' | 'GOLD' | 'ELITE';

export interface PlayerCard {
  id: string;
  player_name: string;
  long_name?: string;
  rating: number;
  potential?: number;
  position: PositionCategory;
  positions: string; // e.g. "ST, CF" or "CM, CAM"
  club: string;
  league_name: string;
  nation: string;
  rarity: CardRarity;
  pace: number;
  shooting: number;
  passing: number;
  dribbling: number;
  defending: number;
  physical: number;
  weak_foot?: number;
  skill_moves?: number;
}

export interface FormationSlot {
  position: PositionCategory | string;
  x: number;
  y: number;
}

export interface Formation {
  name: string;
  slots: FormationSlot[];
}

export interface MatchEvent {
  minute: number;
  text: string;
  is_user: boolean;
  type: 'goal' | 'chance' | 'yellow' | 'red';
}

export interface MatchSimulationResult {
  user_goals: number;
  opponent_goals: number;
  events: MatchEvent[];
  won: boolean;
  draw: boolean;
  lost: boolean;
  avg_rating: number;
  chemistry: number;
  chemistry_bonus: number;
  team_power: number;
  effective_power: number;
  opponent_strength: number;
  power_difference: number;
  user_expected_goals: number;
  opponent_expected_goals: number;
}

export interface SaveData {
  save_version: number;
  coins: number;
  club_cards: PlayerCard[];
  starting_lineup: (PlayerCard | null)[];
  substitutes: PlayerCard[];
  formation: string;
  onboarding_completed: boolean;
  master_volume: number;
}
