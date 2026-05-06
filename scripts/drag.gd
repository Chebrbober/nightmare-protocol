extends Button

@onready var sprite: Sprite2D = %Sprite2D

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	if sprite and sprite.texture:
		custom_minimum_size = sprite.texture.get_size()
