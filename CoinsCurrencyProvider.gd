class_name CoinsCurrencyProvider
extends "res://CurrencyProvider.gd"

# ============================================================
# РЕАЛИЗАЦИЯ: ВНУТРИИГРОВЫЕ МОНЕТЫ (UserProfile autoload)
# ============================================================
# Сохраняет прежнее поведение StoreScreen: списание через
# UserProfile.spend_coins (с валидацией и сохранением в сейв),
# возврат через UserProfile.add_coins.
# ============================================================

var _user_profile: Node


func _get_profile() -> Node:
	if _user_profile == null:
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			_user_profile = (main_loop as SceneTree).root.get_node_or_null("UserProfile")
	return _user_profile


func get_balance() -> int:
	var profile := _get_profile()
	if profile == null:
		return 0
	return int(profile.coins)


func can_afford(amount: int) -> bool:
	var profile := _get_profile()
	if profile == null:
		return false
	return int(profile.coins) >= amount


func spend(amount: int) -> bool:
	var profile := _get_profile()
	if profile == null:
		return false
	return bool(profile.spend_coins(amount))


func refund(amount: int) -> void:
	var profile := _get_profile()
	if profile == null:
		return
	profile.add_coins(amount)


func provider_name() -> String:
	return "coins"
