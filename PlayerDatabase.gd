class_name PlayerDatabase
extends Node


# ============================================================
# НАСТРОЙКИ
# ============================================================

const DATABASE_PATH: String = "res://players.json"

const POSITION_GK: String = "GK"
const POSITION_DEF: String = "DEF"
const POSITION_MID: String = "MID"
const POSITION_FWD: String = "FWD"


# ============================================================
# БАЗА
# ============================================================

static var players: Array[Dictionary] = []

static var players_by_id: Dictionary = {}

static var players_by_position: Dictionary = {
	POSITION_GK: [],
	POSITION_DEF: [],
	POSITION_MID: [],
	POSITION_FWD: []
}

static var players_by_rarity: Dictionary = {
	"BRONZE": [],
	"SILVER": [],
	"GOLD": [],
	"ELITE": []
}


# ============================================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================================

static func _static_init() -> void:

	_load_database()


# ============================================================
# ЗАГРУЗКА БАЗЫ
# ============================================================

static func _load_database() -> void:

	players.clear()
	players_by_id.clear()

	players_by_position = {
		POSITION_GK: [],
		POSITION_DEF: [],
		POSITION_MID: [],
		POSITION_FWD: []
	}

	players_by_rarity = {
		"BRONZE": [],
		"SILVER": [],
		"GOLD": [],
		"ELITE": []
	}


	# --------------------------------------------------------
	# Проверка файла
	# --------------------------------------------------------

	if not FileAccess.file_exists(DATABASE_PATH):

		push_error(
			"PlayerDatabase: файл не найден: "
			+ DATABASE_PATH
		)

		return


	# --------------------------------------------------------
	# Открытие
	# --------------------------------------------------------

	var file: FileAccess = FileAccess.open(
		DATABASE_PATH,
		FileAccess.READ
	)

	if file == null:

		push_error(
			"PlayerDatabase: не удалось открыть "
			+ DATABASE_PATH
		)

		return


	var content: String = file.get_as_text()

	file.close()


	# --------------------------------------------------------
	# JSON
	# --------------------------------------------------------

	var parsed_data: Variant = JSON.parse_string(
		content
	)

	if not parsed_data is Dictionary:

		push_error(
			"PlayerDatabase: некорректный JSON."
		)

		return


	var root: Dictionary = parsed_data


	if not root.has("players"):

		push_error(
			"PlayerDatabase: в JSON отсутствует массив players."
		)

		return


	var raw_players: Variant = root["players"]


	if not raw_players is Array:

		push_error(
			"PlayerDatabase: players должен быть массивом."
		)

		return


	# --------------------------------------------------------
	# Обработка игроков
	# --------------------------------------------------------

	for raw_player in raw_players:

		if not raw_player is Dictionary:
			continue


		var player: Dictionary = _normalize_player(
			raw_player
		)


		var player_id: String = str(
			player.get("id", "")
		)


		if player_id.is_empty():
			continue


		players.append(
			player
		)


		players_by_id[player_id] = player


		# ----------------------------------------------------
		# Позиция
		# ----------------------------------------------------

		var position: String = str(
			player.get(
				"position",
				POSITION_MID
			)
		)


		if players_by_position.has(position):

			players_by_position[position].append(
				player
			)


		# ----------------------------------------------------
		# Редкость
		# ----------------------------------------------------

		var rarity: String = str(
			player.get(
				"rarity",
				"SILVER"
			)
		)


		if players_by_rarity.has(rarity):

			players_by_rarity[rarity].append(
				player
			)


	print(
		"PlayerDatabase: загружено игроков: ",
		players.size()
	)

	print(
		"PlayerDatabase: GK = ",
		players_by_position["GK"].size()
	)

	print(
		"PlayerDatabase: DEF = ",
		players_by_position["DEF"].size()
	)

	print(
		"PlayerDatabase: MID = ",
		players_by_position["MID"].size()
	)

	print(
		"PlayerDatabase: FWD = ",
		players_by_position["FWD"].size()
	)


# ============================================================
# НОРМАЛИЗАЦИЯ ИГРОКА
# ============================================================

static func _normalize_player(
	raw: Dictionary
) -> Dictionary:

	var player: Dictionary = {}


	# ========================================================
	# ОСНОВНАЯ ИНФОРМАЦИЯ
	# ========================================================

	player["id"] = str(
		raw.get(
			"id",
			""
		)
	)

	player["name"] = str(
		raw.get(
			"name",
			"Игрок"
		)
	)

	player["long_name"] = str(
		raw.get(
			"long_name",
			player["name"]
		)
	)


	player["rating"] = int(
		raw.get(
			"rating",
			75
		)
	)

	player["potential"] = int(
		raw.get(
			"potential",
			player["rating"]
		)
	)


	# ========================================================
	# ПОЗИЦИИ
	# ========================================================

	var positions: String = str(
		raw.get(
			"positions",
			""
		)
	)

	player["positions"] = positions


	var primary_position: String = str(
		raw.get(
			"position",
			""
		)
	)


	if primary_position.is_empty():

		primary_position = _detect_position(
			positions
		)


	player["position"] = primary_position


	# ========================================================
	# КЛУБ
	# ========================================================

	player["club"] = str(
		raw.get(
			"club",
			""
		)
	)

	player["club_position"] = str(
		raw.get(
			"club_position",
			""
		)
	)

	player["league"] = str(
		raw.get(
			"league",
			""
		)
	)

	player["league_level"] = int(
		raw.get(
			"league_level",
			0
		)
	)


	# ========================================================
	# СТРАНА
	# ========================================================

	player["nation"] = str(
		raw.get(
			"nation",
			""
		)
	)


	# ========================================================
	# ФИЗИКА
	# ========================================================

	player["age"] = int(
		raw.get(
			"age",
			0
		)
	)

	player["dob"] = str(
		raw.get(
			"dob",
			""
		)
	)

	player["height_cm"] = int(
		raw.get(
			"height_cm",
			0
		)
	)

	player["weight_kg"] = int(
		raw.get(
			"weight_kg",
			0
		)
	)


	# ========================================================
	# ТЕХНИКА
	# ========================================================

	player["preferred_foot"] = str(
		raw.get(
			"preferred_foot",
			""
		)
	)

	player["weak_foot"] = int(
		raw.get(
			"weak_foot",
			0
		)
	)

	player["skill_moves"] = int(
		raw.get(
			"skill_moves",
			0
		)
	)

	player["work_rate"] = str(
		raw.get(
			"work_rate",
			""
		)
	)


	# ========================================================
	# АТРИБУТЫ
	# ========================================================

	player["pace"] = int(
		raw.get(
			"pace",
			0
		)
	)

	player["shooting"] = int(
		raw.get(
			"shooting",
			0
		)
	)

	player["passing"] = int(
		raw.get(
			"passing",
			0
		)
	)

	player["dribbling"] = int(
		raw.get(
			"dribbling",
			0
		)
	)

	player["defending"] = int(
		raw.get(
			"defending",
			0
		)
	)

	player["physical"] = int(
		raw.get(
			"physical",
			0
		)
	)


	# ========================================================
	# ЭКОНОМИКА
	# ========================================================

	player["value_eur"] = int(
		raw.get(
			"value_eur",
			0
		)
	)

	player["wage_eur"] = int(
		raw.get(
			"wage_eur",
			0
		)
	)

	player["market_value_eur"] = int(
		raw.get(
			"market_value_eur",
			0
		)
	)


	# ========================================================
	# TRANSFERMARKT
	# ========================================================

	player["tm_match_score"] = float(
		raw.get(
			"tm_match_score",
			0.0
		)
	)

	player["position_tm"] = str(
		raw.get(
			"position_tm",
			""
		)
	)

	player["foot_tm"] = str(
		raw.get(
			"foot_tm",
			""
		)
	)

	player["contract_until"] = str(
		raw.get(
			"contract_until",
			""
		)
	)

	player["tm_league"] = str(
		raw.get(
			"tm_league",
			""
		)
	)


	# ========================================================
	# SOFASCORE
	# ========================================================

	player["sofascore_rating"] = float(
		raw.get(
			"sofascore_rating",
			0.0
		)
	)

	player["sofascore_appearances"] = int(
		raw.get(
			"sofascore_appearances",
			0
		)
	)

	player["sofascore_minutes"] = int(
		raw.get(
			"sofascore_minutes",
			0
		)
	)

	player["ss_league"] = str(
		raw.get(
			"ss_league",
			""
		)
	)


	# ========================================================
	# РЕДКОСТЬ
	# ========================================================

	var rarity: String = str(
		raw.get(
			"rarity",
			""
		)
	).to_upper()


	if rarity.is_empty():

		rarity = _calculate_rarity(
			player["rating"]
		)


	player["rarity"] = rarity


	# ========================================================
	# ФОТО
	# ========================================================

	player["photo"] = str(
		raw.get(
			"photo",
			""
		)
	)


	return player


# ============================================================
# ОПРЕДЕЛЕНИЕ ОСНОВНОЙ ПОЗИЦИИ
# ============================================================

static func _detect_position(
	positions_string: String
) -> String:

	var positions: Array[String] = []

	for value in positions_string.split(","):

		var position: String = value.strip_edges().to_upper()

		if not position.is_empty():

			positions.append(
				position
			)


	# GK

	for position in positions:

		if position == "GK":

			return POSITION_GK


	# DEF

	for position in positions:

		if position in [
			"CB",
			"LB",
			"RB",
			"LWB",
			"RWB",
			"LCB",
			"RCB"
		]:

			return POSITION_DEF


	# MID

	for position in positions:

		if position in [
			"CDM",
			"CM",
			"CAM",
			"LM",
			"RM",
			"LDM",
			"RDM",
			"LCM",
			"RCM"
		]:

			return POSITION_MID


	# FWD

	for position in positions:

		if position in [
			"ST",
			"CF",
			"LW",
			"RW",
			"LF",
			"RF"
		]:

			return POSITION_FWD


	return POSITION_MID


# ============================================================
# ОПРЕДЕЛЕНИЕ РЕДКОСТИ
# ============================================================

static func _calculate_rarity(
	rating: int
) -> String:

	if rating >= 90:

		return "ELITE"

	if rating >= 85:

		return "GOLD"

	if rating >= 75:

		return "SILVER"

	return "BRONZE"


# ============================================================
# СЛУЧАЙНЫЙ ИГРОК
# ============================================================

static func get_random_player() -> Dictionary:

	if players.is_empty():

		return {}

	return players.pick_random()


# ============================================================
# СЛУЧАЙНЫЙ ИГРОК ПО РЕДКОСТИ
# ============================================================

static func get_random_player_by_rarity(
	rarity: String
) -> Dictionary:

	var result: Array[Dictionary] = (
		get_players_by_rarity(rarity)
	)

	if result.is_empty():

		return {}

	return result.pick_random()


# ============================================================
# ИГРОК ПО ID
# ============================================================

static func get_player_by_id(
	player_id: String
) -> Dictionary:

	if players_by_id.has(player_id):

		return players_by_id[player_id]

	return {}


# ============================================================
# ИГРОКИ ПО ПОЗИЦИИ
# ============================================================

static func get_players_by_position(
	position: String
) -> Array[Dictionary]:

	var normalized_position: String = (
		position.to_upper()
	)

	if not players_by_position.has(
		normalized_position
	):

		return []

	return players_by_position[
		normalized_position
	]


# ============================================================
# СЛУЧАЙНЫЙ ИГРОК ПО ПОЗИЦИИ
# ============================================================

static func get_random_player_by_position(
	position: String
) -> Dictionary:

	var pool: Array[Dictionary] = (
		get_players_by_position(position)
	)

	if pool.is_empty():

		return {}

	return pool.pick_random()


# ============================================================
# ИГРОКИ ПО РЕДКОСТИ
# ============================================================

static func get_players_by_rarity(
	rarity: String
) -> Array[Dictionary]:

	var normalized_rarity: String = (
		rarity.to_upper()
	)

	if not players_by_rarity.has(
		normalized_rarity
	):

		return []

	return players_by_rarity[
		normalized_rarity
	]


# ============================================================
# ИГРОКИ ПО РЕЙТИНГУ
# ============================================================

static func get_players_by_rating(
	min_rating: int,
	max_rating: int
) -> Array[Dictionary]:

	var result: Array[Dictionary] = []

	for player in players:

		var rating: int = int(
			player.get(
				"rating",
				0
			)
		)


		if (
			rating >= min_rating
			and rating <= max_rating
		):

			result.append(
				player
			)


	return result


# ============================================================
# СЛУЧАЙНЫЕ ИГРОКИ ПО ПОЗИЦИИ
# ============================================================

static func get_random_players_by_position(
	position: String,
	count: int
) -> Array[Dictionary]:

	var pool: Array[Dictionary] = (
		get_players_by_position(position)
	)

	if pool.is_empty():

		return []


	var shuffled: Array[Dictionary] = (
		pool.duplicate()
	)

	shuffled.shuffle()


	var result: Array[Dictionary] = []

	var amount: int = min(
		count,
		shuffled.size()
	)


	for i in range(amount):

		result.append(
			shuffled[i]
		)


	return result
