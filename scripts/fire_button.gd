extends Button

signal resources_changed()

func _on_ready() -> void:
	$VBoxContainer/HBoxContainer/artilleryCost.text = str(Data.actions_costs["fire_artillery"]["energy"])
	self.visible = false

func _on_pressed() -> void:
	if States.shooting == false:
		if States.remainingShots != 0:
			var cursor_texture = preload("res://icons/crosshair.png")
			Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(25, 25))  # Set hotspot to top-left
			States.shooting = true
			States.remainingShots -=1
	else:
		set_default()
		
func _on_tile_map_layer_marker_placed() -> void:
	Data.resources["energy"] -=5;
	emit_signal("resources_changed")
	set_default()
	update_remaining_shots()
	
func set_default() -> void:
	Input.set_custom_mouse_cursor(null)
	States.shooting = false


func _on_main_turret_built() -> void:
	self.visible = true
	States.remainingShots += 1
	update_remaining_shots()

func update_remaining_shots() -> void:
	$VBoxContainer/HBoxContainer2/remainingShots.text = str(States.remainingShots)


func _on_end_day_button_day_ended() -> void:
	$VBoxContainer/HBoxContainer2/remainingShots.text = str(States.remainingShots)
