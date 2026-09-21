class_name BrickWall extends StaticBody2D

var max_health = 1000.0
var health = max_health
var dead = false

@onready var noise_texture: NoiseTexture2D = $NoiseCracks.texture
const max_noise = 1
const noise_distance = 0.5

func _ready() -> void:
	$Texture.frame = 0
	var noise: FastNoiseLite = noise_texture.noise
	noise.seed = randi()
	update_texture()

func take_damage(amount):
	if dead: return
	health -= amount
	if health <= 0: die()
	else: update_texture()

func update_texture():
	$Texture.frame = 3
	var ratio = health / max_health
	for i in range($Texture.hframes-1, 0, -1):
		if ratio > float(i) / float($Texture.hframes):
			$Texture.frame = $Texture.hframes - i - 1
			break
	var color_grad: Gradient = noise_texture.color_ramp
	var lower_noise = max_noise - noise_distance
	#color_grad.set_offset(0, lower_noise - (health / max_health) * lower_noise)
	color_grad.set_offset(1, max_noise - (health / max_health) * lower_noise)

func die():
	if !dead:
		$NoiseCracks.hide()
		$Collision.queue_free()
		dead = true
		$Animation.play("destroy")
