extends Node

var hovered_tile: Vector2i = Vector2i(-1, -1)
const NORMAL_SOURCE_ID = 0   #Source ID for common tile set
const OPACITY_SOURCE_ID = 3  #Source ID for tile set with lower opacity

signal marker_placed()
signal handle_left_click

func _ready():
	SignalHub.handle_map_click.connect(_handle_click_on_map)
	SignalHub.handle_map_hover.connect(_handle_hover)
	SignalHub.tileMapLayer_ready.connect(_handle_hover)
	
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
	
func _handle_click_on_map(tileMapLayer : TileMapLayer):
	var mouse_pos = tileMapLayer.get_local_mouse_position()
	var tile_coords = tileMapLayer.local_to_map(mouse_pos)

	if tileMapLayer.get_cell_source_id(tile_coords) != -1:
		States.selected_tile = tile_coords
		if States.shooting:
			place_target_marker(tile_coords,tileMapLayer)
		else:
			_show_build_menu()
			
func _handle_ready(tileMapLayer: TileMapLayer):
	await get_tree().process_frame
	populate_tile_flags_from_tilemap(tileMapLayer)

func _handle_hover(tileMapLayer: TileMapLayer):
	var mouse_pos = tileMapLayer.get_local_mouse_position()
	mouse_pos.y -= 15
	var tile_coords = tileMapLayer.local_to_map(mouse_pos)

	if tile_coords != hovered_tile:
		_update_hovered_tile(tile_coords,tileMapLayer)

func _show_build_menu():
	var menu = get_node("/root/Main/UiScene/BuildMenuCanvas/BuildMenu")
	var viewport_size = get_viewport().get_visible_rect().size
	menu.position = (viewport_size / 2) - (menu.size / 2)
	menu.visible = true

func _update_hovered_tile(new_tile_coords: Vector2i,tileMapLayer: TileMapLayer):
	
	#There can be what seems like a bug in the code where on the hover, the tiles
	# can have a different shade than in the editor. This is because they have lowered opacity
	# so that they are a little bit see through and so the background behind them makes it a little bit
	# different color (with orange background, the hover with have an orange hue)
	
	#this might seems redundant but is actually neccesary
	if _is_valid_tile(hovered_tile,tileMapLayer):
		_set_tile_source(hovered_tile, NORMAL_SOURCE_ID,tileMapLayer)
	if _is_valid_tile(new_tile_coords,tileMapLayer):
		_set_tile_source(new_tile_coords, OPACITY_SOURCE_ID,tileMapLayer)
		hovered_tile = new_tile_coords
	else:
		hovered_tile = Vector2i(-1, -1)
		
func _is_valid_tile(coords: Vector2i,tileMapLayer:TileMapLayer) -> bool:
	# A tile is valid if source ID is not -1 (empty)
	return tileMapLayer.get_cell_source_id(coords) != -1

func _set_tile_source(coords: Vector2i, source_id: int, tileMapLayer: TileMapLayer) -> void:
	# Get current atlas coords and alternative tile for the cell
	var atlas_coords = tileMapLayer.get_cell_atlas_coords(coords)
	var alt_tile = tileMapLayer.get_cell_alternative_tile(coords)

	# If no tile at coords, ignore
	if source_id == -1 or atlas_coords == Vector2i(-1, -1) or alt_tile == -1:
		tileMapLayer.erase_cell(coords)
		return

	# Set the tile at coords with new source ID but keep atlas coords & alternative
	tileMapLayer.set_cell(coords, source_id, atlas_coords, alt_tile)

	# Force immediate update (optional, can be deferred for performance)
	tileMapLayer.update_internals()

func place_target_marker(tile_pos: Vector2i,tileMapLayer: TileMapLayer) -> void:
	var prefabs_node := get_node("/root/Main/Prefabs")
	var placed_items := get_node("/root/Main/PlacedItems")
	# Find the original marker node 
	var original_marker := prefabs_node.get_node("targetCrosshair")
	if original_marker == null:
		print("TargetMarker not found!")
		return

	# Duplicate the marker
	var marker_instance := original_marker.duplicate(true)

	# Convert tile position to world space
	var tile_global_pos := tileMapLayer.to_global(tileMapLayer.map_to_local(tile_pos))

	# Convert to local space of parent node (so it positions correctly)
	var marker_local_pos = prefabs_node.to_local(tile_global_pos)
	marker_instance.position = marker_local_pos

	# Add the instance to the scene
	placed_items.add_child(marker_instance)
	
	CustomTileData.set_tile_flag(tile_pos,"hasCrosshair",true)
	emit_signal("marker_placed")

	
