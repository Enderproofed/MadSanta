extends HSlider

@export var text = "Master"

var busses = []
var bus = 0
var mute = false
var smooth = value

func _ready():
	$Label.text = text
	for i in range(AudioServer.bus_count):
		busses.insert(busses.size(),AudioServer.get_bus_name(i))
		if AudioServer.get_bus_name(i) == name:
			AudioServer.set_bus_volume_db(i,value)
			bus = i

func _process(delta):
	smooth = lerp(smooth,value,0.05)
	AudioServer.set_bus_volume_db(bus,smooth)
	
func _on_master_value_changed(value):
	if value == min_value:
		$mute.button_pressed = true
	elif !mute:
		$mute.button_pressed = false

func _on_TextureButton_toggled(button_pressed):
	AudioServer.set_bus_mute(bus,button_pressed)
	

func _on_mute_button_up():
	mute = !mute
