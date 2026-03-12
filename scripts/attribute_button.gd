extends Button
class_name AttributeButton

@export var object_data: ObjectData

signal attribute_toggled(object_data: ObjectData)

func _ready() -> void:
	if not is_connected("toggled", Callable(self, "_on_toggled")):
		connect("toggled", Callable(self, "_on_toggled"))


func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	emit_signal("attribute_toggled", object_data)
