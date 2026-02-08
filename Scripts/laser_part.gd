class_name LaserPart
extends Node2D

const BEAM_FADE = 0.05
const MAX_BEAM_LENGTH = 2304.0 #exactly double the window/screen width
var BEAM_DIRECTION = Vector2(MAX_BEAM_LENGTH, 0).normalized()

var debug = false

var spread_y_offset = 0

var hit = false

var curve: Curve
var spread = 0

var fully_initialized = false

func _ready() -> void:
	set_beam_length(0)
	await Globals.timer(1.0/59.0)
	fully_initialized = true
	if !$Ray.is_colliding(): stretch_far()

func set_spread(spread_y_offset, spread): # basically functions as a _ready, hehe
	self.spread_y_offset = spread_y_offset
	self.spread = spread
	$Ray.target_position = Vector2(MAX_BEAM_LENGTH, spread_y_offset)
	BEAM_DIRECTION = Vector2(MAX_BEAM_LENGTH, spread_y_offset).normalized()
	$RotationPivot.look_at(global_position + BEAM_DIRECTION)
	
	curve = Curve.new()
	curve.max_value = spread+1
	curve.add_point(Vector2(1, spread+1))
	curve.add_point(Vector2(1, 1))
	$Beam.width_curve = curve

func _process(delta: float) -> void:
	$RotationPivot/VisibityRestrictor/Stars.speed_scale = 0 if Globals.isPaused() else 1
	if !fully_initialized: return
	if $Ray.is_colliding():
		if debug and Globals.debug_mode and $Ray.get_collider() != null: print($Ray.get_collider(), ", name: ", $Ray.get_collider().name)
		hit = true
		set_beam_length(($Ray.get_collision_point()-global_position).length())
		$HitParticles.global_position = $Ray.get_collision_point()
		hit_something(delta)
	elif hit: 
		stretch_far()

func hit_something(delta):
	var collision_body = $Ray.get_collider()
	if collision_body != null and collision_body.has_method("take_damage"):
		collision_body.take_damage(get_parent().single_laser_damage * delta)

func stretch_far():
	hit = false
	set_beam_length(MAX_BEAM_LENGTH)
	$HitParticles.global_position = global_position + $Ray.target_position

func set_beam_length(beam_length: float):
	var length_ratio = beam_length/MAX_BEAM_LENGTH
	
	$Beam.clear_points()
	$Beam.add_point(Vector2.ZERO)
	$Beam.add_point(BEAM_DIRECTION * beam_length)
	var width_fix = ((MAX_BEAM_LENGTH-beam_length) / MAX_BEAM_LENGTH) # hacky magic number
	curve.set_point_value(1, (spread+1) * length_ratio + width_fix)
	if debug and Globals.debug_mode: print("Point 0: ", curve.get_point_position(0), ", Point 1: ", curve.get_point_position(1))
	
	#$ParticlesContainer.scale.x = length_ratio
	var mat:ParticleProcessMaterial = $RotationPivot/VisibityRestrictor/Stars.process_material
	mat.emission_box_extents.x = beam_length / 2
	mat.emission_shape_offset = Vector3(beam_length / 2, 0, 0)
	$RotationPivot/VisibityRestrictor.size.x = beam_length
	$RotationPivot/VisibityRestrictor/Stars.amount_ratio = length_ratio
	
	$HitParticles/Ball.emitting =  beam_length != MAX_BEAM_LENGTH
	$HitParticles/Star.emitting =  beam_length != MAX_BEAM_LENGTH
	
	
