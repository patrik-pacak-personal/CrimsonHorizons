extends Node

func _ready():
	SignalHub.remove_destroyed_items.connect(remove_all_crosshairs)
	SignalHub.reset_turret_charges.connect(reset_turret_charges)
	SignalHub.fire_pressed.connect(_on_fire_button_pressed)
	SignalHub.place_marker.connect(place_target_marker)
	
func remove_all_crosshairs():
	var placed_items_node = get_node("/root/Main/GameplayScene/PlacedItemsContainer")
	var tile_map = get_node("/root/Main/GameplayScene/TileMapLayer")

	var tiles_to_clear := []

	# Step 1: Find all tiles with a crosshair
	for tile_pos in CustomTileData.tile_flags.keys():
		if CustomTileData.get_tile_flag(tile_pos, "hasCrosshair"):
			tiles_to_clear.append(tile_pos)

	# Step 2: Remove crosshair nodes and clear flags
	for tile_pos in tiles_to_clear:
		var world_pos = tile_map.to_global(tile_map.map_to_local(tile_pos))

		for item in placed_items_node.get_children():
			if item.position.distance_to(placed_items_node.to_local(world_pos)) < 10:
				item.queue_free()
				break

		# Clear the flag
		CustomTileData.set_tile_flag(tile_pos, "hasCrosshair", false)

	
func reset_turret_charges() -> void:
	States.remainingShots = Resources.turrets
	
func _on_fire_button_pressed() -> void:
	if States.shooting == false:
		if States.remainingShots != 0:
			var cursor_texture = preload("res://icons/crosshair.png")
			Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(25, 25))  # Set hotspot to top-left
			States.shooting = true
			States.remainingShots -=1
	else:
		set_default_cursor()
		
func place_target_marker(tile_pos: Vector2i,tileMapLayer: TileMapLayer) -> void:
	var prefabs_node := get_node("/root/Main/GameplayScene/Prefabs")
	var placed_items := get_node("/root/Main/GameplayScene/PlacedItemsContainer")
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
	Resources.energy -=5;
	set_default_cursor()
	SignalHub.marker_placed.emit()	
	
	
func set_default_cursor() -> void:
	Input.set_custom_mouse_cursor(null)
	States.shooting = false
	
	
