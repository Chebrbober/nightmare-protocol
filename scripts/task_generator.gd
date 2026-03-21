class_name TaskGenerator
extends Node

const GREETINGS = [
	"Так, мы всё-таки заснули. Вот каким инструкциям мы должны следовать...",
	"О! Дождались! Этот начал дрыхнуть. Что он у нас там просит?",
	"Сразу же перейдём к делу, лень ждать."
]

const EASY_TEMPLATES = [
	"{greetings}\nХочу чтобы {object} {action}, но {condition}",
	"{greetings}\nСделай так чтобы {object} {action}, однако {condition}",
	"{greetings}\n{object} должен {action}, но при этом {condition}",
]

const HARD_TEMPLATES = [
	"{greetings}\nХочу чтобы {object_a} {action}, но {object_a} не должен {restriction}, а {object_b} при этом {side_effect}",
	"{greetings}\nСделай так чтобы {object_a} {action}, однако {object_b} должен {side_effect}, при этом {object_a} не {restriction}",
	"{greetings}\n{object_a} должен {action}, но не {restriction}. И ещё — {object_b} должен {side_effect}",
]

const TAG_ACTIONS = {
	"gravity": ["падал медленно", "летел вверх", "парил на месте", "не падал"],
	"speed": ["двигался быстро", "еле полз", "мчался", "остановился"],
	"temperature": ["оставался холодным", "не таял", "нагрелся", "заморозил всё вокруг"],
	"electric": ["светился", "искрил", "не проводил ток", "заряжался"],
}

const RESTRICTIONS = [
	"касался поверхности",
	"выходил за границы",
	"касался других объектов",
	"нагревался",
]

const SIDE_EFFECTS = [
	"опустился вниз",
	"начал вращаться",
	"остался на месте",
	"полетел вправо",
	"засветился",
	"замер",
]

const TEMPLATES = [EASY_TEMPLATES, HARD_TEMPLATES]


func generate(objects: Array, properties: Array) -> String:
	if objects.is_empty() or properties.is_empty():
		return "Сделай что-нибудь интересное!"

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
	for tag in prop.compatible_tags:
		if tag in TAG_ACTIONS:
			result.append_array(TAG_ACTIONS[tag])
	if result.is_empty():
		result = ["делал что-то необычное", "вёл себя странно"]
	return result
