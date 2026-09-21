class_name Laser
extends Node2D

var laser_part_preload = preload("uid://b2gjuqta6fbgu")
const fade_out_time = 0.8
const base_damage = 700.0

# important for initializing:
@export_range(0.01, 10, 0.01)
var laser_part_width: float = 2

@export_range(5, 100, 1)
var thickness: int = 24

@export_range(0, 100, 1)
var spread: int = 0

var total_laser_damage = base_damage # will be applied each frame according to delta, so this is damage per second
var total_fire_time = 200000.0

# set during initializing:
var single_laser_damage = 0.0
var beam_count = 0
var fire_time = total_fire_time

var strength = 1

func _ready() -> void:
	beam_count = int(thickness / laser_part_width)
	single_laser_damage = total_laser_damage / beam_count
	var y_pos = -thickness/2
	if beam_count % 2 == 0:
		y_pos += laser_part_width/2
	
	for i in range(beam_count):
		var laser_part: LaserPart = laser_part_preload.instantiate()
		if i == 0: laser_part.debug = true
		laser_part.position.y = y_pos
		var beam: Line2D = laser_part.get_node("Beam")
		beam.width = laser_part_width
		laser_part.set_spread(y_pos * (spread-1), spread)
		add_child(laser_part)
		y_pos += laser_part_width
	
	#Globals.shake_effect()

func stop(also_end):
	if also_end: fire_time = 0
	$A.stop(true)
	Globals.stop_shake_effect()

func activate_again():
	$A.play()
	Globals.stop_shake_effect()

# interpolates from 1 down to 0 in the time of fade_out_time
func get_strength():
	strength = (fade_out_time + fire_time) / fade_out_time if fire_time < 0 else 1
	return strength

# interpolation, but taking into account the actual strength (damage) -> used for knockback
func get_real_strength():
	return strength * total_laser_damage / base_damage

func _process(delta: float) -> void:
	if fire_time > 0 and fire_time - delta <= 0:
		$A.stop(true)
	fire_time -= delta
	if fire_time <= 0:
		var laser_strength = get_strength()
		if laser_strength < 0:
			queue_free()
		modulate.a = laser_strength
		single_laser_damage = (total_laser_damage / beam_count) * laser_strength
