extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@export var logic: Script

var values: Dictionary = {}
var current_data: ObjectData
var dragging: bool = false
var sprite_size: Vector2
var of = Vector2.ZERO


func _ready() -> void:
	add_to_group("objects")
	input_pickable = true


func setup(data: ObjectData) -> void:
	current_data = data
	values.clear()

	if sprite and data.texture:
		sprite.texture = data.texture
		sprite_size = sprite.texture.get_size()

	if collision_shape and data.shape:
		collision_shape.shape = data.shape
		collision_shape.shape.set_size(sprite_size)

func _process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() - of

func _on_drag_button_up() -> void:
	dragging = false

func _on_drag_button_down() -> void:
	dragging = true
	of = get_global_mouse_position() - position
