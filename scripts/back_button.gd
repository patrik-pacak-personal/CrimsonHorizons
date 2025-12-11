extends Button

signal resources_changed()

func _on_pressed() -> void:
	Resources.ResetResources()
	States.ResetStates()
	emit_signal("resources_changed")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	States.in_game = false
