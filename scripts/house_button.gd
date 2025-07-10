extends Button

signal build_requested(name)

func _on_pressed():
	var number = randi() % 3 + 1
	emit_signal("build_requested","house"+str(number))
