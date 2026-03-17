extends Node2D

@onready var vbox_container = $PanelContainer/MarginContainer/VBoxContainer
@onready var label = vbox_container.get_node("Label")

func setup(data: PropertyData) -> void:
	label.text = data.name
	
	for child in vbox_container.get_children():
		if child != label:
			child.queue_free()
	
	if not data.logic:
		return
	
	var temp_node = Node.new()
	temp_node.set_script(data.logic)
	
	var properties = temp_node.get_property_list()
	
	for prop in properties:
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		if not (prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		
		var prop_name = prop.name
		if prop_name.begins_with("_"):
			continue
		var prop_type = prop.type
		var prop_value = temp_node.get(prop_name)
		
		# Создаём UI элемент в зависимости от типа
		match prop_type:
			TYPE_FLOAT, TYPE_INT:
				_create_slider(prop_name, prop_value, prop_type, temp_node)
			
			TYPE_BOOL:
				_create_checkbox(prop_name, prop_value, temp_node)
			
			TYPE_COLOR:
				_create_color_picker(prop_name, prop_value, temp_node)
			
			TYPE_STRING:
				_create_text_edit(prop_name, prop_value, temp_node)
	
	# Удаляем временный объект
	temp_node.queue_free()


func _create_slider(prop_name: String, value: Variant, prop_type: int, target: Node) -> void:
	var vbox = VBoxContainer.new()
	
	var prop_label = Label.new()
	prop_label.text = prop_name
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)
	
	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 100 if prop_type == TYPE_INT else 1.0
	slider.step = 1 if prop_type == TYPE_INT else 0.01
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	slider.value_changed.connect(func(v):
		if prop_type == TYPE_INT:
			target.set(prop_name, int(v))
		else:
			target.set(prop_name, v)
	)
	
	vbox.add_child(slider)
	vbox_container.add_child(vbox)


func _create_checkbox(prop_name: String, value: Variant, target: Node) -> void:
	var vbox = VBoxContainer.new()
	
	var prop_label = Label.new()
	prop_label.text = prop_name
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)
	
	var checkbox = CheckBox.new()
	checkbox.button_pressed = value
	checkbox.toggled.connect(func(v):
		target.set(prop_name, v)
	)
	
	vbox.add_child(checkbox)
	vbox_container.add_child(vbox)


func _create_color_picker(prop_name: String, value: Variant, target: Node) -> void:
	var vbox = VBoxContainer.new()
	
	var prop_label = Label.new()
	prop_label.text = prop_name
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)
	
	var picker = ColorPickerButton.new()
	picker.color = value
	picker.color_changed.connect(func(v):
		target.set(prop_name, v)
	)
	
	vbox.add_child(picker)
	vbox_container.add_child(vbox)


func _create_text_edit(prop_name: String, value: Variant, target: Node) -> void:
	var vbox = VBoxContainer.new()
	
	var prop_label = Label.new()
	prop_label.text = prop_name
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)
	
	var text_edit = LineEdit.new()
	text_edit.text = str(value)
	text_edit.text_changed.connect(func(v):
		target.set(prop_name, v)
	)
	
	vbox.add_child(text_edit)
	vbox_container.add_child(vbox)
