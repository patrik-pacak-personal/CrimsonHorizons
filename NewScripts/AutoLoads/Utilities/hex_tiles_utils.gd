extends Node

func get_outskirts_tiles() -> Array:
	var tileMapLayer = get_node("/root/Main/GameplayScene/TileMapLayer")
	var all_tiles = tileMapLayer.get_used_cells()
	var outskirts = []

	for tile in all_tiles:
		var is_edge := false
		for dir in get_flat_top_neighbors(tile):
			if not all_tiles.has(dir):
				is_edge = true
				break
		if is_edge:
			outskirts.append(tile)

	return outskirts
	
func get_flat_top_neighbors(tile: Vector2i) -> Array:
	var even_q := [
		Vector2i(1, 0),    # E
		Vector2i(1, -1),   # NE
		Vector2i(0, -1),   # NW
		Vector2i(-1, 0),   # W
		Vector2i(0, 1),    # SW
		Vector2i(1, 1)     # SE
	]

	var odd_q := [
		Vector2i(1, 0),    # E
		Vector2i(1, -1),   # NE
		Vector2i(0, -1),   # NW
		Vector2i(-1, 0),   # W
		Vector2i(-1, 1),   # SW
		Vector2i(0, 1)     # SE
	]

	var directions = {}
	if tile.x % 2 == 0:
		directions=even_q
	else:
		directions = odd_q
	

	var neighbors := []
	for dir in directions:
		neighbors.append(tile + dir)

	return neighbors
