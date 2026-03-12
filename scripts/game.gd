extends Control

@export_dir var path_to_object_resources = "res://resources/objects/"
@export_dir var path_to_property_resources = "res://resources/properties/"
@onready var attribute_button: AttributeButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton
@onready var spawn_area: Area2D = $SpawnArea

var current_object_data: ObjectData

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
					var attribute_button_instance = preload("res://scenes/attribute_button.tscn").instantiate() as AttributeButton
					attribute_button_instance.object_data = object_data
					attribute_button_instance.text = object_data.name
					attribute_button_instance.tooltip_text = object_data.description
					attribute_button_instance.icon = object_data.texture
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(attribute_button_instance)
					attribute_button_instance.connect("attribute_toggled", Callable(self, "_on_attribute_button_toggled"))
			file_name = dir.get_next()
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton.visible = false
	
	spawn_area.input_pickable = true

func _process(delta: float) -> void:
	pass

func _on_attribute_button_toggled(object_data: ObjectData) -> void:
	print("Toggled attribute: ", object_data.name)
	current_object_data = object_data

func _on_exit_pressed() -> void:
	scene_manager._change_scene(self, "main_menu")

func _on_compile_pressed() -> void:
	pass # Replace with function body.

func _on_spawn_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print('spawn area input event: ', event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var object_scene = load("res://scenes/object.tscn") as PackedScene
		var object_instance = object_scene.instantiate()
		object_instance.position = event.position
		var sprite = object_instance.get_node("Sprite2D") as Sprite2D
		if sprite:
			sprite.texture = current_object_data.texture
		var collision_shape = object_instance.get_node("Area2D/CollisionShape2D") as CollisionShape2D
		if collision_shape and current_object_data.shape:
			collision_shape.shape = current_object_data.shape
		add_child(object_instance)