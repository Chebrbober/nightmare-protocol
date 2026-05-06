class_name GravityProperty
extends Node

@export_range(-8.0, 8.0, 0.01) var gravity: float = 1.0


func _ready() -> void:
	var body = get_parent()
	name = "GravityProperty"

	body.freeze = false
	body.gravity_scale = gravity


func _physics_process(_delta: float) -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()

	if body is RigidBody2D:
		body.gravity_scale = gravity
