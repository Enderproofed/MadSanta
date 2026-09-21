class_name E

enum CHEST_ITEMS { 
	SNOWBALL,
	ICICLE,
	LASER,
	WINGS
}
const weapons = [CHEST_ITEMS.SNOWBALL, CHEST_ITEMS.ICICLE]
const weapons_with_trail = [CHEST_ITEMS.SNOWBALL, CHEST_ITEMS.ICICLE]
static func is_weapon(chest_item: CHEST_ITEMS):
	return chest_item in weapons


const item_type_name_map: Dictionary = {
	E.CHEST_ITEMS.SNOWBALL: "Schneeball",
	E.CHEST_ITEMS.ICICLE : "Eiszapfen",
	E.CHEST_ITEMS.LASER : "Super Eis-Strahl",
	# Das "Engels-" kommt vielleicht noch weg, mal schauen
	E.CHEST_ITEMS.WINGS : "Engels-Flügel"
}

enum COLLECT {
	COIN,
	SNOWFLAKE,
	ICE_SHARD,
	FIRE_SHARD
}
const collectable_name_map: Dictionary = {
	E.COLLECT.COIN: "coins",
	E.COLLECT.SNOWFLAKE: "snowflakes",
	E.COLLECT.ICE_SHARD: "ice_shards",
	E.COLLECT.FIRE_SHARD: "fire_shards"
}

enum UPGRADE {
	STRENGTH,
	RELOAD,
	SPEED,
	SIZE,
	SPREAD,
	BOUNCES
}

enum BOOL_SETTING {
	NONE,
	DRAW_PREVIEW_TRAIL,
	PLAYER_GHOST_VISIBLE,
}

enum IMAGE_ALERTS {
	SAVED_SUCCESSFULLY,
	SAVE_FAILED,
	FAILED_TO_LOAD,
	FAILED_TO_DELETE,
	UNDONE,
	REDONE,
}
const image_alert_text_map = {
		IMAGE_ALERTS.SAVED_SUCCESSFULLY: "SAVE_ALERT",
		IMAGE_ALERTS.SAVE_FAILED: "SAVE_FAIL_ALERT",
		IMAGE_ALERTS.FAILED_TO_LOAD: "FAILED_TO_LOAD",
		IMAGE_ALERTS.FAILED_TO_DELETE: "FAILED_TO_DELETE",
		IMAGE_ALERTS.UNDONE: "UNDONE",
		IMAGE_ALERTS.REDONE: "REDONE",
	}
static func image_alert_to_text(image_alert: IMAGE_ALERTS):
	return image_alert_text_map.get(image_alert, "Not found :(")


const POSITIVE_ALERTS = [IMAGE_ALERTS.SAVED_SUCCESSFULLY, IMAGE_ALERTS.UNDONE, IMAGE_ALERTS.REDONE]
const NEGATIVE_ALERTS = [IMAGE_ALERTS.SAVE_FAILED, IMAGE_ALERTS.FAILED_TO_LOAD, IMAGE_ALERTS.FAILED_TO_DELETE]
static func is_image_alert_positive(image_alert: IMAGE_ALERTS):
	return POSITIVE_ALERTS.has(image_alert)

# going back to using consts instead of enum, so we are spared from headaches from JSON parsing Enum->int and back
const BACKGROUND_NORMAL = 0
const BACKGROUND_NIGHT = 1
const BACKGROUND_MOON = 2

# Place selection pseudo Enum
const PLACE_TAB_FLOOR = "FLOOR"
const PLACE_TILES = "TILES"
const PLACE_ONE_WAY = "ONE_WAY"
const PLACE_BRICK_WALL = "BRICK_WALL"
const PLACE_SELECTION_FLOOR = [PLACE_TILES, PLACE_ONE_WAY, PLACE_BRICK_WALL]

const PLACE_TAB_ENEMIES = "ENEMIES"
const PLACE_GNOME = "GNOME"
const PLACE_ELF = "ELF"
const PLACE_SELECTION_ENEMIES = [PLACE_GNOME, PLACE_ELF]

const PLACE_TAB_COLLECTABLES = "COLLECTABLES"
const PLACE_COIN = "COIN"
const PLACE_SNOWFLAKE = "SNOWFLAKE"
const PLACE_ICE_SHARD = "ICE_SHARD"
const PLACE_FIRE_SHARD = "FIRE_SHARD"
const PLACE_SELECTION_COLLECTABLES = [PLACE_COIN, PLACE_SNOWFLAKE, PLACE_ICE_SHARD, PLACE_FIRE_SHARD]

const PLACE_2x2 = [PLACE_BRICK_WALL]

const PLACE_CONTENT_TEXTURES: Dictionary = {
	PLACE_TAB_FLOOR: {
		PLACE_TILES: "uid://da1nbmv2j4xir",
		PLACE_ONE_WAY: "uid://cgi2wbm0m7o8p",
		PLACE_BRICK_WALL: "uid://c5qt5bykdefv4",
	},
	PLACE_TAB_ENEMIES: {
		PLACE_GNOME: "uid://5kdop0kxrr68",
		PLACE_ELF: "uid://c1slmcauvylme",
	},
	PLACE_TAB_COLLECTABLES: {
		PLACE_COIN: "uid://ho3nr6vu7pan",
		PLACE_SNOWFLAKE: "uid://co4dc1fhpwqs7",
		PLACE_ICE_SHARD: "uid://b7dwukaotedsj", # colored upon loading
		PLACE_FIRE_SHARD: "uid://b7dwukaotedsj", # colored upon loading
	}
}
static func place_content_texture(place_type: String) -> String:
	for key in PLACE_CONTENT_TEXTURES.keys():
		var map: Dictionary = PLACE_CONTENT_TEXTURES[key]
		if map.has(place_type): return map[place_type]
	
	return "uid://3m5msmxv23qb" # Cross icon

static func place_tab_of(place_type: String) -> String:
	for key in PLACE_CONTENT_TEXTURES.keys():
		if PLACE_CONTENT_TEXTURES[key].has(place_type): return key
	return ""


static func enum_to_string(enum_dict: Dictionary, value: int) -> String:
	for k in enum_dict.keys():
		if enum_dict[k] == value:
			return k
	return ""
