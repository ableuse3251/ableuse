class_name UIStyleUtils
extends RefCounted

static func apply_button_style(button: Button, background_color: Color) -> void:

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
	normal.border_color = Color(1, 1, 1, 0.08)
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(
		min(background_color.r + 0.06, 1.0),
		min(background_color.g + 0.06, 1.0),
		min(background_color.b + 0.06, 1.0)
	)
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(
		max(background_color.r - 0.04, 0.0),
		max(background_color.g - 0.04, 0.0),
		max(background_color.b - 0.04, 0.0)
	)
	button.add_theme_stylebox_override("pressed", pressed)

	var focus := normal.duplicate()
	focus.border_width_left = 2
	focus.border_width_right = 2
	focus.border_width_top = 2
	focus.border_width_bottom = 2
	focus.border_color = Color(1, 1, 1, 0.20)
	button.add_theme_stylebox_override("focus", focus)
