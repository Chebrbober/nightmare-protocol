extends Control

signal drag_line_started(from_point: Control)

@export var point_size: Vector2 = Vector2(5, 5)
var is_dragging: bool = false
var owner_node: Node


func _ready() -> void:
	update_point_pos()


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


func update_point_pos() -> void:
	var foldable_container = get_parent().get_node("FoldableContainer")
	if foldable_container.folded:
		position = Vector2(
			foldable_container.position.x + foldable_container.size.x + point_size.x,
			foldable_container.position.y + point_size.y * 2.0
		)
	else:
		position = Vector2(
			foldable_container.position.x + foldable_container.size.x + point_size.x,
			foldable_container.position.y + foldable_container.size.y / 2.0 - point_size.y / 2.0
		)
