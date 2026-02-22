class_name SceneManager
extends CanvasLayer

@onready var animation: AnimationPlayer = $TransitionAnimation

var last_scene 
var scene_dir_path: String = "res://scenes/"

func _ready() -> void:
	hide()

func _change_scene(from, to_scene: String) -> void:
	last_scene = from
	var full_path = scene_dir_path + to_scene + ".tscn"
	show()
	animation.play("transition")
	await animation.animation_finished
	from.get_tree().call_deferred("change_scene_to_file", full_path)
	animation.play_backwards("transition")
	await animation.animation_finished
	hide()
