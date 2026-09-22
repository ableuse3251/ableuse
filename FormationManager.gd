extends Node

const FORMATIONS_PATH: String = "res://data/formations.json"
var formations_data: Dictionary = {}

func _ready() -> void:
	_load_formations()

func _load_formations() -> void:
	if not FileAccess.file_exists(FORMATIONS_PATH):
		push_error("FormationManager: файл не найден: " + FORMATIONS_PATH)
		UIFeedback.show_error("Не найден файл схем. Используется стандартная расстановка")
		formations_data = _get_default_formations()
		return

	var file := FileAccess.open(FORMATIONS_PATH, FileAccess.READ)
	if file == null:
		push_error("FormationManager: не удалось открыть " + FORMATIONS_PATH)
		UIFeedback.show_error("Не удалось открыть файл схем. Используется стандартная расстановка")
		formations_data = _get_default_formations()
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary and parsed.has("formations"):
		formations_data = parsed["formations"] as Dictionary
		print("FormationManager: загружено схем: ", formations_data.size())
	else:
		push_error("FormationManager: ошибка парсинга JSON или отсутствует ключ 'formations'. Используются стандартные схемы.")
		UIFeedback.show_error("Файл схем повреждён. Используется стандартная схема")
		formations_data = _get_default_formations()

func _get_default_formations() -> Dictionary:
	return {
		"4-4-2": [
			{"position": "GK", "x": 0.50, "y": 0.90},
			{"position": "DEF", "x": 0.18, "y": 0.72}, {"position": "DEF", "x": 0.39, "y": 0.76}, {"position": "DEF", "x": 0.61, "y": 0.76}, {"position": "DEF", "x": 0.82, "y": 0.72},
			{"position": "MID", "x": 0.18, "y": 0.50}, {"position": "MID", "x": 0.39, "y": 0.50}, {"position": "MID", "x": 0.61, "y": 0.50}, {"position": "MID", "x": 0.82, "y": 0.50},
			{"position": "FWD", "x": 0.35, "y": 0.22}, {"position": "FWD", "x": 0.65, "y": 0.22}
		]
	}

func get_all_formations() -> Dictionary:
	return formations_data

func get_formation_slots(formation_name: String) -> Array:
	if formations_data.has(formation_name):
		var slots: Array = formations_data[formation_name]
		return slots
	
	push_warning("FormationManager: схема '", formation_name, "' не найдена. Возвращаю 4-4-2.")
	UIFeedback.show_info("Схема не найдена — используется 4-4-2")
	var default_slots: Array = formations_data.get("4-4-2", [])
	return default_slots

# ============================================================
# ВАЛИДАЦИЯ СЛОТОВ ФОРМАЦИИ
# ============================================================
# Слот валиден, если это Dictionary с ключами:
#   position: String (не пустой)
#   x, y: числа в диапазоне 0.0..1.0 (нормализованные координаты)
# ============================================================

func validate_formation_slots(slots: Array) -> bool:
	if slots == null or slots.is_empty():
		return false
	
	for slot in slots:
		if not slot is Dictionary:
			return false
		var pos = slot.get("position", "")
		if not pos is String or str(pos).strip_edges().is_empty():
			return false
		var x = slot.get("x", -1.0)
		var y = slot.get("y", -1.0)
		if not (x is float or x is int) or not (y is float or y is int):
			return false
		if float(x) < 0.0 or float(x) > 1.0 or float(y) < 0.0 or float(y) > 1.0:
			return false
	
	return true
