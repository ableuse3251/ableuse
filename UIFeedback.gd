extends CanvasLayer

# ============================================================
# ГЛОБАЛЬНЫЙ UI-ФИДБЕК (AUTOLOAD)
# Показывает всплывающие уведомления (тосты) поверх всех сцен:
#   - ошибки (красные)
#   - успех (зелёные)
#   - информация (синие)
# Также дублирует ошибки/предупреждения в консоль через push_.
# ============================================================

const TOAST_DURATION: float = 3.0
const MAX_TOASTS: int = 4

var toast_container: VBoxContainer

func _ready() -> void:
	layer = 100  # поверх всех сцен

	var root_control := Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	toast_container = VBoxContainer.new()
	toast_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toast_container.anchor_top = 1.0
	toast_container.anchor_bottom = 1.0
	toast_container.offset_top = -230
	toast_container.offset_bottom = -30
	toast_container.offset_left = 40
	toast_container.offset_right = -40
	toast_container.alignment = BoxContainer.ALIGNMENT_END
	toast_container.add_theme_constant_override("separation", 8)
	toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(toast_container)

# ============================================================
# ПУБЛИЧНЫЙ API
# ============================================================

func show_error(message: String) -> void:
	_add_toast("❌ " + message, Color(0.42, 0.07, 0.07, 0.97))

func show_success(message: String) -> void:
	_add_toast("✅ " + message, Color(0.06, 0.33, 0.11, 0.97))

func show_info(message: String) -> void:
	_add_toast("ℹ️ " + message, Color(0.07, 0.14, 0.32, 0.97))

# Ошибка: пишем в консоль (push_error) И показываем пользователю.
func report_error(source: String, message: String) -> void:
	push_error("[" + source + "] " + message)
	show_error(message)

# Предупреждение: пишем в консоль (push_warning) и показываем информационный тост.
func report_warning(source: String, message: String) -> void:
	push_warning("[" + source + "] " + message)
	show_info(message)

# Информация: пишем в консоль (print) и показываем информационный тост.
# Использовать только для важных пользовательских событий, не спамить.
func report_info(source: String, message: String) -> void:
	print("[" + source + "] " + message)
	show_info(message)

# ============================================================
# ВНУТРЕННЕЕ
# ============================================================

func _add_toast(text: String, bg_color: Color) -> void:
	if toast_container == null or not is_node_ready():
		return

	# Ограничиваем количество тостов на экране.
	while toast_container.get_child_count() >= MAX_TOASTS:
		var oldest := toast_container.get_child(0)
		if oldest != null:
			toast_container.remove_child(oldest)
			oldest.queue_free()

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.25)
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	margin.add_child(label)

	# Плавное появление, пауза, плавное исчезновение.
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_interval(TOAST_DURATION)
	tween.tween_property(panel, "modulate:a", 0.0, 0.4)
	tween.tween_callback(panel.queue_free)