class_name MatchSimulator
extends RefCounted


# ================================================================
# НАСТРОЙКИ СИМУЛЯЦИИ
# ================================================================

const MINUTE_START: int = 1
const MINUTE_END: int = 90

const MIN_EXPECTED_GOALS: float = 0.25
const MAX_EXPECTED_GOALS: float = 3.50

const MIN_SCORE: int = 0
const MAX_SCORE: int = 7

const MIN_CHANCES: int = 4
const MAX_CHANCES: int = 8

const YELLOW_CARD_CHANCE: float = 0.035
const RED_CARD_CHANCE: float = 0.012


# ================================================================
# СИМУЛЯЦИЯ МАТЧА
# ================================================================

static func simulate_match(
	team: Array,
	opponent_strength: int = 80
) -> Dictionary:

	var total_rating: float = 0.0
	var valid_players: Array = []

	# ============================================================
	# ИГРОКИ
	# ============================================================

	for player in team:

		if player == null:
			continue

		var rating: int = _get_player_rating(player)

		total_rating += rating
		valid_players.append(player)

	var player_count: int = valid_players.size()

	if player_count <= 0:
		player_count = 1

	var avg_rating: float = (
		total_rating / float(player_count)
	)


	# ============================================================
	# СЫГРАННОСТЬ
	#
	# Диапазон: 0–33
	# Максимальный бонус: +10 к силе команды.
	# ============================================================

	var chemistry: float = 0.0

	if ChemistryManager:

		chemistry = float(
			ChemistryManager.calculate_team_chemistry(
				team
			)
		)

	chemistry = clamp(
		chemistry,
		0.0,
		33.0
	)


	# ============================================================
	# СИЛА КОМАНДЫ
	# ============================================================

	var chemistry_bonus: float = (
		chemistry / 33.0 * 10.0
	)

	var team_power: float = (
		avg_rating
		+ chemistry_bonus
	)


	# ============================================================
	# СЛУЧАЙНЫЙ ФАКТОР
	#
	# Небольшая вариативность каждого матча.
	# ============================================================

	var random_factor: float = randf_range(
		-5.0,
		5.0
	)

	var effective_power: float = (
		team_power
		+ random_factor
	)


	# ============================================================
	# РАЗНИЦА СИЛ
	# ============================================================

	var diff: float = (
		effective_power
		- float(opponent_strength)
	)


	# ============================================================
	# ОЖИДАЕМЫЕ ГОЛЫ
	#
	# При равных командах:
	# примерно 1.30 : 1.20
	#
	# Преимущество влияет на вероятность голов,
	# но не превращает матч в гарантированную победу.
	# ============================================================

	var user_expected_goals: float = (
		1.30
		+ diff * 0.028
	)

	var opponent_expected_goals: float = (
		1.20
		- diff * 0.024
	)

	user_expected_goals = clamp(
		user_expected_goals,
		MIN_EXPECTED_GOALS,
		MAX_EXPECTED_GOALS
	)

	opponent_expected_goals = clamp(
		opponent_expected_goals,
		MIN_EXPECTED_GOALS,
		MAX_EXPECTED_GOALS
	)


	# ============================================================
	# ГОЛЫ
	# ============================================================

	var user_goals: int = _roll_goals(
		user_expected_goals
	)

	var opponent_goals: int = _roll_goals(
		opponent_expected_goals
	)


	# ============================================================
	# ЗАЩИТА ОТ СТРАННЫХ РЕЗУЛЬТАТОВ
	#
	# Если разница сил большая, сильная команда немного
	# чаще избегает неожиданного поражения.
	# ============================================================

	if diff >= 12.0:

		if user_goals < opponent_goals:

			if randf() < 0.60:

				user_goals = min(
					opponent_goals,
					MAX_SCORE
				)


	elif diff <= -12.0:

		if opponent_goals < user_goals:

			if randf() < 0.60:

				opponent_goals = min(
					user_goals,
					MAX_SCORE
				)


	# ============================================================
	# ОГРАНИЧЕНИЕ СЧЁТА
	# ============================================================

	user_goals = clamp(
		user_goals,
		MIN_SCORE,
		MAX_SCORE
	)

	opponent_goals = clamp(
		opponent_goals,
		MIN_SCORE,
		MAX_SCORE
	)


	# ============================================================
	# СОБЫТИЯ МАТЧА
	# ============================================================

	var events: Array = []

	var available_scorers: Array = (
		valid_players.duplicate()
	)

	available_scorers.shuffle()


	# ============================================================
	# ОПАСНЫЕ МОМЕНТЫ
	# ============================================================

	_generate_match_moments(
		events,
		valid_players
	)


	# ============================================================
	# ГОЛЫ НАШЕЙ КОМАНДЫ
	# ============================================================

	for i in range(user_goals):

		var minute: int = _generate_goal_minute(
			events
		)

		var scorer = _choose_scorer(
			available_scorers
		)

		var scorer_name: String = (
			_get_player_name(scorer)
		)

		events.append(
			{
				"minute": minute,
				"text":
					"⚽ Гол! "
					+ scorer_name
					+ " ("
					+ str(minute)
					+ "')",
				"is_user": true,
				"type": "goal"
			}
		)


	# ============================================================
	# ГОЛЫ СОПЕРНИКА
	# ============================================================

	for i in range(opponent_goals):

		var minute: int = _generate_goal_minute(
			events
		)

		events.append(
			{
				"minute": minute,
				"text":
					"⚽ Гол соперника ("
					+ str(minute)
					+ "')",
				"is_user": false,
				"type": "goal"
			}
		)


	# ============================================================
	# СОРТИРОВКА СОБЫТИЙ
	# ================================================================

	events.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:

			var minute_a: int = int(
				a.get(
					"minute",
					0
				)
			)

			var minute_b: int = int(
				b.get(
					"minute",
					0
				)
			)

			if minute_a == minute_b:

				var type_a: String = str(
					a.get(
						"type",
						""
					)
				)

				var type_b: String = str(
					b.get(
						"type",
						""
					)
				)

				# Голы показываем после остальных событий
				# той же минуты.

				if type_a == "goal" and type_b != "goal":
					return false

				if type_a != "goal" and type_b == "goal":
					return true

				return false

			return minute_a < minute_b
	)


	# ============================================================
	# РЕЗУЛЬТАТ
	# ============================================================

	var won: bool = (
		user_goals > opponent_goals
	)

	var draw: bool = (
		user_goals == opponent_goals
	)

	var lost: bool = (
		user_goals < opponent_goals
	)


	# ============================================================
	# ВОЗВРАЩАЕМ РЕЗУЛЬТАТ
	# ============================================================

	return {
		"user_goals": user_goals,
		"opponent_goals": opponent_goals,

		"events": events,

		"won": won,
		"draw": draw,
		"lost": lost,

		"avg_rating": avg_rating,

		"chemistry": chemistry,
		"chemistry_bonus": chemistry_bonus,

		"team_power": team_power,
		"effective_power": effective_power,

		"opponent_strength": opponent_strength,
		"power_difference": diff,

		"user_expected_goals": user_expected_goals,
		"opponent_expected_goals": opponent_expected_goals
	}


# ================================================================
# НЕГОЛОВЫЕ СОБЫТИЯ
# ================================================================

static func _generate_match_moments(
	events: Array,
	players: Array
) -> void:

	if players.is_empty():
		return


	# ============================================================
	# ОПАСНЫЕ МОМЕНТЫ
	# ============================================================

	var chance_count: int = randi_range(
		MIN_CHANCES,
		MAX_CHANCES
	)

	for i in range(chance_count):

		var minute: int = randi_range(
			3,
			87
		)

		var chance_type: int = randi_range(
			0,
			4
		)

		var text: String

		match chance_type:

			0:
				text = (
					"🔥 Опасная атака вашей команды ("
					+ str(minute)
					+ "')"
				)

			1:
				text = (
					"🎯 Удар по воротам! Вратарь спасает ("
					+ str(minute)
					+ "')"
				)

			2:
				text = (
					"❌ Удар мимо ворот ("
					+ str(minute)
					+ "')"
				)

			3:
				text = (
					"🧤 Отличный сейв вратаря ("
					+ str(minute)
					+ "')"
				)

			_:
				text = (
					"💥 Соперник создаёт опасный момент ("
					+ str(minute)
					+ "')"
				)

		var is_user: bool = (
			chance_type != 4
		)

		events.append(
			{
				"minute": minute,
				"text": text,
				"is_user": is_user,
				"type": "chance"
			}
		)


	# ============================================================
	# ЖЁЛТЫЕ КАРТОЧКИ
	# ============================================================

	var yellow_count: int = randi_range(
		0,
		3
	)

	for i in range(yellow_count):

		var minute: int = randi_range(
			15,
			85
		)

		var is_user: bool = (
			randf() < 0.5
		)

		var player = players.pick_random()

		var player_name: String = (
			_get_player_name(player)
		)

		var text: String

		if is_user:

			text = (
				"🟨 "
				+ player_name
				+ " получает жёлтую карточку ("
				+ str(minute)
				+ "')"
			)

		else:

			text = (
				"🟨 Игрок соперника получает жёлтую карточку ("
				+ str(minute)
				+ "')"
			)

		events.append(
			{
				"minute": minute,
				"text": text,
				"is_user": is_user,
				"type": "yellow"
			}
		)


	# ============================================================
	# КРАСНАЯ КАРТОЧКА
	# ============================================================

	if randf() < 0.07:

		var minute: int = randi_range(
			25,
			82
		)

		var is_user: bool = (
			randf() < 0.5
		)

		var player = players.pick_random()

		var player_name: String = (
			_get_player_name(player)
		)

		var text: String

		if is_user:

			text = (
				"🟥 "
				+ player_name
				+ " удалён! ("
				+ str(minute)
				+ "')"
			)

		else:

			text = (
				"🟥 Игрок соперника удалён! ("
				+ str(minute)
				+ "')"
			)

		events.append(
			{
				"minute": minute,
				"text": text,
				"is_user": is_user,
				"type": "red"
			}
		)


# ================================================================
# ГЕНЕРАЦИЯ МИНУТЫ ГОЛА
#
# Не даём голам постоянно происходить на одной минуте.
# ================================================================

static func _generate_goal_minute(
	events: Array
) -> int:

	var minute: int

	for attempt in range(10):

		minute = randi_range(
			5,
			88
		)

		var occupied: bool = false

		for event_data in events:

			var event_minute: int = int(
				event_data.get(
					"minute",
					-1
				)
			)

			var event_type: String = str(
				event_data.get(
					"type",
					""
				)
			)

			if event_type == "goal" and event_minute == minute:

				occupied = true
				break

		if not occupied:
			return minute

	return minute


# ================================================================
# ПОЛУЧЕНИЕ РЕЙТИНГА ИГРОКА
# ================================================================

static func _get_player_rating(
	player
) -> int:

	if player == null:
		return 80

	if player.has_method("get"):

		var value = player.get(
			"rating"
		)

		if value != null:
			return int(value)

	return 80


# ================================================================
# ПОЛУЧЕНИЕ ИМЕНИ ИГРОКА
# ================================================================

static func _get_player_name(
	player
) -> String:

	if player == null:
		return "Игрок команды"

	if player.has_method("get"):

		var value = player.get(
			"player_name"
		)

		if value != null:

			var name_text := str(
				value
			)

			if not name_text.is_empty():
				return name_text

	return "Игрок команды"


# ================================================================
# РАСЧЁТ КОЛИЧЕСТВА ГОЛОВ
#
# Распределение Пуассона.
# ================================================================

static func _roll_goals(
	expected_goals: float
) -> int:

	expected_goals = max(
		expected_goals,
		0.05
	)

	var probability: float = 1.0

	var threshold: float = exp(
		-expected_goals
	)

	var goals: int = 0

	while probability > threshold:

		probability *= randf()

		goals += 1

		if goals >= 8:
			break

	return max(
		goals - 1,
		0
	)


# ================================================================
# ВЫБОР АВТОРА ГОЛА
# ================================================================

static func _choose_scorer(
	players: Array
):

	if players.is_empty():
		return null


	var total_weight: float = 0.0


	# ============================================================
	# СЧИТАЕМ ОБЩИЙ ВЕС
	# ============================================================

	for player in players:

		var rating: int = (
			_get_player_rating(player)
		)

		var position: String = ""

		if player.has_method("get"):

			var position_value = (
				player.get("position")
			)

			if position_value != null:

				position = str(
					position_value
				)

		var position_bonus: float = (
			_get_position_goal_bonus(
				position
			)
		)

		var weight: float = (
			max(
				rating - 50,
				1
			)
			* position_bonus
		)

		total_weight += weight


	if total_weight <= 0.0:
		return players.pick_random()


	# ============================================================
	# ВЫБИРАЕМ ИГРОКА
	# ============================================================

	var roll: float = randf_range(
		0.0,
		total_weight
	)

	var accumulated: float = 0.0

	for player in players:

		var rating: int = (
			_get_player_rating(player)
		)

		var position: String = ""

		if player.has_method("get"):

			var position_value = (
				player.get("position")
			)

			if position_value != null:

				position = str(
					position_value
				)

		var position_bonus: float = (
			_get_position_goal_bonus(
				position
			)
		)

		var weight: float = (
			max(
				rating - 50,
				1
			)
			* position_bonus
		)

		accumulated += weight

		if roll <= accumulated:
			return player


	return players.back()


# ================================================================
# БОНУС ПОЗИЦИИ ДЛЯ ГОЛА
# ================================================================

static func _get_position_goal_bonus(
	position: String
) -> float:

	var pos := position.to_upper()

	match pos:

		"ST":
			return 3.0

		"CF":
			return 2.7

		"RW":
			return 2.1

		"LW":
			return 2.1

		"CAM":
			return 1.8

		"RM":
			return 1.6

		"LM":
			return 1.6

		"CM":
			return 1.15

		"CDM":
			return 0.55

		"LB":
			return 0.35

		"RB":
			return 0.35

		"LWB":
			return 0.45

		"RWB":
			return 0.45

		"CB":
			return 0.20

		"GK":
			return 0.02

		_:
			return 1.0
