extends SceneTree
# ================================================================
# АУДИТ ЛОКАЛИЗАЦИИ (не входит в игровой код)
# 1. Сверяет ключи tr("...") в коде с translation_strings.csv
# 2. Находит tr() внутри dev-логов (print/push_error/push_warning/...)
# Отчёт пишется в res://i18n_audit.txt (UTF-8).
# ================================================================

const CSV_PATH := "res://translation_strings.csv"
const REPORT_PATH := "res://i18n_audit.txt"

const DEVLOG_CALLS := [
	"print(", "printerr(", "print_verbose(", "push_error(", "push_warning(",
]
const SCAN_DIRS := ["res://", "res://tests/"]

func _initialize() -> void:
	var lines: Array[String] = []

	var csv_keys := _load_csv_keys()
	lines.append("=== АУДИТ ЛОКАЛИЗАЦИИ ===")
	lines.append("Ключей в CSV: " + str(csv_keys.size()))

	var code_keys := {}
	var devlog_hits: Array[String] = []
	var files := _collect_scripts()
	lines.append("Скриптов просканировано: " + str(files.size()))
	lines.append("")

	for path in files:
		var text := _read_text(path)
		if text.is_empty():
			continue
		for key in _extract_tr_keys(text):
			if not code_keys.has(key):
				code_keys[key] = []
			code_keys[key].append(path.get_file())
		devlog_hits.append_array(_find_devlog_tr(path, text))

	# --- 1. Ключи в коде, отсутствующие в CSV -------------------
	var missing: Array[String] = []
	for key in code_keys.keys():
		if not csv_keys.has(key):
			missing.append(key)
	missing.sort()
	lines.append("--- КЛЮЧИ В КОДЕ БЕЗ ПЕРЕВОДА: " + str(missing.size()) + " ---")
	for key in missing:
		lines.append("  [" + ", ".join(code_keys[key]) + "] \"" + key + "\"")
	lines.append("")

	# --- 2. tr() в dev-логах ------------------------------------
	lines.append("--- tr() В DEV-ЛОГАХ: " + str(devlog_hits.size()) + " ---")
	for hit in devlog_hits:
		lines.append("  " + hit)
	lines.append("")

	# --- 3. Неиспользуемые ключи --------------------------------
	var unused: Array[String] = []
	for key in csv_keys.keys():
		if not code_keys.has(key):
			unused.append(key)
	unused.sort()
	lines.append("--- НЕИСПОЛЬЗУЕМЫЕ КЛЮЧИ CSV: " + str(unused.size()) + " ---")
	for key in unused:
		lines.append("  \"" + key + "\"")
	lines.append("")

	# --- 4. Дубликаты -------------------------------------------
	var seen := {}
	var dups: Array[String] = []
	for key in _load_csv_key_list():
		if seen.has(key):
			dups.append(key)
		seen[key] = true
	lines.append("--- ДУБЛИКАТЫ КЛЮЧЕЙ CSV: " + str(dups.size()) + " ---")
	for key in dups:
		lines.append("  \"" + key + "\"")
	lines.append("")

	lines.append("ИТОГ: " + ("OK" if missing.is_empty() and devlog_hits.is_empty() and dups.is_empty() else "ЕСТЬ ЗАМЕЧАНИЯ"))

	var f := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(lines))
		f.close()
	print("Аудит завершён: ", REPORT_PATH)
	quit(0)

func _collect_scripts() -> Array[String]:
	var out: Array[String] = []
	for d in SCAN_DIRS:
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for f in dir.get_files():
			if f.ends_with(".gd") and f != "audit_i18n.gd" and f != "check_scripts.gd":
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

func _load_csv_key_list() -> Array[String]:
	var out: Array[String] = []
	var text := _read_text(CSV_PATH)
	if text.is_empty():
		return out
	var re := RegEx.new()
	re.compile("^\"([^\"]*)\"")
	for line in text.split("\n"):
		var m := re.search(line.strip_edges())
		if m != null:
			out.append(m.get_string(1))
	return out

func _load_csv_keys() -> Dictionary:
	var d := {}
	for key in _load_csv_key_list():
		d[key] = true
	return d

func _extract_tr_keys(text: String) -> Array[String]:
	var out: Array[String] = []
	var re := RegEx.new()
	re.compile("tr\\(\"([^\"]*)\"\\)")
	for m in re.search_all(text):
		out.append(m.get_string(1))
	return out

# Возвращает список dev-логов, внутри которых есть tr().
func _find_devlog_tr(path: String, text: String) -> Array[String]:
	var out: Array[String] = []
	for name in DEVLOG_CALLS:
		var from := 0
		while true:
			var i := text.find(name, from)
			if i < 0:
				break
			var prev := "" if i == 0 else text.substr(i - 1, 1)
			var is_call := not _is_ident_char(prev)
			var end := _find_close_paren(text, i + name.length() - 1)
			if is_call and end > i:
				var stmt := text.substr(i, end - i + 1)
				if stmt.contains("tr("):
					var line_no := text.substr(0, i).count("\n") + 1
					out.append(path.get_file() + ":" + str(line_no) + "  " + stmt.replace("\n", " ").strip_edges())
			from = i + name.length()
	return out

func _is_ident_char(c: String) -> bool:
	if c.is_empty():
		return false
	return c == "_" or (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")

# Ищет индекс закрывающей скобки для '(' на позиции open_idx, учитывая строки.
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