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

		if card != null:
			available_cards.append(card)

	print(
		"CardPool: готово. Доступно карточек: ",
		available_cards.size()
	)


# ============================================================
# СОЗДАНИЕ НОВОЙ КАРТОЧКИ
# ============================================================
func _create_card() -> CardUI:
	var card: CardUI = card_ui_scene.instantiate() as CardUI

	if card == null:
		push_error("CardPool: не удалось создать CardUI.")
		return null

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

	if not available_cards.is_empty():
		card = available_cards.pop_back()
	else:
		if active_cards.size() < MAX_POOL_SIZE:
			card = _create_card()
		else:
			push_warning(
				"CardPool: достигнут лимит пула (",
				MAX_POOL_SIZE,
				")"
			)
			return null

	if card == null:
		return null

	card.visible = true
	card.set_process(true)
	card.set_physics_process(true)
	card.set_process_input(true)

	active_cards.append(card)

	return card


# ============================================================
# ОЧИСТКА RUNTIME SIGNAL-ПОДКЛЮЧЕНИЙ
# ============================================================
func _disconnect_card_signals(card: CardUI) -> void:
	if card == null:
		return

	# get_connections() в Godot 4 возвращает обычный Array.
	# Поэтому здесь намеренно НЕ используем Array[Dictionary].
	var connections: Array = card.card_selected.get_connections()

	for connection in connections:
		if typeof(connection) != TYPE_DICTIONARY:
			continue

		var connection_data: Dictionary = connection

		if not connection_data.has("callable"):
			continue

		var callable: Callable = connection_data["callable"]

		if callable.is_valid():
			if card.card_selected.is_connected(callable):
				card.card_selected.disconnect(callable)


# ============================================================
# ВЕРНУТЬ КАРТОЧКУ В ПУЛ
# ============================================================
func release_card(card: CardUI) -> void:
	if card == null:
		return

	if not active_cards.has(card):
		push_warning(
			"CardPool: попытка вернуть карточку, "
			+ "которая не находится в активном списке."
		)
		return

	active_cards.erase(card)

	# --------------------------------------------------------
	# КРИТИЧЕСКИЙ МОМЕНТ
	# --------------------------------------------------------
	# CardUI переиспользуется повторно.
	# Поэтому удаляем runtime-подключения card_selected,
	# которые были созданы во время предыдущего использования.
	_disconnect_card_signals(card)

	# Сбрасываем внутреннее состояние карточки.
	card.reset()

	# Сбрасываем состояние Node.
	card.visible = false
	card.set_process(false)
	card.set_physics_process(false)
	card.set_process_input(false)

	# Возвращаем карточку в пул.
	available_cards.append(card)


# ============================================================
# МАССОВО ВЕРНУТЬ ВСЕ АКТИВНЫЕ КАРТОЧКИ
# ============================================================
func release_all_cards() -> void:
	var cards_to_release: Array[CardUI] = active_cards.duplicate()

	for card: CardUI in cards_to_release:
		release_card(card)


# ============================================================
# ИНФОРМАЦИЯ О ПУЛЕ
# ============================================================
func get_active_count() -> int:
	return active_cards.size()


func get_available_count() -> int:
	return available_cards.size()
