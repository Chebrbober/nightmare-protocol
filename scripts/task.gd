extends Control

@onready var text_label = $FoldableContainer/Text


func set_task(text: String) -> void:
	text_label.text = text


func _on_exit_pressed() -> void:
	hide()
