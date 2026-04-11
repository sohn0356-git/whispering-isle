extends Node2D

const EXPLORER_SCENE_PATH := "res://scenes/explorer/Explorer.tscn"

const TILE_SIZE := 16
const MAP_WIDTH := 60
const MAP_HEIGHT := 33

const GRASS := "grass"
const PATH := "path"
const PLAZA := "plaza"
const WALL := "wall"
const ROOF_INN := "roof_inn"
const ROOF_SHOP := "roof_shop"
const FLOOR_INN := "floor_inn"
const FLOOR_SHOP := "floor_shop"
const GATE_STONE := "gate_stone"
const TREE_LEAVES := "tree_leaves"
const TREE_TRUNK := "tree_trunk"
const FENCE := "fence"
const BARREL := "barrel"
const SIGN := "sign"
const LAMP := "lamp"
const GRASS_PATCH := "grass_patch"
const WELL := "well"

const INN_RECT := Rect2i(3, 4, 13, 8)
const SHOP_RECT := Rect2i(40, 4, 13, 8)
const PLAZA_RECT := Rect2i(19, 11, 18, 11)
const GATE_RECT := Rect2i(49, 11, 8, 9)

@onready var environment_root: Node2D = $Environment
@onready var ground_tiles: Node2D = $Environment/GroundTiles
@onready var structure_tiles: Node2D = $Environment/StructureTiles
@onready var decor_tiles: Node2D = $Environment/DecorTiles
@onready var player: CharacterBody2D = $Player
@onready var player_info_label: Label = $CanvasLayer/PlayerInfo
@onready var explorer_manager = $ExplorerManager
@onready var explorers_root: Node2D = $Explorers
@onready var explorer_status_panel = $CanvasLayer/ExplorerStatusPanel

var explorer_nodes: Dictionary = {}
var tile_textures: Dictionary = {}

var idle_positions: Array[Vector2] = [
	_tile_center(24, 15),
	_tile_center(26, 17),
	_tile_center(28, 14),
	_tile_center(31, 16),
	_tile_center(33, 18)
]

var prepare_positions: Array[Vector2] = [
	_tile_center(50, 13),
	_tile_center(52, 14),
	_tile_center(50, 16),
	_tile_center(52, 17),
	_tile_center(54, 15)
]

var shopping_positions: Array[Vector2] = [
	_tile_center(42, 7),
	_tile_center(45, 7),
	_tile_center(42, 9),
	_tile_center(45, 9),
	_tile_center(47, 10)
]

var resting_positions: Array[Vector2] = [
	_tile_center(6, 7),
	_tile_center(8, 7),
	_tile_center(11, 7),
	_tile_center(7, 9),
	_tile_center(10, 9)
]

var return_positions: Array[Vector2] = [
	_tile_center(51, 13),
	_tile_center(53, 14),
	_tile_center(51, 16),
	_tile_center(53, 17),
	_tile_center(55, 15)
]

var labyrinth_gate_position: Vector2 = _tile_center(58, 15)


func _ready() -> void:
	_ensure_input_actions()
	_build_pixel_village()
	player_info_label.text = "%s the %s" % [GameState.player_name, GameState.player_class]
	explorer_status_panel.set_manager(explorer_manager)
	explorer_manager.explorers_updated.connect(_on_explorers_updated)
	_spawn_explorer_nodes()
	_on_explorers_updated(explorer_manager.get_explorers())


func _ensure_input_actions() -> void:
	_add_input_action("move_left", KEY_A, KEY_LEFT)
	_add_input_action("move_right", KEY_D, KEY_RIGHT)
	_add_input_action("move_up", KEY_W, KEY_UP)
	_add_input_action("move_down", KEY_S, KEY_DOWN)
	_add_input_action("interact", KEY_E)


func _add_input_action(action_name: StringName, primary_key: Key, secondary_key: Key = KEY_NONE) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	_add_key_event_if_missing(action_name, primary_key)

	if secondary_key != KEY_NONE:
		_add_key_event_if_missing(action_name, secondary_key)


func _add_key_event_if_missing(action_name: StringName, keycode: Key) -> void:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return

	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, input_event)


func _build_pixel_village() -> void:
	_clear_environment_layers()
	_build_tile_textures()
	_fill_ground()
	_paint_paths()
	_paint_buildings()
	_paint_gate()
	_paint_decor()


func _clear_environment_layers() -> void:
	for layer in [ground_tiles, structure_tiles, decor_tiles]:
		for child in layer.get_children():
			child.queue_free()


func _build_tile_textures() -> void:
	tile_textures = {
		GRASS: _create_tile_texture(Color(0.23, 0.43, 0.20, 1.0), Color(0.29, 0.50, 0.25, 1.0), Color(0.17, 0.34, 0.16, 1.0)),
		PATH: _create_tile_texture(Color(0.63, 0.54, 0.38, 1.0), Color(0.70, 0.61, 0.43, 1.0), Color(0.52, 0.45, 0.32, 1.0)),
		PLAZA: _create_tile_texture(Color(0.59, 0.58, 0.53, 1.0), Color(0.68, 0.67, 0.61, 1.0), Color(0.48, 0.47, 0.42, 1.0)),
		WALL: _create_tile_texture(Color(0.62, 0.51, 0.37, 1.0), Color(0.73, 0.63, 0.47, 1.0), Color(0.46, 0.37, 0.28, 1.0)),
		ROOF_INN: _create_tile_texture(Color(0.53, 0.22, 0.19, 1.0), Color(0.65, 0.28, 0.23, 1.0), Color(0.37, 0.14, 0.12, 1.0)),
		ROOF_SHOP: _create_tile_texture(Color(0.22, 0.33, 0.54, 1.0), Color(0.29, 0.43, 0.66, 1.0), Color(0.15, 0.22, 0.38, 1.0)),
		FLOOR_INN: _create_tile_texture(Color(0.74, 0.64, 0.47, 1.0), Color(0.82, 0.72, 0.54, 1.0), Color(0.60, 0.51, 0.36, 1.0)),
		FLOOR_SHOP: _create_tile_texture(Color(0.70, 0.60, 0.42, 1.0), Color(0.79, 0.69, 0.50, 1.0), Color(0.56, 0.47, 0.31, 1.0)),
		GATE_STONE: _create_tile_texture(Color(0.28, 0.30, 0.35, 1.0), Color(0.35, 0.38, 0.44, 1.0), Color(0.19, 0.21, 0.25, 1.0)),
		TREE_LEAVES: _create_tile_texture(Color(0.18, 0.37, 0.16, 1.0), Color(0.25, 0.49, 0.22, 1.0), Color(0.12, 0.26, 0.11, 1.0)),
		TREE_TRUNK: _create_tile_texture(Color(0.43, 0.28, 0.16, 1.0), Color(0.54, 0.36, 0.20, 1.0), Color(0.31, 0.20, 0.12, 1.0)),
		FENCE: _create_tile_texture(Color(0.57, 0.46, 0.30, 1.0), Color(0.66, 0.55, 0.37, 1.0), Color(0.42, 0.34, 0.22, 1.0)),
		BARREL: _create_tile_texture(Color(0.51, 0.33, 0.18, 1.0), Color(0.63, 0.42, 0.23, 1.0), Color(0.35, 0.22, 0.12, 1.0)),
		SIGN: _create_tile_texture(Color(0.62, 0.47, 0.26, 1.0), Color(0.74, 0.58, 0.33, 1.0), Color(0.45, 0.33, 0.18, 1.0)),
		LAMP: _create_tile_texture(Color(0.84, 0.66, 0.22, 1.0), Color(0.95, 0.83, 0.42, 1.0), Color(0.48, 0.34, 0.10, 1.0)),
		GRASS_PATCH: _create_tile_texture(Color(0.20, 0.49, 0.18, 1.0), Color(0.31, 0.61, 0.25, 1.0), Color(0.14, 0.35, 0.12, 1.0)),
		WELL: _create_tile_texture(Color(0.44, 0.49, 0.56, 1.0), Color(0.57, 0.63, 0.71, 1.0), Color(0.29, 0.33, 0.39, 1.0))
	}


func _fill_ground() -> void:
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			_spawn_tile(ground_tiles, x, y, GRASS)


func _paint_paths() -> void:
	_paint_rect(ground_tiles, PLAZA_RECT, PLAZA)
	_paint_rect(ground_tiles, Rect2i(16, 15, 34, 3), PATH)
	_paint_rect(ground_tiles, Rect2i(9, 12, 3, 6), PATH)
	_paint_rect(ground_tiles, Rect2i(45, 12, 3, 6), PATH)
	_paint_rect(ground_tiles, Rect2i(36, 15, 15, 3), PATH)
	_paint_rect(ground_tiles, Rect2i(24, 22, 8, 4), PATH)


func _paint_buildings() -> void:
	_paint_building(INN_RECT, ROOF_INN, FLOOR_INN)
	_paint_building(SHOP_RECT, ROOF_SHOP, FLOOR_SHOP)


func _paint_building(rect: Rect2i, roof_tile: String, floor_tile: String) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var tile_key := floor_tile
			if y <= rect.position.y + 1:
				tile_key = roof_tile
			elif y == rect.end.y - 1 or x == rect.position.x or x == rect.end.x - 1:
				tile_key = WALL
			_spawn_tile(structure_tiles, x, y, tile_key)


func _paint_gate() -> void:
	_paint_rect(structure_tiles, GATE_RECT, GATE_STONE)
	_paint_rect(structure_tiles, Rect2i(55, 13, 2, 5), GRASS)


func _paint_decor() -> void:
	_paint_fences()
	_paint_trees()
	_paint_signposts()
	_paint_barrels()
	_paint_lamps()
	_paint_grass_patches()
	for well_tile in [Vector2i(28, 15), Vector2i(29, 15), Vector2i(28, 16), Vector2i(29, 16)]:
		_spawn_tile(decor_tiles, well_tile.x, well_tile.y, WELL)


func _paint_fences() -> void:
	for x in range(1, 18):
		_spawn_tile(decor_tiles, x, 2, FENCE)
	for x in range(39, 58):
		_spawn_tile(decor_tiles, x, 2, FENCE)
	for y in range(23, 31):
		_spawn_tile(decor_tiles, 5, y, FENCE)
	for y in range(22, 31):
		_spawn_tile(decor_tiles, 57, y, FENCE)


func _paint_trees() -> void:
	var tree_positions := [
		Vector2i(1, 1), Vector2i(4, 1), Vector2i(8, 24), Vector2i(12, 25),
		Vector2i(54, 3), Vector2i(56, 4), Vector2i(52, 25), Vector2i(55, 26)
	]
	for tree_position in tree_positions:
		_spawn_tile(decor_tiles, tree_position.x, tree_position.y, TREE_LEAVES)
		_spawn_tile(decor_tiles, tree_position.x, tree_position.y + 1, TREE_TRUNK)


func _paint_signposts() -> void:
	for sign_position in [Vector2i(11, 12), Vector2i(43, 12), Vector2i(49, 19)]:
		_spawn_tile(decor_tiles, sign_position.x, sign_position.y, SIGN)


func _paint_barrels() -> void:
	for barrel_position in [Vector2i(14, 12), Vector2i(15, 12), Vector2i(40, 12), Vector2i(41, 12)]:
		_spawn_tile(decor_tiles, barrel_position.x, barrel_position.y, BARREL)


func _paint_lamps() -> void:
	for lamp_position in [Vector2i(21, 14), Vector2i(35, 14), Vector2i(21, 19), Vector2i(35, 19), Vector2i(47, 15)]:
		_spawn_tile(decor_tiles, lamp_position.x, lamp_position.y, LAMP)


func _paint_grass_patches() -> void:
	for patch_position in [
		Vector2i(17, 7), Vector2i(18, 6), Vector2i(33, 5), Vector2i(34, 6),
		Vector2i(15, 25), Vector2i(16, 26), Vector2i(40, 24), Vector2i(41, 25)
	]:
		_spawn_tile(decor_tiles, patch_position.x, patch_position.y, GRASS_PATCH)


func _paint_rect(layer: Node2D, rect: Rect2i, tile_key: String) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_spawn_tile(layer, x, y, tile_key)


func _spawn_tile(layer: Node2D, tile_x: int, tile_y: int, tile_key: String) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = tile_textures[tile_key]
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(tile_x * TILE_SIZE, tile_y * TILE_SIZE)
	sprite.z_index = tile_y
	layer.add_child(sprite)


func _create_tile_texture(primary: Color, highlight: Color, shadow: Color) -> Texture2D:
	var image := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(primary)

	for x in range(TILE_SIZE):
		image.set_pixel(x, 0, highlight)
		image.set_pixel(x, TILE_SIZE - 1, shadow)

	for y in range(TILE_SIZE):
		image.set_pixel(0, y, highlight)
		image.set_pixel(TILE_SIZE - 1, y, shadow)

	for y in range(2, TILE_SIZE - 2, 4):
		for x in range(2 + (y % 3), TILE_SIZE - 2, 5):
			image.set_pixel(x, y, highlight)
			if x + 1 < TILE_SIZE and y + 1 < TILE_SIZE:
				image.set_pixel(x + 1, y + 1, shadow)

	return ImageTexture.create_from_image(image)


func _spawn_explorer_nodes() -> void:
	var explorer_scene := load(EXPLORER_SCENE_PATH)
	if explorer_scene == null:
		push_warning("DNS village: failed to load explorer scene at %s" % EXPLORER_SCENE_PATH)
		return

	for explorer in explorer_manager.get_explorers():
		var explorer_name: String = _get_explorer_name(explorer)
		if explorer_name.is_empty():
			continue

		if explorer_nodes.has(explorer_name):
			continue

		var explorer_node = explorer_scene.instantiate()
		explorers_root.add_child(explorer_node)
		explorer_node.position = _get_state_target_position(explorer)
		explorer_node.z_index = int(explorer_node.position.y)
		explorer_node.bind_explorer(explorer)
		explorer_nodes[explorer_name] = explorer_node


func _on_explorers_updated(explorers: Array) -> void:
	for explorer in explorers:
		var explorer_name: String = _get_explorer_name(explorer)
		if explorer_name.is_empty():
			continue

		if not explorer_nodes.has(explorer_name):
			_spawn_explorer_nodes()
		
		var explorer_node = explorer_nodes.get(explorer_name, null)
		if explorer_node == null:
			continue

		explorer_node.sync_from_data(explorer, _get_state_target_position(explorer), labyrinth_gate_position)
		explorer_node.z_index = int(explorer_node.position.y)


func _get_state_target_position(explorer) -> Vector2:
	var positions: Array[Vector2] = idle_positions

	match _get_explorer_state(explorer):
		ExplorerData.State.PREPARE:
			positions = prepare_positions
		ExplorerData.State.GO_TO_LABYRINTH:
			return labyrinth_gate_position
		ExplorerData.State.RETURNING:
			positions = return_positions
		ExplorerData.State.RESTING:
			positions = resting_positions
		ExplorerData.State.SHOPPING:
			positions = shopping_positions
		_:
			positions = idle_positions

	var village_slot: int = _get_explorer_village_slot(explorer)
	return positions[posmod(village_slot, positions.size())]


func _get_explorer_name(explorer) -> String:
	if explorer == null:
		return ""

	if explorer is Dictionary:
		return str(explorer.get("explorer_name", ""))

	return str(explorer.explorer_name)


func _get_explorer_state(explorer) -> int:
	if explorer == null:
		return ExplorerData.State.IDLE

	if explorer is Dictionary:
		return int(explorer.get("state", ExplorerData.State.IDLE))

	return int(explorer.state)


func _get_explorer_village_slot(explorer) -> int:
	if explorer == null:
		return 0

	if explorer is Dictionary:
		return int(explorer.get("village_slot", 0))

	return int(explorer.village_slot)


static func _tile_center(tile_x: int, tile_y: int) -> Vector2:
	return Vector2(tile_x * TILE_SIZE + TILE_SIZE / 2, tile_y * TILE_SIZE + TILE_SIZE / 2)
