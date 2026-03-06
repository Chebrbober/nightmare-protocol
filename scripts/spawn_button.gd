extends Button
class_name SpawnButton

@export var attribute: PackedScene

signal attribute_selected(spawn_scene: PackedScene)

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	emit_signal("attribute_selected", attribute)
