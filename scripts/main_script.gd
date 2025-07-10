extends Node2D

var item_prefabs: Node = null
signal resources_changed()
signal item_built()
signal turret_built()
signal throw_error(error: String)

func _on_build_requested(name: Variant) -> void:
	if States.selected_tile != Vector2i(-1, -1) and States.shooting == false:
		build_item(name,States.selected_tile)
		
func _ready():
	var prefab_scene = preload("res://prefabs.tscn")
	item_prefabs = prefab_scene.instantiate()
	item_prefabs.visible = false
	add_child(item_prefabs)     

func build_item(item_name: String, tile: Vector2i):
# 1. Get the tile's data from the TileMap
	var base_name = item_name.substr(0, item_name.length() - 1)
	
	if base_name == "mine":
		if check_for_minerals(States.selected_tile) == false:
			emit_signal("throw_error","Mine can be built only around minerals")
			return
	
	if can_pay(item_name) == false:
		emit_signal("throw_error","Not enough resources to build a "+ base_name)
		return
	
	if Data.get_tile_flag(States.selected_tile,"occupied"):
		emit_signal("throw_error","This place is already occupied by another building")
		return
		
	var tile_id = $TileMapLayer.get_cell_source_id(tile)
	var tile_data = $TileMapLayer.get_cell_tile_data(tile)
	print("Tile ID:", tile_id, "Data:", tile_data)
	if tile_data:
		var can_build = tile_data.get_custom_data("CanBuild")
		print("CanBuild =", can_build, " (type =", typeof(can_build), ")")
	else:
		print("No tile data at", tile)

	# 2. Check custom data layer property "CanBuild"
	var can_build = tile_data.get_custom_data("CanBuild")
	if can_build == false:
		print("Cannot build here! Tile at", tile, "doesn't allow building.")
		emit_signal("throw_error","Cannot build here, the terrain is not suitable for buildings")
		return

	# 3. Load the item prefab
	var original = item_prefabs.get_node_or_null(item_name)
	if original == null:
		print("Item not found:", item_name)
		return


	# 4. Create instance and place it
	var instance = original.duplicate(true)
	var tile_global_pos = $TileMapLayer.to_global($TileMapLayer.map_to_local(tile))
	var local_pos = $PlacedItems.to_local(tile_global_pos)
	instance.position = local_pos
	$PlacedItems.add_child(instance)
	print("Placed", item_name, "at", tile)
	
	pay_resources(item_name)
	Data.set_tile_flag(States.selected_tile, "occupied", true)
	Data.set_tile_flag(States.selected_tile, base_name, true)
	emit_signal("item_built")
	
	if base_name == "turret":
		States.turretBuilt = true		
		emit_signal("turret_built")
			
	
func pay_resources(building_name: String):
	var building = get_building(building_name)

	# Step 3: Pay resource costs
	for key in building.keys():
		if key == "energy":
			var amount = building[key]
			if Data.resources.has("energy"):				
				Data.resources["energy"] -= amount
				emit_signal("resources_changed")
		if key == "minerals":
			var amount = building[key]
			if Data.resources.has("minerals"):
				Data.resources["minerals"] -= amount
				emit_signal("resources_changed")
				
func can_pay(building_name: String) -> bool:
	var building = get_building(building_name)

	for key in building.keys():
		var cost = building[key]
		if not Data.resources.has(key):
			print("Missing resource:", key)
			return false
		if Data.resources[key] < cost:
			print("Not enough", key, "- needed:", cost, "available:", Data.resources[key])
			return false
	return true
				
func get_building(item_name:String) -> Dictionary:
	if item_name.length() <= 1:
		print("Invalid building name.")
		return {}
	# Step 1: Remove the last letter
	var base_name = item_name.substr(0, item_name.length() - 1)

	# Step 2: Look up building data
	if not Data.building_costs.has(base_name):
		print("No building data for:", base_name)
		return {}

	return Data.building_costs[base_name]
	
func check_for_minerals(selected_tile: Vector2i) -> bool:
	var neighbors = get_flat_top_neighbors(selected_tile)

	for neighbor in neighbors:
		var tile_data = $TileMapLayer.get_cell_tile_data(neighbor)
		if tile_data and tile_data.get_custom_data("IsMineral"):
			return true

	return false
	
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
	
