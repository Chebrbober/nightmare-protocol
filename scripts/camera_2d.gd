extends Camera2D

@export var zoom_speed: float = 0.01
@export var move_speed: float = 5
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		position.x -= move_speed
	if Input.is_action_pressed("move_right"):
		position.x += move_speed
	if Input.is_action_pressed("move_up"):
		position.y -= move_speed
	if Input.is_action_pressed("move_down"):
		position.y += move_speed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_just_pressed("zoom_in"):
				zoom_camera(zoom_speed)
				get_tree().root.set_input_as_handled()
			elif Input.is_action_just_pressed("zoom_out"):
				zoom_camera(-zoom_speed)
				get_tree().root.set_input_as_handled()

func zoom_camera(delta: float):
	var new_zoom = zoom.x + delta
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
