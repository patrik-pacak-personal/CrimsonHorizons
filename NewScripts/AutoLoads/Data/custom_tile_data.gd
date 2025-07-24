extends Node

var tile_flags := {}

func set_tile_flag(pos: Vector2i, key: String, value):
	if not tile_flags.has(pos):
		tile_flags[pos] = {}
	tile_flags[pos][key] = value

func get_tile_flag(pos: Vector2i, key: String) -> bool:
	return tile_flags.has(pos) and tile_flags[pos].get(key, false)
