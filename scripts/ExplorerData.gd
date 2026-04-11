class_name ExplorerData
extends RefCounted

const ExplorerAppearanceDataScript = preload("res://scripts/ExplorerAppearanceData.gd")

enum State {
	IDLE,
	PREPARE,
	GO_TO_LABYRINTH,
	EXPLORING,
	RETURNING,
	RESTING,
	SHOPPING
}

var explorer_name: String = "Explorer"
var race_name: String = "Human"
var class_name_text: String = "Adventurer"
var sprite_path: String = ""
var hp: float = 20.0
var max_hp: float = 20.0
var stamina: float = 20.0
var max_stamina: float = 20.0
var gold: int = 0
var level: int = 1
var level_progress: float = 0.0
var state: int = State.IDLE
var courage: float = 0.5
var greed: float = 0.5
var caution: float = 0.5
var state_timer: float = 0.0
var last_result: String = "Settling into village life."
var village_slot: int = 0
var portrait_id: String = "portrait_default"
var sprite_id: String = "sprite_default"
var color_tag: String = "default"
var appearance_data = null


func _init(config: Dictionary = {}) -> void:
	explorer_name = config.get("explorer_name", explorer_name)
	race_name = config.get("race_name", race_name)
	class_name_text = config.get("class_name_text", config.get("class_name", class_name_text))
	sprite_path = config.get("sprite_path", sprite_path)
	max_hp = float(config.get("max_hp", max_hp))
	hp = float(config.get("hp", max_hp))
	max_stamina = float(config.get("max_stamina", max_stamina))
	stamina = float(config.get("stamina", max_stamina))
	gold = int(config.get("gold", gold))
	level = int(config.get("level", level))
	level_progress = float(config.get("level_progress", level_progress))
	state = int(config.get("state", state))
	courage = clampf(float(config.get("courage", courage)), 0.0, 1.0)
	greed = clampf(float(config.get("greed", greed)), 0.0, 1.0)
	caution = clampf(float(config.get("caution", caution)), 0.0, 1.0)
	state_timer = float(config.get("state_timer", state_timer))
	last_result = config.get("last_result", last_result)
	village_slot = int(config.get("village_slot", village_slot))
	portrait_id = config.get("portrait_id", portrait_id)
	sprite_id = config.get("sprite_id", sprite_id)
	color_tag = config.get("color_tag", color_tag)
	if config.has("appearance_data"):
		var source = config.get("appearance_data")
		if source is RefCounted:
			appearance_data = source
		else:
			appearance_data = ExplorerAppearanceDataScript.new(source)


func apply_appearance(appearance) -> void:
	appearance_data = appearance


func get_class_name() -> String:
	return class_name_text


func get_state_name() -> String:
	match state:
		State.IDLE:
			return "Idle"
		State.PREPARE:
			return "Prepare"
		State.GO_TO_LABYRINTH:
			return "Leaving"
		State.EXPLORING:
			return "Exploring"
		State.RETURNING:
			return "Returning"
		State.RESTING:
			return "Resting"
		State.SHOPPING:
			return "Shopping"
		_:
			return "Unknown"


func is_visible_in_village() -> bool:
	return state != State.EXPLORING


static func create_default_explorers() -> Array[ExplorerData]:
	return [
		ExplorerData.new({
			"explorer_name": "Lyra",
			"race_name": "Elf",
			"class_name_text": "Ranger",
			"max_hp": 22.0,
			"hp": 22.0,
			"max_stamina": 30.0,
			"stamina": 25.0,
			"gold": 14,
			"courage": 0.72,
			"greed": 0.35,
			"caution": 0.68,
			"state_timer": 1.8,
			"village_slot": 0,
			"portrait_id": "elf_ranger_portrait",
			"sprite_id": "elf_ranger_sprite",
			"sprite_path": "res://assets/sprites/explorers/elf_ranger.png",
			"color_tag": "forest"
		}),
		ExplorerData.new({
			"explorer_name": "Brom",
			"race_name": "Dwarf",
			"class_name_text": "Warrior",
			"max_hp": 30.0,
			"hp": 30.0,
			"max_stamina": 24.0,
			"stamina": 20.0,
			"gold": 10,
			"courage": 0.88,
			"greed": 0.3,
			"caution": 0.38,
			"state_timer": 3.0,
			"village_slot": 1,
			"portrait_id": "dwarf_warrior_portrait",
			"sprite_id": "dwarf_warrior_sprite",
			"sprite_path": "res://assets/sprites/explorers/dwarf_warrior.png",
			"color_tag": "ember"
		}),
		ExplorerData.new({
			"explorer_name": "Korga",
			"race_name": "Northlander",
			"class_name_text": "Barbarian",
			"max_hp": 34.0,
			"hp": 34.0,
			"max_stamina": 28.0,
			"stamina": 24.0,
			"gold": 8,
			"courage": 0.95,
			"greed": 0.4,
			"caution": 0.15,
			"state_timer": 2.6,
			"village_slot": 2,
			"portrait_id": "barbarian_portrait",
			"sprite_id": "barbarian_sprite",
			"sprite_path": "res://assets/sprites/explorers/barbarian.png",
			"color_tag": "crimson"
		}),
		ExplorerData.new({
			"explorer_name": "Sera",
			"race_name": "Human",
			"class_name_text": "Rogue",
			"max_hp": 20.0,
			"hp": 20.0,
			"max_stamina": 32.0,
			"stamina": 26.0,
			"gold": 22,
			"courage": 0.62,
			"greed": 0.93,
			"caution": 0.32,
			"state_timer": 4.1,
			"village_slot": 3,
			"portrait_id": "human_rogue_portrait",
			"sprite_id": "human_rogue_sprite",
			"sprite_path": "res://assets/sprites/explorers/human_rogue.png",
			"color_tag": "gold"
		}),
		ExplorerData.new({
			"explorer_name": "Ione",
			"race_name": "Astra",
			"class_name_text": "Mystic Mage",
			"max_hp": 20.0,
			"hp": 20.0,
			"max_stamina": 26.0,
			"stamina": 19.0,
			"gold": 12,
			"courage": 0.38,
			"greed": 0.24,
			"caution": 0.92,
			"state_timer": 5.0,
			"village_slot": 4,
			"portrait_id": "mystic_mage_portrait",
			"sprite_id": "mystic_mage_sprite",
			"sprite_path": "res://assets/sprites/explorers/mystic_mage.png",
			"color_tag": "arcane"
		})
	]
