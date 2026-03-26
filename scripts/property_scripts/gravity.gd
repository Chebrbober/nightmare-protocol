class_name GravityProperty
extends Node

@export_range(-8.0, 8.0, 0.01) var gravity: float = 1.0


func _ready() -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()

	name = "GravityProperty"

	if body and body is RigidBody2D:
		body.gravity_scale = gravity
	else:
		push_error("Gravity property requires RigidBody2D in hierarchy")


func _physics_process(_delta: float) -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()

	if body is RigidBody2D:
		body.gravity_scale = gravity
