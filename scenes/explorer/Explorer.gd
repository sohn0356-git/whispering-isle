extends Node2D

const ExplorerAppearanceGeneratorScript = preload("res://scripts/ExplorerAppearanceGenerator.gd")

@export var move_speed: float = 72.0
@export var frame_size: Vector2i = Vector2i(32, 32)
@export var animation_columns: int = 3

var explorer_data = null
var target_position: Vector2
var return_spawn_position: Vector2
var _was_visible_in_village: bool = true
var _last_motion: Vector2 = Vector2.DOWN

@onready var visual: Polygon2D = $Visual
@onready var animated_sprite: AnimatedSprite2D = $SpriteRoot/AnimatedSprite2D
@onready var name_label: Label = $NameLabel
@onready var title_label: Label = $TitleLabel
@onready var state_label: Label = $StateLabel


func _ready() -> void:
	target_position = global_position
	return_spawn_position = global_position
	_apply_visuals()


func _process(delta: float) -> void:
	if not visible:
		return

	var previous_position: Vector2 = global_position
	global_position = global_position.move_toward(target_position, move_speed * delta)
	var motion: Vector2 = global_position - previous_position
	if motion.length() > 0.01:
		_last_motion = motion.normalized()

	_update_directional_visuals()


func bind_explorer(data) -> void:
	explorer_data = data
	name = "Explorer_%s" % _get_explorer_name(data)
	if is_node_ready():
		_apply_visuals()


func sync_from_data(data, new_target_position: Vector2, reappear_position: Vector2) -> void:
	if explorer_data == null:
		bind_explorer(data)

	var is_visible_in_village: bool = _is_visible_in_village(data)
	if not _was_visible_in_village and is_visible_in_village:
		global_position = reappear_position

	explorer_data = data
	target_position = new_target_position
	return_spawn_position = reappear_position
	visible = is_visible_in_village
	_was_visible_in_village = is_visible_in_village
	_apply_visuals()


func _apply_visuals() -> void:
	if explorer_data == null or name_label == null or title_label == null or state_label == null or animated_sprite == null:
		return

	name_label.text = _get_explorer_name(explorer_data)
	title_label.text = "%s %s" % [_get_value(explorer_data, "race_name", "Human"), _get_class_name(explorer_data)]
	state_label.text = _get_state_name(explorer_data)

	if _apply_external_sprite_sheet():
		visual.visible = false
	else:
		_apply_generated_texture()

	_update_directional_visuals()


func _apply_external_sprite_sheet() -> bool:
	var sprite_path: String = _get_value(explorer_data, "sprite_path", "")
	if sprite_path.is_empty() or not ResourceLoader.exists(sprite_path):
		return false

	var texture: Texture2D = load(sprite_path) as Texture2D
	if texture == null:
		return false

	animated_sprite.sprite_frames = _build_sheet_frames(texture)
	animated_sprite.visible = true
	animated_sprite.centered = true
	animated_sprite.scale = Vector2.ONE
	return true


func _apply_generated_texture() -> void:
	var appearance = _get_value(explorer_data, "appearance_data", null)
	if appearance == null:
		animated_sprite.visible = false
		visual.visible = true
		visual.color = Color(0.85, 0.85, 0.85, 1.0)
		return

	var texture: Texture2D = ExplorerAppearanceGeneratorScript.build_idle_texture(appearance)
	animated_sprite.sprite_frames = _build_generated_frames(texture)
	animated_sprite.visible = true
	animated_sprite.centered = true
	animated_sprite.scale = Vector2.ONE
	visual.visible = false


func _build_sheet_frames(texture: Texture2D) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	var directions: Dictionary = {
		"front": 0,
		"back": 1,
		"left": 2,
		"right": 3
	}

	for animation_name in directions.keys():
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		var row: int = directions[animation_name]
		for column in range(animation_columns):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(column * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame(animation_name, atlas)

	return frames


func _build_generated_frames(texture: Texture2D) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	for animation_name in [&"front", &"back", &"left", &"right"]:
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.add_frame(animation_name, texture)

	return frames


func _update_directional_visuals() -> void:
	if animated_sprite == null or not animated_sprite.visible or animated_sprite.sprite_frames == null:
		return

	var direction_name: StringName = _get_direction_name()
	if animated_sprite.sprite_frames.has_animation(direction_name) and animated_sprite.animation != direction_name:
		animated_sprite.play(direction_name)


func _get_direction_name() -> StringName:
	if absf(_last_motion.x) > absf(_last_motion.y):
		return &"right" if _last_motion.x > 0.0 else &"left"
	return &"back" if _last_motion.y < 0.0 else &"front"


func _get_explorer_name(explorer) -> String:
	return str(_get_value(explorer, "explorer_name", "Explorer"))


func _get_class_name(explorer) -> String:
	if explorer == null:
		return "Adventurer"
	if explorer is Dictionary:
		return str(explorer.get("class_name_text", explorer.get("class_name", "Adventurer")))
	if explorer.has_method("get_class_name"):
		return explorer.get_class_name()
	return str(_get_value(explorer, "class_name_text", "Adventurer"))


func _get_state_name(explorer) -> String:
	if explorer == null:
		return "Unknown"
	if explorer is Dictionary:
		return str(explorer.get("state_name", "Idle"))
	if explorer.has_method("get_state_name"):
		return explorer.get_state_name()
	return "Idle"


func _is_visible_in_village(explorer) -> bool:
	if explorer == null:
		return true
	if explorer is Dictionary:
		var state_value: int = int(explorer.get("state", -1))
		return state_value != 3
	if explorer.has_method("is_visible_in_village"):
		return explorer.is_visible_in_village()
	return true


func _get_value(source, key: String, default_value):
	if source == null:
		return default_value
	if source is Dictionary:
		return source.get(key, default_value)
	var value = source.get(key)
	return default_value if value == null else value
