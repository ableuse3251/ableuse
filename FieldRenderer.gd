class_name FieldRenderer
extends Control

# ============================================================
# ОТРИСОВКА ПОЛЯ И КАРТОЧЕК НА ПОЛЕ (КОМПОНЕНТ PITCHSCREEN)
# ============================================================
# Берёт на себя бывший PitchScreen._draw(): фон, газон, полосы,
# виньетка, разметка, штрафные/воротная зоны, точки, дуги,
# угловые. Плюс управление мини-карточками игроков на поле
# (создание/позиционирование/очистка).
#
# Добавляется как первый ребёнок PitchScreen (индекс 0),
# поэтому рисуется под chem_label и всеми остальными узлами —
# тот же порядок, что был у _draw() родителя.
# ============================================================

const GameColors := preload("res://GameColors.gd")

var screen: PitchScreen

var field_rect: Rect2 = Rect2()

var field_card_nodes: Array[Node] = []
var field_card_slot_indices: Array[int] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_field_rect(rect: Rect2) -> void:
	field_rect = rect
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.020, 0.030, 1.0), true)

	var field := field_rect
	var field_width := field.size.x
	var field_height := field.size.y
	var line_color := GameColors.PITCH_LINE
	var line_width := 2.0
	var thin_line_width := 1.5

	var glow_center := Vector2(size.x * 0.5, field.position.y + field.size.y * 0.5)
	draw_circle(glow_center, min(field_width * 0.65, 550.0), GameColors.PITCH_GLOW)

	draw_style_box(
		_create_field_shadow_style(),
		Rect2(field.position + Vector2(0, 6), field.size)
	)

	draw_rect(field, GameColors.PITCH_GRASS, true)

	var stripe_count := 10
	var stripe_width: float = field_width / float(stripe_count)
	for i in range(stripe_count):
		var stripe_color := GameColors.PITCH_STRIPE_A if i % 2 == 0 else GameColors.PITCH_STRIPE_B
		draw_rect(
			Rect2(field.position.x + stripe_width * i, field.position.y, stripe_width + 1.0, field_height),
			stripe_color,
			true
		)

	var vignette_strength := 0.12
	var edge: float = field_width * 0.03
	draw_rect(Rect2(field.position.x, field.position.y, field_width, edge), Color(GameColors.BLACK, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.end.y - edge, field_width, edge), Color(GameColors.BLACK, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.position.y, edge, field_height), Color(GameColors.BLACK, vignette_strength), true)
	draw_rect(Rect2(field.end.x - edge, field.position.y, edge, field_height), Color(GameColors.BLACK, vignette_strength), true)

	draw_rect(field, line_color, false, line_width)

	var center_x := field.position.x + field_width * 0.5
	draw_line(Vector2(center_x, field.position.y), Vector2(center_x, field.end.y), line_color, line_width)

	var center := Vector2(center_x, field.position.y + field_height * 0.5)
	var center_radius: float = field_height * 0.18
	draw_arc(center, center_radius, 0.0, TAU, 64, line_color, line_width)
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
	var goal_box_height: float = field_height * 0.25
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

	var goal_width: float = field_height * 0.12
	var goal_depth: float = field_width * 0.02
	var goal_left := Rect2(
		field.position.x - goal_depth,
		field.position.y + (field_height - goal_width) * 0.5,
		goal_depth,
		goal_width
	)
	var goal_right := Rect2(
		field.end.x,
		field.position.y + (field_height - goal_width) * 0.5,
		goal_depth,
		goal_width
	)

	draw_rect(goal_left, GameColors.PITCH_GOAL, true)
	draw_rect(goal_right, GameColors.PITCH_GOAL, true)

	var penalty_spot_offset: float = field_width * 0.11
	var left_penalty_spot := Vector2(field.position.x + penalty_spot_offset, field.position.y + field_height * 0.5)
	var right_penalty_spot := Vector2(field.end.x - penalty_spot_offset, field.position.y + field_height * 0.5)

	draw_circle(left_penalty_spot, 3.0, line_color)
	draw_circle(right_penalty_spot, 3.0, line_color)

	var penalty_arc_radius: float = field_width * 0.135

	var left_box_edge_x: float = field.position.x + penalty_box_width
	var right_box_edge_x: float = field.end.x - penalty_box_width

	var left_dist_to_edge: float = left_box_edge_x - left_penalty_spot.x
	var right_dist_to_edge: float = right_box_edge_x - right_penalty_spot.x

	var left_arc_angle: float = acos(left_dist_to_edge / penalty_arc_radius)
	var right_arc_angle: float = acos(right_dist_to_edge / penalty_arc_radius)

	draw_arc(
		left_penalty_spot,
		penalty_arc_radius,
		-left_arc_angle,
		left_arc_angle,
		40,
		line_color,
		thin_line_width
	)

	draw_arc(
		right_penalty_spot,
		penalty_arc_radius,
		PI - right_arc_angle,
		PI + right_arc_angle,
		40,
		line_color,
		thin_line_width
	)

	# ============================================================
	# УГЛОВЫЕ ДУГИ
	# ============================================================

	var corner_radius: float = field_width * 0.02

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


func _create_field_shadow_style() -> StyleBoxFlat:

	var style := StyleBoxFlat.new()
	style.bg_color = GameColors.SHADOW_FIELD
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style

# ============================================================
# ПОЗИЦИЯ СЛОТА НА ПОЛЕ
# ============================================================

func get_formation_field_position(slot_index: int) -> Vector2:

	var slots: Array[Dictionary] = screen.formation_slots

	if slot_index < 0 or slot_index >= slots.size():
		return field_rect.get_center()

	var slot: Dictionary = slots[slot_index]
	var x: float = float(slot.get("x", 0.5))
	var y: float = float(slot.get("y", 0.5))

	return Vector2(
		field_rect.position.x + field_rect.size.x * x,
		field_rect.position.y + field_rect.size.y * y
	)

# ============================================================
# КАРТОЧКА ИГРОКА НА ПОЛЕ
# ============================================================

func add_field_card(card: PlayerCard, slot_index: int) -> void:

	if screen.card_ui_scene == null:
		return

	var mini_card_node := screen.card_ui_scene.instantiate()
	if mini_card_node == null:
		return

	screen.add_child(mini_card_node)
	field_card_nodes.append(mini_card_node)
	field_card_slot_indices.append(slot_index)

	if mini_card_node.has_method("set_compact_mode"):
		mini_card_node.set_compact_mode()
	if mini_card_node.has_method("setup"):
		mini_card_node.setup(card)

	_position_card_node(mini_card_node, get_formation_field_position(slot_index))

func _create_field_card(card: PlayerCard, field_position: Vector2) -> void:

	if screen.card_ui_scene == null:
		return

	var mini_card_node := screen.card_ui_scene.instantiate()
	if mini_card_node == null:
		return

	screen.add_child(mini_card_node)
	field_card_nodes.append(mini_card_node)

	if mini_card_node.has_method("set_compact_mode"):
		mini_card_node.set_compact_mode()
	if mini_card_node.has_method("setup"):
		mini_card_node.setup(card)

	_position_card_node(mini_card_node, field_position)

func _position_card_node(card_node: Node, field_position: Vector2) -> void:

	if not card_node is Control:
		return

	var control := card_node as Control
	var target_width: float = min(field_rect.size.x * 0.11, 110.0)
	var scale_factor: float = target_width / 90.0

	control.scale = Vector2(scale_factor, scale_factor)
	control.position = field_position - Vector2(45.0, 55.0) * scale_factor

# ============================================================
# ПЕРЕПОЗИЦИОНИРОВАНИЕ КАРТОЧЕК
# ============================================================

func reposition_field_cards() -> void:

	if field_card_nodes.is_empty():
		return

	for i in range(field_card_nodes.size()):
		var node := field_card_nodes[i]
		if not is_instance_valid(node):
			continue
		if i >= field_card_slot_indices.size():
			continue
		var slot_index := field_card_slot_indices[i]
		_position_card_node(node, get_formation_field_position(slot_index))

# ============================================================
# ОЧИСТКА КАРТОЧЕК
# ============================================================

func clear_field_cards() -> void:

	for node in field_card_nodes:
		if is_instance_valid(node):
			node.queue_free()
	field_card_nodes.clear()
	field_card_slot_indices.clear()