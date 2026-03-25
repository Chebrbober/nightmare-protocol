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

const TAG_ACTIONS = {
	"gravity": ["fall slowly", "fly upwards", "hover in place", "maintain zero gravity"],
	"speed": ["move fast", "crawl slowly", "dash", "stand still"],
	"temperature": ["stay cold", "refuse to melt", "heat up", "freeze everything around"],
	"electric": ["glow", "spark", "stop conducting electricity", "charge up"],
}

const RESTRICTIONS = [
	"touching the surface",
	"going out of bounds",
	"touching other objects",
	"emitting heat",
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
	for tag in prop.action_tags:
		if tag in TAG_ACTIONS:
			result.append_array(TAG_ACTIONS[tag])
	if result.is_empty():
		result = ["do something unusual", "behave strangely"]
	return result
