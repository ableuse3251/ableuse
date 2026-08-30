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
	for lineup_data in saved_lineup_data:
		if lineup_data is Dictionary:
			var player_id: String = str(lineup_data.get("id", ""))
			if player_id.is_empty():
				starting_lineup.append(null) # Пустой слот
			else:
				var card := _find_card_by_id(player_id)
				starting_lineup.append(card)

	var saved_substitutes_data: Array = SaveManager.get_substitutes()
	substitutes.clear()
	for sub_data in saved_substitutes_data:
		if sub_data is Dictionary:
			var player_id: String = str(sub_data.get("id", ""))
			var card := _find_card_by_id(player_id)
			if card != null:
				substitutes.append(card)

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

func remove_card_from_club(card: PlayerCard) -> void:
	if card == null:
		return
	club_cards.erase(card)
	starting_lineup.erase(card)
	substitutes.erase(card)
	SaveManager.set_club_cards(club_cards)
	SaveManager.set_starting_lineup(starting_lineup)
	SaveManager.set_substitutes(substitutes)
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
	# Если игрок был в запасе, убираем его оттуда
	substitutes.erase(card)
	starting_lineup.append(card)
	SaveManager.set_starting_lineup(starting_lineup)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " добавлен в стартовый состав")

func remove_player_from_lineup(card: PlayerCard) -> void:
	if card == null:
		return
	starting_lineup.erase(card)
	SaveManager.set_starting_lineup(starting_lineup)
	print("ClubManager: ", card.player_name, " удален из стартового состава")

func set_player_in_lineup(slot_index: int, card: PlayerCard) -> void:
	if card == null:
		return
	# Если игрок уже в составе, убираем его оттуда
	starting_lineup.erase(card)
	# Если игрок был в запасе, убираем его оттуда
	substitutes.erase(card)
	
	# Расширяем массив, если нужно
	while starting_lineup.size() <= slot_index:
		starting_lineup.append(null)
	
	# Устанавливаем игрока в конкретный слот
	starting_lineup[slot_index] = card
	
	SaveManager.set_starting_lineup(starting_lineup)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " установлен в слот ", slot_index)

func add_player_to_substitutes(card: PlayerCard) -> void:
	if card == null or card in substitutes or card in starting_lineup:
		return
	substitutes.append(card)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " добавлен в запас")

func remove_player_from_substitutes(card: PlayerCard) -> void:
	if card == null:
		return
	substitutes.erase(card)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " удален из запаса")

func move_to_substitutes(card: PlayerCard) -> void:
	if card == null or card not in starting_lineup:
		return
	starting_lineup.erase(card)
	substitutes.append(card)
	SaveManager.set_starting_lineup(starting_lineup)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " перемещен в запас")

func move_to_lineup(card: PlayerCard) -> void:
	if card == null or card not in substitutes:
		return
	substitutes.erase(card)
	starting_lineup.append(card)
	SaveManager.set_starting_lineup(starting_lineup)
	SaveManager.set_substitutes(substitutes)
	print("ClubManager: ", card.player_name, " перемещен в стартовый состав")
