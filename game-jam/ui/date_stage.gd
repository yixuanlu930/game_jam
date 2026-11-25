class_name DateStage
extends Control

const ProfileData = preload("res://game/date_profile.gd")
const DrinkData = preload("res://game/cafe_drink.gd")

signal shift_requested
signal waiter_requested

@onready var background: TextureRect = %Background
@onready var default_background := background.texture
@onready var portrait: TextureRect = %Portrait
@onready var table_waiter: TextureRect = %WaiterAtTable
@onready var drink_badge: Panel = %ServedDrink

var _at_table := false
var _table_progress := 0.0
var _table_motion: Tween
var _served_drink: DrinkData
var _serving_motion: Tween


func present(profile: ProfileData, can_shift: bool) -> void:
	%Location.visible = profile != null and not profile.location_name.is_empty()
	%Identity.visible = profile != null
	%Portrait.visible = profile != null and profile.portrait != null
	%ShiftActions.visible = profile != null and can_shift
	if profile == null:
		return

	background.texture = profile.background if profile.background != null else default_background
	%Portrait.texture = profile.portrait
	%LocationName.text = profile.location_name.to_upper()
	%DisplayName.text = profile.display_name.to_upper()
	%Occupation.visible = not profile.tagline.is_empty()
	%Tagline.text = profile.tagline


func _on_shift_pressed() -> void:
	shift_requested.emit()


func set_waiter(available: bool, at_table: bool) -> void:
	%WaiterCall.visible = available and not at_table
	if _at_table == at_table:
		return
	_at_table = at_table
	table_waiter.visible = at_table
	if _table_motion:
		_table_motion.kill()
	_table_motion = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_table_motion.tween_method(_arrange_table, _table_progress, 1.0 if at_table else 0.0, 0.24)


func _arrange_table(progress: float) -> void:
	_table_progress = progress
	portrait.anchor_right = lerpf(1.0, 0.67, progress)
	table_waiter.anchor_left = lerpf(0.64, 0.50, progress)
	table_waiter.anchor_right = lerpf(1.09, 0.95, progress)
	table_waiter.modulate.a = progress


func _on_waiter_pressed() -> void:
	waiter_requested.emit()


func set_served_drink(drink: DrinkData) -> void:
	if drink == _served_drink:
		return
	_served_drink = drink
	if _serving_motion:
		_serving_motion.kill()
	drink_badge.visible = drink != null
	if drink == null:
		return
	%ServedDrinkIcon.kind = drink.icon_kind
	_move_drink(0.0)
	_serving_motion = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_serving_motion.tween_method(_move_drink, 0.0, 1.0, 0.40)


func _move_drink(progress: float) -> void:
	var center := size * Vector2(lerpf(0.67, 0.43, progress), 0.74)
	center.y -= 18.0 * sin(PI * progress)
	drink_badge.position = (center - drink_badge.size * 0.5).round()
