extends Control

const MINUTE = 60#s
const HOUR = 60 * MINUTE
const MINIGAME_WAIT_TIME = 3 * HOUR

const SANDBOX_SPIN_INDICIES = [
	[[0, 4], [5, 13], [6, 14], [3, 7]],
	[[1, 11], [10, 12], [9, 15], [2, 8]]
]
var sandbox_spin_speed = 30.0
var sandbox_width = 50.0

@onready var ui: UI = get_parent()
@onready var minigames_texture = load("res://Resources/Images/Targets/TargetBig.png")
@onready var minigames_texture_focused = load("res://Resources/Images/Targets/TargetBigFocus.png")

var daily_time_ready = true
var daily_disabled = false

var focuses: Dictionary = {"Targets": false, "Daily": false, "Speedrun": false}

func _ready() -> void:
	set_daily_time_ready(daily_time_ready)
	set_daily_enabled(!daily_disabled)

func daily_minigame() -> void:
	if !daily_disabled and daily_time_ready:
		Globals.last_minigame_time = Time.get_unix_time_from_system()
		$Daily/Button/PulsateAnimation.stop(true)
		$Daily/Button/Target/Animation.play("pop")
		$Daily/Button/Target/Texture.frame = 1
		ui.change_scenes(State.TARGET_MINIGAME, 0.5, 0.5)


func targets() -> void:
	$Targets/Button/PulsateAnimation.stop(true)
	$Targets/Button/Target/Animation.play("pop")
	ui.change_scenes(State.TARGET_MINIGAME, 0.5, 0.5)


func speedrun() -> void:
	$Speedrun/Button/PulsateAnimation.stop(true)
	$Speedrun/Button/Target/Animation.play("pop")
	ui.change_scenes(State.LEVEL_SELECTION_SPEEDRUN, 0.5, 0.5)


func sandbox() -> void:
	$Sandbox/Button/PulsateAnimation.stop(true)
	$Sandbox/Button/Target/Animation.play("pop")
	ui.start_sandbox()


func set_daily_enabled(enabled: bool):
	$Daily.modulate = Color.WHITE if enabled else Color(0, 0, 0, 0.5)
	$Daily/Title.add_theme_constant_override("outline_size", 15 if enabled else 0)
	if enabled:
		if daily_time_ready:
			$Daily/Button/PulsateAnimation.play("pulsate")
	else:
		$Daily/Button/PulsateAnimation.play("RESET")
		
	daily_disabled = !enabled

func _process(delta: float) -> void:
	for node_name in focuses.keys():
		var button_node = get_node(node_name + "/Button")
		var focus = get_global_mouse_position().distance_to(button_node.global_position) < button_node.shape.radius * button_node.scale.x
		if focus != focuses[node_name]:
			if node_name == "Targets":
				$Targets/Button/Target/Texture.texture = minigames_texture_focused if focus else minigames_texture
			if node_name == "Daily":
				var mat: ShaderMaterial = $Daily/Button/Target/Texture.material
				mat.set_shader_parameter("line_thickness", 0.4 if focus else 0.0)
			if node_name == "Speedrun":
				var mat: ShaderMaterial = $Speedrun/Button/Target/Texture.material
				mat.set_shader_parameter("line_thickness", 1.0 if focus else 0.0)
		focuses[node_name] = focus
	
	check_daily_time_ready(Time.get_unix_time_from_system() - Globals.last_minigame_time)
	sandbox_spin(delta)


func check_daily_time_ready(time_since_last_minigame: float):
	var value = time_since_last_minigame > MINIGAME_WAIT_TIME
	set_minigames_wait_time(time_since_last_minigame)
	if daily_time_ready != value:
		set_daily_time_ready(value)

func set_daily_time_ready(value: bool):
	daily_time_ready = value
	$Daily/Button.modulate = Color.WHITE if value else Color(0.5, 0.5, 0.5, 0.5)
	$Daily/WaitTimer.visible = !value
	$Daily/Button/Target/Texture.frame = bool(!value)
	if value:
		$Daily/Button/PulsateAnimation.play("pulsate")

func set_minigames_wait_time(time_since_last_minigame: float):
	var time_till_next = MINIGAME_WAIT_TIME - time_since_last_minigame
	var hours = int(time_till_next/HOUR)
	var minutes = (int(time_till_next) % HOUR) / MINUTE
	var seconds = (int(time_till_next) % HOUR) % MINUTE
	$Daily/WaitTimer.text = str(zero_prefix(hours), ":", zero_prefix(minutes), ":", zero_prefix(seconds))

func zero_prefix(temporal: int) -> String:
	return str("0", temporal) if temporal < 10 else str(temporal)

var time_to_spin = 0.0
func sandbox_spin(delta: float):
	time_to_spin += delta
	sandbox_spin_part(time_to_spin, true)
	sandbox_spin_part(time_to_spin, false)

func sandbox_spin_part(time: float, top: bool):
	var sandBox_width = get_sandbox_width()
	var offset = sandBox_width/2
	var array_half: Array = SANDBOX_SPIN_INDICIES[0 if top else 1]
	for array_index in range(array_half.size()):
		var index_arrays = array_half[array_index]
		for point_index in index_arrays:
			var x = sin(deg_to_rad(time * sandbox_spin_speed) + PI/2 * array_index) * sandbox_width
			var y = cos(deg_to_rad(time * sandbox_spin_speed) + PI/2 * array_index) * sandbox_width + (-sandbox_width/2 if top else sandbox_width/2)
			$Sandbox/Button/Target/Line2D.set_point_position(point_index, Vector2(x, y))


func get_sandbox_width(width = sandbox_width):
	return sin(PI/2) * width * 2
