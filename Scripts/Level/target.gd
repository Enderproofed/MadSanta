@tool extends Area2D

@export var size = 1:
	set(value): 
		if value > 0 and value <= 5:
			size = value
			if Engine.is_editor_hint(): set_size()
@export var deco = false

var hit = false

const targets_map = {
	1: "TargetMini",
	2: "TargetSmall",
	3: "TargetMiddle",
	4: "Target",
	5: "TargetBig",
}

func _ready() -> void:
	set_size()
	if deco: $Collision.disabled = true

func set_size():
	var texture: CompressedTexture2D = get_target_resource(targets_map[size])
	$Texture.texture = texture
	$Collision.shape.radius = texture.get_width() / 2.0 * 3.0

func get_target_resource(type: String):
	return load("res://Resources/Images/Targets/" + type + ".png")

func pop(projectile: Projectile):
	if !hit:
		hit = true
		$Animation.play("pop")

func _on_body_entered(body: Node2D) -> void:
	if hit: return
	if body is Projectile:
		pop(body)
