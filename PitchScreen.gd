class_name PitchScreen
extends Control

const GameColors := preload("res://GameColors.gd")

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

# ============================================================
# КОМПОНЕНТЫ
# ============================================================

var field_renderer: FieldRenderer

var position_buttons_controller: PositionButtonsController

var draft_flow: DraftFlowController

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

	_init_components()

	setup_top_ui_layer()

	_update_field_rect()

	if draft_flow.has_saved_lineup():

		draft_flow.show_saved_lineup()

	else:

		draft_flow.start_new_draft()

	_redraw_field()

# ============================================================
# ИНИЦИАЛИЗАЦИЯ КОМПОНЕНТОВ
# ============================================================

func _init_components() -> void:

	field_renderer = FieldRenderer.new()
	field_renderer.name = "FieldRenderer"
	field_renderer.screen = self
	add_child(field_renderer)
	move_child(field_renderer, 0)

	position_buttons_controller = PositionButtonsController.new()
	position_buttons_controller.screen = self

	draft_flow = DraftFlowController.new()
	draft_flow.screen = self

# ============================================================
# RESIZE
# ============================================================

func _notification(what: int) -> void:

	if what == NOTIFICATION_RESIZED:

		if field_renderer == null:
			return

		_update_field_rect()

		field_renderer.reposition_field_cards()

		position_buttons_controller.reposition()

		_redraw_field()

# ============================================================
# РАЗМЕР ПОЛЯ (ГОРИЗОНТАЛЬНОЕ)
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
		400.0
	)

	available_height = max(
		available_height,
		300.0
	)

	var field_aspect_ratio: float = 1.544

	var field_height: float = available_height
	var field_width: float = field_height * field_aspect_ratio

	if field_width > available_width:
		field_width = available_width
		field_height = field_width / field_aspect_ratio

	var field_x: float = (
		size.x - field_width
	) * 0.5

	var field_y: float = field_margin_top

	if field_width < available_width:

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

	if field_renderer:
		field_renderer.set_field_rect(field_rect)

# ============================================================
# ПЕРЕРИСОВКА ПОЛЯ
# ============================================================

func _redraw_field() -> void:

	if field_renderer:
		field_renderer.queue_redraw()

# ============================================================
# ПРОВЕРКА СОХРАНЁННОГО СОСТАВА
# == Этот метод перенесён в DraftFlowController.has_saved_lineup
# ============================================================

# ============================================================
# ВЕРХНИЙ HUD
# ============================================================

func setup_top_ui_layer() -> void:

	top_layer = CanvasLayer.new()
	top_layer.layer = 10
	add_child(top_layer)

	var top_panel := Panel.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_bottom = 64.0

	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(GameColors.BG_DARK, 0.97)
	top_style.border_width_bottom = 1
	top_style.border_color = GameColors.BORDER_HAIRLINE
	top_panel.add_theme_stylebox_override("panel", top_style)
	top_layer.add_child(top_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	top_panel.add_child(margin)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 7)
	margin.add_child(top_bar)

	club_button = Button.new()
	club_button.text = tr("  КЛУБ")
	club_button.custom_minimum_size = Vector2(100, 42)
	club_button.add_theme_font_size_override("font_size", 14)
	club_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	club_button.pressed.connect(_on_club_pressed)
	UIStyleUtils.apply_button_style(club_button, GameColors.BTN_TOP_HUD)
	top_bar.add_child(club_button)

	store_button = Button.new()
	store_button.text = tr("🛒  МАГАЗИН")
	store_button.custom_minimum_size = Vector2(115, 42)
	store_button.add_theme_font_size_override("font_size", 14)
	store_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	store_button.pressed.connect(_on_store_pressed)
	UIStyleUtils.apply_button_style(store_button, GameColors.BTN_TOP_HUD)
	top_bar.add_child(store_button)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	var chemistry_box := VBoxContainer.new()
	chemistry_box.custom_minimum_size = Vector2(120, 42)
	chemistry_box.alignment = BoxContainer.ALIGNMENT_CENTER
	chemistry_box.add_theme_constant_override("separation", 1)
	top_bar.add_child(chemistry_box)

	chem_label = Label.new()
	chem_label.text = tr("  Сыгранность 0 / 33")
	chem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chem_label.add_theme_font_size_override("font_size", 12)
	chem_label.add_theme_color_override("font_color", GameColors.ACCENT_CHEMISTRY)
	chemistry_box.add_child(chem_label)

	chemistry_progress = ProgressBar.new()
	chemistry_progress.min_value = 0
	chemistry_progress.max_value = 33
	chemistry_progress.value = 0
	chemistry_progress.show_percentage = false
	chemistry_progress.custom_minimum_size = Vector2(110, 5)
	chemistry_box.add_child(chemistry_progress)

	coins_label = Label.new()
	coins_label.text = " " + str(UserProfile.coins)
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coins_label.custom_minimum_size = Vector2(82, 42)
	coins_label.add_theme_font_size_override("font_size", 16)
	coins_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.3))
	top_bar.add_child(coins_label)

# ============================================================
# РИСОВАНИЕ ПОЛЯ (перенесено в компонент FieldRenderer)
# ============================================================

func _draw() -> void:
	# Поле рисует FieldRenderer (первый ребёнок экрана).
	pass

# ============================================================
# НОВЫЙ ДРАФТ
# ============================================================

func start_new_draft() -> void:

	draft_flow.start_new_draft()

# ============================================================
# ВЫБОР СХЕМЫ
# ============================================================

func open_formation_selection() -> void:

	draft_flow.open_formation_selection()

# ============================================================
# СХЕМА ВЫБРАНА (ТРАНСФОРМАЦИЯ КООРДИНАТ)
# ============================================================

func _on_formation_selected(formation: Dictionary) -> void:

	draft_flow.on_formation_selected(formation)

# ============================================================
# КНОПКИ ПОЗИЦИЙ
# ============================================================

func _create_position_buttons() -> void:

	position_buttons_controller.create_buttons()

# ============================================================
# ПОЗИЦИЯ НАЖАТА
# ============================================================

func _on_position_pressed(slot_index: int) -> void:

	position_buttons_controller.on_position_pressed(slot_index)

# ============================================================
# ВЫБОР ИГРОКА ДЛЯ ПОЗИЦИИ
# ============================================================

func open_player_choice_for_slot(slot_index: int) -> void:

	draft_flow.open_player_choice_for_slot(slot_index)

# ============================================================
# ПЕРЕВОД ПОЗИЦИИ В КАТЕГОРИЮ БАЗЫ
# ============================================================

func _convert_position_to_database_category(position: String) -> String:

	return draft_flow.convert_position_to_database_category(position)

# ============================================================
# ИГРОК ВЫБРАН
# ============================================================

func _on_player_selected(selected_card: Variant) -> void:

	draft_flow.on_player_selected(selected_card)

# ============================================================
# ПОМЕТИТЬ ПОЗИЦИЮ КАК ЗАПОЛНЕННУЮ
# ============================================================

func _mark_position_as_filled(slot_index: int) -> void:

	position_buttons_controller.mark_filled(slot_index)

# ============================================================
# АКТИВНОСТЬ КНОПОК ПОЗИЦИЙ
# ============================================================

func _set_position_buttons_enabled(enabled: bool) -> void:

	position_buttons_controller.set_enabled(enabled)

# ============================================================
# ПОЗИЦИЯ ИГРОКА НА ПОЛЕ
# ============================================================

func _get_formation_field_position(slot_index: int) -> Vector2:

	return field_renderer.get_formation_field_position(slot_index)

# ============================================================
# ПОЗИЦИЯ КНОПКИ НА ПОЛЕ
# ============================================================

func _get_position_button_position(slot_index: int) -> Vector2:

	return position_buttons_controller.get_position_button_position(slot_index)

# ============================================================
# РАЗМЕЩЕНИЕ КНОПОК
# ============================================================

func _reposition_position_buttons() -> void:

	position_buttons_controller.reposition()

# ============================================================
# СТИЛЬ КНОПКИ ПОЗИЦИИ
# ============================================================

func _apply_position_button_style(button: Button, selected: bool, filled: bool = false) -> void:

	position_buttons_controller.apply_style(button, selected, filled)

# ============================================================
# КАРТОЧКА ИГРОКА
# ============================================================

func _create_field_card(card: PlayerCard, field_position: Vector2) -> void:

	field_renderer._create_field_card(card, field_position)

# ============================================================
# ПОЗИЦИОНИРОВАНИЕ КАРТОЧКИ
# ============================================================

func _position_card_node(card_node: Node, field_position: Vector2) -> void:

	field_renderer._position_card_node(card_node, field_position)

# ============================================================
# ПЕРЕПОЗИЦИОНИРОВАНИЕ КАРТОЧЕК
# ============================================================

func _reposition_field_cards() -> void:

	field_renderer.reposition_field_cards()

# ============================================================
# ОЧИСТКА КАРТОЧЕК
# ============================================================

func _clear_field_cards() -> void:

	field_renderer.clear_field_cards()

# ============================================================
# ОЧИСТКА КНОПОК ПОЗИЦИЙ
# ============================================================

func _clear_position_buttons() -> void:

	position_buttons_controller.clear()

# ============================================================
# СОХРАНЁННЫЙ СОСТАВ
# ============================================================

func show_saved_lineup() -> void:

	draft_flow.show_saved_lineup()

# ============================================================
# СЫГРАННОСТЬ СОХРАНЁННОГО СОСТАВА
# ============================================================

func _update_chemistry_from_lineup() -> void:

	if not is_instance_valid(ClubManager):
		return

	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	var total_chem: int = 0

	if lineup.size() > 0:
		total_chem = ChemistryManager.calculate_team_chemistry(lineup)

	_update_chemistry_display(total_chem)

# ============================================================
# СЫГРАННОСТЬ
# ============================================================

func update_chemistry_ui() -> void:

	var total_chem: int = ChemistryManager.calculate_team_chemistry(PlayerData.current_draft_team)
	_update_chemistry_display(total_chem)

# ============================================================
# UI СЫГРАННОСТИ
# ============================================================

func _update_chemistry_display(value: int) -> void:

	if chem_label:
		chem_label.text = tr("  Сыгранность  ") + str(value) + " / 33"

	if chemistry_progress:
		chemistry_progress.value = value

# ============================================================
# КНОПКА НОВОГО ДРАФТА
# ============================================================

func _create_draft_button() -> void:

	if is_instance_valid(draft_button):
		draft_button.queue_free()

	draft_button = Button.new()
	draft_button.text = tr("  НОВЫЙ ДРАФТ")
	draft_button.custom_minimum_size = Vector2(180, 46)
	draft_button.position = Vector2(18, 76)
	draft_button.add_theme_font_size_override("font_size", 14)
	draft_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	draft_button.pressed.connect(start_new_draft)
	UIStyleUtils.apply_button_style(draft_button, GameColors.ACCENT_GREEN_DEEP)
	top_layer.add_child(draft_button)

# ============================================================
# ЗАВЕРШЕНИЕ ДРАФТА (ИСПРАВЛЕНО: Draft → ClubManager → Formation → Lineup → Save → Match
# ============================================================

func finish_draft() -> void:

	draft_flow.finish_draft()

# ============================================================
# МАГАЗИН
# ============================================================

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://StoreScreen.tscn")

# ============================================================
# МОЙ КЛУБ
# ============================================================

func _on_club_pressed() -> void:
	get_tree().change_scene_to_file("res://ClubScreen.tscn")

# ============================================================
# СТИЛЬ ОБЫЧНОЙ КНОПКИ
# ============================================================
