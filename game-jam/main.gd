extends Control

@onready var director: DateDirector = %Director
var shift_pressed_alone := false


func _ready() -> void:
	%PlayerWallet.balance_changed.connect(_on_balance_changed)
	director.night_started.connect(%PlayerWallet.reset)
	%Stage.shift_requested.connect(director.player_shift)
	%Stage.waiter_requested.connect(director.call_waiter)
	%Service.drink_selected.connect(_on_drink_selected)
	%Service.dismissed.connect(director.dismiss_waiter)
	%Dialogue.answer_selected.connect(director.choose)
	%Dialogue.advance_requested.connect(director.advance)
	%ShiftEffect.finished.connect(_present)
	director.changed.connect(_on_date_changed)
	director.start()


func _on_balance_changed(balance: int) -> void:
	%Header.set_coins(balance)
	if director.phase == &"ordering":
		%Service.present(director, balance)


func _on_drink_selected(index: int) -> void:
	director.order_drink(index, %PlayerWallet)


func _on_date_changed() -> void:
	if director.phase == &"player_shift":
		shift_pressed_alone = false
		%ShiftEffect.play()
	else:
		_present()


func _present() -> void:
	var active := director.phase == &"opening" or director.phase == &"question"
	var at_table := director.phase in [&"ordering", &"gift_reaction"]
	var leaving_table: bool = %Service.visible and not at_table
	var can_call := director.can_call_waiter()
	%Header.present(director)
	%Stage.present(director.profile, active)
	%Stage.set_waiter(can_call, at_table)
	%Stage.set_served_drink(director.last_drink if director.phase == &"gift_reaction" else null)
	%Dialogue.visible = not at_table
	%Service.visible = at_table
	if at_table:
		shift_pressed_alone = false
		%Service.present(director, %PlayerWallet.balance)
	else:
		%Dialogue.present(director)
		if leaving_table and director.phase == &"question":
			%Dialogue.focus_first_answer()
	%Hints.present(director.phase, can_call)


func _input(event: InputEvent) -> void:
	if %ShiftEffect.visible:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed:
		shift_pressed_alone = false
	if not event is InputEventKey or event.echo:
		return
	var key := event as InputEventKey
	if %Service.visible:
		if key.pressed and key.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			director.dismiss_waiter()
		return
	if key.keycode == KEY_SHIFT:
		if key.pressed:
			shift_pressed_alone = not (key.alt_pressed or key.ctrl_pressed or key.meta_pressed)
		else:
			if shift_pressed_alone:
				director.player_shift()
			shift_pressed_alone = false
		return
	if not key.pressed:
		return
	shift_pressed_alone = false
	if key.shift_pressed or key.alt_pressed or key.ctrl_pressed or key.meta_pressed:
		return
	if director.phase == &"question":
		if key.keycode == KEY_C and director.can_call_waiter():
			get_viewport().set_input_as_handled()
			director.call_waiter()
			return
		var index := [KEY_1, KEY_2, KEY_3, KEY_4].find(key.keycode)
		if index < 0:
			index = [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4].find(key.keycode)
		if index >= 0:
			get_viewport().set_input_as_handled()
			director.choose(index)
	elif key.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		var focus := get_viewport().gui_get_focus_owner()
		if focus == null or not %Stage.is_ancestor_of(focus):
			get_viewport().set_input_as_handled()
			director.advance()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		shift_pressed_alone = false
