extends Node

enum {
	PLAYING, #0
	TEXT, #1
	PAUSED, #2
	PAUSED_IN_GAME, #3
	SETTINGS, #4
	MAIN_MENU, #5
	SAVE_MENU, #6
	LEVEL_SELECTION, #7
	LEVEL_SELECTION_SPEEDRUN, #8
	CREDITS, #9
	FINISH_MENU, #10
	COLLECT_MENU, #11
	DEATH_SCREEN, #12
	UPGRADES, #13
	MINIGAMES_MENU, #14
	TARGET_MINIGAME, #15
	SPEEDRUN_MINIGAME, #16
	CREATE_LEVEL_MENU, #17
	LEVEL_EDITOR, #18
	LEVEL_EDITOR_EXIT, #19
	LEVEL_EDITOR_EDITING, #20
}
const enum_to_text_map: Dictionary = {
	PLAYING: "PLAYING",
	TEXT: "TEXT",
	PAUSED: "PAUSED",
	PAUSED_IN_GAME: "PAUSED_IN_GAME",
	SETTINGS: "SETTINGS",
	MAIN_MENU: "MAIN_MENU",
	SAVE_MENU: "SAVE_MENU",
	LEVEL_SELECTION: "LEVEL_SELECTION",
	LEVEL_SELECTION_SPEEDRUN: "LEVEL_SELECTION_SPEEDRUN",
	CREDITS: "CREDITS",
	FINISH_MENU: "FINISH_MENU",
	COLLECT_MENU: "COLLECT_MENU",
	DEATH_SCREEN: "DEATH_SCREEN",
	UPGRADES: "UPGRADES",
	MINIGAMES_MENU: "MINIGAMES_MENU",
	TARGET_MINIGAME: "TARGET_MINIGAME",
	SPEEDRUN_MINIGAME: "SPEEDRUN_MINIGAME",
	CREATE_LEVEL_MENU: "CREATE_LEVEL_MENU",
	LEVEL_EDITOR: "LEVEL_EDITOR",
	LEVEL_EDITOR_EXIT: "LEVEL_EDITOR_EXIT",
	LEVEL_EDITOR_EDITING: "LEVEL_EDITOR_EDITING"
}

# SAVE_MENU should be the default
var current_state = SAVE_MENU 

func equals(state):
	if state is Array:
		for stat in state:
			if stat == current_state:
				return true
	else: return state == current_state

# Filled, when leaving states that shall be returned to, really mostly only menus.
# Let's say you are in PLAYING or TARGET_MINIGAME and are navigating to the pause menu
# and then to the settings menu from there... what state do you return to?
var cached_states = []
# Key = State to cache upon (temporarily) leaving
# Value = States that make the Key state be cached
const cache_conditions: Dictionary = {
	PLAYING: [PAUSED, PAUSED_IN_GAME, UPGRADES, SETTINGS],
	TARGET_MINIGAME: [PAUSED, PAUSED_IN_GAME, UPGRADES, SETTINGS],
	SPEEDRUN_MINIGAME: [PAUSED, PAUSED_IN_GAME, UPGRADES, SETTINGS],
	MAIN_MENU: [UPGRADES, SETTINGS],
	PAUSED: [UPGRADES, SETTINGS],
}
const cache_clear_conditions = [MAIN_MENU, LEVEL_SELECTION, CREATE_LEVEL_MENU, MINIGAMES_MENU, LEVEL_EDITOR]

func set_state(state):
	if cache_conditions.has(current_state) and state in cache_conditions[current_state]:
		cached_states.append(current_state)
	elif state in cache_clear_conditions: cached_states.clear() 
	#elif !cached_states.is_empty() and cached_states.has(state):
		#for i in range(cached_states.size()):
			#var index = cached_states.size() - i - 1
			#var last_one = cached_states[index] == state
			#cached_states.remove_at(index)
			#if last_one: break
	current_state = to_enum(state) if state is String else state

func get_state_string(state = current_state) -> String:
	return to_text(state)

func is_settings(state = current_state) -> bool:
	return get_state_string(state).contains(to_text(SETTINGS))

func is_upgrades(state = current_state) -> bool:
	return get_state_string(state).contains(to_text(UPGRADES))

const ingame_menus = [PAUSED, SETTINGS, UPGRADES]
func is_ingame_menu(state = current_state) -> bool:
	return state in ingame_menus

 # also include DEATH_SCREEN, as enemies and other things shall proceed to run
const playing_states = [PLAYING, TARGET_MINIGAME, SPEEDRUN_MINIGAME]
func is_playing(state = current_state) -> bool:
	return state in playing_states
func is_playing_or_player_dead(state = current_state) -> bool:
	return is_playing(state) or state == DEATH_SCREEN

const paused_states = [PAUSED, PAUSED_IN_GAME, TEXT]
func is_paused(state = current_state) -> bool:
	return state in paused_states

const with_background = [MAIN_MENU, CREDITS, SAVE_MENU, LEVEL_SELECTION, LEVEL_SELECTION_SPEEDRUN, UPGRADES, SETTINGS, MINIGAMES_MENU, CREATE_LEVEL_MENU]
func has_background(state = current_state) -> bool:
	return state in with_background

# for now just calls has_background, but might change with future states/scenes
func is_menu(state = current_state) -> bool:
	return has_background(state)

const states_with_title = [
	PAUSED, SETTINGS, MAIN_MENU, SAVE_MENU, CREDITS, FINISH_MENU, DEATH_SCREEN,
	MINIGAMES_MENU, LEVEL_SELECTION, LEVEL_SELECTION_SPEEDRUN, CREATE_LEVEL_MENU
]
func has_title(state = current_state) -> bool:
	return is_settings(state) or states_with_title.has(state)# or is_upgrades(state)

const back_map: Dictionary = {
		FINISH_MENU: LEVEL_SELECTION,
		LEVEL_SELECTION: MAIN_MENU,
		CREDITS: MAIN_MENU,
		DEATH_SCREEN: MAIN_MENU,
		MAIN_MENU: SAVE_MENU,
		PAUSED: PLAYING,
		PAUSED_IN_GAME: PLAYING,
		PLAYING: PAUSED,
		SPEEDRUN_MINIGAME: PAUSED,
		SETTINGS: MAIN_MENU,
		UPGRADES: PLAYING,
		MINIGAMES_MENU: MAIN_MENU,
		LEVEL_SELECTION_SPEEDRUN: MINIGAMES_MENU,
		TARGET_MINIGAME: PAUSED,
		CREATE_LEVEL_MENU: MAIN_MENU,
		LEVEL_EDITOR: LEVEL_EDITOR_EXIT,
		LEVEL_EDITOR_EXIT: LEVEL_EDITOR,
		LEVEL_EDITOR_EDITING: LEVEL_EDITOR,
}
func back(state = current_state):
	if state == SAVE_MENU: get_tree().quit()
	elif !cached_states.is_empty(): return cached_states.pop_back()
	else: return back_map.get(state)

func to_text(state) -> String:
	return enum_to_text_map.get(state)

func to_enum(state):
	return enum_to_text_map.find_key(state)
