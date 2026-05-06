extends Control
@export var settings_menu: String = "res://addons/maaacks_options_menus/examples/scenes/menus/options_menu/master_options_menu_with_tabs.tscn"


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	scene_manager._change_scene(self, "game")

func _on_options_pressed() -> void:
	scene_manager._change_scene(self, settings_menu)
