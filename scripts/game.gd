extends Control

@export_dir var path_to_object_resources = "res://resources/objects/"
@export_dir var path_to_property_resources = "res://resources/properties/"
@onready var attribute_button: AttributeButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton
@onready var spawn_area: Area2D = $SpawnArea
@onready var collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D

var current_attribute_data: AttributeData

func _ready() -> void:
	collision_shape.shape.size = self.size
	collision_shape.position = self.size / 2
	var object_res_dir = DirAccess.open(path_to_object_resources)
	var property_res_dir = DirAccess.open(path_to_property_resources)
	if object_res_dir:
		object_res_dir.list_dir_begin()
		var file_name = object_res_dir.get_next()

		while file_name != "":
			if not object_res_dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = path_to_object_resources + file_name
				var attribute_data = load(resource_path) as AttributeData

				if attribute_data is ObjectData:
					var object_data = attribute_data as ObjectData
					var attribute_button_instance = preload("res://scenes/attribute_button.tscn").instantiate() as AttributeButton
					attribute_button_instance.attribute_data = object_data
					attribute_button_instance.text = object_data.name
					attribute_button_instance.tooltip_text = object_data.description
					attribute_button_instance.icon = object_data.texture
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(attribute_button_instance)
					attribute_button_instance.connect("attribute_toggled", Callable(self, "_on_attribute_button_toggled"))

			file_name = object_res_dir.get_next()

	if property_res_dir:
		property_res_dir.list_dir_begin()
		var file_name = property_res_dir.get_next()

		while file_name != "":
			if not property_res_dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = path_to_property_resources + file_name
				var attribute_data = load(resource_path) as AttributeData

				if attribute_data is PropertyData:
					var property_data = attribute_data as PropertyData
					var attribute_button_instance = preload("res://scenes/attribute_button.tscn").instantiate() as AttributeButton
					attribute_button_instance.attribute_data = property_data
					attribute_button_instance.text = property_data.name
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(attribute_button_instance)
					attribute_button_instance.connect("attribute_toggled", Callable(self, "_on_attribute_button_toggled"))

			file_name = property_res_dir.get_next()

	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton.visible = false


func _on_attribute_button_toggled(attribute_data: AttributeData, is_pressed: bool) -> void:
	if is_pressed:
		current_attribute_data = attribute_data
		print("Selected attribute: ", attribute_data.name)
	else:
		current_attribute_data = null
		print("Attribute deselected")	

func _on_exit_pressed() -> void:
	scene_manager._change_scene(self, "main_menu")

func _on_compile_pressed() -> void:
	pass # Replace with function body.

func _on_spawn_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_attribute_data is ObjectData:
			print("Spawning object: ", current_attribute_data.name)
			var object_data = current_attribute_data as ObjectData
			var object_scene = load("res://scenes/object.tscn") as PackedScene
			var object_instance = object_scene.instantiate()
			object_instance.position = event.position
			var sprite = object_instance.get_node("Sprite2D") as Sprite2D
			if sprite:
				sprite.texture = object_data.texture
			var collision_shape = object_instance.get_node("Area2D/CollisionShape2D") as CollisionShape2D
			if collision_shape and object_data.shape:
				collision_shape.shape = object_data.shape
			add_child(object_instance)
		elif current_attribute_data is PropertyData:
			print("Spawning property: ", current_attribute_data.name)
			var property_data = current_attribute_data as PropertyData
			var property_scene = load("res://scenes/property.tscn") as PackedScene
			var property_instance = property_scene.instantiate()
			property_instance.position = event.position
			add_child(property_instance)
			property_instance.setup(property_data)