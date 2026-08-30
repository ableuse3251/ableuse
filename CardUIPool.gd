extends Node

# ============================================================
# НАСТРОЙКИ ПУЛА
# ============================================================
const INITIAL_POOL_SIZE: int = 30
const MAX_POOL_SIZE: int = 100

var card_ui_scene: PackedScene = preload("res://CardUI.tscn")

# ============================================================
# ПУЛ ОБЪЕКТОВ
# ============================================================
var available_cards: Array[CardUI] = []
var active_cards: Array[CardUI] = []

# ============================================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================================
func _ready() -> void:
	_preload_cards()

func _preload_cards() -> void:
	print("CardPool: предзагрузка ", INITIAL_POOL_SIZE, " карточек...")
	for i in range(INITIAL_POOL_SIZE):
		var card: CardUI = _create_card()
		if card:
			available_cards.append(card)
	print("CardPool: готово. Доступно карточек: ", available_cards.size())

# ============================================================
# СОЗДАНИЕ НОВОЙ КАРТОЧКИ
# ============================================================
func _create_card() -> CardUI:
	var card: CardUI = card_ui_scene.instantiate()
	if card:
		add_child(card)
		card.visible = false
		card.set_process(false)
		card.set_physics_process(false)
		card.set_process_input(false)
	return card

# ============================================================
# ПОЛУЧИТЬ КАРТОЧКУ ИЗ ПУЛА
# ============================================================
func acquire_card() -> CardUI:
	var card: CardUI = null
	
	if available_cards.size() > 0:
		card = available_cards.pop_back()
	else:
		if active_cards.size() < MAX_POOL_SIZE:
			card = _create_card()
		else:
			push_warning("CardPool: достигнут лимит пула (", MAX_POOL_SIZE, ")")
			return null
	
	if card:
		card.visible = true
		card.set_process(true)
		card.set_physics_process(true)
		card.set_process_input(true)
		active_cards.append(card)
	
	return card

# ============================================================
# ВЕРНУТЬ КАРТОЧКУ В ПУЛ
# ============================================================
func release_card(card: CardUI) -> void:
	if card == null:
		return
	
	if not active_cards.has(card):
		push_warning("CardPool: попытка вернуть карточку, которая не в активном списке")
		return
	
	active_cards.erase(card)
	
	# Сбрасываем состояние карточки
	if card.has_method("reset"):
		card.reset()
	
	card.visible = false
	card.set_process(false)
	card.set_physics_process(false)
	card.set_process_input(false)
	
	available_cards.append(card)

# ============================================================
# МАССОВЫЕ ОПЕРАЦИИ
# ============================================================
func release_all_cards() -> void:
	for card in active_cards.duplicate():
		release_card(card)
	active_cards.clear()

func get_active_count() -> int:
	return active_cards.size()

func get_available_count() -> int:
	return available_cards.size()
