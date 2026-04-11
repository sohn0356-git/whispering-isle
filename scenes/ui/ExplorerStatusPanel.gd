extends Control

var explorer_manager: Node
var _row_labels: Dictionary = {}

@onready var rows_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Rows


func set_manager(manager: Node) -> void:
	explorer_manager = manager
	_rebuild_rows()


func _process(_delta: float) -> void:
	if explorer_manager == null:
		return

	if _row_labels.size() != explorer_manager.get_explorers().size():
		_rebuild_rows()

	for explorer in explorer_manager.get_explorers():
		var explorer_name: String = _get_explorer_name(explorer)
		if explorer_name.is_empty():
			continue

		if not _row_labels.has(explorer_name):
			_rebuild_rows()
			return

		var label: Label = _row_labels.get(explorer_name, null)
		if label == null:
			continue

		label.text = "%s | %s %s | %s | HP %d/%d | STA %d/%d | %dg" % [
			explorer_name,
			_get_explorer_value(explorer, "race_name", ""),
			_get_explorer_value(explorer, "class_name_text", ""),
			_get_explorer_state_name(explorer),
			int(round(float(_get_explorer_value(explorer, "hp", 0.0)))),
			int(round(float(_get_explorer_value(explorer, "max_hp", 0.0)))),
			int(round(float(_get_explorer_value(explorer, "stamina", 0.0)))),
			int(round(float(_get_explorer_value(explorer, "max_stamina", 0.0)))),
			int(_get_explorer_value(explorer, "gold", 0))
		]


func _rebuild_rows() -> void:
	for child in rows_container.get_children():
		child.queue_free()

	_row_labels.clear()

	if explorer_manager == null:
		return

	for explorer in explorer_manager.get_explorers():
		var explorer_name: String = _get_explorer_name(explorer)
		if explorer_name.is_empty():
			continue

		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(0, 32)
		rows_container.add_child(label)
		_row_labels[explorer_name] = label


func _get_explorer_name(explorer) -> String:
	return str(_get_explorer_value(explorer, "explorer_name", ""))


func _get_explorer_state_name(explorer) -> String:
	if explorer == null:
		return "Unknown"

	if explorer is Dictionary:
		var state_value: int = int(explorer.get("state", -1))
		match state_value:
			0:
				return "Idle"
			1:
				return "Prepare"
			2:
				return "Leaving"
			3:
				return "Exploring"
			4:
				return "Returning"
			5:
				return "Resting"
			6:
				return "Shopping"
			_:
				return "Unknown"

	return explorer.get_state_name()


func _get_explorer_value(explorer, key: String, default_value):
	if explorer == null:
		return default_value

	if explorer is Dictionary:
		return explorer.get(key, default_value)

	return explorer.get(key) if key in explorer else default_value
