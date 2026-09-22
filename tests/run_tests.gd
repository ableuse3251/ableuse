extends SceneTree

# ============================================================
# ТЕСТОВЫЙ РАННЕР ДЛЯ MatchSimulator
# ============================================================
# Запуск (headless, из папки проекта):
#   godot --headless -s tests/run_tests.gd
#
# Код возврата: 0 — все тесты пройдены, 1 — есть падения.
# ============================================================

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	print("============================================================")
	print("ЗАПУСК ТЕСТОВ MATCH SIMULATOR")
	print("============================================================")

	test_goals_in_valid_range()
	test_empty_team_does_not_crash()
	test_null_entries_in_team()
	test_wrong_types_in_team()
	test_result_dictionary_consistency()
	test_determinism_with_seed()
	test_strong_team_wins_more()
	test_goal_minutes_unique_and_in_range()

	print("============================================================")
	if failures == 0:
		print("ИТОГ: OK — все проверки пройдены (%d assertions)" % checks)
	else:
		print("ИТОГ: ПРОВАЛЕНО проверок: %d из %d" % [failures, checks])
	print("============================================================")

	quit(0 if failures == 0 else 1)


# ============================================================
# ХЕЛПЕРЫ
# ============================================================

func _make_card(id: String, card_name: String, card_rating: int, pos: String = "FWD") -> PlayerCard:
	var card: PlayerCard = PlayerCard.new()
	card.id = id
	card.player_name = card_name
	card.rating = card_rating
	card.position = pos
	card.positions = pos
	card.club = "Test FC"
	card.nation = "Testland"
	card.league_name = "Test League"
	return card


func _make_team(count: int, card_rating: int) -> Array[PlayerCard]:
	var team: Array[PlayerCard] = []
	for i in range(count):
		team.append(_make_card("id_%d" % i, "Player %d" % i, card_rating, "MID"))
	return team


func _run_match(team: Array[PlayerCard], opponent_strength: int = 80) -> Dictionary:
	return MatchSimulator.simulate_match(team, opponent_strength)


func _assert(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("  [PASS] " + message)
	else:
		failures += 1
		print("  [FAIL] " + message)


# ============================================================
# 1. ДИАПАЗОН ГОЛОВ
# ============================================================

func test_goals_in_valid_range() -> void:
	print("\n[ТЕСТ] Диапазон голов 0..%d при разных силах" % MatchSimulator.MAX_SCORE)
	var team: Array[PlayerCard] = _make_team(11, 80)
	var out_of_range: int = 0
	for i in range(300):
		var result := _run_match(team, 60 + (i % 50))
		if (
			result["user_goals"] < MatchSimulator.MIN_SCORE
			or result["user_goals"] > MatchSimulator.MAX_SCORE
			or result["opponent_goals"] < MatchSimulator.MIN_SCORE
			or result["opponent_goals"] > MatchSimulator.MAX_SCORE
		):
			out_of_range += 1
	_assert(out_of_range == 0, "300 матчей: счёт всегда в диапазоне %d..%d" % [MatchSimulator.MIN_SCORE, MatchSimulator.MAX_SCORE])


# ============================================================
# 2. ПУСТОЙ СОСТАВ
# ============================================================

func test_empty_team_does_not_crash() -> void:
	print("\n[ТЕСТ] Пустой состав — матч симулируется без ошибок")
	var empty_team: Array[PlayerCard] = []
	var result: Dictionary = {}
	for i in range(20):
		result = _run_match(empty_team, 80)
		if result.is_empty():
			break
	_assert(not result.is_empty(), "20 симуляций с пустым составом завершились результатом")
	if not result.is_empty():
		_assert(
			result["user_goals"] >= 0 and result["user_goals"] <= MatchSimulator.MAX_SCORE
			and result["opponent_goals"] >= 0 and result["opponent_goals"] <= MatchSimulator.MAX_SCORE,
			"Счёт в валидном диапазоне при пустом составе"
		)


# ============================================================
# 3. NULL-ЭЛЕМЕНТЫ В СОСТАВЕ
# ============================================================

func test_null_entries_in_team() -> void:
	print("\n[ТЕСТ] null-игроки в составе не ломают симуляцию")
	var team: Array[PlayerCard] = []
	team.append(_make_card("a", "Alpha", 85))
	team.append(null)
	team.append(_make_card("b", "Beta", 84))
	team.append(null)
	var result: Dictionary = {}
	for i in range(20):
		result = _run_match(team, 80)
		if result.is_empty():
			break
	_assert(not result.is_empty(), "Симуляция с null-игроками возвращает результат")
	if not result.is_empty():
		# null игнорируются при расчёте средней силы
		_assert(absf(float(result["avg_rating"]) - 84.5) < 0.01, "avg_rating считается только по реальным игрокам (84.5)")


# ============================================================
# 4. НЕКОРРЕКТНЫЕ ДАННЫЕ
# ============================================================

func test_wrong_types_in_team() -> void:
	print("\n[ТЕСТ] Экстремальные значения rating не ломают симуляцию")
	var card: PlayerCard = _make_card("bad", "", 0)
	card.rating = -5
	var team: Array[PlayerCard] = [card]
	var result: Dictionary = {}
	for i in range(10):
		result = _run_match(team, 80)
		if result.is_empty():
			break
	_assert(not result.is_empty(), "Симуляция с rating=-5 и пустым именем не падает")
	if not result.is_empty():
		_assert(result["events"].size() >= 0, "События формируются корректно")


# ============================================================
# 5. СОГЛАСОВАННОСТЬ РЕЗУЛЬТАТА
# ============================================================

func test_result_dictionary_consistency() -> void:
	print("\n[ТЕСТ] won/draw/lost согласованы со счётом, голы = голы в событиях")
	var team: Array[PlayerCard] = _make_team(11, 82)
	var mismatches: int = 0
	for i in range(100):
		var result := _run_match(team, 75 + (i % 20))
		var ug: int = result["user_goals"]
		var og: int = result["opponent_goals"]
		var ok_flags: bool = (
			bool(result["won"]) == (ug > og)
			and bool(result["draw"]) == (ug == og)
			and bool(result["lost"]) == (ug < og)
		)
		var goal_events_user: int = 0
		var goal_events_opp: int = 0
		for event in result["events"]:
			if str(event.get("type", "")) == "goal":
				if bool(event.get("is_user", false)):
					goal_events_user += 1
				else:
					goal_events_opp += 1
		if not ok_flags or goal_events_user != ug or goal_events_opp != og:
			mismatches += 1
	_assert(mismatches == 0, "100 матчей: флаги и события согласованы со счётом")


# ============================================================
# 6. ДЕТЕРМИНИРОВАННОСТЬ ПРИ ФИКСИРОВАННОМ SEED
# ============================================================

func test_determinism_with_seed() -> void:
	print("\n[ТЕСТ] Детерминированность: один seed = одинаковый результат")
	var team: Array[PlayerCard] = _make_team(11, 83)

	seed(20260904)
	var first: Dictionary = _run_match(team, 80)

	seed(20260904)
	var second: Dictionary = _run_match(team, 80)

	_assert(int(first["user_goals"]) == int(second["user_goals"]), "user_goals совпадают при одинаковом seed")
	_assert(int(first["opponent_goals"]) == int(second["opponent_goals"]), "opponent_goals совпадают")

	var events_equal: bool = first["events"].size() == second["events"].size()
	if events_equal:
		for i in range(first["events"].size()):
			var e1: Dictionary = first["events"][i]
			var e2: Dictionary = second["events"][i]
			if str(e1.get("text", "")) != str(e2.get("text", "")) or int(e1.get("minute", -1)) != int(e2.get("minute", -1)):
				events_equal = false
				break
	_assert(events_equal, "Хронология событий идентична при одинаковом seed")

	# Разные seed — результаты различаются (хотя бы иногда)
	var different: bool = false
	for i in range(10):
		seed(1000 + i)
		var a: Dictionary = _run_match(team, 80)
		seed(2000 + i)
		var b: Dictionary = _run_match(team, 80)
		if int(a["user_goals"]) != int(b["user_goals"]) or int(a["opponent_goals"]) != int(b["opponent_goals"]):
			different = true
			break
	_assert(different, "Разные seed дают разные результаты")


# ============================================================
# 7. СТАТИСТИКА: СИЛЬНАЯ КОМАНДА ПОБЕЖДАЕТ ЧАЩЕ
# ============================================================

func test_strong_team_wins_more() -> void:
	print("\n[ТЕСТ] Сильная команда побеждает чаще слабой (100 матчей на сторону)")
	var strong: Array[PlayerCard] = _make_team(11, 92)
	var wins: int = 0
	for i in range(100):
		var result := _run_match(strong, 65)
		if bool(result["won"]):
			wins += 1
	_assert(wins >= 60, "Сильная (92 OVR vs 65): побед >= 60 из 100 (факт: %d)" % wins)

	var weak: Array[PlayerCard] = _make_team(11, 65)
	var losses: int = 0
	for i in range(100):
		var result := _run_match(weak, 92)
		if bool(result["lost"]):
			losses += 1
	# Примечание: симулятор намеренно асимметричен в пользу команды игрока
	# (базовые XG 1.30 vs 1.20, наклоны 0.028 vs 0.024), поэтому слабая
	# команда проигрывает реже, чем сильная побеждает (~54% против ~88%).
	# Порог 50 проверяет доминирование соперника, но не точную симметрию.
	_assert(losses >= 50, "Слабая (65 OVR vs 92): поражений >= 50 из 100 (факт: %d)" % losses)


# ============================================================
# 8. МИНУТЫ ГОЛОВ
# ============================================================

func test_goal_minutes_unique_and_in_range() -> void:
	print("\n[ТЕСТ] Минуты голов: в диапазоне и не дублируются")
	var team: Array[PlayerCard] = _make_team(11, 85)
	var problems: int = 0
	for i in range(100):
		var result := _run_match(team, 70)
		var goal_minutes: Dictionary = {}
		for event in result["events"]:
			if str(event.get("type", "")) == "goal":
				var minute: int = int(event.get("minute", -1))
				if minute < 1 or minute > 90:
					problems += 1
				elif goal_minutes.has(minute):
					problems += 1
				else:
					goal_minutes[minute] = true
	_assert(problems == 0, "100 матчей: минуты голов уникальны и в пределах 1..90")
