@tool
extends Control

enum Icon { HEART, GAMEPAD, SIGNAL, COIN }

@export var icon: Icon = Icon.HEART:
	set(value):
		icon = value
		queue_redraw()
@export var tint: Color = Color("#ff81aa"):
	set(value):
		tint = value
		queue_redraw()

const HEART = [
	"0011100011100",
	"0122210122210",
	"1233221222221",
	"1232222222221",
	"1222222222221",
	"0122222222210",
	"0012222222100",
	"0001222221000",
	"0000122210000",
	"0000012100000",
	"0000001000000",
]
const GAMEPAD = [
	"00011111000", "01111111110", "11121111211", "11222112121",
	"11121111211", "11111111111", "11100000111",
]
const SIGNAL = [
	"00000011", "00000011", "00011011", "00011011", "11011011", "11011011",
]
const COIN = [
	"0001111000", "0013332100", "0132222210", "1322322221", "1322322221",
	"1222322221", "1222322211", "0122222110", "0012211100", "0001111000",
]


func _draw() -> void:
	var grid: Array = [HEART, GAMEPAD, SIGNAL, COIN][icon]
	var columns: int = grid[0].length()
	var unit := floorf(minf(size.x / columns, size.y / grid.size()))
	if unit < 1:
		return
	var origin := ((size - Vector2(columns, grid.size()) * unit) / 2.0).floor()
	var inks := [Color.TRANSPARENT, tint.darkened(0.43), tint, tint.lightened(0.61)]
	if icon == Icon.GAMEPAD:
		inks = [Color.TRANSPARENT, tint, Color("#171d28"), tint]
	elif icon == Icon.SIGNAL:
		inks[1] = tint
	for y in grid.size():
		for x in columns:
			var shade := int(grid[y][x])
			if shade:
				draw_rect(Rect2(origin + Vector2(x, y) * unit, Vector2.ONE * unit), inks[shade])
