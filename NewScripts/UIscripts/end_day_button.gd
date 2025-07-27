extends Button

func _on_pressed() -> void:
	SignalHub.end_day()
	
