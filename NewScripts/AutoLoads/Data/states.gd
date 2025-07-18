extends Node

var selected_tile: Vector2i = Vector2i(-1, -1)
var shooting = false
var turretBuilt = false
var remainingShots = 0
var nightN = 0

func ResetStates():
	shooting = false
	turretBuilt = false
	remainingShots = 0
	nightN = 0
