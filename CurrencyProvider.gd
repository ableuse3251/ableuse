class_name CurrencyProvider
extends RefCounted

# ============================================================
# ABSTRACTION: ИСТОЧНИК ВАЛЮТЫ (ИНТЕРФЕЙС)
# ============================================================
# StoreScreen и другие потребители работают ТОЛЬКО с этим
# интерфейсом. Сейчас используется CoinsCurrencyProvider
# (внутриигровые монеты через autoload UserProfile).
# В будущем достаточно реализовать подкласс, например:
#   BillingCurrencyProvider (Google Play Billing / StoreKit)
# — и подменить создание провайдера в StoreScreen._ready().
# ============================================================

# Текущий баланс в минимальных единицах валюты.
func get_balance() -> int:
	return 0


# Может ли игрок позволить себе покупку на amount?
func can_afford(amount: int) -> bool:
	return false


# Списать amount. true — успех, false — недостаточно средств/отказ.
func spend(amount: int) -> bool:
	return false


# Вернуть amount игроку (откат неудавшейся покупки).
func refund(amount: int) -> void:
	pass


# Человекочитаемое имя провайдера (для логов/UI).
func provider_name() -> String:
	return "none"
