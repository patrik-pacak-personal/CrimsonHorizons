extends Node

signal finished_movement()

func _ready():
	SignalHub.spawn_aliens.connect(spawn_aliens)
	SignalHub.move_aliens.connect(move_aliens)
	SignalHub.check_for_killed_aliens.connect(check_for_killed_aliens)

func spawn_aliens():
	var tileMapLayer = get_node("/root/Main/GameplayScene/TileMapLayer")
	var prefabsNode = get_node("/root/Main/GameplayScene/Prefabs")
	var aliensNode = get_node("/root/Main/GameplayScene/AliensContainer")	

	if  (randi() % 2) == 1:		
		var outskirts_tiles := HexTilesUtils.get_outskirts_tiles()
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
		
		
func check_for_killed_aliens():
	for tile_pos in CustomTileData.tile_flags.keys():
		if CustomTileData.get_tile_flag(tile_pos, "hasAlien") and CustomTileData.get_tile_flag(tile_pos, "hasCrosshair"):
			kill_alien(tile_pos)

func kill_alien(tile_pos: Vector2i):
	var aliens_node = get_node("/root/Main/GameplayScene/AliensContainer")
	var placed_items_node = get_node("/root/Main/GameplayScene/PlacedItemsContainer")
	var tile_map = get_node("/root/Main/GameplayScene/TileMapLayer")

	# Get world position of the tile
	var world_pos = tile_map.to_global(tile_map.map_to_local(tile_pos))

	# Look for alien at that tile position
	for alien in aliens_node.get_children():
		if alien.position.distance_to(aliens_node.to_local(world_pos)) < 10:
			alien.queue_free()
			break

	# Clear flags from Data
	CustomTileData.set_tile_flag(tile_pos, "hasAlien", false)
	
func move_aliens():
	await get_tree().create_timer(1).timeout
	var tileMapLayer = get_node("/root/Main/GameplayScene/TileMapLayer")
	var aliensNode = get_node("/root/Main/GameplayScene/AliensContainer")	
	var center_tile: Vector2i = CustomTileData.find_center_tile()
	if center_tile == Vector2i.ZERO:
			print("Center tile not found!")
			return
		
	for alien in aliensNode.get_children():
		await move_alien_towards(alien, center_tile,tileMapLayer,aliensNode)
	
	#hacky way to make the SignalHub to wait until it hides the night shader panel
	SignalHub.aliens_finished_moving()	

func move_alien_towards(
	alien: Node2D, 
	target_tile: Vector2i, 
	tileMapLayer: TileMapLayer, 
	aliensNode: Node2D,
	steps: int = 2
) -> void:
	
	var alien_global_pos = alien.get_global_position()
	var tilemap_local_pos = tileMapLayer.to_local(alien_global_pos)
	var current_tile = tileMapLayer.local_to_map(tilemap_local_pos)
	
	CustomTileData.set_tile_flag(current_tile, "hasAlien", false)

	for i in range(steps):
		var direction = (target_tile - current_tile).sign()
		var next_tile = current_tile + direction
		if not tileMapLayer.get_used_cells().has(next_tile):
			break
		current_tile = next_tile

	var new_tile_pos = tileMapLayer.map_to_local(current_tile)
	alien.global_position = tileMapLayer.to_global(new_tile_pos)

	CustomTileData.set_tile_flag(current_tile, "hasAlien", true)

	var placed_items_node = get_node("/root/Main/GameplayScene/PlacedItemsContainer")  # Adjust to match your node path
	for item in placed_items_node.get_children():
		var item_tile = tileMapLayer.local_to_map(tileMapLayer.to_local(item.global_position))
		if item_tile == current_tile and CustomTileData.get_tile_flag(item_tile,"hasCrosshair") == false:
			item.queue_free()
			determineBuildingToRemove(item_tile)
			break

	if current_tile == target_tile:
		SignalHub.game_over.emit()
	
	await get_tree().create_timer(0.5).timeout
	
func determineBuildingToRemove(tile:Vector2i) -> void:
	if CustomTileData.get_tile_flag(tile,Constants.HouseString):
		Resources.houses -=1
	if CustomTileData.get_tile_flag(tile,Constants.MineString):
		Resources.mines -=1
	if CustomTileData.get_tile_flag(tile,Constants.GeneratorString):
		Resources.generators -=1
	if CustomTileData.get_tile_flag(tile,Constants.FarmString):
		Resources.farms -=1
	if CustomTileData.get_tile_flag(tile,Constants.TurretString):
		Resources.turrets -=1
