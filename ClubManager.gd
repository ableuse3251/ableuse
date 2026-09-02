extends Node

# ============================================================
# КАРТЫ КЛУБА
# ============================================================
var club_cards: Array[PlayerCard] = []

# ============================================================
# СТАРТОВЫЙ СОСТАВ И ЗАПАСНЫЕ
# ============================================================
var starting_lineup: Array[PlayerCard] = []
var substitutes: Array[PlayerCard] = []
var current_formation: String = "4-4-2"

# ============================================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================================
func _ready() -> void:
	print("ClubManager: _ready() вызван (autoload)")
	_load_club_data()

# ============================================================
# ПУБЛИЧНАЯ ПЕРЕЗАГРУЗКА (например, после сброса прогресса)
# ============================================================
func reload_data() -> void:
	print("ClubManager: перезагрузка данных клуба...")
	_load_club_data()

# ============================================================
# ЗАГРУЗКА ДАННЫХ КЛУБА
# ============================================================
func _load_club_data() -> void:
	print("ClubManager: начинаю загрузку данных...")

	var saved_cards_data: Array = SaveManager.get_club_cards()
	club_cards.clear()
	for card_data in saved_cards_data:
		if card_data is Dictionary:
			var card := PlayerCard.new()
			card.id = str(card_data.get("id", ""))
			card.player_name = str(card_data.get("player_name", ""))
			card.rating = int(card_data.get("rating", 75))
			card.position = str(card_data.get("position", "MID"))
			card.club = str(card_data.get("club", ""))
			card.nation = str(card_data.get("nation", ""))
			card.rarity = str(card_data.get("rarity", "BRONZE"))
			card.pace = int(card_data.get("pace", 0))
			card.shooting = int(card_data.get("shooting", 0))
			card.passing = int(card_data.get("passing", 0))
			card.dribbling = int(card_data.get("dribbling", 0))
			card.defending = int(card_data.get("defending", 0))
			card.physical = int(card_data.get("physical", 0))
			club_cards.append(card)

	var saved_lineup_data: Array = SaveManager.get_starting_lineup()
	starting_lineup.clear()
	var lineup_invalid_ids: int = 0
	for lineup_data in saved_lineup_data:
		if lineup_data is Dictionary:
			var player_id: String = str(lineup_data.get("id", ""))
			if player_id.is_empty():
				starting_lineup.append(null)
			else:
				var card := _find_card_by_id(player_id)
				if card == null:
					lineup_invalid_ids += 1
					push_warning("ClubManager: в сохранённом стартовом составе найден несуществующий ID = '" + player_id + "', слот будет пустым.")
					starting_lineup.append(null)
				else:
					starting_lineup.append(card)

	if lineup_invalid_ids > 0:
		print("ClubManager: предупреждение: пропущено ", lineup_invalid_ids, " невалидных ID в стартовом составе.")

	var saved_substitutes_data: Array = SaveManager.get_substitutes()
	substitutes.clear()
	var subs_invalid_ids: int = 0
	for sub_data in saved_substitutes_data:
		if sub_data is Dictionary:
			var player_id: String = str(sub_data.get("id", ""))
			var card := _find_card_by_id(player_id)
			if card == null:
				subs_invalid_ids += 1
				push_warning("ClubManager: в сохранённых запасных найден несуществующий ID = '" + player_id + "', игрок пропущен.")
			else:
				substitutes.append(card)

	if subs_invalid_ids > 0:
		print("ClubManager: предупреждение: пропущено ", subs_invalid_ids, " невалидных ID в запасных.")

	current_formation = SaveManager.get_formation()
	if current_formation.is_empty():
		current_formation = "4-4-2"

	print("ClubManager: загружено карт клуба: ", club_cards.size(), ", в старте: ", starting_lineup.size(), ", в запасе: ", substitutes.size(), ", схема: ", current_formation)

func _find_card_by_id(player_id: String) -> PlayerCard:
	for card in club_cards:
		if card != null and card.id == player_id:
			return card
	return null

# ============================================================
# УПРАВЛЕНИЕ КАРТАМИ КЛУБА
# ============================================================
func add_card_to_club(card: PlayerCard) -> void:
	if card == null:
		return
	club_cards.append(card)
	SaveManager.set_club_cards(club_cards)
	print("ClubManager: добавлена карта ", card.player_name)

func add_cards_to_club_batch(cards: Array[PlayerCard]) -> void:
	if cards == null or cards.is_empty():
		return

	var added: int = 0
	for card in cards:
		if card == null:
			continue
		club_cards.append(card)
		added += 1

	if added > 0:
		SaveManager.set_club_cards(club_cards)

	print("ClubManager: batch-операция: добавлено ", added, " карт в клуб за одно сохранение.")

func remove_card_from_club(card: PlayerCard) -> void:
	if card == null:
		return
	club_cards.erase(card)
	starting_lineup.erase(card)
	substitutes.erase(card)
	SaveManager.set_club_cards(club_cards)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: удалена карта ", card.player_name)

# ============================================================
# УПРАВЛЕНИЕ СОСТАВОМ
# ============================================================
func get_all_cards() -> Array[PlayerCard]:
	return club_cards

func get_starting_lineup() -> Array[PlayerCard]:
	return starting_lineup

func get_substitutes() -> Array[PlayerCard]:
	return substitutes

func get_current_formation() -> String:
	return current_formation

func set_formation(formation: String) -> void:
	current_formation = formation
	SaveManager.set_formation(current_formation)
	print("ClubManager: схема изменена на ", current_formation)

func add_player_to_lineup(card: PlayerCard) -> void:
	if card == null or card in starting_lineup:
		return
	substitutes.erase(card)
	starting_lineup.append(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " добавлен в стартовый состав")

func remove_player_from_lineup(card: PlayerCard) -> void:
	if card == null:
		return
	starting_lineup.erase(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " удален из стартового состава")

func set_player_in_lineup(slot_index: int, card: PlayerCard) -> void:
	if card == null:
		return
	starting_lineup.erase(card)
	substitutes.erase(card)

	while starting_lineup.size() <= slot_index:
		starting_lineup.append(null)

	starting_lineup[slot_index] = card

	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " установлен в слот ", slot_index)

func add_player_to_substitutes(card: PlayerCard) -> void:
	if card == null or card in substitutes or card in starting_lineup:
		return
	substitutes.append(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " добавлен в запас")

func remove_player_from_substitutes(card: PlayerCard) -> void:
	if card == null:
		return
	substitutes.erase(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " удален из запаса")

func move_to_substitutes(card: PlayerCard) -> void:
	if card == null or card not in starting_lineup:
		return
	starting_lineup.erase(card)
	substitutes.append(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " перемещен в запас")

func move_to_lineup(card: PlayerCard) -> void:
	if card == null or card not in substitutes:
		return
	substitutes.erase(card)
	starting_lineup.append(card)
	SaveManager.save_lineup_and_subs(starting_lineup, substitutes)
	print("ClubManager: ", card.player_name, " перемещен в стартовый состав")
