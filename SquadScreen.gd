extends Control

# ============================================================
# ПЕРЕМЕННЫЕ
# ============================================================
var card_ui_scene: PackedScene = preload("res://CardUI.tscn")

var formation_button: Button
var field_rect: Rect2 = Rect2()
var formation_slots: Array[Dictionary] = []
var slot_buttons: Array[Button] = []
var field_cards: Array[Node] = []

var subs_scroll: ScrollContainer
var subs_container: HBoxContainer
var subs_cards: Array[Node] = []

var current_formation: String = "4-4-2"
var formations: Dictionary = {}

var chemistry_label: Label
var team_rating_label: Label

var card_popup: PanelContainer
var card_popup_slot_index: int = -1

var selection_overlay: PanelContainer
var selection_grid: GridContainer

var formation_overlay: PanelContainer
var formation_grid: GridContainer

# ============================================================
# READY
# ============================================================
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	formations = FormationManager.get_all_formations()
	if formations.is_empty():
		push_error("SquadScreen: не удалось загрузить схемы!")
	
	current_formation = ClubManager.get_current_formation()
	if current_formation.is_empty() or not formations.has(current_formation):
		current_formation = "4-4-2"
	
	_build_ui()
	call_deferred("_initialize_field")

func _initialize_field() -> void:
	_update_field_rect()
	_refresh_squad()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_field_rect()
		_reposition_slots_and_cards()
		queue_redraw()

# ============================================================
# ПОСТРОЕНИЕ UI
# ============================================================
func _build_ui() -> void:
	var top_panel := PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0, 60)
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_bottom = 60
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(0.05, 0.08, 0.12, 0.95)
	top_style.corner_radius_bottom_left = 12
	top_style.corner_radius_bottom_right = 12
	top_panel.add_theme_stylebox_override("panel", top_style)
	add_child(top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 15)
	top_margin.add_theme_constant_override("margin_right", 15)
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_bottom", 8)
	top_panel.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 15)
	top_margin.add_child(top_hbox)

	var back_btn := Button.new()
	back_btn.text = "← Домой"
	back_btn.custom_minimum_size = Vector2(120, 40)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.pressed.connect(_on_back_pressed)
	_apply_button_style(back_btn, Color(0.15, 0.25, 0.4))
	top_hbox.add_child(back_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	var stats_vbox := VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 2)
	top_hbox.add_child(stats_vbox)

	chemistry_label = Label.new()
	chemistry_label.text = "Сыгранность: 0 / 33"
	chemistry_label.add_theme_font_size_override("font_size", 14)
	chemistry_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.65))
	stats_vbox.add_child(chemistry_label)

	team_rating_label = Label.new()
	team_rating_label.text = "Сила команды: 0"
	team_rating_label.add_theme_font_size_override("font_size", 14)
	team_rating_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	stats_vbox.add_child(team_rating_label)

	formation_button = Button.new()
	formation_button.text = "Схема: " + current_formation + " ▼"
	formation_button.custom_minimum_size = Vector2(160, 40)
	formation_button.add_theme_font_size_override("font_size", 16)
	formation_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	formation_button.pressed.connect(_on_formation_button_pressed)
	_apply_button_style(formation_button, Color(0.1, 0.52, 0.26))
	top_hbox.add_child(formation_button)

	var subs_panel := PanelContainer.new()
	subs_panel.custom_minimum_size = Vector2(0, 160)
	subs_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	subs_panel.offset_top = -160
	var subs_style := StyleBoxFlat.new()
	subs_style.bg_color = Color(0.04, 0.06, 0.09, 0.95)
	subs_style.border_width_top = 2
	subs_style.border_color = Color(1.0, 0.78, 0.22, 0.3)
	subs_panel.add_theme_stylebox_override("panel", subs_style)
	add_child(subs_panel)

	var subs_margin := MarginContainer.new()
	subs_margin.add_theme_constant_override("margin_left", 15)
	subs_margin.add_theme_constant_override("margin_right", 15)
	subs_margin.add_theme_constant_override("margin_top", 10)
	subs_margin.add_theme_constant_override("margin_bottom", 10)
	subs_panel.add_child(subs_margin)

	var subs_vbox := VBoxContainer.new()
	subs_vbox.add_theme_constant_override("separation", 8)
	subs_margin.add_child(subs_vbox)

	var subs_title := Label.new()
	subs_title.text = "Запасные"
	subs_title.add_theme_font_size_override("font_size", 16)
	subs_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	subs_vbox.add_child(subs_title)

	subs_scroll = ScrollContainer.new()
	subs_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	subs_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	subs_scroll.custom_minimum_size = Vector2(0, 100)
	subs_vbox.add_child(subs_scroll)

	subs_container = HBoxContainer.new()
	subs_container.add_theme_constant_override("separation", 10)
	subs_scroll.add_child(subs_container)

	var add_sub_btn := Button.new()
	add_sub_btn.text = "+ Добавить в запас"
	add_sub_btn.custom_minimum_size = Vector2(140, 80)
	add_sub_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_sub_btn.pressed.connect(func(): _open_player_selector("SUBSTITUTE"))
	_apply_button_style(add_sub_btn, Color(0.15, 0.35, 0.25))
	subs_container.add_child(add_sub_btn)

	selection_overlay = PanelContainer.new()
	selection_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_overlay.visible = false
	selection_overlay.z_index = 100
	var overlay_style := StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.0, 0.0, 0.0, 0.92)
	selection_overlay.add_theme_stylebox_override("panel", overlay_style)
	add_child(selection_overlay)

	var overlay_margin := MarginContainer.new()
	overlay_margin.add_theme_constant_override("margin_left", 50)
	overlay_margin.add_theme_constant_override("margin_right", 50)
	overlay_margin.add_theme_constant_override("margin_top", 50)
	overlay_margin.add_theme_constant_override("margin_bottom", 50)
	selection_overlay.add_child(overlay_margin)

	var overlay_vbox := VBoxContainer.new()
	overlay_vbox.add_theme_constant_override("separation", 15)
	overlay_margin.add_child(overlay_vbox)

	var overlay_title := Label.new()
	overlay_title.text = "Выберите игрока"
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 24)
	overlay_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	overlay_vbox.add_child(overlay_title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	overlay_vbox.add_child(scroll)

	selection_grid = GridContainer.new()
	selection_grid.columns = 5
	selection_grid.add_theme_constant_override("h_separation", 15)
	selection_grid.add_theme_constant_override("v_separation", 15)
	scroll.add_child(selection_grid)

	var close_overlay_btn := Button.new()
	close_overlay_btn.text = "Закрыть"
	close_overlay_btn.custom_minimum_size = Vector2(200, 45)
	close_overlay_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_overlay_btn.pressed.connect(func(): selection_overlay.visible = false)
	_apply_button_style(close_overlay_btn, Color(0.5, 0.15, 0.15))
	overlay_vbox.add_child(close_overlay_btn)

	formation_overlay = PanelContainer.new()
	formation_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	formation_overlay.visible = false
	formation_overlay.z_index = 100
	var form_overlay_style := StyleBoxFlat.new()
	form_overlay_style.bg_color = Color(0.0, 0.0, 0.0, 0.92)
	formation_overlay.add_theme_stylebox_override("panel", form_overlay_style)
	add_child(formation_overlay)

	var form_overlay_margin := MarginContainer.new()
	form_overlay_margin.add_theme_constant_override("margin_left", 80)
	form_overlay_margin.add_theme_constant_override("margin_right", 80)
	form_overlay_margin.add_theme_constant_override("margin_top", 80)
	form_overlay_margin.add_theme_constant_override("margin_bottom", 80)
	formation_overlay.add_child(form_overlay_margin)

	var form_overlay_vbox := VBoxContainer.new()
	form_overlay_vbox.add_theme_constant_override("separation", 20)
	form_overlay_margin.add_child(form_overlay_vbox)

	var form_overlay_title := Label.new()
	form_overlay_title.text = "Выберите схему"
	form_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_overlay_title.add_theme_font_size_override("font_size", 28)
	form_overlay_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	form_overlay_vbox.add_child(form_overlay_title)

	var form_scroll := ScrollContainer.new()
	form_scroll.custom_minimum_size = Vector2(0, 500)
	form_overlay_vbox.add_child(form_scroll)

	formation_grid = GridContainer.new()
	formation_grid.columns = 4
	formation_grid.add_theme_constant_override("h_separation", 15)
	formation_grid.add_theme_constant_override("v_separation", 15)
	form_scroll.add_child(formation_grid)

	var close_form_overlay_btn := Button.new()
	close_form_overlay_btn.text = "Закрыть"
	close_form_overlay_btn.custom_minimum_size = Vector2(200, 45)
	close_form_overlay_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_form_overlay_btn.pressed.connect(func(): formation_overlay.visible = false)
	_apply_button_style(close_form_overlay_btn, Color(0.5, 0.15, 0.15))
	form_overlay_vbox.add_child(close_form_overlay_btn)

	card_popup = PanelContainer.new()
	card_popup.visible = false
	card_popup.z_index = 50
	card_popup.custom_minimum_size = Vector2(180, 100)
	var popup_style := StyleBoxFlat.new()
	popup_style.bg_color = Color(0.06, 0.09, 0.14, 0.97)
	popup_style.set_corner_radius_all(12)
	popup_style.set_border_width_all(2)
	popup_style.border_color = Color(1.0, 0.78, 0.22, 0.6)
	popup_style.shadow_color = Color(0.0, 0.0, 0.0, 0.7)
	popup_style.shadow_size = 10
	card_popup.add_theme_stylebox_override("panel", popup_style)
	add_child(card_popup)

	var popup_margin := MarginContainer.new()
	popup_margin.add_theme_constant_override("margin_left", 10)
	popup_margin.add_theme_constant_override("margin_right", 10)
	popup_margin.add_theme_constant_override("margin_top", 8)
	popup_margin.add_theme_constant_override("margin_bottom", 8)
	card_popup.add_child(popup_margin)

	var popup_vbox := VBoxContainer.new()
	popup_vbox.add_theme_constant_override("separation", 6)
	popup_margin.add_child(popup_vbox)

	var replace_btn := Button.new()
	replace_btn.text = "🔄 Заменить"
	replace_btn.custom_minimum_size = Vector2(160, 38)
	replace_btn.add_theme_font_size_override("font_size", 14)
	replace_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	replace_btn.pressed.connect(_on_popup_replace_pressed)
	_apply_button_style(replace_btn, Color(0.1, 0.45, 0.25))
	popup_vbox.add_child(replace_btn)

	var remove_btn := Button.new()
	remove_btn.text = "❌ Убрать из состава"
	remove_btn.custom_minimum_size = Vector2(160, 38)
	remove_btn.add_theme_font_size_override("font_size", 14)
	remove_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	remove_btn.pressed.connect(_on_popup_remove_pressed)
	_apply_button_style(remove_btn, Color(0.5, 0.15, 0.15))
	popup_vbox.add_child(remove_btn)

# ============================================================
# ОТРИСОВКА ПОЛЯ
# ============================================================
func _draw() -> void:
	if field_rect.size.x <= 0 or field_rect.size.y <= 0:
		return
	
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.020, 0.030, 1.0), true)
	
	var field := field_rect
	var field_width := field.size.x
	var field_height := field.size.y
	
	var line_color := Color(0.95, 0.98, 1.0, 0.90)
	var line_width := 2.0
	var thin_line_width := 1.5
	
	var glow_center := Vector2(size.x * 0.5, field.position.y + field.size.y * 0.5)
	draw_circle(glow_center, min(field_width * 0.65, 550.0), Color(0.035, 0.16, 0.075, 0.16))
	
	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color(0, 0, 0, 0.38)
	shadow_style.set_corner_radius_all(16)
	draw_style_box(shadow_style, Rect2(field.position + Vector2(0, 6), field.size))
	
	draw_rect(field, Color(0.045, 0.245, 0.105, 1.0), true)
	
	var stripe_count := 10
	var stripe_width: float = field_width / float(stripe_count)
	for i in range(stripe_count):
		var stripe_color := Color(0.055, 0.265, 0.115, 1.0) if i % 2 == 0 else Color(0.040, 0.220, 0.090, 1.0)
		draw_rect(
			Rect2(field.position.x + stripe_width * i, field.position.y, stripe_width + 1.0, field_height),
			stripe_color,
			true
		)
	
	var vignette_strength := 0.12
	var edge: float = field_width * 0.03
	draw_rect(Rect2(field.position.x, field.position.y, field_width, edge), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.end.y - edge, field_width, edge), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.position.x, field.position.y, edge, field_height), Color(0, 0, 0, vignette_strength), true)
	draw_rect(Rect2(field.end.x - edge, field.position.y, edge, field_height), Color(0, 0, 0, vignette_strength), true)
	
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
	var goal_box_height: float = field_height * 0.22
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
	
	var penalty_spot_offset: float = field_width * 0.12
	draw_circle(Vector2(field.position.x + penalty_spot_offset, center.y), 3.0, line_color)
	draw_circle(Vector2(field.end.x - penalty_spot_offset, center.y), 3.0, line_color)
	
	var corner_radius: float = min(field_width, field_height) * 0.015
	draw_arc(field.position, corner_radius, 0.0, PI * 0.5, 20, line_color, thin_line_width)
	draw_arc(Vector2(field.end.x, field.position.y), corner_radius, PI * 0.5, PI, 20, line_color, thin_line_width)
	draw_arc(Vector2(field.position.x, field.end.y), corner_radius, PI * 1.5, TAU, 20, line_color, thin_line_width)
	draw_arc(field.end, corner_radius, PI, PI * 1.5, 20, line_color, thin_line_width)

# ============================================================
# ЛОГИКА ПОЛЯ И СЛОТОВ
# ============================================================
func _update_field_rect() -> void:
	var available_width := size.x - 36.0
	var available_height := size.y - 240.0
	available_width = max(available_width, 400.0)
	available_height = max(available_height, 300.0)

	var field_aspect_ratio := 1.544
	var field_height := available_height
	var field_width := field_height * field_aspect_ratio

	if field_width > available_width:
		field_width = available_width
		field_height = field_width / field_aspect_ratio

	var field_x := (size.x - field_width) * 0.5
	var field_y := 70.0 + (available_height - field_height) * 0.5

	field_rect = Rect2(field_x, field_y, field_width, field_height)

func _refresh_squad() -> void:
	_hide_card_popup()
	formation_slots.clear()
	
	var default_slots: Array = formations.get("4-4-2", [])
	var raw_slots: Array = formations.get(current_formation, default_slots)
	
	for i in range(raw_slots.size()):
		var slot: Dictionary = raw_slots[i]
		var transformed: Dictionary = slot.duplicate(true)
		var old_x: float = float(slot.get("x", 0.5))
		var old_y: float = float(slot.get("y", 0.5))
		transformed["x"] = 1.0 - old_y
		transformed["y"] = old_x
		formation_slots.append(transformed)

	_clear_slots_and_cards()
	
	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	
	for i in range(formation_slots.size()):
		var has_player: bool = i < lineup.size() and lineup[i] != null
		
		if has_player:
			var card: PlayerCard = lineup[i]
			_create_field_card(card, i)
		else:
			_create_slot_button(i)
	
	_refresh_substitutes()
	_update_chemistry_and_rating()
	queue_redraw()

func _create_slot_button(slot_index: int) -> void:
	var btn := Button.new()
	btn.text = formation_slots[slot_index].position
	btn.custom_minimum_size = Vector2(60, 40)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 12)
	btn.z_index = 10
	
	var slot_idx: int = slot_index
	btn.pressed.connect(func(): _on_slot_pressed(slot_idx))
	
	_apply_position_button_style(btn, false)
	add_child(btn)
	slot_buttons.append(btn)
	btn.position = _get_slot_position(slot_index) - Vector2(30, 20)

func _create_field_card(card: PlayerCard, slot_index: int) -> void:
	if card_ui_scene == null:
		return
	var card_node: CardUI = card_ui_scene.instantiate()
	card_node.z_index = 5
	add_child(card_node)
	field_cards.append(card_node)
	
	card_node.set_compact_mode()
	card_node.setup(card)
	
	card_node.card_selected.connect(func(_data): _on_field_card_clicked(slot_index))
	
	card_node.position = _get_slot_position(slot_index) - Vector2(72, 80) * 0.8
	card_node.scale = Vector2(0.8, 0.8)

func _reposition_slots_and_cards() -> void:
	for i in range(slot_buttons.size()):
		if is_instance_valid(slot_buttons[i]):
			slot_buttons[i].position = _get_slot_position(i) - Vector2(30, 20)

	for i in range(field_cards.size()):
		if is_instance_valid(field_cards[i]):
			var card_node: Control = field_cards[i] as Control
			card_node.scale = Vector2(0.8, 0.8)
			card_node.position = _get_slot_position(i) - Vector2(72, 80) * 0.8

func _get_slot_position(slot_index: int) -> Vector2:
	if slot_index < 0 or slot_index >= formation_slots.size():
		return field_rect.get_center()
	var slot: Dictionary = formation_slots[slot_index]
	return Vector2(
		field_rect.position.x + field_rect.size.x * float(slot.get("x", 0.5)),
		field_rect.position.y + field_rect.size.y * float(slot.get("y", 0.5))
	)

func _clear_slots_and_cards() -> void:
	for btn in slot_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	slot_buttons.clear()
	
	for card in field_cards:
		if is_instance_valid(card):
			card.queue_free()
	field_cards.clear()

# ============================================================
# ВСПЛЫВАЮЩЕЕ МЕНЮ КАРТОЧКИ
# ============================================================
func _show_card_popup(slot_index: int) -> void:
	card_popup_slot_index = slot_index
	var slot_pos := _get_slot_position(slot_index)
	
	var popup_x: float = slot_pos.x + 50
	var popup_y: float = slot_pos.y - 60
	
	if popup_x + 180 > size.x:
		popup_x = slot_pos.x - 200
	if popup_y < 70:
		popup_y = 70
	if popup_y + 100 > size.y - 170:
		popup_y = size.y - 270
	
	card_popup.position = Vector2(popup_x, popup_y)
	card_popup.visible = true

func _hide_card_popup() -> void:
	card_popup.visible = false
	card_popup_slot_index = -1

func _on_popup_replace_pressed() -> void:
	_hide_card_popup()
	if card_popup_slot_index >= 0 and card_popup_slot_index < formation_slots.size():
		_open_player_selector(formation_slots[card_popup_slot_index].position, card_popup_slot_index)

func _on_popup_remove_pressed() -> void:
	var slot_idx := card_popup_slot_index
	_hide_card_popup()
	
	if slot_idx < 0:
		return
	
	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	if slot_idx < lineup.size() and lineup[slot_idx] != null:
		var card: PlayerCard = lineup[slot_idx]
		ClubManager.remove_player_from_lineup(card)
		print("Игрок ", card.player_name, " убран из состава")
		_refresh_squad()

# ============================================================
# СЫГРАННОСТЬ И РЕЙТИНГ
# ============================================================
func _update_chemistry_and_rating() -> void:
	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	var total_chem: int = 0
	var total_rating: int = 0
	var player_count: int = 0
	
	for card in lineup:
		if card != null:
			total_rating += card.rating
			player_count += 1
	
	if is_instance_valid(ChemistryManager) and lineup.size() > 0:
		total_chem = ChemistryManager.calculate_team_chemistry(lineup)
	
	if chemistry_label:
		chemistry_label.text = "Сыгранность: " + str(total_chem) + " / 33"
	
	if team_rating_label:
		var avg_rating: int = 0
		if player_count > 0:
			avg_rating = total_rating / player_count
		team_rating_label.text = "Сила команды: " + str(avg_rating)

# ============================================================
# ЗАПАСНЫЕ (С ИСПОЛЬЗОВАНИЕМ ПУЛА CardPool)
# ============================================================
func _refresh_substitutes() -> void:
	for card_node in subs_cards:
		if is_instance_valid(card_node) and card_node is CardUI:
			CardPool.release_card(card_node)
	subs_cards.clear()

	var subs: Array[PlayerCard] = ClubManager.get_substitutes()
	for card in subs:
		if card != null:
			var card_node: CardUI = CardPool.acquire_card()
			if card_node == null:
				push_warning("SquadScreen: не удалось получить карточку из пула")
				continue
			
			if card_node.get_parent() != subs_container:
				card_node.reparent(subs_container)
			
			subs_cards.append(card_node)
			
			card_node.set_compact_mode()
			card_node.setup(card)
			
			if card_node.card_selected.is_connected(_on_sub_card_clicked):
				card_node.card_selected.disconnect(_on_sub_card_clicked)
			card_node.card_selected.connect(_on_sub_card_clicked.bind(card))

# ============================================================
# ОБРАБОТЧИКИ НАЖАТИЙ
# ============================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _on_formation_button_pressed() -> void:
	_open_formation_selector()

func _on_slot_pressed(slot_index: int) -> void:
	_hide_card_popup()
	_open_player_selector(formation_slots[slot_index].position, slot_index)

func _on_field_card_clicked(slot_index: int) -> void:
	_show_card_popup(slot_index)

func _on_sub_card_clicked(card: PlayerCard) -> void:
	ClubManager.remove_player_from_substitutes(card)
	print("Игрок ", card.player_name, " убран из запаса")
	_refresh_squad()

# ============================================================
# ВЫБОР СХЕМЫ
# ============================================================
func _open_formation_selector() -> void:
	for child in formation_grid.get_children():
		child.queue_free()
	
	for formation_name in formations.keys():
		var btn := Button.new()
		btn.text = formation_name
		btn.custom_minimum_size = Vector2(150, 60)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 18)
		
		var f_name: String = formation_name
		btn.pressed.connect(func(): _on_formation_selected(f_name))
		
		var bg_color: Color = Color(0.1, 0.52, 0.26)
		if formation_name == current_formation:
			bg_color = Color(1.0, 0.70, 0.18)
		
		_apply_button_style(btn, bg_color)
		formation_grid.add_child(btn)
	
	formation_overlay.visible = true

func _on_formation_selected(formation_name: String) -> void:
	current_formation = formation_name
	ClubManager.set_formation(current_formation)
	formation_button.text = "Схема: " + current_formation + " ▼"
	formation_overlay.visible = false
	_refresh_squad()

# ============================================================
# ВЫБОР ИГРОКА (С ИСПОЛЬЗОВАНИЕМ ПУЛА CardPool)
# ============================================================
func _open_player_selector(required_position: String, slot_index: int = -1) -> void:
	for child in selection_grid.get_children():
		if child is CardUI:
			CardPool.release_card(child)
	
	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	var subs: Array[PlayerCard] = ClubManager.get_substitutes()
	var all_club_cards: Array[PlayerCard] = ClubManager.get_all_cards()
	
	var available_players: Array[PlayerCard] = []
	
	var current_card_in_slot: PlayerCard = null
	if slot_index >= 0 and slot_index < lineup.size():
		current_card_in_slot = lineup[slot_index]
	
	for card in all_club_cards:
		if card == null:
			continue
		
		if card == current_card_in_slot:
			continue
		
		var in_lineup: bool = false
		for c in lineup:
			if c == card:
				in_lineup = true
				break
		
		var in_subs: bool = false
		for c in subs:
			if c == card:
				in_subs = true
				break
		
		if not in_lineup and not in_subs:
			if required_position == "SUBSTITUTE" or card.position.to_upper() == required_position.to_upper():
				available_players.append(card)
	
	if available_players.is_empty():
		print("Нет доступных игроков для этой позиции в коллекции.")
		selection_overlay.visible = false
		return
	
	for card in available_players:
		var card_node: CardUI = CardPool.acquire_card()
		if card_node == null:
			push_warning("SquadScreen: не удалось получить карточку из пула для выбора")
			continue
		
		if card_node.get_parent() != selection_grid:
			card_node.reparent(selection_grid)
		
		card_node.set_compact_mode()
		card_node.setup(card)
		
		if required_position == "SUBSTITUTE":
			card_node.card_selected.connect(_on_player_selected_for_sub.bind(card))
		else:
			card_node.card_selected.connect(_on_player_selected_for_slot.bind(card, slot_index))
	
	selection_overlay.visible = true

func _on_player_selected_for_slot(card: PlayerCard, slot_index: int) -> void:
	ClubManager.set_player_in_lineup(slot_index, card)
	selection_overlay.visible = false
	_refresh_squad()

func _on_player_selected_for_sub(card: PlayerCard) -> void:
	ClubManager.add_player_to_substitutes(card)
	selection_overlay.visible = false
	_refresh_squad()

# ============================================================
# СТИЛИ
# ============================================================
func _apply_button_style(button: Button, background_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = background_color
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.border_color = Color(1, 1, 1, 0.1)
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(background_color.r + 0.06, 1.0), min(background_color.g + 0.06, 1.0), min(background_color.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(background_color.r - 0.04, 0.0), max(background_color.g - 0.04, 0.0), max(background_color.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)

func _apply_position_button_style(button: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.025, 0.055, 0.085, 0.94) if not selected else Color(1.0, 0.70, 0.18, 0.95)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(1, 1, 1, 0.25) if not selected else Color(1.0, 0.90, 0.40, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	
	var hover := normal.duplicate()
	if not selected:
		hover.bg_color = Color(0.12, 0.18, 0.23, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	
	button.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
