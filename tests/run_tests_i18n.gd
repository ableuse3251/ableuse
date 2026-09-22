extends SceneTree

# ============================================================
# ПРОВЕРКА ЛОКАЛИЗАЦИИ (после импорта CSV Godot)
# ============================================================
# Запуск: godot --headless -s tests/run_tests_i18n.gd --path .
# ============================================================

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	print("=== ТЕСТ ЛОКАЛИЗАЦИИ ===")

	# 1. Переводы подключены к TranslationServer
	var translations: Array = TranslationServer.get_translations()
	_assert(not translations.is_empty(), "Переводы загружены в TranslationServer (найдено: %d)" % translations.size())

	# 2. tr() по ключам из CSV возвращает русский текст (identity-маппинг)
	_assert(TranslationServer.translate("МАГАЗИН") == "МАГАЗИН", "Ключ 'МАГАЗИН' переводится")
	_assert(TranslationServer.translate("ЗОЛОТОЙ ПАК") == "ЗОЛОТОЙ ПАК", "Ключ 'ЗОЛОТОЙ ПАК' переводится")
	_assert(TranslationServer.translate("← Домой") == "← Домой", "Ключ '← Домой' переводится")
	_assert(TranslationServer.translate("Нужно: %s монет.") == "Нужно: %s монет.", "Ключ с плейсхолдером %s переводится")
	_assert(TranslationServer.translate("Сыгранность: ") == "Сыгранность: ", "Ключ с хвостовым пробелом сохранён")

	# 3. Отсутствующий ключ возвращается как есть (graceful fallback)
	_assert(TranslationServer.translate("НЕСУЩЕСТВУЮЩИЙ КЛЮЧ") == "НЕСУЩЕСТВУЮЩИЙ КЛЮЧ", "Незнакомый ключ возвращается без изменений")

	# 4. Формат-строка после tr() даёт идентичный исходный результат
	var formatted: String = TranslationServer.translate("ШАГ %s ИЗ %s") % ["1", "6"]
	_assert(formatted == "ШАГ 1 ИЗ 6", "Формат 'ШАГ %s ИЗ %s' => 'ШАГ 1 ИЗ 6'")

	print("=== ИТОГ: %s (%d/%d проверок) ===" % ["OK" if failures == 0 else "ПРОВАЛ", checks - failures, checks])
	quit(0 if failures == 0 else 1)


func _assert(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("  [PASS] " + message)
	else:
		failures += 1
		print("  [FAIL] " + message)
