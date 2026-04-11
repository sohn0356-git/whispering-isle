extends Node

const VILLAGE_SCENE_PATH := "res://scenes/village/Village.tscn"

@onready var fallback_label: Label = $CanvasLayer/FallbackLabel


func _ready() -> void:
	_load_first_playable_scene()


func _load_first_playable_scene() -> void:
	if not ResourceLoader.exists(VILLAGE_SCENE_PATH):
		_show_fallback("Village scene is not ready yet.\nCreate %s and run again." % VILLAGE_SCENE_PATH)
		push_warning("DNS bootstrap: village scene not found at %s" % VILLAGE_SCENE_PATH)
		return

	var village_scene := load(VILLAGE_SCENE_PATH) as PackedScene
	if village_scene == null:
		_show_fallback("Village scene exists but could not be loaded.\nCheck the scene for import or script errors.")
		push_warning("DNS bootstrap: failed to load village scene at %s" % VILLAGE_SCENE_PATH)
		return

	var village_instance := village_scene.instantiate()
	add_child(village_instance)
	fallback_label.hide()


func _show_fallback(message: String) -> void:
	fallback_label.text = message
	fallback_label.show()
