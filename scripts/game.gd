extends Control

@export_dir var path_to_object_resources = "res://resources/objects/"
@export_dir var path_to_property_resources = "res://resources/properties/"
@onready var attribute_button: AttributeButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton

func _ready() -> void:
	var dir = DirAccess.open(path_to_object_resources)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = path_to_object_resources + file_name
				var object_data = load(resource_path) as ObjectData
				if object_data:
					var attribute_button_instance = attribute_button.duplicate()
					attribute_button_instance.object_data = object_data
					attribute_button_instance.text = object_data.name
					attribute_button_instance.icon = object_data.texture
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(attribute_button_instance)
					attribute_button_instance.connect("attribute_toggled", Callable(self, "_on_attribute_button_toggled"))
			file_name = dir.get_next()
	# Optionally hide or remove the original
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton.visible = false


func _process(delta: float) -> void:
	pass

func _on_attribute_button_toggled(object_data: ObjectData) -> void:
	print("Toggled attribute: ", object_data.name)

func _on_exit_pressed() -> void:
	scene_manager._change_scene(self, "main_menu")

func _on_compile_pressed() -> void:
	pass # Replace with function body.
