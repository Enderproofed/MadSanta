extends PivotElementSwitcher

const buttons_vanish_on_end = true

var level_button_load = load("uid://c1oul5fnukx8a")

func _ready() -> void:
	POSITION_OFFSET = 500
	INITIAL_POSITION = Vector2()
	#OFFSET = -240
	pivot_element = $Selection/Pivot
	init_buttons()
	turn_over = false
	is_weapons = false
	set_init_pos = false
	get_ready()
	set_elements(range(Globals.levels.size()), Globals.unlocked_level-1, range(Globals.unlocked_level))
	update_slide_buttons()

func init_buttons():
	#init 1st butt
	var init_pos = $Selection/Pivot/LevelButton.position
	for i in range(1, Globals.levels.size()):
		var level_button: LevelButton = level_button_load.instantiate()
		level_button.level_number = i+1
		#level_button.position = Vector2(init_pos.x + POSITION_OFFSET * i, init_pos.y)
		$Selection/Pivot.add_child(level_button)

func update_slide_buttons():
	if buttons_vanish_on_end:
		$Selection/Back.visible = has_previous()
		$Selection/Forth.visible = has_next()

func _process(delta: float) -> void:
	if !State.equals([State.LEVEL_SELECTION, State.LEVEL_SELECTION_SPEEDRUN]): return
	if Input.is_action_just_pressed("mouse_up"): change_index(-1)
	if Input.is_action_just_pressed("mouse_down"): change_index(1)
	super._process(delta)

func _on_back_button_up() -> void:
	change_index(-1)
	update_slide_buttons()
func _on_forth_button_up() -> void:
	change_index(1)
	update_slide_buttons()
