class_name PowerSourceProperty
extends Node

@export_range(1, 10, 0.1) var voltage: float = 5.0


func _ready() -> void:
	var body = get_parent()

	if body and body is RigidBody2D:
		body.add_to_group("powered")
