extends SceneTree
# ================================================================
# СКАНЕР ОСТАТКОВ ЛОКАЛИЗАЦИИ (не входит в игровой код)
# Находит строковые литералы с кириллицей, которые НЕ обёрнуты в tr()
# и НЕ являются dev-логами (print/printerr/push_error/push_warning/...).
# Отчёт: res://scan_literals.txt (UTF-8).
# ================================================================

const REPORT_PATH := "res://scan_literals.txt"
const SCAN_DIRS := ["res://", "res://tests/"]
const DEVLOG_CALLS := [
	"print(", "printerr(", "print_verbose(", "push_error(", "push_warning(",
]
const SKIP_FILES := [
	"scan_i18n.gd", "audit_i18n.gd", "check_scripts.gd",
	"run_tests.gd", "run_tests_managers.gd", "run_tests_store.gd",
	"run_tests_i18n.gd", "run_tests_match.gd",
]

func _initialize() -> void:
	var out: Array[String] = []
	out.append("=== НЕЛОКАЛИЗОВАННЫЕ ЛИТЕРАЛЫ (кириллица) ===")
	out.append("")

	var files := _collect_scripts()
	var total := 0

	for path in files:
		var text := _read_text(path)
		if text.is_empty():
			continue

		var skip_ranges := _devlog_ranges(text)
		var literals := _find_literals(text)

		for lit in literals:
			var start: int = lit["start"]
			if _in_ranges(start, skip_ranges):
				continue
			if _is_localized(text, start):
				continue
			var value: String = lit["text"]
			if not _has_cyrillic(value):
				continue
			var line_no := text.substr(0, start).count("\n") + 1
			out.append(path.get_file() + ":" + str(line_no) + "  \"" + value + "\"")
			total += 1

	out.append("")
	out.append("ИТОГ: " + str(total) + " нелокализованных литералов")

	var f := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(out))
		f.close()

	print("Скан завершён: ", REPORT_PATH, " | найдено: ", total)
	quit(0)

func _collect_scripts() -> Array[String]:
	var out: Array[String] = []
	for d in SCAN_DIRS:
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for f in dir.get_files():
			if f.ends_with(".gd") and not SKIP_FILES.has(f):
				out.append(d + f)
	out.sort()
	return out

func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var t := f.get_as_text()
	f.close()
	return t

# Диапазоны символов, занимаемые вызовами dev-логов целиком.
func _devlog_ranges(text: String) -> Array:
	var ranges: Array = []
	for name in DEVLOG_CALLS:
		var from := 0
		while true:
			var i := text.find(name, from)
			if i < 0:
				break
			var prev := "" if i == 0 else text.substr(i - 1, 1)
			if not _is_ident_char(prev):
				var end := _find_close_paren(text, i + name.length() - 1)
				if end > i:
					ranges.append(Vector2i(i, end))
					from = end
					continue
			from = i + name.length()
	return ranges

func _in_ranges(pos: int, ranges: Array) -> bool:
	for r in ranges:
		if pos >= r.x and pos <= r.y:
			return true
	return false

# Все строковые литералы файла с позициями.
# Поддерживается экранирование \" внутри литерала.
func _find_literals(text: String) -> Array:
	var out: Array = []
	var i := 0
	var n := text.length()
	while i < n:
		var c := text[i]
		if c == "#":
			# комментарий до конца строки
			var nl := text.find("\n", i)
			i = n if nl < 0 else nl + 1
			continue
		if c == "\"":
			var start := i
			var value := ""
			i += 1
			while i < n:
				var d := text[i]
				if d == "\\":
					value += d
					if i + 1 < n:
						value += text[i + 1]
						i += 2
						continue
					i += 1
					continue
				if d == "\"":
					i += 1
					break
				if d == "\n":
					# незакрытый литерал — прерываем
					break
				value += d
				i += 1
			out.append({"start": start, "text": value})
			continue
		i += 1
	return out

# Литерал уже внутри tr("...")?
func _is_localized(text: String, lit_start: int) -> bool:
	var j := lit_start - 1
	while j >= 0 and (text[j] == " " or text[j] == "\t"):
		j -= 1
	if j >= 1 and text[j] == "(" and text[j - 1] == "r":
		if j >= 2 and text[j - 2] == "t":
			return true
	return false

func _has_cyrillic(s: String) -> bool:
	for i in s.length():
		var cp := s.unicode_at(i)
		if cp >= 0x0400 and cp <= 0x04FF:
			return true
	return false

func _is_ident_char(c: String) -> bool:
	if c.is_empty():
		return false
	return c == "_" or (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")

# Индекс закрывающей скобки для '(' на позиции open_idx, с учётом строк.
func _find_close_paren(text: String, open_idx: int) -> int:
	var depth := 0
	var in_str := false
	var esc := false
	var j := open_idx
	while j < text.length():
		var c := text[j]
		if in_str:
			if esc:
				esc = false
			elif c == "\\":
				esc = true
			elif c == "\"":
				in_str = false
		else:
			if c == "\"":
				in_str = true
			elif c == "(":
				depth += 1
			elif c == ")":
				depth -= 1
				if depth == 0:
					return j
		j += 1
	return -1
