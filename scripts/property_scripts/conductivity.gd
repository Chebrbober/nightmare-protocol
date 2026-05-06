class_name ConductivityProperty
extends Node


func _ready() -> void:
	var body = get_parent()
	body.add_to_group("conductive")
	name = "ConductivityProperty"


func _physics_process(delta: float) -> void:
	var body = get_parent()
	var contacts = body.get_colliding_bodies()
	for c in contacts:
		if c.is_in_group("powered"):
			body.add_to_group("powered")
			_visual_update(true)
			return

	if body.is_in_group("powered"):
		body.remove_from_group("powered")
		_visual_update(false)


func _visual_update(is_on: bool):
	var sprite = get_parent().get_node("Sprite2D")
	if sprite:
		sprite.modulate = Color(0.8, 0.8, 2.0) if is_on else Color(1, 1, 1)
