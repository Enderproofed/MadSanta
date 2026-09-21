class_name Level extends Node2D

@export var level_number: int
@export var gravity_scale = 1.0
@export var snow_ratio = 0.1

@onready var level_base:LevelBase = $LevelBase

var time_started = false
var level_time = 0.0
var ghost_frames: Array[GhostFrame] = []
var ghost_index = 0
const GHOST_FRAMES_PER_SECOND = 20

var player_ghost: PlayerGhost

func _ready() -> void:
	Globals.gravity = Globals.base_gravity * gravity_scale
	if Globals.player != null:
		Globals.player.set_snow_ratio(snow_ratio)
		Globals.player.speedrun_time = Globals.speedrun_times[0][str(level_number)]
	else:
		print("Could not set snow")
	await get_tree().physics_frame
	Globals.player_cam.limit_left = level_base.get_left()
	Globals.player_cam.limit_top = level_base.get_top()
	Globals.player_cam.limit_right = level_base.get_right()
	Globals.player_cam.limit_bottom = level_base.get_bottom()
	if !Globals.level1_played:
		Globals.player_cam.position.y = 60

func set_ghost_frames(ghost_frames: Array[GhostFrame]):
	self.ghost_frames = ghost_frames
	player_ghost = load("uid://7n63swrb6u01").instantiate()
	add_child(player_ghost)

func update_ghost(time: float):
	if player_ghost == null or ghost_frames.size() <= 1: return
	
	if ghost_frames[ghost_index + 1].time <= time:
		ghost_index += 1
		if ghost_frames.size() == ghost_index + 1:
			if ghost_frames[ghost_index].died: player_ghost.die()
			else: player_ghost.finish()
			player_ghost = null
			return
		
	var frame1 = ghost_frames[ghost_index]
	var frame2 = ghost_frames[ghost_index + 1]
	var weight = (time - frame1.time) / (frame2.time - frame1.time)
	player_ghost.process_frame(frame1, frame2, weight)

#func _process(delta: float) -> void:
	#if Globals.debug_mode and State.is_playing() and Input.is_action_pressed("mouse_right"):
		#var mouse_pos = get_global_mouse_position()
		#var cell = Vector2i(mouse_pos/48)
		#if mouse_pos.y < 0: cell.y -= 1
		#$Level/TileMapLayer.set_cells_terrain_connect([cell], 0, 0)

func zoom_out():
	#Globals.player_cam.position_smoothing_enabled = false
	$Player/CamAnimation.play("zoom out")
	Globals.player_cam.position.y = 0
	await Globals.timer(2)
	#Globals.player_cam.position_smoothing_enabled = true

func get_bottom():
	return $LevelBase.get_bottom()
	
