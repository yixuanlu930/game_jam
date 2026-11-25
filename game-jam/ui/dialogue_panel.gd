extends PanelContainer

const Director = preload("res://game/date_director.gd")
const AnswerButton = preload("res://ui/answer_button.gd")

signal answer_selected(index: int)
signal advance_requested

@onready var heading: Label = %Heading
@onready var status: Label = %Status
@onready var prompt: Label = %Prompt
@onready var choices: GridContainer = %Choices
@onready var advance_button: Button = %Advance


func _ready() -> void:
	for index in choices.get_child_count():
		var button := choices.get_child(index) as AnswerButton
		button.pressed.connect(answer_selected.emit.bind(index))
	advance_button.pressed.connect(advance_requested.emit)


func focus_first_answer() -> void:
	(choices.get_child(0) as Button).grab_focus()


func present(director: Director) -> void:
	var is_question := director.phase == &"question"
	var focus_owner := get_viewport().gui_get_focus_owner()
	var move_focus := choices.visible != is_question and focus_owner != null and is_ancestor_of(focus_owner)
	choices.visible = is_question
	advance_button.visible = not is_question
	var profile := director.profile
	match director.phase:
		&"question":
			var question := profile.questions[director.question_index]
			heading.text = "DIÁLOGO"
			status.text = "PREGUNTA %02d / %02d" % [director.question_index + 1, profile.questions.size()]
			prompt.text = question.prompt
			if not director.last_reply.is_empty():
				prompt.text = director.last_reply + " " + question.prompt
			for index in choices.get_child_count():
				var button := choices.get_child(index) as AnswerButton
				button.set_answer(index, question.answers[index].text)
		&"opening":
			heading.text = "DIÁLOGO"
			status.text = "PRESENTACIÓN"
			prompt.text = profile.opening_lines[director.opening_index]
			advance_button.text = "Continuar  ›"
		&"player_shift":
			heading.text = "HAS HECHO SHIFT"
			prompt.text = "Has decidido terminar tu cita con %s." % profile.display_name
		&"npc_shift":
			heading.text = "%s HA HECHO SHIFT" % profile.display_name.to_upper()
			prompt.text = profile.rejected_line
		&"success":
			heading.text = "QUIERE VOLVER A VERTE"
			prompt.text = profile.success_line
		&"neutral":
			heading.text = "DESPEDIDA"
			prompt.text = profile.neutral_line
		&"finished":
			heading.text = "FIN DE LA NOCHE"
			status.text = "CITAS COMPLETADAS"
			prompt.text = "El café cierra por hoy. ¿Volvemos a empezar?"
			advance_button.text = "Volver a jugar  ›"
	if director.phase in [&"player_shift", &"npc_shift", &"success", &"neutral"]:
		status.text = "FIN DE LA CITA"
		var has_next := director.encounter_index + 1 < director.catalog.encounters.size()
		advance_button.text = "Siguiente cita  ›" if has_next else "Terminar la noche  ›"
	if move_focus:
		if is_question:
			focus_first_answer()
		else:
			advance_button.grab_focus()
