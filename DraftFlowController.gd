class_name DraftFlowController
extends RefCounted

# ============================================================
# ЛОГИКА ДРАФТА (КОМПОНЕНТ PITCHSCREEN)
# ============================================================
# Полный цикл драфта: проверка сохранённого состава, старт
# нового драфта, выбор схемы, выбор игрока для слота,
# завершение драфта (ClubManager → Formation → Lineup → Save →
# Match) и показ сохранённого состава.
#
# Общее состояние (formation_slots, selected_slot_indices,
# current_selected_slot и т.д.) живёт в PitchScreen; здесь —
# только собственные флаги процесса и ссылка на экран.
# ============================================================

var screen: PitchScreen

var current_draft_screen: Node = null

var selecting_position: bool = false

var draft_in_progress: bool = false

var showing_saved_lineup: bool = false


func has_saved_lineup() -> bool:

	if not is_instance_valid(ClubManager):
		return false

	return ClubManager.starting_lineup.size() > 0


func start_new_draft() -> void:

	if draft_in_progress:
		return

	draft_in_progress = true
	showing_saved_lineup = false
	selecting_position = false
	screen.current_selected_slot = -1

	screen.field_renderer.clear_field_cards()
	position_buttons().clear()

	if is_instance_valid(current_draft_screen):
		current_draft_screen.queue_free()
		current_draft_screen = null

	PlayerData.clear_draft()
	screen.selected_formation.clear()
	screen.formation_slots.clear()
	screen.selected_slot_indices.clear()

	screen.update_chemistry_ui()
	open_formation_selection()


func open_formation_selection() -> void:

	if screen.formation_select_scene == null:
		push_error("PitchScreen: formation_select_scene не назначена.")
		draft_in_progress = false
		return

	var formation_screen := screen.formation_select_scene.instantiate()
	screen.add_child(formation_screen)

	if formation_screen.has_signal("formation_selected"):
		formation_screen.formation_selected.connect(on_formation_selected)
	else:
		push_error("FormationSelectScreen не имеет сигнала formation_selected.")


func on_formation_selected(formation: Dictionary) -> void:

	screen.selected_formation = formation.duplicate(true)

	screen.formation_slots.clear()
	screen.selected_slot_indices.clear()

	for slot in screen.selected_formation.get("slots", []):
		if slot is Dictionary:
			var transformed_slot: Dictionary = slot.duplicate(true)
			var old_x: float = float(slot.get("x", 0.5))
			var old_y: float = float(slot.get("y", 0.5))

			transformed_slot["x"] = 1.0 - old_y
			transformed_slot["y"] = old_x

			screen.formation_slots.append(transformed_slot)

	for child in screen.get_children():
		if child == current_draft_screen:
			continue
		if child.has_signal("formation_selected"):
			child.queue_free()

	screen.position_buttons_controller.create_buttons()
	selecting_position = true
	screen.current_selected_slot = -1
	screen._update_chemistry_display(0)
	screen._redraw_field()


func open_player_choice_for_slot(slot_index: int) -> void:

	if screen.draft_select_scene == null:
		push_error("PitchScreen: draft_select_scene не назначена.")
		return

	if slot_index < 0 or slot_index >= screen.formation_slots.size():
		return

	var actual_position: String = str(screen.formation_slots[slot_index].get("position", ""))
	var database_position := convert_position_to_database_category(actual_position)
	var choices: Array[PlayerCard] = CardDatabase.generate_draft_choice(database_position)

	if choices.is_empty():
		push_error("CardDatabase не смогла предоставить игроков для позиции: " + actual_position + " / категория: " + database_position)
		UIFeedback.show_error(tr("Нет доступных игроков для этой позиции"))
		return

	screen.position_buttons_controller.set_enabled(false)

	if is_instance_valid(current_draft_screen):
		current_draft_screen.queue_free()
		current_draft_screen = null

	current_draft_screen = screen.draft_select_scene.instantiate()
	screen.add_child(current_draft_screen)

	if current_draft_screen.has_signal("player_selected_on_screen"):
		current_draft_screen.player_selected_on_screen.connect(on_player_selected)
	else:
		push_error("DraftSelectScreen не имеет сигнала player_selected_on_screen.")

	if current_draft_screen.has_method("start_choice_for_position"):
		current_draft_screen.start_choice_for_position(actual_position, choices)


func convert_position_to_database_category(position: String) -> String:

	var normalized := position.to_upper().strip_edges()

	match normalized:
		"GK":
			return "GK"
		"LB", "CB", "RB", "LWB", "RWB":
			return "DEF"
		"LM", "CM", "RM", "CDM", "CAM":
			return "MID"
		"LW", "ST", "RW", "CF":
			return "FWD"
		_:
			return normalized


func position_buttons() -> PositionButtonsController:
	return screen.position_buttons_controller

# ============================================================
# ИГРОК ВЫБРАН
# ============================================================

func on_player_selected(selected_card: Variant) -> void:

	if is_instance_valid(current_draft_screen):
		current_draft_screen.queue_free()
		current_draft_screen = null

	if not selected_card is PlayerCard:
		push_error("Получен объект неизвестного типа вместо PlayerCard.")
		screen.position_buttons_controller.set_enabled(true)
		return

	var player_card: PlayerCard = selected_card

	if screen.current_selected_slot < 0:
		push_error("Игрок выбран, но текущая позиция не определена.")
		screen.position_buttons_controller.set_enabled(true)
		return

	var selected_slot := screen.current_selected_slot
	PlayerData.current_draft_team.append(player_card)
	screen.selected_slot_indices.append(selected_slot)

	screen.field_renderer.add_field_card(player_card, selected_slot)

	screen.position_buttons_controller.mark_filled(selected_slot)
	screen.current_selected_slot = -1
	screen.update_chemistry_ui()

	if screen.selected_slot_indices.size() >= screen.formation_slots.size():
		finish_draft()
	else:
		screen.position_buttons_controller.set_enabled(true)
		selecting_position = true

# ============================================================
# СОХРАНЁННЫЙ СОСТАВ
# ============================================================

func show_saved_lineup() -> void:

	showing_saved_lineup = true
	draft_in_progress = false
	selecting_position = false

	screen.field_renderer.clear_field_cards()
	position_buttons().clear()
	screen._update_chemistry_from_lineup()
	screen._create_draft_button()

	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	if lineup.is_empty():
		return

	screen.formation_slots.clear()

	# Берём слоты СОХРАНЁННОЙ формации; при устаревшем имени — 4-4-2;
	# если и его нет — захардкоженный fallback.
	var formation_name: String = ClubManager.get_current_formation()
	var saved_slots: Array = FormationManager.get_formation_slots(formation_name)
	if saved_slots.is_empty():
		saved_slots = FormationManager.get_formation_slots("4-4-2")

	var default_slots: Array[Dictionary] = [
		{"position": "GK", "x": 0.50, "y": 0.90},
		{"position": "DEF", "x": 0.18, "y": 0.72},
		{"position": "DEF", "x": 0.39, "y": 0.76},
		{"position": "DEF", "x": 0.61, "y": 0.76},
		{"position": "DEF", "x": 0.82, "y": 0.72},
		{"position": "MID", "x": 0.22, "y": 0.53},
		{"position": "MID", "x": 0.50, "y": 0.48},
		{"position": "MID", "x": 0.78, "y": 0.53},
		{"position": "FWD", "x": 0.22, "y": 0.27},
		{"position": "FWD", "x": 0.50, "y": 0.22},
		{"position": "FWD", "x": 0.78, "y": 0.27}
	]

	var raw_slots: Array = saved_slots if not saved_slots.is_empty() else default_slots

	for slot in raw_slots:
		if not slot is Dictionary:
			continue
		var transformed_slot: Dictionary = slot.duplicate(true)
		var old_x: float = float(slot.get("x", 0.5))
		var old_y: float = float(slot.get("y", 0.5))
		transformed_slot["x"] = 1.0 - old_y
		transformed_slot["y"] = old_x
		screen.formation_slots.append(transformed_slot)

	screen.selected_slot_indices.clear()

	for i in range(min(lineup.size(), screen.formation_slots.size())):
		var card: PlayerCard = lineup[i]
		screen.selected_slot_indices.append(i)
		if card != null:
			screen.field_renderer.add_field_card(card, i)
# ============================================================
# ЗАВЕРШЕНИЕ ДРАФТА (Draft → ClubManager → Formation → Lineup → Save → Match)
# ============================================================

func finish_draft() -> void:

	draft_in_progress = false
	selecting_position = false
	position_buttons().clear()

	# ============================================================
	# ШАГ 1: ВАЛИДАЦИЯ
	# ============================================================
	var expected_count: int = screen.formation_slots.size()
	if PlayerData.current_draft_team.size() < expected_count:
		push_error("PitchScreen.finish_draft: драфт не завершён, но выбрано только " + str(PlayerData.current_draft_team.size()) + " из " + str(expected_count) + " игроков. Отмена.")
		return

	if not is_instance_valid(ClubManager):
		push_error("PitchScreen.finish_draft: ClubManager не доступен.")
		return

	# ============================================================
	# ШАГ 2: СОСТАВИТЬ LINEUP В ПОРЯДКЕ СЛОТОВ ФОРМАЦИИ
	# ============================================================
	var ordered_lineup: Array[PlayerCard] = []
	ordered_lineup.resize(expected_count)
	for i in range(expected_count):
		ordered_lineup[i] = null

	for idx in range(screen.selected_slot_indices.size()):
		var slot_idx: int = screen.selected_slot_indices[idx]
		var card: PlayerCard = PlayerData.current_draft_team[idx]
		if slot_idx >= 0 and slot_idx < expected_count and card != null:
			ordered_lineup[slot_idx] = card

	# ============================================================
	# ШАГ 3: ДОБАВИТЬ ВСЕ ИГРОКИ В КЛУБ (ОДНО СОХРАНЕНИЕ)
	# ============================================================
	var cards_to_add: Array[PlayerCard] = []
	for c in PlayerData.current_draft_team:
		if c == null:
			continue
		if c in ClubManager.club_cards:
			continue
		cards_to_add.append(c)

	if not cards_to_add.is_empty():
		ClubManager.add_cards_to_club_batch(cards_to_add)

	# ============================================================
	# ШАГ 4: СОХРАНИТЬ ФОРМАЦИЮ
	# ============================================================
	var formation_name: String = str(screen.selected_formation.get("name", ClubManager.current_formation))
	if not formation_name.is_empty():
		ClubManager.set_formation(formation_name)
		print("PitchScreen.finish_draft: формация драфта сохранена: ", formation_name)

	# ============================================================
	# ШАГ 5: ЗАПИСАТЬ STARTING LINEUP И ОЧИСТИТЬ ЗАПАСНЫЕ
	# ============================================================
	ClubManager.starting_lineup = ordered_lineup.duplicate()
	ClubManager.substitutes.clear()
	SaveManager.save_lineup_and_subs(ClubManager.starting_lineup, ClubManager.substitutes)
	print("PitchScreen.finish_draft: стартовый сохранён (", ordered_lineup.size(), " слотов, запасные очищены.")

	# ============================================================
	# ШАГ 6: ФИНАЛЬНОЕ СОХРАНЕНИЕ ВСЕГО СОСТОЯНИЯ
	# ============================================================
	if SaveManager and SaveManager.has_method("save_game"):
		SaveManager.save_game()

	# ============================================================
	# ШАГ 7: ЗАПУСК МАТЧА (ТОЛЬКО ПОСЛЕ СОХРАНЕНИЯ!)
	# ============================================================
	var match_scene := load("res://MatchScreen.tscn") as PackedScene

	if match_scene == null:
		push_error("Не удалось загрузить res://MatchScreen.tscn")
		UIFeedback.show_error(tr("Не удалось запустить матч"))
		if screen.summary_screen_scene:
			var summary := screen.summary_screen_scene.instantiate()
			screen.add_child(summary)
		return

	var match_screen := match_scene.instantiate()
	screen.add_child(match_screen)

	if match_screen.has_method("setup"):
		match_screen.setup(ordered_lineup)

	print("PitchScreen.finish_draft: УСПЕХ — драфт_team: ", cards_to_add.size(), " новых игроков в клубе, матч запущен.")