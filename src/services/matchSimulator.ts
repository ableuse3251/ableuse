import { MatchEvent, MatchSimulationResult, PlayerCard } from '../types';
import { calculateTeamChemistry } from './chemistry';

const MIN_EXPECTED_GOALS = 0.25;
const MAX_EXPECTED_GOALS = 3.50;
const MIN_SCORE = 0;
const MAX_SCORE = 7;
const MIN_CHANCES = 4;
const MAX_CHANCES = 8;

function randRange(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}

function randInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function rollGoals(expectedGoals: number): number {
  const exp = Math.max(expectedGoals, 0.05);
  let probability = 1.0;
  const threshold = Math.exp(-exp);
  let goals = 0;

  while (probability > threshold) {
    probability *= Math.random();
    goals += 1;
    if (goals >= 8) break;
  }

  return Math.max(goals - 1, 0);
}

function getPositionGoalBonus(pos: string): number {
  const p = (pos || '').toUpperCase();
  switch (p) {
    case 'FWD':
    case 'ST':
      return 3.0;
    case 'CF':
      return 2.7;
    case 'RW':
    case 'LW':
      return 2.1;
    case 'CAM':
      return 1.8;
    case 'RM':
    case 'LM':
      return 1.6;
    case 'MID':
    case 'CM':
      return 1.15;
    case 'CDM':
      return 0.55;
    case 'LB':
    case 'RB':
    case 'DEF':
      return 0.35;
    case 'LWB':
    case 'RWB':
      return 0.45;
    case 'CB':
      return 0.20;
    case 'GK':
      return 0.02;
    default:
      return 1.0;
  }
}

function chooseScorer(players: PlayerCard[]): PlayerCard | null {
  if (players.length === 0) return null;
  let totalWeight = 0;
  for (const player of players) {
    const bonus = getPositionGoalBonus(player.position);
    const weight = Math.max(player.rating - 50, 1) * bonus;
    totalWeight += weight;
  }

  if (totalWeight <= 0) {
    return players[Math.floor(Math.random() * players.length)];
  }

  const roll = Math.random() * totalWeight;
  let accumulated = 0;
  for (const player of players) {
    const bonus = getPositionGoalBonus(player.position);
    const weight = Math.max(player.rating - 50, 1) * bonus;
    accumulated += weight;
    if (roll <= accumulated) {
      return player;
    }
  }

  return players[players.length - 1];
}

export function simulateMatch(
  team: (PlayerCard | null)[],
  opponentStrength: number = 80
): MatchSimulationResult {
  const validPlayers = team.filter((p): p is PlayerCard => p !== null);
  const totalRating = validPlayers.reduce((acc, p) => acc + p.rating, 0);
  const count = validPlayers.length || 1;
  const avgRating = totalRating / count;

  const chemistry = calculateTeamChemistry(team);
  const chemistryBonus = (chemistry / 33.0) * 10.0;
  const teamPower = avgRating + chemistryBonus;

  const randomFactor = randRange(-5.0, 5.0);
  const effectivePower = teamPower + randomFactor;
  const diff = effectivePower - opponentStrength;

  let userExpectedGoals = 1.30 + diff * 0.028;
  let opponentExpectedGoals = 1.20 - diff * 0.024;

  userExpectedGoals = Math.min(Math.max(userExpectedGoals, MIN_EXPECTED_GOALS), MAX_EXPECTED_GOALS);
  opponentExpectedGoals = Math.min(Math.max(opponentExpectedGoals, MIN_EXPECTED_GOALS), MAX_EXPECTED_GOALS);

  let userGoals = rollGoals(userExpectedGoals);
  let opponentGoals = rollGoals(opponentExpectedGoals);

  // Safety protection from weird results when difference is huge
  if (diff >= 12.0 && userGoals < opponentGoals && Math.random() < 0.60) {
    userGoals = Math.min(opponentGoals, MAX_SCORE);
  } else if (diff <= -12.0 && opponentGoals < userGoals && Math.random() < 0.60) {
    opponentGoals = Math.min(userGoals, MAX_SCORE);
  }

  userGoals = Math.min(Math.max(userGoals, MIN_SCORE), MAX_SCORE);
  opponentGoals = Math.min(Math.max(opponentGoals, MIN_SCORE), MAX_SCORE);

  const events: MatchEvent[] = [];

  // Match moments: chances
  const chanceCount = randInt(MIN_CHANCES, MAX_CHANCES);
  for (let i = 0; i < chanceCount; i++) {
    const minute = randInt(3, 87);
    const chanceType = randInt(0, 4);
    let text = '';
    let isUser = true;

    switch (chanceType) {
      case 0:
        text = `🔥 Опасная атака вашей команды (${minute}')`;
        break;
      case 1:
        text = `🎯 Удар по воротам! Вратарь спасает (${minute}')`;
        break;
      case 2:
        text = `❌ Удар мимо ворот (${minute}')`;
        break;
      case 3:
        text = `🧤 Отличный сейв вратаря (${minute}')`;
        break;
      default:
        text = `💥 Соперник создаёт опасный момент (${minute}')`;
        isUser = false;
        break;
    }

    events.push({ minute, text, is_user: isUser, type: 'chance' });
  }

  // Yellow cards
  const yellowCount = randInt(0, 3);
  for (let i = 0; i < yellowCount; i++) {
    const minute = randInt(15, 85);
    const isUser = Math.random() < 0.5;
    const player = validPlayers[Math.floor(Math.random() * validPlayers.length)];
    const playerName = player?.player_name || 'Игрок команды';
    const text = isUser
      ? `🟨 ${playerName} получает жёлтую карточку (${minute}')`
      : `🟨 Игрок соперника получает жёлтую карточку (${minute}')`;
    events.push({ minute, text, is_user: isUser, type: 'yellow' });
  }

  // Red card chance (7%)
  if (Math.random() < 0.07) {
    const minute = randInt(25, 82);
    const isUser = Math.random() < 0.5;
    const player = validPlayers[Math.floor(Math.random() * validPlayers.length)];
    const playerName = player?.player_name || 'Игрок команды';
    const text = isUser
      ? `🟥 ${playerName} удалён! (${minute}')`
      : `🟥 Игрок соперника удалён! (${minute}')`;
    events.push({ minute, text, is_user: isUser, type: 'red' });
  }

  // User goals
  for (let i = 0; i < userGoals; i++) {
    const minute = randInt(5, 88);
    const scorer = chooseScorer(validPlayers);
    const scorerName = scorer?.player_name || 'Игрок команды';
    events.push({
      minute,
      text: `⚽ Гол! ${scorerName} (${minute}')`,
      is_user: true,
      type: 'goal',
    });
  }

  // Opponent goals
  for (let i = 0; i < opponentGoals; i++) {
    const minute = randInt(5, 88);
    events.push({
      minute,
      text: `⚽ Гол соперника (${minute}')`,
      is_user: false,
      type: 'goal',
    });
  }

  // Sort events by minute
  events.sort((a, b) => {
    if (a.minute === b.minute) {
      if (a.type === 'goal' && b.type !== 'goal') return 1;
      if (a.type !== 'goal' && b.type === 'goal') return -1;
      return 0;
    }
    return a.minute - b.minute;
  });

  const won = userGoals > opponentGoals;
  const draw = userGoals === opponentGoals;
  const lost = userGoals < opponentGoals;

  return {
    user_goals: userGoals,
    opponent_goals: opponentGoals,
    events,
    won,
    draw,
    lost,
    avg_rating: Math.round(avgRating),
    chemistry,
    chemistry_bonus: Math.round(chemistryBonus * 10) / 10,
    team_power: Math.round(teamPower * 10) / 10,
    effective_power: Math.round(effectivePower * 10) / 10,
    opponent_strength: opponentStrength,
    power_difference: Math.round(diff * 10) / 10,
    user_expected_goals: Math.round(userExpectedGoals * 100) / 100,
    opponent_expected_goals: Math.round(opponentExpectedGoals * 100) / 100,
  };
}
