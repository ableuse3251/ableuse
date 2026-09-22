class_name SquadFieldController
extends Control

# ============================================================
# ПОЛЕ И СЛОТЫ (КОМПОНЕНТ SQUADSCREEN)
# ============================================================
# Рисует фон экрана и футбольное поле (бывший SquadScreen._draw),
# вычисляет геометрию поля (field_rect), создаёт кнопки пустых
# слотов и мини-карточки игроков, позиционирует и очищает их.
#
# Добавляется первым ребёнком SquadScreen (индекс 0), поэтому
# рисуется ПОД всеми остальными узлами — тот же порядок, что
# был у _draw() родителя. Mouse-события игнорируются.
# ============================================================

const GameColors := preload("res://GameColors.gd")

var screen: SquadScreen

var field_rect: Rect2 = Rect2()

var slot_buttons: Array[Button] = []

var field_cards: Array[Node] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	if field_rect.size.x <= 0 or field_rect.size.y <= 0:
		return

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.020, 0.030, 1.0), true)

	var field := field_rect
	var field_width := field.size.x
	var field_height := field.size.y

	var line_color := GameColors.PITCH_LINE
	var line_width := 2.0
	var thin_line_width := 1.5

	var glow_center := Vector2(size.x * 0.5, field.position.y + field.size.y * 0.5)
	draw_circle(glow_center, min(field_width * 0.65, 550.0), GameColors.PITCH_GLOW)

	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = GameColors.SHADOW_FIELD
	shadow_style.set_corner_radius_all(16)
	draw_style_box(shadow_style, Rect2(field.position + Vector2(0, 6), field.size))

	draw_rect(field, GameColors.PITCH_GRASS, true)

	var stripe_count := 10
	var stripe_width: float = field_width / float(stripe_count)

	for i in range(stripe_count):
		var stripe_color := GameColors.PITCH_STRIPE_A if i % 2 == 0 else GameColors.PITCH_STRIPE_B
		draw_rect(
			Rect2(
				field.position.x + stripe_width * i,
				field.position.y,
				stripe_width + 1.0,
				field_height
			),
			stripe_color,
			true
		)

	var vignette_strength := 0.12
	var edge: float = field_width * 0.03

	draw_rect(
		Rect2(field.position.x, field.position.y, field_width, edge),
		Color(GameColors.BLACK, vignette_strength),
		true
	)
	draw_rect(
		Rect2(field.position.x, field.end.y - edge, field_width, edge),
		Color(GameColors.BLACK, vignette_strength),
		true
	)
	draw_rect(
		Rect2(field.position.x, field.position.y, edge, field_height),
		Color(GameColors.BLACK, vignette_strength),
		true
	)
	draw_rect(
		Rect2(field.end.x - edge, field.position.y, edge, field_height),
		Color(GameColors.BLACK, vignette_strength),
		true
	)

	draw_rect(field, line_color, false, line_width)

	var center_x := field.position.x + field_width * 0.5
	draw_line(
		Vector2(center_x, field.position.y),
		Vector2(center_x, field.end.y),
		line_color,
		line_width
	)

	var center := Vector2(center_x, field.position.y + field_height * 0.5)
	var center_radius: float = field_height * 0.18

	draw_arc(
		center,
		center_radius,
		0.0,
		TAU,
		64,
		line_color,
		line_width
	)
	draw_circle(center, 3.0, line_color)

	var penalty_box_width: float = field_width * 0.18
	var penalty_box_height: float = field_height * 0.50

	var penalty_box_left := Rect2(
		field.position.x,
		field.position.y + (field_height - penalty_box_height) * 0.5,
		penalty_box_width,
		penalty_box_height
	)

	var penalty_box_right := Rect2(
		field.end.x - penalty_box_width,
		field.position.y + (field_height - penalty_box_height) * 0.5,
		penalty_box_width,
		penalty_box_height
	)

	draw_rect(penalty_box_left, line_color, false, line_width)
	draw_rect(penalty_box_right, line_color, false, line_width)

	var goal_box_width: float = field_width * 0.06
	var goal_box_height: float = field_height * 0.22

	var goal_box_left := Rect2(
		field.position.x,
		field.position.y + (field_height - goal_box_height) * 0.5,
		goal_box_width,
		goal_box_height
	)

	var goal_box_right := Rect2(
		field.end.x - goal_box_width,
		field.position.y + (field_height - goal_box_height) * 0.5,
		goal_box_width,
		goal_box_height
	)

	draw_rect(goal_box_left, line_color, false, line_width)
	draw_rect(goal_box_right, line_color, false, line_width)

	var penalty_spot_offset: float = field_width * 0.12

	draw_circle(
		Vector2(field.position.x + penalty_spot_offset, center.y),
		3.0,
		line_color
	)

	draw_circle(
		Vector2(field.end.x - penalty_spot_offset, center.y),
		3.0,
		line_color
	)

	var corner_radius: float = min(field_width, field_height) * 0.015

	draw_arc(
		field.position,
		corner_radius,
		0.0,
		PI * 0.5,
		20,
		line_color,
		thin_line_width
	)

	draw_arc(
		Vector2(field.end.x, field.position.y),
		corner_radius,
		PI * 0.5,
		PI,
		20,
		line_color,
		thin_line_width
	)

	draw_arc(
		Vector2(field.position.x, field.end.y),
		corner_radius,
		PI * 1.5,
		TAU,
		20,
		line_color,
		thin_line_width
	)

	draw_arc(
		field.end,
		corner_radius,
		PI,
		PI * 1.5,
		20,
		line_color,
		thin_line_width
	)

# ============================================================
# ГЕОМЕТРИЯ ПОЛЯ
# ============================================================

func update_field_rect() -> void:
	var available_width := size.x - 36.0
	var available_height := size.y - 240.0

	available_width = max(available_width, 400.0)
	available_height = max(available_height, 300.0)

	var field_aspect_ratio := 1.544
	var field_height := available_height
	var field_width := field_height * field_aspect_ratio

	if field_width > available_width:
		field_width = available_width
		field_height = field_width / field_aspect_ratio

	var field_x := (size.x - field_width) * 0.5
	var field_y := 70.0 + (available_height - field_height) * 0.5

	field_rect = Rect2(field_x, field_y, field_width, field_height)


func get_slot_position(slot_index: int) -> Vector2:
	if slot_index < 0 or slot_index >= screen.formation_slots.size():
		return field_rect.get_center()

	var slot: Dictionary = screen.formation_slots[slot_index]

	return Vector2(
		field_rect.position.x + field_rect.size.x * float(slot.get("x", 0.5)),
		field_rect.position.y + field_rect.size.y * float(slot.get("y", 0.5))
	)

# ============================================================
# КНОПКА ПУСТОГО СЛОТА
# ============================================================

func create_slot_button(slot_index: int) -> void:
	var btn := Button.new()
	btn.text = screen.formation_slots[slot_index].position
	btn.custom_minimum_size = Vector2(60, 40)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 12)
	btn.z_index = 10

	var slot_idx: int = slot_index
	btn.pressed.connect(func(): screen._on_slot_pressed(slot_idx))

	apply_position_button_style(btn, false)
	screen.add_child(btn)
	slot_buttons.append(btn)

	btn.position = get_slot_position(slot_index) - Vector2(30, 20)

# ============================================================
# КАРТОЧКА ИГРОКА НА ПОЛЕ
# ============================================================

func create_field_card(card: PlayerCard, slot_index: int) -> void:
	if screen.card_ui_scene == null:
		return

	var card_node: CardUI = screen.card_ui_scene.instantiate()
	card_node.z_index = 5
	screen.add_child(card_node)
	field_cards.append(card_node)

	card_node.set_compact_mode()
	card_node.setup(card)

	card_node.card_selected.connect(
		func(_data): screen._on_field_card_clicked(slot_index)
	)

	card_node.position = get_slot_position(slot_index) - Vector2(72, 80) * 0.8
	card_node.scale = Vector2(0.8, 0.8)

# ============================================================
# ПЕРЕПОЗИЦИОНИРОВАНИЕ
# ============================================================

func reposition_slots_and_cards() -> void:
	for i in range(slot_buttons.size()):
		if is_instance_valid(slot_buttons[i]):
			slot_buttons[i].position = get_slot_position(i) - Vector2(30, 20)

	for i in range(field_cards.size()):
		if is_instance_valid(field_cards[i]):
			var card_node: Control = field_cards[i] as Control
			card_node.scale = Vector2(0.8, 0.8)
			card_node.position = get_slot_position(i) - Vector2(72, 80) * 0.8

# ============================================================
# ОЧИСТКА
# ============================================================

func clear_slots_and_cards() -> void:
	for btn in slot_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	slot_buttons.clear()

	for card in field_cards:
		if is_instance_valid(card):
			card.queue_free()
	field_cards.clear()

# ============================================================
# СТИЛЬ КНОПКИ СЛОТА
# ============================================================

func apply_position_button_style(button: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = GameColors.BTN_POSITION if not selected else GameColors.BTN_POSITION_ACTIVE

	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10

	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2

	normal.border_color = GameColors.BTN_POSITION_ACTIVE_BORDER if not selected else GameColors.BORDER_MEDIUM

	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()

	if not selected:
		hover.bg_color = GameColors.BTN_POSITION_HOVER

	button.add_theme_stylebox_override("hover", hover)

	button.add_theme_color_override(
		"font_color",
		GameColors.TEXT_BRIGHT
	)