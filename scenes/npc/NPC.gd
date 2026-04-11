extends Area2D

@export var npc_name: String = "Villager"
@export_multiline var dialogue_lines: PackedStringArray = PackedStringArray(["Hello there."])

var _player_in_range: bool = false

@onready var name_label: Label = $NameLabel


func _ready() -> void:
	name_label.text = npc_name
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not _player_in_range:
		return

	if Input.is_action_just_pressed("interact"):
		var dialog_box = get_tree().get_first_node_in_group("dialog_box")
		if dialog_box and not dialog_box.is_active():
			dialog_box.start_dialogue(npc_name, dialogue_lines)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
