extends Button


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	scene_manager._change_scene(self, "main_menu")
