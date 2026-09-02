extends Control

# ============================================================
# ЭКРАН НАСТРОЕК
# Громкость, повтор онбординга, сброс прогресса.
# ============================================================

var volume_slider: HSlider
var volume_value_label: Label
var reset_button: Button
var back_button: Button

var user_profile: Node

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	user_profile = get_node("/root/UserProfile")

	_build_ui()
	_update_volume_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.08, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 560)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.075, 0.11, 0.98)
	panel_style.corner_radius_top_left = 26
	panel_style.corner_radius_top_right = 26
	panel_style.corner_radius_bottom_left = 26
	panel_style.corner_radius_bottom_right = 26
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.78, 0.22, 0.45)
	panel_style.shadow_color = Color(0, 0, 0, 0.7)
	panel_style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 25)
	margin.add_theme_constant_override("margin_bottom", 25)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var title := Label.new()
	title.text = "⚙️ НАСТРОЙКИ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Настрой свой клуб под себя"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	box.add_child(subtitle)

	# ============================================================
	# ЗВУК
	# ============================================================
	var volume_panel := PanelContainer.new()
	var volume_style := StyleBoxFlat.new()
	volume_style.bg_color = Color(0.08, 0.11, 0.16, 1.0)
	volume_style.corner_radius_top_left = 16
	volume_style.corner_radius_top_right = 16
	volume_style.corner_radius_bottom_left = 16
	volume_style.corner_radius_bottom_right = 16
	volume_panel.add_theme_stylebox_override("panel", volume_style)
	box.add_child(volume_panel)

	var volume_margin := MarginContainer.new()
	volume_margin.add_theme_constant_override("margin_left", 18)
	volume_margin.add_theme_constant_override("margin_right", 18)
	volume_margin.add_theme_constant_override("margin_top", 14)
	volume_margin.add_theme_constant_override("margin_bottom", 14)
	volume_panel.add_child(volume_margin)

	var volume_box := VBoxContainer.new()
	volume_box.add_theme_constant_override("separation", 8)
	volume_margin.add_child(volume_box)

	var volume_header := HBoxContainer.new()
	volume_header.add_theme_constant_override("separation", 10)
	volume_box.add_child(volume_header)

	var volume_title := Label.new()
	volume_title.text = "🔊 Громкость"
	volume_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_title.add_theme_font_size_override("font_size", 16)
	volume_title.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	volume_header.add_child(volume_title)

	volume_value_label = Label.new()
	volume_value_label.add_theme_font_size_override("font_size", 14)
	volume_value_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	volume_header.add_child(volume_value_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value = SaveManager.get_master_volume()
	volume_slider.custom_minimum_size = Vector2(0, 30)
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_box.add_child(volume_slider)

	var volume_hint := Label.new()
	volume_hint.text = "0% — выключить звук, 100% — максимум"
	volume_hint.add_theme_font_size_override("font_size", 11)
	volume_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	volume_box.add_child(volume_hint)

	# ============================================================
	# ОБУЧЕНИЕ
	# ============================================================
	var tutorial_btn := Button.new()
	tutorial_btn.text = "📖 Повторить обучение"
	tutorial_btn.custom_minimum_size = Vector2(0, 48)
	tutorial_btn.add_theme_font_size_override("font_size", 15)
	tutorial_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tutorial_btn.pressed.connect(_on_tutorial_pressed)
	_apply_button_style(tutorial_btn, Color(0.20, 0.28, 0.45))
	box.add_child(tutorial_btn)

	var tutorial_hint := Label.new()
	tutorial_hint.text = "Покажет учебник заново"
	tutorial_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_hint.add_theme_font_size_override("font_size", 11)
	tutorial_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	box.add_child(tutorial_hint)

	# ============================================================
	# СБРОС ПРОГРЕССА
	# ============================================================
	var reset_panel := PanelContainer.new()
	var reset_style := StyleBoxFlat.new()
	reset_style.bg_color = Color(0.16, 0.06, 0.06, 1.0)
	reset_style.corner_radius_top_left = 16
	reset_style.corner_radius_top_right = 16
	reset_style.corner_radius_bottom_left = 16
	reset_style.corner_radius_bottom_right = 16
	reset_style.border_width_left = 1
	reset_style.border_width_right = 1
	reset_style.border_width_top = 1
	reset_style.border_width_bottom = 1
	reset_style.border_color = Color(1.0, 0.3, 0.3, 0.35)
	reset_panel.add_theme_stylebox_override("panel", reset_style)
	box.add_child(reset_panel)

	var reset_margin := MarginContainer.new()
	reset_margin.add_theme_constant_override("margin_left", 18)
	reset_margin.add_theme_constant_override("margin_right", 18)
	reset_margin.add_theme_constant_override("margin_top", 14)
	reset_margin.add_theme_constant_override("margin_bottom", 14)
	reset_panel.add_child(reset_margin)

	var reset_box := VBoxContainer.new()
	reset_box.add_theme_constant_override("separation", 8)
	reset_margin.add_child(reset_box)

	var reset_title := Label.new()
	reset_title.text = "⚠️ ОПАСНАЯ ЗОНА"
	reset_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reset_title.add_theme_font_size_override("font_size", 15)
	reset_title.add_theme_color_override("font_color", Color(1.0, 0.55, 0.55))
	reset_box.add_child(reset_title)

	reset_button = Button.new()
	reset_button.text = "🗑️ СБРОСИТЬ ВЕСЬ ПРОГРЕСС"
	reset_button.custom_minimum_size = Vector2(0, 48)
	reset_button.add_theme_font_size_override("font_size", 15)
	reset_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_button.pressed.connect(_on_reset_pressed)
	_apply_button_style(reset_button, Color(0.55, 0.12, 0.12))
	reset_box.add_child(reset_button)

	var reset_hint := Label.new()
	reset_hint.text = "Клуб, состав, монеты — всё будет удалено"
	reset_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reset_hint.add_theme_font_size_override("font_size", 11)
	reset_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	reset_box.add_child(reset_hint)

	# ============================================================
	# НАЗАД
	# ============================================================
	back_button = Button.new()
	back_button.text = "← Домой"
	back_button.custom_minimum_size = Vector2(0, 44)
	back_button.add_theme_font_size_override("font_size", 15)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_back_pressed)
	_apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	box.add_child(back_button)

func _update_volume_ui() -> void:
	if volume_slider != null and volume_value_label != null:
		var volume: int = int(round(volume_slider.value * 100.0))
		volume_value_label.text = str(volume) + "%"

func _on_volume_changed(value: float) -> void:
	SaveManager.set_master_volume(value)
	var bus_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value <= 0.001)
	_update_volume_ui()

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://OnboardingScreen.tscn")

func _on_reset_pressed() -> void:
	_show_reset_confirmation()

func _show_reset_confirmation() -> void:
	# Затемняющая подложка.
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.name = "ResetOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var dialog := PanelContainer.new()
	dialog.custom_minimum_size = Vector2(380, 280)
	var dialog_style := StyleBoxFlat.new()
	dialog_style.bg_color = Color(0.07, 0.09, 0.13, 1.0)
	dialog_style.corner_radius_top_left = 20
	dialog_style.corner_radius_top_right = 20
	dialog_style.corner_radius_bottom_left = 20
	dialog_style.corner_radius_bottom_right = 20
	dialog_style.border_width_left = 2
	dialog_style.border_width_right = 2
	dialog_style.border_width_top = 2
	dialog_style.border_width_bottom = 2
	dialog_style.border_color = Color(1.0, 0.3, 0.3, 0.5)
	dialog.add_theme_stylebox_override("panel", dialog_style)
	center.add_child(dialog)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	dialog.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var warn_icon := Label.new()
	warn_icon.text = "⚠️"
	warn_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn_icon.add_theme_font_size_override("font_size", 46)
	box.add_child(warn_icon)

	var warn_title := Label.new()
	warn_title.text = "СБРОСИТЬ ПРОГРЕСС?"
	warn_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn_title.add_theme_font_size_override("font_size", 20)
	warn_title.add_theme_color_override("font_color", Color(1.0, 0.55, 0.55))
	box.add_child(warn_title)

	var warn_text := Label.new()
	warn_text.text = "Все игроки, состав, монеты и настройки\nбудут удалены. Это действие невозможно отменить."
	warn_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warn_text.add_theme_font_size_override("font_size", 13)
	warn_text.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	box.add_child(warn_text)

	var buttons_row := HBoxContainer.new()
	buttons_row.add_theme_constant_override("separation", 10)
	box.add_child(buttons_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Отмена"
	cancel_btn.custom_minimum_size = Vector2(145, 45)
	cancel_btn.add_theme_font_size_override("font_size", 14)
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cancel_btn.pressed.connect(overlay.queue_free)
	_apply_button_style(cancel_btn, Color(0.12, 0.15, 0.20))
	buttons_row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "Сбросить"
	confirm_btn.custom_minimum_size = Vector2(145, 45)
	confirm_btn.add_theme_font_size_override("font_size", 14)
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	confirm_btn.pressed.connect(_confirm_reset.bind(overlay))
	_apply_button_style(confirm_btn, Color(0.55, 0.12, 0.12))
	buttons_row.add_child(confirm_btn)

func _confirm_reset(overlay: Control) -> void:
	SaveManager.reset_progress()
	UserProfile.coins = SaveManager.get_coins(1000)

	# Клуб в памяти (autoload) тоже должен перезагрузиться:
	# карты, состав, запасные и схема из очищенного сохранения.
	ClubManager.reload_data()

	# Применяем сохранённую громкость (она не сбрасывается).
	var bus_idx := AudioServer.get_bus_index("Master")
	var volume := SaveManager.get_master_volume()
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	AudioServer.set_bus_mute(bus_idx, volume <= 0.001)

	if is_instance_valid(overlay):
		overlay.queue_free()

	UIFeedback.show_success("Прогресс сброшен. Начни с чистого листа!")
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _apply_button_style(button: Button, bg: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(bg.r + 0.06, 1.0), min(bg.g + 0.06, 1.0), min(bg.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(bg.r - 0.04, 0.0), max(bg.g - 0.04, 0.0), max(bg.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)