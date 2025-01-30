extends Node2D

var selected_weapon
var selected_index = 0
var selectable_weapons = []

func _ready() -> void:
	for child in $Pivot.get_children():
		child.modulate = Color(0.5, 0.5, 0.5, 0)

func add_selectable_weapon(weapon):
	var selectable_weapon = Globals.item_to_id(weapon)
	if selectable_weapon != -1 and selectable_weapon not in selectable_weapons:
		selectable_weapons.append(selectable_weapon)
		selected_index = selectable_weapons.size()-1
		#maybe sort (when having a different order of selection)
		selected_weapon = selectable_weapon
	$Pivot.get_child(selectable_weapon).modulate = Color(1,1,1)

func change_index(change: int):
	var new_index = selected_index + change
	if selectable_weapons.size() > new_index and new_index >= 0:
		selected_index = new_index
		selected_weapon = selectable_weapons[selected_index]
		Globals.selected_weapon = Globals.id_to_item(selected_weapon)

func _process(delta: float) -> void:
	if Globals.isPaused(): return
	if Input.is_action_just_pressed("mouse_up"): change_index(-1)
	if Input.is_action_just_pressed("mouse_down"): change_index(1)
	if selected_weapon != null and selected_weapon <= $Pivot.get_child_count() and abs($Pivot.position.x + $Pivot.get_child(selected_weapon).position.x) > 0.01:
		$Pivot.position.x = lerp($Pivot.position.x, -$Pivot.get_child(selected_weapon).position.x, 0.1)
		for child in $Pivot.get_children():
			var size = clamp(80 - abs($Pivot.position.x + child.position.x), 0, 80) / 80.0
			child.scale = Vector2(max(0.001,size), max(0.001,size))
			child.modulate.a = size
