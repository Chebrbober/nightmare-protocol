extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
var values: Dictionary = {}
var current_data: ObjectData


func _ready() -> void:
	add_to_group("objects")


func setup(data: ObjectData) -> void:
	current_data = data
	values.clear()

	if sprite and data.texture:
		sprite.texture = data.texture

	if collision_shape and data.shape:
		collision_shape.shape = data.shape

	# if not data.logic:
	# 	return

	# var temp_node = Node.new()
	# temp_node.set_script(data.logic)

	# var properties = temp_node.get_property_list()

	# for prop in properties:
	# 	if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
	# 		continue
	# 	if not (prop.usage & PROPERTY_USAGE_EDITOR):
	# 		continue

	# 	var prop_name = prop.name
	# 	if prop_name.begins_with("_"):
	# 		continue
	# 	var prop_value = temp_node.get(prop_name)
	# 	values[prop_name] = prop_value
	# 	set(prop_name, prop_value)

	# temp_node.free()

