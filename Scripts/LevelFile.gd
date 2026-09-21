class_name LevelFile extends Object

static var INVALID_FILE = create_invalid()

const base_level_data: Dictionary = {
	"game_version": Save.GAME_VERSION,
	"level_name": "Unnamed",
	"editor_data": {
		"cam_position": Vector2(0, 0),
		"cam_zoom": 1.0,
		"current_action": 1, # Place
		"current_place_type": E.PLACE_TILES
	},
	"background": 0,
	"snow_ratio": 0.0,
	"cam_limit_left": 48.0,
	"cam_limit_finish": 2000.0,
	"cam_limit_ground": -48.0,
	"cam_limit_top": -1200.0,
	"player_pos": Vector2i(4, -4),
	"tiles": [
		Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1),
		Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2),
		Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3), Vector2i(5, -3),
		],
	"placed_content": {
		E.PLACE_ONE_WAY: [],
		E.PLACE_BRICK_WALL: [],
		E.PLACE_GNOME: [],
		E.PLACE_ELF: [],
		E.PLACE_COIN: [],
		E.PLACE_SNOWFLAKE: [],
		E.PLACE_ICE_SHARD: [],
		E.PLACE_FIRE_SHARD: [],
	},
	"ghost_frames": [],
	"completion_time": 10000.1,
	"validated": false
}

var invalid = false

var data: Dictionary = {}: set = set_data

func set_data(new_data: Dictionary):
	data = new_data
	# Hook to insert missing data upon version/scope change -> default
	for key in base_level_data.keys():
		var variant = base_level_data[key]
		if !data.has(key): data[key] = variant.duplicate(true) if variant is Array or variant is Dictionary else variant

func set_level_name(level_name: String): data["level_name"] = level_name
func get_level_name() -> String: return data["level_name"]

func set_validated(validated: bool): data["validated"] = validated
func is_validated(): return data["validated"]

func set_completion_time(completion_time: float): data["completion_time"] = completion_time
func get_completion_time() -> float: return data["completion_time"]

func set_ghost_frames(ghost_frames: Array[GhostFrame]): data["ghost_frames"] = ghost_frames
func get_ghost_frames() -> Array[GhostFrame]: return data["ghost_frames"]

func save() -> bool:
	return Save.save_level(adjust_data_before_save(), data["level_name"])

func play():
	Globals.ui.start_custom_level(self)

##### Editor data #####

func set_cam_properties(cam_position: Vector2, cam_zoom: float):
	data["editor_data"]["cam_position"] = cam_position
	data["editor_data"]["cam_zoom"] = cam_zoom
func get_cam_position() -> Vector2:
	return data["editor_data"]["cam_position"]
func get_cam_zoom() -> Vector2:
	return Vector2(data["editor_data"]["cam_zoom"], data["editor_data"]["cam_zoom"])

func set_current_action(current_action: int): data["editor_data"]["current_action"] = current_action
func get_current_action() -> int: return data["editor_data"]["current_action"]

func set_current_place_type(current_place_type: String): data["editor_data"]["current_place_type"] = current_place_type
func get_current_place_type() -> String: return data["editor_data"]["current_place_type"]

##### Level Data #####

func set_tiles(tiles: Array[Vector2i]): data["tiles"] = tiles
func get_tiles() -> Array: return data["tiles"]

func set_placed_content(placed_content: Dictionary): data["placed_content"] = placed_content
func get_placed_content() -> Dictionary: return data["placed_content"]

func set_cam_limits(cam_limit_left: float, cam_limit_ground: float, cam_limit_finish: float, cam_limit_top: float):
	data["cam_limit_left"] = cam_limit_left
	data["cam_limit_ground"] = cam_limit_ground
	data["cam_limit_finish"] = cam_limit_finish
	data["cam_limit_top"] = cam_limit_top
func get_cam_limits() -> Vector4:
	return Vector4(data["cam_limit_left"], data["cam_limit_ground"], data["cam_limit_finish"], data["cam_limit_top"])

func set_player_pos(player_pos: Vector2i): data["player_pos"] = player_pos
func get_player_pos() -> Vector2i: return data["player_pos"]

### Cosmetic Level Data ###
func set_background(background: int): data["background"] = background
func get_background() -> int: return data["background"]

func set_snow_ratio(snow_ratio: float): data["snow_ratio"] = snow_ratio
func get_snow_ratio() -> float: return data["snow_ratio"]


static func string_to_vec(string: String, vec2i = false):
	var split = string.replace("(", "").replace(")", "").replace(" ", "").split(",")
	return Vector2i(int(split[0]), int(split[1])) if vec2i else Vector2(float(split[0]), float(split[1]))

static func convert_tiles(tiles_string: Array) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for tile in tiles_string:
		tiles.append(string_to_vec(tile, true))
	return tiles

# When storing vectors as JSON, they will become Strings. We need to parse them again.
static func adjust_data_types(level_file: LevelFile) -> LevelFile:
	var tiles: Array =  level_file.data["tiles"]
	if !tiles.is_empty() and tiles[0] is String:
		level_file.set_tiles(convert_tiles(tiles))
	
	if level_file.data["editor_data"]["cam_position"] is String:
		level_file.data["editor_data"]["cam_position"] = string_to_vec(level_file.data["editor_data"]["cam_position"])
	
	if level_file.data["player_pos"] is String:
		level_file.data["player_pos"] = string_to_vec(level_file.data["player_pos"], true)
	
	for key in level_file.data["placed_content"].keys():
		for content: Dictionary in level_file.data["placed_content"][key]:
			if content.has(LevelEditorPlaceholder.POSITION) and content[LevelEditorPlaceholder.POSITION] is String:
				content[LevelEditorPlaceholder.POSITION] = string_to_vec(content[LevelEditorPlaceholder.POSITION])
	
	var ghost_frames: Array[GhostFrame] = []
	if !level_file.data["ghost_frames"].is_empty():
		for frame: Dictionary in level_file.data["ghost_frames"]:
			ghost_frames.append(GhostFrame.from_map(frame))
	level_file.data["ghost_frames"] = ghost_frames
	
	return add_missing_values(level_file)

func adjust_data_before_save() -> Dictionary:
	var adjusted_data = data.duplicate(true)
	var ghost_frames: Array[Dictionary] = []
	for frame: GhostFrame in data["ghost_frames"]:
		ghost_frames.append(frame.to_map())
	adjusted_data["ghost_frames"] = ghost_frames
	return adjusted_data

static func add_missing_values(level_file: LevelFile):
	add_missing_values_recursively(level_file.data, base_level_data)
	return level_file

static func add_missing_values_recursively(level_file_dict: Dictionary, base_value_dict: Dictionary):
	for key in base_value_dict.keys():
		var value = base_value_dict[key]
		if level_file_dict.get(key) == null:
			level_file_dict[key] = value
		elif value is Dictionary: # might not be fully filled correctly
			add_missing_values_recursively(level_file_dict[key], value)


static func create(data: Dictionary) -> LevelFile:
	var level_file: LevelFile = new()
	level_file.data = data
	return adjust_data_types(level_file)

static func create_invalid() -> LevelFile:
	var level_file: LevelFile = new()
	level_file.invalid = true
	return level_file
