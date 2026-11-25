extends Button


func set_answer(index: int, caption: String) -> void:
	var number := str(index + 1)
	%Number.text = number
	%Caption.text = caption
	accessibility_name = "%s. %s" % [number, caption]


func _get_minimum_size() -> Vector2:
	var inset := get_node_or_null("Inset") as MarginContainer
	if inset == null:
		return Vector2.ZERO
	return Vector2(0, inset.get_combined_minimum_size().y)
