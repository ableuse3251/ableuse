class_name FormationSelectScreen
extends Control

# ============================================================
# СИГНАЛЫ
# ============================================================

signal formation_selected(formation: Dictionary)

# ============================================================
# БАЗА ВСЕХ СХЕМ
# ============================================================

const ALL_FORMATIONS: Array[Dictionary] = [
	{"name": "4-4-2 Классика", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "LM", "x": 0.15, "y": 0.50},
		{"position": "CM", "x": 0.38, "y": 0.52}, {"position": "CM", "x": 0.62, "y": 0.52},
		{"position": "RM", "x": 0.85, "y": 0.50}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "4-3-3 Атака", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CM", "x": 0.30, "y": 0.52},
		{"position": "CDM", "x": 0.50, "y": 0.55}, {"position": "CM", "x": 0.70, "y": 0.52},
		{"position": "LW", "x": 0.20, "y": 0.25}, {"position": "ST", "x": 0.50, "y": 0.20},
		{"position": "RW", "x": 0.80, "y": 0.25}
	]},
	{"name": "3-5-2 Баланс", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "CB", "x": 0.25, "y": 0.78},
		{"position": "CB", "x": 0.50, "y": 0.80}, {"position": "CB", "x": 0.75, "y": 0.78},
		{"position": "LM", "x": 0.10, "y": 0.50}, {"position": "CM", "x": 0.35, "y": 0.52},
		{"position": "CM", "x": 0.50, "y": 0.48}, {"position": "CM", "x": 0.65, "y": 0.52},
		{"position": "RM", "x": 0.90, "y": 0.50}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "4-2-3-1 Модерн", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CDM", "x": 0.38, "y": 0.55},
		{"position": "CDM", "x": 0.62, "y": 0.55}, {"position": "LW", "x": 0.20, "y": 0.38},
		{"position": "CAM", "x": 0.50, "y": 0.35}, {"position": "RW", "x": 0.80, "y": 0.38},
		{"position": "ST", "x": 0.50, "y": 0.20}
	]},
	{"name": "4-1-4-1 Защита", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CDM", "x": 0.50, "y": 0.58},
		{"position": "LM", "x": 0.15, "y": 0.45}, {"position": "CM", "x": 0.38, "y": 0.48},
		{"position": "CM", "x": 0.62, "y": 0.48}, {"position": "RM", "x": 0.85, "y": 0.45},
		{"position": "ST", "x": 0.50, "y": 0.22}
	]},
	{"name": "3-4-3 Атака", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "CB", "x": 0.25, "y": 0.78},
		{"position": "CB", "x": 0.50, "y": 0.80}, {"position": "CB", "x": 0.75, "y": 0.78},
		{"position": "LM", "x": 0.12, "y": 0.50}, {"position": "CM", "x": 0.40, "y": 0.52},
		{"position": "CM", "x": 0.60, "y": 0.52}, {"position": "RM", "x": 0.88, "y": 0.50},
		{"position": "LW", "x": 0.20, "y": 0.25}, {"position": "ST", "x": 0.50, "y": 0.20},
		{"position": "RW", "x": 0.80, "y": 0.25}
	]},
	{"name": "5-3-2 Защита", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LWB", "x": 0.10, "y": 0.72},
		{"position": "CB", "x": 0.30, "y": 0.78}, {"position": "CB", "x": 0.50, "y": 0.80},
		{"position": "CB", "x": 0.70, "y": 0.78}, {"position": "RWB", "x": 0.90, "y": 0.72},
		{"position": "CM", "x": 0.30, "y": 0.50}, {"position": "CM", "x": 0.50, "y": 0.48},
		{"position": "CM", "x": 0.70, "y": 0.50}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "4-5-1 Защита", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "LM", "x": 0.12, "y": 0.48},
		{"position": "CM", "x": 0.35, "y": 0.50}, {"position": "CM", "x": 0.50, "y": 0.46},
		{"position": "CM", "x": 0.65, "y": 0.50}, {"position": "RM", "x": 0.88, "y": 0.48},
		{"position": "ST", "x": 0.50, "y": 0.22}
	]},
	{"name": "4-3-1-2 Узкая", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CM", "x": 0.30, "y": 0.52},
		{"position": "CDM", "x": 0.50, "y": 0.55}, {"position": "CM", "x": 0.70, "y": 0.52},
		{"position": "CAM", "x": 0.50, "y": 0.35}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "4-2-2-2 Квадрат", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CDM", "x": 0.38, "y": 0.55},
		{"position": "CDM", "x": 0.62, "y": 0.55}, {"position": "LM", "x": 0.20, "y": 0.40},
		{"position": "RM", "x": 0.80, "y": 0.40}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "3-4-1-2 Плеймейкер", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "CB", "x": 0.25, "y": 0.78},
		{"position": "CB", "x": 0.50, "y": 0.80}, {"position": "CB", "x": 0.75, "y": 0.78},
		{"position": "LM", "x": 0.12, "y": 0.50}, {"position": "CM", "x": 0.40, "y": 0.52},
		{"position": "CM", "x": 0.60, "y": 0.52}, {"position": "RM", "x": 0.88, "y": 0.50},
		{"position": "CAM", "x": 0.50, "y": 0.35}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "4-3-2-1 Ёлка", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CM", "x": 0.30, "y": 0.52},
		{"position": "CDM", "x": 0.50, "y": 0.55}, {"position": "CM", "x": 0.70, "y": 0.52},
		{"position": "LW", "x": 0.30, "y": 0.35}, {"position": "RW", "x": 0.70, "y": 0.35},
		{"position": "ST", "x": 0.50, "y": 0.20}
	]},
	{"name": "5-4-1 Автобус", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LWB", "x": 0.10, "y": 0.72},
		{"position": "CB", "x": 0.30, "y": 0.78}, {"position": "CB", "x": 0.50, "y": 0.80},
		{"position": "CB", "x": 0.70, "y": 0.78}, {"position": "RWB", "x": 0.90, "y": 0.72},
		{"position": "LM", "x": 0.15, "y": 0.48}, {"position": "CM", "x": 0.38, "y": 0.50},
		{"position": "CM", "x": 0.62, "y": 0.50}, {"position": "RM", "x": 0.85, "y": 0.48},
		{"position": "ST", "x": 0.50, "y": 0.22}
	]},
	{"name": "4-4-1-1 Поддержка", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "LM", "x": 0.15, "y": 0.50},
		{"position": "CM", "x": 0.38, "y": 0.52}, {"position": "CM", "x": 0.62, "y": 0.52},
		{"position": "RM", "x": 0.85, "y": 0.50}, {"position": "CAM", "x": 0.50, "y": 0.32},
		{"position": "ST", "x": 0.50, "y": 0.20}
	]},
	{"name": "4-1-3-2 Опорник", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LB", "x": 0.15, "y": 0.75},
		{"position": "CB", "x": 0.38, "y": 0.78}, {"position": "CB", "x": 0.62, "y": 0.78},
		{"position": "RB", "x": 0.85, "y": 0.75}, {"position": "CDM", "x": 0.50, "y": 0.58},
		{"position": "LM", "x": 0.20, "y": 0.42}, {"position": "CM", "x": 0.50, "y": 0.40},
		{"position": "RM", "x": 0.80, "y": 0.42}, {"position": "ST", "x": 0.35, "y": 0.22},
		{"position": "ST", "x": 0.65, "y": 0.22}
	]},
	{"name": "3-5-1-1 Контроль", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "CB", "x": 0.25, "y": 0.78},
		{"position": "CB", "x": 0.50, "y": 0.80}, {"position": "CB", "x": 0.75, "y": 0.78},
		{"position": "LM", "x": 0.10, "y": 0.50}, {"position": "CM", "x": 0.35, "y": 0.52},
		{"position": "CM", "x": 0.50, "y": 0.48}, {"position": "CM", "x": 0.65, "y": 0.52},
		{"position": "RM", "x": 0.90, "y": 0.50}, {"position": "CAM", "x": 0.50, "y": 0.32},
		{"position": "ST", "x": 0.50, "y": 0.20}
	]},
	{"name": "5-2-3 Контратака", "slots": [
		{"position": "GK", "x": 0.50, "y": 0.92}, {"position": "LWB", "x": 0.10, "y": 0.72},
		{"position": "CB", "x": 0.30, "y": 0.78}, {"position": "CB", "x": 0.50, "y": 0.80},
		{"position": "CB", "x": 0.70, "y": 0.78}, {"position": "RWB", "x": 0.90, "y": 0.72},
		{"position": "CM", "x": 0.38, "y": 0.52}, {"position": "CM", "x": 0.62, "y": 0.52},
		{"position": "LW", "x": 0.20, "y": 0.25}, {"position": "ST", "x": 0.50, "y": 0.20},
		{"position": "RW", "x": 0.80, "y": 0.25}
	]}
]

# ============================================================
# НАСТРОЙКИ
# ============================================================

const FORMATIONS_TO_SHOW: int = 4
const CARD_HEIGHT: float = 360.0
const CARD_MARGIN: float = 16.0
const PREVIEW_HEIGHT: float = 200.0

# ============================================================
# ПЕРЕМЕННЫЕ
# ============================================================

var available_formations: Array[Dictionary] = []

# ============================================================
# READY
# ============================================================

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_select_random_formations()
	_create_ui()

# ============================================================
# ВЫБОР СЛУЧАЙНЫХ СХЕМ
# ============================================================

func _select_random_formations() -> void:
	available_formations.clear()
	var all_formations_copy: Array[Dictionary] = []
	for formation in ALL_FORMATIONS:
		all_formations_copy.append(formation.duplicate(true))
	all_formations_copy.shuffle()
	var count: int = min(FORMATIONS_TO_SHOW, all_formations_copy.size())
	for i in range(count):
		available_formations.append(all_formations_copy[i])

# ============================================================
# СОЗДАНИЕ UI
# ============================================================

func _create_ui() -> void:
	# Фон
	var background := ColorRect.new()
	background.color = Color(0.02, 0.03, 0.05, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Декоративное свечение сверху
	var top_glow := ColorRect.new()
	top_glow.color = Color(0.1, 0.3, 0.5, 0.15)
	top_glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_glow.offset_bottom = 200.0
	add_child(top_glow)

	# Заголовок
	var title_label := Label.new()
	title_label.text = "ВЫБЕРИТЕ СХЕМУ"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_bottom = 80.0
	add_child(title_label)

	# Подзаголовок
	var subtitle_label := Label.new()
	subtitle_label.text = "4 случайные схемы из 17 доступных"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.8))
	subtitle_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle_label.offset_top = 80.0
	subtitle_label.offset_bottom = 105.0
	add_child(subtitle_label)

	# ScrollContainer
	var scroll_container := ScrollContainer.new()
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll_container.offset_top = 110.0
	scroll_container.offset_bottom = -20.0
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll_container)

	# Контейнер для карточек — растягивается на всю ширину
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", CARD_MARGIN)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(vbox)

	# Создаём карточки
	for formation in available_formations:
		var card := _create_formation_card(formation)
		vbox.add_child(card)

# ============================================================
# СОЗДАНИЕ КАРТОЧКИ СХЕМЫ
# ============================================================

func _create_formation_card(formation: Dictionary) -> Control:
	# Главный контейнер карточки — растягивается на всю ширину
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, CARD_HEIGHT)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Стиль карточки
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.09, 0.14, 0.95)
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.15, 0.25, 0.4, 0.6)
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 14
	card_style.content_margin_bottom = 14
	card.add_theme_stylebox_override("panel", card_style)

	# Внутренний VBoxContainer
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(vbox)

	# Верхняя строка: название + счётчик игроков
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(header)

	# Левая акцентная полоса
	var accent_bar := ColorRect.new()
	accent_bar.color = Color(0.2, 0.6, 1.0, 0.8)
	accent_bar.custom_minimum_size = Vector2(4, 28)
	header.add_child(accent_bar)

	# Название схемы
	var name_label := Label.new()
	name_label.text = formation["name"]
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 0.95))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)

	# Счётчик игроков
	var player_count_label := Label.new()
	player_count_label.text = str(formation["slots"].size()) + " игроков"
	player_count_label.add_theme_font_size_override("font_size", 14)
	player_count_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 0.7))
	player_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(player_count_label)

	# Превью поля — растягивается на всю ширину
	var preview_wrapper := Control.new()
	preview_wrapper.custom_minimum_size = Vector2(0, PREVIEW_HEIGHT)
	preview_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(preview_wrapper)

	# Превью поля (Control с draw)
	var preview := Control.new()
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_wrapper.add_child(preview)

	# Отрисовка превью
	preview.connect("draw", func():
		var preview_size: Vector2 = preview.size
		if preview_size.x < 10 or preview_size.y < 10:
			return

		# Вычисляем размер поля с сохранением пропорций (1.544)
		var field_aspect: float = 1.544
		var field_width: float = preview_size.x * 0.9
		var field_height: float = field_width / field_aspect
		if field_height > preview_size.y * 0.95:
			field_height = preview_size.y * 0.95
			field_width = field_height * field_aspect

		var field_x: float = (preview_size.x - field_width) * 0.5
		var field_y: float = (preview_size.y - field_height) * 0.5
		var field_rect := Rect2(field_x, field_y, field_width, field_height)

		# Фон поля
		preview.draw_rect(field_rect, Color(0.04, 0.22, 0.10, 1.0), true)

		# Полосы газона
		var stripe_count := 8
		var stripe_height: float = field_rect.size.y / float(stripe_count)
		for i in range(stripe_count):
			var stripe_color := Color(0.05, 0.25, 0.11, 1.0) if i % 2 == 0 else Color(0.035, 0.20, 0.09, 1.0)
			preview.draw_rect(
				Rect2(field_rect.position.x, field_rect.position.y + stripe_height * i, field_rect.size.x, stripe_height + 1.0),
				stripe_color,
				true
			)

		# Линии поля
		var line_color := Color(0.95, 0.98, 1.0, 0.75)
		preview.draw_rect(field_rect, line_color, false, 1.5)
		preview.draw_line(
			Vector2(field_rect.position.x, field_rect.position.y + field_rect.size.y * 0.5),
			Vector2(field_rect.end.x, field_rect.position.y + field_rect.size.y * 0.5),
			line_color, 1.5
		)

		# Центральный круг
		var center := Vector2(field_rect.get_center().x, field_rect.position.y + field_rect.size.y * 0.5)
		var center_radius: float = min(field_rect.size.x, field_rect.size.y) * 0.12
		preview.draw_arc(center, center_radius, 0.0, TAU, 48, line_color, 1.5)

		# Точки игроков
		for slot in formation["slots"]:
			var x: float = float(slot.get("x", 0.5))
			var y: float = float(slot.get("y", 0.5))
			var px: float = field_rect.position.x + x * field_rect.size.x
			var py: float = field_rect.position.y + y * field_rect.size.y
			# Свечение
			preview.draw_circle(Vector2(px, py), 10.0, Color(1.0, 0.85, 0.3, 0.35))
			# Точка
			preview.draw_circle(Vector2(px, py), 6.0, Color(1.0, 0.85, 0.3, 0.95))
	)

	# Кнопка выбора
	var select_button := Button.new()
	select_button.text = "ВЫБРАТЬ"
	select_button.custom_minimum_size = Vector2(0, 50)
	select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_button.add_theme_font_size_override("font_size", 16)
	select_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.15, 0.65, 0.35, 0.95)
	button_style.corner_radius_top_left = 12
	button_style.corner_radius_top_right = 12
	button_style.corner_radius_bottom_left = 12
	button_style.corner_radius_bottom_right = 12
	select_button.add_theme_stylebox_override("normal", button_style)

	var button_hover := button_style.duplicate()
	button_hover.bg_color = Color(0.2, 0.75, 0.4, 1.0)
	select_button.add_theme_stylebox_override("hover", button_hover)

	var button_pressed := button_style.duplicate()
	button_pressed.bg_color = Color(0.1, 0.55, 0.3, 1.0)
	select_button.add_theme_stylebox_override("pressed", button_pressed)

	select_button.pressed.connect(func():
		formation_selected.emit(formation)
		queue_free()
	)

	vbox.add_child(select_button)

	# Анимация при наведении
	card.mouse_entered.connect(func():
		var style: StyleBoxFlat = card.get_theme_stylebox("panel")
		if style:
			style.border_color = Color(0.3, 0.7, 1.0, 0.9)
			style.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	)
	card.mouse_exited.connect(func():
		var style: StyleBoxFlat = card.get_theme_stylebox("panel")
		if style:
			style.border_color = Color(0.15, 0.25, 0.4, 0.6)
			style.bg_color = Color(0.06, 0.09, 0.14, 0.95)
	)

	return card
