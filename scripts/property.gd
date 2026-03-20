extends Control

@onready
var vbox_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var connection_point = $ConnectionPoint
@onready var label = $PanelContainer/MarginContainer/VBoxContainer/TitleBar/Label

var values: Dictionary = {}
var current_data: PropertyData

signal drag_started(from_point)


func setup(data: PropertyData) -> void:
	current_data = data
	label.text = data.name
	values.clear()
	connection_point.owner_node = self

	for child in vbox_container.get_children():
		if child != label:
			vbox_container.remove_child(child)
			child.free()

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
		values[prop_name] = prop_value

		match prop_type:
			TYPE_FLOAT, TYPE_INT:
				_create_slider(prop_name, prop_value, prop_type)

			TYPE_BOOL:
				_create_checkbox(prop_name, prop_value)

			TYPE_COLOR:
				_create_color_picker(prop_name, prop_value)

			TYPE_STRING:
				_create_text_edit(prop_name, prop_value)

	temp_node.free()


func _create_slider(prop_name: String, value: Variant, prop_type: int) -> void:
	var panel_container = PanelContainer.new()

	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 3)
	margin_container.add_theme_constant_override("margin_right", 3)
	margin_container.add_theme_constant_override("margin_top", 3)
	margin_container.add_theme_constant_override("margin_bottom", 3)
	panel_container.add_child(margin_container)

	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)

	var prop_label = Label.new()
	prop_label.text = format_prop_name(prop_name)
	vbox.add_child(prop_label)

	var hbox = HBoxContainer.new()

	var slider = HSlider.new()
	slider.min_value = get_min_value(prop_name, prop_type)
	slider.max_value = get_max_value(prop_name, prop_type)
	slider.step = 1 if prop_type == TYPE_INT else 0.01
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var value_label = Label.new()
	value_label.text = str(value)
	value_label.custom_minimum_size.x = 40

	slider.value_changed.connect(
		func(v):
			values[prop_name] = int(v) if prop_type == TYPE_INT else v
			value_label.text = "%.2f" % v if prop_type == TYPE_FLOAT else str(int(v))
	)

	hbox.add_child(slider)
	hbox.add_child(value_label)
	vbox.add_child(hbox)

	vbox_container.add_child(panel_container)


func _create_checkbox(prop_name: String, value: Variant) -> void:
	var panel_container = PanelContainer.new()

	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 3)
	margin_container.add_theme_constant_override("margin_right", 3)
	margin_container.add_theme_constant_override("margin_top", 3)
	margin_container.add_theme_constant_override("margin_bottom", 3)
	panel_container.add_child(margin_container)

	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)

	var prop_label = Label.new()
	prop_label.text = format_prop_name(prop_name)
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)

	var checkbox = CheckBox.new()
	checkbox.button_pressed = value
	checkbox.toggled.connect(func(v): values[prop_name] = v)

	vbox.add_child(checkbox)
	vbox_container.add_child(panel_container)


func _create_color_picker(
	prop_name: String,
	value: Variant,
) -> void:
	var panel_container = PanelContainer.new()

	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 3)
	margin_container.add_theme_constant_override("margin_right", 3)
	margin_container.add_theme_constant_override("margin_top", 3)
	margin_container.add_theme_constant_override("margin_bottom", 3)
	panel_container.add_child(margin_container)

	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)

	var prop_label = Label.new()
	prop_label.text = format_prop_name(prop_name)
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)

	var picker = ColorPickerButton.new()
	picker.color = value
	picker.color_changed.connect(func(c): values[prop_name] = c)

	vbox.add_child(picker)
	vbox_container.add_child(panel_container)


func _create_text_edit(
	prop_name: String,
	value: Variant,
) -> void:
	var panel_container = PanelContainer.new()

	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 3)
	margin_container.add_theme_constant_override("margin_right", 3)
	margin_container.add_theme_constant_override("margin_top", 3)
	margin_container.add_theme_constant_override("margin_bottom", 3)
	panel_container.add_child(margin_container)

	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)

	var prop_label = Label.new()
	prop_label.text = prop_name
	prop_label.custom_minimum_size.x = 100
	vbox.add_child(prop_label)

	var text_edit = LineEdit.new()
	text_edit.text = str(value)
	text_edit.text_changed.connect(func(v): values[prop_name] = v)

	vbox.add_child(text_edit)
	vbox_container.add_child(panel_container)


func format_prop_name(prop_name: String) -> String:
	return prop_name.capitalize().replace("_", " ")


func get_min_value(prop_name: String, prop_type: int) -> float:
	var min_key = "min_" + prop_name + "_value"
	if min_key in current_data.logic:
		return current_data.logic.get_variable(min_key)
	return 0.0


func get_max_value(prop_name: String, prop_type: int) -> float:
	var max_key = "max_" + prop_name + "_value"
	if max_key in current_data.logic:
		return current_data.logic.get_variable(max_key)
	return 100.0


func _on_drag_started(point: Control) -> void:
	drag_started.emit(point)


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position += event.relative
