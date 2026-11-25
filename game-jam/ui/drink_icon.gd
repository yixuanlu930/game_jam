@tool
extends Control

@export_enum("Café", "Limonada", "Chocolate") var kind: int = 0:
	set(value):
		kind = value
		queue_redraw()

const SPRITES = [
	[
		"................", ".....s..s.......", "......s..s......", ".....s..s.......",
		"................", "...dddddddd.....", "..dccccccccddd..", "..dbbbbbbbbdacd.",
		"..dbabbbbbbd.bd.", "..dbabbbbbbd.cd.", "..dbbbbbbbbddd..", "...dbbbbbbd.....",
		"....dddddd......", ".daaaaaaaaaccd..", "..ddddddddddd...", "................",
	],
	[
		"................", "..........ggg...", ".........gaggg..", "........gagggg..",
		"....s...ggggg...", ".....s...ggg....", "...ddddddddd....", "...daccccacd....",
		"...dgggggggd....", "...daggcgggd....", "...daggggcd.....", "....daggggd.....",
		"....daggccd.....", "....daaccd......", ".....dddd.......", "................",
	],
	[
		"................", ".......a........", "......aaa.......", "....aaacca......",
		"...aaccccaa.....", "...aaaaaccca....", "..dddddddddd....", "..dbbbbbbbbddd..",
		"..dbabbbbbbd.bd.", "..dbabbbbbbd.bd.", "..dbbbbccbbd.cd.", "..dbbbbccbbddd..",
		"..dbbbbbbbbd....", "...dbbbbbbd.....", "....dddddd......", "................",
	],
]
const PALETTES = [
	{"a": Color("#ffe8bd"), "b": Color("#e08a65"), "c": Color("#75434c")},
	{"a": Color("#ebffe5"), "b": Color("#70b1ae"), "c": Color("#e1de75"), "g": Color("#87cb80")},
	{"a": Color("#ffe4c8"), "b": Color("#c86d88"), "c": Color("#cb9689")},
]


func _draw() -> void:
	var slot := clampi(kind, 0, SPRITES.size() - 1)
	var unit := floorf(minf(size.x, size.y) / 16.0)
	if unit < 1.0:
		return
	var origin := ((size - Vector2.ONE * unit * 16.0) * 0.5).floor()
	var palette: Dictionary = PALETTES[slot]
	for y in SPRITES[slot].size():
		var row: String = SPRITES[slot][y]
		for x in row.length():
			var pigment := row[x]
			if pigment == ".":
				continue
			var ink: Color = palette.get(pigment, Color("#80575e"))
			if pigment == "s":
				ink = Color("#c5b7d4")
			draw_rect(Rect2(origin + Vector2(x, y) * unit, Vector2.ONE * unit), ink)
