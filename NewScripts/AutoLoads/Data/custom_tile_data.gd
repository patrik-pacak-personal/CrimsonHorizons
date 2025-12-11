extends Node

var tile_flags := {}

func set_tile_flag(pos: Vector2i, key: String, value : Variant):
	if not tile_flags.has(pos):
		tile_flags[pos] = {}
	tile_flags[pos][key] = value

func get_tile_flag(pos: Vector2i, key: String) -> Variant:
	if not tile_flags.has(pos):
		return null
	return tile_flags[pos].get(key)

func set_tile_flags_to_basic(pos: Vector2i):
	CustomTileData.set_tile_flag(pos,"occupied",false)
	CustomTileData.set_tile_flag(pos,"hasAlien",false)
	CustomTileData.set_tile_flag(pos,"hasCrosshair",false)
	CustomTileData.set_tile_flag(pos,"house",false)
	CustomTileData.set_tile_flag(pos,"farm",false)
	CustomTileData.set_tile_flag(pos,"mine",false)
	CustomTileData.set_tile_flag(pos,"generator",false)
	CustomTileData.set_tile_flag(pos,"turret",false)
	CustomTileData.set_tile_flag(pos,"object_name","")
	
func find_center_tile() -> Vector2i:
	for pos in tile_flags.keys():
		if tile_flags[pos].get("IsCenter"):
			return pos
	return Vector2i.ZERO
