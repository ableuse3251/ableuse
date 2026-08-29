extends Node

# ============================================================
# БАЗА
# ============================================================

const DATABASE_PATH: String = "res://players.json"
const DEFAULT_DRAFT_SIZE: int = 5

var database: Array[PlayerCard] = []

# ============================================================
# КЭШИ
# ============================================================

var players_by_position: Dictionary = {}
var players_by_rarity: Dictionary = {}
var players_by_league: Dictionary = {}
var players_by_name_lower: Dictionary = {} # НОВЫЙ КЭШ ДЛЯ БЫСТРОГО ПОИСКА ПО ИМЕНИ

# ============================================================
# READY
# ============================================================

func _ready() -> void:
	_load_database()

# ============================================================
# ЗАГРУЗКА БАЗЫ
# ============================================================

func _load_database() -> void:
	database.clear()
	players_by_position.clear()
	players_by_rarity.clear()
	players_by_league.clear()
	players_by_name_lower.clear()

	if not FileAccess.file_exists(DATABASE_PATH):
		push_error("CardDatabase: файл не найден: " + DATABASE_PATH)
		return

	var file: FileAccess = FileAccess.open(DATABASE_PATH, FileAccess.READ)
	if file == null:
		push_error("CardDatabase: не удалось открыть " + DATABASE_PATH)
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed_data: Variant = JSON.parse_string(content)
	if parsed_data == null or not parsed_data is Dictionary:
		push_error("CardDatabase: JSON содержит ошибку или не является Dictionary.")
		return

	var players_data: Variant = parsed_data.get("players", [])
	if not players_data is Array:
		push_error("CardDatabase: поле players должно быть Array.")
		return

	print("============================================================")
	print("CARD DATABASE: НАЧАЛО ЗАГРУЗКИ")
	print("JSON игроков: ", players_data.size())

	for player_data: Variant in players_data:
		if not player_data is Dictionary:
			continue

		var card: PlayerCard = PlayerCard.from_dictionary(player_data)
		if card == null or card.id == "":
			continue

		database.append(card)
		_add_to_position_cache(card)
		_add_to_rarity_cache(card)
		_add_to_league_cache(card)
		_add_to_name_cache(card) # НОВОЕ: добавляем в кэш имён

	print("CardDatabase: загружено игроков: ", database.size())
	print("CardDatabase: позиций в кэше: ", players_by_position.size())
	print("CardDatabase: редкостей в кэше: ", players_by_rarity.size())
	print("CardDatabase: лиг в кэше: ", players_by_league.size())
	print("CardDatabase: имён в кэше: ", players_by_name_lower.size())
	print("============================================================")

# ============================================================
# КЭШИРОВАНИЕ
# ============================================================

func _add_to_position_cache(card: PlayerCard) -> void:
	var positions: String = card.positions if card.positions != "" else card.position
	var raw_positions: PackedStringArray = positions.replace("/", ",").split(",", false)

	for raw_position: String in raw_positions:
		var position: String = raw_position.strip_edges().to_upper()
		if position == "":
			continue
		if not players_by_position.has(position):
			players_by_position[position] = []
		var position_array: Array = players_by_position[position]
		if not position_array.has(card):
			position_array.append(card)

	var normalized_position: String = card.position.to_upper()
	if normalized_position != "":
		if not players_by_position.has(normalized_position):
			players_by_position[normalized_position] = []
		var normalized_array: Array = players_by_position[normalized_position]
		if not normalized_array.has(card):
			normalized_array.append(card)

func _add_to_rarity_cache(card: PlayerCard) -> void:
	var rarity: String = card.rarity.strip_edges().to_upper()
	if rarity == "":
		rarity = "BRONZE"
	if not players_by_rarity.has(rarity):
		players_by_rarity[rarity] = []
	players_by_rarity[rarity].append(card)

func _add_to_league_cache(card: PlayerCard) -> void:
	var league: String = card.league_name.strip_edges()
	if league == "":
		return
	if not players_by_league.has(league):
		players_by_league[league] = []
	players_by_league[league].append(card)

# НОВЫЙ МЕТОД: Кэширование имени для поиска за O(1)
func _add_to_name_cache(card: PlayerCard) -> void:
	var name_lower: String = card.player_name.strip_edges().to_lower()
	if name_lower != "":
		players_by_name_lower[name_lower] = card.id
	
	var long_name_lower: String = card.long_name.strip_edges().to_lower()
	if long_name_lower != "" and long_name_lower != name_lower:
		players_by_name_lower[long_name_lower] = card.id

# ============================================================
# ПОЛУЧЕНИЕ ДАННЫХ
# ============================================================

func get_all_players() -> Array[PlayerCard]:
	return database.duplicate()

func get_player_count() -> int:
	return database.size()

func get_player_by_id(player_id: String) -> PlayerCard:
	for card: PlayerCard in database:
		if card.id == player_id:
			return card
	return null

# НОВЫЙ МЕТОД: Мгновенный поиск ID по имени (O(1))
func get_player_id_by_name_lower(target_name: String) -> String:
	var target: String = target_name.strip_edges().to_lower()
	if players_by_name_lower.has(target):
		return players_by_name_lower[target]
	return ""

func get_players_by_position(position: String) -> Array[PlayerCard]:
	var result: Array[PlayerCard] = []
	var target: String = position.strip_edges().to_upper()
	if target == "":
		return result

	if players_by_position.has(target):
		for value: Variant in players_by_position[target]:
			if value is PlayerCard:
				result.append(value)
		return result

	for card: PlayerCard in database:
		if card.has_position(target):
			result.append(card)
	return result

func get_players_by_rarity(rarity: String) -> Array[PlayerCard]:
	var result: Array[PlayerCard] = []
	var target: String = rarity.strip_edges().to_upper()
	if target == "" or not players_by_rarity.has(target):
		return result
	for value: Variant in players_by_rarity[target]:
		if value is PlayerCard:
			result.append(value)
	return result

func get_players_by_rating(min_rating: int, max_rating: int) -> Array[PlayerCard]:
	var result: Array[PlayerCard] = []
	for card: PlayerCard in database:
		if card.rating >= min_rating and card.rating <= max_rating:
			result.append(card)
	return result

func get_players_by_league(league_name: String) -> Array[PlayerCard]:
	var result: Array[PlayerCard] = []
	var target: String = league_name.strip_edges()
	if target == "" or not players_by_league.has(target):
		return result
	for value: Variant in players_by_league[target]:
		if value is PlayerCard:
			result.append(value)
	return result

func get_random_player() -> PlayerCard:
	return database.pick_random() if not database.is_empty() else null

func get_random_player_by_position(position: String) -> PlayerCard:
	var pool: Array[PlayerCard] = get_players_by_position(position)
	return pool.pick_random() if not pool.is_empty() else null

func get_random_player_by_rarity(rarity: String) -> PlayerCard:
	var pool: Array[PlayerCard] = get_players_by_rarity(rarity)
	return pool.pick_random() if not pool.is_empty() else null

func get_random_player_by_rating(min_rating: int, max_rating: int) -> PlayerCard:
	var pool: Array[PlayerCard] = get_players_by_rating(min_rating, max_rating)
	return pool.pick_random() if not pool.is_empty() else null

func get_players_filtered(position: String = "", min_rating: int = 0, max_rating: int = 999, rarity: String = "") -> Array[PlayerCard]:
	var result: Array[PlayerCard] = []
	for card: PlayerCard in database:
		if position != "" and not card.has_position(position):
			continue
		if card.rating < min_rating or card.rating > max_rating:
			continue
		if rarity != "" and card.rarity.to_upper() != rarity.to_upper():
			continue
		result.append(card)
	return result

func calculate_rarity(card: PlayerCard) -> String:
	if card.rating >= 90: return "ELITE"
	if card.rating >= 85: return "GOLD"
	if card.rating >= 78: return "SILVER"
	return "BRONZE"

func get_effective_rarity(card: PlayerCard) -> String:
	if card.rarity != "" and card.rarity.to_upper() != "BRONZE":
		return card.rarity.to_upper()
	return calculate_rarity(card)

func get_player_quality_score(card: PlayerCard) -> float:
	var score: float = float(card.rating) * 5.0
	if card.potential > 0:
		score += float(card.potential - card.rating) * 2.0
	score += float(card.pace + card.shooting + card.passing + card.dribbling + card.defending + card.physical) * 0.5
	score += float(card.international_reputation) * 2.0 + float(card.skill_moves) + float(card.weak_foot) * 0.5
	if card.sofascore_rating > 0.0:
		score += card.sofascore_rating * 3.0
	if card.transfermarkt_match_score > 0.0:
		score += card.transfermarkt_match_score * 2.0
	return score

func generate_draft_choice(pos: String = "") -> Array[PlayerCard]:
	var pool: Array[PlayerCard] = get_players_by_position(pos) if pos != "" else get_all_players()
	if pool.is_empty():
		return []

	pool.shuffle()
	var result: Array[PlayerCard] = []
	var used_ids: Dictionary = {}
	var attempts: int = 0
	var max_attempts: int = min(pool.size(), 200)

	while result.size() < DEFAULT_DRAFT_SIZE and attempts < max_attempts:
		var candidate: PlayerCard = pool[attempts]
		attempts += 1
		if candidate == null or used_ids.has(candidate.id):
			continue

		var chance: float = 1.0
		if candidate.rating >= 90: chance = 0.12
		elif candidate.rating >= 87: chance = 0.25
		elif candidate.rating >= 84: chance = 0.40
		elif candidate.rating >= 80: chance = 0.65

		if randf() > chance:
			continue

		used_ids[candidate.id] = true
		result.append(candidate)

	if result.size() < DEFAULT_DRAFT_SIZE:
		for candidate: PlayerCard in pool:
			if result.size() >= DEFAULT_DRAFT_SIZE:
				break
			if candidate == null or used_ids.has(candidate.id):
				continue
			used_ids[candidate.id] = true
			result.append(candidate)

	return result

func generate_draft_choice_by_rarity(pos: String, rarity: String) -> Array[PlayerCard]:
	var position_pool: Array[PlayerCard] = get_players_by_position(pos)
	var rarity_pool: Array[PlayerCard] = get_players_by_rarity(rarity)
	
	if position_pool.is_empty() or rarity_pool.is_empty():
		return generate_draft_choice(pos)

	var rarity_ids: Dictionary = {}
	for rarity_card: PlayerCard in rarity_pool:
		rarity_ids[rarity_card.id] = true

	var result: Array[PlayerCard] = []
	for card: PlayerCard in position_pool:
		if rarity_ids.has(card.id):
			result.append(card)

	if result.is_empty():
		return generate_draft_choice(pos)

	result.shuffle()
	if result.size() > DEFAULT_DRAFT_SIZE:
		result.resize(DEFAULT_DRAFT_SIZE)
	return result

func get_top_players(count: int = 10) -> Array[PlayerCard]:
	var sorted_players: Array[PlayerCard] = get_all_players()
	sorted_players.sort_custom(func(a: PlayerCard, b: PlayerCard) -> bool: return a.rating > b.rating)
	
	var result: Array[PlayerCard] = []
	var amount: int = min(count, sorted_players.size())
	for i in range(amount):
		result.append(sorted_players[i])
	return result

func reload_database() -> void:
	_load_database()

func print_database_statistics() -> void:
	print("========== CARD DATABASE ==========")
	print("Всего игроков: ", database.size())
	print("Позиций: ", players_by_position.size())
	print("Редкостей: ", players_by_rarity.size())
	print("Лиг: ", players_by_league.size())
	print("===================================")
