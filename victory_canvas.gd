extends CanvasLayer

func _on_ready() -> void:
	$VictoryPanel.visible = false


func _on_end_day_button_victory_achieved() -> void:
	$VictoryPanel.visible = true
