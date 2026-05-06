extends MenuButton

func _ready() -> void:
	get_popup().add_item("Delete Objects")
	get_popup().add_item("Delete Properties")
	get_popup().add_item("Delete All")
	get_popup().connect("id_pressed", Callable(self, "_on_item_pressed"))

func _on_item_pressed(id: int) -> void:
	if id == 0:
		_on_DeleteObjects_pressed()
	elif id == 1:
		_on_DeleteProperties_pressed()
	elif id == 2:
		_on_DeleteAll_pressed()

func _on_DeleteObjects_pressed():
	var game = get_node("../../../..")
	var objects_container = game.objects_container
	for child in objects_container.get_children():
		game.connection_manager.remove_all_connections_for_object(child)
		child.queue_free()

func _on_DeleteProperties_pressed():
	var game = get_node("../../../..")
	var properties_container = game.properties_container
	for child in properties_container.get_children():
		child.queue_free()

func _on_DeleteAll_pressed():
	var game = get_node("../../../..")
	var objects_container = game.objects_container
	var properties_container = game.properties_container
	for child in objects_container.get_children():
		child.queue_free()
	for child in properties_container.get_children():
		child.queue_free()
