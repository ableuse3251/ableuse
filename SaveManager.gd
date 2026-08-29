extends Node

# ============================================================
# ПУТЬ И ДАННЫЕ
# ============================================================

const SAVE_PATH: String = "user://save_game.json"

var save_data: Dictionary = {
	"coins": 1000,
	"club_cards": [],
	"starting_lineup": []
}

# ============================================================
# ЗАГРУЗКА ИГРЫ
# ============================================================

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
		
		# Защита от старых сохранений
		if not save_data.has("starting_lineup"):
			save_data["starting_lineup"] = []
		if not save_data.has("club_cards"):
			save_data["club_cards"] = []
		if not save_data.has("coins"):
			save_data["coins"] = 1000

		print("SaveManager: сохранение загружено.")
	else:
		print("SaveManager: файл сохранения повреждён. Используются начальные данные.")

# ============================================================
# СОХРАНЕНИЕ
# ============================================================

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("SaveManager: НЕ удалось создать файл сохранения.")
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("SaveManager: игра сохранена.")

# ============================================================
# КОЛЛЕКЦИЯ КАРТОЧЕК (ОПТИМИЗИРОВАНО)
# ============================================================

func set_club_cards(cards: Array) -> void:
	var cards_data: Array = []
	for card in cards:
		if not card is PlayerCard:
			continue
		# ОПТИМИЗАЦИЯ: Сохраняем ТОЛЬКО ID. 
		# Все остальные данные подтягиваются из CardDatabase при загрузке.
		cards_data.append(card.id)
	
	save_data["club_cards"] = cards_data
	save_game()

func get_club_cards() -> Array:
	return save_data.get("club_cards", [])

# ============================================================
# СТАРТОВЫЙ СОСТАВ
# ============================================================

func set_starting_lineup(lineup: Array) -> void:
	var lineup_data: Array = []
	for card in lineup:
		if not card is PlayerCard:
			continue
		lineup_data.append({"id": card.id})
	
	save_data["starting_lineup"] = lineup_data
	save_game()

func get_starting_lineup() -> Array:
	return save_data.get("starting_lineup", [])

# ============================================================
# БАЛАНС (С ОБРАТНОЙ СОВМЕСТИМОСТЬЮ)
# ============================================================

func set_coins(value: int) -> void:
	save_data["coins"] = value
	save_game()

func get_coins(default_value: int = 1000) -> int:
	if save_data.has("coins"):
		return int(save_data["coins"])
	return default_value

func add_coins(amount: int) -> void:
	save_data["coins"] = get_coins() + amount
	save_game()

func spend_coins(amount: int) -> bool:
	var current: int = get_coins()
	if current >= amount:
		save_data["coins"] = current - amount
		save_game()
		return true
	return false
