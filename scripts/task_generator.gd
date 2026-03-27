class_name TaskGenerator
extends Node

const GREETINGS = [
	"Alright, we finally fell asleep. Here are the instructions we must follow...",
	"Oh! Finally! This one started dozing off. What is it asking for?",
	"Let's get straight to the point, I'm too lazy to wait >:D"
]

const EASY_TEMPLATES = [
	"{greetings}\nI want {object} to be able to {action}, but it must stop {condition}",
	"{greetings}\nMake {object} start {action}, but it should stop {condition}",
	"{greetings}\nLet {object} {action}, but ensure it doesn't {condition}",
]

const HARD_TEMPLATES = [
	"{greetings}\nI want {object_a} to start {action} and stop {restriction}, while {object_b} starts {side_effect}",
	"{greetings}\nMake {object_a} able to {action}, but {object_b} must {side_effect}, while {object_a} does not {restriction}",
	"{greetings}\nLet {object_a} {action} but stop {restriction}. Also — {object_b} must {side_effect}",
]

const INTENSITY_ADJECTIVES = {
	"below": ["inverted", "unnaturally", "reversely", "backwards"],
	"zero": ["perfectly still", "weightless", "neutral", "completely balanced"],
	"low": ["gently", "hesitantly", "barely"],
	"mid": ["steadily", "normally", "moderately"],
	"high": ["violently", "uncontrollably", "to the extreme"]
}

const PROPERTY_TAGS = {
	"gravity": {"label": "{direction} {intensity}", "var_name": "gravity"},
	"speed": {"label": "{direction} {intensity}", "var_name": "power"},
	"temperature": {"label": "{intensity}", "var_name": "temperature"},
	"electric": {"label": "{intensity} energized", "var_name": "voltage"},
	"phantomness": {"label": "being unable to collide"},
}

const RESTRICTIONS = [
	"touching the surface",
	"going out of bounds",
	"touching other objects",
]

const SIDE_EFFECTS = [
	"move downwards",
	"rotate",
	"stay in place",
	"fly to the right",
	"emit light",
	"freeze",
]

const TEMPLATES = [EASY_TEMPLATES, HARD_TEMPLATES]


func generate(objects: Array, properties: Array) -> String:
	if objects.is_empty() or properties.is_empty():
		return "Make something entertaining!"

	var prop = properties.pick_random()
	var actions = _get_actions_for_property(prop)
	var action = actions.pick_random()

	if objects.size() >= 2 and randi() % 2 == 0:
		var obj_a = objects.pick_random()
		var obj_b = objects.filter(func(o): return o != obj_a).pick_random()
		var template = HARD_TEMPLATES.pick_random()
		return (
			template
			. format(
				{
					"greetings": GREETINGS.pick_random(),
					"object_a": obj_a.name,
					"object_b": obj_b.name,
					"action": action,
					"restriction": RESTRICTIONS.pick_random(),
					"side_effect": SIDE_EFFECTS.pick_random(),
				}
			)
		)
	else:
		var obj = objects.pick_random()
		var template = EASY_TEMPLATES.pick_random()
		return (
			template
			. format(
				{
					"greetings": GREETINGS.pick_random(),
					"object": obj.name,
					"action": action,
					"condition": RESTRICTIONS.pick_random(),
				}
			)
		)


func _get_actions_for_property(prop: PropertyData) -> Array:
	var result = []

	var temp_node = Node.new()
	temp_node.set_script(prop.logic)
	var prop_list = temp_node.get_property_list()

	for tag in prop.property_tags:
		var config = PROPERTY_TAGS[tag]
		var var_name = config["var_name"]

		for p in prop_list:
			if p.name == var_name and p.hint == PROPERTY_HINT_RANGE:
				var parts = p.hint_string.split(",")
				var p_min = float(parts[0])
				var p_max = float(parts[1])

				var available_keys = ["low", "mid", "high"]
				if p_min < 0:
					available_keys.append("below")
				if p_min <= 0 and p_max >= 0:
					available_keys.append("zero")

				var intensity_key = available_keys.pick_random()
				var adj = INTENSITY_ADJECTIVES[intensity_key].pick_random()

				var direction_text = ""

				if tag == "gravity":
					if intensity_key == "zero":
						direction_text = "hover"
					elif intensity_key == "below":
						direction_text = "float upwards"
					else:
						direction_text = "fall downwards"

				elif tag == "speed":
					var dirs = ["to the right", "to the left", "upwards", "downwards"]
					direction_text = (
						"move " + dirs.pick_random() if intensity_key != "zero" else "stay still"
					)

				elif tag == "temperature":
					direction_text = (
						"radiate heat" if intensity_key != "below" else "chill everything"
					)
					if intensity_key == "zero":
						direction_text = "stay at room temperature"

				var final_label = (
					config["label"]
					. format({"intensity": adj, "direction": direction_text})
					. strip_edges()
				)

				result.append(final_label)
				break

	temp_node.free()

	if result.is_empty():
		result = ["behave strangely", "distort reality"]
	return result
