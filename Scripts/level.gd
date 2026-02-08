class_name Level extends Node2D

@export var level_number: int

@onready var level_base:LevelBase = $LevelBase

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	for collectable in $Level/Collectables.get_children():
		collectable.level_number = level_number
	
	$Player/Cam.limit_left = level_base.get_left()
	$Player/Cam.limit_top = level_base.get_top()
	$Player/Cam.limit_right = level_base.get_right()
	$Player/Cam.limit_bottom = level_base.get_bottom()
	if !Globals.level1_played:
		$Player/Cam.position.y = 60

func zoom_out():
	$Player/Cam.position_smoothing_enabled = false
	$Player/CamAnimation.play("zoom out")
	$Player/Cam.position.y = 0
	await Globals.timer(2)
	$Player/Cam.position_smoothing_enabled = true

func get_bottom():
	return $LevelBase.get_bottom()
	
