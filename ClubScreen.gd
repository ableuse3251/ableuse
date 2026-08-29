extends Control


var club_manager: Node

var details_layer: CanvasLayer = null
var current_details_card: PlayerCard = null
var current_squad_button: Button = null


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	club_manager = get_node("/root/ClubManager")

	_build_ui()
	_refresh_club()


# ============================================================
# СОЗДАНИЕ ЭКРАНА
# ============================================================

func _build_ui() -> void:
	# ========================================================
	# ФОН
	# ========================================================

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


	# ========================================================
	# ГЛАВНЫЙ MARGIN
	# ========================================================

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

	add_child(margin)


	# ========================================================
	# MAIN VBOX
	# ========================================================

	var main_vbox := VBoxContainer.new()

	main_vbox.add_theme_constant_override(
		"separation",
		15
	)

	margin.add_child(main_vbox)


	# ========================================================
	# ЗАГОЛОВОК
	# ========================================================

	var title := Label.new()

	title.text = (
		"МОЙ КЛУБ  •  ВСЕГО ИГРОКОВ: "
		+ str(club_manager.my_club_cards.size())
	)

	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		26
	)

	main_vbox.add_child(title)


	# ========================================================
	# ПРОКРУТКА
	# ========================================================

	var scroll := ScrollContainer.new()

	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	main_vbox.add_child(scroll)


	# ========================================================
	# СЕТКА
	# ========================================================

	var grid := GridContainer.new()

	grid.columns = 2

	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	grid.add_theme_constant_override(
		"h_separation",
		15
	)

	grid.add_theme_constant_override(
		"v_separation",
		15
	)

	scroll.add_child(grid)


	# ========================================================
	# ПУСТОЙ КЛУБ
	# ========================================================

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

		main_vbox.add_child(
			empty_label
		)

	else:

		var card_ui_scene = load(
			"res://CardUI.tscn"
		)

		if card_ui_scene == null:
			print(
				"ClubScreen: ERROR - CardUI.tscn не найден."
			)

		else:

			for card_data in club_manager.my_club_cards:

				var mini_card = (
					card_ui_scene.instantiate()
					as CardUI
				)

				if mini_card == null:
					print(
						"ClubScreen: ERROR - не удалось создать CardUI."
					)

					continue

				# =================================================
				# ВАЖНО:
				# Подписываем ClubScreen на сигнал CardUI.
				# =================================================

				mini_card.card_selected.connect(
					_on_card_selected
				)

				grid.add_child(
					mini_card
				)

				mini_card.setup(
					card_data
				)

				mini_card.set_compact_mode()


	# ========================================================
	# КНОПКА НАЗАД
	# ========================================================

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


# ============================================================
# CARDUI → CLUBSCREEN
# ============================================================

func _on_card_selected(player_data: Variant) -> void:
	print(
		"ClubScreen: получен клик по игроку -> ",
		player_data
	)

	if player_data is PlayerCard:

		_open_player_details(
			player_data
		)

	else:

		print(
			"ClubScreen: ERROR - полученные данные не PlayerCard."
		)


# ============================================================
# ОКНО ИГРОКА
# ============================================================

func _open_player_details(card: PlayerCard) -> void:

	print(
		"ClubScreen: открываем игрока -> ",
		card.player_name
	)

	# Если окно уже открыто — удаляем старое.

	if details_layer != null:

		details_layer.queue_free()

		details_layer = null

	current_details_card = card
	current_squad_button = null


	# ========================================================
	# CANVAS LAYER
	# ========================================================

	details_layer = CanvasLayer.new()

	details_layer.layer = 100

	add_child(
		details_layer
	)


	# ========================================================
	# ЗАТЕМНЕНИЕ
	# ========================================================

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


	# ========================================================
	# ЦЕНТР
	# ========================================================

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


	# ========================================================
	# ОКНО
	# ========================================================

	var window := PanelContainer.new()

	window.custom_minimum_size = Vector2(
		390,
		600
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


	# ========================================================
	# ВНУТРЕННИЙ MARGIN
	# ========================================================

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
		15
	)

	content_margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	window.add_child(
		content_margin
	)


	# ========================================================
	# MAIN
	# ========================================================

	var main := VBoxContainer.new()

	main.add_theme_constant_override(
		"separation",
		8
	)

	content_margin.add_child(
		main
	)


	# ========================================================
	# HEADER
	# ========================================================

	var header := HBoxContainer.new()

	header.custom_minimum_size = Vector2(
		0,
		45
	)

	main.add_child(
		header
	)


	var header_title := Label.new()

	header_title.text = "ПРОФИЛЬ ИГРОКА"

	header_title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	header_title.add_theme_font_size_override(
		"font_size",
		19
	)

	header_title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	header_title.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	header.add_child(
		header_title
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

	_apply_button_style(
		close_button,
		Color(
			0.10,
			0.12,
			0.16
		)
	)

	header.add_child(
		close_button
	)


	# ========================================================
	# РЕДКОСТЬ
	# ========================================================

	var rarity_label := Label.new()

	rarity_label.text = card.rarity

	rarity_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rarity_label.add_theme_font_size_override(
		"font_size",
		15
	)

	rarity_label.add_theme_color_override(
		"font_color",
		_get_rarity_text_color(
			card.rarity
		)
	)

	rarity_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		rarity_label
	)


	# ========================================================
	# ФОТО
	# ========================================================

	var photo := Panel.new()

	photo.custom_minimum_size = Vector2(
		0,
		210
	)

	photo.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	var photo_style := StyleBoxFlat.new()

	photo_style.bg_color = Color(
		0.02,
		0.025,
		0.035
	)

	photo_style.corner_radius_top_left = 18
	photo_style.corner_radius_top_right = 18
	photo_style.corner_radius_bottom_left = 18
	photo_style.corner_radius_bottom_right = 18

	photo.add_theme_stylebox_override(
		"panel",
		photo_style
	)

	main.add_child(
		photo
	)


	if card.photo != null:

		var texture := TextureRect.new()

		texture.texture = card.photo

		texture.expand_mode = (
			TextureRect.EXPAND_IGNORE_SIZE
		)

		texture.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		)

		texture.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

		texture.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		photo.add_child(
			texture
		)

	else:

		var placeholder := Label.new()

		placeholder.text = "PHOTO"

		placeholder.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

		placeholder.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)

		placeholder.vertical_alignment = (
			VERTICAL_ALIGNMENT_CENTER
		)

		placeholder.add_theme_font_size_override(
			"font_size",
			22
		)

		placeholder.add_theme_color_override(
			"font_color",
			Color(
				1,
				1,
				1,
				0.20
			)
		)

		placeholder.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		photo.add_child(
			placeholder
		)


	# ========================================================
	# РЕЙТИНГ
	# ========================================================

	var rating := Label.new()

	rating.text = str(card.rating)

	rating.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rating.add_theme_font_size_override(
		"font_size",
		40
	)

	rating.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.82,
			0.25
		)
	)

	rating.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		rating
	)


	# ========================================================
	# ИМЯ
	# ========================================================

	var name_label := Label.new()

	name_label.text = card.player_name

	name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	name_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	name_label.add_theme_font_size_override(
		"font_size",
		27
	)

	name_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		name_label
	)


	# ========================================================
	# ПОЗИЦИЯ
	# ========================================================

	var position_label := Label.new()

	position_label.text = (
		"Позиция: "
		+ card.position
	)

	position_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	position_label.add_theme_font_size_override(
		"font_size",
		16
	)

	position_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		position_label
	)


	# ========================================================
	# КЛУБ
	# ========================================================

	var club_label := Label.new()

	club_label.text = card.club

	club_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	club_label.add_theme_font_size_override(
		"font_size",
		15
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


	# ========================================================
	# СТРАНА
	# ========================================================

	var nation_label := Label.new()

	nation_label.text = card.nation

	nation_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	nation_label.add_theme_font_size_override(
		"font_size",
		14
	)

	nation_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.55
		)
	)

	nation_label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	main.add_child(
		nation_label
	)


	# ========================================================
	# РАЗДЕЛИТЕЛЬ
	# ========================================================

	var separator := HSeparator.new()

	main.add_child(
		separator
	)


	# ========================================================
	# КНОПКА СОСТАВА
	# ========================================================

	var squad_button := Button.new()

	current_squad_button = squad_button

	_update_squad_button(
		squad_button,
		card
	)

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
		_on_details_lineup_pressed
	)

	main.add_child(
		squad_button
	)


# ============================================================
# ОБНОВЛЕНИЕ КНОПКИ СОСТАВА
# ============================================================

func _update_squad_button(
	button: Button,
	card: PlayerCard
) -> void:

	if club_manager.is_in_starting_lineup(card):

		button.text = "✓ В СОСТАВЕ"

		_apply_button_style(
			button,
			Color(
				0.18,
				0.45,
				0.25
			)
		)

	else:

		button.text = "В СОСТАВ"

		_apply_button_style(
			button,
			Color(
				0.10,
				0.12,
				0.17
			)
		)


# ============================================================
# ДОБАВЛЕНИЕ / УДАЛЕНИЕ ИЗ СОСТАВА
# ============================================================

func _on_details_lineup_pressed() -> void:

	if current_details_card == null:
		return

	var card := current_details_card


	if club_manager.is_in_starting_lineup(card):

		club_manager.remove_from_starting_lineup(
			card
		)

	else:

		var added: bool = (
			club_manager.add_to_starting_lineup(
				card
			)
		)

		if not added:

			print(
				"ClubScreen: нельзя добавить больше 11 игроков."
			)

			return


	if current_squad_button != null:

		_update_squad_button(
			current_squad_button,
			card
		)


# ============================================================
# ЗАКРЫТИЕ ОКНА
# ============================================================

func _close_player_details() -> void:

	if details_layer != null:

		details_layer.queue_free()

		details_layer = null

	current_details_card = null
	current_squad_button = null


# ============================================================
# ОБНОВЛЕНИЕ
# ============================================================

func _refresh_club() -> void:

	if club_manager == null:
		return

	print(
		"ClubScreen: игроков в клубе -> ",
		club_manager.my_club_cards.size()
	)


# ============================================================
# ЦВЕТ РЕДКОСТИ
# ============================================================

func _get_rarity_text_color(
	rarity: String
) -> Color:

	match rarity:

		"BRONZE":
			return Color(
				0.75,
				0.45,
				0.25
			)

		"SILVER":
			return Color(
				0.78,
				0.80,
				0.85
			)

		"GOLD":
			return Color(
				1.0,
				0.80,
				0.20
			)

		"ELITE":
			return Color(
				0.75,
				0.45,
				1.0
			)

		_:
			return Color.WHITE


# ============================================================
# СТИЛЬ КНОПОК
# ============================================================

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


# ============================================================
# НАЗАД
# ============================================================

func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://PitchScreen.tscn"
	)
