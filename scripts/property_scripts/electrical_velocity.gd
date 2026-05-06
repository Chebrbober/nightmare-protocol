class_name ElectricalVelocityProperty
extends Node

@export_range(0, 1000000) var power: float = 1000.0
@export_range(0, 360) var angle: float = 0.0


func _ready() -> void:
	name = "ElectricalVelocity"


func _physics_process(delta: float) -> void:
	var body = get_parent() as RigidBody2D
	if not body.is_in_group("powered"):
		return
	if body.sleeping or body.freeze:
		body.sleeping = false
		body.freeze = false

	var dir_vector = Vector2.RIGHT.rotated(deg_to_rad(angle))
	body.apply_central_force(dir_vector * power)
