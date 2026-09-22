extends SceneTree

# ============================================================
# ТЕСТОВЫЙ РАННЕР: ChemistryManager + FormationManager
# ============================================================
# Запуск (headless, из папки проекта):
#   godot --headless -s tests/run_tests_managers.gd
# Код возврата: 0 — успех, 1 — есть падения.
# ============================================================

var failures: int = 0
var checks: int = 0

var fm: Node


func _initialize() -> void:
	print("============================================================")
	print("ЗАПУСК ТЕСТОВ CHEMISTRY MANAGER + FORMATION MANAGER")
	print("============================================================")

	fm = load("res://FormationManager.gd").new()

	test_chemistry_all_same_club_max()
	test_chemistry_no_overlap_zero()
	test_chemistry_club_thresholds()
	test_chemistry_nation_thresholds()
	test_chemistry_league_thresholds()
	test_chemistry_cap_per_player()
	test_chemistry_ignores_nulls()
	test_chemistry_empty_team()
	test_chemistry_realistic_mixed_team()

	test_formations_real_file_loads()
	test_formations_fallback_unknown_name()
	test_formations_fallback_empty_data()
	test_formations_default_formations_valid()
	test_formation_slots_validation_valid()
	test_formation_slots_validation_empty()
	test_formation_slots_validation_bad_entries()
	test_formation_slots_validation_coords()

	print("============================================================")
	if failures == 0:
		print("ИТОГ: OK — все проверки пройдены (%d assertions)" % checks)
	else:
		print("ИТОГ: ПРОВАЛЕНО проверок: %d из %d" % [failures, checks])
	print("============================================================")

	fm.free()
	quit(0 if failures == 0 else 1)


# ============================================================
# ХЕЛПЕРЫ
# ============================================================

func _assert(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("  [PASS] " + message)
	else:
		failures += 1
		print("  [FAIL] " + message)


func _make_card(id: String, club_name: String, nation_name: String, league: String) -> PlayerCard:
	var card: PlayerCard = PlayerCard.new()
	card.id = id
	card.player_name = "P" + id
	card.rating = 80
	card.position = "MID"
	card.club = club_name
	card.nation = nation_name
	card.league_name = league
	return card


func _chem(team: Array) -> int:
	var typed: Array[PlayerCard] = []
	for c in team:
		typed.append(c)
	return ChemistryManager.calculate_team_chemistry(typed)


# ============================================================
# ХИМИЯ: ВСЕ ИЗ ОДНОГО КЛУБА/ЛИГИ/НАЦИИ → МАКСИМУМ 33
# ============================================================

func test_chemistry_all_same_club_max() -> void:
	print("\n[ТЕСТ] Все игроки из одного клуба/лиги/нации → 33")
	var team: Array = []
	for i in range(11):
		team.append(_make_card(str(i), "One FC", "Brazil", "Premier League"))
	_assert(_chem(team) == 33, "11 одинаковых игроков дают максимум 33 (факт: %d)" % _chem(team))


# ============================================================
# ХИМИЯ: ПОЛНОСТЬЮ РАЗНЫЕ ИГРОКИ → 0
# ============================================================

func test_chemistry_no_overlap_zero() -> void:
	print("\n[ТЕСТ] Все из разных клубов/лиг/наций → 0")
	var team: Array = []
	for i in range(11):
		team.append(_make_card(str(i), "Club %d" % i, "Nation %d" % i, "League %d" % i))
	_assert(_chem(team) == 0, "Нет пересечений — химия 0 (факт: %d)" % _chem(team))


# ============================================================
# ХИМИЯ: ПОРОГИ ПО КЛУБУ (2/4/7)
# ============================================================

func test_chemistry_club_thresholds() -> void:
	print("\n[ТЕСТ] Пороги химии по клубу: 2 → +1, 4 → +2, 7 → +3 (на игрока)")
	var team2: Array = []
	for i in range(11):
		var club_name: String = "Same FC" if i < 2 else "Solo %d" % i
		team2.append(_make_card(str(i), club_name, "N%d" % i, "L%d" % i))
	_assert(_chem(team2) == 2, "2 игрока клуба → всего 2 (факт: %d)" % _chem(team2))

	var team4: Array = []
	for i in range(11):
		var club_name: String = "Same FC" if i < 4 else "Solo %d" % i
		team4.append(_make_card(str(i), club_name, "N%d" % i, "L%d" % i))
	_assert(_chem(team4) == 8, "4 игрока клуба → всего 8 (факт: %d)" % _chem(team4))

	var team7: Array = []
	for i in range(11):
		var club_name: String = "Same FC" if i < 7 else "Solo %d" % i
		team7.append(_make_card(str(i), club_name, "N%d" % i, "L%d" % i))
	_assert(_chem(team7) == 21, "7 игроков клуба → всего 21 (факт: %d)" % _chem(team7))


# ============================================================
# ХИМИЯ: ПОРОГИ ПО НАЦИИ (2/5/8)
# ============================================================

func test_chemistry_nation_thresholds() -> void:
	print("\n[ТЕСТ] Пороги химии по нации: 5 → +2 на игрока")
	var team5: Array = []
	for i in range(11):
		var nat: String = "Brazil" if i < 5 else "N%d" % i
		team5.append(_make_card(str(i), "C%d" % i, nat, "L%d" % i))
	_assert(_chem(team5) == 10, "5 игроков одной нации → всего 10 (факт: %d)" % _chem(team5))


# ============================================================
# ХИМИЯ: ПОРОГИ ПО ЛИГЕ (3/5/8), ПУСТАЯ ЛИГА
# ============================================================

func test_chemistry_league_thresholds() -> void:
	print("\n[ТЕСТ] Пороги химии по лиге: 3 → +1; пустая лига не даёт очков")
	var team3: Array = []
	for i in range(11):
		var lg: String = "La Liga" if i < 3 else "L%d" % i
		team3.append(_make_card(str(i), "C%d" % i, "N%d" % i, lg))
	_assert(_chem(team3) == 3, "3 игрока одной лиги → всего 3 (факт: %d)" % _chem(team3))

	var team_empty_league: Array = []
	for i in range(8):
		team_empty_league.append(_make_card(str(i), "C%d" % i, "N%d" % i, ""))
	team_empty_league.append(_make_card("x", "CX", "NX", "Real L"))
	team_empty_league.append(_make_card("y", "CY", "NY", "Real L"))
	team_empty_league.append(_make_card("z", "CZ", "NZ", "Real L"))
	# Все клубы/нации уникальны; "" в подсчёт лиг не попадает (0 очков),
	# а 3 игрока с "Real L" дают по +1 → 3
	_assert(_chem(team_empty_league) == 3, "Пустая лига даёт 0; 3 игрока 'Real L' дают 3 (факт: %d)" % _chem(team_empty_league))


# ============================================================
# ХИМИЯ: КАП 3 ОЧКА НА ИГРОКА
# ============================================================

func test_chemistry_cap_per_player() -> void:
	print("\n[ТЕСТ] Кап: не более 3 очков на игрока")
	var team: Array = []
	for i in range(11):
		var nat: String = "Brazil" if i < 8 else "N%d" % i
		var lg: String = "Big L" if i < 8 else "L%d" % i
		var club_name: String = "Mega FC" if i < 7 else "Solo %d" % i
		team.append(_make_card(str(i), club_name, nat, lg))
	# Расчёт: игроки 0..6 — клуб(≥7)+3, нация(≥8)+3, лига(≥8)+3 = 9 → кап 3 → 21;
	# игрок 7 — нация+лига = 6 → кап 3 → 3; игроки 8..10 — всё уникально → 0.
	# Итого 24 (проверяет, что кап не даёт превысить 3 на игрока).
	_assert(_chem(team) == 24, "Кап 3 на игрока: 7×3 + 3 + 0 = 24 (факт: %d)" % _chem(team))


# ============================================================
# ХИМИЯ: NULL-ИГРОКИ, ПУСТОЙ СОСТАВ
# ============================================================

func test_chemistry_ignores_nulls() -> void:
	print("\n[ТЕСТ] null-игроки не ломают химию")
	var team: Array = []
	for i in range(5):
		team.append(_make_card(str(i), "One FC", "Brazil", "Premier League"))
	team.append(null)
	team.append(null)
	_assert(_chem(team) == 15, "5 полных + 2 null → 15 (факт: %d)" % _chem(team))


func test_chemistry_empty_team() -> void:
	print("\n[ТЕСТ] Пустой состав → 0")
	_assert(_chem([]) == 0, "Пустой состав даёт 0")


# ============================================================
# ХИМИЯ: РЕАЛИСТИЧНАЯ СМЕШАННАЯ КОМАНДА
# ============================================================

func test_chemistry_realistic_mixed_team() -> void:
	print("\n[ТЕСТ] Реалистичная команда: 4+4+3 клуба, общая лига")
	var team: Array = []
	for i in range(4):
		team.append(_make_card("a%d" % i, "Arsenal", "England", "EPL"))
	for i in range(4):
		team.append(_make_card("b%d" % i, "Barcelona", "Spain", "EPL"))
	for i in range(3):
		team.append(_make_card("c%d" % i, "Chelsea", "France" if i < 2 else "Italy", "EPL"))
	# Каждая группа получает клуб+лига+нация ≥ 3 очков → кап 3 → 11*3 = 33
	_assert(_chem(team) == 33, "Клуб+лига+нация у каждого ≥3 → кап даёт 33 (факт: %d)" % _chem(team))


# ============================================================
# ФОРМАЦИИ: РЕАЛЬНЫЙ ФАЙЛ ЗАГРУЖАЕТСЯ И ВАЛИДЕН
# ============================================================

func test_formations_real_file_loads() -> void:
	print("\n[ТЕСТ] formations.json загружается, все схемы валидны")
	fm._load_formations()
	var all: Dictionary = fm.get_all_formations()
	_assert(not all.is_empty(), "Файл схем загружен, схем: %d" % all.size())
	_assert(all.has("4-4-2"), "Присутствует базовая схема 4-4-2")

	var invalid: Array[String] = []
	for formation_name in all.keys():
		if not fm.validate_formation_slots(all[formation_name]):
			invalid.append(str(formation_name))
	_assert(invalid.is_empty(), "Все схемы из файла проходят валидацию слотов (невалидны: %s)" % str(invalid))


# ============================================================
# ФОРМАЦИИ: НЕИЗВЕСТНОЕ ИМЯ → FALLBACK 4-4-2
# ============================================================

func test_formations_fallback_unknown_name() -> void:
	print("\n[ТЕСТ] Неизвестное имя схемы → слоты 4-4-2")
	fm.formations_data = fm._get_default_formations()
	var slots: Array = fm.get_formation_slots("9-0-1-fake")
	_assert(slots.size() == 11, "Fallback возвращает 11 слотов 4-4-2 (факт: %d)" % slots.size())


# ============================================================
# ФОРМАЦИИ: ПУСТЫЕ ДАННЫЕ → ПУСТОЙ МАССИВ (БЕЗ ПАДЕНИЯ)
# ============================================================

func test_formations_fallback_empty_data() -> void:
	print("\n[ТЕСТ] Пустой formations_data → пустой массив, без ошибок")
	fm.formations_data = {}
	var slots: Array = fm.get_formation_slots("4-4-2")
	_assert(slots.is_empty(), "Пустые данные → пустой массив слотов")
	fm.formations_data = fm._get_default_formations()


# ============================================================
# ФОРМАЦИИ: ДЕФОЛТНАЯ СХЕМА ВАЛИДНА
# ============================================================

func test_formations_default_formations_valid() -> void:
	print("\n[ТЕСТ] Встроенная дефолтная схема 4-4-2 корректна")
	var defaults: Dictionary = fm._get_default_formations()
	var slots: Array = defaults["4-4-2"]
	_assert(fm.validate_formation_slots(slots), "Дефолтная 4-4-2 проходит валидацию")
	_assert(slots.size() == 11, "В дефолтной схеме 11 слотов (факт: %d)" % slots.size())

	var gk_count: int = 0
	for slot in slots:
		if str(slot.get("position", "")) == "GK":
			gk_count += 1
	_assert(gk_count == 1, "Ровно один вратарь (факт: %d)" % gk_count)


# ============================================================
# ВАЛИДАЦИЯ СЛОТОВ: КОРРЕКТНЫЕ ДАННЫЕ
# ============================================================

func test_formation_slots_validation_valid() -> void:
	print("\n[ТЕСТ] Валидатор принимает корректные слоты")
	var good: Array = [
		{"position": "GK", "x": 0.5, "y": 0.9},
		{"position": "DEF", "x": 0.0, "y": 0.0},
		{"position": "FWD", "x": 1.0, "y": 1.0},
	]
	_assert(fm.validate_formation_slots(good), "Слоты с граничными координатами 0/1 валидны")


# ============================================================
# ВАЛИДАЦИЯ СЛОТОВ: ПУСТЫЕ И NULL
# ============================================================

func test_formation_slots_validation_empty() -> void:
	print("\n[ТЕСТ] Валидатор отклоняет пустой массив")
	_assert(not fm.validate_formation_slots([]), "Пустой массив слотов невалиден")


# ============================================================
# ВАЛИДАЦИЯ СЛОТОВ: НЕКОРРЕКТНЫЕ ЭЛЕМЕНТЫ
# ============================================================

func test_formation_slots_validation_bad_entries() -> void:
	print("\n[ТЕСТ] Валидатор отклоняет некорректные элементы")
	var not_dict: Array = [{"position": "GK", "x": 0.5, "y": 0.5}, "garbage"]
	_assert(not fm.validate_formation_slots(not_dict), "Не-Dictionary элемент невалиден")

	var empty_pos: Array = [{"position": "", "x": 0.5, "y": 0.5}]
	_assert(not fm.validate_formation_slots(empty_pos), "Пустая позиция невалидна")

	var missing_pos: Array = [{"x": 0.5, "y": 0.5}]
	_assert(not fm.validate_formation_slots(missing_pos), "Отсутствие position невалидно")


# ============================================================
# ВАЛИДАЦИЯ СЛОТОВ: КООРДИНАТЫ ВНЕ ДИАПАЗОНА
# ============================================================

func test_formation_slots_validation_coords() -> void:
	print("\n[ТЕСТ] Валидатор отклоняет координаты вне 0..1 и не-числа")
	var too_big: Array = [{"position": "GK", "x": 1.5, "y": 0.5}]
	_assert(not fm.validate_formation_slots(too_big), "x=1.5 невалиден")

	var negative: Array = [{"position": "GK", "x": 0.5, "y": -0.2}]
	_assert(not fm.validate_formation_slots(negative), "y=-0.2 невалиден")

	var not_number: Array = [{"position": "GK", "x": "левый", "y": 0.5}]
	_assert(not fm.validate_formation_slots(not_number), "x-строка невалидна")
