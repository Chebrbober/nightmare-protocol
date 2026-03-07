extends Button
class_name AttributeButton

@export var object_data: ObjectData

signal attribute_toggled(object_data: ObjectData)

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	emit_signal("attribute_toggled", object_data)
