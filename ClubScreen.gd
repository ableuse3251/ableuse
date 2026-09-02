extends Control

var cards_container: GridContainer
var empty_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_ui()
	
	await get_tree().create_timer(0.2).timeout
	_refresh_cards()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.025, 0.035, 0.055, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)

	var top_panel := PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0, 60)
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(0.055, 0.07, 0.10, 0.95)
	top_style.corner_radius_bottom_left = 12
	top_style.corner_radius_bottom_right = 12
	top_panel.add_theme_stylebox_override("panel", top_style)
	main_vbox.add_child(top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 20)
	top_margin.add_theme_constant_override("margin_right", 20)
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.add_theme_constant_override("margin_bottom", 10)
	top_panel.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 15)
	top_margin.add_child(top_hbox)

	var title := Label.new()
	title.text = "МОЯ КОЛЛЕКЦИЯ"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	top_hbox.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	var back_button := Button.new()
	back_button.text = "← Домой"
	back_button.custom_minimum_size = Vector2(100, 40)
	back_button.add_theme_font_size_override("font_size", 14)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_back_pressed)
	_apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	top_hbox.add_child(back_button)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)

	var scroll_margin := MarginContainer.new()
	scroll_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_margin.add_theme_constant_override("margin_left", 20)
	scroll_margin.add_theme_constant_override("margin_right", 20)
	scroll_margin.add_theme_constant_override("margin_top", 15)
	scroll_margin.add_theme_constant_override("margin_bottom", 15)
	scroll.add_child(scroll_margin)

	cards_container = GridContainer.new()
	cards_container.columns = 3
	cards_container.add_theme_constant_override("h_separation", 12)
	cards_container.add_theme_constant_override("v_separation", 12)
	cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_margin.add_child(cards_container)

	empty_label = Label.new()
	empty_label.text = "В вашем клубе пока нет игроков.\nОткройте пак в магазине, чтобы получить первого игрока!"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.add_theme_font_size_override("font_size", 16)
	empty_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
	empty_label.visible = false
	main_vbox.add_child(empty_label)

func _refresh_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	
	var all_cards: Array = ClubManager.club_cards
	
	if all_cards.is_empty():
		empty_label.visible = true
		cards_container.visible = false
		return
	
	empty_label.visible = false
	cards_container.visible = true
	
	for card in all_cards:
		var card_ui := CardUI.new()
		card_ui.setup(card)
		card_ui.custom_minimum_size = Vector2(180, 250)
		card_ui.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card_ui.gui_input.connect(_on_card_clicked.bind(card))
		cards_container.add_child(card_ui)

func _on_card_clicked(event: InputEvent, card: PlayerCard) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("ClubScreen: клик по игроку -> ", card.player_name)
		_open_player_details(card)

func _open_player_details(card: PlayerCard) -> void:
	if card == null:
		return
	var details_scene := load("res://PlayerDetailsScreen.tscn") as PackedScene
	if details_scene == null:
		push_error("ClubScreen: не удалось загрузить PlayerDetailsScreen.tscn")
		return
	var details := details_scene.instantiate()
	add_child(details)
	if details.has_method("setup"):
		details.setup(card)

func _apply_button_style(button: Button, background_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = background_color
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(background_color.r + 0.06, 1.0), min(background_color.g + 0.06, 1.0), min(background_color.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(background_color.r - 0.04, 0.0), max(background_color.g - 0.04, 0.0), max(background_color.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")

func _on_visibility_changed() -> void:
	if visible:
		await get_tree().create_timer(0.05).timeout
		_refresh_cards()
