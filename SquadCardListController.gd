class_name SquadCardListController
extends RefCounted

# ============================================================
# СПИСОК ЗАПАСНЫХ ИГРОКОВ (КОМПОНЕНТ SQUADSCREEN)
# ============================================================
# Управляет списком запасных: обновление карточек из пула,
# подключение сигналов клика, удаление игрока из запаса.
# ============================================================

var screen: SquadScreen

var subs_cards: Array[Node] = []


func refresh_subs() -> void:
	# Очистка: возвращаем все карточки в пул и очищаем список
	for card_node in subs_cards:
		if card_node.get_parent() == screen.subs_container:
			CardPool.release_card(card_node)

	subs_cards.clear()

	var subs: Array[PlayerCard] = ClubManager.get_substitutes()

	for card in subs:
		if card != null:
			var card_node: CardUI = CardPool.acquire_card()

			if card_node == null:
				push_warning("SquadCardListController: не удалось получить карточку из пула")
				UIFeedback.show_error(tr("Не удалось отобразить карточку игрока"))
				continue

			if card_node.get_parent() != screen.subs_container:
				card_node.reparent(screen.subs_container)

			subs_cards.append(card_node)

			card_node.set_compact_mode()
			card_node.setup(card)

			if card_node.card_selected.is_connected(_on_sub_card_clicked):
				card_node.card_selected.disconnect(_on_sub_card_clicked)

			card_node.card_selected.connect(_on_sub_card_clicked.bind(card))


func _on_sub_card_clicked(card: PlayerCard) -> void:
	ClubManager.remove_player_from_substitutes(card)
	print("Игрок ", card.player_name, " убран из запаса")
	screen._refresh_substitutes()