extends Control


var club_manager: Node

var details_layer: CanvasLayer = null


func _ready() -> void:

	anchor_right = 1.0
	anchor_bottom = 1.0

	club_manager = get_node(
		"/root/ClubManager"
	)

	_build_ui()

	_refresh_club()


# ================================================================
# ПОСТРОЕНИЕ UI
# ================================================================

func _build_ui() -> void:

	# ============================================================
	# ФОН
	# ============================================================

	var background := ColorRect.new()

	background.color = Color(
		0.035,
		0.045,
		0.06
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)


	# ============================================================
	# ГЛАВНЫЙ CONTAINER
	# ============================================================

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_top",
		20
	)

	margin.add_theme_constant_override(
		"margin_left",
		20
	)

	margin.add_theme_constant_override(
		"margin_right",
		20
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(margin)


	var main_vbox := VBoxContainer.new()

	main_vbox.add_theme_constant_override(
		"separation",
		15
	)

	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	margin.add_child(main_vbox)


	# ============================================================
	# ЗАГОЛОВОК
	# ============================================================

	var title := Label.new()

	title.text = (
		"МОЙ КЛУБ  •  ВСЕГО ИГРОКОВ: "
		+ str(
			club_manager.my_club_cards.size()
		)
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		26
	)

	title.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(title)


	# ============================================================
	# ОБЛАСТЬ ПРОКРУТКИ
	# ============================================================

	var scroll := ScrollContainer.new()

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	scroll.mouse_filter = Control.MOUSE_FILTER_PASS

	main_vbox.add_child(scroll)


	# ============================================================
	# СЕТКА
	# ============================================================

	var grid := GridContainer.new()

	grid.columns = 2

	grid.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	grid.add_theme_constant_override(
		"h_separation",
		15
	)

	grid.add_theme_constant_override(
		"v_separation",
		15
	)

	grid.mouse_filter = Control.MOUSE_FILTER_PASS

	scroll.add_child(grid)


	# ============================================================
	# ПУСТОЙ КЛУБ
	# ============================================================

	if club_manager.my_club_cards.is_empty():

		var empty_label := Label.new()

		empty_label.text = (
			"В вашем клубе пока нет игроков.\n\n"
			+ "Открывайте паки в магазине!"
		)

		empty_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)

		empty_label.vertical_alignment = (
			VERTICAL_ALIGNMENT_CENTER
		)

		empty_label.add_theme_font_size_override(
			"font_size",
			18
		)

		empty_label.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		empty_label.size_flags_vertical = (
			Control.SIZE_EXPAND_FILL
		)

		empty_label.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		main_vbox.add_child(
			empty_label
		)

	else:

		# ========================================================
		# CARD UI
		# ========================================================

		var card_ui_scene = load(
			"res://CardUI.tscn"
		)

		if card_ui_scene:

			for card_data in club_manager.my_club_cards:

				var mini_card = (
					card_ui_scene.instantiate()
					as CardUI
				)

				if mini_card == null:
					continue


				# ------------------------------------------------
				# ВАЖНО:
				# ПОДПИСЫВАЕМСЯ НА КЛИК
				# ------------------------------------------------

				mini_card.card_selected.connect(
					_on_player_card_selected
				)


				grid.add_child(
					mini_card
				)


				mini_card.setup(
					card_data
				)


				mini_card.set_compact_mode()


	# ============================================================
	# КНОПКА НАЗАД
	# ============================================================

	var back_button := Button.new()

	back_button.text = "← Вернуться в игру"

	back_button.custom_minimum_size = Vector2(
		0,
		45
	)

	back_button.add_theme_font_size_override(
		"font_size",
		15
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

	main_vbox.add_child(
		back_button
	)


# ================================================================
# ОБНОВЛЕНИЕ
# ================================================================

func _refresh_club() -> void:

	if club_manager == null:
		return

	print(
		"MyClubScreen: игроков в клубе -> ",
		club_manager.my_club_cards.size()
	)


# ================================================================
# КЛИК ПО ИГРОКУ
# ================================================================

func _on_player_card_selected(
	player_data: Variant
) -> void:

	print(
		"MyClubScreen: выбран игрок -> ",
		_get_player_name(player_data)
	)

	_open_player_details(
		player_data
	)


# ================================================================
# ОКНО ИГРОКА
# ================================================================

func _open_player_details(
	player_data: Variant
) -> void:

	if details_layer != null:

		details_layer.queue_free()

		details_layer = null


	details_layer = CanvasLayer.new()

	details_layer.layer = 100

	add_child(
		details_layer
	)


	# ============================================================
	# ЗАТЕМНЕНИЕ
	# ============================================================

	var overlay := ColorRect.new()

	overlay.color = Color(
		0,
		0,
		0,
		0.78
	)

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	details_layer.add_child(
		overlay
	)


	# ============================================================
	# ЦЕНТР
	# ============================================================

	var center := CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = (
		Control.MOUSE_FILTER_PASS
	)

	details_layer.add_child(
		center
	)


	# ============================================================
	# ОКНО
	# ============================================================

	var window := PanelContainer.new()

	window.custom_minimum_size = Vector2(
		360,
		500
	)

	window.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)


	var window_style := StyleBoxFlat.new()

	window_style.bg_color = Color(
		0.055,
		0.065,
		0.085,
		0.99
	)

	window_style.corner_radius_top_left = 24
	window_style.corner_radius_top_right = 24
	window_style.corner_radius_bottom_left = 24
	window_style.corner_radius_bottom_right = 24

	window_style.border_width_left = 1
	window_style.border_width_right = 1
	window_style.border_width_top = 1
	window_style.border_width_bottom = 1

	window_style.border_color = Color(
		1,
		1,
		1,
		0.15
	)

	window.add_theme_stylebox_override(
		"panel",
		window_style
	)

	center.add_child(
		window
	)


	# ============================================================
	# СОДЕРЖИМОЕ
	# ============================================================

	var content_margin := MarginContainer.new()

	content_margin.add_theme_constant_override(
		"margin_left",
		20
	)

	content_margin.add_theme_constant_override(
		"margin_right",
		20
	)

	content_margin.add_theme_constant_override(
		"margin_top",
		20
	)

	content_margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	content_margin.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	window.add_child(
		content_margin
	)


	var main := VBoxContainer.new()

	main.add_theme_constant_override(
		"separation",
		10
	)

	main.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	content_margin.add_child(
		main
	)


	# ============================================================
	# HEADER
	# ============================================================

	var header := HBoxContainer.new()

	header.custom_minimum_size = Vector2(
		0,
		45
	)

	header.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		header
	)


	var title := Label.new()

	title.text = "ИГРОК"

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	title.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	header.add_child(
		title
	)


	var close_button := Button.new()

	close_button.text = "✕"

	close_button.custom_minimum_size = Vector2(
		45,
		45
	)

	close_button.add_theme_font_size_override(
		"font_size",
		20
	)

	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	close_button.pressed.connect(
		_close_player_details
	)

	header.add_child(
		close_button
	)


	# ============================================================
	# ИМЯ
	# ============================================================

	var name_label := Label.new()

	name_label.text = _get_player_name(
		player_data
	)

	name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	name_label.add_theme_font_size_override(
		"font_size",
		28
	)

	name_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		name_label
	)


	# ============================================================
	# РЕЙТИНГ
	# ============================================================

	var rating_label := Label.new()

	rating_label.text = (
		str(
			_get_player_rating(
				player_data
			)
		)
		+ " OVR"
	)

	rating_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rating_label.add_theme_font_size_override(
		"font_size",
		38
	)

	rating_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.82,
			0.25
		)
	)

	rating_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		rating_label
	)


	# ============================================================
	# ПОЗИЦИЯ
	# ============================================================

	var position_label := Label.new()

	position_label.text = (
		"Позиция: "
		+ _get_player_position(
			player_data
		)
	)

	position_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	position_label.add_theme_font_size_override(
		"font_size",
		17
	)

	position_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		position_label
	)


	# ============================================================
	# КЛУБ
	# ============================================================

	var club_label := Label.new()

	club_label.text = _get_player_club(
		player_data
	)

	club_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	club_label.add_theme_font_size_override(
		"font_size",
		16
	)

	club_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.70
		)
	)

	club_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		club_label
	)


	# ============================================================
	# СТРАНА / РЕДКОСТЬ
	# ============================================================

	if player_data is PlayerCard:

		var info_label := Label.new()

		info_label.text = (
			player_data.nation
			+ "  •  "
			+ player_data.rarity
		)

		info_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)

		info_label.add_theme_font_size_override(
			"font_size",
			15
		)

		info_label.add_theme_color_override(
			"font_color",
			Color(
				1,
				1,
				1,
				0.55
			)
		)

		info_label.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		main.add_child(
			info_label
		)


	# ============================================================
	# РАЗДЕЛИТЕЛЬ
	# ============================================================

	var separator := HSeparator.new()

	separator.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		separator
	)


	# ============================================================
	# СОСТАВ
	# ============================================================

	if player_data is PlayerCard:

		var squad_button := Button.new()

		if club_manager.is_in_starting_lineup(
			player_data
		):

			squad_button.text = "✓ В СОСТАВЕ"

		else:

			squad_button.text = "В СОСТАВ"


		squad_button.custom_minimum_size = Vector2(
			0,
			48
		)

		squad_button.add_theme_font_size_override(
			"font_size",
			16
		)

		squad_button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
		)

		squad_button.pressed.connect(
			_on_details_lineup_pressed.bind(
				player_data,
				squad_button
			)
		)


		if club_manager.is_in_starting_lineup(
			player_data
		):

			_apply_button_style(
				squad_button,
				Color(
					0.18,
					0.45,
					0.25
				)
			)

		else:

			_apply_button_style(
				squad_button,
				Color(
					0.10,
					0.12,
					0.17
				)
			)


		main.add_child(
			squad_button
		)


# ================================================================
# КНОПКА СОСТАВА В ОКНЕ
# ================================================================

func _on_details_lineup_pressed(
	card: PlayerCard,
	button: Button
) -> void:

	if club_manager.is_in_starting_lineup(
		card
	):

		club_manager.remove_from_starting_lineup(
			card
		)

		button.text = "В СОСТАВ"

		_apply_button_style(
			button,
			Color(
				0.10,
				0.12,
				0.17
			)
		)

	else:

		var added: bool = (
			club_manager.add_to_starting_lineup(
				card
			)
		)

		if not added:

			print(
				"ClubManager: нельзя добавить больше 11 игроков."
			)

			return


		button.text = "✓ В СОСТАВЕ"

		_apply_button_style(
			button,
			Color(
				0.18,
				0.45,
				0.25
			)
		)


# ================================================================
# ЗАКРЫТЬ ОКНО
# ================================================================

func _close_player_details() -> void:

	if details_layer != null:

		details_layer.queue_free()

		details_layer = null


# ================================================================
# ПОЛУЧЕНИЕ ИМЕНИ
# ================================================================

func _get_player_name(
	player_data: Variant
) -> String:

	if player_data is PlayerCard:

		return player_data.player_name


	if typeof(player_data) == TYPE_DICTIONARY:

		return str(
			player_data.get(
				"player_name",
				"Игрок"
			)
		)


	return "Игрок"


# ================================================================
# ПОЛУЧЕНИЕ РЕЙТИНГА
# ================================================================

func _get_player_rating(
	player_data: Variant
) -> int:

	if player_data is PlayerCard:

		return player_data.rating


	if typeof(player_data) == TYPE_DICTIONARY:

		return int(
			player_data.get(
				"rating",
				80
			)
		)


	return 80


# ================================================================
# ПОЛУЧЕНИЕ ПОЗИЦИИ
# ================================================================

func _get_player_position(
	player_data: Variant
) -> String:

	if player_data is PlayerCard:

		return player_data.position


	if typeof(player_data) == TYPE_DICTIONARY:

		return str(
			player_data.get(
				"position",
				"MID"
			)
		)


	return "MID"


# ================================================================
# ПОЛУЧЕНИЕ КЛУБА
# ================================================================

func _get_player_club(
	player_data: Variant
) -> String:

	if player_data is PlayerCard:

		return player_data.club


	if typeof(player_data) == TYPE_DICTIONARY:

		return str(
			player_data.get(
				"club",
				"FC Draft"
			)
		)


	return "FC Draft"


# ================================================================
# СТИЛЬ КНОПКИ
# ================================================================

func _apply_button_style(
	button: Button,
	background_color: Color
) -> void:

	var normal := StyleBoxFlat.new()

	normal.bg_color = background_color

	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12

	button.add_theme_stylebox_override(
		"normal",
		normal
	)


	var hover := normal.duplicate()

	hover.bg_color = Color(
		min(
			background_color.r + 0.05,
			1.0
		),
		min(
			background_color.g + 0.05,
			1.0
		),
		min(
			background_color.b + 0.05,
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


# ================================================================
# НАЗАД
# ================================================================

func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://PitchScreen.tscn"
	)
