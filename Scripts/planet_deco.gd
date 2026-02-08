@tool extends Node2D

enum PLANET_TYPE {
	EARTH,
	MOON
}

const PLANET_TEXTURES_MAP = {
	PLANET_TYPE.EARTH: preload("res://Resources/Images/EarthSpinning.png"),
	PLANET_TYPE.MOON: preload("res://Resources/Images/MoonSpinning.png")
}

@export var planet_type: PLANET_TYPE = PLANET_TYPE.EARTH:
	set(value): 
		planet_type = value
		$Planet.texture = PLANET_TEXTURES_MAP.get(planet_type)
		$Planet.modulate = Color(1.2, 1.2, 1.2) if planet_type == PLANET_TYPE.MOON else Color.WHITE
		spin()

func _ready() -> void:
	spin()

func spin():
	$Spin.play("Spin50Frames" if planet_type == PLANET_TYPE.MOON else "Spin100Frames")
