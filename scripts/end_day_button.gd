extends Button

signal nights_changed()
signal game_over()
signal victory_achieved()
signal resources_changed()
signal day_ended()

var item_prefabs: Node = null
var houses =0;
var mines =0;
var generators =0;
var turrets = 0;
var farms = 0;

func _on_pressed() -> void:
	start_night()
	count_buildings()
	await spawn_and_move_aliens()
	check_for_killed_aliens()
	give_resources()
	check_for_victory()
	reset_turret_charges()
	end_night()

	
func start_night() -> void:
	var nightShader = get_node("/root/Main/NightCanvas/NightShader")
	nightShader.visible = true
	States.nightN += 1
	emit_signal("nights_changed")

func end_night() -> void:
	var nightShader = get_node("/root/Main/NightCanvas/NightShader")
	nightShader.visible = false
	
func give_resources() -> void:
	var required_farms = int(ceil(houses / 2.0))
	if farms >= required_farms and farms != 0:
		Data.resources["people"] = houses * Data.building_gains["house"]
	Data.resources["minerals"] =Data.resources["minerals"] + mines * Data.building_gains["mine"]	
	Data.resources["energy"] = Data.resources["energy"] + generators * Data.building_gains["generator"]
	Data.resources["food"] = farms * Data.building_gains["farm"]
	
	emit_signal("resources_changed")
	
func count_buildings() -> void:
	reset_to_base_numbers()
	for tile_pos in Data.tile_flags.keys():
		var flags = Data.tile_flags[tile_pos]

		if flags.get("house"):
			houses +=1
		if flags.get("mine"):
			mines +=1
		if flags.get("farm"):
			farms  +=1
		if flags.get("turret"):
			turrets +=1
		if flags.get("generator"):
			generators +=1

	set_counts_globally()
	Data.emit_signal("resources_changed")
	
func set_counts_globally() -> void:
	Data.houses = houses
	Data.mines = mines
	Data.farms = farms
	Data.generators = generators
	Data.turrets = turrets

func reset_to_base_numbers() -> void:
	houses =0;
	mines =0;
	generators =0;
	turrets = 0;
	farms = 0;
	

func _on_ready() -> void:
	item_prefabs = null
	
func find_center_tile() -> Vector2i:
	for pos in Data.tile_flags.keys():
		if Data.tile_flags[pos].get("IsCenter"):
			return pos
	return Vector2i.ZERO
	
func spawn_and_move_aliens():
	var tileMapLayer = get_node("/root/Main/TileMapLayer")
	var prefabsNode = get_node("/root/Main/Prefabs")
	var aliensNode = get_node("/root/Main/Aliens")	
	var center_tile: Vector2i = find_center_tile()
	if  (randi() % 2) == 1:
		if center_tile == Vector2i.ZERO:
			print("Center tile not found!")
			return

		var outskirts_tiles := get_outskirts_tiles()
		if outskirts_tiles.is_empty():
			print("No outskirts tiles found.")
			return

		# Pick random existing alien node
		var aliens := []
		for child in prefabsNode.get_children():
			if child.name in ["alien1", "alien2", "alien3"]:
				aliens.append(child)
		
		var alienNode = aliens[randi() % aliens.size()].duplicate(true)
		
		var spawn_tile = outskirts_tiles[randi() % outskirts_tiles.size()]	
		var tile_global_pos = tileMapLayer.to_global(tileMapLayer.map_to_local(spawn_tile))
		var local_pos = aliensNode.to_local(tile_global_pos)
		
		alienNode.position = local_pos
		aliensNode.add_child(alienNode)
	
	if aliensNode.get_children().size() == 0:
		await get_tree().create_timer(1).timeout
		# Move all aliens 2 tiles toward center
	for alien in aliensNode.get_children():
		await move_alien_towards(alien, center_tile,tileMapLayer,aliensNode)	
		
func check_for_victory():
	if Data.houses > 6 and Data.farms > 3:
		emit_signal("victory_achieved")

func check_for_killed_aliens():
	for tile_pos in Data.tile_flags.keys():
		if Data.get_tile_flag(tile_pos, "hasAlien") and Data.get_tile_flag(tile_pos, "hasCrosshair"):
			kill_alien(tile_pos)
	remove_all_crosshairs()

func kill_alien(tile_pos: Vector2i):
	var aliens_node = get_node("/root/Main/Aliens")
	var placed_items_node = get_node("/root/Main/PlacedItems")
	var tile_map = get_node("/root/Main/TileMapLayer")

	# Get world position of the tile
	var world_pos = tile_map.to_global(tile_map.map_to_local(tile_pos))

	# Look for alien at that tile position
	for alien in aliens_node.get_children():
		if alien.position.distance_to(aliens_node.to_local(world_pos)) < 10:
			alien.queue_free()
			break

	# Clear flags from Data
	Data.set_tile_flag(tile_pos, "hasAlien", false)
	
func remove_all_crosshairs():
	var placed_items_node = get_node("/root/Main/PlacedItems")
	var tile_map = get_node("/root/Main/TileMapLayer")

	var tiles_to_clear := []

	# Step 1: Find all tiles with a crosshair
	for tile_pos in Data.tile_flags.keys():
		if Data.get_tile_flag(tile_pos, "hasCrosshair"):
			tiles_to_clear.append(tile_pos)

	# Step 2: Remove crosshair nodes and clear flags
	for tile_pos in tiles_to_clear:
		var world_pos = tile_map.to_global(tile_map.map_to_local(tile_pos))

		for item in placed_items_node.get_children():
			if item.position.distance_to(placed_items_node.to_local(world_pos)) < 10:
				item.queue_free()
				break

		# Clear the flag
		Data.set_tile_flag(tile_pos, "hasCrosshair", false)
	
func move_alien_towards(
	alien: Node2D, 
	target_tile: Vector2i, 
	tileMapLayer: TileMapLayer, 
	aliensNode: Node2D,
	steps: int = 2
) -> void:
	await get_tree().create_timer(1).timeout

	var alien_global_pos = alien.get_global_position()
	var tilemap_local_pos = tileMapLayer.to_local(alien_global_pos)
	var current_tile = tileMapLayer.local_to_map(tilemap_local_pos)
	
	Data.set_tile_flag(current_tile, "hasAlien", false)

	for i in range(steps):
		var direction = (target_tile - current_tile).sign()
		var next_tile = current_tile + direction
		if not tileMapLayer.get_used_cells().has(next_tile):
			break
		current_tile = next_tile

	var new_tile_pos = tileMapLayer.map_to_local(current_tile)
	alien.global_position = tileMapLayer.to_global(new_tile_pos)

	Data.set_tile_flag(current_tile, "hasAlien", true)

	var placed_items_node = get_node("/root/Main/PlacedItems")  # Adjust to match your node path
	for item in placed_items_node.get_children():
		var item_tile = tileMapLayer.local_to_map(tileMapLayer.to_local(item.global_position))
		if item_tile == current_tile and Data.get_tile_flag(item_tile,"hasCrosshair") == false:
			item.queue_free()
			determinerBuildingToRemove(item_tile)
			break

	if current_tile == target_tile:
		emit_signal("game_over")
		
	await get_tree().create_timer(0.5).timeout
	
	
func determinerBuildingToRemove(tile:Vector2i) -> void:
	if Data.get_tile_flag(tile,"house"):
		Data.houses -=1
	if Data.get_tile_flag(tile,"mine"):
		Data.mines -=1
	if Data.get_tile_flag(tile,"generator"):
		Data.generators -=1
	if Data.get_tile_flag(tile,"farm"):
		Data.farms -=1
	if Data.get_tile_flag(tile,"turret"):
		Data.turrets -=1

func get_outskirts_tiles() -> Array:
	var tileMapLayer = get_node("/root/Main/TileMapLayer")
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
	
func reset_turret_charges() -> void:
	States.remainingShots = Data.turrets
	emit_signal("day_ended")
	
