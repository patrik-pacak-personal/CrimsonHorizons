extends Button

func _on_pressed() -> void:
	var menu = get_node("/root/Main/UiScene/BuildMenuScene/BuildMenuCanvas/BuildMenu")
	menu.visible = false
