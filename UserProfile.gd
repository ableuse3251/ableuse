extends Node

var coins: int = 1000


func _ready() -> void:
	SaveManager.load_game()
	
	coins = SaveManager.get_coins(1000)
	
	print("UserProfile: загружен баланс ", coins, " монет")


func add_coins(amount: int) -> void:
	coins += amount
	
	print("Баланс обновлен: ", coins, " монет")
	
	SaveManager.set_coins(coins)


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		
		print("Покупка совершена! Остаток: ", coins, " монет")
		
		SaveManager.set_coins(coins)
		
		return true
	
	print("Недостаточно монет!")
	return false
