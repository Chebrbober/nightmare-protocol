extends Button
class_name AttributeButton

@export var attribute_data: AttributeData

signal attribute_toggled(attribute_data: AttributeData, is_pressed: bool)

func _ready() -> void:
	if not is_connected("toggled", Callable(self, "_on_toggled")):
		connect("toggled", Callable(self, "_on_toggled"))


func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	emit_signal("attribute_toggled", attribute_data, button_pressed)
