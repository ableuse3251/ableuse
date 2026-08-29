class_name CardUI
extends Control


signal card_selected(player_data)


# ============================================================
# ДАННЫЕ
# ============================================================

var player_data: Variant = null
var is_compact: bool = false
var _ui_built: bool = false


# ============================================================
# UI
# ============================================================

var name_label: Label
var rating_label: Label
var pos_label: Label
var club_label: Label
var nation_label: Label

var pace_label: Label
var shooting_label: Label
var passing_label: Label
var dribbling_label: Label
var defending_label: Label
var physical_label: Label

var rarity_label: Label

var main_panel: Panel
var glow_panel: Panel


# ============================================================
# РАЗМЕРЫ
# ============================================================

const NORMAL_SIZE := Vector2(180, 260)
const COMPACT_SIZE := Vector2(105, 125)


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	mouse_filter = Control.MOUSE_FILTER_STOP

	# --------------------------------------------------------
	# Если размер ещё не задан — задаём его.
	# --------------------------------------------------------

	if custom_minimum_size == Vector2.ZERO:

		if is_compact:
			custom_minimum_size = COMPACT_SIZE
		else:
			custom_minimum_size = NORMAL_SIZE

	size = custom_minimum_size

	# --------------------------------------------------------
	# Строим UI только один раз.
	# --------------------------------------------------------

	if not _ui_built:

		_build_ui()

		_ui_built = true

	# --------------------------------------------------------
	# После построения UI обязательно обновляем данные.
	# Это важно для первого выбора драфта.
	# --------------------------------------------------------

	_update_ui_values()


# ============================================================
# КОМПАКТНЫЙ РЕЖИМ
# ============================================================

func set_compact_mode() -> void:

	is_compact = true

	custom_minimum_size = COMPACT_SIZE
	size = COMPACT_SIZE

	# --------------------------------------------------------
	# Если _ready() уже был вызван — строим UI сейчас.
	# Если ещё нет — _ready() сделает это сам.
	# --------------------------------------------------------

	if is_inside_tree():

		_build_ui()

		_ui_built = true

		_update_ui_values()


# ============================================================
# УСТАНОВКА ИГРОКА
# ============================================================

func setup(data: Variant) -> void:

	# --------------------------------------------------------
	# Сохраняем данные ДО обновления интерфейса.
	# --------------------------------------------------------

	player_data = data

	# --------------------------------------------------------
	# Если UI уже существует — сразу обновляем его.
	# Если setup() вызван до _ready(), _ready() обновит
	# интерфейс после входа в дерево.
	# --------------------------------------------------------

	if _ui_built:

		_update_ui_values()


# ============================================================
# СОЗДАНИЕ UI
# ============================================================

func _build_ui() -> void:

	# --------------------------------------------------------
	# Если UI уже существует — удаляем его.
	# --------------------------------------------------------

	for child in get_children():

		child.queue_free()


	# --------------------------------------------------------
	# Размер карточки.
	# --------------------------------------------------------

	if is_compact:

		custom_minimum_size = COMPACT_SIZE
		size = COMPACT_SIZE

	else:

		custom_minimum_size = NORMAL_SIZE
		size = NORMAL_SIZE


	# ========================================================
	# ВНЕШНЕЕ СВЕЧЕНИЕ
	# ========================================================

	glow_panel = Panel.new()

	glow_panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	glow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var glow_style := StyleBoxFlat.new()

	glow_style.bg_color = Color(
		1.0,
		0.72,
		0.15,
		0.07
	)

	glow_style.set_corner_radius_all(
		14 if not is_compact else 9
	)

	glow_style.shadow_color = Color(
		0.0,
		0.0,
		0.0,
		0.45
	)

	glow_style.shadow_size = (
		10 if not is_compact else 5
	)

	glow_panel.add_theme_stylebox_override(
		"panel",
		glow_style
	)

	add_child(glow_panel)


	# ========================================================
	# ОСНОВНАЯ КАРТОЧКА
	# ========================================================

	main_panel = Panel.new()

	main_panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var card_style := StyleBoxFlat.new()

	if is_compact:

		card_style.bg_color = Color(
			0.035,
			0.055,
			0.085,
			0.99
		)

		card_style.set_border_width_all(1)

		card_style.border_color = Color(
			1.0,
			0.78,
			0.22,
			0.90
		)

		card_style.set_corner_radius_all(7)

		card_style.shadow_size = 3

	else:

		card_style.bg_color = Color(
			0.055,
			0.075,
			0.11,
			1.0
		)

		card_style.set_border_width_all(2)

		card_style.border_color = Color(
			1.0,
			0.78,
			0.22,
			1.0
		)

		card_style.set_corner_radius_all(10)

		card_style.shadow_size = 6


	card_style.shadow_color = Color(
		0.0,
		0.0,
		0.0,
		0.55
	)

	main_panel.add_theme_stylebox_override(
		"panel",
		card_style
	)

	add_child(main_panel)


	# ========================================================
	# ВНУТРЕННЯЯ РАМКА
	# ========================================================

	var inner_panel := Panel.new()

	inner_panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	inner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var inner_style := StyleBoxFlat.new()

	inner_style.bg_color = Color(
		0,
		0,
		0,
		0
	)

	inner_style.set_border_width_all(1)

	inner_style.border_color = Color(
		1.0,
		0.9,
		0.55,
		0.18
	)

	inner_style.set_corner_radius_all(
		8 if not is_compact else 5
	)

	inner_panel.add_theme_stylebox_override(
		"panel",
		inner_style
	)

	main_panel.add_child(inner_panel)


	# ========================================================
	# ДЕКОРАТИВНАЯ ВЕРХНЯЯ ЛИНИЯ
	# ========================================================

	var top_decor := ColorRect.new()

	top_decor.position = Vector2(
		6 if not is_compact else 4,
		6 if not is_compact else 4
	)

	top_decor.size = Vector2(
		size.x * 0.48,
		2 if not is_compact else 1
	)

	top_decor.color = Color(
		1.0,
		0.84,
		0.30,
		0.75
	)

	top_decor.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_panel.add_child(top_decor)


	# ========================================================
	# ДЕКОРАТИВНЫЕ ДИАГОНАЛИ
	# ========================================================

	_create_diagonal(
		Vector2(
			size.x * 0.56,
			size.y * 0.12
		),
		Vector2(
			size.x * 0.34,
			size.y * 0.70
		),
		Color(
			1.0,
			0.78,
			0.20,
			0.055
		)
	)

	_create_diagonal(
		Vector2(
			size.x * 0.70,
			size.y * 0.04
		),
		Vector2(
			size.x * 0.26,
			size.y * 0.80
		),
		Color(
			0.3,
			0.75,
			1.0,
			0.035
		)
	)


	# ========================================================
	# MARGIN
	# ========================================================

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if is_compact:

		margin.add_theme_constant_override(
			"margin_left",
			6
		)

		margin.add_theme_constant_override(
			"margin_right",
			6
		)

		margin.add_theme_constant_override(
			"margin_top",
			5
		)

		margin.add_theme_constant_override(
			"margin_bottom",
			5
		)

	else:

		margin.add_theme_constant_override(
			"margin_left",
			10
		)

		margin.add_theme_constant_override(
			"margin_right",
			10
		)

		margin.add_theme_constant_override(
			"margin_top",
			9
		)

		margin.add_theme_constant_override(
			"margin_bottom",
			9
		)

	main_panel.add_child(margin)


	# ========================================================
	# ОСНОВНОЙ VBOX
	# ========================================================

	var vbox := VBoxContainer.new()

	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN

	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_theme_constant_override(
		"separation",
		3 if is_compact else 4
	)

	margin.add_child(vbox)


	# ========================================================
	# ВЕРХНЯЯ СТРОКА
	# ========================================================

	var top_row := HBoxContainer.new()

	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(top_row)


	# ========================================================
	# РЕЙТИНГ
	# ========================================================

	rating_label = Label.new()

	rating_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	rating_label.text = "80"

	rating_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	rating_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	rating_label.add_theme_font_size_override(
		"font_size",
		20 if is_compact else 30
	)

	rating_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.88,
			0.38
		)
	)

	rating_label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0,
			0,
			0,
			0.65
		)
	)

	rating_label.add_theme_constant_override(
		"shadow_offset_x",
		1
	)

	rating_label.add_theme_constant_override(
		"shadow_offset_y",
		2
	)

	top_row.add_child(rating_label)


	# ========================================================
	# РАСПОРКА
	# ========================================================

	var spacer := Control.new()

	spacer.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	top_row.add_child(spacer)


	# ========================================================
	# РЕДКОСТЬ
	# ========================================================

	rarity_label = Label.new()

	rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	rarity_label.text = "BRONZE"

	rarity_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	rarity_label.add_theme_font_size_override(
		"font_size",
		8 if is_compact else 9
	)

	rarity_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.78,
			0.22
		)
	)

	top_row.add_child(rarity_label)


	# ========================================================
	# ПОЗИЦИЯ
	# ========================================================

	pos_label = Label.new()

	pos_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	pos_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	pos_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	pos_label.add_theme_font_size_override(
		"font_size",
		9 if is_compact else 13
	)

	pos_label.add_theme_color_override(
		"font_color",
		Color(
			0.50,
			0.85,
			1.0
		)
	)

	top_row.add_child(pos_label)


	# ========================================================
	# РАЗДЕЛИТЕЛЬ
	# ========================================================

	var separator := ColorRect.new()

	separator.custom_minimum_size = Vector2(
		0,
		1
	)

	separator.color = Color(
		1.0,
		0.82,
		0.30,
		0.28
	)

	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(separator)


	# ========================================================
	# ЦЕНТРАЛЬНАЯ ЗОНА
	# ========================================================

	var center_space := Control.new()

	center_space.custom_minimum_size = Vector2(
		0,
		86 if not is_compact else 32
	)

	center_space.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(center_space)


	# ========================================================
	# ЭМБЛЕМА
	# ========================================================

	var emblem := Label.new()

	emblem.text = "◆"

	emblem.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	emblem.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	emblem.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER
	)

	emblem.position -= Vector2(
		20 if not is_compact else 9,
		20 if not is_compact else 9
	)

	emblem.size = Vector2(
		40 if not is_compact else 18,
		40 if not is_compact else 18
	)

	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE

	emblem.add_theme_font_size_override(
		"font_size",
		14 if is_compact else 28
	)

	emblem.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.78,
			0.22,
			0.28
		)
	)

	center_space.add_child(emblem)


	# ========================================================
	# ИМЯ
	# ========================================================

	name_label = Label.new()

	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	name_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	name_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	name_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	name_label.clip_text = true

	name_label.custom_minimum_size = Vector2(
		0,
		25 if is_compact else 38
	)

	name_label.add_theme_font_size_override(
		"font_size",
		10 if is_compact else 15
	)

	name_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			1.0,
			1.0
		)
	)

	name_label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0,
			0,
			0,
			0.8
		)
	)

	name_label.add_theme_constant_override(
		"shadow_offset_x",
		1
	)

	name_label.add_theme_constant_override(
		"shadow_offset_y",
		1
	)

	vbox.add_child(name_label)


	# ========================================================
	# КЛУБ
	# ========================================================

	club_label = Label.new()

	club_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	club_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	club_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	club_label.clip_text = true

	club_label.add_theme_font_size_override(
		"font_size",
		8 if is_compact else 11
	)

	club_label.add_theme_color_override(
		"font_color",
		Color(
			0.64,
			0.70,
			0.78
		)
	)

	vbox.add_child(club_label)


	# ========================================================
	# СТРАНА
	# ========================================================

	nation_label = Label.new()

	nation_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	nation_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	nation_label.clip_text = true

	nation_label.add_theme_font_size_override(
		"font_size",
		7 if is_compact else 9
	)

	nation_label.add_theme_color_override(
		"font_color",
		Color(
			0.50,
			0.58,
			0.68
		)
	)

	vbox.add_child(nation_label)


	# ========================================================
	# РАЗДЕЛИТЕЛЬ СТАТИСТИКИ
	# ========================================================

	var stats_separator := ColorRect.new()

	stats_separator.custom_minimum_size = Vector2(
		0,
		1
	)

	stats_separator.color = Color(
		1.0,
		1.0,
		1.0,
		0.10
	)

	stats_separator.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(stats_separator)


	# ========================================================
	# СТАТИСТИКИ
	# ========================================================

	var stats_grid := GridContainer.new()

	stats_grid.columns = 3

	stats_grid.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	stats_grid.add_theme_constant_override(
		"h_separation",
		3
	)

	stats_grid.add_theme_constant_override(
		"v_separation",
		1
	)

	stats_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(stats_grid)


	pace_label = _create_stat_label("PAC")
	shooting_label = _create_stat_label("SHO")
	passing_label = _create_stat_label("PAS")
	dribbling_label = _create_stat_label("DRI")
	defending_label = _create_stat_label("DEF")
	physical_label = _create_stat_label("PHY")

	stats_grid.add_child(pace_label)
	stats_grid.add_child(shooting_label)
	stats_grid.add_child(passing_label)
	stats_grid.add_child(dribbling_label)
	stats_grid.add_child(defending_label)
	stats_grid.add_child(physical_label)


	# ========================================================
	# НИЖНИЙ ДЕКОР
	# ========================================================

	var bottom_line := ColorRect.new()

	bottom_line.custom_minimum_size = Vector2(
		0,
		1
	)

	bottom_line.color = Color(
		1.0,
		1.0,
		1.0,
		0.10
	)

	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(bottom_line)


	var bottom_label := Label.new()

	bottom_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	bottom_label.text = (
		"FC DRAFT"
		if not is_compact
		else "FC"
	)

	bottom_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	bottom_label.add_theme_font_size_override(
		"font_size",
		7 if is_compact else 8
	)

	bottom_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.82,
			0.32,
			0.55
		)
	)

	vbox.add_child(bottom_label)


	# ========================================================
	# КЛИК
	# ========================================================

	mouse_filter = Control.MOUSE_FILTER_STOP


# ============================================================
# СОЗДАНИЕ STAT LABEL
# ============================================================

func _create_stat_label(
	stat_name: String
) -> Label:

	var label := Label.new()

	label.text = stat_name + "  0"

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.add_theme_font_size_override(
		"font_size",
		7 if is_compact else 9
	)

	label.add_theme_color_override(
		"font_color",
		Color(
			0.82,
			0.86,
			0.92
		)
	)

	return label


# ============================================================
# ДЕКОРАТИВНАЯ ДИАГОНАЛЬ
# ============================================================

func _create_diagonal(
	start_position: Vector2,
	diagonal_size: Vector2,
	tint: Color
) -> void:

	var diagonal := ColorRect.new()

	diagonal.position = start_position
	diagonal.size = diagonal_size
	diagonal.color = tint
	diagonal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diagonal.rotation = -0.38

	add_child(diagonal)


# ============================================================
# ОБНОВЛЕНИЕ ДАННЫХ
# ============================================================

func _update_ui_values() -> void:

	# --------------------------------------------------------
	# Если UI ещё не построен — обновлять нечего.
	# --------------------------------------------------------

	if not _ui_built:
		return

	if player_data == null:
		return


	# ========================================================
	# ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ
	# ========================================================

	var p_name: String = "Игрок"
	var p_rating: int = 80
	var p_pos: String = "MID"
	var p_club: String = "FC Draft"
	var p_nation: String = ""

	var p_rarity: String = "BRONZE"

	var p_pace: int = 0
	var p_shooting: int = 0
	var p_passing: int = 0
	var p_dribbling: int = 0
	var p_defending: int = 0
	var p_physical: int = 0


	# ========================================================
	# PLAYER CARD
	# ========================================================

	if player_data is PlayerCard:

		p_name = player_data.player_name
		p_rating = player_data.rating
		p_pos = player_data.position
		p_club = player_data.club
		p_nation = player_data.nation

		p_rarity = player_data.rarity

		p_pace = player_data.pace
		p_shooting = player_data.shooting
		p_passing = player_data.passing
		p_dribbling = player_data.dribbling
		p_defending = player_data.defending
		p_physical = player_data.physical


	# ========================================================
	# DICTIONARY
	# ========================================================

	elif typeof(player_data) == TYPE_DICTIONARY:

		p_name = str(
			player_data.get(
				"player_name",
				player_data.get(
					"name",
					"Игрок"
				)
			)
		)

		p_rating = int(
			player_data.get(
				"rating",
				player_data.get(
					"overall",
					80
				)
			)
		)

		p_pos = str(
			player_data.get(
				"position",
				player_data.get(
					"pos",
					"MID"
				)
			)
		)

		p_club = str(
			player_data.get(
				"club",
				player_data.get(
					"club_name",
					"FC Draft"
				)
			)
		)

		p_nation = str(
			player_data.get(
				"nation",
				player_data.get(
					"nationality_name",
					""
				)
			)
		)

		p_rarity = str(
			player_data.get(
				"rarity",
				"BRONZE"
			)
		)

		p_pace = int(
			player_data.get(
				"pace",
				0
			)
		)

		p_shooting = int(
			player_data.get(
				"shooting",
				0
			)
		)

		p_passing = int(
			player_data.get(
				"passing",
				0
			)
		)

		p_dribbling = int(
			player_data.get(
				"dribbling",
				0
			)
		)

		p_defending = int(
			player_data.get(
				"defending",
				0
			)
		)

		p_physical = int(
			player_data.get(
				"physical",
				0
			)
		)


	# ========================================================
	# UI
	# ========================================================

	if rating_label != null:
		rating_label.text = str(p_rating)

	if pos_label != null:
		pos_label.text = p_pos.to_upper()

	if rarity_label != null:
		rarity_label.text = p_rarity.to_upper()

	if name_label != null:
		name_label.text = p_name

	if club_label != null:
		club_label.text = p_club

	if nation_label != null:
		nation_label.text = p_nation

	if pace_label != null:
		pace_label.text = "PAC  " + str(p_pace)

	if shooting_label != null:
		shooting_label.text = "SHO  " + str(p_shooting)

	if passing_label != null:
		passing_label.text = "PAS  " + str(p_passing)

	if dribbling_label != null:
		dribbling_label.text = "DRI  " + str(p_dribbling)

	if defending_label != null:
		defending_label.text = "DEF  " + str(p_defending)

	if physical_label != null:
		physical_label.text = "PHY  " + str(p_physical)


# ============================================================
# ОБРАБОТКА КЛИКА
# ============================================================

func _gui_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				print(
					"CardUI: КЛИК ПО КАРТОЧКЕ -> ",
					_get_player_name()
				)

				card_selected.emit(
					player_data
				)

				accept_event()


	elif event is InputEventScreenTouch:

		if event.pressed:

			print(
				"CardUI: ТАЧ ПО КАРТОЧКЕ -> ",
				_get_player_name()
			)

			card_selected.emit(
				player_data
			)

			accept_event()


# ============================================================
# ИМЯ ИГРОКА
# ============================================================

func _get_player_name() -> String:

	if player_data is PlayerCard:

		return player_data.player_name


	if typeof(player_data) == TYPE_DICTIONARY:

		return str(
			player_data.get(
				"player_name",
				player_data.get(
					"name",
					"Игрок"
				)
			)
		)


	return "Игрок"
