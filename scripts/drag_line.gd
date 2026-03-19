extends Line2D

var active: bool = false
var from_point: Control


func start(point: Control) -> void:
	active = true
	from_point = point
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)


func stop() -> void:
	active = false
	clear_points()


func _process(_delta: float) -> void:
	if not active:
		return
	set_point_position(0, from_point.global_position + Vector2(8, 8))
	set_point_position(1, get_global_mouse_position())
