class_name GravityProperty
extends Node

@export var gravity: float = 1.0
@export var mass: float = 1.0
@export var max_gravity_value: float = 8.0
@export var min_gravity_value: float = -(max_gravity_value)
@export var max_mass_value: float = 1000.0
@export var min_mass_value: float = 0.01


func _ready() -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()

	if body and body is RigidBody2D:
		body.gravity_scale = gravity
		body.mass = mass
	else:
		push_error("Gravity property requires RigidBody2D in hierarchy")


func _physics_process(_delta: float) -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()

	if body is RigidBody2D:
		body.gravity_scale = gravity
		body.mass = mass
