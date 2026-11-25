class_name DateDirector
extends Node

const CatalogData = preload("res://game/date_catalog.gd")
const ProfileData = preload("res://game/date_profile.gd")
const MenuData = preload("res://game/drink_menu.gd")
const DrinkData = preload("res://game/cafe_drink.gd")
const Wallet = preload("res://game/player_wallet.gd")

signal changed
signal night_started

@export var catalog: CatalogData
@export var drink_menu: MenuData

var profile: ProfileData
var encounter_index: int = 0
var score: int = 0
var question_index: int = 0
var opening_index: int = 0
var last_reply: String = ""
var last_drink: DrinkData
var gift_gain: int = 0
var gift_reply: String = ""
var phase: StringName = &"finished"


func start() -> void:
	night_started.emit()
	_load_encounter(0)


func advance() -> void:
	match phase:
		&"opening":
			opening_index += 1
			if opening_index >= profile.opening_lines.size():
				phase = &"question"
			changed.emit()
		&"player_shift", &"npc_shift", &"success", &"neutral":
			_load_encounter(encounter_index + 1)
		&"finished":
			start()


func choose(index: int) -> void:
	if phase != &"question":
		return
	var question := profile.questions[question_index]
	if index < 0 or index >= question.answers.size():
		return

	var answer := question.answers[index]
	last_reply = answer.reply.strip_edges()
	score += answer.score_delta
	if score <= profile.rejection_threshold:
		phase = &"npc_shift"
	elif question_index + 1 < profile.questions.size():
		question_index += 1
		_clear_gift()
	elif score >= profile.success_threshold:
		phase = &"success"
	else:
		phase = &"neutral"
	changed.emit()


func player_shift() -> void:
	if phase == &"opening" or phase == &"question":
		phase = &"player_shift"
		changed.emit()


func can_call_waiter() -> bool:
	return (phase == &"question" and last_drink == null
		and profile.questions[question_index].waiter_available
		and drink_menu != null and drink_menu.has_drinks())


func call_waiter() -> void:
	if can_call_waiter():
		phase = &"ordering"
		changed.emit()


func dismiss_waiter() -> void:
	if phase == &"ordering" or phase == &"gift_reaction":
		phase = &"question"
		changed.emit()


func order_drink(index: int, wallet: Wallet) -> bool:
	if phase != &"ordering" or drink_menu == null or wallet == null or last_drink != null:
		return false
	var drink := drink_menu.get_drink(index)
	if drink == null or wallet.balance < drink.price:
		return false

	var preference := profile.preference_for(drink)
	gift_gain = maxi(0, preference.affinity_gain) if preference != null else 0
	gift_reply = profile.default_drink_reply
	if preference != null and not preference.reply.strip_edges().is_empty():
		gift_reply = preference.reply
	last_drink = drink
	score += gift_gain
	phase = &"gift_reaction"
	# La señal síncrona del monedero debe observar el regalo ya entregado.
	wallet.change_balance(-drink.price)
	changed.emit()
	return true


func _clear_gift() -> void:
	last_drink = null
	gift_gain = 0
	gift_reply = ""


func _load_encounter(index: int) -> void:
	encounter_index = index
	opening_index = 0
	question_index = 0
	last_reply = ""
	_clear_gift()
	score = 0
	profile = null
	phase = &"finished"

	if catalog != null:
		while encounter_index < catalog.encounters.size():
			var candidate := catalog.encounters[encounter_index]
			var error := "falta el recurso del personaje"
			if candidate != null:
				error = candidate.validation_error()
			if error.is_empty():
				profile = candidate
				score = profile.starting_score
				phase = &"question" if profile.opening_lines.is_empty() else &"opening"
				break
			push_warning("Se omite la cita %d: %s." % [encounter_index + 1, error])
			encounter_index += 1

	changed.emit()
