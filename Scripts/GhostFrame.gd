class_name GhostFrame extends Node

const TIME = "TIME"
const POSITION = "POSITION"

const FLYING = "FLYING"
const ROLLING = "ROLLING"

const ROLLING_DEG = "ROLLING_DEG"
const DIED = "DIED" # optional

const default_values: Dictionary = {
	FLYING: false,
	ROLLING: false,
	ROLLING_DEG: 0.0,
}

var successor: GhostFrame

var time: float

# values - for now just position, animations and the like when such is coming
var position: Vector2

var flying: bool
var rolling: bool
var rolling_deg: float

var died: bool = false # optional

static func init(time: float, posiion: Vector2, flying: bool, rolling: bool, rolling_deg: float, died: bool = false) -> GhostFrame:
	var frame = GhostFrame.new()
	frame.time = time
	frame.position = posiion
	
	frame.flying = flying
	frame.rolling = rolling
	frame.rolling_deg = rolling_deg
	
	frame.died = died
	return frame

static func from_map(map: Dictionary) -> GhostFrame:
	var frame = GhostFrame.new()
	frame.time = map[TIME]
	frame.position = LevelFile.string_to_vec(map[POSITION]) if map[POSITION] is String else map[POSITION]
	
	frame.flying = map[FLYING] if map.has(FLYING) else default_values[FLYING]
	frame.rolling = map[ROLLING] if map.has(ROLLING) else default_values[ROLLING]
	frame.rolling_deg = map[ROLLING_DEG] if map.has(ROLLING_DEG) else default_values[ROLLING_DEG]
	
	frame.died = map.has(DIED) and map[DIED]
	return frame

func to_map() -> Dictionary:
	return {
		TIME: time,
		POSITION: position,
		FLYING: flying,
		ROLLING: rolling,
		ROLLING_DEG: rolling_deg
	} if !died else {
		TIME: time,
		POSITION: position,
		FLYING: flying,
		ROLLING: rolling,
		ROLLING_DEG: rolling_deg,
		DIED: died
	}
