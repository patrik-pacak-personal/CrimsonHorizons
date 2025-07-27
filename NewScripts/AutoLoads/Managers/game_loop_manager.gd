extends Node

func _ready():
	SignalHub.check_for_victory.connect(check_for_victory)

func check_for_victory():
	if Resources.houses > 6 and Resources.farms > 3:
		emit_signal("victory_achieved")
