class_name ExplorerAppearanceGenerator
extends RefCounted

const CANVAS_SIZE := Vector2i(32, 32)
const TRANSPARENT := Color(0.0, 0.0, 0.0, 0.0)

const SKIN_PALETTES := [
	[Color(0.95, 0.84, 0.74, 1.0), Color(0.81, 0.67, 0.56, 1.0)],
	[Color(0.88, 0.72, 0.60, 1.0), Color(0.73, 0.57, 0.46, 1.0)],
	[Color(0.72, 0.55, 0.43, 1.0), Color(0.58, 0.42, 0.31, 1.0)],
	[Color(0.53, 0.37, 0.28, 1.0), Color(0.39, 0.26, 0.19, 1.0)]
]

const HAIR_PALETTES := [
	[Color(0.16, 0.12, 0.10, 1.0), Color(0.11, 0.08, 0.07, 1.0)],
	[Color(0.38, 0.25, 0.17, 1.0), Color(0.23, 0.15, 0.10, 1.0)],
	[Color(0.78, 0.62, 0.27, 1.0), Color(0.58, 0.44, 0.16, 1.0)],
	[Color(0.72, 0.72, 0.74, 1.0), Color(0.50, 0.50, 0.54, 1.0)],
	[Color(0.64, 0.24, 0.18, 1.0), Color(0.46, 0.16, 0.12, 1.0)]
]

const OUTFIT_PALETTES := {
	"Ranger": [
		[Color(0.28, 0.46, 0.24, 1.0), Color(0.60, 0.47, 0.22, 1.0)],
		[Color(0.19, 0.39, 0.34, 1.0), Color(0.48, 0.52, 0.22, 1.0)]
	],
	"Warrior": [
		[Color(0.49, 0.29, 0.23, 1.0), Color(0.67, 0.64, 0.60, 1.0)],
		[Color(0.33, 0.28, 0.26, 1.0), Color(0.78, 0.45, 0.22, 1.0)]
	],
	"Barbarian": [
		[Color(0.54, 0.23, 0.20, 1.0), Color(0.44, 0.31, 0.18, 1.0)],
		[Color(0.42, 0.18, 0.15, 1.0), Color(0.61, 0.49, 0.31, 1.0)]
	],
	"Rogue": [
		[Color(0.20, 0.22, 0.28, 1.0), Color(0.48, 0.34, 0.24, 1.0)],
		[Color(0.16, 0.19, 0.22, 1.0), Color(0.44, 0.24, 0.18, 1.0)]
	],
	"Mystic Mage": [
		[Color(0.32, 0.35, 0.68, 1.0), Color(0.67, 0.58, 0.88, 1.0)],
		[Color(0.21, 0.27, 0.55, 1.0), Color(0.44, 0.63, 0.88, 1.0)]
	]
}

const RACE_RULES := {
	"Elf": {
		"body_types": ["agile", "light"],
		"hair_styles": ["long", "ponytail", "braided"],
		"beard_styles": ["none"],
		"ear_type": "long",
		"beard_chance": 0.0
	},
	"Dwarf": {
		"body_types": ["stout", "broad"],
		"hair_styles": ["braided", "short", "wild"],
		"beard_styles": ["braided", "full", "short"],
		"ear_type": "round",
		"beard_chance": 0.9
	},
	"Northlander": {
		"body_types": ["broad", "tall"],
		"hair_styles": ["wild", "mohawk", "short"],
		"beard_styles": ["full", "short", "none"],
		"ear_type": "round",
		"beard_chance": 0.45
	},
	"Human": {
		"body_types": ["lean", "average"],
		"hair_styles": ["short", "hood", "ponytail"],
		"beard_styles": ["none", "short"],
		"ear_type": "round",
		"beard_chance": 0.2
	},
	"Astra": {
		"body_types": ["robed", "light"],
		"hair_styles": ["long", "hood", "crest"],
		"beard_styles": ["none"],
		"ear_type": "arcane",
		"beard_chance": 0.0
	}
}

const CLASS_RULES := {
	"Ranger": {"armor_type": "leather", "accessories": ["quiver", "satchel", "cloak"]},
	"Warrior": {"armor_type": "plate", "accessories": ["pauldron", "hammer", "shield"]},
	"Barbarian": {"armor_type": "fur", "accessories": ["totem", "bone", "axe"]},
	"Rogue": {"armor_type": "shadow", "accessories": ["pouch", "dagger", "hood_clasp"]},
	"Mystic Mage": {"armor_type": "robe", "accessories": ["orb", "rune", "mantle"]}
}


static func generate_for(explorer, used_signatures: Dictionary):
	var base_seed: int = hash("%s|%s|%s" % [explorer.explorer_name, explorer.race_name, explorer.class_name_text])

	for attempt in range(12):
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = int(base_seed + attempt * 7919)
		var appearance = _build_appearance(explorer, rng)
		var signature: String = appearance.get_signature()
		if not used_signatures.has(signature):
			used_signatures[signature] = true
			return appearance

	var fallback_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	fallback_rng.randomize()
	var fallback = _build_appearance(explorer, fallback_rng)
	used_signatures[fallback.get_signature() + "|fallback"] = true
	return fallback


static func build_idle_image(appearance) -> Image:
	var canvas_size: Vector2i = appearance.pixel_canvas_size
	var image: Image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)

	var body_rect: Rect2i = _get_body_rect(canvas_size, appearance.body_type)
	var head_rect: Rect2i = _get_head_rect(body_rect, appearance.body_type)
	var outfit_rect: Rect2i = _get_outfit_rect(body_rect, appearance.armor_type)

	_fill_rect(image, body_rect, appearance.get_skin_color())
	_fill_rect(image, Rect2i(body_rect.position.x, body_rect.end.y - 3, body_rect.size.x, 3), appearance.get_skin_shadow())
	_fill_rect(image, head_rect, appearance.get_skin_color())
	_fill_rect(image, Rect2i(head_rect.position.x, head_rect.end.y - 2, head_rect.size.x, 2), appearance.get_skin_shadow())

	_draw_ears(image, head_rect, appearance)
	_draw_hair(image, head_rect, appearance)
	_draw_face(image, head_rect)
	_draw_outfit(image, body_rect, outfit_rect, appearance)
	_draw_accessory(image, body_rect, appearance)
	_draw_beard(image, head_rect, appearance)
	_draw_outline(image)

	return image


static func build_idle_texture(appearance) -> Texture2D:
	return ImageTexture.create_from_image(build_idle_image(appearance))


static func _build_appearance(explorer, rng: RandomNumberGenerator):
	var race_rule: Dictionary = RACE_RULES.get(explorer.race_name, RACE_RULES["Human"])
	var class_rule: Dictionary = CLASS_RULES.get(explorer.class_name_text, CLASS_RULES["Rogue"])
	var beard_style: String = "none"

	if rng.randf() < float(race_rule.get("beard_chance", 0.0)):
		beard_style = _pick_string(rng, race_rule.get("beard_styles", ["none"]))

	return ExplorerAppearanceData.new({
		"race_name": explorer.race_name,
		"class_name_text": explorer.class_name_text,
		"body_type": _pick_string(rng, race_rule.get("body_types", ["average"])),
		"hair_style": _pick_string(rng, race_rule.get("hair_styles", ["short"])),
		"beard_style": beard_style,
		"ear_type": race_rule.get("ear_type", "round"),
		"armor_type": class_rule.get("armor_type", "cloth"),
		"accessory_type": _pick_string(rng, class_rule.get("accessories", ["none"])),
		"skin_palette": _pick_palette(rng, SKIN_PALETTES),
		"hair_palette": _pick_palette(rng, HAIR_PALETTES),
		"beard_palette": _pick_palette(rng, HAIR_PALETTES),
		"outfit_palette": _pick_palette(rng, OUTFIT_PALETTES.get(explorer.class_name_text, OUTFIT_PALETTES["Rogue"])),
		"pixel_canvas_size": CANVAS_SIZE
	})


static func _get_body_rect(canvas_size: Vector2i, body_type: String) -> Rect2i:
	match body_type:
		"light":
			return Rect2i(canvas_size.x / 2 - 4, 15, 8, 11)
		"agile":
			return Rect2i(canvas_size.x / 2 - 4, 14, 8, 12)
		"lean":
			return Rect2i(canvas_size.x / 2 - 4, 14, 9, 12)
		"stout":
			return Rect2i(canvas_size.x / 2 - 6, 16, 12, 10)
		"broad":
			return Rect2i(canvas_size.x / 2 - 6, 14, 12, 12)
		"tall":
			return Rect2i(canvas_size.x / 2 - 5, 13, 10, 13)
		"robed":
			return Rect2i(canvas_size.x / 2 - 5, 14, 10, 13)
		_:
			return Rect2i(canvas_size.x / 2 - 5, 14, 10, 12)


static func _get_head_rect(body_rect: Rect2i, body_type: String) -> Rect2i:
	var head_width: int = 8
	if body_type == "stout":
		head_width = 9
	elif body_type == "light":
		head_width = 7

	return Rect2i(body_rect.position.x + (body_rect.size.x - head_width) / 2, body_rect.position.y - 7, head_width, 7)


static func _get_outfit_rect(body_rect: Rect2i, armor_type: String) -> Rect2i:
	match armor_type:
		"robe":
			return Rect2i(body_rect.position.x, body_rect.position.y + 1, body_rect.size.x, body_rect.size.y)
		"plate":
			return Rect2i(body_rect.position.x, body_rect.position.y, body_rect.size.x, body_rect.size.y - 2)
		"fur":
			return Rect2i(body_rect.position.x, body_rect.position.y, body_rect.size.x, body_rect.size.y - 1)
		_:
			return Rect2i(body_rect.position.x + 1, body_rect.position.y + 1, maxi(body_rect.size.x - 2, 1), body_rect.size.y - 2)


static func _draw_ears(image: Image, head_rect: Rect2i, appearance) -> void:
	if appearance.ear_type == "round":
		return

	var ear_color: Color = appearance.get_skin_shadow()
	var left_x: int = head_rect.position.x - 1
	var right_x: int = head_rect.end.x
	var mid_y: int = head_rect.position.y + 3

	_set_pixel_safe(image, left_x, mid_y, ear_color)
	_set_pixel_safe(image, right_x, mid_y, ear_color)

	if appearance.ear_type == "long":
		_set_pixel_safe(image, left_x - 1, mid_y + 1, ear_color)
		_set_pixel_safe(image, right_x + 1, mid_y + 1, ear_color)
	else:
		_set_pixel_safe(image, left_x - 1, mid_y, ear_color)
		_set_pixel_safe(image, right_x + 1, mid_y, ear_color)


static func _draw_hair(image: Image, head_rect: Rect2i, appearance) -> void:
	var hair_color: Color = appearance.get_hair_color()
	var hair_shadow: Color = appearance.get_hair_shadow()

	match appearance.hair_style:
		"hood":
			_fill_rect(image, Rect2i(head_rect.position.x - 1, head_rect.position.y, head_rect.size.x + 2, 5), hair_color)
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y + 4, head_rect.size.x, 1), hair_shadow)
		"long":
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y, head_rect.size.x, 3), hair_color)
			_fill_rect(image, Rect2i(head_rect.position.x - 1, head_rect.position.y + 3, 2, 5), hair_shadow)
			_fill_rect(image, Rect2i(head_rect.end.x - 1, head_rect.position.y + 3, 2, 5), hair_shadow)
		"ponytail":
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y, head_rect.size.x, 3), hair_color)
			_fill_rect(image, Rect2i(head_rect.position.x + head_rect.size.x / 2 - 1, head_rect.end.y - 1, 2, 4), hair_shadow)
		"braided":
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y, head_rect.size.x, 3), hair_color)
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y + 3, 1, 4), hair_shadow)
			_fill_rect(image, Rect2i(head_rect.end.x - 1, head_rect.position.y + 3, 1, 4), hair_shadow)
		"wild":
			_fill_rect(image, Rect2i(head_rect.position.x - 1, head_rect.position.y, head_rect.size.x + 2, 3), hair_color)
			_set_pixel_safe(image, head_rect.position.x - 2, head_rect.position.y + 1, hair_shadow)
			_set_pixel_safe(image, head_rect.end.x + 1, head_rect.position.y + 1, hair_shadow)
		"mohawk":
			_fill_rect(image, Rect2i(head_rect.position.x + head_rect.size.x / 2 - 1, head_rect.position.y - 1, 2, 5), hair_color)
		"crest":
			_fill_rect(image, Rect2i(head_rect.position.x + head_rect.size.x / 2 - 1, head_rect.position.y - 1, 2, 4), hair_color)
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y + 1, head_rect.size.x, 2), hair_shadow)
		_:
			_fill_rect(image, Rect2i(head_rect.position.x, head_rect.position.y, head_rect.size.x, 2), hair_color)


static func _draw_face(image: Image, head_rect: Rect2i) -> void:
	var eye_color: Color = Color(0.12, 0.08, 0.08, 1.0)
	_set_pixel_safe(image, head_rect.position.x + 2, head_rect.position.y + 3, eye_color)
	_set_pixel_safe(image, head_rect.end.x - 3, head_rect.position.y + 3, eye_color)


static func _draw_outfit(image: Image, body_rect: Rect2i, outfit_rect: Rect2i, appearance) -> void:
	var primary: Color = appearance.get_outfit_primary()
	var secondary: Color = appearance.get_outfit_secondary()

	_fill_rect(image, outfit_rect, primary)
	_fill_rect(image, Rect2i(outfit_rect.position.x, outfit_rect.position.y, outfit_rect.size.x, 2), secondary)

	if appearance.armor_type == "plate":
		_fill_rect(image, Rect2i(outfit_rect.position.x + 1, outfit_rect.position.y + 3, outfit_rect.size.x - 2, 2), secondary)
	elif appearance.armor_type == "fur":
		_fill_rect(image, Rect2i(outfit_rect.position.x, outfit_rect.position.y, outfit_rect.size.x, 1), secondary.lightened(0.08))
	elif appearance.armor_type == "robe":
		_fill_rect(image, Rect2i(outfit_rect.position.x + 1, outfit_rect.end.y - 3, maxi(outfit_rect.size.x - 2, 1), 3), secondary)
	elif appearance.armor_type == "shadow":
		_fill_rect(image, Rect2i(outfit_rect.position.x, outfit_rect.position.y + 4, outfit_rect.size.x, 2), secondary)

	var leg_y: int = body_rect.end.y - 2
	_fill_rect(image, Rect2i(body_rect.position.x + 1, leg_y, maxi(body_rect.size.x / 2 - 1, 1), 2), secondary.darkened(0.12))
	_fill_rect(image, Rect2i(body_rect.position.x + body_rect.size.x / 2, leg_y, maxi(body_rect.size.x / 2 - 1, 1), 2), secondary.darkened(0.20))


static func _draw_accessory(image: Image, body_rect: Rect2i, appearance) -> void:
	var accent: Color = appearance.get_outfit_secondary()
	var metal: Color = accent.lightened(0.18)
	match appearance.accessory_type:
		"quiver", "totem", "axe", "hammer":
			_fill_rect(image, Rect2i(body_rect.end.x - 2, body_rect.position.y - 2, 2, 8), accent)
			_fill_rect(image, Rect2i(body_rect.end.x - 1, body_rect.position.y - 3, 3, 3), metal)
		"satchel", "pouch":
			_fill_rect(image, Rect2i(body_rect.position.x - 1, body_rect.position.y + 4, 4, 4), accent)
		"cloak", "mantle":
			_fill_rect(image, Rect2i(body_rect.position.x - 1, body_rect.position.y + 1, 2, body_rect.size.y - 1), accent)
		"pauldron", "shield":
			_fill_rect(image, Rect2i(body_rect.position.x - 2, body_rect.position.y, 3, 5), metal)
		"dagger":
			_fill_rect(image, Rect2i(body_rect.end.x - 2, body_rect.position.y + 3, 1, 6), metal)
		"hood_clasp", "orb", "rune", "bone":
			_fill_rect(image, Rect2i(body_rect.position.x + body_rect.size.x / 2 - 1, body_rect.position.y + 1, 2, 2), metal)


static func _draw_beard(image: Image, head_rect: Rect2i, appearance) -> void:
	if appearance.beard_style == "none":
		return

	var beard_color: Color = appearance.get_beard_color()
	match appearance.beard_style:
		"short":
			_fill_rect(image, Rect2i(head_rect.position.x + 2, head_rect.end.y - 1, head_rect.size.x - 4, 2), beard_color)
		"full":
			_fill_rect(image, Rect2i(head_rect.position.x + 1, head_rect.end.y - 1, head_rect.size.x - 2, 4), beard_color)
		"braided":
			_fill_rect(image, Rect2i(head_rect.position.x + 2, head_rect.end.y - 1, head_rect.size.x - 4, 2), beard_color)
			_fill_rect(image, Rect2i(head_rect.position.x + head_rect.size.x / 2 - 1, head_rect.end.y + 1, 2, 4), beard_color.darkened(0.1))


static func _draw_outline(image: Image) -> void:
	var outline_color: Color = Color(0.08, 0.07, 0.08, 1.0)
	var points: Array[Vector2i] = []
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a <= 0.0:
				continue
			for neighbor in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var nx: int = x + neighbor.x
				var ny: int = y + neighbor.y
				if nx < 0 or ny < 0 or nx >= image.get_width() or ny >= image.get_height() or image.get_pixel(nx, ny).a == 0.0:
					points.append(Vector2i(nx, ny))

	for point in points:
		_set_pixel_safe(image, point.x, point.y, outline_color)


static func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_set_pixel_safe(image, x, y, color)


static func _set_pixel_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)


static func _pick_string(rng: RandomNumberGenerator, source: Array) -> String:
	return source[rng.randi_range(0, source.size() - 1)]


static func _pick_palette(rng: RandomNumberGenerator, palettes: Array) -> Array[Color]:
	var selected: Array = palettes[rng.randi_range(0, palettes.size() - 1)]
	var result: Array[Color] = []
	for color_variant in selected:
		result.append(color_variant)
	return result
