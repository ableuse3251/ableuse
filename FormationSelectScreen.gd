class_name FormationSelectScreen
extends Control

signal formation_selected(formation: Dictionary)

const FORMATIONS_TO_SHOW: int = 4
const CARD_HEIGHT: float = 360.0
const CARD_MARGIN: float = 16.0
const PREVIEW_HEIGHT: float = 200.0

var available_formations: Array[Dictionary] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_select_random_formations()
	_create_ui()

func _select_random_formations() -> void:
	available_formations.clear()
	
	var all_formations_dict: Dictionary = FormationManager.get_all_formations()
	if all_formations_dict.is_empty():
		push_error("FormationSelectScreen: нет доступных схем!")
		return
	
	var all_list: Array[Dictionary] = []
	for key in all_formations_dict.keys():
		var slots: Array = all_formations_dict[key] # Явное указание типа
		all_list.append({"name": key, "slots": slots})
	
	all_list.shuffle()
	var count: int = min(FORMATIONS_TO_SHOW, all_list.size())
	for i in range(count):
		available_formations.append(all_list[i])

func _create_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.02, 0.03, 0.05, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var top_glow := ColorRect.new()
	top_glow.color = Color(0.1, 0.3, 0.5, 0.15)
	top_glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_glow.offset_bottom = 200.0
	add_child(top_glow)

	var top_bar := HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 70)
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 70.0
	top_bar.add_theme_constant_override("separation", 15)
	add_child(top_bar)

	var back_button := Button.new()
	back_button.text = "← Домой"
	back_button.custom_minimum_size = Vector2(100, 45)
	back_button.add_theme_font_size_override("font_size", 16)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_back_pressed)
	_apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	top_bar.add_child(back_button)

	var title_label := Label.new()
	title_label.text = "ВЫБОР СХЕМЫ"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	top_bar.add_child(title_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(100, 45)
	top_bar.add_child(spacer)

	var subtitle_label := Label.new()
	subtitle_label.text = "4 случайные схемы из " + str(FormationManager.get_all_formations().size()) + " доступных"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.8))
	subtitle_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle_label.offset_top = 75.0
	subtitle_label.offset_bottom = 100.0
	add_child(subtitle_label)

	var scroll_container := ScrollContainer.new()
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll_container.offset_top = 105.0
	scroll_container.offset_bottom = -20.0
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll_container)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", CARD_MARGIN)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(vbox)

	for formation in available_formations:
		var card := _create_formation_card(formation)
		vbox.add_child(card)

func _create_formation_card(formation: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, CARD_HEIGHT)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

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

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(header)

	var accent_bar := ColorRect.new()
	accent_bar.color = Color(0.2, 0.6, 1.0, 0.8)
	accent_bar.custom_minimum_size = Vector2(4, 28)
	header.add_child(accent_bar)

	var name_label := Label.new()
	name_label.text = formation["name"]
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 0.95))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)

	var player_count_label := Label.new()
	player_count_label.text = str(formation["slots"].size()) + " игроков"
	player_count_label.add_theme_font_size_override("font_size", 14)
	player_count_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 0.7))
	player_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(player_count_label)

	var preview_wrapper := Control.new()
	preview_wrapper.custom_minimum_size = Vector2(0, PREVIEW_HEIGHT)
	preview_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(preview_wrapper)

	var preview := Control.new()
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_wrapper.add_child(preview)

	preview.connect("draw", func():
		var preview_size: Vector2 = preview.size
		if preview_size.x < 10 or preview_size.y < 10:
			return

		var field_aspect: float = 1.544
		var field_width: float = preview_size.x * 0.9
		var field_height: float = field_width / field_aspect
		if field_height > preview_size.y * 0.95:
			field_height = preview_size.y * 0.95
			field_width = field_height * field_aspect

		var field_x: float = (preview_size.x - field_width) * 0.5
		var field_y: float = (preview_size.y - field_height) * 0.5
		var field_rect := Rect2(field_x, field_y, field_width, field_height)

		preview.draw_rect(field_rect, Color(0.04, 0.22, 0.10, 1.0), true)

		var stripe_count := 8
		var stripe_height: float = field_rect.size.y / float(stripe_count)
		for i in range(stripe_count):
			var stripe_color := Color(0.05, 0.25, 0.11, 1.0) if i % 2 == 0 else Color(0.035, 0.20, 0.09, 1.0)
			preview.draw_rect(
				Rect2(field_rect.position.x, field_rect.position.y + stripe_height * i, field_rect.size.x, stripe_height + 1.0),
				stripe_color,
				true
			)

		var line_color := Color(0.95, 0.98, 1.0, 0.75)
		preview.draw_rect(field_rect, line_color, false, 1.5)
		preview.draw_line(
			Vector2(field_rect.position.x, field_rect.position.y + field_rect.size.y * 0.5),
			Vector2(field_rect.end.x, field_rect.position.y + field_rect.size.y * 0.5),
			line_color, 1.5
		)

		var center := Vector2(field_rect.get_center().x, field_rect.position.y + field_rect.size.y * 0.5)
		var center_radius: float = min(field_rect.size.x, field_rect.size.y) * 0.12
		preview.draw_arc(center, center_radius, 0.0, TAU, 48, line_color, 1.5)

		var slots_array: Array = formation["slots"]
		for i in range(slots_array.size()):
			var slot: Dictionary = slots_array[i]
			var x: float = float(slot.get("x", 0.5))
			var y: float = float(slot.get("y", 0.5))
			var px: float = field_rect.position.x + x * field_rect.size.x
			var py: float = field_rect.position.y + y * field_rect.size.y
			preview.draw_circle(Vector2(px, py), 10.0, Color(1.0, 0.85, 0.3, 0.35))
			preview.draw_circle(Vector2(px, py), 6.0, Color(1.0, 0.85, 0.3, 0.95))
	)

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

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _apply_button_style(button: Button, background_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = background_color
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(background_color.r + 0.06, 1.0), min(background_color.g + 0.06, 1.0), min(background_color.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(background_color.r - 0.04, 0.0), max(background_color.g - 0.04, 0.0), max(background_color.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)
