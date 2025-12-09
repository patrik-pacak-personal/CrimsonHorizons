extends Node2D

var tilemap_layer: TileMapLayer = null
var placed_items: Node2D = null
var item_prefabs: Node2D = null

var houses =0;
var mines =0;
var generators =0;
var turrets = 0;
var farms = 0;

var building_prefab: PackedScene

signal resources_changed()
signal item_built()
signal turret_built()
signal throw_error(error: String)

func _on_build_requested(name: Variant) -> void:
	if States.selected_tile != Vector2i(-1, -1) and States.shooting == false:
		build_item(name,States.selected_tile)
		
#Connect all the neccesary signals 
func _ready():
	building_prefab = preload("res://scenes/BuildingScene.tscn")
	
	SignalHub.build_requested.connect(_on_build_requested)
	SignalHub.count_buildings.connect(count_buildings)
	SignalHub.on_reset.connect(reset_building_counts)

	
#Set all the neccesary stuff for the builder to work
func set_prefabs(node:Node2D) -> void:
	item_prefabs = node	
func set_placed_items(node: Node2D) -> void:
	placed_items = node
func set_tilemap_layer(layer: TileMapLayer) -> void:
	tilemap_layer = layer

func build_item(item_name: String, tile: Vector2i):
# 1. Get the tile's data from the TileMap
	for pos in tilemap_layer.get_used_cells():
		var id = tilemap_layer.get_cell_source_id(pos)
		if id == -1:
			print("Invalid tile at", pos)

	var base_name = item_name.substr(0, item_name.length() - 1)
	
	if base_name == "mine":
		if check_for_minerals(States.selected_tile) == false:
			SignalHub.throw_error.emit("Mine can be built only around minerals")
			return
	
	if Resources.can_pay(item_name) == false:
		SignalHub.throw_error.emit("Not enough resources to build a "+ base_name)
		return
	
	if CustomTileData.get_tile_flag(States.selected_tile,"occupied"):
		SignalHub.throw_error.emit("This place is already occupied by another building")
		return
		
	var tile_id = tilemap_layer.get_cell_source_id(tile)
	if tile_id == null or tile_id == -1:
		print("tile data is null")
		
	var tile_data = tilemap_layer.get_cell_tile_data(tile)
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
		SignalHub.throw_error.emit("Cannot build here, the terrain is not suitable for buildings")		
		return

	# Create a generic building instance
	var instance = building_prefab.instantiate()

	# Find the correct texture based on item name
	var tex = Constants.building_textures[item_name]

	if tex == null:
		SignalHub.throw_error.emit("Missing texture for " + item_name)
		return

	var tile_global_pos = tilemap_layer.to_global(tilemap_layer.map_to_local(tile))
	var local_pos = placed_items.to_local(tile_global_pos)
	instance.position = local_pos

	placed_items.add_child(instance)
	# Configure the instance
	instance.setup(item_name, tex)

	# Position like before


	Resources.pay_resources(item_name)
	CustomTileData.set_tile_flag(States.selected_tile, "occupied", true)
	CustomTileData.set_tile_flag(States.selected_tile, item_name.substr(0, item_name.length() - 1), true)

	SignalHub.item_built.emit()
	
	if base_name == "turret":
		States.turretBuilt = true
		emit_signal("turret_built")
	
func check_for_minerals(selected_tile: Vector2i) -> bool:
	var neighbors = get_flat_top_neighbors(selected_tile)

	for neighbor in neighbors:
		var tile_data = tilemap_layer.get_cell_tile_data(neighbor)		
		if tile_data and tile_data.get_custom_data("IsMineral"):
			return true

	return false
	
func count_buildings() -> void:
	reset_building_counts()
	for tile_pos in CustomTileData.tile_flags.keys():
		var flags = CustomTileData.tile_flags[tile_pos]

		if flags.get(Constants.HouseString):
			Resources.houses +=1
		if flags.get(Constants.MineString):
			Resources.mines +=1
		if flags.get(Constants.FarmString):
			Resources.farms  +=1
		if flags.get(Constants.TurretString):
			Resources.turrets +=1
		if flags.get(Constants.GeneratorString):
			Resources.generators +=1

func reset_building_counts() -> void:
	Resources.houses =0;
	Resources.mines =0;
	Resources.generators =0;
	Resources.turrets = 0;
	Resources.farms = 0;

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
	
