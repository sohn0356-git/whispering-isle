extends Control

var _speaker_name: String = ""
var _dialogue_lines: PackedStringArray = PackedStringArray()
var _current_line_index: int = 0
var _active: bool = false

@onready var speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var body_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BodyLabel


func _ready() -> void:
	add_to_group("dialog_box")
	hide()


func start_dialogue(speaker_name: String, dialogue_lines: PackedStringArray) -> void:
	if dialogue_lines.is_empty():
		return

	_speaker_name = speaker_name
	_dialogue_lines = dialogue_lines
	_current_line_index = 0
	_active = true
	show()
	_render_current_line()


func is_active() -> bool:
	return _active


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		advance_dialogue()
		get_viewport().set_input_as_handled()


func advance_dialogue() -> void:
	_current_line_index += 1
	if _current_line_index >= _dialogue_lines.size():
		close_dialogue()
		return

	_render_current_line()


func close_dialogue() -> void:
	_active = false
	_dialogue_lines = PackedStringArray()
	hide()


func _render_current_line() -> void:
	speaker_label.text = _speaker_name
	body_label.text = _dialogue_lines[_current_line_index]
