extends Node

#building
signal build_requested(building_id: String)

signal show_build_menu()

#tile map layer stuff
signal handle_map_click(tileMapLayer: TileMapLayer)
signal handle_map_hover(tileMapLayer: TileMapLayer)
signal tileMapLayer_ready(tileMapLayer: TileMapLayer)

#turret stuff
signal turret_built()
signal fire_pressed()
signal place_marker(tileCords:Vector2i,tileMapLayer: TileMapLayer)
signal marker_placed()

#game state
signal update_resources_ui()
signal on_reset()

func level_over():
	update_resources_ui.emit()
	on_reset.emit()
	
signal start_night()
signal count_buildings()
signal spawn_aliens()
signal move_aliens()
signal check_for_killed_aliens()
signal remove_destroyed_items()
signal give_resources()
signal check_for_victory()
signal reset_turret_charges()
signal end_night()

func aliens_finished_moving():
	check_for_killed_aliens.emit()
	end_night.emit()
	remove_destroyed_items.emit()

func end_day():
	start_night.emit()
	count_buildings.emit()
	spawn_aliens.emit()
	move_aliens.emit()
	give_resources.emit()
	check_for_victory.emit()
	reset_turret_charges.emit()
