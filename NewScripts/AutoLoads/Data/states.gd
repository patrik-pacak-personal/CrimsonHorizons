extends Node

func _ready():	
	SignalHub.on_reset.connect(ResetStates)

var selected_tile: Vector2i = Vector2i(-1, -1)
var shooting = false

var _turretBuilt = false
var turretBuilt:
	get:
		return _turretBuilt
	set(value):
		_turretBuilt = value
		SignalHub.turret_built.emit()
		
var remainingShots = 0
var nightN = 0

func ResetStates():
	shooting = false
	turretBuilt = false
	remainingShots = 0
	nightN = 0
