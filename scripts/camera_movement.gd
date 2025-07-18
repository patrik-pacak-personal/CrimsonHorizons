extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 1.0
@export var max_zoom: float = 2.0

@export var limits_enabled: bool = true
@export var min_pos: Vector2 = Vector2.ZERO
@export var max_pos: Vector2 = Vector2(5000, 5000)

@export var drag_speed: float = 0.6

var is_dragging := false
var drag_start_mouse_pos := Vector2.ZERO
var drag_start_camera_pos := Vector2.ZERO

func _ready():
	zoom = Vector2.ONE

func _process(_delta):
	if limits_enabled:
		global_position.x = clamp(global_position.x, min_pos.x, max_pos.x)
		global_position.y = clamp(global_position.y, min_pos.y, max_pos.y)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(zoom_step)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_dragging = true
				drag_start_mouse_pos = get_viewport().get_mouse_position()
				drag_start_camera_pos = global_position
			else:
				is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var delta = drag_start_mouse_pos - current_mouse_pos
		global_position = (drag_start_camera_pos + (delta / zoom) * drag_speed).round()

func zoom_camera(amount: float):
	var new_zoom = zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
