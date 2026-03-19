extends Control

signal connected(from_point, to_point)
signal drag_started(from_point)

var circle_size: Vector2 = Vector2(8, 8)
var is_dragging: bool = false
var owner_node: Node


func _process(_delta: float) -> void:
	var panel = get_parent().get_node("PanelContainer")
	position = Vector2(
		panel.position.x + panel.size.x, panel.position.y + panel.size.y / 2.0 - circle_size.y / 2.0
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_started.emit(self)
			else:
				is_dragging = false


func _draw() -> void:
	draw_circle(Vector2(circle_size), 8, Color.WHITE)
