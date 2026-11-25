class_name DateAnswer
extends Resource

## Opción que puede elegir el jugador.
@export_multiline var text: String = ""
## Un valor positivo suma afinidad, uno negativo la resta y cero la mantiene.
@export var score_delta: int = 0
## Réplica opcional del NPC antes de su siguiente pregunta.
@export_multiline var reply: String = ""
