extends Control

const VILLAGE_SCENE_PATH := "res://scenes/village/Village.tscn"

@onready var class_picker: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ClassPicker
@onready var name_input: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/NameInput


func _ready() -> void:
	class_picker.clear()
	class_picker.add_item("Warrior")
	class_picker.add_item("Rogue")
	class_picker.add_item("Mystic")
	class_picker.select(0)
	name_input.text = GameState.player_name
	name_input.grab_focus()


func _on_start_button_pressed() -> void:
	GameState.set_profile(name_input.text, class_picker.get_item_text(class_picker.selected))
	get_tree().change_scene_to_file(VILLAGE_SCENE_PATH)
