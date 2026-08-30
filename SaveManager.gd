extends Node

const SAVE_PATH: String = "user://save.json"

var save_data: Dictionary = {
	"coins": 1000,
	"club_cards": [],
	"starting_lineup": [],
	"substitutes": [],
	"formation": "4-4-2"
}

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: сохранение не найдено. Используются начальные данные.")
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("SaveManager: не удалось открыть файл сохранения.")
		return
	
	var content: String = file.get_as_text()
	file.close()
	
	var parsed_data = JSON.parse_string(content)
	if parsed_data is Dictionary:
		save_data = parsed_data
		if not save_data.has("starting_lineup"):
			save_data["starting_lineup"] = []
		if not save_data.has("club_cards"):
			save_data["club_cards"] = []
		if not save_data.has("substitutes"):
			save_data["substitutes"] = []
		if not save_data.has("coins"):
			save_data["coins"] = 1000
		if not save_data.has("formation"):
			save_data["formation"] = "4-4-2"
		print("SaveManager: сохранение загружено.")
	else:
		print("SaveManager: файл сохранения повреждён. Используются начальные данные.")

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("SaveManager: НЕ удалось создать файл сохранения.")
		return
	
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("SaveManager: игра сохранена.")

func set_coins(value: int) -> void:
	save_data["coins"] = value
	save_game()

func get_coins(default_value: int = 1000) -> int:
	if save_data.has("coins"):
		return int(save_data["coins"])
	return default_value

func set_club_cards(cards: Array) -> void:
	var cards_data: Array = []
	for card in cards:
		if not card is PlayerCard:
			continue
		var card_data: Dictionary = {
			"id": card.id,
			"player_name": card.player_name,
			"rating": card.rating,
			"position": card.position,
			"club": card.club,
			"nation": card.nation,
			"rarity": card.rarity,
			"pace": card.pace,
			"shooting": card.shooting,
			"passing": card.passing,
			"dribbling": card.dribbling,
			"defending": card.defending,
			"physical": card.physical
		}
		cards_data.append(card_data)
	
	save_data["club_cards"] = cards_data
	save_game()
	print("SaveManager: сохранено карт клуба: ", cards_data.size())

func get_club_cards() -> Array:
	if save_data.has("club_cards") and save_data["club_cards"] is Array:
		return save_data["club_cards"]
	return []

func set_starting_lineup(lineup: Array) -> void:
	var lineup_data: Array = []
	for card in lineup:
		if card == null:
			lineup_data.append({"id": ""}) # Пустой слот
		elif card is PlayerCard:
			var player_data: Dictionary = {
				"id": card.id
			}
			lineup_data.append(player_data)
		else:
			lineup_data.append({"id": ""}) # Неизвестный тип
	
	save_data["starting_lineup"] = lineup_data
	save_game()
	print("SaveManager: сохранен стартовый состав: ", lineup_data.size(), " слотов")

func get_starting_lineup() -> Array:
	if save_data.has("starting_lineup") and save_data["starting_lineup"] is Array:
		return save_data["starting_lineup"]
	return []

func set_substitutes(subs: Array) -> void:
	var subs_data: Array = []
	for card in subs:
		if not card is PlayerCard:
			continue
		var player_data: Dictionary = {
			"id": card.id
		}
		subs_data.append(player_data)
	
	save_data["substitutes"] = subs_data
	save_game()
	print("SaveManager: сохранен состав запасных: ", subs_data.size(), " игроков")

func get_substitutes() -> Array:
	if save_data.has("substitutes") and save_data["substitutes"] is Array:
		return save_data["substitutes"]
	return []

func set_formation(formation: String) -> void:
	save_data["formation"] = formation
	save_game()
	print("SaveManager: сохранена схема: ", formation)

func get_formation() -> String:
	if save_data.has("formation") and save_data["formation"] is String:
		return save_data["formation"]
	return "4-4-2"
