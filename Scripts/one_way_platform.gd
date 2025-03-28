@tool
extends Node2D

@export var blocks = 1

var player_detected = false
var countdown = 0.0

func editor_edit():
	$Texture.size.x = 16 * blocks
	$OneWayBody/Collision.shape.size.x = 48
	$OneWayBody/Collision.scale.x = blocks
	$Playerdetect/Collision.scale.x = blocks
	$OneWayBody/Collision.position.x = 24 * blocks
	$Playerdetect/Collision.position.x = 24 * blocks

func _ready() -> void:
	editor_edit()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		editor_edit()
		return
	
	if player_detected and Input.is_action_pressed("ui_down"): countdown = 0.7
	else: countdown = max(0, countdown-delta)
	
	$OneWayBody.collision_layer = 0 if countdown > 0 else 16

func _on_playerdetect_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		player_detected = true


func _on_playerdetect_body_exited(body: Node2D) -> void:
	if body == Globals.player:
		player_detected = false
