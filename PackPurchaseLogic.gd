class_name PackPurchaseLogic
extends RefCounted

# ============================================================
# ЛОГИКА ПОКУПКИ ПАКА (ЧТО ВЫДАЁТСЯ)
# ============================================================
# Отвечает только на вопрос «что игрок получает за пак»:
# редкость → карта → резервный поиск. Никакой работы с
# валютой здесь нет (за это отвечает CurrencyProvider).
#
# database — источник карт (по умолчанию autoload CardDatabase,
# для тестов можно подставить заглушку с теми же методами:
#   get_random_player_by_rarity(rarity: String) -> PlayerCard
#   get_random_player() -> PlayerCard)
# ============================================================

const RARITY_BRONZE_CHANCE: float = 55.0
const RARITY_SILVER_CHANCE: float = 85.0
const RARITY_GOLD_CHANCE: float = 97.0
# Выше — ELITE

var database: Object


func _init(source: Object = null) -> void:
	if source != null:
		database = source
	else:
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			database = (main_loop as SceneTree).root.get_node_or_null("CardDatabase")


# Вероятностный ролл редкости (BRONZE/SILVER/GOLD/ELITE).
func roll_rarity() -> String:
	var roll := randf() * 100.0
	if roll < RARITY_BRONZE_CHANCE:
		return "BRONZE"
	elif roll < RARITY_SILVER_CHANCE:
		return "SILVER"
	elif roll < RARITY_GOLD_CHANCE:
		return "GOLD"
	else:
		return "ELITE"


# Полная попытка покупки пака.
# Возвращает Dictionary:
#   success: bool
#   card: PlayerCard (при success == true)
#   rarity: String (выпавшая редкость)
#   used_fallback: bool (true — по выпавшей редкости карт не нашлось)
#   reason: String (человекочитаемая причина отказа, при success == false)
func purchase_pack() -> Dictionary:
	if database == null:
		return {"success": false, "card": null, "rarity": "", "used_fallback": false, "reason": "База игроков недоступна."}

	var rarity := roll_rarity()

	# Карта сознательно нетипизирована: провайдер базы может быть
	# подменён в тестах (duck-typing), а StoreScreen приводит к PlayerCard.
	var card = null
	if database.has_method("get_random_player_by_rarity"):
		card = database.get_random_player_by_rarity(rarity)

	var used_fallback := false
	if card == null:
		# Резервный поиск, если в выпавшей редкости нет карт
		used_fallback = true
		if database.has_method("get_random_player"):
			card = database.get_random_player()

	if card == null:
		return {"success": false, "card": null, "rarity": rarity, "used_fallback": used_fallback, "reason": "В базе игроков нет доступных карт."}

	return {"success": true, "card": card, "rarity": rarity, "used_fallback": used_fallback, "reason": ""}
