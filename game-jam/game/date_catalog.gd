class_name DateCatalog
extends Resource

const ProfileData = preload("res://game/date_profile.gd")

## Orden de las citas durante la partida. Cada entrada tiene su propio guion y afinidad.
@export var encounters: Array[ProfileData] = []
