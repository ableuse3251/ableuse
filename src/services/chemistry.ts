import { PlayerCard } from '../types';

export function calculateTeamChemistry(team: (PlayerCard | null)[]): number {
  let totalChem = 0;
  const clubCounts: Record<string, number> = {};
  const nationCounts: Record<string, number> = {};
  const leagueCounts: Record<string, number> = {};

  for (const card of team) {
    if (!card) continue;
    if (card.club) {
      clubCounts[card.club] = (clubCounts[card.club] || 0) + 1;
    }
    if (card.nation) {
      nationCounts[card.nation] = (nationCounts[card.nation] || 0) + 1;
    }
    const league = (card.league_name || '').trim();
    if (league) {
      leagueCounts[league] = (leagueCounts[league] || 0) + 1;
    }
  }

  for (const card of team) {
    if (!card) continue;
    let cardChem = 0;

    // Club threshold
    const cCount = clubCounts[card.club] || 0;
    if (cCount >= 7) cardChem += 3;
    else if (cCount >= 4) cardChem += 2;
    else if (cCount >= 2) cardChem += 1;

    // League threshold (empty league gives 0)
    const league = (card.league_name || '').trim();
    const lCount = league ? leagueCounts[league] || 0 : 0;
    if (lCount >= 8) cardChem += 3;
    else if (lCount >= 5) cardChem += 2;
    else if (lCount >= 3) cardChem += 1;

    // Nation threshold
    const nCount = nationCounts[card.nation] || 0;
    if (nCount >= 8) cardChem += 3;
    else if (nCount >= 5) cardChem += 2;
    else if (nCount >= 2) cardChem += 1;

    totalChem += Math.min(cardChem, 3);
  }

  return Math.min(totalChem, 33);
}

export function calculateCardChemistry(card: PlayerCard | null, team: (PlayerCard | null)[]): number {
  if (!card) return 0;
  const clubCounts: Record<string, number> = {};
  const nationCounts: Record<string, number> = {};
  const leagueCounts: Record<string, number> = {};

  for (const c of team) {
    if (!c) continue;
    if (c.club) {
      clubCounts[c.club] = (clubCounts[c.club] || 0) + 1;
    }
    if (c.nation) {
      nationCounts[c.nation] = (nationCounts[c.nation] || 0) + 1;
    }
    const league = (c.league_name || '').trim();
    if (league) {
      leagueCounts[league] = (leagueCounts[league] || 0) + 1;
    }
  }

  let cardChem = 0;
  const cCount = clubCounts[card.club] || 0;
  if (cCount >= 7) cardChem += 3;
  else if (cCount >= 4) cardChem += 2;
  else if (cCount >= 2) cardChem += 1;

  const league = (card.league_name || '').trim();
  const lCount = league ? leagueCounts[league] || 0 : 0;
  if (lCount >= 8) cardChem += 3;
  else if (lCount >= 5) cardChem += 2;
  else if (lCount >= 3) cardChem += 1;

  const nCount = nationCounts[card.nation] || 0;
  if (nCount >= 8) cardChem += 3;
  else if (nCount >= 5) cardChem += 2;
  else if (nCount >= 2) cardChem += 1;

  return Math.min(cardChem, 3);
}
