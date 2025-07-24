extends TileMapLayer

var hovered_tile: Vector2i = Vector2i(-1, -1)
const NORMAL_SOURCE_ID = 0       # Change these to your actual source IDs
const OPACITY_SOURCE_ID = 3

signal marker_placed()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var tile_coords = local_to_map(mouse_pos)
		
		# If the tile is valid and you want to show the menu
		if get_cell_source_id(tile_coords) != -1:
			States.selected_tile = tile_coords
			if States.shooting:
				place_target_marker(tile_coords)
			else:
				var menu = 	 get_node("/root/Main/UiScene/BuildMenuCanvas/BuildMenu")
				var viewport_size = get_viewport().get_visible_rect().size
				menu.position = (viewport_size / 2) - (menu.size / 2)
				menu.visible = true
				
	else:
		var mouse_pos = get_local_mouse_position()
		mouse_pos.y -= 15
		var tile_coords = local_to_map(mouse_pos)

		if tile_coords != hovered_tile:
			# revert previous hovered tile back to normal
			if _is_valid_tile(hovered_tile):
				_set_tile_source(hovered_tile, NORMAL_SOURCE_ID)

			# apply opacity source to new hovered tile
			if _is_valid_tile(tile_coords):
				_set_tile_source(tile_coords, OPACITY_SOURCE_ID)
				hovered_tile = tile_coords
			else:
				hovered_tile = Vector2i(-1, -1)

func _is_valid_tile(coords: Vector2i) -> bool:
	# A tile is valid if source ID is not -1 (empty)
	return get_cell_source_id(coords) != -1

func _set_tile_source(coords: Vector2i, source_id: int) -> void:
	# Get current atlas coords and alternative tile for the cell
	var atlas_coords = get_cell_atlas_coords(coords)
	var alt_tile = get_cell_alternative_tile(coords)

	# If no tile at coords, ignore
	if source_id == -1 or atlas_coords == Vector2i(-1, -1) or alt_tile == -1:
		erase_cell(coords)
		return

	# Set the tile at coords with new source ID but keep atlas coords & alternative
	set_cell(coords, source_id, atlas_coords, alt_tile)

	# Force immediate update (optional, can be deferred for performance)
	update_internals()


func _on_ready() -> void:
	TileMapLayerActions.populate_tile_flags_from_tilemap(self)
			
func place_target_marker(tile_pos: Vector2i) -> void:
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
	var tile_global_pos := self.to_global(self.map_to_local(tile_pos))

	# Convert to local space of parent node (so it positions correctly)
	var marker_local_pos = prefabs_node.to_local(tile_global_pos)
	marker_instance.position = marker_local_pos

	# Add the instance to the scene
	placed_items.add_child(marker_instance)
	
	Data.set_tile_flag(tile_pos,"hasCrosshair",true)
	emit_signal("marker_placed")
