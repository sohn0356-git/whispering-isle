class_name ExplorerAppearanceData
extends RefCounted

var race_name: String = "Human"
var class_name_text: String = "Adventurer"
var body_type: String = "average"
var hair_style: String = "short"
var beard_style: String = "none"
var ear_type: String = "round"
var armor_type: String = "cloth"
var accessory_type: String = "none"
var skin_palette: Array[Color] = []
var hair_palette: Array[Color] = []
var outfit_palette: Array[Color] = []
var beard_palette: Array[Color] = []
var pixel_canvas_size: Vector2i = Vector2i(32, 32)


func _init(config: Dictionary = {}) -> void:
	race_name = config.get("race_name", race_name)
	class_name_text = config.get("class_name_text", config.get("class_name", class_name_text))
	body_type = config.get("body_type", body_type)
	hair_style = config.get("hair_style", hair_style)
	beard_style = config.get("beard_style", beard_style)
	ear_type = config.get("ear_type", ear_type)
	armor_type = config.get("armor_type", armor_type)
	accessory_type = config.get("accessory_type", accessory_type)
	skin_palette = _to_color_array(config.get("skin_palette", skin_palette))
	hair_palette = _to_color_array(config.get("hair_palette", hair_palette))
	outfit_palette = _to_color_array(config.get("outfit_palette", outfit_palette))
	beard_palette = _to_color_array(config.get("beard_palette", beard_palette))
	pixel_canvas_size = config.get("pixel_canvas_size", pixel_canvas_size)


func get_signature() -> String:
	return "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s" % [
		race_name,
		class_name_text,
		body_type,
		hair_style,
		beard_style,
		ear_type,
		armor_type,
		accessory_type,
		_palette_key(skin_palette),
		_palette_key(hair_palette),
		_palette_key(outfit_palette),
		_palette_key(beard_palette),
		"%dx%d" % [pixel_canvas_size.x, pixel_canvas_size.y]
	]


func get_skin_color() -> Color:
	return skin_palette[0] if skin_palette.size() > 0 else Color(0.84, 0.72, 0.62, 1.0)


func get_hair_color() -> Color:
	return hair_palette[0] if hair_palette.size() > 0 else Color(0.31, 0.21, 0.15, 1.0)


func get_outfit_primary() -> Color:
	return outfit_palette[0] if outfit_palette.size() > 0 else Color(0.34, 0.42, 0.58, 1.0)


func get_outfit_secondary() -> Color:
	return outfit_palette[1] if outfit_palette.size() > 1 else get_outfit_primary().darkened(0.2)


func get_beard_color() -> Color:
	return beard_palette[0] if beard_palette.size() > 0 else get_hair_color()


func get_skin_shadow() -> Color:
	return skin_palette[1] if skin_palette.size() > 1 else get_skin_color().darkened(0.18)


func get_hair_shadow() -> Color:
	return hair_palette[1] if hair_palette.size() > 1 else get_hair_color().darkened(0.18)


func _palette_key(palette: Array) -> String:
	var parts: Array[String] = []
	for color_variant in palette:
		parts.append((color_variant as Color).to_html())
	return ",".join(parts)


func _to_color_array(source: Variant) -> Array[Color]:
	var result: Array[Color] = []
	if source is Array:
		for color_variant in source:
			if color_variant is Color:
				result.append(color_variant)
	return result
