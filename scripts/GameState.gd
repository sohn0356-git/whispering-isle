class_name GameState
extends Node

static var player_name: String = "Traveler"
static var player_class: String = "Warrior"


static func set_profile(new_name: String, new_class: String) -> void:
	player_name = new_name.strip_edges()
	if player_name.is_empty():
		player_name = "Traveler"

	player_class = new_class
	if player_class.is_empty():
		player_class = "Warrior"


static func reset() -> void:
	player_name = "Traveler"
	player_class = "Warrior"
