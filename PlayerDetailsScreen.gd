extends Control

var player_card: PlayerCard

var overlay: ColorRect
var window_panel: PanelContainer

var player_name_label: Label
var rating_label: Label
var position_label: Label
var club_label: Label
var nation_label: Label
var rarity_label: Label

var photo_area: Panel
var close_button: Button
var squad_button: Button


func setup(card: PlayerCard) -> void:
	player_card = card

	if is_node_ready():
		_update_player_info()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	z_index = 100

	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_ui()

	if player_card:
		_update_player_info()


func _build_ui() -> void:
	# ============================================================
	# ЗАТЕМНЁННЫЙ ФОН
	# ============================================================

	overlay = ColorRect.new()

	overlay.color = Color(
		0.0,
		0.0,
		0.0,
		0.78
	)

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(overlay)


	# ============================================================
	# ЦЕНТРАЛЬНЫЙ CONTAINER
	# ============================================================

	var center := CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(center)


	# ============================================================
	# ОКНО
	# ============================================================

	window_panel = PanelContainer.new()

	window_panel.custom_minimum_size = Vector2(
		390,
		600
	)

	window_panel.mouse_filter = Control.MOUSE_FILTER_STOP

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
		1.0,
		1.0,
		1.0,
		0.15
	)

	window_panel.add_theme_stylebox_override(
		"panel",
		window_style
	)

	center.add_child(window_panel)


	# ============================================================
	# ОСНОВНОЙ CONTAINER
	# ============================================================

	var main := VBoxContainer.new()

	main.add_theme_constant_override(
		"separation",
		8
	)

	window_panel.add_child(main)


	# ============================================================
	# HEADER
	# ============================================================

	var header := HBoxContainer.new()

	header.custom_minimum_size = Vector2(
		0,
		50
	)

	main.add_child(header)


	var title := Label.new()

	title.text = "ИГРОК"

	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	header.add_child(title)


	close_button = Button.new()

	close_button.text = "✕"

	close_button.custom_minimum_size = Vector2(
		50,
		50
	)

	close_button.add_theme_font_size_override(
		"font_size",
		22
	)

	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	close_button.pressed.connect(
		_close
	)

	header.add_child(close_button)


	# ============================================================
	# РЕДКОСТЬ
	# ============================================================

	rarity_label = Label.new()

	rarity_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rarity_label.add_theme_font_size_override(
		"font_size",
		15
	)

	main.add_child(rarity_label)


	# ============================================================
	# ФОТО
	# ============================================================

	photo_area = Panel.new()

	photo_area.custom_minimum_size = Vector2(
		0,
		220
	)

	photo_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var photo_style := StyleBoxFlat.new()

	photo_style.bg_color = Color(
		0.02,
		0.025,
		0.035,
		1.0
	)

	photo_style.corner_radius_top_left = 18
	photo_style.corner_radius_top_right = 18
	photo_style.corner_radius_bottom_left = 18
	photo_style.corner_radius_bottom_right = 18

	photo_area.add_theme_stylebox_override(
		"panel",
		photo_style
	)

	main.add_child(photo_area)


	# ============================================================
	# РЕЙТИНГ
	# ============================================================

	rating_label = Label.new()

	rating_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rating_label.add_theme_font_size_override(
		"font_size",
		38
	)

	main.add_child(rating_label)


	# ============================================================
	# ИМЯ
	# ============================================================

	player_name_label = Label.new()

	player_name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	player_name_label.add_theme_font_size_override(
		"font_size",
		26
	)

	player_name_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main.add_child(player_name_label)


	# ============================================================
	# ПОЗИЦИЯ
	# ============================================================

	position_label = Label.new()

	position_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	position_label.add_theme_font_size_override(
		"font_size",
		16
	)

	main.add_child(position_label)


	# ============================================================
	# КЛУБ
	# ============================================================

	club_label = Label.new()

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

	main.add_child(club_label)


	# ============================================================
	# СТРАНА
	# ============================================================

	nation_label = Label.new()

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

	main.add_child(nation_label)


	# ============================================================
	# РАЗДЕЛИТЕЛЬ
	# ============================================================

	var separator := HSeparator.new()

	main.add_child(separator)


	# ============================================================
	# ХАРАКТЕРИСТИКИ
	# ============================================================

	var stats := HBoxContainer.new()

	stats.custom_minimum_size = Vector2(
		0,
		55
	)

	main.add_child(stats)

	_add_stat(stats, "PAC", "—")
	_add_stat(stats, "SHO", "—")
	_add_stat(stats, "PAS", "—")
	_add_stat(stats, "DRI", "—")
	_add_stat(stats, "DEF", "—")
	_add_stat(stats, "PHY", "—")


	# ============================================================
	# КНОПКА СОСТАВА
	# ============================================================

	squad_button = Button.new()

	squad_button.text = "В СОСТАВ"

	squad_button.custom_minimum_size = Vector2(
		0,
		50
	)

	squad_button.add_theme_font_size_override(
		"font_size",
		16
	)

	squad_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	squad_button.pressed.connect(_on_squad_pressed)
	_apply_button_style(squad_button, Color(0.12, 0.55, 0.28))

	main.add_child(squad_button)


	# ============================================================
	# PLACEHOLDER PHOTO
	# ============================================================

	var placeholder := Label.new()

	placeholder.text = "PHOTO"

	placeholder.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	placeholder.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	placeholder.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
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

	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	photo_area.add_child(placeholder)


func _add_stat(
	container: HBoxContainer,
	stat_name: String,
	value: String
) -> void:

	var box := VBoxContainer.new()

	box.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	container.add_child(box)


	var name_label := Label.new()

	name_label.text = stat_name

	name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	name_label.add_theme_font_size_override(
		"font_size",
		11
	)

	name_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.50
		)
	)

	box.add_child(name_label)


	var value_label := Label.new()

	value_label.text = value

	value_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	value_label.add_theme_font_size_override(
		"font_size",
		16
	)

	box.add_child(value_label)


func _update_player_info() -> void:
	if player_card == null:
		return

	if rating_label:
		rating_label.text = (
			str(player_card.rating)
			+ " OVR"
		)

	if player_name_label:
		player_name_label.text = player_card.player_name

	if position_label:
		position_label.text = (
			"Позиция: "
			+ player_card.position
		)

	if club_label:
		club_label.text = player_card.club

	if nation_label:
		nation_label.text = player_card.nation

	if rarity_label:
		rarity_label.text = player_card.rarity

		_apply_rarity_style(
			player_card.rarity
		)

	if squad_button and is_instance_valid(ClubManager):
		var already_in_lineup: bool = player_card in ClubManager.starting_lineup
		if already_in_lineup:
			squad_button.disabled = true
			squad_button.text = "УЖЕ В СОСТАВЕ"
		else:
			squad_button.disabled = false
			squad_button.text = "В СОСТАВ"

	# ============================================================
	# ФОТО
	# ============================================================

	if player_card.photo:
		for child in photo_area.get_children():
			child.queue_free()

		var texture_rect := TextureRect.new()

		texture_rect.texture = player_card.photo

		texture_rect.expand_mode = (
			TextureRect.EXPAND_IGNORE_SIZE
		)

		texture_rect.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		)

		texture_rect.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

		texture_rect.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		photo_area.add_child(
			texture_rect
		)


func _apply_rarity_style(rarity: String) -> void:
	if rarity_label == null:
		return

	match rarity:
		"BRONZE":
			rarity_label.add_theme_color_override(
				"font_color",
				Color(
					0.75,
					0.45,
					0.25
				)
			)

		"SILVER":
			rarity_label.add_theme_color_override(
				"font_color",
				Color(
					0.75,
					0.78,
					0.82
				)
			)

		"GOLD":
			rarity_label.add_theme_color_override(
				"font_color",
				Color(
					1.0,
					0.78,
					0.20
				)
			)

		"ELITE":
			rarity_label.add_theme_color_override(
				"font_color",
				Color(
					0.75,
					0.45,
					1.0
				)
			)

		_:
			rarity_label.add_theme_color_override(
				"font_color",
				Color.WHITE
			)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Если окно ещё не создано — ничего не делаем.
				if window_panel == null:
					return

				# Получаем координаты клика.
				var click_position: Vector2 = event.position

				# Проверяем, попал ли клик внутрь окна.
				var window_rect: Rect2 = window_panel.get_global_rect()

				if not window_rect.has_point(click_position):
					_close()


func _on_squad_pressed() -> void:
	if player_card == null:
		return

	if not is_instance_valid(ClubManager):
		push_warning("PlayerDetailsScreen: ClubManager не доступен, невозможно добавить игрока в состав.")
		_close()
		return

	if player_card in ClubManager.starting_lineup:
		_close()
		return

	if not (player_card in ClubManager.club_cards):
		ClubManager.add_card_to_club(player_card)

	ClubManager.add_player_to_lineup(player_card)

	print("PlayerDetailsScreen: ", player_card.player_name, " добавлен в стартовый состав.")
	_close()


func _close() -> void:
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				_close()


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
