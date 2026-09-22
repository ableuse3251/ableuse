extends Control

const PACK_PRICE: int = 500

var coins_label: Label
var result_label: Label
var buy_button: Button
var back_button: Button

var user_profile: Node
var club_manager: Node

# ============================================================
# СЛОИ ПОКУПКИ
# ============================================================
const CurrencyProviderBase := preload("res://CurrencyProvider.gd")
const CoinsCurrencyProviderScript := preload("res://CoinsCurrencyProvider.gd")
const PackPurchaseLogicScript := preload("res://PackPurchaseLogic.gd")

var currency_provider: CurrencyProviderBase
var pack_logic: PackPurchaseLogicScript

func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_STOP

	user_profile = get_node("/root/UserProfile")
	club_manager = get_node("/root/ClubManager")

	# ============================================================
	# СЛОИ ПОКУПКИ (РЕФАКТОРИНГ ПОД БУДУЩИЙ IAP)
	# ============================================================
	# currency_provider — откуда «деньги» (сейчас монеты, в будущем
	#   Billing-реализация для Google Play Billing/StoreKit).
	# pack_logic — что выдаётся при покупке (редкость/карта).
	# Для перехода на IAP достаточно заменить создание
	# currency_provider ниже; остальной код StoreScreen не меняется.
	currency_provider = CoinsCurrencyProviderScript.new()
	pack_logic = PackPurchaseLogicScript.new()

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
	panel.custom_minimum_size = Vector2(390, 540)
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
	title.text = tr("МАГАЗИН")
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
	# ПАК
	# ============================================================
	var pack_panel := PanelContainer.new()
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
	pack_title.text = tr("ЗОЛОТОЙ ПАК")
	pack_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_title.add_theme_font_size_override("font_size", 21)
	pack_title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.20))
	pack_box.add_child(pack_title)

	var pack_description := Label.new()
	pack_description.text = tr("1 случайный игрок из доступной базы")
	pack_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_description.add_theme_font_size_override("font_size", 13)
	pack_description.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.65))
	pack_box.add_child(pack_description)

	var price_label := Label.new()
	price_label.text = tr("💰 ") + str(PACK_PRICE) + tr(" МОНЕТ")
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	pack_box.add_child(price_label)

	# ============================================================
	# ШАНСЫ
	# ============================================================
	var chances := Label.new()
	chances.text = tr("BRONZE 55%  •  SILVER 30%  •  GOLD 12%  •  ELITE 3%")
	chances.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chances.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chances.add_theme_font_size_override("font_size", 11)
	chances.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.50))
	box.add_child(chances)

	# ============================================================
	# КНОПКА ПОКУПКИ
	# ============================================================
	buy_button = Button.new()
	buy_button.text = tr("📦 ОТКРЫТЬ ПАК")
	buy_button.custom_minimum_size = Vector2(0, 48)
	buy_button.add_theme_font_size_override("font_size", 17)
	buy_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	buy_button.pressed.connect(_on_buy_pressed)
	UIStyleUtils.apply_button_style(buy_button, Color(0.65, 0.45, 0.08))
	box.add_child(buy_button)

	# ============================================================
	# РЕЗУЛЬТАТ
	# ============================================================
	result_label = Label.new()
	result_label.text = tr("Выберите пак и получите нового игрока.")
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.custom_minimum_size = Vector2(0, 65)
	result_label.add_theme_font_size_override("font_size", 13)
	result_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.75))
	box.add_child(result_label)

	# ============================================================
	# НАЗАД
	# ============================================================
	back_button = Button.new()
	back_button.text = tr("← Домой")
	back_button.custom_minimum_size = Vector2(0, 40)
	back_button.add_theme_font_size_override("font_size", 14)
	back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(_on_back_pressed)
	UIStyleUtils.apply_button_style(back_button, Color(0.10, 0.12, 0.17))
	box.add_child(back_button)

func _update_coins() -> void:
	if coins_label == null:
		return
	# Баланс читаем через провайдера — UI не знает, откуда деньги.
	var balance: int = currency_provider.get_balance() if currency_provider != null else 0
	coins_label.text = tr("🪙 ") + str(balance) + tr(" МОНЕТ")

func _on_buy_pressed() -> void:
	if currency_provider == null:
		result_label.text = tr("❌ Платёжная система недоступна.")
		return

	if pack_logic == null:
		result_label.text = tr("❌ Логика паков недоступна.")
		return

	if club_manager == null:
		result_label.text = tr("❌ Менеджер клуба недоступен.")
		return

	if buy_button and buy_button.disabled:
		return

	# ============================================================
	# 1. ПРОВЕРКА И СПИСАНИЕ (ЧЕРЕЗ CURRENCY PROVIDER)
	# ============================================================
	if not currency_provider.can_afford(PACK_PRICE):
		result_label.text = tr("❌ Недостаточно монет!") + "\n" + tr("Нужно: %s монет.") % str(PACK_PRICE)
		return

	if not currency_provider.spend(PACK_PRICE):
		result_label.text = tr("❌ Не удалось списать монеты.")
		return

	# Защита от двойного клика (ставим сразу после успешного списания)
	buy_button.disabled = true

	_update_coins()

	# ============================================================
	# 2. ТОЛЬКО ПОСЛЕ ОПЛАТЫ - ГЕНЕРИРУЕМ НАГРАДУ (PACK LOGIC)
	# ============================================================
	var outcome: Dictionary = pack_logic.purchase_pack()

	if not bool(outcome.get("success", false)):
		result_label.text = "❌ " + str(outcome.get("reason", tr("Ошибка покупки."))) + "\n" + tr("Возврат монет.")
		# Откат: возвращаем оплату через того же провайдера
		currency_provider.refund(PACK_PRICE)
		_update_coins()
		if is_instance_valid(buy_button):
			buy_button.disabled = false
		return

	var card: PlayerCard = outcome.get("card")
	var rarity: String = str(outcome.get("rarity", ""))
	if bool(outcome.get("used_fallback", false)):
		print("Пак: редкость ", rarity, " пуста. Используем случайного игрока.")

	# ============================================================
	# 3. ДОБАВЛЕНИЕ В КЛУБ
	# ============================================================
	club_manager.add_card_to_club(card)

	print("Пак: выпал игрок ", card.player_name, " [", card.rarity, "] (провайдер: ", currency_provider.provider_name(), ")")

	# ============================================================
	# 4. РЕЗУЛЬТАТ
	# ============================================================
	result_label.text = (
		tr("🎉 ВЫ ВЫТАЩИЛИ ИГРОКА!")
		+ "\n\n"
		+ card.player_name
		+ " — "
		+ str(card.rating)
		+ " OVR\n"
		+ card.position
		+ "  •  "
		+ card.club
		+ "\n"
		+ tr("Редкость: ")
		+ card.rarity
		+ "\n\n"
		+ tr("✅ Игрок добавлен в «Мой клуб»!")
	)

	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(buy_button):
		buy_button.disabled = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")
