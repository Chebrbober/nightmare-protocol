class_name TaskChecker
extends Node


func check_task(task_text: String, connections: Dictionary) -> bool:
	for obj in connections.keys():
		var properties = connections[obj]
		for prop in properties:
			var prop_data = prop.current_data as PropertyData

			if _is_condition_met(obj, prop_data, task_text):
				return true

	return false


func _is_condition_met(obj: RigidBody2D, prop_data: PropertyData, task_text: String) -> bool:
	for tag in prop_data.action_tags:
		if tag in task_text:
			return true
	return false
