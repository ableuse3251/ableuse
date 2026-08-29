extends Node

# ============================================================
# ДАННЫЕ КЛУБА
# ============================================================

var my_club_cards: Array[PlayerCard] = []
var starting_lineup: Array[PlayerCard] = []

# Кэш для мгновенного поиска по ID (O(1) вместо O(N))
var _club_cards_by_id: Dictionary = {}

# ============================================================
# READY
# ============================================================

func _ready() -> void:
	load_club_cards()
	load_starting_lineup()

# ============================================================
# ЗАГРУЗКА КОЛЛЕКЦИИ
# ============================================================

func load_club_cards() -> void:
	my_club_cards.clear()
	_club_cards_by_id.clear()

	var saved_cards: Array = SaveManager.get_club_cards()
	print("ClubManager: сохранённых записей: ", saved_cards.size())

	for card_data: Variant in saved_cards:
		var saved_id: String = ""
		var saved_name: String = ""

		if card_data is String:
			# Новый формат: сохранён только ID (оптимизация)
			saved_id = card_data
		elif card_data is Dictionary:
			# Старый формат: сохранён словарь (обратная совместимость)
			saved_id = str(card_data.get("id", ""))
			saved_name = str(card_data.get("player_name", ""))
		else:
			continue

		var card: PlayerCard = null

		# 1. Поиск по ID (O(1))
		if saved_id != "":
			card = CardDatabase.get_player_by_id(saved_id)

		# 2. Fallback для старых сохранений по имени (теперь тоже O(1) благодаря кэшу в CardDatabase)
		if card == null and saved_name != "":
			card = _find_player_by_name(saved_name)

		if card == null:
			print("ClubManager: игрок не найден. ID: ", saved_id, " | Имя: ", saved_name)
			continue

		# Защита от дублей через кэш
		if _club_cards_by_id.has(card.id):
			continue

		my_club_cards.append(card)
		_club_cards_by_id[card.id] = card

	print("ClubManager: загружено карточек в клуб: ", my_club_cards.size())

# ============================================================
# ПОИСК ИГРОКА ПО ИМЕНИ (ОПТИМИЗИРОВАНО ДО O(1))
# ============================================================

func _find_player_by_name(target_name: String) -> PlayerCard:
	var target: String = target_name.strip_edges().to_lower()
	if target == "":
		return null

	# Используем оптимизированный поиск по кэшу в CardDatabase
	var found_id: String = CardDatabase.get_player_id_by_name_lower(target)
	if found_id != "":
		var card = CardDatabase.get_player_by_id(found_id)
		if card:
			print("ClubManager: найден старый игрок по имени: ", target_name, " -> ", card.player_name)
			return card

	return null

# ============================================================
# УПРАВЛЕНИЕ КЛУБОМ
# ============================================================

func add_to_club(card: PlayerCard) -> bool:
	if card == null or _club_cards_by_id.has(card.id):
		return false

	my_club_cards.append(card)
	_club_cards_by_id[card.id] = card
	_save_club_to_disk()
	print("ClubManager: игрок добавлен в клуб: ", card.player_name)
	return true

func is_in_club(card: PlayerCard) -> bool:
	return card != null and _club_cards_by_id.has(card.id)

func remove_from_club(card: PlayerCard) -> bool:
	if card == null or not _club_cards_by_id.has(card.id):
		return false

	my_club_cards.erase(card)
	_club_cards_by_id.erase(card.id)
	
	# Если игрок был в составе, убираем его и оттуда
	if is_in_starting_lineup(card):
		remove_from_starting_lineup(card)
		
	_save_club_to_disk()
	return true

# ============================================================
# УПРАВЛЕНИЕ СОСТАВОМ
# ============================================================

func add_to_starting_lineup(card: PlayerCard) -> bool:
	if card == null or not _club_cards_by_id.has(card.id):
		print("ClubManager: игрок отсутствует в клубе.")
		return false

	for lineup_card: PlayerCard in starting_lineup:
		if lineup_card.id == card.id:
			return false

	if starting_lineup.size() >= 11:
		print("ClubManager: состав уже заполнен.")
		return false

	# Берём ссылку напрямую из кэша (O(1))
	var club_card_reference: PlayerCard = _club_cards_by_id[card.id]
	starting_lineup.append(club_card_reference)
	
	_save_lineup_to_disk()
	return true

func remove_from_starting_lineup(card: PlayerCard) -> bool:
	if card == null:
		return false

	var found_index: int = -1
	for i in range(starting_lineup.size()):
		if starting_lineup[i].id == card.id:
			found_index = i
			break

	if found_index == -1:
		return false

	starting_lineup.remove_at(found_index)
	_save_lineup_to_disk()
	return true

func is_in_starting_lineup(card: PlayerCard) -> bool:
	if card == null:
		return false
	for lineup_card: PlayerCard in starting_lineup:
		if lineup_card.id == card.id:
			return true
	return false

func get_starting_lineup() -> Array[PlayerCard]:
	return starting_lineup

# ============================================================
# ЗАГРУЗКА СОСТАВА
# ============================================================

func load_starting_lineup() -> void:
	starting_lineup.clear()
	var saved_lineup: Array = SaveManager.get_starting_lineup()

	for lineup_data: Variant in saved_lineup:
		if not lineup_data is Dictionary:
			continue

		var saved_id: String = str(lineup_data.get("id", ""))
		if saved_id == "":
			continue

		# Мгновенный поиск в кэше клуба (O(1))
		if _club_cards_by_id.has(saved_id):
			starting_lineup.append(_club_cards_by_id[saved_id])

		if starting_lineup.size() >= 11:
			break

	print("ClubManager: загружено игроков в составе: ", starting_lineup.size())

# ============================================================
# СОХРАНЕНИЕ
# ============================================================

func _save_club_to_disk() -> void:
	SaveManager.set_club_cards(my_club_cards)

func _save_lineup_to_disk() -> void:
	SaveManager.set_starting_lineup(starting_lineup)

func clear_club() -> void:
	my_club_cards.clear()
	_club_cards_by_id.clear()
	starting_lineup.clear()
	_save_club_to_disk()
	_save_lineup_to_disk()
	print("ClubManager: клуб очищен.")
