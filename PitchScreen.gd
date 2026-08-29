class_name PitchScreen
extends Control

# ============================================================
# СЦЕНЫ
# ============================================================

@export var formation_select_scene: PackedScene
@export var draft_select_scene: PackedScene
@export var card_ui_scene: PackedScene
@export var summary_screen_scene: PackedScene

@onready var chem_label: Label = $ChemLabel

# ============================================================
# ВЕРХНИЙ HUD
# ============================================================

var store_button: Button
var club_button: Button
var coins_label: Label
var top_layer: CanvasLayer

var chemistry_panel: PanelContainer
var chemistry_progress: ProgressBar

# ============================================================
# КНОПКА НОВОГО ДРАФТА
# ============================================================

var draft_button: Button

# ============================================================
# ПОЛЕ
# ============================================================

var field_rect: Rect2 = Rect2()

var field_margin_top: float = 78.0
var field_margin_bottom: float = 20.0
var field_margin_horizontal: float = 18.0

# ============================================================
# СХЕМА
# ============================================================

var selected_formation: Dictionary = {}

var formation_slots: Array[Dictionary] = []

var selected_slot_indices: Array[int] = []

var position_buttons: Array[Button] = []

# ============================================================
# КАРТОЧКИ НА ПОЛЕ
# ============================================================

var field_card_nodes: Array[Node] = []

var field_card_slot_indices: Array[int] = []

# ============================================================
# ТЕКУЩИЙ ДРАФТ
# ============================================================

var current_draft_screen: Node = null

var selecting_position: bool = false

var draft_in_progress: bool = false

var showing_saved_lineup: bool = false

# ============================================================
# СОСТОЯНИЕ
# ============================================================

var current_selected_slot: int = -1

# ============================================================
# READY
# ============================================================

func _ready() -> void:

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	for node in get_children():

		if node == chem_label:
			continue

		var n_name: String = node.name.to_lower()

		if (
			"line" in n_name
			or "container" in n_name
			or "formation" in n_name
			or "grid" in n_name
		):

			node.queue_free()

	setup_top_ui_layer()

	_update_field_rect()

	if _has_saved_lineup():

		show_saved_lineup()

	else:

		start_new_draft()

	queue_redraw()

# ============================================================
# RESIZE
# ============================================================

func _notification(what: int) -> void:

	if what == NOTIFICATION_RESIZED:

		_update_field_rect()

		_reposition_field_cards()

		_reposition_position_buttons()

		queue_redraw()

# ============================================================
# РАЗМЕР ПОЛЯ (ИСПРАВЛЕНО - FIFA ПРОПОРЦИИ)
# ============================================================

func _update_field_rect() -> void:

	var available_width: float = (
		size.x - field_margin_horizontal * 2.0
	)

	var available_height: float = (
		size.y - field_margin_top - field_margin_bottom
	)

	available_width = max(
		available_width,
		300.0
	)

	available_height = max(
		available_height,
		450.0
	)

	# Стандартное соотношение футбольного поля FIFA: 105м x 68м = 1.544
	var field_aspect_ratio: float = 1.544

	var field_width: float = available_width
	var field_height: float = field_width * field_aspect_ratio

	# Если поле не влезает по высоте, подстраиваем по высоте
	if field_height > available_height:
		field_height = available_height
		field_width = field_height / field_aspect_ratio

	var field_x: float = (
		size.x - field_width
	) * 0.5

	var field_y: float = field_margin_top

	if field_height < available_height:

		field_y = (
			field_margin_top
			+ (
				available_height
				- field_height
			) * 0.5
		)

	field_rect = Rect2(
		field_x,
		field_y,
		field_width,
		field_height
	)

# ============================================================
# ПРОВЕРКА СОХРАНЁННОГО СОСТАВА
# ============================================================

func _has_saved_lineup() -> bool:

	if not is_instance_valid(ClubManager):
		return false

	return ClubManager.starting_lineup.size() > 0

# ============================================================
# ВЕРХНИЙ HUD
# ============================================================

func setup_top_ui_layer() -> void:

	top_layer = CanvasLayer.new()

	top_layer.layer = 10

	add_child(top_layer)

	var top_panel := Panel.new()

	top_panel.set_anchors_preset(
		Control.PRESET_TOP_WIDE
	)

	top_panel.offset_bottom = 64.0

	var top_style := StyleBoxFlat.new()

	top_style.bg_color = Color(
		0.025,
		0.035,
		0.055,
		0.97
	)

	top_style.border_width_bottom = 1

	top_style.border_color = Color(
		1,
		1,
		1,
		0.08
	)

	top_panel.add_theme_stylebox_override(
		"panel",
		top_style
	)

	top_layer.add_child(top_panel)

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		8
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		8
	)

	top_panel.add_child(margin)

	var top_bar := HBoxContainer.new()

	top_bar.add_theme_constant_override(
		"separation",
		7
	)

	margin.add_child(top_bar)

	# ========================================================
	# МОЙ КЛУБ
	# ========================================================

	club_button = Button.new()

	club_button.text = "🏆  КЛУБ"

	club_button.custom_minimum_size = Vector2(
		100,
		42
	)

	club_button.add_theme_font_size_override(
		"font_size",
		14
	)

	club_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	club_button.pressed.connect(
		_on_club_pressed
	)

	_apply_button_style(
		club_button,
		Color(
			0.075,
			0.105,
			0.15
		)
	)

	top_bar.add_child(
		club_button
	)

	# ========================================================
	# МАГАЗИН
	# ========================================================

	store_button = Button.new()

	store_button.text = "🛒  МАГАЗИН"

	store_button.custom_minimum_size = Vector2(
		115,
		42
	)

	store_button.add_theme_font_size_override(
		"font_size",
		14
	)

	store_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	store_button.pressed.connect(
		_on_store_pressed
	)

	_apply_button_style(
		store_button,
		Color(
			0.075,
			0.105,
			0.15
		)
	)

	top_bar.add_child(
		store_button
	)

	# ========================================================
	# РАСПОРКА
	# ========================================================

	var spacer := Control.new()

	spacer.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	top_bar.add_child(spacer)

	# ========================================================
	# СЫГРАННОСТЬ
	# ========================================================

	var chemistry_box := VBoxContainer.new()

	chemistry_box.custom_minimum_size = Vector2(
		120,
		42
	)

	chemistry_box.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	chemistry_box.add_theme_constant_override(
		"separation",
		1
	)

	top_bar.add_child(chemistry_box)

	chem_label = Label.new()

	chem_label.text = "⚡  Сыгранность 0 / 33"

	chem_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	chem_label.add_theme_font_size_override(
		"font_size",
		12
	)

	chem_label.add_theme_color_override(
		"font_color",
		Color(
			0.55,
			1.0,
			0.65
		)
	)

	chemistry_box.add_child(
		chem_label
	)

	chemistry_progress = ProgressBar.new()

	chemistry_progress.min_value = 0
	chemistry_progress.max_value = 33
	chemistry_progress.value = 0

	chemistry_progress.show_percentage = false

	chemistry_progress.custom_minimum_size = Vector2(
		110,
		5
	)

	chemistry_box.add_child(
		chemistry_progress
	)

	# ========================================================
	# МОНЕТЫ
	# ========================================================

	coins_label = Label.new()

	coins_label.text = (
		"💰 "
		+ str(UserProfile.coins)
	)

	coins_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	coins_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	coins_label.custom_minimum_size = Vector2(
		82,
		42
	)

	coins_label.add_theme_font_size_override(
		"font_size",
		16
	)

	coins_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.86,
			0.3
		)
	)

	top_bar.add_child(
		coins_label
	)

# ============================================================
# РИСОВАНИЕ ПОЛЯ (ИСПРАВЛЕНО - ПРАВИЛЬНЫЕ ПРОПОРЦИИ)
# ============================================================

func _draw() -> void:

	# 1. Фон экрана
	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.015, 0.020, 0.030, 1.0),
		true
	)

	var field := field_rect
	
	# Базовый размер для всех расчётов — ширина и высота поля
	var field_width := field.size.x
	var field_height := field.size.y
	
	# Цвет и толщина линий
	var line_color := Color(0.95, 0.98, 1.0, 0.90)
	var line_width := 2.0
	var thin_line_width := 1.5

	# 2. Мягкое свечение за полем
	var glow_center := Vector2(size.x * 0.5, field.position.y + field.size.y * 0.42)
	draw_circle(glow_center, min(size.x * 0.58, 480.0), Color(0.035, 0.16, 0.075, 0.16))

	# 3. Тень поля
	draw_style_box(
		_create_field_shadow_style(),
		Rect2(field.position + Vector2(0, 6), field.size)
	)

	# 4. Основа газона
	draw_rect(field, Color(0.045, 0.245, 0.105, 1.0), true)

	# 5. Полосы газона (10 широких полос)
	var stripe_count := 10
	var stripe_height := field_height / float(stripe_count)
	for i in range(stripe_count):
		var stripe_color := Color(0.055, 0.265, 0.115, 1.0) if i % 2 == 0 else Color(0.040, 0.220, 0.090, 1.0)
		draw_rect(
			Rect2(field.position.x, field.position.y + stripe_height * i, field_width, stripe_height + 1.0),
			stripe_color,
			true
		)

	# 6. Лёгкая виньетка по краям
	var vignette_strength := 0.12
	var edge := field_width * 0.05
	draw_rect(Rect2(field.position.x, field.position.y, field_width, edge), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.end.y - edge, field_width, edge), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.position.y, edge, field_height), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.end.x - edge, field.position.y, edge, field_height), Color(0, 0, 0, vignette_strength), true)

	# 7. Внешняя рамка
	draw_rect(field, line_color, false, line_width)

	# 8. Центральная линия
	var center_y := field.position.y + field_height * 0.5
	draw_line(Vector2(field.position.x, center_y), Vector2(field.end.x, center_y), line_color, line_width)

	# 9. Центральный круг (радиус 9.15м при ширине 68м = 0.1346 от ширины)
	var center := Vector2(field.position.x + field_width * 0.5, center_y)
	var center_radius := field_width * 0.1346
	draw_arc(center, center_radius, 0.0, TAU, 64, line_color, line_width)
	draw_circle(center, 3.0, line_color)

	# 10. Штрафные площади (ширина 40.32м = 0.593 от ширины поля, глубина 16.5м = 0.157 от длины)
	var penalty_box_width := field_width * 0.593
	var penalty_box_height := field_height * 0.157
	var penalty_box_x := field.position.x + (field_width - penalty_box_width) * 0.5
	
	var top_penalty_box := Rect2(penalty_box_x, field.position.y, penalty_box_width, penalty_box_height)
	var bottom_penalty_box := Rect2(penalty_box_x, field.end.y - penalty_box_height, penalty_box_width, penalty_box_height)
	
	draw_rect(top_penalty_box, line_color, false, line_width)
	draw_rect(bottom_penalty_box, line_color, false, line_width)

	# 11. Вратарские площади (ширина 18.32м = 0.269 от ширины, глубина 5.5м = 0.052 от длины)
	var goal_box_width := field_width * 0.269
	var goal_box_height := field_height * 0.052
	var goal_box_x := field.position.x + (field_width - goal_box_width) * 0.5
	
	var top_goal_box := Rect2(goal_box_x, field.position.y, goal_box_width, goal_box_height)
	var bottom_goal_box := Rect2(goal_box_x, field.end.y - goal_box_height, goal_box_width, goal_box_height)
	
	draw_rect(top_goal_box, line_color, false, line_width)
	draw_rect(bottom_goal_box, line_color, false, line_width)

	# 12. Врата (визуальные)
	var goal_width := field_width * 0.108
	var goal_depth := field_height * 0.02
	var goal_x := field.position.x + (field_width - goal_width) * 0.5
	
	var top_goal := Rect2(goal_x, field.position.y - goal_depth, goal_width, goal_depth)
	var bottom_goal := Rect2(goal_x, field.end.y, goal_width, goal_depth)
	
	draw_rect(top_goal, Color(0.90, 0.95, 0.92, 0.40), true)
	draw_rect(bottom_goal, Color(0.90, 0.95, 0.92, 0.40), true)

	# 13. Точки пенальти (11м от линии ворот = 0.105 от длины поля)
	var penalty_spot_offset := field_height * 0.105
	var top_penalty_spot := Vector2(field.position.x + field_width * 0.5, field.position.y + penalty_spot_offset)
	var bottom_penalty_spot := Vector2(field.position.x + field_width * 0.5, field.end.y - penalty_spot_offset)
	
	draw_circle(top_penalty_spot, 3.0, line_color)
	draw_circle(bottom_penalty_spot, 3.0, line_color)

	# 14. Дуги штрафной (радиус 9.15м = 0.1346 от ширины)
	var penalty_arc_radius := field_width * 0.1346
	# Верхняя дуга (от точки пенальти, направлена к центру)
	draw_arc(top_penalty_spot, penalty_arc_radius, 0.0, PI, 40, line_color, thin_line_width)
	# Нижняя дуга (от точки пенальти, направлена к центру)
	draw_arc(bottom_penalty_spot, penalty_arc_radius, PI, TAU, 40, line_color, thin_line_width)

	# 15. Угловые дуги (радиус 1м = 0.0147 от ширины)
	var corner_radius := field_width * 0.0147
	# Верхний левый
	draw_arc(field.position, corner_radius, 0.0, PI * 0.5, 20, line_color, thin_line_width)
	# Верхний правый
	draw_arc(Vector2(field.end.x, field.position.y), corner_radius, PI * 0.5, PI, 20, line_color, thin_line_width)
	# Нижний левый
	draw_arc(Vector2(field.position.x, field.end.y), corner_radius, PI * 1.5, TAU, 20, line_color, thin_line_width)
	# Нижний правый
	draw_arc(field.end, corner_radius, PI, PI * 1.5, 20, line_color, thin_line_width)


# ============================================================
# ТЕНЬ ПОЛЯ
# ============================================================

func _create_field_shadow_style() -> StyleBoxFlat:

	var style := StyleBoxFlat.new()

	style.bg_color = Color(0, 0, 0, 0.38)

	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	return style

# ============================================================
# НОВЫЙ ДРАФТ
# ============================================================

func start_new_draft() -> void:

	if draft_in_progress:
		return

	draft_in_progress = true
	showing_saved_lineup = false
	selecting_position = false
	current_selected_slot = -1

	_clear_field_cards()
	_clear_position_buttons()

	if is_instance_valid(current_draft_screen):

		current_draft_screen.queue_free()

		current_draft_screen = null

	PlayerData.clear_draft()

	selected_formation.clear()
	formation_slots.clear()
	selected_slot_indices.clear()

	update_chemistry_ui()

	open_formation_selection()

# ============================================================
# ВЫБОР СХЕМЫ
# ============================================================

func open_formation_selection() -> void:

	if formation_select_scene == null:

		push_error(
			"PitchScreen: formation_select_scene не назначена."
		)

		draft_in_progress = false

		return

	var formation_screen := (
		formation_select_scene.instantiate()
	)

	add_child(
		formation_screen
	)

	if formation_screen.has_signal(
		"formation_selected"
	):

		formation_screen.formation_selected.connect(
			_on_formation_selected
		)

	else:

		push_error(
			"FormationSelectScreen не имеет сигнала formation_selected."
		)

# ============================================================
# СХЕМА ВЫБРАНА
# ============================================================

func _on_formation_selected(
	formation: Dictionary
) -> void:

	selected_formation = formation.duplicate(true)

	formation_slots.clear()
	selected_slot_indices.clear()

	for slot in selected_formation.get(
		"slots",
		[]
	):

		if slot is Dictionary:

			formation_slots.append(
				slot.duplicate(true)
			)

	for child in get_children():

		if child == current_draft_screen:
			continue

		if child.has_signal(
			"formation_selected"
		):

			child.queue_free()

	_create_position_buttons()

	selecting_position = true

	current_selected_slot = -1

	_update_chemistry_display(0)

	queue_redraw()

# ============================================================
# КНОПКИ ПОЗИЦИЙ
# ============================================================

func _create_position_buttons() -> void:

	_clear_position_buttons()

	for i in range(
		formation_slots.size()
	):

		var slot: Dictionary = (
			formation_slots[i]
		)

		var button := Button.new()

		button.text = str(
			slot.get(
				"position",
				"?"
			)
		)

		button.custom_minimum_size = Vector2(
			74,
			48
		)

		button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
		)

		button.focus_mode = Control.FOCUS_NONE

		button.add_theme_font_size_override(
			"font_size",
			12
		)

		_apply_position_button_style(
			button,
			false
		)

		var slot_index := i

		button.pressed.connect(
			func():
				_on_position_pressed(
					slot_index
				)
		)

		add_child(
			button
		)

		position_buttons.append(
			button
		)

	_reposition_position_buttons()

# ============================================================
# ПОЗИЦИЯ НАЖАТА
# ============================================================

func _on_position_pressed(
	slot_index: int
) -> void:

	if slot_index < 0:
		return

	if slot_index >= formation_slots.size():
		return

	if selected_slot_indices.has(
		slot_index
	):

		return

	current_selected_slot = slot_index

	for i in range(
		position_buttons.size()
	):

		if i == slot_index:

			_apply_position_button_style(
				position_buttons[i],
				true
			)

		else:

			_apply_position_button_style(
				position_buttons[i],
				false
			)

	open_player_choice_for_slot(
		slot_index
	)

# ============================================================
# ВЫБОР ИГРОКА ДЛЯ ПОЗИЦИИ
# ============================================================

func open_player_choice_for_slot(
	slot_index: int
) -> void:

	if draft_select_scene == null:

		push_error(
			"PitchScreen: draft_select_scene не назначена."
		)

		return

	if slot_index < 0:
		return

	if slot_index >= formation_slots.size():
		return

	var actual_position: String = str(
		formation_slots[slot_index].get(
			"position",
			""
		)
	)

	var database_position := (
		_convert_position_to_database_category(
			actual_position
		)
	)

	var choices: Array[PlayerCard] = (
		CardDatabase.generate_draft_choice(
			database_position
		)
	)

	if choices.is_empty():

		push_error(
			"CardDatabase не смогла предоставить игроков для позиции: "
			+ actual_position
			+ " / категория: "
			+ database_position
		)

		return

	_set_position_buttons_enabled(
		false
	)

	if is_instance_valid(current_draft_screen):

		current_draft_screen.queue_free()

		current_draft_screen = null

	current_draft_screen = (
		draft_select_scene.instantiate()
	)

	add_child(
		current_draft_screen
	)

	if current_draft_screen.has_signal(
		"player_selected_on_screen"
	):

		current_draft_screen.player_selected_on_screen.connect(
			_on_player_selected
		)

	else:

		push_error(
			"DraftSelectScreen не имеет сигнала player_selected_on_screen."
		)

	if current_draft_screen.has_method(
		"start_choice_for_position"
	):

		current_draft_screen.start_choice_for_position(
			actual_position,
			choices
		)

# ============================================================
# ПЕРЕВОД ПОЗИЦИИ В КАТЕГОРИЮ БАЗЫ
# ============================================================

func _convert_position_to_database_category(
	position: String
) -> String:

	var normalized := position.to_upper().strip_edges()

	match normalized:

		"GK":
			return "GK"

		"LB", "CB", "RB", "LWB", "RWB":
			return "DEF"

		"LM", "CM", "RM", "CDM", "CAM":
			return "MID"

		"LW", "ST", "RW", "CF":
			return "FWD"

		_:
			return normalized

# ============================================================
# ИГРОК ВЫБРАН
# ============================================================

func _on_player_selected(
	selected_card: Variant
) -> void:

	if is_instance_valid(
		current_draft_screen
	):

		current_draft_screen.queue_free()

		current_draft_screen = null

	if not selected_card is PlayerCard:

		push_error(
			"Получен объект неизвестного типа вместо PlayerCard."
		)

		_set_position_buttons_enabled(
			true
		)

		return

	var player_card: PlayerCard = selected_card

	if current_selected_slot < 0:

		push_error(
			"Игрок выбран, но текущая позиция не определена."
		)

		_set_position_buttons_enabled(
			true
		)

		return

	var selected_slot := current_selected_slot

	PlayerData.current_draft_team.append(
		player_card
	)

	selected_slot_indices.append(
		selected_slot
	)

	if card_ui_scene:

		var mini_card_node := (
			card_ui_scene.instantiate()
		)

		if mini_card_node:

			add_child(
				mini_card_node
			)

			field_card_nodes.append(
				mini_card_node
			)

			field_card_slot_indices.append(
				selected_slot
			)

			if mini_card_node.has_method(
				"set_compact_mode"
			):

				mini_card_node.set_compact_mode()

			if mini_card_node.has_method(
				"setup"
			):

				mini_card_node.setup(
					player_card
				)

			_position_card_node(
				mini_card_node,
				_get_formation_field_position(
					selected_slot
				)
			)

	_mark_position_as_filled(
		selected_slot
	)

	current_selected_slot = -1

	update_chemistry_ui()

	if selected_slot_indices.size() >= formation_slots.size():

		finish_draft()

	else:

		_set_position_buttons_enabled(
			true
		)

		selecting_position = true

# ============================================================
# ПОМЕТИТЬ ПОЗИЦИЮ КАК ЗАПОЛНЕННУЮ
# ============================================================

func _mark_position_as_filled(
	slot_index: int
) -> void:

	if slot_index < 0:
		return

	if slot_index >= position_buttons.size():
		return

	var button := position_buttons[
		slot_index
	]

	button.text = "✓ " + str(
		formation_slots[
			slot_index
		].get(
			"position",
			"?"
		)
	)

	button.disabled = true

	_apply_position_button_style(
		button,
		false,
		true
	)

# ============================================================
# АКТИВНОСТЬ КНОПОК ПОЗИЦИЙ
# ============================================================

func _set_position_buttons_enabled(
	enabled: bool
) -> void:

	for i in range(
		position_buttons.size()
	):

		var button := position_buttons[i]

		if not is_instance_valid(
			button
		):

			continue

		if selected_slot_indices.has(
			i
		):

			button.disabled = true

		else:

			button.disabled = not enabled

# ============================================================
# ПОЗИЦИЯ ИГРОКА НА ПОЛЕ
# ============================================================

func _get_formation_field_position(
	slot_index: int
) -> Vector2:

	if slot_index < 0:
		return field_rect.get_center()

	if slot_index >= formation_slots.size():
		return field_rect.get_center()

	var slot: Dictionary = (
		formation_slots[slot_index]
	)

	var x: float = float(
		slot.get(
			"x",
			0.5
		)
	)

	var y: float = float(
		slot.get(
			"y",
			0.5
		)
	)

	return Vector2(
		field_rect.position.x
		+ field_rect.size.x * x,
		field_rect.position.y
		+ field_rect.size.y * y
	)

# ============================================================
# ПОЗИЦИЯ КНОПКИ НА ПОЛЕ
# ============================================================

func _get_position_button_position(
	slot_index: int
) -> Vector2:

	var center := (
		_get_formation_field_position(
			slot_index
		)
	)

	var button_size := Vector2(
		74,
		48
	)

	return center - button_size * 0.5

# ============================================================
# РАЗМЕЩЕНИЕ КНОПОК
# ============================================================

func _reposition_position_buttons() -> void:

	if position_buttons.is_empty():
		return

	for i in range(
		position_buttons.size()
	):

		var button := position_buttons[i]

		if not is_instance_valid(
			button
		):

			continue

		button.position = (
			_get_position_button_position(
				i
			)
		)

# ============================================================
# СТИЛЬ КНОПКИ ПОЗИЦИИ
# ============================================================

func _apply_position_button_style(
	button: Button,
	selected: bool,
	filled: bool = false
) -> void:

	var normal := StyleBoxFlat.new()

	if filled:

		normal.bg_color = Color(
			0.10,
			0.48,
			0.25,
			0.92
		)

	elif selected:

		normal.bg_color = Color(
			1.0,
			0.70,
			0.18,
			0.95
		)

	else:

		normal.bg_color = Color(
			0.025,
			0.055,
			0.085,
			0.94
		)

	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14

	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2

	if filled:

		normal.border_color = Color(
			0.45,
			1.0,
			0.60,
			0.70
		)

	elif selected:

		normal.border_color = Color(
			1.0,
			0.90,
			0.40,
			1.0
		)

	else:

		normal.border_color = Color(
			1,
			1,
			1,
			0.25
		)

	button.add_theme_stylebox_override(
		"normal",
		normal
	)

	var hover := normal.duplicate()

	if not filled:

		hover.bg_color = Color(
			0.12,
			0.18,
			0.23,
			1.0
		)

	button.add_theme_stylebox_override(
		"hover",
		hover
	)

	var pressed := normal.duplicate()

	if not filled:

		pressed.bg_color = Color(
			0.15,
			0.22,
			0.28,
			1.0
		)

	button.add_theme_stylebox_override(
		"pressed",
		pressed
	)

	button.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.95
		)
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color(
			1,
			0.90,
			0.45
		)
	)

# ============================================================
# КАРТОЧКА ИГРОКА
# ============================================================

func _create_field_card(
	card: PlayerCard,
	field_position: Vector2
) -> void:

	if card_ui_scene == null:
		return

	var mini_card_node := (
		card_ui_scene.instantiate()
	)

	if mini_card_node == null:
		return

	add_child(
		mini_card_node
	)

	field_card_nodes.append(
		mini_card_node
	)

	if mini_card_node.has_method(
		"set_compact_mode"
	):

		mini_card_node.set_compact_mode()

	if mini_card_node.has_method(
		"setup"
	):

		mini_card_node.setup(
			card
		)

	_position_card_node(
		mini_card_node,
		field_position
	)

# ============================================================
# ПОЗИЦИОНИРОВАНИЕ КАРТОЧКИ
# ============================================================

func _position_card_node(
	card_node: Node,
	field_position: Vector2
) -> void:

	if not card_node is Control:
		return

	var control := card_node as Control

	var target_width: float = min(
		field_rect.size.x * 0.19,
		125.0
	)

	var scale_factor: float = (
		target_width / 180.0
	)

	control.scale = Vector2(
		scale_factor,
		scale_factor
	)

	control.position = (
		field_position
		- Vector2(
			90.0 * scale_factor,
			130.0 * scale_factor
		)
	)

# ============================================================
# ПЕРЕПОЗИЦИОНИРОВАНИЕ КАРТОЧЕК
# ============================================================

func _reposition_field_cards() -> void:

	if field_card_nodes.is_empty():
		return

	for i in range(
		field_card_nodes.size()
	):

		var node := field_card_nodes[i]

		if not is_instance_valid(
			node
		):

			continue

		if i >= field_card_slot_indices.size():
			continue

		var slot_index := (
			field_card_slot_indices[i]
		)

		_position_card_node(
			node,
			_get_formation_field_position(
				slot_index
			)
		)

# ============================================================
# ОЧИСТКА КАРТОЧЕК
# ============================================================

func _clear_field_cards() -> void:

	for node in field_card_nodes:

		if is_instance_valid(
			node
		):

			node.queue_free()

	field_card_nodes.clear()
	field_card_slot_indices.clear()

# ============================================================
# ОЧИСТКА КНОПОК ПОЗИЦИЙ
# ============================================================

func _clear_position_buttons() -> void:

	for button in position_buttons:

		if is_instance_valid(
			button
		):

			button.queue_free()

	position_buttons.clear()

# ============================================================
# СОХРАНЁННЫЙ СОСТАВ
# ============================================================

func show_saved_lineup() -> void:

	showing_saved_lineup = true
	draft_in_progress = false
	selecting_position = false

	_clear_field_cards()
	_clear_position_buttons()

	_update_chemistry_from_lineup()

	_create_draft_button()

	var lineup: Array[PlayerCard] = (
		ClubManager.get_starting_lineup()
	)

	if lineup.is_empty():
		return

	formation_slots.clear()

	var default_slots: Array[Dictionary] = [

		{"position": "GK", "x": 0.50, "y": 0.90},

		{"position": "DEF", "x": 0.18, "y": 0.72},
		{"position": "DEF", "x": 0.39, "y": 0.76},
		{"position": "DEF", "x": 0.61, "y": 0.76},
		{"position": "DEF", "x": 0.82, "y": 0.72},

		{"position": "MID", "x": 0.22, "y": 0.53},
		{"position": "MID", "x": 0.50, "y": 0.48},
		{"position": "MID", "x": 0.78, "y": 0.53},

		{"position": "FWD", "x": 0.22, "y": 0.27},
		{"position": "FWD", "x": 0.50, "y": 0.22},
		{"position": "FWD", "x": 0.78, "y": 0.27}
	]

	for slot in default_slots:

		formation_slots.append(
			slot
		)

	selected_slot_indices.clear()

	for i in range(
		min(
			lineup.size(),
			formation_slots.size()
		)
	):

		var card: PlayerCard = lineup[i]

		selected_slot_indices.append(
			i
		)

		_create_field_card(
			card,
			_get_formation_field_position(i)
		)

# ============================================================
# СЫГРАННОСТЬ СОХРАНЁННОГО СОСТАВА
# ============================================================

func _update_chemistry_from_lineup() -> void:

	if not is_instance_valid(
		ClubManager
	):

		return

	var lineup: Array[PlayerCard] = (
		ClubManager.get_starting_lineup()
	)

	var total_chem: int = 0

	if lineup.size() > 0:

		total_chem = (
			ChemistryManager.calculate_team_chemistry(
				lineup
			)
		)

	_update_chemistry_display(
		total_chem
	)

# ============================================================
# СЫГРАННОСТЬ
# ============================================================

func update_chemistry_ui() -> void:

	var total_chem: int = (
		ChemistryManager.calculate_team_chemistry(
			PlayerData.current_draft_team
		)
	)

	_update_chemistry_display(
		total_chem
	)

# ============================================================
# UI СЫГРАННОСТИ
# ============================================================

func _update_chemistry_display(
	value: int
) -> void:

	if chem_label:

		chem_label.text = (
			"  Сыгранность  "
			+ str(value)
			+ " / 33"
		)

	if chemistry_progress:

		chemistry_progress.value = value

# ============================================================
# КНОПКА НОВОГО ДРАФТА
# ============================================================

func _create_draft_button() -> void:

	if is_instance_valid(
		draft_button
	):

		draft_button.queue_free()

	draft_button = Button.new()

	draft_button.text = "⚡  НОВЫЙ ДРАФТ"

	draft_button.custom_minimum_size = Vector2(
		180,
		46
	)

	draft_button.position = Vector2(
		18,
		76
	)

	draft_button.add_theme_font_size_override(
		"font_size",
		14
	)

	draft_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	draft_button.pressed.connect(
		start_new_draft
	)

	_apply_button_style(
		draft_button,
		Color(
			0.10,
			0.52,
			0.26
		)
	)

	top_layer.add_child(
		draft_button
	)

# ============================================================
# ЗАВЕРШЕНИЕ ДРАФТА
# ============================================================

func finish_draft() -> void:

	draft_in_progress = false
	selecting_position = false

	_clear_position_buttons()

	var match_scene := load(
		"res://MatchScreen.tscn"
	) as PackedScene

	if match_scene == null:

		push_error(
			"Не удалось загрузить res://MatchScreen.tscn"
		)

		if summary_screen_scene:

			var summary := (
				summary_screen_scene.instantiate()
			)

			add_child(
				summary
			)

		return

	var match_screen := (
		match_scene.instantiate()
	)

	add_child(
		match_screen
	)

	if match_screen.has_method(
		"setup"
	):

		match_screen.setup(
			PlayerData.current_draft_team
		)

# ============================================================
# МАГАЗИН
# ============================================================

func _on_store_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://StoreScreen.tscn"
	)

# ============================================================
# МОЙ КЛУБ
# ============================================================

func _on_club_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://ClubScreen.tscn"
	)

# ============================================================
# СТИЛЬ ОБЫЧНОЙ КНОПКИ
# ============================================================

func _apply_button_style(
	button: Button,
	background_color: Color
) -> void:

	var normal := StyleBoxFlat.new()

	normal.bg_color = background_color

	normal.corner_radius_top_left = 11
	normal.corner_radius_top_right = 11
	normal.corner_radius_bottom_left = 11
	normal.corner_radius_bottom_right = 11

	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1

	normal.border_color = Color(
		1,
		1,
		1,
		0.08
	)

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

	var focus := normal.duplicate()

	focus.border_width_left = 2
	focus.border_width_right = 2
	focus.border_width_top = 2
	focus.border_width_bottom = 2

	focus.border_color = Color(
		1,
		1,
		1,
		0.20
	)

	button.add_theme_stylebox_override(
		"focus",
		focus
	)
