class_name LevelEditorPlaceholder extends Node2D

const DEFAULT_RECT = Rect2(-24, -24, 48, 48)
const RECT_MAP: Dictionary = {
	E.PLACE_ONE_WAY: Rect2(-24, -24, 48, 12),
	E.PLACE_BRICK_WALL: Rect2(-48, -48, 96, 96),
	E.PLACE_GNOME: Rect2(-9.75, -30, 21, 54),
	E.PLACE_ELF: Rect2(10.5, -30, 21, 54),
	E.PLACE_COIN: Rect2(-12, -12, 24, 22),
	E.PLACE_SNOWFLAKE: Rect2(-16, -19, 32, 38),
	E.PLACE_ICE_SHARD: Rect2(-12, -21, 24, 42), # colored upon loading
	E.PLACE_FIRE_SHARD: Rect2(-12, -21, 24, 42), # colored upon loading
}
static func get_rect(place_type: String):
	return RECT_MAP[place_type] if RECT_MAP.has(place_type) else DEFAULT_RECT

const DEFAULT_SCALE = 3.0
const SCALE_MAP: Dictionary = {
	E.PLACE_GNOME: 1.5,
	E.PLACE_ELF: 1.5,
	E.PLACE_COIN: 2,
	E.PLACE_SNOWFLAKE: 1.2,
	E.PLACE_ICE_SHARD: 2,
	E.PLACE_FIRE_SHARD: 2,
}
static func get_scle(place_type: String) -> float:
	return SCALE_MAP[place_type] if SCALE_MAP.has(place_type) else DEFAULT_SCALE

const ALT_COLOR_MAP: Dictionary = {
	E.PLACE_ICE_SHARD: Color(0.7, 0.95, 2),
	E.PLACE_FIRE_SHARD: Color(2, 0.75, 0.5)
}
static func get_color(place_type: String) -> Color:
	return ALT_COLOR_MAP[place_type] if ALT_COLOR_MAP.has(place_type) else Color.WHITE

const OFFSET_MAP: Dictionary = {
	E.PLACE_GNOME: Vector2(0, -3),
	E.PLACE_ELF: Vector2(0, -3)
}
static func get_offset(place_type: String) -> Vector2:
	return OFFSET_MAP[place_type] if OFFSET_MAP.has(place_type) else Vector2(0, 0)

const ID = "ID"
const POSITION = "POSITION"
##### Enemies #####
const HAS_NAME = "HAS_NAME"
const RANDOM_NAME = "RANDOM_NAME"
const NAME = "NAME"
### Gnomes ###
const SIZE = "SIZE"

# set upon initialization
var place_type: String
var texture

var data: Dictionary = {}: set = set_data
var selected = false: set = set_selected

func _ready() -> void:
	$Texture.texture = load(E.place_content_texture(place_type))
	$Texture.scale = Vector2.ONE * get_scle(place_type)
	$Texture.modulate = get_color(place_type)
	$Texture.position = get_offset(place_type)
	if data.has(SIZE): set_size(data[SIZE], false)
	else:
		var rect: Rect2 = get_rect(place_type)
		$Rect.position = rect.position
		$Rect.size = rect.size
	
	if data.has(POSITION): position = data[POSITION]
	else: data[POSITION] = position

func set_id(id: int): if !data.has(ID): data[ID] = id
func get_id() -> int: return data.get(ID, -1)

func set_has_name(has_name: bool): data[HAS_NAME] = has_name
func has_name() -> bool: return data.has(HAS_NAME) and data[HAS_NAME]

func set_random_name(random_name: bool): data[RANDOM_NAME] = random_name
func is_random_name() -> bool: return data.has(RANDOM_NAME) and data[RANDOM_NAME]

func set_placeholder_name(placeholder_name): data[NAME] = placeholder_name
func get_placeholder_name() -> String: return data.get(NAME, "")

func set_size(size: int, with_pos_change: bool = true, previous_size: int = get_size()):
	data[SIZE] = size
	$Rect.position = Vector2(-9.75, -30) * size
	$Rect.size = Vector2(21, 54) * size
	$Texture.position.y = -3 * size
	$Texture.scale = Vector2(1.5, 1.5) * size
	if with_pos_change:
		position.y += (previous_size - size) * 24
		if selected: LevelEditor.current.calc_selection_rect()
func get_size() -> int: return data.get(SIZE, 1)

func set_data(new_data: Dictionary):
	var previous_size = get_size()
	data = new_data.duplicate(true)
	if data.has(POSITION) and data[POSITION] is String: data[POSITION] = LevelFile.string_to_vec(data[POSITION])
	if place_type == E.PLACE_GNOME: set_size(get_size(), true, previous_size)
func get_data() -> Dictionary:
	data[POSITION] = position
	return data.duplicate(true)

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	var mat: ShaderMaterial = $Texture.material
	mat.set_shader_parameter("line_thickness", 1 if is_selected else 0)

func get_bounds() -> Rect2:
	return $Rect.get_global_rect()

func is_different_to(other_data: Dictionary) -> bool:
	return has_name() != other_data.get(HAS_NAME, false)\
	or is_random_name() != other_data.get(RANDOM_NAME, false)\
	or get_placeholder_name() != other_data.get(NAME, "")\
	or get_size() != other_data.get(SIZE, 1)
