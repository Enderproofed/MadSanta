@tool
extends Node2D

@export var blocks = 1
@export var left = false

var player_detected = false
var countdown = 0.0

func editor_edit():
	$OneWayBody/Collision.scale.x = blocks
	$Texture.size.x = 16 * blocks
	if !left:
		$Texture.position.x = 0
		$OneWayBody/Collision.position.x = 24 * blocks
	else:
		$Texture.position.x = -16 * blocks * $Texture.scale.x
		$OneWayBody/Collision.position.x = -24 * blocks

func _ready() -> void:
	editor_edit()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		editor_edit()
		return
