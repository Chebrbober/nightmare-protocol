class_name TaskGenerator
extends Node

var pure_tags: Array = []

const GREETINGS = [
    "Alright, we finally fell asleep. He seems to be very tired of work and wants to rest a bit. Here are the wishes we must fulfill...",
    "Oh! Finally! This one started dozing off. Maybe we can make it happy and get some rest ourselves? What is it asking for?",
    "I'm so tired... Can we just rest for a bit? Sure, but it seems like we have to do some work first. What does it want?",
    "I'm so bored... Can we do something fun? Sure, but it seems like we have to do some work first. What does she or he want?",
    "We should eat to live, but this guy lives to eat... He lost the sense of life... But maybe we can make him happy with some food? What does he want?",
    "Maybe if we fulfill this wish, we can escape this loop? What does it want?",
    "Let's get straight to the point, I'm too lazy to wait >:D"
]

const EASY_TEMPLATES = [
    "{greetings}\nI want {object} to be {action}, but it must stop {condition}",
    "{greetings}\nMake {object} {action}, but it should stop {condition}",
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
    "temperature": {"label": "{intensity} {direction}", "var_name": "temperature"},
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

func generate(objects: Array, properties: Array) -> Dictionary:
    if objects.is_empty() or properties.is_empty():
        return {"text": "Make something entertaining!", "tags": []}

    var prop = properties.pick_random()
    pure_tags = prop.property_tags
    
    var actions = _get_actions_for_property(prop)
    var action = actions.pick_random()

    var template_data = {
        "greetings": GREETINGS.pick_random(),
        "action": action,
        "restriction": RESTRICTIONS.pick_random(),
        "condition": RESTRICTIONS.pick_random(),
        "side_effect": SIDE_EFFECTS.pick_random()
    }

    if objects.size() >= 2 and randi() % 2 == 0:
        var shuffled_obs = objects.duplicate()
        shuffled_obs.shuffle()
        template_data["object_a"] = shuffled_obs[0].name
        template_data["object_b"] = shuffled_obs[1].name
        return { "text": HARD_TEMPLATES.pick_random().format(template_data), "tags": pure_tags }
    else:
        template_data["object"] = objects.pick_random().name
        return { "text": EASY_TEMPLATES.pick_random().format(template_data), "tags": pure_tags }


func _get_actions_for_property(prop: PropertyData) -> Array:
    var result = []

    for tag in prop.property_tags:
        if not PROPERTY_TAGS.has(tag): continue
        
        var config = PROPERTY_TAGS[tag]
        
        if not config.has("var_name"):
            result.append(config["label"])
            continue

        var var_name = config["var_name"]
        var action_label = _calculate_dynamic_action(prop, tag, config)
        result.append(action_label)

    if result.is_empty():
        result = ["behave strangely", "distort reality"]
    return result


func _calculate_dynamic_action(prop: PropertyData, tag: String, config: Dictionary) -> String:
    var temp_node = Node.new()
    temp_node.set_script(prop.logic)
    var prop_list = temp_node.get_property_list()
    
    var adj = "normally"
    var intensity_key = "mid"
    var direction_text = "exist"

    for p in prop_list:
        if p.name == config["var_name"]:
            if p.hint == PROPERTY_HINT_RANGE:
                var parts = p.hint_string.split(",")
                var p_min = float(parts[0])
                var p_max = float(parts[1])

                var available_keys = ["low", "mid", "high"]
                if p_min < 0: available_keys.append("below")
                if p_min <= 0 and p_max >= 0: available_keys.append("zero")

                intensity_key = available_keys.pick_random()
                adj = INTENSITY_ADJECTIVES[intensity_key].pick_random()
            break
    
    match tag:
        "gravity":
            if intensity_key == "zero": direction_text = "hover"
            elif intensity_key == "below": direction_text = "float upwards"
            else: direction_text = "fall downwards"
        "speed":
            var dirs = ["to the right", "to the left", "upwards", "downwards"]
            direction_text = "move " + dirs.pick_random() if intensity_key != "zero" else "stay still"
        "temperature":
            if intensity_key == "zero": direction_text = "stay at room temperature"
            else: direction_text = "radiate heat" if intensity_key != "below" else "chill everything"
        "electric":
            direction_text = "be energized" if intensity_key != "zero" else "stay uncharged"

    temp_node.free()
    return config["label"].format({"intensity": adj, "direction": direction_text}).strip_edges()