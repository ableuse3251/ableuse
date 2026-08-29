extends Node


# ============================================================
# CARD DATABASE
# ============================================================
#
# Главный источник данных:
#
# res://players.json
#
# JSON -> Dictionary -> PlayerCard
#
# CardDatabase используется как Autoload.
#
# ============================================================


const DATABASE_PATH: String = "res://players.json"

const DEFAULT_DRAFT_SIZE: int = 5


# ============================================================
# БАЗА
# ============================================================

var database: Array[PlayerCard] = []


# ============================================================
# КЭШИ
# ============================================================

var players_by_position: Dictionary = {}
var players_by_rarity: Dictionary = {}
var players_by_league: Dictionary = {}


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


	if not FileAccess.file_exists(DATABASE_PATH):

		push_error(
			"CardDatabase: файл не найден: "
			+ DATABASE_PATH
		)

		return


	var file: FileAccess = FileAccess.open(
		DATABASE_PATH,
		FileAccess.READ
	)


	if file == null:

		push_error(
			"CardDatabase: не удалось открыть "
			+ DATABASE_PATH
		)

		return


	var content: String = file.get_as_text()

	file.close()


	var parsed_data: Variant = JSON.parse_string(
		content
	)


	if parsed_data == null:

		push_error(
			"CardDatabase: JSON содержит ошибку."
		)

		return


	if not parsed_data is Dictionary:

		push_error(
			"CardDatabase: корневой объект JSON должен быть Dictionary."
		)

		return


	var players_data: Variant = parsed_data.get(
		"players",
		[]
	)


	if not players_data is Array:

		push_error(
			"CardDatabase: поле players должно быть Array."
		)

		return


	print("")
	print("============================================================")
	print("CARD DATABASE: НАЧАЛО ЗАГРУЗКИ")
	print("============================================================")
	print("JSON игроков: ", players_data.size())
	print("")


	# ========================================================
	# ЗАГРУЗКА ИГРОКОВ
	# ========================================================

	var debug_player_count: int = 0


	for player_data: Variant in players_data:

		if not player_data is Dictionary:
			continue


		var data: Dictionary = player_data


		# ----------------------------------------------------
		# ДИАГНОСТИКА JSON
		#
		# Проверяем первые 3 игроков.
		# ----------------------------------------------------

		if debug_player_count < 3:

			print("------------------------------------------------------------")
			print(
				"DEBUG JSON PLAYER #",
				debug_player_count + 1
			)

			print(
				"Name: ",
				data.get("name", "<нет>")
			)

			print(
				"ID: ",
				data.get("id", "<нет>")
			)

			print(
				"Rating: ",
				data.get("rating", "<нет>")
			)

			print(
				"Pace: ",
				data.get("pace", "<нет>")
			)

			print(
				"Shooting: ",
				data.get("shooting", "<нет>")
			)

			print(
				"Passing: ",
				data.get("passing", "<нет>")
			)

			print(
				"Dribbling: ",
				data.get("dribbling", "<нет>")
			)

			print(
				"Defending: ",
				data.get("defending", "<нет>")
			)

			print(
				"Physical: ",
				data.get("physical", "<нет>")
			)

			print("")
			print(
				"Тип pace: ",
				typeof(data.get("pace"))
			)

			print(
				"Тип shooting: ",
				typeof(data.get("shooting"))
			)

			print(
				"Тип passing: ",
				typeof(data.get("passing"))
			)

			print(
				"Тип dribbling: ",
				typeof(data.get("dribbling"))
			)

			print(
				"Тип defending: ",
				typeof(data.get("defending"))
			)

			print(
				"Тип physical: ",
				typeof(data.get("physical"))
			)

			print("")


		# ----------------------------------------------------
		# СОЗДАЁМ PLAYER CARD
		# ----------------------------------------------------

		var card: PlayerCard = PlayerCard.from_dictionary(
			data
		)


		if card == null:
			continue


		if card.id == "":
			continue


		# ----------------------------------------------------
		# ДИАГНОСТИКА ПОСЛЕ PlayerCard.from_dictionary()
		# ----------------------------------------------------

		if debug_player_count < 3:

			print(
				"PLAYER CARD ПОСЛЕ from_dictionary():"
			)

			print(
				"Name: ",
				card.player_name
			)

			print(
				"ID: ",
				card.id
			)

			print(
				"Rating: ",
				card.rating
			)

			print(
				"Pace: ",
				card.pace
			)

			print(
				"Shooting: ",
				card.shooting
			)

			print(
				"Passing: ",
				card.passing
			)

			print(
				"Dribbling: ",
				card.dribbling
			)

			print(
				"Defending: ",
				card.defending
			)

			print(
				"Physical: ",
				card.physical
			)

			print("")


			# ------------------------------------------------
			# ПРЯМОЕ СРАВНЕНИЕ
			# ------------------------------------------------

			print(
				"СРАВНЕНИЕ JSON -> CARD:"
			)

			print(
				"PACE: ",
				data.get("pace", "<нет>"),
				" -> ",
				card.pace
			)

			print(
				"SHOOTING: ",
				data.get("shooting", "<нет>"),
				" -> ",
				card.shooting
			)

			print(
				"PASSING: ",
				data.get("passing", "<нет>"),
				" -> ",
				card.passing
			)

			print(
				"DRIBBLING: ",
				data.get("dribbling", "<нет>"),
				" -> ",
				card.dribbling
			)

			print(
				"DEFENDING: ",
				data.get("defending", "<нет>"),
				" -> ",
				card.defending
			)

			print(
				"PHYSICAL: ",
				data.get("physical", "<нет>"),
				" -> ",
				card.physical
			)

			print("------------------------------------------------------------")
			print("")


		debug_player_count += 1


		database.append(card)

		_add_to_position_cache(card)
		_add_to_rarity_cache(card)
		_add_to_league_cache(card)


	print("")
	print("============================================================")
	print("CARD DATABASE: ЗАГРУЗКА ЗАВЕРШЕНА")
	print("============================================================")
	print(
		"CardDatabase: загружено игроков: ",
		database.size()
	)

	print(
		"CardDatabase: позиций в кэше: ",
		players_by_position.size()
	)

	print(
		"CardDatabase: редкостей в кэше: ",
		players_by_rarity.size()
	)

	print(
		"CardDatabase: лиг в кэше: ",
		players_by_league.size()
	)

	print("============================================================")
	print("")


# ============================================================
# КЭШ ПО ПОЗИЦИЯМ
# ============================================================

func _add_to_position_cache(
	card: PlayerCard
) -> void:

	var positions: String = card.positions


	if positions == "":
		positions = card.position


	var raw_positions: PackedStringArray = (
		positions
		.replace("/", ",")
		.split(",", false)
	)


	for raw_position: String in raw_positions:

		var position: String = (
			raw_position.strip_edges().to_upper()
		)


		if position == "":
			continue


		if not players_by_position.has(position):

			players_by_position[position] = []


		var position_array: Array = (
			players_by_position[position]
		)


		if not position_array.has(card):

			position_array.append(card)


	# Нормализованная позиция.

	var normalized_position: String = (
		card.position.to_upper()
	)


	if normalized_position == "":
		return


	if not players_by_position.has(
		normalized_position
	):

		players_by_position[normalized_position] = []


	var normalized_array: Array = (
		players_by_position[normalized_position]
	)


	if not normalized_array.has(card):

		normalized_array.append(card)


# ============================================================
# КЭШ ПО РЕДКОСТИ
# ============================================================

func _add_to_rarity_cache(
	card: PlayerCard
) -> void:

	var rarity: String = (
		card.rarity
		.strip_edges()
		.to_upper()
	)


	if rarity == "":
		rarity = "BRONZE"


	if not players_by_rarity.has(rarity):

		players_by_rarity[rarity] = []


	var rarity_array: Array = (
		players_by_rarity[rarity]
	)


	rarity_array.append(card)


# ============================================================
# КЭШ ПО ЛИГЕ
# ============================================================

func _add_to_league_cache(
	card: PlayerCard
) -> void:

	var league: String = (
		card.league_name
		.strip_edges()
	)


	if league == "":
		return


	if not players_by_league.has(league):

		players_by_league[league] = []


	var league_array: Array = (
		players_by_league[league]
	)


	league_array.append(card)


# ============================================================
# ВСЕ ИГРОКИ
# ============================================================

func get_all_players() -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []

	for card: PlayerCard in database:

		result.append(card)


	return result


# ============================================================
# КОЛИЧЕСТВО ИГРОКОВ
# ============================================================

func get_player_count() -> int:

	return database.size()


# ============================================================
# ИГРОК ПО ID
# ============================================================

func get_player_by_id(
	player_id: String
) -> PlayerCard:

	for card: PlayerCard in database:

		if card.id == player_id:

			return card


	return null


# ============================================================
# ИГРОКИ ПО ПОЗИЦИИ
# ============================================================

func get_players_by_position(
	position: String
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []

	var target: String = (
		position
		.strip_edges()
		.to_upper()
	)


	if target == "":
		return result


	if players_by_position.has(target):

		var cached: Array = (
			players_by_position[target]
		)


		for value: Variant in cached:

			if value is PlayerCard:

				result.append(value)


		return result


	for card: PlayerCard in database:

		if card.has_position(target):

			result.append(card)


	return result


# ============================================================
# ИГРОКИ ПО РЕДКОСТИ
# ============================================================

func get_players_by_rarity(
	rarity: String
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []

	var target: String = (
		rarity
		.strip_edges()
		.to_upper()
	)


	if target == "":
		return result


	if not players_by_rarity.has(target):

		return result


	var cached: Array = (
		players_by_rarity[target]
	)


	for value: Variant in cached:

		if value is PlayerCard:

			result.append(value)


	return result


# ============================================================
# ИГРОКИ ПО РЕЙТИНГУ
# ============================================================

func get_players_by_rating(
	min_rating: int,
	max_rating: int
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []


	for card: PlayerCard in database:

		if card.rating >= min_rating:

			if card.rating <= max_rating:

				result.append(card)


	return result


# ============================================================
# ИГРОКИ ПО POTENTIAL
# ============================================================

func get_players_by_potential(
	min_potential: int,
	max_potential: int
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []


	for card: PlayerCard in database:

		if card.potential <= 0:
			continue


		if card.potential >= min_potential:

			if card.potential <= max_potential:

				result.append(card)


	return result


# ============================================================
# ИГРОКИ ПО ЛИГЕ
# ============================================================

func get_players_by_league(
	league_name: String
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []

	var target: String = (
		league_name
		.strip_edges()
	)


	if target == "":
		return result


	if not players_by_league.has(target):

		return result


	var cached: Array = (
		players_by_league[target]
	)


	for value: Variant in cached:

		if value is PlayerCard:

			result.append(value)


	return result


# ============================================================
# ИГРОКИ ПО УРОВНЮ ЛИГИ
# ============================================================

func get_players_by_league_level(
	league_level: float
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []


	for card: PlayerCard in database:

		if is_equal_approx(
			card.league_level,
			league_level
		):

			result.append(card)


	return result


# ============================================================
# СЛУЧАЙНЫЙ ИГРОК
# ============================================================

func get_random_player() -> PlayerCard:

	if database.is_empty():

		return null


	return database.pick_random()


# ============================================================
# СЛУЧАЙНЫЙ ПО ПОЗИЦИИ
# ============================================================

func get_random_player_by_position(
	position: String
) -> PlayerCard:

	var pool: Array[PlayerCard] = (
		get_players_by_position(position)
	)


	if pool.is_empty():

		return null


	return pool.pick_random()


# ============================================================
# СЛУЧАЙНЫЙ ПО РЕДКОСТИ
# ============================================================

func get_random_player_by_rarity(
	rarity: String
) -> PlayerCard:

	var pool: Array[PlayerCard] = (
		get_players_by_rarity(rarity)
	)


	if pool.is_empty():

		return null


	return pool.pick_random()


# ============================================================
# СЛУЧАЙНЫЙ ПО РЕЙТИНГУ
# ============================================================

func get_random_player_by_rating(
	min_rating: int,
	max_rating: int
) -> PlayerCard:

	var pool: Array[PlayerCard] = (
		get_players_by_rating(
			min_rating,
			max_rating
		)
	)


	if pool.is_empty():

		return null


	return pool.pick_random()


# ============================================================
# ФИЛЬТРАЦИЯ
# ============================================================

func get_players_filtered(
	position: String = "",
	min_rating: int = 0,
	max_rating: int = 999,
	rarity: String = ""
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []


	for card: PlayerCard in database:

		if position != "":

			if not card.has_position(
				position
			):

				continue


		if card.rating < min_rating:
			continue


		if card.rating > max_rating:
			continue


		if rarity != "":

			if card.rarity.to_upper() != rarity.to_upper():

				continue


		result.append(card)


	return result


# ============================================================
# ОПРЕДЕЛЕНИЕ РЕДКОСТИ
# ============================================================

func calculate_rarity(
	card: PlayerCard
) -> String:

	if card.rating >= 90:

		return "ELITE"


	if card.rating >= 85:

		return "GOLD"


	if card.rating >= 78:

		return "SILVER"


	return "BRONZE"


# ============================================================
# ЭФФЕКТИВНАЯ РЕДКОСТЬ
# ============================================================

func get_effective_rarity(
	card: PlayerCard
) -> String:

	if (
		card.rarity != ""
		and card.rarity.to_upper() != "BRONZE"
	):

		return card.rarity.to_upper()


	return calculate_rarity(card)


# ============================================================
# ОЦЕНКА КАЧЕСТВА ИГРОКА
# ============================================================

func get_player_quality_score(
	card: PlayerCard
) -> float:

	var score: float = 0.0


	score += float(card.rating) * 5.0


	if card.potential > 0:

		score += float(
			card.potential - card.rating
		) * 2.0


	score += float(card.pace) * 0.5
	score += float(card.shooting) * 0.5
	score += float(card.passing) * 0.5
	score += float(card.dribbling) * 0.5
	score += float(card.defending) * 0.5
	score += float(card.physical) * 0.5


	score += float(
		card.international_reputation
	) * 2.0


	score += float(
		card.skill_moves
	)


	score += float(
		card.weak_foot
	) * 0.5


	if card.sofascore_rating > 0.0:

		score += (
			card.sofascore_rating
			* 3.0
		)


	if card.transfermarkt_match_score > 0.0:

		score += (
			card.transfermarkt_match_score
			* 2.0
		)


	return score


# ============================================================
# ДРАФТ
# ============================================================

func generate_draft_choice(
	pos: String = ""
) -> Array[PlayerCard]:

	var pool: Array[PlayerCard] = []


	if pos != "":

		pool = get_players_by_position(
			pos
		)


	if pool.is_empty():

		pool = get_all_players()


	if pool.is_empty():

		return []


	pool.shuffle()


	var result: Array[PlayerCard] = []

	var used_ids: Dictionary = {}


	var attempts: int = 0

	var max_attempts: int = min(
		pool.size(),
		200
	)


	while (
		result.size() < DEFAULT_DRAFT_SIZE
		and attempts < max_attempts
	):

		var candidate: PlayerCard = pool[attempts]

		attempts += 1


		if candidate == null:
			continue


		if used_ids.has(candidate.id):
			continue


		var chance: float = 1.0


		if candidate.rating >= 90:

			chance = 0.12

		elif candidate.rating >= 87:

			chance = 0.25

		elif candidate.rating >= 84:

			chance = 0.40

		elif candidate.rating >= 80:

			chance = 0.65

		else:

			chance = 1.0


		if randf() > chance:

			continue


		used_ids[candidate.id] = true

		result.append(candidate)


	if result.size() < DEFAULT_DRAFT_SIZE:

		for candidate: PlayerCard in pool:

			if result.size() >= DEFAULT_DRAFT_SIZE:

				break


			if candidate == null:
				continue


			if used_ids.has(candidate.id):
				continue


			used_ids[candidate.id] = true

			result.append(candidate)


	return result


# ============================================================
# ДРАФТ ПО РЕДКОСТИ
# ============================================================

func generate_draft_choice_by_rarity(
	pos: String,
	rarity: String
) -> Array[PlayerCard]:

	var result: Array[PlayerCard] = []


	var position_pool: Array[PlayerCard] = (
		get_players_by_position(pos)
	)


	var rarity_pool: Array[PlayerCard] = (
		get_players_by_rarity(rarity)
	)


	if position_pool.is_empty():

		return result


	if rarity_pool.is_empty():

		return generate_draft_choice(pos)


	var rarity_ids: Dictionary = {}


	for rarity_card: PlayerCard in rarity_pool:

		rarity_ids[rarity_card.id] = true


	for card: PlayerCard in position_pool:

		if rarity_ids.has(card.id):

			result.append(card)


	if result.is_empty():

		return generate_draft_choice(pos)


	result.shuffle()


	if result.size() > DEFAULT_DRAFT_SIZE:

		result.resize(
			DEFAULT_DRAFT_SIZE
		)


	return result


# ============================================================
# ЛУЧШИЕ ИГРОКИ
# ============================================================

func get_top_players(
	count: int = 10
) -> Array[PlayerCard]:

	var sorted_players: Array[PlayerCard] = (
		get_all_players()
	)


	sorted_players.sort_custom(
		func(
			a: PlayerCard,
			b: PlayerCard
		) -> bool:

			return a.rating > b.rating
	)


	var result: Array[PlayerCard] = []


	var amount: int = min(
		count,
		sorted_players.size()
	)


	for i in range(amount):

		result.append(
			sorted_players[i]
		)


	return result


# ============================================================
# ПЕРЕЗАГРУЗКА
# ============================================================

func reload_database() -> void:

	_load_database()


# ============================================================
# СТАТИСТИКА
# ============================================================

func print_database_statistics() -> void:

	print(
		"========== CARD DATABASE =========="
	)

	print(
		"Всего игроков: ",
		database.size()
	)

	print(
		"Позиций: ",
		players_by_position.size()
	)

	print(
		"Редкостей: ",
		players_by_rarity.size()
	)

	print(
		"Лиг: ",
		players_by_league.size()
	)

	print(
		"==================================="
	)
