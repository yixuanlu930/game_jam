extends Node

signal balance_changed(balance: int)

@export_range(0, 1000000, 1, "or_greater") var starting_coins: int = 100
var balance: int = 0


func reset() -> void:
	balance = maxi(0, starting_coins)
	balance_changed.emit(balance)


## Suma monedas con un valor positivo o gástalas con uno negativo.
## Devuelve false si el saldo no cubre el gasto.
func change_balance(amount: int) -> bool:
	var new_balance := balance + amount
	if new_balance < 0:
		return false
	if new_balance != balance:
		balance = new_balance
		balance_changed.emit(balance)
	return true
