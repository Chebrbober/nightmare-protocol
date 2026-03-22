extends Control

signal drag_line_started(from_point: Control)

@export var point_size: Vector2 = Vector2(5, 5)
var is_dragging: bool = false
var owner_node: Node


func _ready() -> void:
	_on_property_item_rect_changed()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_line_started.emit(self)
			else:
				is_dragging = false


func _draw() -> void:
	draw_circle(Vector2(point_size), 8, Color.WHITE)


func _on_property_item_rect_changed() -> void:
	var panel = get_parent().get_node("PanelContainer")
	position = Vector2(
		panel.position.x + panel.size.x + point_size.x / 2.0,
		panel.position.y + panel.size.y / 2.0 - point_size.y / 2.0
	)
