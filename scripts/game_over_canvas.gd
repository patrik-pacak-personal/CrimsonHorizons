extends CanvasLayer

func _on_ready() -> void:
	$GameOverPanel.visible = false
	SignalHub.game_over.connect(_on_end_day_button_game_over)
	
func _on_end_day_button_game_over() -> void:
	$GameOverPanel.visible = true
