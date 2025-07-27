extends Node

func _ready():
	SignalHub.start_night.connect(start_night)
	SignalHub.end_night.connect(end_night)

func start_night() -> void:
	var nightShader = get_node("/root/Main/UiScene/NightCanvas/NightShader")
	nightShader.visible = true
	States.nightN += 1
	emit_signal("nights_changed")

func end_night() -> void:
	var nightShader = get_node("/root/Main/UiScene/NightCanvas/NightShader")
	nightShader.visible = false
