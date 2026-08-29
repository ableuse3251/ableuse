extends Node

# ============================================================
# КАРТЫ КЛУБА
# ============================================================

var club_cards: Array[PlayerCard] = []
var my_club_cards: Array[PlayerCard]:  # Алиас для совместимости с ClubScreen
	get:
		return club_cards
	set(value):
		club_cards = value

# ============================================================
# СТАРТОВЫЙ СОСТАВ
# ============================================================

var starting_lineup: Array[PlayerCard] = []

# ============================================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================================

func _ready() -> void:
	_load_club_data()

# ============================================================
# ЗАГРУЗКА ДАННЫХ КЛУБА
# ============================================================

func _load_club_data() -> void:
	# Загружаем карты из сохранения
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
			
			# Загружаем статы, если они есть
			card.pace = int(card_data.get("pace", 0))
			card.shooting = int(card_data.get("shooting", 0))
			card.passing = int(card_data.get("passing", 0))
			card.dribbling = int(card_data.get("dribbling", 0))
			card.defending = int(card_data.get("defending", 0))
			card.physical = int(card_data.get("physical", 0))
			
			club_cards.append(card)
	
	print("ClubManager: загружено карт клуба: ", club_cards.size())
	
	# Загружаем стартовый состав
	var saved_lineup_data: Array = SaveManager.get_starting_lineup()
	starting_lineup.clear()
	
	for lineup_data in saved_lineup_data:
		if lineup_data is Dictionary:
			var player_id: String = str(lineup_data.get("id", ""))
			var card := _find_card_by_id(player_id)
			if card != null:
				starting_lineup.append(card)
	
	print("ClubManager: загружено игроков в стартовом составе: ", starting_lineup.size())

# ============================================================
# ПОИСК КАРТЫ ПО ID
# ============================================================

func _find_card_by_id(player_id: String) -> PlayerCard:
	for card in club_cards:
		if card.id == player_id:
			return card
	return null

# ============================================================
# ДОБАВЛЕНИЕ КАРТЫ В КЛУБ
# ============================================================

func add_card_to_club(card: PlayerCard) -> void:
	if card == null:
		return
	
	club_cards.append(card)
	
	# Сохраняем обновлённый список карт
	SaveManager.set_club_cards(club_cards)
	
	print("ClubManager: добавлена карта ", card.player_name, " в клуб. Всего карт: ", club_cards.size())

# ============================================================
# УДАЛЕНИЕ КАРТЫ ИЗ КЛУБА
# ============================================================

func remove_card_from_club(card: PlayerCard) -> void:
	if card == null:
		return
	
	club_cards.erase(card)
	SaveManager.set_club_cards(club_cards)
	
	# Удаляем из стартового состава, если там был
	starting_lineup.erase(card)
	SaveManager.set_starting_lineup(starting_lineup)
	
	print("ClubManager: удалена карта ", card.player_name, " из клуба. Всего карт: ", club_cards.size())

# ============================================================
# ПОЛУЧЕНИЕ ВСЕХ КАРТ
# ============================================================

func get_all_cards() -> Array[PlayerCard]:
	return club_cards

# ============================================================
# ПОЛУЧЕНИЕ СТАРТОВОГО СОСТАВА
# ============================================================

func get_starting_lineup() -> Array[PlayerCard]:
	return starting_lineup

# ============================================================
# УСТАНОВКА СТАРТОВОГО СОСТАВА
# ============================================================

func set_starting_lineup(lineup: Array[PlayerCard]) -> void:
	starting_lineup = lineup.duplicate()
	SaveManager.set_starting_lineup(starting_lineup)
	
	print("ClubManager: установлен стартовый состав из ", starting_lineup.size(), " игроков")

# ============================================================
# ДОБАВЛЕНИЕ ИГРОКА В СОСТАВ
# ============================================================

func add_player_to_lineup(card: PlayerCard) -> void:
	if card == null:
		return
	
	if card in starting_lineup:
		return
	
	starting_lineup.append(card)
	SaveManager.set_starting_lineup(starting_lineup)
	
	print("ClubManager: добавлен ", card.player_name, " в стартовый состав")

# ============================================================
# УДАЛЕНИЕ ИГРОКА ИЗ СОСТАВА
# ============================================================

func remove_player_from_lineup(card: PlayerCard) -> void:
	if card == null:
		return
	
	starting_lineup.erase(card)
	SaveManager.set_starting_lineup(starting_lineup)
	
	print("ClubManager: удалён ", card.player_name, " из стартового состава")
