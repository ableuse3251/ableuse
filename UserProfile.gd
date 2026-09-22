extends Node

var coins: int = 1000


func _ready() -> void:
	SaveManager.load_game()

	coins = SaveManager.get_coins(1000)
	_apply_volume()

	print("UserProfile: загружен баланс ", coins, " монет")


func _apply_volume() -> void:
	apply_volume(SaveManager.get_master_volume())


# Единая точка применения громкости к AudioServer.
# Используется при старте игры и на экране настроек.
func apply_volume(volume: float) -> void:
	var clamped: float = clampf(volume, 0.0, 1.0)
	var bus_idx: int = AudioServer.get_bus_index("Master")
	if bus_idx < 0:
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clamped))
	AudioServer.set_bus_mute(bus_idx, clamped <= 0.001)


func add_coins(amount: int) -> void:
	if amount <= 0:
		print("Отрицательная или нулевая сумма начисления отклонена: ", amount)
		return

	coins += amount

	print("Баланс обновлен: ", coins, " монет")

	SaveManager.set_coins(coins)


func spend_coins(amount: int) -> bool:
	if amount <= 0:
		print("Отрицательная или нулевая сумма списания отклонена: ", amount)
		return false

	if coins >= amount:
		coins -= amount
		coins = max(0, coins)

		print("Покупка совершена! Остаток: ", coins, " монет")

		SaveManager.set_coins(coins)

		return true

	print("Недостаточно монет!")
	return false
