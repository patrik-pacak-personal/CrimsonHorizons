extends Button

func _on_pressed() -> void:
	var menu = get_node("/root/Main/UiScene/BuildMenuCanvas/BuildMenu")
	menu.visible = false
