extends Button

func _on_ready() -> void:
	SignalHub.throw_error.connect(_on_throw_error)
	
	var menu = get_node("/root/Main/UiScene/ErrorScene/ErrorCanvas/ErrorPanel")
	menu.visible = false

func _on_pressed() -> void:
	var menu = get_node("/root/Main/UiScene/ErrorScene/ErrorCanvas/ErrorPanel")
	menu.visible = false


func _on_throw_error(error: String) -> void:
	var menu = get_node("/root/Main/UiScene/ErrorScene/ErrorCanvas/ErrorPanel")
	var errorLabel = get_node("/root/Main/UiScene/ErrorScene/ErrorCanvas/ErrorPanel/VBoxContainer/Error")
	errorLabel.text = error
	var viewport_size = get_viewport().get_visible_rect().size
	menu.position = (viewport_size / 2) - (menu.size / 2)
	menu.visible = true
