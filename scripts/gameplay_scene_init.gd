extends Node2D

func _ready():
	BuildingManager.set_tilemap_layer($TileMapLayer)     
	BuildingManager.set_placed_items($PlacedItemsContainer)
	
	
