extends Control

signal finished

const FACE := preload("res://ui/pixel.ttf")
const DURATION := 0.92
const PINK := Color("#ff609c")
const CYAN := Color("#75e9df")
const INK := Color("#161321")
const CREAM := Color("#fff3ed")
const FONT_SIZE := 216

var elapsed := 0.0


func play() -> void:
	if visible:
		return
	_set_time(0.0)
	show()
	$Impact.play()
	var tween := create_tween()
	tween.tween_method(_set_time, 0.0, DURATION, DURATION)
	tween.tween_callback(_finish)


func _set_time(seconds: float) -> void:
	elapsed = seconds
	self_modulate.a = smoothstep(0.0, 0.055, seconds) * (1.0 - smoothstep(0.72, DURATION, seconds))
	queue_redraw()


func _finish() -> void:
	hide()
	finished.emit()


func _draw() -> void:
	var unit := minf(size.x / 1280.0, size.y / 800.0)
	if unit <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.045, 0.035, 0.085, 0.52))
	draw_set_transform(size * 0.5, deg_to_rad(-7.0), Vector2.ONE * unit)

	var entry := 1.0 - pow(1.0 - clampf(elapsed / 0.20, 0.0, 1.0), 3.0)
	var leaving := smoothstep(0.71, DURATION, elapsed)
	var half_width := size.length() / (2.0 * unit)
	var half_height := lerpf(4.0, 112.0, entry) * (1.0 - 0.70 * leaving)
	var width := 2.0 * half_width
	draw_rect(Rect2(-half_width, -half_height, width, 2.0 * half_height), Color(INK, 0.96))
	draw_rect(Rect2(-half_width, -half_height, width, 5.0), PINK)
	draw_rect(Rect2(-half_width, half_height - 3.0, width, 3.0), PINK)
	draw_rect(Rect2(-half_width, half_height + 5.0, width, 2.0), Color(CYAN, 0.8))

	# Líneas escalonadas y chispas de píxel que se alejan del rótulo.
	for side: int in [-1, 1]:
		for row in 5:
			var distance := 358.0 + 32.0 * (row % 3) + elapsed * (58.0 + 14.0 * row)
			var length := 28.0 + 16.0 * ((row + 1) % 4)
			var y := (-0.70 + 0.31 * row) * half_height
			var start := Vector2(side * distance, side * y)
			var end := start + Vector2(side * length, 0.0)
			var color := CYAN if row % 2 == 0 else PINK
			draw_line(start, end, Color(color, 0.80), 3.0)
			draw_rect(Rect2(end + Vector2(side * 12.0, -2.0), Vector2(5.0, 5.0)), color)

	var text_width := FACE.get_string_size("SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var slide := -420.0 * (1.0 - entry) + 330.0 * leaving
	var origin := Vector2(-text_width * 0.5 + slide, FONT_SIZE * 0.35)
	var offset := 5.0 + 16.0 * (1.0 - entry) + 9.0 * leaving
	draw_string(FACE, origin + Vector2(-offset, 6.0), "SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, CYAN)
	draw_string(FACE, origin + Vector2(offset, -4.0), "SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, PINK)
	draw_string(FACE, origin, "SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, CREAM)
