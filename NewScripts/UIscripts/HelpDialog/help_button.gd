extends Button

func _on_pressed() -> void:
	var helpNode = get_node("/root/Main/UiScene/HelpTextCanvas/HelpPanel")
	if helpNode.visible == true:
		helpNode.visible = false
	else:
		helpNode.visible = true
