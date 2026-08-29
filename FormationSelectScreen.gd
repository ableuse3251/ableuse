class_name FormationSelectScreen
extends Control


signal formation_selected(formation_data: Dictionary)


# ============================================================
# СХЕМЫ
# ============================================================

const FORMATIONS: Array[Dictionary] = [
	{
		"id": "4-3-3",
		"name": "4-3-3",
		"description": "Атакующая классика",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "LB", "x": 0.15, "y": 0.72},
			{"position": "CB", "x": 0.38, "y": 0.76},
			{"position": "CB", "x": 0.62, "y": 0.76},
			{"position": "RB", "x": 0.85, "y": 0.72},
			{"position": "CM", "x": 0.23, "y": 0.53},
			{"position": "CM", "x": 0.50, "y": 0.49},
			{"position": "CM", "x": 0.77, "y": 0.53},
			{"position": "LW", "x": 0.22, "y": 0.27},
			{"position": "ST", "x": 0.50, "y": 0.21},
			{"position": "RW", "x": 0.78, "y": 0.27}
		]
	},
	{
		"id": "4-2-3-1",
		"name": "4-2-3-1",
		"description": "Контроль центра",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "LB", "x": 0.15, "y": 0.72},
			{"position": "CB", "x": 0.38, "y": 0.76},
			{"position": "CB", "x": 0.62, "y": 0.76},
			{"position": "RB", "x": 0.85, "y": 0.72},
			{"position": "CDM", "x": 0.38, "y": 0.58},
			{"position": "CDM", "x": 0.62, "y": 0.58},
			{"position": "LW", "x": 0.20, "y": 0.39},
			{"position": "CAM", "x": 0.50, "y": 0.38},
			{"position": "RW", "x": 0.80, "y": 0.39},
			{"position": "ST", "x": 0.50, "y": 0.20}
		]
	},
	{
		"id": "4-4-2",
		"name": "4-4-2",
		"description": "Баланс",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "LB", "x": 0.15, "y": 0.72},
			{"position": "CB", "x": 0.38, "y": 0.76},
			{"position": "CB", "x": 0.62, "y": 0.76},
			{"position": "RB", "x": 0.85, "y": 0.72},
			{"position": "LM", "x": 0.15, "y": 0.51},
			{"position": "CM", "x": 0.38, "y": 0.53},
			{"position": "CM", "x": 0.62, "y": 0.53},
			{"position": "RM", "x": 0.85, "y": 0.51},
			{"position": "ST", "x": 0.39, "y": 0.25},
			{"position": "ST", "x": 0.61, "y": 0.25}
		]
	},
	{
		"id": "4-3-2-1",
		"name": "4-3-2-1",
		"description": "Вузькая атака",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "LB", "x": 0.15, "y": 0.72},
			{"position": "CB", "x": 0.38, "y": 0.76},
			{"position": "CB", "x": 0.62, "y": 0.76},
			{"position": "RB", "x": 0.85, "y": 0.72},
			{"position": "CM", "x": 0.25, "y": 0.53},
			{"position": "CM", "x": 0.50, "y": 0.50},
			{"position": "CM", "x": 0.75, "y": 0.53},
			{"position": "CAM", "x": 0.38, "y": 0.32},
			{"position": "CAM", "x": 0.62, "y": 0.32},
			{"position": "ST", "x": 0.50, "y": 0.19}
		]
	},
	{
		"id": "3-5-2",
		"name": "3-5-2",
		"description": "Перегруз центра",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "CB", "x": 0.25, "y": 0.74},
			{"position": "CB", "x": 0.50, "y": 0.78},
			{"position": "CB", "x": 0.75, "y": 0.74},
			{"position": "LM", "x": 0.10, "y": 0.52},
			{"position": "CM", "x": 0.30, "y": 0.55},
			{"position": "CAM", "x": 0.50, "y": 0.48},
			{"position": "CM", "x": 0.70, "y": 0.55},
			{"position": "RM", "x": 0.90, "y": 0.52},
			{"position": "ST", "x": 0.38, "y": 0.24},
			{"position": "ST", "x": 0.62, "y": 0.24}
		]
	},
	{
		"id": "3-4-3",
		"name": "3-4-3",
		"description": "Максимальная атака",
		"slots": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "CB", "x": 0.25, "y": 0.75},
			{"position": "CB", "x": 0.50, "y": 0.78},
			{"position": "CB", "x": 0.75, "y": 0.75},
			{"position": "LM", "x": 0.18, "y": 0.53},
			{"position": "CM", "x": 0.39, "y": 0.55},
			{"position": "CM", "x": 0.61, "y": 0.55},
			{"position": "RM", "x": 0.82, "y": 0.53},
			{"position": "LW", "x": 0.22, "y": 0.27},
			{"position": "ST", "x": 0.50, "y": 0.20},
			{"position": "RW", "x": 0.78, "y": 0.27}
		]
	}
]


# ============================================================
# UI
# ============================================================

var scroll: ScrollContainer
var grid: GridContainer


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_build_ui()


# ============================================================
# UI
# ============================================================

func _build_ui() -> void:

	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.025, 0.045, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var main := VBoxContainer.new()
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	main.add_theme_constant_override("separation", 10)
	main.alignment = BoxContainer.ALIGNMENT_CENTER

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 24)

	add_child(margin)
	margin.add_child(main)

	var top_label := Label.new()
	top_label.text = "DRAFT"
	top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_label.add_theme_font_size_override("font_size", 12)
	top_label.add_theme_color_override(
		"font_color",
		Color(0.45, 0.65, 0.95, 0.85)
	)
	main.add_child(top_label)

	var title := Label.new()
	title.text = "ВЫБЕРИТЕ СХЕМУ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override(
		"font_color",
		Color(1.0, 0.88, 0.38)
	)
	main.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Выберите тактическую схему для своего драфта"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override(
		"font_color",
		Color(1, 1, 1, 0.55)
	)
	main.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	main.add_child(spacer)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)

	scroll.add_child(grid)

	for formation in FORMATIONS:
		_create_formation_card(formation)


# ============================================================
# КАРТОЧКА СХЕМЫ
# ============================================================

func _create_formation_card(
	formation: Dictionary
) -> void:

	var button := Button.new()

	button.custom_minimum_size = Vector2(250, 260)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.065, 0.105, 0.96)

	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18

	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1

	style.border_color = Color(1, 1, 1, 0.08)

	button.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(0.07, 0.105, 0.16, 1.0)
	hover.border_color = Color(1, 0.88, 0.38, 0.35)

	button.add_theme_stylebox_override("hover", hover)

	var pressed := style.duplicate()
	pressed.bg_color = Color(0.10, 0.14, 0.20, 1.0)

	button.add_theme_stylebox_override("pressed", pressed)

	button.pressed.connect(
		func():
			_on_formation_selected(formation)
	)

	grid.add_child(button)

	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	content.add_theme_constant_override("separation", 5)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE

	button.add_child(content)

	var name_label := Label.new()
	name_label.text = formation["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 23)
	name_label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.88, 0.38)
	)
	content.add_child(name_label)

	var description := Label.new()
	description.text = formation["description"]
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 11)
	description.add_theme_color_override(
		"font_color",
		Color(1, 1, 1, 0.45)
	)
	content.add_child(description)

	var pitch := Control.new()
	pitch.custom_minimum_size = Vector2(220, 185)
	pitch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(pitch)

	_draw_mini_pitch(pitch, formation)


# ============================================================
# МИНИ-ПОЛЕ
# ============================================================

func _draw_mini_pitch(
	pitch: Control,
	formation: Dictionary
) -> void:

	var field := ColorRect.new()

	field.position = Vector2(20, 4)
	field.size = Vector2(180, 165)
	field.color = Color(0.045, 0.28, 0.12, 1.0)

	field.mouse_filter = Control.MOUSE_FILTER_IGNORE

	pitch.add_child(field)

	var line := ColorRect.new()
	line.position = Vector2(20, 82)
	line.size = Vector2(180, 1)
	line.color = Color(1, 1, 1, 0.25)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pitch.add_child(line)

	var center := ColorRect.new()
	center.position = Vector2(109, 81)
	center.size = Vector2(2, 2)
	center.color = Color(1, 1, 1, 0.5)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pitch.add_child(center)

	for slot in formation["slots"]:

		var marker := Label.new()

		marker.text = slot["position"]
		marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		marker.position = Vector2(
			20 + float(slot["x"]) * 180.0 - 18,
			4 + float(slot["y"]) * 165.0 - 9
		)

		marker.size = Vector2(36, 18)

		marker.add_theme_font_size_override("font_size", 8)
		marker.add_theme_color_override(
			"font_color",
			Color(1, 1, 1, 0.9)
		)

		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE

		pitch.add_child(marker)


# ============================================================
# ВЫБОР СХЕМЫ
# ============================================================

func _on_formation_selected(
	formation: Dictionary
) -> void:

	formation_selected.emit(formation)
