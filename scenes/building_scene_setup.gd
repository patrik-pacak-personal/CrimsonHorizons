extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $AnimationPlayer

var building_name: String

func setup(name: String, texture: Texture2D):
	self.name = name
	building_name = name
	sprite.texture = texture

	if anim.has_animation("BuildBuilding"):
		anim.play("BuildBuilding")
