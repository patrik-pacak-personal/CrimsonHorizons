extends Button

signal resources_changed()

func _on_pressed() -> void:
	States.ResetStates()
	Data.ResetResources()
	emit_signal("resources_changed")
	get_tree().change_scene_to_file("res://MainMenu.tscn")
