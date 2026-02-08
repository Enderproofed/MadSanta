class_name SoundSlider extends HSlider

@export var text = "Master"
@export var bus_name = "Master"

var bus_id = 0
var mute = false
var smooth = value

func _ready():
	Globals.timer(1)
	load_saved_data()
	Globals.add_listener(Globals.LOAD, Callable(self, "load_saved_data"))
	$Label.text = text
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == bus_name:
			AudioServer.set_bus_volume_db(i, value)
			bus_id = i

func load_saved_data():
	mute = Globals.audio[bus_name]["mute"]
	print(Globals.audio[bus_name])
	value = Globals.audio[bus_name]["value"]
	smooth = value
	$mute.button_pressed = mute or value == min_value

func _process(delta):
	smooth = lerp(smooth,value,0.05)
	AudioServer.set_bus_volume_db(bus_id, smooth)

func _on_master_value_changed(value):
	if value == min_value:
		$mute.button_pressed = true
	elif !mute:
		$mute.button_pressed = false
	
	if not Globals.loading_data: save_changes()

func save_changes():
	Globals.audio[bus_name]["mute"] = mute
	Globals.audio[bus_name]["value"] = value
	
	Save.save_data()

func _on_TextureButton_toggled(button_pressed):
	AudioServer.set_bus_mute(bus_id, button_pressed)

func _on_mute_button_up():
	if value != min_value:
		mute = !mute
	else:
		$mute.button_pressed = true
	save_changes()
