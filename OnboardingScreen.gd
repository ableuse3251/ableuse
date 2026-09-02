extends Control

# ============================================================
# ОНБОРДИНГ / УЧЕБНИК ДЛЯ НОВОГО ИГРОКА
# Показывается при первом запуске (либо повторно из настроек).
# ============================================================

var current_step: int = 0

var title_label: Label
var text_label: Label
var step_label: Label
var prev_button: Button
var next_button: Button
var skip_button: Button
var dots: HBoxContainer

var steps: Array[Dictionary] = [
	{
		"icon": "🏆",
		"title": "ДОБРО ПОЖАЛОВАТЬ В FC DRAFT!",
		"text": "Ты — тренер и менеджер футбольного клуба.\nСобирай команду мечты, открывай паки с игроками\nи выигрывай матчи, чтобы заработать монеты.\n\nВсё начинается с драфта — выбери 11 игроков,\nкоторые станут основой твоего клуба."
	},
	{
		"icon": "🎯",
		"title": "ДРАФТ",
		"text": "На главном экране нажми «Драфт».\nТы будешь выбирать игроков по очереди,\nа после выбора 11 футболистов команда\nбудет добавлена в твой клуб.\n\nСледи за позициями и рейтингом игроков!"
	},
	{
		"icon": "👥",
		"title": "СОСТАВ",
		"text": "В разделе «Мой состав» ты видишь всех игроков клуба.\nРасставляй стартовые 11 и выбирай запасных.\nСхема (например, 4-4-2) влияет на расстановку\nи химию команды.\n\nМежду экранами можно свободно переключаться."
	},
	{
		"icon": "🛒",
		"title": "МАГАЗИН",
		"text": "Открывай ЗОЛОТЫЕ ПАКИ в магазине за 500 монет.\nВнутри — случайный игрок: от BRONZE до ELITE.\nЧем выше редкость, тем сильнее и ценнее карточка.\n\nМонеты зарабатываются за матчи и с наград клуба."
	},
	{
		"icon": "⚽",
		"title": "МАТЧИ",
		"text": "Нажми «Матч», когда соберёшь 11 игроков.\nМатч симулируется автоматически: голы, жёлтые\nкарточки, опасные моменты.\n\nЗа победу — 500 монет, за ничью — 300,\nза поражение — 200. Без проигрыша не бывает побед!"
	},
	{
		"icon": "🚀",
		"title": "ВСЁ ГОТОВО!",
		"text": "Ты узнал основы. Удачи в построении команды мечты!\n\nНастройки (звук, сброс прогресса) доступны\nпо кнопке ⚙️ на главном экране.\n\nПриятной игры!"
	}
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_update_step()

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
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(1.0, 0.78, 0.22, 0.55)
	panel_style.shadow_color = Color(0, 0, 0, 0.7)
	panel_style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 25)
	margin.add_theme_constant_override("margin_bottom", 25)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var icon := Label.new()
	icon.text = "🌟"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 22)
	icon.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	box.add_child(icon)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	box.add_child(title_label)

	var step_icon := Label.new()
	step_icon.text = "📖 УЧЕБНИК"
	step_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_icon.add_theme_font_size_override("font_size", 13)
	step_icon.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	box.add_child(step_icon)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 0.78, 0.22, 0.25)
	divider.custom_minimum_size = Vector2(240, 2)
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(divider)

	text_label = Label.new()
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size = Vector2(0, 250)
	text_label.add_theme_font_size_override("font_size", 15)
	text_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	box.add_child(text_label)

	step_label = Label.new()
	step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_label.add_theme_font_size_override("font_size", 13)
	step_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	box.add_child(step_label)

	dots = HBoxContainer.new()
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	dots.add_theme_constant_override("separation", 8)
	box.add_child(dots)

	var nav_row := HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 12)
	nav_row.custom_minimum_size = Vector2(0, 55)
	box.add_child(nav_row)

	prev_button = Button.new()
	prev_button.text = "← Назад"
	prev_button.custom_minimum_size = Vector2(130, 50)
	prev_button.add_theme_font_size_override("font_size", 15)
	prev_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	prev_button.pressed.connect(_on_prev_pressed)
	_apply_button_style(prev_button, Color(0.10, 0.12, 0.17))
	nav_row.add_child(prev_button)

	next_button = Button.new()
	next_button.text = "Далее →"
	next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_button.custom_minimum_size = Vector2(0, 50)
	next_button.add_theme_font_size_override("font_size", 15)
	next_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	next_button.pressed.connect(_on_next_pressed)
	_apply_button_style(next_button, Color(0.65, 0.45, 0.08))
	nav_row.add_child(next_button)

	skip_button = Button.new()
	skip_button.text = "Пропустить"
	skip_button.custom_minimum_size = Vector2(0, 40)
	skip_button.add_theme_font_size_override("font_size", 13)
	skip_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	skip_button.pressed.connect(_finish)
	_apply_button_style(skip_button, Color(0.08, 0.10, 0.14))
	box.add_child(skip_button)

func _update_step() -> void:
	var step: Dictionary = steps[current_step]
	title_label.text = str(step["icon"]) + "  " + str(step["title"])
	text_label.text = str(step["text"])
	step_label.text = "ШАГ " + str(current_step + 1) + " ИЗ " + str(steps.size())

	prev_button.disabled = current_step == 0
	if current_step >= steps.size() - 1:
		next_button.text = "НАЧАТЬ ИГРУ"
	else:
		next_button.text = "Далее →"

	# Обновляем точки-индикаторы.
	for child in dots.get_children():
		child.queue_free()
	for i in range(steps.size()):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		if i == current_step:
			dot.color = Color(1.0, 0.78, 0.22, 1.0)
		else:
			dot.color = Color(1, 1, 1, 0.2)
		dot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		dots.add_child(dot)

func _on_prev_pressed() -> void:
	if current_step > 0:
		current_step -= 1
		_update_step()

func _on_next_pressed() -> void:
	if current_step >= steps.size() - 1:
		_finish()
		return
	current_step += 1
	_update_step()

func _finish() -> void:
	SaveManager.set_onboarding_completed(true)
	UIFeedback.show_success("Отличная работа! Добро пожаловать в FC Draft!")
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