extends CanvasLayer



func _on_ready() -> void:
	$GameOverPanel.visible = false
	
func _on_end_day_button_game_over() -> void:
	$GameOverPanel.visible = true
