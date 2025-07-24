extends Node

func populate_tile_flags_from_tilemap(tilemap: TileMapLayer):
	for pos in tilemap.get_used_cells():
		var tile_data = tilemap.get_cell_tile_data(pos)
		if tile_data:
			CustomTileData.set_tile_flag(pos,"occupied",false)
			CustomTileData.set_tile_flag(pos,"hasAlien",false)
			CustomTileData.set_tile_flag(pos,"hasCrosshair",false)
			CustomTileData.set_tile_flag(pos,"house",false)
			CustomTileData.set_tile_flag(pos,"farm",false)
			CustomTileData.set_tile_flag(pos,"mine",false)
			CustomTileData.set_tile_flag(pos,"generator",false)
			CustomTileData.set_tile_flag(pos,"turret",false)
			
			_set_flags_from_custom_layers(tile_data,pos)

func _set_flags_from_custom_layers(tile_data: TileData,pos: Vector2i):
	var isMineral = tile_data.get_custom_data("IsMineral")
	CustomTileData.set_tile_flag(pos,"IsMineral",isMineral)
	
	var isCenter = tile_data.get_custom_data("IsCenter")
	CustomTileData.set_tile_flag(pos,"IsCenter",isCenter)
	
	var canBuild = tile_data.get_custom_data("CanBuild")
	CustomTileData.set_tile_flag(pos,"CanBuild",canBuild)
	
