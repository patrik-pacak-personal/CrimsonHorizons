extends Node

#building
signal build_requested(building_id: String)

signal show_build_menu()

#tile map layer stuff
signal handle_map_click(tileMapLayer: TileMapLayer)
signal handle_map_hover(tileMapLayer: TileMapLayer)
signal tileMapLayer_ready(tileMapLayer: TileMapLayer)
