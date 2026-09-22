class_name SquadPlayerSelectorController
extends RefCounted

# ============================================================
# ВЫБОР ИГРОКА (КОМПОНЕНТ SQUADSCREEN)
# ============================================================
# Список доступных карточек для слота/запаса: сбор игроков
# клуба ещё не в составе, фильтрация по позиции, вывод карточек
# через CardPool, обработка выбора (в слот / в запасные).
# ============================================================

var screen: SquadScreen


func open_selector(required_position: String, slot_index: int = -1) -> void:
	for child in screen.selection_grid.get_children():
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
		screen.selection_overlay.visible = false
		return

	for card in available_players:
		var card_node: CardUI = CardPool.acquire_card()

		if card_node == null:
			push_warning("SquadScreen: не удалось получить карточку из пула для выбора")
			UIFeedback.show_error(tr("Не удалось отобразить карточку игрока"))
			continue

		if card_node.get_parent() != screen.selection_grid:
			card_node.reparent(screen.selection_grid)

		card_node.set_compact_mode()
		card_node.setup(card)

		if required_position == "SUBSTITUTE":
			# card_selected уже передаёт PlayerCard.
			# bind(card) здесь был ошибкой: он добавлял второй аргумент.
			card_node.card_selected.connect(on_player_selected_for_sub)
		else:
			# card_selected передаёт PlayerCard первым аргументом.
			# Поэтому bind нужен только для slot_index.
			card_node.card_selected.connect(
				on_player_selected_for_slot.bind(slot_index)
			)

	screen.selection_overlay.visible = true


func on_player_selected_for_slot(card: PlayerCard, slot_index: int) -> void:
	ClubManager.set_player_in_lineup(slot_index, card)
	screen.selection_overlay.visible = false
	screen._refresh_squad()


func on_player_selected_for_sub(card: PlayerCard) -> void:
	ClubManager.add_player_to_substitutes(card)
	screen.selection_overlay.visible = false
	screen._refresh_squad()