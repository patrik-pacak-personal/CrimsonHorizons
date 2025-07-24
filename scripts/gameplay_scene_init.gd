extends Node2D

var item_prefabs: Node = null

func _ready():
	load_prefabs()	
	BuildingManager.set_tilemap_layer($TileMapLayer)     
	BuildingManager.set_placed_items($PlacedItemsContainer)
	BuildingManager.set_prefabs(item_prefabs)  
	
func load_prefabs() -> void:
	var prefab_scene = preload("res://scenes/prefabs.tscn")
	item_prefabs = prefab_scene.instantiate()
	item_prefabs.visible = false
	add_child(item_prefabs)	
	
