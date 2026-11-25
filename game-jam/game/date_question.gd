class_name DateQuestion
extends Resource

const AnswerData = preload("res://game/date_answer.gd")

## Intervención del personaje que da paso a las cuatro respuestas.
@export_multiline var prompt: String = ""
@export var answers: Array[AnswerData] = [null, null, null, null]
## Permite llamar al camarero y regalar una bebida antes de responder.
@export var waiter_available: bool = false


func validation_error() -> String:
	if prompt.strip_edges().is_empty():
		return "falta el texto de la pregunta"
	if answers.size() != 4:
		return "se necesitan exactamente cuatro respuestas"
	for index in answers.size():
		var answer := answers[index]
		if answer == null or answer.text.strip_edges().is_empty():
			return "falta el texto de la respuesta %d" % (index + 1)
	return ""
