class_name DrinkMenu
extends Resource

const DrinkData = preload("res://game/cafe_drink.gd")

@export var drinks: Array[DrinkData] = []


func get_drink(index: int) -> DrinkData:
	if index < 0 or index >= drinks.size():
		return null
	var drink := drinks[index]
	if drink == null or drink.price <= 0 or drink.display_name.strip_edges().is_empty():
		return null
	return drink


func has_drinks() -> bool:
	for index in drinks.size():
		if get_drink(index) != null:
			return true
	return false
