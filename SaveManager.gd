extends Node

const SAVE_PATH: String = "user://save.json"

# ============================================================
# ВЕРСИОНИРОВАНИЕ ФОРМАТА СОХРАНЕНИЯ
# ============================================================
# SAVE_VERSION — текущая версия формата save-файла.
# Увеличивай её при каждом изменении структуры данных и добавляй
# миграцию в _upgrade_save_data() (инструкция — в блоке "МИГРАЦИИ").
#   0 — сейвы «до версионирования» (без поля save_version);
#   1 — первый версионированный формат (текущий).
const SAVE_VERSION: int = 1

var save_data: Dictionary = {}

func _ready() -> void:
	save_data = _default_save_data()

# Единый источник данных «с нуля»: используется при первом запуске,
# при отсутствующем/повреждённом файле и при сбросе прогресса.
func _default_save_data() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"coins": 1000,
		"club_cards": [],
		"starting_lineup": [],
		"substitutes": [],
		"formation": "4-4-2",
		"onboarding_completed": false,
		"master_volume": 1.0
	}

# ============================================================
# ЗАГРУЗКА / СОХРАНЕНИЕ
# ============================================================

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: сохранение не найдено. Используются начальные данные.")
		save_data = _default_save_data()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		UIFeedback.report_error("SaveManager", "Не удалось открыть файл сохранения.")
		save_data = _default_save_data()
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(content)
	if not (parsed_data is Dictionary):
		UIFeedback.report_error("SaveManager", "Файл сохранения повреждён. Используются начальные данные.")
		save_data = _default_save_data()
		return

	save_data = parsed_data

	# Миграция старого формата к актуальному.
	var upgraded: bool = _upgrade_save_data()

	# Страховка: даже в актуальном формате могло не хватать отдельных полей
	# (например, файл правили вручную) — дополняем значениями по умолчанию.
	_ensure_defaults(save_data)

	if upgraded:
		save_game()
	else:
		print("SaveManager: сохранение загружено (версия %d)." % _get_save_version())

func _ensure_defaults(data: Dictionary) -> void:
	if not data.has("starting_lineup"):
		data["starting_lineup"] = []
	if not data.has("club_cards"):
		data["club_cards"] = []
	if not data.has("substitutes"):
		data["substitutes"] = []
	if not data.has("coins"):
		data["coins"] = 1000
	if not data.has("formation"):
		data["formation"] = "4-4-2"
	if not data.has("onboarding_completed"):
		data["onboarding_completed"] = false
	if not data.has("master_volume"):
		data["master_volume"] = 1.0


# ============================================================
# МИГРАЦИИ ФОРМАТА СОХРАНЕНИЯ
# ============================================================
# КАК ДОБАВИТЬ НОВУЮ МИГРАЦИЮ:
#   1. Увеличь SAVE_VERSION на 1 (например, 1 -> 2).
#   2. Если появились новые поля — добавь их в _default_save_data().
#   3. Напиши функцию _migrate_vN_to_vN1(data: Dictionary), которая
#      переводит данные из версии N в N+1 (изменяет data на месте).
#      Миграция обязана быть идемпотентной (повторный запуск безопасен).
#   4. Зарегистрируй её в match внутри _upgrade_save_data() под ключом N.
#   5. Проверь, что старый сейв открывается и в файле появляется
#      новый save_version.
# ============================================================

# Приводит save_data к актуальной версии формата.
# Возвращает true, если данные изменились (тогда файл пересохраняется).
func _upgrade_save_data() -> bool:
	var from_version: int = _get_save_version()

	if from_version == SAVE_VERSION:
		return false

	if from_version > SAVE_VERSION:
		# Файл из более новой сборки игры: неизвестные поля сохраняем
		# как есть, миграции не запускаем (downgrade-safe).
		push_warning("SaveManager: версия сохранения %d новее поддерживаемой %d — миграция пропущена." % [from_version, SAVE_VERSION])
		return false

	var version: int = from_version
	while version < SAVE_VERSION:
		match version:
			# ── ЗАРЕГИСТРИРОВАННЫЕ МИГРАЦИИ ─────────────────────
			0:
				_migrate_v0_to_v1(save_data)
			# 1:
			#	_migrate_v1_to_v2(save_data)
			# ────────────────────────────────────────────────────
			_:
				push_warning("SaveManager: нет миграции с версии %d — данные будут дополнены значениями по умолчанию." % version)
				_ensure_defaults(save_data)
		version += 1

	save_data["save_version"] = SAVE_VERSION
	print("SaveManager: формат сохранения мигрирован: %d -> %d." % [from_version, SAVE_VERSION])
	return true


# Версия формата в текущих данных. Отсутствие/мусор => 0 (легаси-сейв).
func _get_save_version() -> int:
	var raw = save_data.get("save_version", 0)
	if raw is int:
		return int(raw)
	if raw is float:
		return int(raw)
	if raw is String and raw.is_valid_int():
		return int(raw)
	return 0


# v0 -> v1: сейв «до версионирования» (без поля save_version).
# Тогда часть ключей могла отсутствовать — дополняем значениями по умолчанию.
func _migrate_v0_to_v1(data: Dictionary) -> void:
	_ensure_defaults(data)


func save_game() -> void:
	# Помечаем файл актуальной версией формата, чтобы миграции не
	# запускались повторно. Номер версии сейва из более новой сборки
	# игры не понижаем.
	if _get_save_version() <= SAVE_VERSION:
		save_data["save_version"] = SAVE_VERSION

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		UIFeedback.report_error("SaveManager", "Не удалось создать файл сохранения.")
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("SaveManager: игра сохранена.")

# ============================================================
# НАСТРОЙКИ
# ============================================================

func is_onboarding_completed() -> bool:
	return bool(save_data.get("onboarding_completed", false))

func set_onboarding_completed(value: bool) -> void:
	save_data["onboarding_completed"] = value
	save_game()
	print("SaveManager: онбординг завершён = ", value)

func get_master_volume() -> float:
	var raw = save_data.get("master_volume", 1.0)
	if raw is float or raw is int:
		return clampf(float(raw), 0.0, 1.0)
	return 1.0

func set_master_volume(value: float) -> void:
	save_data["master_volume"] = clampf(value, 0.0, 1.0)
	save_game()
	print("SaveManager: громкость = ", save_data["master_volume"])

# ============================================================
# СБРОС ПРОГРЕССА
# ============================================================

func reset_progress() -> void:
	save_data = _default_save_data()
	save_game()
	print("SaveManager: прогресс сброшен. Начальные данные восстановлены.")

# ============================================================
# АТОМАРНЫЕ МЕТОДЫ СОХРАНЕНИЯ (RECOMMENDED API)
# ============================================================

func save_lineup_and_subs(lineup: Array, subs: Array) -> void:
	var lineup_data: Array = []
	for card in lineup:
		if card == null:
			lineup_data.append({"id": ""})
		elif card is PlayerCard:
			lineup_data.append({"id": card.id})
		else:
			lineup_data.append({"id": ""})

	var subs_data: Array = []
	for card in subs:
		if not card is PlayerCard:
			continue
		subs_data.append({"id": card.id})

	save_data["starting_lineup"] = lineup_data
	save_data["substitutes"] = subs_data
	save_game()
	print("SaveManager: сохранены состав (", lineup_data.size(), " слотов) и запасные (", subs_data.size(), " игроков) за одну операцию")

func set_formation(formation: String) -> void:
	save_data["formation"] = formation
	save_game()
	print("SaveManager: сохранена схема: ", formation)

# ============================================================
# СОВМЕСТИМОСТЬ (WRAPPERS, НЕ ДУБЛИРУЮТ ЛОГИКУ)
# ============================================================

func save_formation(formation: String) -> void:
	set_formation(formation)

func set_coins(value: int) -> void:
	save_data["coins"] = value
	save_game()

func get_coins(default_value: int = 1000) -> int:
	var raw = save_data.get("coins", default_value)
	if raw is int or raw is float:
		return int(maxf(float(raw), 0.0))
	# Повреждённое значение (строка, null, Dictionary и т.п.) — fallback.
	return default_value

func set_club_cards(cards: Array) -> void:
	var cards_data: Array = []
	for card in cards:
		if not card is PlayerCard:
			continue
		var card_data: Dictionary = {
			"id": card.id,
			"player_name": card.player_name,
			"rating": card.rating,
			"position": card.position,
			"club": card.club,
			"nation": card.nation,
			"rarity": card.rarity,
			"pace": card.pace,
			"shooting": card.shooting,
			"passing": card.passing,
			"dribbling": card.dribbling,
			"defending": card.defending,
			"physical": card.physical
		}
		cards_data.append(card_data)

	save_data["club_cards"] = cards_data
	save_game()
	print("SaveManager: сохранено карт клуба: ", cards_data.size())

func get_club_cards() -> Array:
	if save_data.has("club_cards") and save_data["club_cards"] is Array:
		return save_data["club_cards"]
	return []

func set_starting_lineup(lineup: Array) -> void:
	save_lineup_and_subs(lineup, get_substitutes())

func get_starting_lineup() -> Array:
	if save_data.has("starting_lineup") and save_data["starting_lineup"] is Array:
		return save_data["starting_lineup"]
	return []

func set_substitutes(subs: Array) -> void:
	save_lineup_and_subs(get_starting_lineup(), subs)

func get_substitutes() -> Array:
	if save_data.has("substitutes") and save_data["substitutes"] is Array:
		return save_data["substitutes"]
	return []

func get_formation() -> String:
	if save_data.has("formation") and save_data["formation"] is String:
		return save_data["formation"]
	return "4-4-2"
