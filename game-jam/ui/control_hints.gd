extends HBoxContainer


func present(phase: StringName, can_call_waiter: bool = false) -> void:
	var at_table := phase in [&"ordering", &"gift_reaction"]
	%RespondHint.visible = phase == &"question"
	%ContinueHint.visible = phase != &"question"
	%ContinueHint.get_node("Key").text = "ESC" if at_table else "ENTER"
	%ContinueHint.get_node("Text").text = "Volver a la cita" if at_table else "Continuar"
	%ShiftHint.visible = phase in [&"question", &"opening"]
	%WaiterHint.visible = can_call_waiter
	match phase:
		&"question":
			%Turn.text = "TU TURNO"
		&"opening":
			%Turn.text = "EN CONVERSACIÓN"
		&"ordering":
			%Turn.text = "ELIGE UNA BEBIDA"
		&"gift_reaction":
			%Turn.text = "BEBIDA ENTREGADA"
		&"finished":
			%Turn.text = "NOCHE COMPLETADA"
		_:
			%Turn.text = "CITA TERMINADA"
