extends Node

@export var label: String = "Nothing to edit..."


func _ready() -> void:
	var body = get_parent()
	if body and body is RigidBody2D:
		body.modulate = Color(1, 1, 1, 0.5)
		body.collision_layer = 0
		body.collision_mask = 0
