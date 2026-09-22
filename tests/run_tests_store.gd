extends SceneTree

# ============================================================
# РўР•РЎРўРћР’Р«Р™ Р РђРќРќР•Р : CurrencyProvider + PackPurchaseLogic
# ============================================================
# Р—Р°РїСѓСЃРє (headless, РёР· РїР°РїРєРё РїСЂРѕРµРєС‚Р°):
#   godot --headless -s tests/run_tests_store.gd
# РљРѕРґ РІРѕР·РІСЂР°С‚Р°: 0 вЂ” СѓСЃРїРµС…, 1 вЂ” РµСЃС‚СЊ РїР°РґРµРЅРёСЏ.
# ============================================================

var failures: int = 0
var checks: int = 0


const CurrencyProviderBase := preload("res://CurrencyProvider.gd")
const CoinsCurrencyProviderScript := preload("res://CoinsCurrencyProvider.gd")
const PackPurchaseLogicScript := preload("res://PackPurchaseLogic.gd")

class StubCard:
	# Р—Р°РіР»СѓС€РєР° РєР°СЂС‚С‹: PackPurchaseLogic РІРѕР·РІСЂР°С‰Р°РµС‚ РµС‘ РєР°Рє РµСЃС‚СЊ.
	var name: String

	func _init(n: String) -> void:
		name = n


class StubDatabase extends RefCounted:
	# Р—Р°РіР»СѓС€РєР° CardDatabase (duck-typing С‚РµС… Р¶Рµ РґРІСѓС… РјРµС‚РѕРґРѕРІ).
	var by_rarity: StubCard = null
	var random: StubCard = null

	func get_random_player_by_rarity(_rarity: String) -> StubCard:
		return by_rarity

	func get_random_player() -> StubCard:
		return random


class FakeCurrencyProvider extends CurrencyProviderBase:
	# РџРѕРґРјРµРЅРЅС‹Р№ РїСЂРѕРІР°Р№РґРµСЂ: РїСЂРѕРІРµСЂСЏРµС‚, С‡С‚Рѕ StoreScreen-СЃР»РѕР№
	# СЂР°Р±РѕС‚Р°РµС‚ СЃ Р›Р®Р‘РћР™ СЂРµР°Р»РёР·Р°С†РёРµР№ РёРЅС‚РµСЂС„РµР№СЃР°.
	var balance: int = 1000
	var spent_calls: int = 0
	var refund_calls: int = 0
	var allow_spend: bool = true

	func get_balance() -> int:
		return balance

	func can_afford(amount: int) -> bool:
		return balance >= amount

	func spend(amount: int) -> bool:
		if not allow_spend:
			return false
		if balance < amount:
			return false
		balance -= amount
		spent_calls += 1
		return true

	func refund(amount: int) -> void:
		balance += amount
		refund_calls += 1

	func provider_name() -> String:
		return "fake"


func _initialize() -> void:
	print("============================================================")
	print("Р—РђРџРЈРЎРљ РўР•РЎРўРћР’ CURRENCY PROVIDER + PACK PURCHASE LOGIC")
	print("============================================================")

	test_base_provider_defaults()
	test_fake_provider_polymorphism()
	test_purchase_success()
	test_purchase_fallback()
	test_purchase_failure_no_cards()
	test_purchase_failure_no_database()
	test_roll_rarity_valid_values()
	test_coins_provider_roundtrip()

	print("============================================================")
	if failures == 0:
		print("РРўРћР“: OK вЂ” РІСЃРµ РїСЂРѕРІРµСЂРєРё РїСЂРѕР№РґРµРЅС‹ (%d assertions)" % checks)
	else:
		print("РРўРћР“: РџР РћР’РђР›Р•РќРћ РїСЂРѕРІРµСЂРѕРє: %d РёР· %d" % [failures, checks])
	print("============================================================")

	quit(0 if failures == 0 else 1)


func _assert(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("  [PASS] " + message)
	else:
		failures += 1
		print("  [FAIL] " + message)


# ============================================================
# Р‘РђР—РћР’Р«Р™ РџР РћР’РђР™Р”Р•Р : Р‘Р•Р—РћРџРђРЎРќР«Р• РЈРњРћР›Р§РђРќРРЇ
# ============================================================

func test_base_provider_defaults() -> void:
	print("\n[РўР•РЎРў] Р‘Р°Р·РѕРІС‹Р№ CurrencyProvider: СѓРјРѕР»С‡Р°РЅРёСЏ Р±РµР·РѕРїР°СЃРЅС‹")
	var base := CurrencyProviderBase.new()
	_assert(base.get_balance() == 0, "Р‘Р°Р»Р°РЅСЃ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ 0")
	_assert(base.can_afford(1) == false, "can_afford РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ false")
	_assert(base.spend(1) == false, "spend РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ false")
	_assert(base.provider_name() == "none", "РРјСЏ РїСЂРѕРІР°Р№РґРµСЂР° РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ 'none'")
	base.refund(1)
	_assert(true, "refund РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ вЂ” no-op (РЅРµ РїР°РґР°РµС‚)")


# ============================================================
# РџРћР›РРњРћР Р¤РР—Рњ: Р›Р®Р‘РђРЇ Р Р•РђР›РР—РђР¦РРЇ Р РђР‘РћРўРђР•Рў РљРђРљ CurrencyProvider
# ============================================================

func test_fake_provider_polymorphism() -> void:
	print("\n[РўР•РЎРў] РџРѕРґРјРµРЅРЅС‹Р№ РїСЂРѕРІР°Р№РґРµСЂ СЂР°Р±РѕС‚Р°РµС‚ С‡РµСЂРµР· РёРЅС‚РµСЂС„РµР№СЃ")
	var provider: CurrencyProviderBase = FakeCurrencyProvider.new()
	_assert(provider.can_afford(500), "Fake: 500 РґРѕСЃС‚СѓРїРЅРѕ РїСЂРё Р±Р°Р»Р°РЅСЃРµ 1000")
	_assert(provider.spend(500), "Fake: СЃРїРёСЃР°РЅРёРµ 500 СѓСЃРїРµС€РЅРѕ")
	_assert(provider.get_balance() == 500, "Fake: Р±Р°Р»Р°РЅСЃ РїРѕСЃР»Рµ СЃРїРёСЃР°РЅРёСЏ 500")
	provider.refund(500)
	_assert(provider.get_balance() == 1000, "Fake: РІРѕР·РІСЂР°С‚ РІРѕСЃСЃС‚Р°РЅР°РІР»РёРІР°РµС‚ Р±Р°Р»Р°РЅСЃ")
	_assert(provider.can_afford(1500) == false, "Fake: 1500 РЅРµРґРѕСЃС‚СѓРїРЅРѕ РїСЂРё Р±Р°Р»Р°РЅСЃРµ 1000")


# ============================================================
# PACK LOGIC: РЈРЎРџР•РЁРќРђРЇ РџРћРљРЈРџРљРђ
# ============================================================

func test_purchase_success() -> void:
	print("\n[РўР•РЎРў] purchase_pack: СѓСЃРїРµС…, РєР°СЂС‚Р° РёР· РІС‹РїР°РІС€РµР№ СЂРµРґРєРѕСЃС‚Рё")
	var card := StubCard.new("Star Player")
	var db := StubDatabase.new()
	db.by_rarity = card
	var logic := PackPurchaseLogicScript.new(db)
	var outcome: Dictionary = logic.purchase_pack()
	_assert(bool(outcome.get("success", false)), "РџРѕРєСѓРїРєР° СѓСЃРїРµС€РЅР°")
	_assert(outcome.get("card") == card, "Р’РѕР·РІСЂР°С‰РµРЅР° РєР°СЂС‚Р° РёР· Р±Р°Р·С‹")
	_assert(str(outcome.get("rarity", "")) in ["BRONZE", "SILVER", "GOLD", "ELITE"], "Р РµРґРєРѕСЃС‚СЊ РІР°Р»РёРґРЅР°: " + str(outcome.get("rarity")))
	_assert(bool(outcome.get("used_fallback", true)) == false, "Fallback РЅРµ РёСЃРїРѕР»СЊР·РѕРІР°Р»СЃСЏ")


# ============================================================
# PACK LOGIC: FALLBACK Р•РЎР›Р Р Р•Р”РљРћРЎРўР¬ РџРЈРЎРўРђ
# ============================================================

func test_purchase_fallback() -> void:
	print("\n[РўР•РЎРў] purchase_pack: fallback РїСЂРё РїСѓСЃС‚РѕР№ СЂРµРґРєРѕСЃС‚Рё")
	var card := StubCard.new("Random Player")
	var db := StubDatabase.new()
	db.by_rarity = null
	db.random = card
	var logic := PackPurchaseLogicScript.new(db)
	var outcome: Dictionary = logic.purchase_pack()
	_assert(bool(outcome.get("success", false)), "РџРѕРєСѓРїРєР° СѓСЃРїРµС€РЅР° С‡РµСЂРµР· fallback")
	_assert(outcome.get("card") == card, "Р’РѕР·РІСЂР°С‰РµРЅР° РєР°СЂС‚Р° РёР· РѕР±С‰РµРіРѕ РїСѓР»Р°")
	_assert(bool(outcome.get("used_fallback", false)), "Р¤Р»Р°Рі used_fallback СѓСЃС‚Р°РЅРѕРІР»РµРЅ")


# ============================================================
# PACK LOGIC: РћРўРљРђР— Р•РЎР›Р РљРђР Рў РќР•Рў Р’РћРћР‘Р©Р•
# ============================================================

func test_purchase_failure_no_cards() -> void:
	print("\n[РўР•РЎРў] purchase_pack: РѕС‚РєР°Р·, РµСЃР»Рё РєР°СЂС‚ РЅРµС‚ РІРѕРІСЃРµ")
	var db := StubDatabase.new()
	var logic := PackPurchaseLogicScript.new(db)
	var outcome: Dictionary = logic.purchase_pack()
	_assert(not bool(outcome.get("success", true)), "РџРѕРєСѓРїРєР° РЅРµ СѓСЃРїРµС€РЅР°")
	_assert(str(outcome.get("reason", "")).length() > 0, "Р•СЃС‚СЊ С‡РµР»РѕРІРµРєРѕС‡РёС‚Р°РµРјР°СЏ РїСЂРёС‡РёРЅР°")
	_assert(outcome.get("card") == null, "РљР°СЂС‚Р° РЅРµ РІС‹РґР°РЅР°")


# ============================================================
# PACK LOGIC: РћРўРљРђР— Р•РЎР›Р Р‘РђР—Рђ РќР•Р”РћРЎРўРЈРџРќРђ
# ============================================================

func test_purchase_failure_no_database() -> void:
	print("\n[РўР•РЎРў] purchase_pack: РѕС‚РєР°Р· РїСЂРё РЅРµРґРѕСЃС‚СѓРїРЅРѕР№ Р±Р°Р·Рµ")
	var logic := PackPurchaseLogicScript.new(null)
	var outcome: Dictionary = logic.purchase_pack()
	_assert(not bool(outcome.get("success", true)), "РџРѕРєСѓРїРєР° РЅРµ СѓСЃРїРµС€РЅР° Р±РµР· Р±Р°Р·С‹")
	_assert(str(outcome.get("reason", "")).length() > 0, "РџСЂРёС‡РёРЅР° РѕС‚РєР°Р·Р° РѕРїРёСЃР°РЅР°")


# ============================================================
# PACK LOGIC: Р РћР›Р› Р Р•Р”РљРћРЎРўР Р’РЎР•Р“Р”Рђ Р’РђР›РР”Р•Рќ
# ============================================================

func test_roll_rarity_valid_values() -> void:
	print("\n[РўР•РЎРў] roll_rarity: 5000 СЂРѕР»Р»РѕРІ С‚РѕР»СЊРєРѕ РІ 4 Р·РЅР°С‡РµРЅРёСЏС…")
	var logic := PackPurchaseLogicScript.new(null)
	var counts := {"BRONZE": 0, "SILVER": 0, "GOLD": 0, "ELITE": 0}
	for i in range(5000):
		var rarity := logic.roll_rarity()
		if not counts.has(rarity):
			_assert(false, "РќРµРІР°Р»РёРґРЅР°СЏ СЂРµРґРєРѕСЃС‚СЊ: " + rarity)
			return
		counts[rarity] = int(counts[rarity]) + 1
	_assert(true, "Р’СЃРµ 5000 СЂРѕР»Р»РѕРІ РІР°Р»РёРґРЅС‹")
	var bronze_share: float = float(counts["BRONZE"]) / 5000.0 * 100.0
	_assert(bronze_share > 50.0 and bronze_share < 60.0, "Р”РѕР»СЏ BRONZE ~55%% (С„Р°РєС‚: %.1f%%)" % bronze_share)
	var elite_share: float = float(counts["ELITE"]) / 5000.0 * 100.0
	_assert(elite_share > 1.0 and elite_share < 5.0, "Р”РѕР»СЏ ELITE ~3%% (С„Р°РєС‚: %.1f%%)" % elite_share)


# ============================================================
# COINS PROVIDER: РЎРџРРЎРђРќРР• + Р’РћР—Р’Р РђРў (РќР•РўРўРћ 0)
# ============================================================

func test_coins_provider_roundtrip() -> void:
	print("\n[РўР•РЎРў] CoinsCurrencyProvider: СЃРїРёСЃР°РЅРёРµ+РІРѕР·РІСЂР°С‚ РЅРµ РјРµРЅСЏСЋС‚ Р±Р°Р»Р°РЅСЃ")
	var provider := CoinsCurrencyProviderScript.new()
	_assert(provider.provider_name() == "coins", "РРјСЏ РїСЂРѕРІР°Р№РґРµСЂР° 'coins'")

	var profile: Node = Engine.get_main_loop().root.get_node_or_null("UserProfile")
	if profile == null:
		_assert(false, "UserProfile autoload РЅРµ РЅР°Р№РґРµРЅ")
		return

	var before: int = int(profile.coins)
	_assert(provider.get_balance() == before, "get_balance СЃРѕРІРїР°РґР°РµС‚ СЃ UserProfile.coins")
	_assert(provider.can_afford(1) == (before >= 1), "can_afford(1) СЃРѕРіР»Р°СЃРѕРІР°РЅ СЃ Р±Р°Р»Р°РЅСЃРѕРј")

	if before >= 1:
		_assert(provider.spend(1), "РЎРїРёСЃР°РЅРёРµ 1 РјРѕРЅРµС‚С‹ СѓСЃРїРµС€РЅРѕ")
		_assert(int(profile.coins) == before - 1, "Р‘Р°Р»Р°РЅСЃ СѓРјРµРЅСЊС€РёР»СЃСЏ СЂРѕРІРЅРѕ РЅР° 1")
		provider.refund(1)
		_assert(int(profile.coins) == before, "Р’РѕР·РІСЂР°С‚ РІРѕСЃСЃС‚Р°РЅРѕРІРёР» Р±Р°Р»Р°РЅСЃ (РёС‚РѕРі РЅРµС‚С‚Рѕ 0)")
	else:
		_assert(not provider.spend(1), "РџСЂРё РЅСѓР»РµРІРѕРј Р±Р°Р»Р°РЅСЃРµ СЃРїРёСЃР°РЅРёРµ РѕС‚РєР»РѕРЅРµРЅРѕ")

