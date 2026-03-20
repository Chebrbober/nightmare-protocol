extends Control

@onready var text_label = $PanelContainer/MarginContainer/VBoxContaoiner/Label


func set_ticket(text: String) -> void:
	text_label.text = text


func _on_exit_pressed() -> void:
	hide()
