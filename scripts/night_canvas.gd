extends CanvasLayer


func _on_ready() -> void:
	$NightShader.visible = false
	$NightShader/nightNumber.text = str(States.nightN)


func _on_end_day_button_nights_changed() -> void:
	$NightShader/nightNumber.text = str(States.nightN)
