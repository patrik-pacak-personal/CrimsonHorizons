extends TileMapLayer

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		SignalHub.handle_map_click.emit(self)
	else:
		SignalHub.handle_map_hover.emit(self)
		
func _on_ready() -> void:
	SignalHub.tileMapLayer_ready.emit(self)
