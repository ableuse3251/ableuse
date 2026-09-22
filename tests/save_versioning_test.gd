extends Node

# ============================================================
# ТЕСТ: версионирование и миграции save-файла (SaveManager)
# ============================================================
# Запуск (headless, из папки проекта):
#   godot --headless --path . res://tests/SaveVersioningTest.tscn
# Код возврата: 0 — все проверки пройдены, 1 — есть провалы.
#
# Тест запускается как сцена (а не через -s), потому что ему нужны
# автолоады (SaveManager). На диск тест НЕ пишет: save_game() не
# вызывается, поэтому реальный user://save.json не изменяется.
# ============================================================

var failures: int = 0
var checks: int = 0


func _ready() -> void:
	print("============================================================")
	print("ТЕСТ ВЕРСИОНИРОВАНИЯ И МИГРАЦИЙ SAVE-ФАЙЛА")
	print("============================================================")

	_test_default_data_has_version()
	_test_legacy_v0_upgrade()
	_test_current_version_noop()
	_test_future_version_kept()
	_test_invalid_version_is_zero()

	print("============================================================")
	if failures == 0:
		print("ИТОГ: OK — все проверки пройдены (%d assertions)" % checks)
	else:
		print("ИТОГ: ПРОВАЛЕНО проверок: %d из %d" % [failures, checks])
	print("============================================================")
	print("### RESULT: %s (failures=%d checks=%d) ###" % ["OK" if failures == 0 else "FAIL", failures, checks])

	get_tree().quit(0 if failures == 0 else 1)


func _assert(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("  [OK]   ", message)
	else:
		failures += 1
		print("  [FAIL] ", message)


func _current_version() -> int:
	return int(SaveManager._default_save_data().get("save_version", -1))


# Данные «с нуля» содержат актуальную версию формата.
func _test_default_data_has_version() -> void:
	print("- дефолтные данные")
	var data: Dictionary = SaveManager._default_save_data()
	_assert(int(data.get("save_version", -1)) == _current_version(), "в дефолтах актуальный save_version")
	_assert(data.has("coins"), "в дефолтах есть coins")
	_assert(data.has("master_volume"), "в дефолтах есть master_volume")


# Легаси-сейв (v0, без save_version) мигрирует: данные сохраняются,
# недостающие поля дополняются значениями по умолчанию.
func _test_legacy_v0_upgrade() -> void:
	print("- легаси v0 -> текущая версия")
	SaveManager.save_data = {"coins": 250, "club_cards": []}

	var changed: bool = SaveManager._upgrade_save_data()
	_assert(changed, "миграция сообщила об изменениях")
	_assert(SaveManager._get_save_version() == _current_version(), "save_version стал актуальным")
	_assert(SaveManager.get_coins() == 250, "существующие монеты не потеряны")
	_assert(SaveManager.save_data.has("starting_lineup"), "добавлен starting_lineup")
	_assert(SaveManager.save_data.has("substitutes"), "добавлен substitutes")
	_assert(SaveManager.save_data.has("formation"), "добавлена formation")
	_assert(SaveManager.save_data.has("onboarding_completed"), "добавлен onboarding_completed")
	_assert(SaveManager.save_data.has("master_volume"), "добавлен master_volume")

	# Идемпотентность: повторный запуск ничего не меняет.
	var changed_again: bool = SaveManager._upgrade_save_data()
	_assert(not changed_again, "повторная миграция не требуется (идемпотентность)")


# Сейв актуальной версии миграции не требует.
func _test_current_version_noop() -> void:
	print("- актуальная версия без изменений")
	SaveManager.save_data = SaveManager._default_save_data()
	var changed: bool = SaveManager._upgrade_save_data()
	_assert(not changed, "миграция не запускается для текущей версии")


# Сейв из более новой сборки: данные и номер версии не портим.
func _test_future_version_kept() -> void:
	print("- сейв из будущей версии")
	SaveManager.save_data = {"save_version": 99, "coins": 5, "future_field": true}
	var changed: bool = SaveManager._upgrade_save_data()
	_assert(not changed, "миграция пропущена для новой версии")
	_assert(SaveManager._get_save_version() == 99, "номер версии сохранён")
	_assert(SaveManager.save_data.get("future_field") == true, "неизвестное поле не потеряно")


# Мусор/отсутствие save_version трактуется как легаси (v0).
func _test_invalid_version_is_zero() -> void:
	print("- мусор в save_version")
	SaveManager.save_data = {"save_version": "abc", "coins": 7}
	_assert(SaveManager._get_save_version() == 0, "некорректная версия => 0")

	SaveManager.save_data = {"coins": 7}
	_assert(SaveManager._get_save_version() == 0, "отсутствующая версия => 0")

	SaveManager.save_data = {"save_version": 1.0}
	_assert(SaveManager._get_save_version() == 1, "число с плавающей точкой читается")
