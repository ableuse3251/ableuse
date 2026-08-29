extends Node


# ============================================================
# КОЛЛЕКЦИЯ ИГРОКОВ
# ============================================================

var my_club_cards: Array[PlayerCard] = []


# ============================================================
# СТАРТОВЫЙ СОСТАВ
# ============================================================

var starting_lineup: Array[PlayerCard] = []


# ============================================================
# СОСТОЯНИЕ ЗАГРУЗКИ
# ============================================================

var _club_loaded: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Очень важно:
	#
	# CardDatabase и ClubManager являются Autoload.
	# CardDatabase должна сначала успеть загрузить players.json.
	#
	# Поэтому не загружаем клуб напрямую здесь.
	# Откладываем загрузку на следующий кадр.
	#
	# К этому моменту CardDatabase._ready()
	# уже должен завершить загрузку базы.

	call_deferred("_initialize_club")


# ============================================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================================

func _initialize_club() -> void:

	# Дополнительная защита.
	#
	# Если база ещё пустая, ждём следующий кадр.

	if CardDatabase.get_player_count() <= 0:

		print(
			"ClubManager: CardDatabase ещё не готова. Ожидание..."
		)

		call_deferred("_initialize_club")

		return


	print(
		"ClubManager: CardDatabase готова. Игроков в базе: ",
		CardDatabase.get_player_count()
	)


	load_club_cards()

	load_starting_lineup()

	_club_loaded = true


	print(
		"ClubManager: инициализация завершена."
	)


# ============================================================
# ДОБАВЛЕНИЕ ИГРОКА В КЛУБ
# ============================================================

func add_card_to_club(
	card: PlayerCard
) -> void:

	if card == null:
		return


	# Не добавляем одного игрока несколько раз.
	for existing_card: PlayerCard in my_club_cards:

		if existing_card.id == card.id:

			print(
				"ClubManager: игрок уже есть в клубе: ",
				card.player_name
			)

			return


	# Используем полноценную карточку из CardDatabase.
	#
	# Это гарантирует, что в клуб попадёт объект
	# со всеми характеристиками.

	var database_card: PlayerCard = (
		CardDatabase.get_player_by_id(
			card.id
		)
	)


	if database_card != null:

		card = database_card


	my_club_cards.append(card)


	print(
		"ClubManager: игрок добавлен в клуб: ",
		card.player_name,
		" | ID: ",
		card.id,
		" | Рейтинг: ",
		card.rating,
		" | PAC: ",
		card.pace,
		" | SHO: ",
		card.shooting,
		" | PAS: ",
		card.passing,
		" | DRI: ",
		card.dribbling,
		" | DEF: ",
		card.defending,
		" | PHY: ",
		card.physical
	)


	SaveManager.set_club_cards(
		my_club_cards
	)


# ============================================================
# ЗАГРУЗКА КОЛЛЕКЦИИ
# ============================================================

func load_club_cards() -> void:

	my_club_cards.clear()


	var saved_cards: Array = (
		SaveManager.get_club_cards()
	)


	print(
		"ClubManager: сохранённых карточек: ",
		saved_cards.size()
	)


	for card_data: Variant in saved_cards:

		if not card_data is Dictionary:
			continue


		var saved_id: String = str(
			card_data.get(
				"id",
				""
			)
		)


		var saved_name: String = str(
			card_data.get(
				"player_name",
				""
			)
		)


		var card: PlayerCard = null


		# --------------------------------------------------------
		# 1. ПЕРВЫЙ ВАРИАНТ — ПО ID
		# --------------------------------------------------------

		if saved_id != "":

			card = CardDatabase.get_player_by_id(
				saved_id
			)


		# --------------------------------------------------------
		# 2. FALLBACK ДЛЯ СТАРЫХ СОХРАНЕНИЙ
		#
		# Старое сохранение может содержать:
		#
		# bellingham
		# courtois
		# player_002
		#
		# а новая база содержит:
		#
		# 252371
		# ...
		#
		# Поэтому пробуем найти игрока по имени.
		# --------------------------------------------------------

		if card == null and saved_name != "":

			card = _find_player_by_name(
				saved_name
			)


		# --------------------------------------------------------
		# 3. Игрок не найден вообще.
		# --------------------------------------------------------

		if card == null:

			print(
				"ClubManager: игрок не найден.",
				" Старый ID: ",
				saved_id,
				" | Имя: ",
				saved_name
			)

			continue


		# --------------------------------------------------------
		# Защита от дублей.
		# --------------------------------------------------------

		var already_added: bool = false


		for existing_card: PlayerCard in my_club_cards:

			if existing_card.id == card.id:

				already_added = true
				break


		if already_added:

			continue


		# --------------------------------------------------------
		# Добавляем ПОЛНУЮ карточку из CardDatabase.
		#
		# Здесь уже есть:
		#
		# rating
		# potential
		# pace
		# shooting
		# passing
		# dribbling
		# defending
		# physical
		# weak_foot
		# skill_moves
		# и остальные данные.
		# --------------------------------------------------------

		my_club_cards.append(
			card
		)


		print(
			"ClubManager: загружен игрок: ",
			card.player_name,
			" | ID: ",
			card.id,
			" | Рейтинг: ",
			card.rating,
			" | PAC: ",
			card.pace,
			" | SHO: ",
			card.shooting,
			" | PAS: ",
			card.passing,
			" | DRI: ",
			card.dribbling,
			" | DEF: ",
			card.defending,
			" | PHY: ",
			card.physical
		)


	print(
		"ClubManager: загружено игроков: ",
		my_club_cards.size()
	)


# ============================================================
# ПОИСК ИГРОКА ПО ИМЕНИ
# ============================================================

func _find_player_by_name(
	target_name: String
) -> PlayerCard:

	var target: String = (
		target_name
		.strip_edges()
		.to_lower()
	)


	if target == "":
		return null


	for card: PlayerCard in CardDatabase.get_all_players():

		if card == null:
			continue


		var card_name: String = (
			card.player_name
			.strip_edges()
			.to_lower()
		)


		if card_name == target:

			print(
				"ClubManager: найден старый игрок по имени: ",
				target_name,
				" -> ",
				card.player_name,
				" | новый ID: ",
				card.id
			)

			return card


		# Дополнительно проверяем long_name.
		var long_name: String = (
			card.long_name
			.strip_edges()
			.to_lower()
		)


		if long_name != "" and long_name == target:

			print(
				"ClubManager: найден игрок по long_name: ",
				target_name,
				" -> ",
				card.long_name,
				" | новый ID: ",
				card.id
			)

			return card


	return null


# ============================================================
# ДОБАВИТЬ ИГРОКА В СТАРТОВЫЙ СОСТАВ
# ============================================================

func add_to_starting_lineup(
	card: PlayerCard
) -> bool:

	if card == null:
		return false


	# --------------------------------------------------------
	# Игрок должен находиться в клубе.
	# Проверяем по ID.
	# --------------------------------------------------------

	var player_is_in_club: bool = false


	for club_card: PlayerCard in my_club_cards:

		if club_card.id == card.id:

			player_is_in_club = true
			break


	if not player_is_in_club:

		print(
			"ClubManager: игрок отсутствует в клубе."
		)

		return false


	# --------------------------------------------------------
	# Не добавляем игрока дважды.
	# --------------------------------------------------------

	for lineup_card: PlayerCard in starting_lineup:

		if lineup_card.id == card.id:

			print(
				"ClubManager: игрок уже находится в составе: ",
				card.player_name
			)

			return false


	# --------------------------------------------------------
	# Максимум 11 игроков.
	# --------------------------------------------------------

	if starting_lineup.size() >= 11:

		print(
			"ClubManager: состав уже заполнен."
		)

		return false


	# --------------------------------------------------------
	# Находим именно объект из клуба.
	# --------------------------------------------------------

	var club_card_reference: PlayerCard = null


	for club_card: PlayerCard in my_club_cards:

		if club_card.id == card.id:

			club_card_reference = club_card
			break


	if club_card_reference == null:

		return false


	starting_lineup.append(
		club_card_reference
	)


	print(
		"ClubManager: игрок добавлен в состав: ",
		club_card_reference.player_name,
		" (",
		club_card_reference.position,
		")"
	)


	SaveManager.set_starting_lineup(
		starting_lineup
	)


	return true


# ============================================================
# УДАЛИТЬ ИГРОКА ИЗ СОСТАВА
# ============================================================

func remove_from_starting_lineup(
	card: PlayerCard
) -> bool:

	if card == null:
		return false


	var found_card: PlayerCard = null


	for lineup_card: PlayerCard in starting_lineup:

		if lineup_card.id == card.id:

			found_card = lineup_card
			break


	if found_card == null:

		return false


	starting_lineup.erase(
		found_card
	)


	print(
		"ClubManager: игрок убран из состава: ",
		found_card.player_name
	)


	SaveManager.set_starting_lineup(
		starting_lineup
	)


	return true


# ============================================================
# ПРОВЕРКА — ЕСТЬ ЛИ ИГРОК В СОСТАВЕ
# ============================================================

func is_in_starting_lineup(
	card: PlayerCard
) -> bool:

	if card == null:
		return false


	for lineup_card: PlayerCard in starting_lineup:

		if lineup_card.id == card.id:

			return true


	return false


# ============================================================
# ПОЛУЧИТЬ СОСТАВ
# ============================================================

func get_starting_lineup() -> Array[PlayerCard]:

	return starting_lineup


# ============================================================
# ОЧИСТИТЬ СОСТАВ
# ============================================================

func clear_starting_lineup() -> void:

	starting_lineup.clear()


	SaveManager.set_starting_lineup(
		starting_lineup
	)


	print(
		"ClubManager: стартовый состав очищен."
	)


# ============================================================
# ЗАГРУЗКА СОСТАВА
# ============================================================

func load_starting_lineup() -> void:

	starting_lineup.clear()


	var saved_lineup: Array = (
		SaveManager.get_starting_lineup()
	)


	for lineup_data: Variant in saved_lineup:

		if not lineup_data is Dictionary:
			continue


		var saved_id: String = str(
			lineup_data.get(
				"id",
				""
			)
		)


		if saved_id == "":
			continue


		# --------------------------------------------------------
		# Ищем игрока среди уже загруженных карточек клуба.
		# --------------------------------------------------------

		for card: PlayerCard in my_club_cards:

			if card.id == saved_id:

				starting_lineup.append(
					card
				)

				break


		# --------------------------------------------------------
		# Максимум 11.
		# --------------------------------------------------------

		if starting_lineup.size() >= 11:

			break


	print(
		"ClubManager: загружено игроков в составе: ",
		starting_lineup.size()
	)
