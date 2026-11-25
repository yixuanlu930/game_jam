class_name DateProfile
extends Resource

const QuestionData = preload("res://game/date_question.gd")
const DrinkData = preload("res://game/cafe_drink.gd")
const PreferenceData = preload("res://game/drink_preference.gd")

@export_group("Personaje")
@export var display_name: String = ""
@export var tagline: String = ""
@export var location_name: String = ""
@export var portrait: Texture2D
@export var background: Texture2D

@export_group("Guion")
## Cada entrada se muestra por separado antes de la primera pregunta.
@export var opening_lines: PackedStringArray = []
@export var questions: Array[QuestionData] = []

@export_group("Afinidad")
@export var starting_score: int = 0
## Tras una respuesta, el personaje hace SHIFT si la afinidad llega a este valor o baja de él.
@export var rejection_threshold: int = -3
## Afinidad mínima para que quiera volver a verte al terminar las preguntas.
@export var success_threshold: int = 3

@export_group("Bebidas")
@export var drink_preferences: Array[PreferenceData] = []
## Réplica para bebidas sin preferencia asignada. Su efecto en afinidad es cero.
@export_multiline var default_drink_reply: String = "Gracias por invitarme."

@export_group("Desenlaces")
@export_multiline var rejected_line: String = "Creo que lo voy a dejar aquí. Gracias por la cita."
@export_multiline var success_line: String = "Me encantaría que nos volviéramos a ver."
@export_multiline var neutral_line: String = "Me ha gustado conocerte. ¡Que vaya bien la noche!"


func preference_for(drink: DrinkData) -> PreferenceData:
	for preference in drink_preferences:
		if preference != null and preference.drink == drink:
			return preference
	return null


func validation_error() -> String:
	if display_name.strip_edges().is_empty():
		return "falta el nombre del personaje"
	if questions.is_empty():
		return "se necesita al menos una pregunta"
	if rejection_threshold >= success_threshold:
		return "el umbral de rechazo debe ser inferior al de éxito"
	for index in questions.size():
		var question := questions[index]
		if question == null:
			return "falta la pregunta %d" % (index + 1)
		var error := question.validation_error()
		if not error.is_empty():
			return "pregunta %d, %s" % [index + 1, error]
	return ""
