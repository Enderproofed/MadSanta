class_name SoundSlider extends HSlider

@export var text = "Master"
@export var bus_name = "Master"

var bus_id = 0
var mute = false: set = set_mute
var smooth = value
var dragging = false
var initialized = false

func _ready():
	Localization.translate_node($Label, text)
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == bus_name:
			AudioServer.set_bus_volume_db(i, value)
			bus_id = i
	load_saved_data()
	initialized = true

func load_saved_data():
	print(bus_name, ": ", Globals.audio[bus_name])
	mute = Globals.audio[bus_name]["mute"]
	value = Globals.audio[bus_name]["value"]
	smooth = value

func save_changes():
	if !initialized: return
	Globals.audio[bus_name]["mute"] = mute
	Globals.audio[bus_name]["value"] = value
	print("saved")
	Save.save_value("audio")

func _process(delta):
	$Paricles.emitting = dragging
	$Paricles.position = Vector2(size.x * ((value - min_value) / (max_value - min_value)), size.y / 2)
	$Paricles.amount_ratio -= 0.1
	
	if abs(smooth - value) < 0.05:
		if smooth != value:
			smooth = value
			AudioServer.set_bus_volume_db(bus_id, smooth)
	else:
		smooth = lerp(smooth,value,0.05)
		AudioServer.set_bus_volume_db(bus_id, smooth)

var previous_value = value
func _on_master_value_changed(value):
	if !initialized: return
	if value == min_value:
		mute = true
	elif mute:
		mute = false
	
	$Paricles.amount_ratio = clamp(abs(value - previous_value), 0.0, 1.0)
	previous_value = value

func _on_mute_button_up():
	if value == min_value: mute = true
	else: mute = !mute

func set_mute(new_mute):
	mute = new_mute
	$mute.button_pressed = new_mute
	$Cross.visible = new_mute
	AudioServer.set_bus_mute(bus_id, new_mute)
	save_changes()

func _on_drag_started() -> void:
	dragging = true

func _on_drag_ended(value_changed: bool) -> void:
	if value_changed: save_changes()
	dragging = false
