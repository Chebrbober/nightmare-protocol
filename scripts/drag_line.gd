extends Line2D

var active: bool = false
var is_persistent: bool = false
var from_point: Control


func start(point: Control) -> void:
	active = true
	is_persistent = false
	from_point = point
	clear_points()
	var point_size = point.size
	var start_pos = point.global_position + point_size - global_position
	add_point(start_pos)
	add_point(start_pos)


func stop() -> void:
	active = false
	is_persistent = false
	clear_points()


func _process(_delta: float) -> void:
	if not active or is_persistent:
		return
	set_point_position(0, from_point.global_position + from_point.point_size - global_position)
	set_point_position(1, get_global_mouse_position() - global_position)
