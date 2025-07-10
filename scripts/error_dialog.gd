extends Button

func _on_ready() -> void:
	var menu = get_node("/root/Main/ErrorCanvas/ErrorPanel")
	menu.visible = false

func _on_pressed() -> void:
	var menu = get_node("/root/Main/ErrorCanvas/ErrorPanel")
	menu.visible = false


func _on_throw_error(error: String) -> void:
	var menu = get_node("/root/Main/ErrorCanvas/ErrorPanel")
	var errorLabel = get_node("/root/Main/ErrorCanvas/ErrorPanel/VBoxContainer/Error")
	errorLabel.text = error
	var viewport_size = get_viewport().get_visible_rect().size
	menu.position = (viewport_size / 2) - (menu.size / 2)
	menu.visible = true
