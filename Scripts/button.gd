@tool class_name TriggerButton extends Node2D

var pressed = false

@export var door: Door
@export var id = 1

func _ready() -> void:
	if Engine.is_editor_hint():
		for sibling in get_parent().get_children():
			if sibling != self and sibling is TriggerButton and sibling.id >= id:
				id = sibling.id + 1

func _on_body_entered(body: Node2D) -> void:
	if !pressed:
		$Animation.play("press")
		pressed = true
		door.open(self)
		Globals.set_button_triggered(Globals.level.level_number, id)
