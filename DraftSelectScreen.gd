class_name DraftSelectScreen
extends Control


signal player_selected_on_screen(player_data: Resource)


# ================================================================
# UI
# ================================================================

@export var card_ui_scene: PackedScene

var container: HBoxContainer
var title_label: Label
var subtitle_label: Label
var hint_label: Label
var round_label: Label

var main_vbox: VBoxContainer
var cards_panel: PanelContainer


# ================================================================
# НАСТРОЙКИ
# ================================================================

const CARD_WIDTH: float = 180.0
const CARD_HEIGHT: float = 260.0

const CARD_GAP: float = 22.0


# ================================================================
# READY
# ================================================================

func _ready() -> void:

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_STOP

	_setup_ui()


# ================================================================
# ОСНОВНОЙ UI
# ================================================================

func _setup_ui() -> void:

	# ============================================================
	# ФОН
	# ============================================================

	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.018,
		0.025,
		0.045,
		1.0
	)

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)


	# ============================================================
	# ВЕРХНИЙ ГРАДИЕНТ / СВЕЧЕНИЕ
	# ============================================================

	var top_glow := ColorRect.new()

	top_glow.set_anchors_preset(
		Control.PRESET_TOP_WIDE
	)

	top_glow.position = Vector2(
		0,
		0
	)

	top_glow.size = Vector2(
		0,
		220
	)

	top_glow.color = Color(
		0.06,
		0.10,
		0.19,
		0.45
	)

	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(top_glow)


	# ============================================================
	# ЦЕНТРАЛЬНОЕ СВЕЧЕНИЕ
	# ============================================================

	var center_glow := Panel.new()

	center_glow.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER
	)

	center_glow.position = Vector2(
		-260,
		-170
	)

	center_glow.size = Vector2(
		520,
		340
	)

	var glow_style := StyleBoxFlat.new()

	glow_style.bg_color = Color(
		0.12,
		0.16,
		0.28,
		0.18
	)

	glow_style.corner_radius_top_left = 170
	glow_style.corner_radius_top_right = 170
	glow_style.corner_radius_bottom_left = 170
	glow_style.corner_radius_bottom_right = 170

	center_glow.add_theme_stylebox_override(
		"panel",
		glow_style
	)

	center_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(center_glow)


	# ============================================================
	# ОСНОВНОЙ CONTAINER
	# ============================================================

	main_vbox = VBoxContainer.new()

	main_vbox.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	main_vbox.add_theme_constant_override(
		"separation",
		8
	)

	main_vbox.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(main_vbox)


	# ============================================================
	# ВЕРХНИЙ ИНДИКАТОР
	# ============================================================

	round_label = Label.new()

	round_label.text = "DRAFT  •  ВЫБОР ИГРОКА"

	round_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	round_label.add_theme_font_size_override(
		"font_size",
		11
	)

	round_label.add_theme_color_override(
		"font_color",
		Color(
			0.55,
			0.70,
			0.90,
			0.85
		)
	)

	round_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(round_label)


	# ============================================================
	# ЗАГОЛОВОК
	# ============================================================

	title_label = Label.new()

	title_label.text = "ВЫБЕРИТЕ ИГРОКА"

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title_label.add_theme_font_size_override(
		"font_size",
		27
	)

	title_label.add_theme_color_override(
		"font_color",
		Color(
			1.0,
			0.88,
			0.38
		)
	)

	title_label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0,
			0,
			0,
			0.7
		)
	)

	title_label.add_theme_constant_override(
		"shadow_offset_x",
		2
	)

	title_label.add_theme_constant_override(
		"shadow_offset_y",
		2
	)

	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(title_label)


	# ============================================================
	# ПОДЗАГОЛОВОК
	# ============================================================

	subtitle_label = Label.new()

	subtitle_label.text = (
		"Выберите одного игрока для своего состава"
	)

	subtitle_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	subtitle_label.add_theme_font_size_override(
		"font_size",
		13
	)

	subtitle_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.55
		)
	)

	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(subtitle_label)


	# ============================================================
	# ПРОМЕЖУТОК
	# ============================================================

	var spacer_top := Control.new()

	spacer_top.custom_minimum_size = Vector2(
		0,
		8
	)

	spacer_top.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(spacer_top)


	# ============================================================
	# ПАНЕЛЬ КАРТОЧЕК
	# ============================================================

	cards_panel = PanelContainer.new()

	cards_panel.custom_minimum_size = Vector2(
		0,
		CARD_HEIGHT + 24
	)

	var cards_style := StyleBoxFlat.new()

	cards_style.bg_color = Color(
		0.035,
		0.050,
		0.080,
		0.78
	)

	cards_style.corner_radius_top_left = 22
	cards_style.corner_radius_top_right = 22
	cards_style.corner_radius_bottom_left = 22
	cards_style.corner_radius_bottom_right = 22

	cards_style.border_width_left = 1
	cards_style.border_width_right = 1
	cards_style.border_width_top = 1
	cards_style.border_width_bottom = 1

	cards_style.border_color = Color(
		1,
		1,
		1,
		0.08
	)

	cards_panel.add_theme_stylebox_override(
		"panel",
		cards_style
	)

	cards_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(cards_panel)


	# ============================================================
	# ОТСТУПЫ КАРТОЧЕК
	# ============================================================

	var cards_margin := MarginContainer.new()

	cards_margin.add_theme_constant_override(
		"margin_left",
		14
	)

	cards_margin.add_theme_constant_override(
		"margin_right",
		14
	)

	cards_margin.add_theme_constant_override(
		"margin_top",
		12
	)

	cards_margin.add_theme_constant_override(
		"margin_bottom",
		12
	)

	cards_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cards_panel.add_child(cards_margin)


	# ============================================================
	# HBOX КАРТОЧЕК
	# ============================================================

	container = HBoxContainer.new()

	container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	container.add_theme_constant_override(
		"separation",
		CARD_GAP
	)

	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cards_margin.add_child(container)


	# ============================================================
	# НИЖНИЙ SPACER
	# ============================================================

	var spacer_bottom := Control.new()

	spacer_bottom.custom_minimum_size = Vector2(
		0,
		5
	)

	spacer_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(spacer_bottom)


	# ============================================================
	# ПОДСКАЗКА
	# ============================================================

	hint_label = Label.new()

	hint_label.text = (
		"▸  Нажмите на карточку, чтобы выбрать игрока"
	)

	hint_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	hint_label.add_theme_font_size_override(
		"font_size",
		12
	)

	hint_label.add_theme_color_override(
		"font_color",
		Color(
			1,
			1,
			1,
			0.42
		)
	)

	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_vbox.add_child(hint_label)


	# ============================================================
	# АНИМАЦИЯ ПОЯВЛЕНИЯ
	# ============================================================

	modulate.a = 0.0

	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.35
	)


# ================================================================
# ВЫБОР ИГРОКА
# ================================================================

func start_choice_for_position(
	pos_name: Variant = "ПОЗИЦИЮ",
	choices: Array = []
) -> void:

	var real_pos := "ПОЗИЦИЮ"
	var real_choices := choices


	# ============================================================
	# СОВМЕСТИМОСТЬ СО СТАРЫМ ВЫЗОВОМ
	# ============================================================

	if typeof(pos_name) == TYPE_ARRAY:

		real_choices = pos_name

	elif typeof(pos_name) == TYPE_STRING:

		real_pos = pos_name


	# ============================================================
	# ЗАГОЛОВКИ
	# ============================================================

	title_label.text = (
		"ВЫБЕРИТЕ ИГРОКА"
	)

	subtitle_label.text = (
		"Позиция: "
		+ real_pos.to_upper()
		+ "  •  выберите одного из вариантов"
	)


	print(
		"DraftSelectScreen: получено вариантов для выбора -> ",
		real_choices.size()
	)


	# ============================================================
	# ОЧИСТКА СТАРЫХ КАРТОЧЕК
	# ============================================================

	for child in container.get_children():

		child.queue_free()


	# ============================================================
	# СОЗДАНИЕ НОВЫХ КАРТОЧЕК
	# ============================================================

	var index := 0


	for card_data in real_choices:

		var card_node = null


		# ========================================================
		# ПОДГОТОВЛЕННАЯ СЦЕНА
		# ========================================================

		if card_ui_scene:

			card_node = card_ui_scene.instantiate()


		# ========================================================
		# РЕЗЕРВНЫЙ LOAD
		# ========================================================

		else:

			var scene_res = load(
				"res://CardUI.tscn"
			)

			if scene_res:

				card_node = scene_res.instantiate()

			else:

				card_node = Control.new()

				var script_ref = load(
					"res://CardUI.gd"
				)

				if script_ref:

					card_node.set_script(
						script_ref
					)


		# ========================================================
		# КАРТОЧКА
		# ========================================================

		if card_node:

			card_node.custom_minimum_size = Vector2(
				CARD_WIDTH,
				CARD_HEIGHT
			)

			card_node.modulate.a = 0.0

			card_node.scale = Vector2(
				0.92,
				0.92
			)

			container.add_child(
				card_node
			)


			# ====================================================
			# ДАННЫЕ
			# ====================================================

			if card_node.has_method("setup"):

				card_node.setup(
					card_data
				)


			# ====================================================
			# SIGNAL CARDUI
			# ====================================================

			if card_node.has_signal(
				"card_selected"
			):

				card_node.card_selected.connect(
					func(selected_resource):
						player_selected_on_screen.emit(
							selected_resource
						)
				)


			# ====================================================
			# FALLBACK BUTTON
			# ====================================================

			elif card_node is BaseButton:

				card_node.pressed.connect(
					func():
						player_selected_on_screen.emit(
							card_data
						)
				)


			# ====================================================
			# АНИМАЦИЯ
			# ====================================================

			var delay := 0.08 * float(index)

			var tween := create_tween()

			tween.set_trans(
				Tween.TRANS_BACK
			)

			tween.set_ease(
				Tween.EASE_OUT
			)

			tween.tween_interval(
				delay
			)

			tween.parallel().tween_property(
				card_node,
				"modulate:a",
				1.0,
				0.22
			)

			tween.parallel().tween_property(
				card_node,
				"scale",
				Vector2.ONE,
				0.28
			)


			index += 1


	# ============================================================
	# АНИМАЦИЯ ПАНЕЛИ
	# ============================================================

	cards_panel.modulate.a = 0.0
	cards_panel.scale = Vector2(
		0.98,
		0.98
	)

	var panel_tween := create_tween()

	panel_tween.set_trans(
		Tween.TRANS_QUAD
	)

	panel_tween.set_ease(
		Tween.EASE_OUT
	)

	panel_tween.tween_property(
		cards_panel,
		"modulate:a",
		1.0,
		0.20
	)

	panel_tween.parallel().tween_property(
		cards_panel,
		"scale",
		Vector2.ONE,
		0.25
	)


# ================================================================
# СТАРЫЙ API
# ================================================================

func show_choices(choices: Array) -> void:

	start_choice_for_position(
		"ПОЗИЦИЮ",
		choices
	)
