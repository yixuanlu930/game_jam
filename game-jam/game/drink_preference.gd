class_name DrinkPreference
extends Resource

const DrinkData = preload("res://game/cafe_drink.gd")

@export var drink: DrinkData
@export_range(0, 10, 1, "or_greater") var affinity_gain: int = 0
@export_multiline var reply: String = ""
