extends SceneTree

# ============================================================
# ПРОВЕРКА: все скрипты проекта парсятся (нет Parse Error)
# ============================================================
# Запуск: godot --headless -s tests/check_scripts.gd --path .
# Возврат: 0 — все ок, 1 — есть неразобранные скрипты.
# ============================================================

func _initialize() -> void:
	var files: Array = []
	_collect("res://", files)
	files.sort()

	var bad: Array = []
	for f in files:
		var res: Variant = load(f)
		if res == null:
			bad.append(f)

	print("=== ПРОВЕРКА ЗАГРУЗКИ СКРИПТОВ ===")
	print("Проверено файлов: ", files.size())
	print("Не загрузилось: ", bad.size())
	for b in bad:
		print("  ОШИБКА: ", b)
	print("=== ИТОГ: %s ===" % ("OK" if bad.is_empty() else "ПРОВАЛ"))
	quit(0 if bad.is_empty() else 1)


func _collect(path: String, out: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for f in dir.get_files():
		if f.ends_with(".gd"):
			out.append(path.path_join(f))
	for d in dir.get_directories():
		if d.begins_with("."):
			continue
		_collect(path.path_join(d), out)
