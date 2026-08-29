class_name MatchSummaryScreen
extends Control

# Сигналы оставлены для совместимости, если они используются где-то ещё
signal start_match_pressed
signal restart_draft_pressed

var container: VBoxContainer

var match_result: Dictionary = {}
var current_team: Array = []

var title_label: Label
var score_label: Label
var minute_label: Label
var status_label: Label
var events_label: RichTextLabel
var reward_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_setup_ui()


# ================================================================
# UI
# ================================================================

func _setup_ui() -> void:
	# ============================================================
	# ФОН
	# ============================================================
	var bg := ColorRect.new()
	bg.color = Color(0.018, 0.025, 0.042, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# ============================================================
	# ЦЕНТР
	# ============================================================
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# ============================================================
	# ОСНОВНАЯ ПАНЕЛЬ
	# ============================================================
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(390, 570)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.045, 0.058, 0.085, 0.99)
	panel_style.corner_radius_top_left = 24
	panel_style.corner_radius_top_right = 24
	panel_style.corner_radius_bottom_left = 24
	panel_style.corner_radius_bottom_right = 24
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(1, 1, 1, 0.10)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	# ============================================================
	# ВНУТРЕННИЕ ОТСТУПЫ
	# ============================================================
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	# ============================================================
	# ОСНОВНОЙ CONTAINER
	# ============================================================
	container = VBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 7)
	margin.add_child(container)

	# ============================================================
	# ВЕРХНЯЯ ПАНЕЛЬ (НОВАЯ)
	# ============================================================
	var top_bar := HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 50)
	top_bar.add_theme_constant_override("separation", 10)
	container.add_child(top_bar)

	var back_button := Button.new()
	back_button.text = "← Домой"
	back_button.custom_minimum_size = Vector2(100, 45)
	back_button.add_theme_font_size_override("font_size", 16)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_home_pressed)
	_apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	top_bar.add_child(back_button)

	var title := Label.new()
	title.text = "ИТОГИ МАТЧА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	top_bar.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(100, 45)
	top_bar.add_child(spacer)

	# ============================================================
	# ВЕРХНИЙ ЗАГОЛОВОК
	# ============================================================
	var match_label := Label.new()
	match_label.text = "МАТЧ ОКОНЧЕН"
	match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_label.add_theme_font_size_override("font_size", 11)
	match_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	container.add_child(match_label)

	# ============================================================
	# РЕЗУЛЬТАТ
	# ============================================================
	title_label = Label.new()
	title_label.text = "ИТОГ МАТЧА"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 27)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	container.add_child(title_label)

	# ============================================================
	# СЧЁТ — БОЛЬШАЯ КАРТОЧКА
	# ============================================================
	var score_panel := PanelContainer.new()
	score_panel.custom_minimum_size = Vector2(0, 130)
	var score_style := StyleBoxFlat.new()
	score_style.bg_color = Color(0.075, 0.095, 0.135, 1.0)
	score_style.corner_radius_top_left = 18
	score_style.corner_radius_top_right = 18
	score_style.corner_radius_bottom_left = 18
	score_style.corner_radius_bottom_right = 18
	score_style.border_width_left = 1
	score_style.border_width_right = 1
	score_style.border_width_top = 1
	score_style.border_width_bottom = 1
	score_style.border_color = Color(1, 1, 1, 0.08)
	score_panel.add_theme_stylebox_override("panel", score_style)
	container.add_child(score_panel)

	var score_box := VBoxContainer.new()
	score_box.alignment = BoxContainer.ALIGNMENT_CENTER
	score_box.add_theme_constant_override("separation", 2)
	score_panel.add_child(score_box)

	# ============================================================
	# КОМАНДЫ
	# ============================================================
	var teams_label := Label.new()
	teams_label.text = "ВАША КОМАНДА          СОПЕРНИК"
	teams_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	teams_label.add_theme_font_size_override("font_size", 11)
	teams_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	score_box.add_child(teams_label)

	# ============================================================
	# СЧЁТ
	# ============================================================
	score_label = Label.new()
	score_label.text = "— : —"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 50)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_box.add_child(score_label)

	# ============================================================
	# ВРЕМЯ
	# ============================================================
	minute_label = Label.new()
	minute_label.text = "90'"
	minute_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minute_label.add_theme_font_size_override("font_size", 11)
	minute_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	score_box.add_child(minute_label)

	# ============================================================
	# СТАТУС
	# ============================================================
	status_label = Label.new()
	status_label.text = "Матч завершён."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.custom_minimum_size = Vector2(0, 30)
	container.add_child(status_label)

	# ============================================================
	# ХРОНОЛОГИЯ
	# ============================================================
	var events_panel := PanelContainer.new()
	events_panel.custom_minimum_size = Vector2(0, 145)
	var events_style := StyleBoxFlat.new()
	events_style.bg_color = Color(0.035, 0.048, 0.070, 1.0)
	events_style.corner_radius_top_left = 15
	events_style.corner_radius_top_right = 15
	events_style.corner_radius_bottom_left = 15
	events_style.corner_radius_bottom_right = 15
	events_style.border_width_left = 1
	events_style.border_width_right = 1
	events_style.border_width_top = 1
	events_style.border_width_bottom = 1
	events_style.border_color = Color(1, 1, 1, 0.06)
	events_panel.add_theme_stylebox_override("panel", events_style)
	container.add_child(events_panel)

	var events_margin := MarginContainer.new()
	events_margin.add_theme_constant_override("margin_left", 10)
	events_margin.add_theme_constant_override("margin_right", 10)
	events_margin.add_theme_constant_override("margin_top", 8)
	events_margin.add_theme_constant_override("margin_bottom", 8)
	events_panel.add_child(events_margin)

	var events_box := VBoxContainer.new()
	events_box.add_theme_constant_override("separation", 3)
	events_margin.add_child(events_box)

	# ============================================================
	# ЗАГОЛОВОК ХРОНОЛОГИИ
	# ============================================================
	var events_title := Label.new()
	events_title.text = "ХРОНОЛОГИЯ"
	events_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	events_title.add_theme_font_size_override("font_size", 12)
	events_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	events_box.add_child(events_title)

	# ============================================================
	# СОБЫТИЯ
	# ============================================================
	events_label = RichTextLabel.new()
	events_label.bbcode_enabled = true
	events_label.fit_content = false
	events_label.scroll_active = true
	events_label.scroll_following = false
	events_label.custom_minimum_size = Vector2(0, 105)
	events_label.add_theme_font_size_override("normal_font_size", 13)
	events_box.add_child(events_label)

	# ============================================================
	# НАГРАДА
	# ============================================================
	reward_label = Label.new()
	reward_label.text = ""
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.add_theme_font_size_override("font_size", 15)
	reward_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	reward_label.custom_minimum_size = Vector2(0, 28)
	container.add_child(reward_label)

	# ============================================================
	# КНОПКИ (ОБНОВЛЁННЫЕ)
	# ============================================================
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	buttons.custom_minimum_size = Vector2(0, 44)
	container.add_child(buttons)

	# Кнопка "Домой"
	var home_button := Button.new()
	home_button.text = "🏠 Домой"
	home_button.custom_minimum_size = Vector2(0, 44)
	home_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_button.add_theme_font_size_override("font_size", 14)
	home_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	home_button.pressed.connect(_on_home_pressed)
	_apply_button_style(home_button, Color(0.10, 0.12, 0.17))
	buttons.add_child(home_button)

	# Кнопка "Магазин" (отличная возможность потратить заработанные монеты!)
	var store_button := Button.new()
	store_button.text = "📦 Магазин"
	store_button.custom_minimum_size = Vector2(0, 44)
	store_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	store_button.add_theme_font_size_override("font_size", 14)
	store_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	store_button.pressed.connect(_on_store_pressed)
	_apply_button_style(store_button, Color(0.4, 0.3, 0.1))
	buttons.add_child(store_button)


# ================================================================
# ПОЛУЧЕНИЕ РЕЗУЛЬТАТА
# ================================================================

func setup_summary(team: Array, result: Dictionary) -> void:
	current_team = team.duplicate()
	match_result = result.duplicate(true)

	var user_goals: int = int(match_result.get("user_goals", 0))
	var opponent_goals: int = int(match_result.get("opponent_goals", 0))
	var won: bool = bool(match_result.get("won", false))
	var draw: bool = bool(match_result.get("draw", false))

	# ============================================================
	# СЧЁТ
	# ============================================================
	score_label.text = str(user_goals) + " : " + str(opponent_goals)
	minute_label.text = "90' — МАТЧ ОКОНЧЕН"

	# ============================================================
	# РЕЗУЛЬТАТ
	# ============================================================
	if won:
		title_label.text = "🏆 ПОБЕДА"
		status_label.text = "Отличный матч! Команда забрала победу."
		score_label.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45))
		reward_label.text = "🎁 +500 монет"
	elif draw:
		title_label.text = "🤝 НИЧЬЯ"
		status_label.text = "Равный матч. Команды разделили очки."
		score_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		reward_label.text = "🎁 +300 монет"
	else:
		title_label.text = "МАТЧ ОКОНЧЕН"
		status_label.text = "На этот раз победить не удалось."
		score_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		reward_label.text = "🎁 +200 монет"

	# ============================================================
	# ХРОНОЛОГИЯ
	# ============================================================
	var events: Array = match_result.get("events", [])
	var events_text := ""

	if events.is_empty():
		events_text = "[color=#888888]• Матч прошёл без значимых событий.[/color]"
	else:
		for event_data in events:
			var event_text := str(event_data.get("text", "Событие матча"))
			var event_type := str(event_data.get("type", ""))
			var event_color := "#CCCCCC"

			match event_type:
				"goal":
					event_color = "#FFFFFF"
				"yellow":
					event_color = "#F5D742"
				"red":
					event_color = "#FF5C5C"
				"chance":
					event_color = "#AFC8FF"
				_:
					event_color = "#CCCCCC"

			events_text += "[color=" + event_color + "]" + event_text + "[/color]\n"

	events_label.text = events_text

	# ============================================================
	# СИГНАЛ
	# ============================================================
	start_match_pressed.emit()


# ================================================================
# НАВИГАЦИЯ
# ================================================================

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://StoreScreen.tscn")


# ================================================================
# СТИЛЬ КНОПКИ
# ================================================================

func _apply_button_style(button: Button, background_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = background_color
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(background_color.r + 0.06, 1.0), min(background_color.g + 0.06, 1.0), min(background_color.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(background_color.r - 0.04, 0.0), max(background_color.g - 0.04, 0.0), max(background_color.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)
