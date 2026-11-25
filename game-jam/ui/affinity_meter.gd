@tool
extends Control

const SEGMENTS := 8

var fill_ratio := 0.45


func set_affinity(value: int, minimum: int, maximum: int) -> void:
	fill_ratio = clampf(inverse_lerp(minimum, maximum, value), 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var gap := 3.0
	var width := floorf((size.x - gap * (SEGMENTS - 1)) / SEGMENTS)
	var filled := roundi(fill_ratio * SEGMENTS)
	var top := floorf((size.y - 8) / 2.0)
	for index in SEGMENTS:
		var ink := Color("#ff81aa") if index < filled else Color("#393240")
		draw_rect(Rect2(index * (width + gap), top, width, 8), ink)
