extends Control

const PACK_PRICE: int = 500

var coins_label: Label
var result_label: Label
var action_button: Button
var back_button: Button

var pack_panel: PanelContainer
var chances_label: Label
var revealed_card_ui: CardUI = null

var user_profile: Node
var club_manager: Node

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	user_profile = get_node("/root/UserProfile")
	club_manager = get_node("/root/ClubManager")

	_build_ui()
	_update_coins()

func _build_ui() -> void:
	# ============================================================
	# ФОН
	# ============================================================
	var bg := ColorRect.new()
	bg.color = Color(0.025, 0.035, 0.055, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# ============================================================
	# ЦЕНТР
	# ============================================================
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# ============================================================
	# ОСНОВНАЯ ПАНЕЛЬ
	# ============================================================
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(390, 580)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.07, 0.10, 0.98)
	panel_style.corner_radius_top_left = 22
	panel_style.corner_radius_top_right = 22
	panel_style.corner_radius_bottom_left = 22
	panel_style.corner_radius_bottom_right = 22
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(1.0, 1.0, 1.0, 0.12)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	# ============================================================
	# ОТСТУПЫ
	# ============================================================
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)

	# ============================================================
	# ОСНОВНОЙ CONTAINER
	# ============================================================
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)

	# ============================================================
	# ЗАГОЛОВОК
	# ============================================================
	var title := Label.new()
	title.text = "МАГАЗИН"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	box.add_child(title)

	# ============================================================
	# БАЛАНС
	# ============================================================
	coins_label = Label.new()
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.add_theme_font_size_override("font_size", 18)
	coins_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	box.add_child(coins_label)

	# ============================================================
	# ПАК (скрывается при открытии)
	# ============================================================
	pack_panel = PanelContainer.new()
	pack_panel.custom_minimum_size = Vector2(0, 205)
	var pack_style := StyleBoxFlat.new()
	pack_style.bg_color = Color(0.11, 0.09, 0.045, 1.0)
	pack_style.corner_radius_top_left = 18
	pack_style.corner_radius_top_right = 18
	pack_style.corner_radius_bottom_left = 18
	pack_style.corner_radius_bottom_right = 18
	pack_style.border_width_left = 2
	pack_style.border_width_right = 2
	pack_style.border_width_top = 2
	pack_style.border_width_bottom = 2
	pack_style.border_color = Color(1.0, 0.78, 0.20, 0.35)
	pack_panel.add_theme_stylebox_override("panel", pack_style)
	box.add_child(pack_panel)

	var pack_box := VBoxContainer.new()
	pack_box.alignment = BoxContainer.ALIGNMENT_CENTER
	pack_box.add_theme_constant_override("separation", 4)
	pack_panel.add_child(pack_box)

	var pack_icon := Label.new()
	pack_icon.text = "📦"
	pack_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_icon.add_theme_font_size_override("font_size", 42)
	pack_box.add_child(pack_icon)

	var pack_title := Label.new()
	pack_title.text = "ЗОЛОТОЙ ПАК"
	pack_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_title.add_theme_font_size_override("font_size", 21)
	pack_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.20))
	pack_box.add_child(pack_title)

	var pack_description := Label.new()
	pack_description.text = "1 случайный игрок из доступной базы"
	pack_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_description.add_theme_font_size_override("font_size", 13)
	pack_description.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.65))
	pack_box.add_child(pack_description)

	var price_label := Label.new()
	price_label.text = "💰 " + str(PACK_PRICE) + " МОНЕТ"
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	pack_box.add_child(price_label)

	# ============================================================
	# ШАНСЫ (скрываются при открытии)
	# ============================================================
	chances_label = Label.new()
	chances_label.text = "BRONZE 55%  •  SILVER 30%  •  GOLD 12%  •  ELITE 3%"
	chances_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chances_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chances_label.add_theme_font_size_override("font_size", 11)
	chances_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.50))
	box.add_child(chances_label)

	# ============================================================
	# КАРТОЧКА (изначально скрыта)
	# ============================================================
	revealed_card_ui = CardUI.new()
	revealed_card_ui.visible = false
	revealed_card_ui.custom_minimum_size = Vector2(220, 310)
	box.add_child(revealed_card_ui)

	# ============================================================
	# РЕЗУЛЬТАТ
	# ============================================================
	result_label = Label.new()
	result_label.text = "Выберите пак и получите нового игрока."
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.custom_minimum_size = Vector2(0, 65)
	result_label.add_theme_font_size_override("font_size", 13)
	result_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.75))
	box.add_child(result_label)

	# ============================================================
	# КНОПКА ДЕЙСТВИЯ
	# ============================================================
	action_button = Button.new()
	action_button.text = "📦 ОТКРЫТЬ ПАК"
	action_button.custom_minimum_size = Vector2(0, 48)
	action_button.add_theme_font_size_override("font_size", 17)
	action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	action_button.pressed.connect(_on_action_pressed)
	_apply_button_style(action_button, Color(0.65, 0.45, 0.08))
	box.add_child(action_button)

	# ============================================================
	# НАЗАД
	# ============================================================
	back_button = Button.new()
	back_button.text = "← Вернуться в игру"
	back_button.custom_minimum_size = Vector2(0, 40)
	back_button.add_theme_font_size_override("font_size", 14)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_back_pressed)
	_apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	box.add_child(back_button)

# ============================================================
# ОБНОВЛЕНИЕ БАЛАНСА
# ============================================================
func _update_coins() -> void:
	if coins_label == null or user_profile == null:
		return
	coins_label.text = "🪙 " + str(user_profile.coins) + " МОНЕТ"

# ============================================================
# ГЕНЕРАЦИЯ РЕДКОСТИ
# ============================================================
func _get_random_rarity() -> String:
	var roll := randf() * 100.0
	if roll < 55.0:
		return "BRONZE"
	elif roll < 85.0:
		return "SILVER"
	elif roll < 97.0:
		return "GOLD"
	else:
		return "ELITE"

# ============================================================
# ОБРАБОТКА НАЖАТИЯ (ПОКУПКА ИЛИ ЗАБИРАНИЕ)
# ============================================================
func _on_action_pressed() -> void:
	# Если карточка уже показана, значит это кнопка "ЗАБРАТЬ В КЛУБ"
	if revealed_card_ui != null and revealed_card_ui.visible:
		_reset_store_ui()
		return

	# ИНАЧЕ ЭТО ПОКУПКА ПАКА
	if user_profile == null:
		result_label.text = "❌ Профиль игрока недоступен."
		return

	if club_manager == null:
		result_label.text = "❌ Менеджер клуба недоступен."
		return

	if not user_profile.spend_coins(PACK_PRICE):
		result_label.text = "❌ Недостаточно монет!\nНужно: " + str(PACK_PRICE) + " монет."
		return

	_update_coins()

	var rarity := _get_random_rarity()
	print("Пак: выпала редкость ", rarity)

	var random_data: Dictionary = PlayerDatabase.get_random_player_by_rarity(rarity)

	if random_data.is_empty():
		print("Пак: редкость ", rarity, " не имеет игроков в базе. Ищем любого...")
		random_data = PlayerDatabase.get_random_player()
		if random_data.is_empty():
			result_label.text = "❌ В базе игроков нет доступных игроков."
			return
		rarity = str(random_data.get("rarity", "BRONZE"))

	# Создаём и наполняем карточку
	var card := PlayerCard.new()
	card.id = str(random_data.get("id", ""))
	card.player_name = str(random_data.get("name", ""))
	card.rating = int(random_data.get("rating", 75))
	card.position = str(random_data.get("pos", "FWD"))
	card.club = str(random_data.get("club", ""))
	card.nation = str(random_data.get("nation", ""))
	card.rarity = rarity
	
	# Переносим статы, чтобы они отобразились на CardUI
	card.pace = int(random_data.get("pace", 0))
	card.shooting = int(random_data.get("shooting", 0))
	card.passing = int(random_data.get("passing", 0))
	card.dribbling = int(random_data.get("dribbling", 0))
	card.defending = int(random_data.get("defending", 0))
	card.physical = int(random_data.get("physical", 0))

	club_manager.add_card_to_club(card)
	print("Пак: выпал игрок ", card.player_name, " [", card.rarity, "]")

	# ПОКАЗЫВАЕМ КАРТОЧКУ
	revealed_card_ui.setup(card)
	revealed_card_ui.visible = true
	
	# СКРЫВАЕМ ПАК И ШАНСЫ
	pack_panel.visible = false
	if chances_label != null:
		chances_label.visible = false

	result_label.text = "🎉 ПОЗДРАВЛЯЕМ!\nВы получили нового игрока в свой клуб."

	# МЕНЯЕМ КНОПКУ НА "ЗАБРАТЬ"
	action_button.text = "✅ ЗАБРАТЬ В КЛУБ"
	_apply_button_style(action_button, Color(0.15, 0.55, 0.25)) # Зелёный цвет

# ============================================================
# СБРОС ИНТЕРФЕЙСА МАГАЗИНА
# ============================================================
func _reset_store_ui() -> void:
	if revealed_card_ui != null:
		revealed_card_ui.visible = false
	
	if pack_panel != null:
		pack_panel.visible = true
		
	if chances_label != null:
		chances_label.visible = true

	result_label.text = "Выберите пак и получите нового игрока."
	
	action_button.text = "📦 ОТКРЫТЬ ПАК"
	_apply_button_style(action_button, Color(0.65, 0.45, 0.08))

# ============================================================
# СТИЛЬ КНОПКИ
# ============================================================
func _apply_button_style(button: Button, background_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = background_color
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(min(background_color.r + 0.06, 1.0), min(background_color.g + 0.06, 1.0), min(background_color.b + 0.06, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(max(background_color.r - 0.04, 0.0), max(background_color.g - 0.04, 0.0), max(background_color.b - 0.04, 0.0))
	button.add_theme_stylebox_override("pressed", pressed)

# ============================================================
# ВОЗВРАТ В ИГРУ
# ============================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://PitchScreen.tscn")
