extends Control

var user_profile: Node
var club_manager: Node

var coins_label: Label
var club_rating_label: Label
var players_count_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	user_profile = get_node("/root/UserProfile")
	club_manager = get_node("/root/ClubManager")

	_build_ui()
	_update_club_info()

func _build_ui() -> void:
	# ============================================================
	# ФОН
	# ============================================================
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.08, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# ============================================================
	# ВЕРХНЯЯ ПАНЕЛЬ
	# ============================================================
	var top_panel := PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0, 70)
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.anchor_bottom = 0.0
	top_panel.offset_bottom = 70
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(0.05, 0.08, 0.12, 0.95)
	top_style.corner_radius_bottom_left = 15
	top_style.corner_radius_bottom_right = 15
	top_panel.add_theme_stylebox_override("panel", top_style)
	add_child(top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 20)
	top_margin.add_theme_constant_override("margin_right", 20)
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.add_theme_constant_override("margin_bottom", 10)
	top_panel.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 15)
	top_margin.add_child(top_hbox)

	var club_icon := Label.new()
	club_icon.text = "⚽"
	club_icon.add_theme_font_size_override("font_size", 32)
	top_hbox.add_child(club_icon)

	var club_name_label := Label.new()
	club_name_label.text = "FC DRAFT"
	club_name_label.add_theme_font_size_override("font_size", 20)
	club_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	top_hbox.add_child(club_name_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	coins_label = Label.new()
	coins_label.text = "🪙 0"
	coins_label.add_theme_font_size_override("font_size", 18)
	coins_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	top_hbox.add_child(coins_label)

	# ============================================================
	# ЦЕНТРАЛЬНАЯ ЧАСТЬ
	# ============================================================
	var center_container := CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.offset_top = 80
	center_container.offset_bottom = -100
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center_container)

	var club_card_panel := PanelContainer.new()
	club_card_panel.custom_minimum_size = Vector2(320, 420)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	card_style.corner_radius_top_left = 25
	card_style.corner_radius_top_right = 25
	card_style.corner_radius_bottom_left = 25
	card_style.corner_radius_bottom_right = 25
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(1.0, 0.78, 0.22, 0.6)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.7)
	card_style.shadow_size = 15
	club_card_panel.add_theme_stylebox_override("panel", card_style)
	center_container.add_child(club_card_panel)

	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 25)
	card_margin.add_theme_constant_override("margin_right", 25)
	card_margin.add_theme_constant_override("margin_top", 25)
	card_margin.add_theme_constant_override("margin_bottom", 25)
	club_card_panel.add_child(card_margin)

	var card_vbox := VBoxContainer.new()
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_theme_constant_override("separation", 12)
	card_margin.add_child(card_vbox)

	var emblem := Label.new()
	emblem.text = "🏆"
	emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emblem.add_theme_font_size_override("font_size", 80)
	card_vbox.add_child(emblem)

	var club_title := Label.new()
	club_title.text = "FC DRAFT"
	club_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	club_title.add_theme_font_size_override("font_size", 32)
	club_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	card_vbox.add_child(club_title)

	club_rating_label = Label.new()
	club_rating_label.text = "Рейтинг: 0"
	club_rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	club_rating_label.add_theme_font_size_override("font_size", 18)
	club_rating_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	card_vbox.add_child(club_rating_label)

	players_count_label = Label.new()
	players_count_label.text = "Игроков: 0"
	players_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	players_count_label.add_theme_font_size_override("font_size", 16)
	players_count_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.6))
	card_vbox.add_child(players_count_label)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 0.78, 0.22, 0.3)
	divider.custom_minimum_size = Vector2(200, 2)
	card_vbox.add_child(divider)

	var status_label := Label.new()
	status_label.text = "Готов к матчу"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 0.9))
	card_vbox.add_child(status_label)

	# ============================================================
	# НИЖНЯЯ НАВИГАЦИЯ
	# ============================================================
	var bottom_panel := PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(0, 90)
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_top = 0
	bottom_panel.anchor_top = 1.0
	bottom_panel.offset_top = -90
	var bottom_style := StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.05, 0.08, 0.12, 0.98)
	bottom_style.corner_radius_top_left = 20
	bottom_style.corner_radius_top_right = 20
	bottom_style.border_width_top = 2
	bottom_style.border_color = Color(1.0, 0.78, 0.22, 0.4)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	add_child(bottom_panel)

	var bottom_margin := MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 10)
	bottom_margin.add_theme_constant_override("margin_right", 10)
	bottom_margin.add_theme_constant_override("margin_top", 8)
	bottom_margin.add_theme_constant_override("margin_bottom", 8)
	bottom_panel.add_child(bottom_margin)

	var nav_hbox := HBoxContainer.new()
	nav_hbox.add_theme_constant_override("separation", 8)
	bottom_margin.add_child(nav_hbox)

	_create_nav_button(nav_hbox, "📦", "Коллекция", _on_collection_pressed, Color(0.15, 0.25, 0.4))
	_create_nav_button(nav_hbox, "👥", "Мой состав", _on_squad_pressed, Color(0.15, 0.35, 0.25))
	_create_nav_button(nav_hbox, "🎯", "Драфт", _on_draft_pressed, Color(0.35, 0.2, 0.15))
	_create_nav_button(nav_hbox, "🛒", "Магазин", _on_store_pressed, Color(0.4, 0.3, 0.1))
	_create_nav_button(nav_hbox, "⚽", "Матч", _on_match_pressed, Color(0.3, 0.15, 0.15))

func _create_nav_button(parent: HBoxContainer, icon: String, text: String, callback: Callable, color: Color) -> void:
	var btn_container := VBoxContainer.new()
	btn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 4)
	parent.add_child(btn_container)

	var button := Button.new()
	button.text = icon
	button.custom_minimum_size = Vector2(60, 50)
	button.add_theme_font_size_override("font_size", 28)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(color.r + 0.08, 1.0), min(color.g + 0.08, 1.0), min(color.b + 0.08, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(color.r - 0.05, 0.0), max(color.g - 0.05, 0.0), max(color.b - 0.05, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)

	btn_container.add_child(button)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.7))
	btn_container.add_child(label)

func _update_club_info() -> void:
	if coins_label != null and user_profile != null:
		coins_label.text = "🪙 " + str(user_profile.coins)
	
	if club_manager != null:
		var cards: Array = club_manager.club_cards
		if players_count_label != null:
			players_count_label.text = "Игроков: " + str(cards.size())
		
		if cards.size() > 0 and club_rating_label != null:
			var total_rating := 0
			for card in cards:
				if card is PlayerCard:
					total_rating += card.rating
			var avg_rating := total_rating / cards.size()
			club_rating_label.text = "Рейтинг: " + str(int(avg_rating))

func _on_collection_pressed() -> void:
	get_tree().change_scene_to_file("res://ClubScreen.tscn")

func _on_squad_pressed() -> void:
	get_tree().change_scene_to_file("res://SquadScreen.tscn")

func _on_draft_pressed() -> void:
	get_tree().change_scene_to_file("res://PitchScreen.tscn")

func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://StoreScreen.tscn")

func _on_match_pressed() -> void:
	get_tree().change_scene_to_file("res://MatchScreen.tscn")

func _on_visibility_changed() -> void:
	if visible:
		_update_club_info()
