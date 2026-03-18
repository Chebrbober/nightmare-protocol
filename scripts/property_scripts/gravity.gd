extends Node

@export var gravity_value: float = 1.0
@export var mass: float = 1.0
var max_gravity_value: float = 8.0
var min_gravity_value: float = -(max_gravity_value)
var max_mass_value: float = 1000.0
var min_mass_value: float = -(max_mass_value)

func _ready() -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()
	
	if body and body is RigidBody2D:
		body.gravity_scale = gravity_value
		body.mass = mass
	else:
		push_error("Gravity property requires RigidBody2D in hierarchy")

func _physics_process(_delta: float) -> void:
	var body = get_parent()
	while body and not body is RigidBody2D:
		body = body.get_parent()
	
	if body is RigidBody2D:
		body.gravity_scale = gravity_value
		body.mass = mass
