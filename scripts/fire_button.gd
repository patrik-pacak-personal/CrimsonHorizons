extends Button

signal resources_changed()

func _on_ready() -> void:
	$VBoxContainer/HBoxContainer/artilleryCost.text = str(Resources.actions_costs["fire_artillery"]["energy"])
	self.visible = false
	SignalHub.turret_built.connect(_on_turret_built)
	SignalHub.marker_placed.connect(_on_marker_placed)
	SignalHub.end_night.connect(_reset_shots)
	SignalHub.determine_shoot_panel_visibility.connect(determine_panel_visibility)

func _reset_shots():
	update_remaining_shots()

func _on_pressed() -> void:
	SignalHub.fire_pressed.emit()
		
func _on_marker_placed() -> void:
	update_remaining_shots()

func _on_turret_built() -> void:
	self.visible = true
	States.remainingShots += 1
	update_remaining_shots()

func update_remaining_shots() -> void:
	$VBoxContainer/HBoxContainer2/remainingShots.text = str(States.remainingShots)
	
func determine_panel_visibility():
	if States.remainingShots == 0:
		self.visible=false

func _on_end_day_button_day_ended() -> void:
	$VBoxContainer/HBoxContainer2/remainingShots.text = str(States.remainingShots)
