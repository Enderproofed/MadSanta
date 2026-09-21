class_name HealthComponent extends Node

signal health_changed(current: float, max: float)
signal died

@export var max_health := 100.0
var current_health := 0.0

func _ready() -> void:
	current_health = max_health

func damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0.0, max_health)
	emit_health_change()

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	emit_health_change()

func emit_health_change() -> void:
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()
