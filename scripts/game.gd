extends Control

@export_dir var path_to_object_resources = "res://resources/objects/"
@export_dir var path_to_property_resources = "res://resources/properties/"
@onready
var attribute_button: AttributeButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton
@onready var spawn_area: Area2D = $SpawnArea
@onready var collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var task_node: Control = $Task
@onready var drag_line: Line2D = $DragLine

var current_attribute_data: AttributeData
var dragging_from: Control

var task_generator: TaskGenerator
var connections: Dictionary = {}
var connection_lines: Dictionary = {}
var property_list = []
var object_list = []
var active_connection: Dictionary = {}


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
					var attribute_button_instance = (
						preload("res://scenes/attribute_button.tscn").instantiate()
						as AttributeButton
					)
					attribute_button_instance.attribute_data = object_data
					attribute_button_instance.text = object_data.name
					attribute_button_instance.tooltip_text = object_data.description
					attribute_button_instance.icon = object_data.texture
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(
						attribute_button_instance
					)
					attribute_button_instance.connect(
						"attribute_toggled", Callable(self, "_on_attribute_button_toggled")
					)
					object_list.append(object_data)

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
					var attribute_button_instance = (
						preload("res://scenes/attribute_button.tscn").instantiate()
						as AttributeButton
					)
					attribute_button_instance.attribute_data = property_data
					attribute_button_instance.text = property_data.name
					attribute_button_instance.visible = true
					$MarginContainer/PanelContainer/MarginContainer/VBoxContainer.add_child(
						attribute_button_instance
					)
					attribute_button_instance.connect(
						"attribute_toggled", Callable(self, "_on_attribute_button_toggled")
					)
					property_list.append(property_data)

			file_name = property_res_dir.get_next()

	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AttributeButton.visible = false

	task_generator = TaskGenerator.new()
	add_child(task_generator)
	generate_task()


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
	print("Compile button pressed")
	var all_nodes = get_tree().get_nodes_in_group("objects")
	for node in all_nodes:
		if node is Object:
			node.set_process(true)


func _on_property_drag_started(from_point: Control) -> void:
	dragging_from = from_point
	drag_line.start(from_point)

	await get_tree().create_timer(0.0).timeout
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		await get_tree().process_frame

	var connection_made = _try_connect(get_global_mouse_position())
	if not connection_made:
		drag_line.stop()


func _on_spawn_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_attribute_data is ObjectData:
			print("Spawning object: ", current_attribute_data.name)
			var object_data = current_attribute_data as ObjectData
			var object_scene = load("res://scenes/object.tscn") as PackedScene
			var object_instance = object_scene.instantiate()
			object_instance.position = event.position
			add_child(object_instance)
			object_instance.setup(object_data)
		elif current_attribute_data is PropertyData:
			print("Spawning property: ", current_attribute_data.name)
			var property_data = current_attribute_data as PropertyData
			var property_scene = load("res://scenes/property.tscn") as PackedScene
			var property_instance = property_scene.instantiate()
			property_instance.position = event.position
			add_child(property_instance)
			property_instance.setup(property_data)
			property_instance.drag_started.connect(_on_property_drag_started)


func _try_connect(mouse_pos: Vector2) -> bool:
	var all_objects = get_tree().get_nodes_in_group("objects")
	for obj in all_objects:
		if not obj is RigidBody2D:
			continue
		var sprite = obj.get_node("Sprite2D")
		if not sprite or not sprite.texture:
			continue
		var texture_size = sprite.texture.get_size()
		var obj_rect = Rect2(obj.global_position - texture_size / 2, texture_size)
		if obj_rect.has_point(mouse_pos):
			_make_connection(dragging_from.owner_node, obj)
			return true
	return false


func _make_connection(property: Node, obj: RigidBody2D) -> void:
	var prop_data = property.current_data as PropertyData
	var obj_data = obj.current_data as ObjectData

	for tag in prop_data.incompatible_tags:
		if tag in obj_data.tags:
			print("Incompatible: ", tag)
			return

	if not connections.has(obj):
		connections[obj] = []
	connections[obj].append(property)

	drag_line.is_persistent = true
	drag_line.active = true

	if not connection_lines.has(obj):
		connection_lines[obj] = []
	connection_lines[obj].append({"property": property, "line": drag_line})

	print("Connected: ", prop_data.name, " -> ", obj_data.name)


func _process(_delta: float) -> void:
	for obj in connection_lines.keys():
		if not is_instance_valid(obj):
			connection_lines.erase(obj)
			continue

		for connection in connection_lines[obj]:
			var property = connection["property"]
			var line = connection["line"]

			if not is_instance_valid(property) or not is_instance_valid(line):
				continue

			if line.get_point_count() >= 2:
				var start_pos = (
					property.connection_point.global_position + Vector2(8, 8) - line.global_position
				)
				var end_pos = obj.global_position - line.global_position
				line.set_point_position(0, start_pos)
				line.set_point_position(1, end_pos)


func generate_task() -> void:
	var text = task_generator.generate(object_list, property_list)
	task_node.set_task(text)
