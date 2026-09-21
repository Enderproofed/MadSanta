class_name EnemyBase extends Node2D

@onready var enemy: Enemy = get_parent()

func _ready() -> void:
	var seed = int(global_position.x * global_position.y)
	if enemy.has_name:
		if enemy.random_name: enemy.enemy_name = Namegenerator.generate_full_name()
	else: enemy.enemy_name = ""
	$Label.text = enemy.enemy_name
	
