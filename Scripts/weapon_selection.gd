class_name WeaponSelection extends PivotElementSwitcher

func _ready() -> void:
	POSITION_OFFSET = 40
	turn_over = false
	vanish_distance = 2
	on_position_update = Callable(self, "update_label")
	get_ready()

func update_label(node, index):
	node.get_node("Label").text = str(index)

func set_index(new_index):
	super.set_index(new_index)
	Globals.selected_weapon = Globals.id_to_item(selected_element)

func _process(delta: float) -> void:
	if Globals.isPaused(): return
	if Input.is_action_just_pressed("mouse_up"): change_index(-1)
	if Input.is_action_just_pressed("mouse_down"): change_index(1)
	super._process(delta)
