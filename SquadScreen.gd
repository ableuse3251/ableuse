class_name SquadScreen
extends Control

const GameColors := preload("res://GameColors.gd")

# ============================================================
# ПЕРЕМЕННЫЕ
# ============================================================
var card_ui_scene: PackedScene = preload("res://CardUI.tscn")

var formation_button: Button
var formation_slots: Array[Dictionary] = []

var subs_scroll: ScrollContainer
var subs_container: HBoxContainer
var subs_cards: Array[Node] = []

var current_formation: String = "4-4-2"
var formations: Dictionary = {}

var chemistry_label: Label
var team_rating_label: Label

var card_popup: PanelContainer

var selection_overlay: PanelContainer
var selection_grid: GridContainer

var formation_overlay: PanelContainer
var formation_grid: GridContainer

# ============================================================
# КОМПОНЕНТЫ
# ============================================================

var field_controller: SquadFieldController

var player_selector: SquadPlayerSelectorController

var card_popup_controller: SquadCardPopupController

var card_list_controller: SquadCardListController

# ============================================================
# READY
# ============================================================
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	formations = FormationManager.get_all_formations()
	if formations.is_empty():
		push_error("SquadScreen: не удалось загрузить схемы!")
		UIFeedback.show_error(tr("Не удалось загрузить схемы"))
	
	current_formation = ClubManager.get_current_formation()
	if formations.is_empty():
		# Схемы не загрузились вовсе — оставляем дефолт, слоты будут пустыми.
		push_error("SquadScreen: formations пуст — расстановка недоступна.")
		current_formation = "4-4-2"
	elif current_formation.is_empty() or not formations.has(current_formation):
		# Устаревшая формация из сохранения — откат на 4-4-2 (или первую доступную)
		# с синхронизацией в ClubManager/сохранение.
		var fallback: String = "4-4-2" if formations.has("4-4-2") else str(formations.keys()[0])
		push_warning("SquadScreen: формация '" + current_formation + "' устарела, откат на '" + fallback + "'.")
		current_formation = fallback
		ClubManager.set_formation(current_formation)
	
	_init_components()
	_build_ui()
	call_deferred("_initialize_field")


func _init_components() -> void:

	field_controller = SquadFieldController.new()
	field_controller.name = "SquadField"
	field_controller.screen = self
	add_child(field_controller)
	move_child(field_controller, 0)

	player_selector = SquadPlayerSelectorController.new()
	player_selector.screen = self

	card_popup_controller = SquadCardPopupController.new()
	card_popup_controller.screen = self

	card_list_controller = SquadCardListController.new()
	card_list_controller.screen = self


func _initialize_field() -> void:
	field_controller.update_field_rect()
	_refresh_squad()
	field_controller.queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if field_controller == null:
			return
		field_controller.update_field_rect()
		field_controller.reposition_slots_and_cards()
		field_controller.queue_redraw()


# ============================================================
# ПОСТРОЕНИЕ UI
# ============================================================
func _build_ui() -> void:
	var top_panel := PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0, 60)
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_bottom = 60
	
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = GameColors.BG_TOP_BAR
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
	back_btn.text = tr("← Домой")
	back_btn.custom_minimum_size = Vector2(120, 40)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.pressed.connect(_on_back_pressed)
	UIStyleUtils.apply_button_style(back_btn, GameColors.ACCENT_BLUE)
	top_hbox.add_child(back_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	var stats_vbox := VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 2)
	top_hbox.add_child(stats_vbox)

	chemistry_label = Label.new()
	chemistry_label.text = tr("Сыгранность: 0 / 33")
	chemistry_label.add_theme_font_size_override("font_size", 14)
	chemistry_label.add_theme_color_override("font_color", GameColors.ACCENT_CHEMISTRY)
	stats_vbox.add_child(chemistry_label)

	team_rating_label = Label.new()
	team_rating_label.text = tr("Сила команды: 0")
	team_rating_label.add_theme_font_size_override("font_size", 14)
	team_rating_label.add_theme_color_override("font_color", GameColors.ACCENT_GOLD)
	stats_vbox.add_child(team_rating_label)

	formation_button = Button.new()
	formation_button.text = tr("Схема: %s ▼") % current_formation
	formation_button.custom_minimum_size = Vector2(160, 40)
	formation_button.add_theme_font_size_override("font_size", 16)
	formation_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	formation_button.pressed.connect(_on_formation_button_pressed)
	UIStyleUtils.apply_button_style(formation_button, GameColors.ACCENT_GREEN_DEEP)
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
	subs_title.text = tr("Запасные")
	subs_title.add_theme_font_size_override("font_size", 16)
	subs_title.add_theme_color_override("font_color", GameColors.ACCENT_GOLD)
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
	add_sub_btn.text = tr("+ Добавить в запас")
	add_sub_btn.custom_minimum_size = Vector2(140, 80)
	add_sub_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_sub_btn.pressed.connect(func(): _open_player_selector("SUBSTITUTE"))
	UIStyleUtils.apply_button_style(add_sub_btn, Color(0.15, 0.35, 0.25))
	subs_container.add_child(add_sub_btn)

	selection_overlay = PanelContainer.new()
	selection_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_overlay.visible = false
	selection_overlay.z_index = 100
	
	var overlay_style := StyleBoxFlat.new()
	overlay_style.bg_color = GameColors.OVERLAY_STRONG
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
	overlay_title.text = tr("Выберите игрока")
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 24)
	overlay_title.add_theme_color_override("font_color", GameColors.ACCENT_GOLD)
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
	close_overlay_btn.text = tr("Закрыть")
	close_overlay_btn.custom_minimum_size = Vector2(200, 45)
	close_overlay_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_overlay_btn.pressed.connect(func(): selection_overlay.visible = false)
	UIStyleUtils.apply_button_style(close_overlay_btn, Color(0.5, 0.15, 0.15))
	overlay_vbox.add_child(close_overlay_btn)

	formation_overlay = PanelContainer.new()
	formation_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	formation_overlay.visible = false
	formation_overlay.z_index = 100
	
	var form_overlay_style := StyleBoxFlat.new()
	form_overlay_style.bg_color = GameColors.OVERLAY_STRONG
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
	form_overlay_title.text = tr("Выберите схему")
	form_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_overlay_title.add_theme_font_size_override("font_size", 28)
	form_overlay_title.add_theme_color_override("font_color", GameColors.ACCENT_GOLD)
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
	close_form_overlay_btn.text = tr("Закрыть")
	close_form_overlay_btn.custom_minimum_size = Vector2(200, 45)
	close_form_overlay_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_form_overlay_btn.pressed.connect(func(): formation_overlay.visible = false)
	UIStyleUtils.apply_button_style(close_form_overlay_btn, GameColors.BTN_DANGER)
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
	popup_style.shadow_color = GameColors.SHADOW_POPUP
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
	replace_btn.text = tr("🔄 Заменить")
	replace_btn.custom_minimum_size = Vector2(160, 38)
	replace_btn.add_theme_font_size_override("font_size", 14)
	replace_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	replace_btn.pressed.connect(card_popup_controller.on_replace_pressed)
	UIStyleUtils.apply_button_style(replace_btn, Color(0.1, 0.45, 0.25))
	popup_vbox.add_child(replace_btn)

	var remove_btn := Button.new()
	remove_btn.text = tr("❌ Убрать из состава")
	remove_btn.custom_minimum_size = Vector2(160, 38)
	remove_btn.add_theme_font_size_override("font_size", 14)
	remove_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	remove_btn.pressed.connect(card_popup_controller.on_remove_pressed)
	UIStyleUtils.apply_button_style(remove_btn, GameColors.BTN_DANGER)
	popup_vbox.add_child(remove_btn)


# ============================================================
# ЛОГИКА ПОЛЯ И СЛОТОВ
# ============================================================
func _update_field_rect() -> void:
	field_controller.update_field_rect()


func _refresh_squad() -> void:
	card_popup_controller.hide()
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

	field_controller.clear_slots_and_cards()
	
	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()
	
	for i in range(formation_slots.size()):
		var has_player: bool = i < lineup.size() and lineup[i] != null
		
		if has_player:
			var card: PlayerCard = lineup[i]
			field_controller.create_field_card(card, i)
		else:
			field_controller.create_slot_button(i)
	
	_refresh_substitutes()
	_update_chemistry_and_rating()
	field_controller.queue_redraw()


func _create_slot_button(slot_index: int) -> void:
	field_controller.create_slot_button(slot_index)


func _create_field_card(card: PlayerCard, slot_index: int) -> void:
	field_controller.create_field_card(card, slot_index)


func _reposition_slots_and_cards() -> void:
	field_controller.reposition_slots_and_cards()


func _get_slot_position(slot_index: int) -> Vector2:
	return field_controller.get_slot_position(slot_index)


func _clear_slots_and_cards() -> void:
	field_controller.clear_slots_and_cards()


# ============================================================
# ВСПЛЫВАЮЩЕЕ МЕНЮ КАРТОЧКИ
# ============================================================
func _show_card_popup(slot_index: int) -> void:
	card_popup_controller.show(slot_index)


func _hide_card_popup() -> void:
	card_popup_controller.hide()


func _on_popup_replace_pressed() -> void:
	card_popup_controller.on_replace_pressed()


func _on_popup_remove_pressed() -> void:
	card_popup_controller.on_remove_pressed()
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
		chemistry_label.text = tr("Сыгранность: ") + str(total_chem) + " / 33"
	
	if team_rating_label:
		var avg_rating: int = 0
		
		if player_count > 0:
			avg_rating = total_rating / player_count
		
		team_rating_label.text = tr("Сила команды: ") + str(avg_rating)


# ============================================================
# ЗАПАСНЫЕ (С ИСПОЛЬЗОВАНИЕМ ПУЛА CardPool)
# ============================================================
func _refresh_substitutes() -> void:
	card_list_controller.refresh_subs()



# ============================================================
# ОБРАБОТЧИКИ НАЖАТИЙ
# ============================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")


func _on_formation_button_pressed() -> void:
	_open_formation_selector()


func _on_slot_pressed(slot_index: int) -> void:
	_hide_card_popup()
	if slot_index < 0 or slot_index >= formation_slots.size():
		return
	_open_player_selector(formation_slots[slot_index].position, slot_index)


func _on_field_card_clicked(slot_index: int) -> void:
	_show_card_popup(slot_index)


func _on_sub_card_clicked(card: PlayerCard) -> void:
	card_list_controller._on_sub_card_clicked(card)


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
		
		var bg_color: Color = GameColors.ACCENT_GREEN_DEEP
		
		if formation_name == current_formation:
			bg_color = GameColors.ACCENT_ORANGE
		
		UIStyleUtils.apply_button_style(btn, bg_color)
		formation_grid.add_child(btn)
	
	formation_overlay.visible = true


func _on_formation_selected(formation_name: String) -> void:
	current_formation = formation_name
	ClubManager.set_formation(current_formation)
	formation_button.text = tr("Схема: %s ▼") % current_formation
	formation_overlay.visible = false
	_refresh_squad()


# ============================================================
# ВЫБОР ИГРОКА (С ИСПОЛЬЗОВАНИЕМ ПУЛА CardPool)
# ============================================================
func _open_player_selector(required_position: String, slot_index: int = -1) -> void:
	player_selector.open_selector(required_position, slot_index)


func _on_player_selected_for_slot(card: PlayerCard, slot_index: int) -> void:
	player_selector.on_player_selected_for_slot(card, slot_index)


func _on_player_selected_for_sub(card: PlayerCard) -> void:
	player_selector.on_player_selected_for_sub(card)


func _apply_position_button_style(button: Button, selected: bool) -> void:
	field_controller.apply_position_button_style(button, selected)
