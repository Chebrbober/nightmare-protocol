class_name ConnectionManager


var connections: Dictionary = {}
var connection_lines: Dictionary = {}

const CLICK_THRESHOLD = 5.0


func add_connection(obj: RigidBody2D, property: Node, line: Line2D) -> void:
	if has_connection(obj, property):
		disconnect_property_from_object(obj, property)
	
	if not connections.has(obj):
		connections[obj] = []
	connections[obj].append(property)
	
	if not connection_lines.has(obj):
		connection_lines[obj] = []
	connection_lines[obj].append({"property": property, "line": line})


func disconnect_property_from_object(obj: RigidBody2D, property: Node) -> void:
	var line_index = find_connection_line_index(obj, property)
	if line_index >= 0:
		remove_connection(obj, property, line_index)


func remove_connection(obj: RigidBody2D, property: Node, line_index: int) -> void:
	if not is_instance_valid(obj):
		return
	
	if connection_lines.has(obj) and line_index < connection_lines[obj].size():
		var line = connection_lines[obj][line_index]["line"] as Line2D
		if is_instance_valid(line):
			line.queue_free()
		connection_lines[obj].remove_at(line_index)
		
		if connection_lines[obj].is_empty():
			connection_lines.erase(obj)
	
	if connections.has(obj):
		connections[obj].erase(property)
		if connections[obj].is_empty():
			connections.erase(obj)


func has_connection(obj: RigidBody2D, property: Node) -> bool:
	if not connections.has(obj):
		return false
	return property in connections[obj]

func get_connections(obj: RigidBody2D) -> Array:
	if not connections.has(obj):
		return []
	return connections[obj]


func get_connected_objects(property: Node) -> Array:
	var result = []
	for obj in connections.keys():
		if property in connections[obj]:
			result.append(obj)
	return result


func find_connection_line_index(obj: RigidBody2D, property: Node) -> int:
	if not connection_lines.has(obj):
		return -1
	
	for i in range(connection_lines[obj].size()):
		if connection_lines[obj][i]["property"] == property:
			return i
	return -1


func get_connection_line(obj: RigidBody2D, property: Node) -> Line2D:
	var index = find_connection_line_index(obj, property)
	if index >= 0 and connection_lines.has(obj):
		return connection_lines[obj][index]["line"] as Line2D
	return null


func update_lines() -> void:
	for obj in connection_lines.keys():
		if not is_instance_valid(obj):
			connection_lines.erase(obj)
			continue
		
		for connection in connection_lines[obj]:
			var property = connection["property"]
			var line = connection["line"]
			
			if not is_instance_valid(property) or not is_instance_valid(line):
				continue
			
			if line.get_point_count() >= 2:
				var start_pos = (
					property.connection_point.global_position
					+ property.connection_point.point_size
					- line.global_position
				)
				var end_pos = obj.global_position - line.global_position
				line.set_point_position(0, start_pos)
				line.set_point_position(1, end_pos)


func is_point_near_line(point: Vector2, line: Line2D) -> bool:
	if line.get_point_count() < 2:
		return false
	
	var start = line.get_point_position(0) + line.global_position
	var end = line.get_point_position(1) + line.global_position
	
	var line_vec = end - start
	var point_vec = point - start
	var line_len = line_vec.length()
	
	if line_len == 0:
		return false
	
	var t = clamp(point_vec.dot(line_vec) / (line_len * line_len), 0.0, 1.0)
	var closest = start + line_vec * t
	
	return point.distance_to(closest) < CLICK_THRESHOLD


func try_disconnect_at_point(mouse_pos: Vector2) -> bool:
	for obj in connection_lines.keys():
		for i in range(connection_lines[obj].size() - 1, -1, -1):
			var connection = connection_lines[obj][i]
			var line = connection["line"] as Line2D
			var property = connection["property"]
			
			if not is_instance_valid(line):
				continue
			
			if is_point_near_line(mouse_pos, line):
				remove_connection(obj, property, i)
				return true
	return false


func clear_all() -> void:
	for obj in connection_lines.keys():
		for connection in connection_lines[obj]:
			var line = connection["line"] as Line2D
			if is_instance_valid(line):
				line.queue_free()
	
	connections.clear()
	connection_lines.clear()


func has_any_connections() -> bool:
	return not connections.is_empty()
