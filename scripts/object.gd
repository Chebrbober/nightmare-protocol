extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@export var logic: Script

var values: Dictionary = {}
var current_data: ObjectData
var dragging: bool = false
var sprite_size: Vector2


func _ready() -> void:
	add_to_group("objects")
	input_pickable = true
	freeze = true


func setup(data: ObjectData) -> void:
	current_data = data
	values.clear()

	if sprite and data.texture:
		sprite.texture = data.texture
		sprite_size = sprite.texture.get_size()

	if collision_shape and data.shape:
		collision_shape.shape = data.shape
		collision_shape.shape.set_size(sprite_size)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
			else:
				dragging = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and dragging:
		position += event.relative
