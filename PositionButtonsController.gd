class_name PositionButtonsController
extends RefCounted

# ============================================================
# КНОПКИ ПОЗИЦИЙ НА ПОЛЕ (КОМПОНЕНТ PITCHSCREEN)
# ============================================================
# Создание кнопок по слотам схемы, стилизация, выделение,
# активность, позиционирование и очистка. Состояние массива
# кнопок живёт здесь; общее состояние драфта — в PitchScreen.
# ============================================================

const GameColors := preload("res://GameColors.gd")

var screen: PitchScreen

var position_buttons: Array[Button] = []


func create_buttons() -> void:

	clear()

	for i in range(screen.formation_slots.size()):
		var slot: Dictionary = screen.formation_slots[i]
		var button := Button.new()
		button.text = str(slot.get("position", "?"))
		button.custom_minimum_size = Vector2(74, 48)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 12)
		apply_style(button, false)

		var slot_index := i
		button.pressed.connect(func(): on_position_pressed(slot_index))

		screen.add_child(button)
		position_buttons.append(button)

	reposition()


func on_position_pressed(slot_index: int) -> void:

	if slot_index < 0 or slot_index >= screen.formation_slots.size():
		return

	if screen.selected_slot_indices.has(slot_index):
		return

	screen.current_selected_slot = slot_index

	for i in range(position_buttons.size()):
		if i == slot_index:
			apply_style(position_buttons[i], true)
		else:
			apply_style(position_buttons[i], false)

	screen.draft_flow.open_player_choice_for_slot(slot_index)


func mark_filled(slot_index: int) -> void:

	if slot_index < 0 or slot_index >= position_buttons.size():
		return

	var button := position_buttons[slot_index]
	button.visible = false


func set_enabled(enabled: bool) -> void:

	for i in range(position_buttons.size()):
		var button := position_buttons[i]
		if not is_instance_valid(button):
			continue
		if screen.selected_slot_indices.has(i):
			button.disabled = true
		else:
			button.disabled = not enabled


func clear() -> void:

	for button in position_buttons:
		if is_instance_valid(button):
			button.queue_free()
	position_buttons.clear()


func reposition() -> void:

	if position_buttons.is_empty():
		return

	for i in range(position_buttons.size()):
		var button := position_buttons[i]
		if not is_instance_valid(button):
			continue
		button.position = get_position_button_position(i)


func get_position_button_position(slot_index: int) -> Vector2:

	var center := screen.field_renderer.get_formation_field_position(slot_index)
	var button_size := Vector2(74, 48)
	return center - button_size * 0.5


func apply_style(button: Button, selected: bool, filled: bool = false) -> void:

	var normal := StyleBoxFlat.new()

	if filled:
		normal.bg_color = GameColors.BTN_POSITION_FILLED
	elif selected:
		normal.bg_color = GameColors.BTN_POSITION_ACTIVE
	else:
		normal.bg_color = GameColors.BTN_POSITION

	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2

	if filled:
		normal.border_color = GameColors.BTN_POSITION_FILLED_BORDER
	elif selected:
		normal.border_color = GameColors.BTN_POSITION_ACTIVE_BORDER
	else:
		normal.border_color = GameColors.BORDER_MEDIUM

	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	if not filled:
		hover.bg_color = GameColors.BTN_POSITION_HOVER
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	if not filled:
		pressed.bg_color = GameColors.BTN_POSITION_PRESSED
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override("font_color", GameColors.TEXT_BRIGHT)
	button.add_theme_color_override("font_hover_color", GameColors.ACCENT_GOLD_LIGHT)