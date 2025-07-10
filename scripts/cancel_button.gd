extends Button

func _on_pressed() -> void:
	var menu = get_node("/root/Main/BuildMenuCanvas/BuildMenu")
	menu.visible = false
