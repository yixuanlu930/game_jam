extends HBoxContainer


func set_coins(balance: int) -> void:
	%CoinCount.text = str(balance)


func present(director: DateDirector) -> void:
	var total := director.catalog.encounters.size() if director.catalog else 0
	%Counter.text = "%02d / %02d" % [mini(director.encounter_index + 1, total), total]
	%Affinity.visible = director.profile != null
	%Divider.visible = %Affinity.visible
	if director.profile:
		%Score.text = "%+d" % director.score
		%Meter.set_affinity(director.score, director.profile.rejection_threshold, director.profile.success_threshold)
