class_name PlayerGhost extends Node2D

@export var animation: AnimationPlayer

func _ready() -> void:
	visible = Globals.player_ghost_visible
	SignalBus.setting_changed_bool.connect(setting_changed_bool)

func setting_changed_bool(setting: E.BOOL_SETTING, value: bool):
	if setting == E.BOOL_SETTING.PLAYER_GHOST_VISIBLE:
		visible = value

func die():
	animation.play("die")

func finish():
	modulate = Color.WHITE
	$Icon.modulate = Color.WHITE
	$Icon.texture = load("uid://debe8kidgi7jo")
	hide_all()

func hide_all():
	$Snowman.visible = false
	$Snowball.visible = false
	$Wings.visible = false

func process_frame(frame1: GhostFrame, frame2: GhostFrame, weight: float):
	position = frame1.position.lerp(frame2.position, weight)
	roll(frame1.rolling if weight < 0.5 else frame2.rolling, lerpf(frame1.rolling_deg, frame2.rolling_deg, weight))
	fly(frame1.flying if weight < 0.5 else frame2.flying)

func roll(rolling: bool, roll_deg: float):
	$Snowman.visible = !rolling
	$Snowball.visible = rolling
	$Snowball.rotation_degrees = roll_deg

func fly(flying: bool):
	$Wings.visible = flying
	if flying: $Snowball.visible = false
