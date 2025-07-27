extends CanvasLayer

func _on_ready() -> void:
	$NightShader.visible = false
	$NightShader/nightNumber.text = str(States.nightN)
	SignalHub.start_night.connect(_on_end_day_button_nights_changed)

func _on_end_day_button_nights_changed() -> void:
	$NightShader/nightNumber.text = str(States.nightN)
