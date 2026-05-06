class_name PowerSourceProperty
extends Node

@export_range(1, 10, 0.1) var voltage: float = 5.0


func _ready() -> void:
	var body = get_parent()
	body.body_entered.connect(_on_collide_detected)

	if body and body is RigidBody2D:
		body.add_to_group("powered")
		var sprite = get_parent().get_node("Sprite2D")
		if sprite:
			sprite.modulate = Color(0.8, 0.8, 2.0)


func _on_collide_detected(body: Node):
	if body.is_in_group("conductive") or body.has_node("ConductivityProperty"):
		body.add_to_group("powered")
		if body.has_method("receive_power"):
			body.receive_power(voltage)
