class_name ChemistryManager
extends Node

static func calculate_team_chemistry(team: Array[PlayerCard]) -> int:
	var total_chem: int = 0
	
	var club_counts: Dictionary = {}
	var nation_counts: Dictionary = {}
	
	for card in team:
		if card == null: continue
		club_counts[card.club] = club_counts.get(card.club, 0) + 1
		nation_counts[card.nation] = nation_counts.get(card.nation, 0) + 1
		
	for card in team:
		if card == null: continue
		var card_chem: int = 0
		
		# Очки за клуб
		var c_count = club_counts.get(card.club, 0)
		if c_count >= 2: card_chem += 1
		if c_count >= 4: card_chem += 1
		if c_count >= 7: card_chem += 1
		
		# Очки за нацию
		var n_count = nation_counts.get(card.nation, 0)
		if n_count >= 2: card_chem += 1
		if n_count >= 5: card_chem += 1
		if n_count >= 8: card_chem += 1
		
		total_chem += min(card_chem, 3) # Максимум 3 очка сыгранности на игрока
		
	return total_chem
