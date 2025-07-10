extends Button

signal build_requested(name)

func _on_pressed():
	var number = randi() % 2 + 1
	emit_signal("build_requested","mine"+str(number))
