class_name SquadPlayerDetailsController
extends RefCounted

# ============================================================
# ДЕТАЛИ ВЫБРАННОГО ИГРОКА / ПОПАП (КОМПОНЕНТ SQUADSCREEN)
# ============================================================
# Показ/скрытие pop-up карточки игрока на поле:
# позиционирование у слота, операции «Заменить» и
# «Убрать из состава», согласованное с field_controller
# и player_selector.
# ============================================================

var screen: SquadScreen

var popup_slot_index: int = -1


func show_popup(slot_index: int) -> void:
	popup_slot_index = slot_index

	var slot_pos: Vector2 = screen.field_controller.get_slot_position(slot_index)

	var popup_x: float = slot_pos.x + 50
	var popup_y: float = slot_pos.y - 60

	if popup_x + 180 > screen.size.x:
		popup_x = slot_pos.x - 200

	if popup_y < 70:
		popup_y = 70

	if popup_y + 100 > screen.size.y - 170:
		popup_y = screen.size.y - 270

	screen.card_popup.position = Vector2(popup_x, popup_y)
	screen.card_popup.visible = true


func hide_popup() -> void:
	screen.card_popup.visible = false
	popup_slot_index = -1


func on_replace_pressed() -> void:
	hide_popup()

	# Сохраняем поведение оригинального SquadScreen 1:1:
	# hide() сбрасывает popup_slot_index, поэтому условие ниже
	# в исходном коде заведомо ложно (кнопка «Заменить» не
	# открывала селектор). Не меняем поведение при рефакторинге.
	if popup_slot_index >= 0 and popup_slot_index < screen.formation_slots.size():
		screen.player_selector.open_selector(
			screen.formation_slots[popup_slot_index].position,
			popup_slot_index
		)


func on_remove_pressed() -> void:
	var slot_idx := popup_slot_index
	hide_popup()

	if slot_idx < 0:
		return

	var lineup: Array[PlayerCard] = ClubManager.get_starting_lineup()

	if slot_idx < lineup.size() and lineup[slot_idx] != null:
		var card: PlayerCard = lineup[slot_idx]
		ClubManager.remove_player_from_lineup(card)
		print("Игрок ", card.player_name, " убран из состава")
		screen._refresh_squad()