class_name ChemistryManager
extends Node

static func calculate_team_chemistry(team: Array[PlayerCard]) -> int:
	var total_chem: int = 0
	
	var club_counts: Dictionary = {}
	var nation_counts: Dictionary = {}
	var league_counts: Dictionary = {}
	
	for card in team:
		if card == null: continue
		club_counts[card.club] = club_counts.get(card.club, 0) + 1
		nation_counts[card.nation] = nation_counts.get(card.nation, 0) + 1
		var league: String = card.league_name.strip_edges()
		if league != "":
			league_counts[league] = league_counts.get(league, 0) + 1
		
	for card in team:
		if card == null: continue
		var card_chem: int = 0
		
		# Очки за клуб
		var c_count = club_counts.get(card.club, 0)
		if c_count >= 2: card_chem += 1
		if c_count >= 4: card_chem += 1
		if c_count >= 7: card_chem += 1
		
		# Очки за лигу (пустая лига не даёт очков)
		var l_count = league_counts.get(card.league_name.strip_edges(), 0)
		if l_count >= 3: card_chem += 1
		if l_count >= 5: card_chem += 1
		if l_count >= 8: card_chem += 1
		
		# Очки за нацию
		var n_count = nation_counts.get(card.nation, 0)
		if n_count >= 2: card_chem += 1
		if n_count >= 5: card_chem += 1
		if n_count >= 8: card_chem += 1
		
		total_chem += min(card_chem, 3) # Максимум 3 очка сыгранности на игрока
		
	return total_chem
