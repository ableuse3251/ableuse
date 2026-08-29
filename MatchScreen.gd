class_name MatchScreen
extends Control


# ================================================================
# ДАННЫЕ МАТЧА
# ================================================================

var team: Array = []
var match_result: Dictionary = {}

var home_name_label: Label
var away_name_label: Label
var home_score_label: Label
var away_score_label: Label
var minute_label: Label
var status_label: Label
var event_label: Label
var progress_bar: ProgressBar
var play_button: Button
var back_button: Button

var current_event_index: int = 0
var current_minute: int = 0

var match_started: bool = false
var match_finished: bool = false
var reward_given: bool = false

var match_timer: Timer


# ================================================================
# ПОЛУЧЕНИЕ КОМАНДЫ
# ================================================================

func setup(
	match_team: Array
) -> void:

	team = match_team.duplicate()

	if is_node_ready():
		_start_match()


# ================================================================
# READY
# ================================================================

func _ready() -> void:

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_ui()

	if team.size() > 0:
		_start_match()


# ================================================================
# ПОСТРОЕНИЕ UI
# ================================================================

func _build_ui() -> void:

	# ============================================================
	# ФОН
	# ============================================================

	var background := ColorRect.new()

	background.color = Color(
		0.025,
		0.035,
		0.055,
		1.0
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)


	# ============================================================
	# ОСНОВНОЙ CONTAINER
	# ============================================================

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		25
	)

	margin.add_theme_constant_override(
		"margin_right",
		25
	)

	margin.add_theme_constant_override(
		"margin_top",
		20
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(margin)


	var main := VBoxContainer.new()

	main.alignment = BoxContainer.ALIGNMENT_BEGIN

	main.add_theme_constant_override(
		"separation",
		14
	)

	main.mouse_filter = Control.MOUSE_FILTER_IGNORE

	margin.add_child(main)


	# ============================================================
	# ВЕРХНЯЯ ПАНЕЛЬ
	# ============================================================

	var top_bar := HBoxContainer.new()

	top_bar.custom_minimum_size = Vector2(
		0,
		50
	)

	top_bar.add_theme_constant_override(
		"separation",
		10
	)

	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main.add_child(top_bar)


	back_button = Button.new()

	back_button.text = "←"

	back_button.custom_minimum_size = Vector2(
		50,
		45
	)

	back_button.add_theme_font_size_override(
		"font_size",
		24
	)

	back_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	back_button.pressed.connect(
		_on_back_pressed
	)

	_apply_button_style(
		back_button,
		Color(
			0.10,
			0.12,
			0.17
		)
	)

	top_bar.add_child(
		back_button
	)


	var title := Label.new()

	title.text = "MATCH DAY"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	title.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.85,
			0.25
		)
	)

	top_bar.add_child(
		title
	)


	var spacer := Control.new()

	spacer.custom_minimum_size = Vector2(
		50,
		45
	)

	top_bar.add_child(
		spacer
	)


	# ============================================================
	# СЧЁТ
	# ============================================================

	var score_panel := PanelContainer.new()

	score_panel.custom_minimum_size = Vector2(
		0,
		210
	)

	var score_style := StyleBoxFlat.new()

	score_style.bg_color = Color(
		0.055,
		0.075,
		0.11,
		1.0
	)

	score_style.corner_radius_top_left = 24
	score_style.corner_radius_top_right = 24
	score_style.corner_radius_bottom_left = 24
	score_style.corner_radius_bottom_right = 24

	score_style.border_width_left = 1
	score_style.border_width_right = 1
	score_style.border_width_top = 1
	score_style.border_width_bottom = 1

	score_style.border_color = Color(
		1,
		1,
		1,
		0.10
	)

	score_panel.add_theme_stylebox_override(
		"panel",
		score_style
	)

	main.add_child(
		score_panel
	)


	var score_box := VBoxContainer.new()

	score_box.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	score_box.add_theme_constant_override(
		"separation",
		8
	)

	score_panel.add_child(
		score_box
	)


	# ============================================================
	# КОМАНДЫ
	# ============================================================

	var teams_row := HBoxContainer.new()

	teams_row.custom_minimum_size = Vector2(
		0,
		45
	)

	teams_row.add_theme_constant_override(
		"separation",
		20
	)

	score_box.add_child(
		teams_row
	)


	home_name_label = Label.new()

	home_name_label.text = "ВАША КОМАНДА"

	home_name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	home_name_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	home_name_label.add_theme_font_size_override(
		"font_size",
		17
	)

	teams_row.add_child(
		home_name_label
	)


	var vs_label := Label.new()

	vs_label.text = "VS"

	vs_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	vs_label.custom_minimum_size = Vector2(
		40,
		40
	)

	vs_label.add_theme_font_size_override(
		"font_size",
		13
	)

	vs_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.45
		)
	)

	teams_row.add_child(
		vs_label
	)


	away_name_label = Label.new()

	away_name_label.text = "СОПЕРНИК"

	away_name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_LEFT
	)

	away_name_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	away_name_label.add_theme_font_size_override(
		"font_size",
		17
	)

	teams_row.add_child(
		away_name_label
	)


	# ============================================================
	# СЧЁТ
	# ============================================================

	var score_row := HBoxContainer.new()

	score_row.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	score_row.add_theme_constant_override(
		"separation",
		18
	)

	score_box.add_child(
		score_row
	)


	home_score_label = Label.new()

	home_score_label.text = "0"

	home_score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	home_score_label.custom_minimum_size = Vector2(
		80,
		65
	)

	home_score_label.add_theme_font_size_override(
		"font_size",
		52
	)

	score_row.add_child(
		home_score_label
	)


	var colon := Label.new()

	colon.text = ":"

	colon.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	colon.add_theme_font_size_override(
		"font_size",
		40
	)

	colon.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.4
		)
	)

	score_row.add_child(
		colon
	)


	away_score_label = Label.new()

	away_score_label.text = "0"

	away_score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	away_score_label.custom_minimum_size = Vector2(
		80,
		65
	)

	away_score_label.add_theme_font_size_override(
		"font_size",
		52
	)

	score_row.add_child(
		away_score_label
	)


	# ============================================================
	# ВРЕМЯ
	# ============================================================

	minute_label = Label.new()

	minute_label.text = "0'"

	minute_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	minute_label.add_theme_font_size_override(
		"font_size",
		18
	)

	minute_label.add_theme_color_override(
		"font_color",
		Color(
			0.3,
			0.9,
			0.5
		)
	)

	score_box.add_child(
		minute_label
	)


	# ============================================================
	# ПРОГРЕСС
	# ============================================================

	progress_bar = ProgressBar.new()

	progress_bar.min_value = 0
	progress_bar.max_value = 90
	progress_bar.value = 0

	progress_bar.custom_minimum_size = Vector2(
		0,
		10
	)

	progress_bar.show_percentage = false

	main.add_child(
		progress_bar
	)


	# ============================================================
	# СТАТУС
	# ============================================================

	status_label = Label.new()

	status_label.text = "МАТЧ НАЧИНАЕТСЯ"

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	status_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(
		status_label
	)


	# ============================================================
	# СОБЫТИЕ
	# ============================================================

	event_label = Label.new()

	event_label.text = (
		"Следим за событиями матча..."
	)

	event_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	event_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	event_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	event_label.custom_minimum_size = Vector2(
		0,
		80
	)

	event_label.add_theme_font_size_override(
		"font_size",
		17
	)

	event_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.85
		)
	)

	main.add_child(
		event_label
	)


	# ============================================================
	# РАСПОРКА
	# ============================================================

	var expand := Control.new()

	expand.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	main.add_child(
		expand
	)


	# ============================================================
	# КНОПКА
	# ============================================================

	play_button = Button.new()

	play_button.text = "НАЧАТЬ МАТЧ"

	play_button.custom_minimum_size = Vector2(
		0,
		55
	)

	play_button.add_theme_font_size_override(
		"font_size",
		18
	)

	play_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	play_button.pressed.connect(
		_on_play_pressed
	)

	_apply_button_style(
		play_button,
		Color(
			0.12,
			0.55,
			0.28
		)
	)

	main.add_child(
		play_button
	)


# ================================================================
# НАЧАЛО МАТЧА
# ================================================================

func _start_match() -> void:

	if team.is_empty():
		return


	# ============================================================
	# MatchSimulator вызывается ОДИН РАЗ.
	# ============================================================

	match_result = MatchSimulator.simulate_match(
		team
	)


	current_event_index = 0
	current_minute = 0

	match_started = false
	match_finished = false
	reward_given = false


	# ============================================================
	# НАЧАЛЬНЫЙ СЧЁТ
	# ============================================================

	home_score_label.text = "0"
	away_score_label.text = "0"

	minute_label.text = "0'"

	progress_bar.value = 0


	status_label.text = "МАТЧ ГОТОВ"

	event_label.text = (
		"Ваша команда выходит на поле."
	)

	play_button.text = "НАЧАТЬ МАТЧ"

	play_button.disabled = false


# ================================================================
# НАЖАТИЕ НА НАЧАТЬ
# ================================================================

func _on_play_pressed() -> void:

	if match_finished:

		_show_summary()

		return


	if not match_started:

		match_started = true

		play_button.disabled = true

		status_label.text = (
			"МАТЧ ИДЁТ..."
		)

		_start_match_timer()


# ================================================================
# ТАЙМЕР
# ================================================================

func _start_match_timer() -> void:

	if is_instance_valid(match_timer):

		match_timer.queue_free()


	match_timer = Timer.new()

	match_timer.wait_time = 0.12

	match_timer.one_shot = false

	add_child(
		match_timer
	)

	match_timer.timeout.connect(
		_advance_match
	)

	match_timer.start()


# ================================================================
# ПРОДВИЖЕНИЕ МИНУТЫ
# ================================================================

func _advance_match() -> void:

	if match_finished:
		return


	current_minute += 1

	minute_label.text = (
		str(current_minute)
		+ "'"
	)

	progress_bar.value = (
		current_minute
	)


	_process_events()


	if current_minute >= 90:

		_finish_match()


# ================================================================
# ОБРАБОТКА СОБЫТИЙ
#
# ВАЖНО:
# Событие увеличивает счёт ТОЛЬКО если:
#
# type == "goal"
#
# Карточки, сейвы, промахи и моменты
# больше НЕ считаются голами.
# ================================================================

func _process_events() -> void:

	if current_event_index >= match_result.events.size():
		return


	var processed_event: bool = false


	# ============================================================
	# Обрабатываем ВСЕ события текущей минуты.
	# ============================================================

	while current_event_index < match_result.events.size():

		var event_data: Dictionary = (
			match_result.events[current_event_index]
		)

		var event_minute: int = int(
			event_data.get(
				"minute",
				0
			)
		)


		if event_minute > current_minute:
			break


		_display_event(
			event_data
		)

		processed_event = true

		current_event_index += 1


	# ============================================================
	# Если событие было — оставляем его на экране.
	# ============================================================

	if not processed_event:
		return


# ================================================================
# ОТОБРАЖЕНИЕ ОДНОГО СОБЫТИЯ
# ================================================================

func _display_event(
	event_data: Dictionary
) -> void:

	var event_type: String = str(
		event_data.get(
			"type",
			""
		)
	)

	var is_user: bool = bool(
		event_data.get(
			"is_user",
			false
		)
	)

	var text: String = str(
		event_data.get(
			"text",
			"Событие матча"
		)
	)


	event_label.text = text


	# ============================================================
	# ГОЛ
	#
	# ТОЛЬКО здесь изменяется счёт.
	# ============================================================

	if event_type == "goal":

		if is_user:

			var current_score: int = int(
				home_score_label.text
			)

			home_score_label.text = str(
				current_score + 1
			)

			status_label.text = (
				"⚽ ГОЛ ВАШЕЙ КОМАНДЫ!"
			)

		else:

			var current_score: int = int(
				away_score_label.text
			)

			away_score_label.text = str(
				current_score + 1
			)

			status_label.text = (
				"⚽ ГОЛ СОПЕРНИКА!"
			)

		return


	# ============================================================
	# ОСТАЛЬНЫЕ СОБЫТИЯ
	# ============================================================

	match event_type:

		"chance":

			status_label.text = (
				"ОПАСНЫЙ МОМЕНТ"
			)


		"yellow":

			status_label.text = (
				"🟨 ЖЁЛТАЯ КАРТОЧКА"
			)


		"red":

			status_label.text = (
				"🟥 КРАСНАЯ КАРТОЧКА"
			)


		_:

			status_label.text = (
				"СОБЫТИЕ МАТЧА"
			)


# ================================================================
# ЗАВЕРШЕНИЕ МАТЧА
# ================================================================

func _finish_match() -> void:

	if match_finished:
		return


	match_finished = true
	match_started = false


	if is_instance_valid(match_timer):

		match_timer.stop()

		match_timer.queue_free()

		match_timer = null


	minute_label.text = "90'"

	progress_bar.value = 90


	# ============================================================
	# ФИНАЛЬНЫЙ СЧЁТ
	#
	# На всякий случай синхронизируем UI с настоящим
	# результатом MatchSimulator.
	#
	# Это гарантирует, что экран матча и итоговый экран
	# никогда не покажут разные результаты.
	# ============================================================

	var final_user_goals: int = int(
		match_result.get(
			"user_goals",
			0
		)
	)

	var final_opponent_goals: int = int(
		match_result.get(
			"opponent_goals",
			0
		)
	)


	home_score_label.text = str(
		final_user_goals
	)

	away_score_label.text = str(
		final_opponent_goals
	)


	# ============================================================
	# ФИНАЛЬНЫЙ СТАТУС
	# ============================================================

	if final_user_goals > final_opponent_goals:

		status_label.text = (
			"🏆 ПОБЕДА!"
		)

	elif final_user_goals < final_opponent_goals:

		status_label.text = (
			"ПОРАЖЕНИЕ"
		)

	else:

		status_label.text = (
			"🤝 НИЧЬЯ"
		)


	event_label.text = (
		"Матч завершён!"
	)


	# ============================================================
	# НАГРАДА
	# ============================================================

	_give_match_reward()


	play_button.disabled = false

	play_button.text = (
		"ПОСМОТРЕТЬ РЕЗУЛЬТАТ"
	)


# ================================================================
# НАГРАДА
# ================================================================

func _give_match_reward() -> void:

	if reward_given:
		return


	reward_given = true


	var won: bool = bool(
		match_result.get(
			"won",
			false
		)
	)

	var draw: bool = bool(
		match_result.get(
			"draw",
			false
		)
	)


	var reward: int


	if won:

		reward = 500

	elif draw:

		reward = 300

	else:

		reward = 200


	UserProfile.add_coins(
		reward
	)


	print(
		"MatchScreen: награда за матч +",
		reward,
		" монет. Баланс: ",
		UserProfile.coins
	)


	# ============================================================
	# ДОПОЛНИТЕЛЬНОЕ СОХРАНЕНИЕ
	# ============================================================

	if SaveManager:

		if SaveManager.has_method(
			"save_game"
		):

			SaveManager.save_game()


# ================================================================
# ИТОГОВЫЙ ЭКРАН
# ================================================================

func _show_summary() -> void:

	var summary_scene := load(
		"res://MatchSummaryScreen.tscn"
	) as PackedScene


	if summary_scene == null:

		push_error(
			"Не удалось загрузить MatchSummaryScreen.tscn"
		)

		return


	var summary := (
		summary_scene.instantiate()
	)


	add_child(
		summary
	)


	# ============================================================
	# ПЕРЕДАЁМ УЖЕ ГОТОВЫЙ РЕЗУЛЬТАТ.
	#
	# MatchSimulator здесь НЕ вызывается.
	# ============================================================

	if summary.has_method(
		"setup_summary"
	):

		summary.setup_summary(
			team,
			match_result
		)


# ================================================================
# НАЗАД
# ================================================================

func _on_back_pressed() -> void:

	if is_instance_valid(match_timer):

		match_timer.stop()


	get_tree().change_scene_to_file(
		"res://PitchScreen.tscn"
	)


# ================================================================
# СТИЛЬ КНОПКИ
# ================================================================

func _apply_button_style(
	button: Button,
	background_color: Color
) -> void:

	var normal := StyleBoxFlat.new()

	normal.bg_color = (
		background_color
	)

	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14


	button.add_theme_stylebox_override(
		"normal",
		normal
	)


	var hover := normal.duplicate()

	hover.bg_color = Color(
		min(
			background_color.r + 0.06,
			1.0
		),
		min(
			background_color.g + 0.06,
			1.0
		),
		min(
			background_color.b + 0.06,
			1.0
		)
	)


	button.add_theme_stylebox_override(
		"hover",
		hover
	)


	var pressed := normal.duplicate()

	pressed.bg_color = Color(
		max(
			background_color.r - 0.04,
			0.0
		),
		max(
			background_color.g - 0.04,
			0.0
		),
		max(
			background_color.b - 0.04,
			0.0
		)
	)


	button.add_theme_stylebox_override(
		"pressed",
		pressed
	)
