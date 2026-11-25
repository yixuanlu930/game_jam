class_name CafeDrink
extends Resource

enum IconKind { COFFEE, LEMONADE, CHOCOLATE }

@export var display_name: String
@export var description: String
@export_range(1, 100, 1, "or_greater") var price: int = 12
@export var icon_kind: IconKind = IconKind.COFFEE
