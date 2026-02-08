class_name PivotElementSwitcher extends Control

var selected_index = -1
var selected_element = -1
var selectables = []

var POSITION_OFFSET = 232
var turn_over = true
var vanish_distance = 1
var is_weapons = true

var on_position_update = null

@onready var pivot_element = $Pivot
@onready var INITIAL_POSITION = Vector2($Pivot.position)

# child classes must set the required values in the _ready() function and call this to initialize
func get_ready() -> void:
	for child in pivot_element.get_children():
		child.modulate = Color(0.5, 0.5, 0.5, 0)
	
	if is_weapons:
		Globals.add_listeners([Globals.LOAD, Globals.LVL_RESET, Globals.ITEM_COLLECTED], [Callable(self, "set_weapons_from_globals")])

func add_selectable_element(element: int):
	if element != -1 and element not in selectables:
		selectables.append(element)
		selectables.sort()
		selected_element = element
		selected_index = selectables.find(element)
	pivot_element.get_child(selected_element).modulate = Color(1,1,1)
	update_positions()

func update_positions():
	var unlocked_position_offset = 0
	for element in selectables:
		var node = pivot_element.get_child(element) # either Control or Node2D, luckily both have a position attribute :)
		node.position.x = unlocked_position_offset * POSITION_OFFSET
		unlocked_position_offset += 1
		if on_position_update != null: on_position_update.call(node, unlocked_position_offset)
	smoothly_transition()

func set_weapons_from_globals():
	var collected_items_int: Array[int] = []
	for collected_item in Globals.collected_items: collected_items_int.append(Globals.item_to_id(collected_item))
	set_elements(collected_items_int, Globals.selected_weapon)

func set_elements(elements: Array[int], selected):
	selected_index = 0
	selectables = []
	for child_id in range(pivot_element.get_child_count()):
		if child_id in elements:
			add_selectable_element(child_id)
		else:
			pivot_element.get_child(child_id).modulate = Color(0.5, 0.5, 0.5, 0)
	
	if selected != null and selected in selectables:
		selected_index = selectables.find(Globals.item_to_id(selected))
		update_positions()

func set_index(new_index):
	if selectables.is_empty(): return
	if turn_over: 
		selected_index = new_index
		if selected_index < 0: selected_index = selectables.size() - 1
		elif selected_index == selectables.size(): selected_index = 0 
	else:
		selected_index = clamp(new_index, 0, selectables.size()-1)
	
	selected_element = selectables[selected_index]

func change_index(change: int):
	set_index(selected_index + change)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected_index < pivot_element.get_child_count() and abs(pivot_element.position.x + pivot_element.get_child(selected_index).position.x) > 0.01:
		smoothly_transition()


func smoothly_transition():
	pivot_element.position.x = lerp(pivot_element.position.x, -pivot_element.get_child(selected_index).position.x + INITIAL_POSITION.x, 0.1)
	for child in pivot_element.get_children():
		var size_modifier = POSITION_OFFSET * vanish_distance
		var element_size = clamp(size_modifier - abs(pivot_element.position.x + child.position.x - INITIAL_POSITION.x), 0, size_modifier) / size_modifier
		child.scale = Vector2(max(0.001,element_size), max(0.001,element_size))
		if child.modulate.r != 0.5:
			child.modulate.a = element_size
