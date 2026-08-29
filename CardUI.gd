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
# UI ЭЛЕМЕНТЫ
# ============================================================

var name_label: Label
var rating_label: Label
var pos_label: Label
var main_panel: Panel
var glow_panel: Panel

# Для полного режима (драфт)
var club_label: Label
var nation_label: Label
var rarity_label: Label
var pace_label: Label
var shooting_label: Label
var passing_label: Label
var dribbling_label: Label
var defending_label: Label
var physical_label: Label

# ============================================================
# РАЗМЕРЫ
# ============================================================

const NORMAL_SIZE := Vector2(180, 260)
const COMPACT_SIZE := Vector2(90, 110) # Оптимизировано для поля

# ============================================================
# READY
# ============================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if custom_minimum_size == Vector2.ZERO:
		if is_compact:
			custom_minimum_size = COMPACT_SIZE
		else:
			custom_minimum_size = NORMAL_SIZE

	size = custom_minimum_size

	if not _ui_built:
		_build_ui()
		_ui_built = true

	_update_ui_values()

# ============================================================
# КОМПАКТНЫЙ РЕЖИМ
# ============================================================

func set_compact_mode() -> void:
	is_compact = true
	custom_minimum_size = COMPACT_SIZE
	size = COMPACT_SIZE

	if is_inside_tree():
		# Перестраиваем UI для компактного режима
		_ui_built = false
		_build_ui()
		_ui_built = true
		_update_ui_values()

# ============================================================
# УСТАНОВКА ИГРОКА
# ============================================================

func setup(data: Variant) -> void:
	player_data = data
	if _ui_built:
		_update_ui_values()

# ============================================================
# ЦВЕТА РЕДКОСТИ
# ============================================================

func _get_rarity_color(rarity: String) -> Color:
	match rarity.to_upper():
		"ELITE":
			return Color(0.2, 0.8, 1.0)    # Яркий голубой/циан для элиты
		"GOLD":
			return Color(0.95, 0.75, 0.2)  # Классический золотой
		"SILVER":
			return Color(0.75, 0.8, 0.85)  # Серебряный
		"BRONZE":
			return Color(0.65, 0.45, 0.25) # Бронзовый
		_:
			return Color(0.95, 0.75, 0.2)

# ============================================================
# СОЗДАНИЕ UI
# ============================================================

func _build_ui() -> void:
	# Очищаем старые дочерние узлы
	for child in get_children():
		child.queue_free()

	if is_compact:
		_build_compact_ui()
	else:
		_build_normal_ui()

# --------------------------------------------------------
# КОМПАКТНЫЙ UI (ДЛЯ ФУТБОЛЬНОГО ПОЛЯ)
# --------------------------------------------------------

func _build_compact_ui() -> void:
	custom_minimum_size = COMPACT_SIZE
	size = COMPACT_SIZE

	# 1. Свечение
	glow_panel = Panel.new()
	glow_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color(1.0, 0.8, 0.2, 0.15)
	glow_style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	glow_style.shadow_size = 4
	glow_style.set_corner_radius_all(8)
	glow_panel.add_theme_stylebox_override("panel", glow_style)
	add_child(glow_panel)

	# 2. Основная панель
	main_panel = Panel.new()
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.04, 0.06, 0.09, 0.98)
	card_style.set_border_width_all(2)
	card_style.border_color = Color(0.95, 0.75, 0.2, 0.9)
	card_style.set_corner_radius_all(8)
	card_style.shadow_size = 3
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	main_panel.add_theme_stylebox_override("panel", card_style)
	add_child(main_panel)

	# 3. Контейнер с отступами
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	main_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# 4. Верхняя строка: Рейтинг и Позиция
	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(top_row)

	rating_label = Label.new()
	rating_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	rating_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rating_label.add_theme_font_size_override("font_size", 22)
	rating_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	rating_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	rating_label.add_theme_constant_override("shadow_offset_x", 1)
	rating_label.add_theme_constant_override("shadow_offset_y", 1)
	top_row.add_child(rating_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(spacer)

	pos_label = Label.new()
	pos_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pos_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pos_label.add_theme_font_size_override("font_size", 11)
	pos_label.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	top_row.add_child(pos_label)

	# 5. Разделитель
	var separator := ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 2)
	separator.color = Color(0.95, 0.75, 0.2, 0.6)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(separator)

	# 6. Имя игрока (занимает всё оставшееся место по вертикали)
	var name_container := Control.new()
	name_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	name_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_container)

	name_label = Label.new()
	name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_container.add_child(name_label)

	# 7. Нижний декор
	var bottom_line := ColorRect.new()
	bottom_line.custom_minimum_size = Vector2(0, 1)
	bottom_line.color = Color(1.0, 1.0, 1.0, 0.15)
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(bottom_line)

	var bottom_label := Label.new()
	bottom_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_label.text = "FC"
	bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_label.add_theme_font_size_override("font_size", 7)
	bottom_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3, 0.6))
	vbox.add_child(bottom_label)

# --------------------------------------------------------
# ПОЛНЫЙ UI (ДЛЯ ЭКРАНА ДРАФТА)
# --------------------------------------------------------

func _build_normal_ui() -> void:
	custom_minimum_size = NORMAL_SIZE
	size = NORMAL_SIZE

	# Свечение
	glow_panel = Panel.new()
	glow_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color(1.0, 0.72, 0.15, 0.07)
	glow_style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	glow_style.shadow_size = 10
	glow_style.set_corner_radius_all(14)
	glow_panel.add_theme_stylebox_override("panel", glow_style)
	add_child(glow_panel)

	# Основная панель
	main_panel = Panel.new()
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.055, 0.075, 0.11, 1.0)
	card_style.set_border_width_all(2)
	card_style.border_color = Color(1.0, 0.78, 0.22, 1.0)
	card_style.set_corner_radius_all(10)
	card_style.shadow_size = 6
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	main_panel.add_theme_stylebox_override("panel", card_style)
	add_child(main_panel)

	# Внутренняя рамка
	var inner_panel := Panel.new()
	inner_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = Color(0, 0, 0, 0)
	inner_style.set_border_width_all(1)
	inner_style.border_color = Color(1.0, 0.9, 0.55, 0.18)
	inner_style.set_corner_radius_all(8)
	inner_panel.add_theme_stylebox_override("panel", inner_style)
	main_panel.add_child(inner_panel)

	# Декоративная верхняя линия
	var top_decor := ColorRect.new()
	top_decor.position = Vector2(6, 6)
	top_decor.size = Vector2(size.x * 0.48, 2)
	top_decor.color = Color(1.0, 0.84, 0.30, 0.75)
	top_decor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_panel.add_child(top_decor)

	# Margin
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	main_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	# Верхняя строка
	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(top_row)

	rating_label = Label.new()
	rating_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rating_label.text = "80"
	rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rating_label.add_theme_font_size_override("font_size", 30)
	rating_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.38))
	rating_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	rating_label.add_theme_constant_override("shadow_offset_x", 1)
	rating_label.add_theme_constant_override("shadow_offset_y", 2)
	top_row.add_child(rating_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(spacer)

	rarity_label = Label.new()
	rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rarity_label.text = "BRONZE"
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rarity_label.add_theme_font_size_override("font_size", 9)
	rarity_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.22))
	top_row.add_child(rarity_label)

	pos_label = Label.new()
	pos_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pos_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pos_label.add_theme_font_size_override("font_size", 13)
	pos_label.add_theme_color_override("font_color", Color(0.50, 0.85, 1.0))
	top_row.add_child(pos_label)

	# Разделитель
	var separator := ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 1)
	separator.color = Color(1.0, 0.82, 0.30, 0.28)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(separator)

	# Центральная зона (для эмблемы)
	var center_space := Control.new()
	center_space.custom_minimum_size = Vector2(0, 86)
	center_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(center_space)

	var emblem := Label.new()
	emblem.text = "◆"
	emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emblem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emblem.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	emblem.position -= Vector2(20, 20)
	emblem.size = Vector2(40, 40)
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem.add_theme_font_size_override("font_size", 28)
	emblem.add_theme_color_override("font_color", Color(1.0, 0.78, 0.22, 0.28))
	center_space.add_child(emblem)

	# Имя
	name_label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.clip_text = true
	name_label.custom_minimum_size = Vector2(0, 38)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(name_label)

	# Клуб
	club_label = Label.new()
	club_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	club_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	club_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	club_label.clip_text = true
	club_label.add_theme_font_size_override("font_size", 11)
	club_label.add_theme_color_override("font_color", Color(0.64, 0.70, 0.78))
	vbox.add_child(club_label)

	# Страна
	nation_label = Label.new()
	nation_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nation_label.clip_text = true
	nation_label.add_theme_font_size_override("font_size", 9)
	nation_label.add_theme_color_override("font_color", Color(0.50, 0.58, 0.68))
	vbox.add_child(nation_label)

	# Разделитель статистики
	var stats_separator := ColorRect.new()
	stats_separator.custom_minimum_size = Vector2(0, 1)
	stats_separator.color = Color(1.0, 1.0, 1.0, 0.10)
	stats_separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stats_separator)

	# Статистика
	var stats_grid := GridContainer.new()
	stats_grid.columns = 3
	stats_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_grid.add_theme_constant_override("h_separation", 3)
	stats_grid.add_theme_constant_override("v_separation", 1)
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

	# Нижний декор
	var bottom_line := ColorRect.new()
	bottom_line.custom_minimum_size = Vector2(0, 1)
	bottom_line.color = Color(1.0, 1.0, 1.0, 0.10)
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(bottom_line)

	var bottom_label := Label.new()
	bottom_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_label.text = "FC DRAFT"
	bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_label.add_theme_font_size_override("font_size", 8)
	bottom_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.32, 0.55))
	vbox.add_child(bottom_label)

# ============================================================
# СОЗДАНИЕ STAT LABEL
# ============================================================

func _create_stat_label(stat_name: String) -> Label:
	var label := Label.new()
	label.text = stat_name + "  0"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92))
	return label

# ============================================================
# ОБНОВЛЕНИЕ ДАННЫХ
# ============================================================

func _update_ui_values() -> void:
	if not _ui_built or player_data == null:
		return

	var p_name: String = "Игрок"
	var p_rating: int = 80
	var p_pos: String = "MID"
	var p_rarity: String = "BRONZE"
	var p_club: String = "FC Draft"
	var p_nation: String = ""

	var p_pace: int = 0
	var p_shooting: int = 0
	var p_passing: int = 0
	var p_dribbling: int = 0
	var p_defending: int = 0
	var p_physical: int = 0

	if player_data is PlayerCard:
		p_name = player_data.player_name
		p_rating = player_data.rating
		p_pos = player_data.position
		p_rarity = player_data.rarity
		p_club = player_data.club
		p_nation = player_data.nation
		p_pace = player_data.pace
		p_shooting = player_data.shooting
		p_passing = player_data.passing
		p_dribbling = player_data.dribbling
		p_defending = player_data.defending
		p_physical = player_data.physical

	elif typeof(player_data) == TYPE_DICTIONARY:
		p_name = str(player_data.get("player_name", player_data.get("name", "Игрок")))
		p_rating = int(player_data.get("rating", player_data.get("overall", 80)))
		p_pos = str(player_data.get("position", player_data.get("pos", "MID")))
		p_rarity = str(player_data.get("rarity", "BRONZE"))
		p_club = str(player_data.get("club", player_data.get("club_name", "FC Draft")))
		p_nation = str(player_data.get("nation", player_data.get("nationality_name", "")))
		p_pace = int(player_data.get("pace", 0))
		p_shooting = int(player_data.get("shooting", 0))
		p_passing = int(player_data.get("passing", 0))
		p_dribbling = int(player_data.get("dribbling", 0))
		p_defending = int(player_data.get("defending", 0))
		p_physical = int(player_data.get("physical", 0))

	# Применяем цвет редкости к рамке и свечению
	var rarity_color := _get_rarity_color(p_rarity)

	if main_panel != null:
		var style: StyleBoxFlat = main_panel.get_theme_stylebox("panel")
		if style:
			style.border_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.9 if is_compact else 1.0)
			
	if glow_panel != null:
		var glow_style: StyleBoxFlat = glow_panel.get_theme_stylebox("panel")
		if glow_style:
			glow_style.bg_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.15)
			glow_style.shadow_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.3)

	# Обновляем тексты
	if rating_label != null:
		rating_label.text = str(p_rating)
		rating_label.add_theme_color_override("font_color", rarity_color.lightened(0.2))

	if pos_label != null:
		pos_label.text = p_pos.to_upper()

	if name_label != null:
		name_label.text = p_name

	# Для полного режима обновляем остальные поля
	if not is_compact:
		if rarity_label != null: rarity_label.text = p_rarity.to_upper()
		if club_label != null: club_label.text = p_club
		if nation_label != null: nation_label.text = p_nation

		if pace_label != null: pace_label.text = "PAC  " + str(p_pace)
		if shooting_label != null: shooting_label.text = "SHO  " + str(p_shooting)
		if passing_label != null: passing_label.text = "PAS  " + str(p_passing)
		if dribbling_label != null: dribbling_label.text = "DRI  " + str(p_dribbling)
		if defending_label != null: defending_label.text = "DEF  " + str(p_defending)
		if physical_label != null: physical_label.text = "PHY  " + str(p_physical)

# ============================================================
# ОБРАБОТКА КЛИКА
# ============================================================

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_selected.emit(player_data)
			accept_event()
	elif event is InputEventScreenTouch:
		if event.pressed:
			card_selected.emit(player_data)
			accept_event()
