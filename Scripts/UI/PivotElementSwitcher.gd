class_name PivotElementSwitcher extends Control

const not_unlocked_color = Color(0.5, 0.5, 0.5, 0)
const disabled_color = Color(0, 0, 0, 0.4)

var selected_index = -1
var selected_element = -1
var selectables: Array[int] = []
var disabled_elements: Array[int] = []
var all_disabled = false
var fake_index = -1

# on initialization variables
var OFFSET = 0
var POSITION_OFFSET = 232
var turn_over = true
var vanish_distance = 1
var is_weapons = true
var is_items = false

var on_position_update = null

@onready var pivot_element = $Pivot
var INITIAL_POSITION = Vector2()
var set_init_pos = true

# child classes must set the required values in the _ready() function and call this to initialize
func get_ready() -> void:
	INITIAL_POSITION = Vector2(pivot_element.position) if set_init_pos else INITIAL_POSITION
	for child in pivot_element.get_children():
		child.modulate = not_unlocked_color
		child.visible = false
	
	if is_weapons:
		SignalBus.item_collected.connect(_item_collected)
		SignalBus.load.connect(_set_weapons_from_globals)
		SignalBus.level_reset.connect(_set_weapons_from_globals)
		_set_weapons_from_globals()

func _item_collected(item: E.CHEST_ITEMS):
	if is_items or E.is_weapon(item):
		add_selectable_element(Globals.item_to_id(item))

func _set_weapons_from_globals():
	if is_items:
		set_elements(Globals.collected_items, Globals.selected_weapon) # might want to check others -> just got angel wings? pre-select it :)
	elif is_weapons:
		set_elements(Globals.get_collected_weapons_int(), Globals.selected_weapon)

func add_selectable_element(element: int):
	if element != -1 and element not in selectables:
		selectables.append(element)
		selectables.sort()
		selected_element = element
		var previous_index = selected_index
		selected_index = selectables.find(element)
		fake_index += selected_index - previous_index
	var child = pivot_element.get_child(selected_element)
	child.modulate = Color(1,1,1)
	child.visible = true
	update_positions()

func set_disabled_elements(elements):
	if elements is Array:
		disabled_elements = elements
	elif elements is int:
		disabled_elements = [elements]
	
	var enabled_elements = selectables.duplicate()
	for disabled_element in disabled_elements:
		enabled_elements.erase(disabled_element)
		var element = pivot_element.get_child(disabled_element)
		element.modulate = disabled_color
		if element is Button:
			element.disabled = true
	for enabled_element in enabled_elements:
		var element = pivot_element.get_child(enabled_element)
		if element is Button:
			element.disabled = false
	
	all_disabled = enabled_elements.is_empty()
	
	if !all_disabled and is_disabled(selected_element):
		set_selected_element(enabled_elements.front())

func set_all_disabled_except(elements):
	var disabled_ones = selectables.duplicate()
	
	if elements is Array:
		for element in elements:
			disabled_ones.erase(element)
	elif elements is int:
		disabled_ones.erase(elements)
	
	set_disabled_elements(disabled_ones)

func is_disabled(element) -> bool:
	return element in disabled_elements

func update_positions():
	var unlocked_position_offset = 0
	for element in selectables:
		var node = pivot_element.get_child(element) # either Control or Node2D, luckily both have a position attribute :)
		node.position.x = -OFFSET + unlocked_position_offset * POSITION_OFFSET
		unlocked_position_offset += 1
		if on_position_update != null: on_position_update.call(node, unlocked_position_offset)
	smoothly_transition()

func set_elements(elements: Array, selected, enabled_elements = null):
	selected_index = 0
	fake_index = 0
	selectables = []
	for child_id in range(pivot_element.get_child_count()):
		if child_id in elements:
			add_selectable_element(child_id)
		else:
			pivot_element.get_child(child_id).modulate = Color(0.5, 0.5, 0.5, 0)
	
	set_selected_element(selected)
	
	if enabled_elements != null:
		set_all_disabled_except(enabled_elements)

func set_selected_element(selected, instantly = true):
	if selected != null and selected in selectables:
		selected_element = selected
		selected_index = selectables.find(selected)
		update_positions()
		if instantly:
			pivot_element.position.x = -pivot_element.get_child(selected_index).position.x + INITIAL_POSITION.x
			smoothly_transition()
		if self is WeaponSelection:
			Globals.selected_weapon = Globals.id_to_item(selected)

var tmp_fake_index = -1
func set_index(new_index, source_is_number = false, from_recursion = false) -> bool:
	if !from_recursion: tmp_fake_index = fake_index
	if selectables.is_empty(): return false
	
	var requested_change = new_index - selected_index
	
	if can_apply_turn_over():
		tmp_fake_index += requested_change
		if new_index < 0: new_index = selectables.size() - 1
		elif new_index == selectables.size(): new_index = 0 
	else:
		if new_index < 0 or new_index >= selectables.size():
			return false
	
	if is_disabled(new_index):
		if all_disabled or source_is_number: return false
		elif requested_change > 0: return set_index(new_index + 1, false, true)
		else: return set_index(new_index - 1, false, true)
	
	fake_index = tmp_fake_index
	selected_index = new_index
	selected_element = selectables[selected_index]
	return true

func change_index(change: int):
	set_index(selected_index + change)

func getIndex():
	return fake_index if can_apply_turn_over() else selected_index

func get_first_selectable_index(): #nullable
	for element in selectables:
		if !is_disabled(element):
			return selectables.find(element)
func get_last_selectable_index(): #nullable
	var last_index = null
	for element in selectables:
		if !is_disabled(element):
			last_index = selectables.find(element)
	return last_index

func has_previous() -> bool:
	if can_apply_turn_over(): return true
	if all_disabled: return false
	return selected_index != get_first_selectable_index()
func has_next() -> bool:
	if can_apply_turn_over(): return true
	if all_disabled: return false
	return selected_index != get_last_selectable_index()

func can_apply_turn_over() -> bool:
	return turn_over and (selectables.size() >= 2 if vanish_distance == 1 else selectables.size() >= 1 + (vanish_distance - 1) * 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected_index < pivot_element.get_child_count():
		#if abs(pivot_element.position.x + pivot_element.get_child(selected_index).position.x) > 0.01:
		if abs(pivot_element.position.x + getIndex() * POSITION_OFFSET) > 0.01:
			smoothly_transition()
	else:
		print("Warum ist '", selected_index, "' selected, wenn doch nur ", selectables.size(), " Elemente existieren")

func smoothly_transition():
	var full_round = POSITION_OFFSET * selectables.size()
	var vanish_distance_pixel = POSITION_OFFSET * vanish_distance
	#pivot_element.position.x = lerp(pivot_element.position.x, -pivot_element.get_child(selected_index).position.x + INITIAL_POSITION.x, 0.1)
	pivot_element.position.x = lerp(pivot_element.position.x, -(getIndex() * POSITION_OFFSET) + INITIAL_POSITION.x, 0.1)
	for i in range(pivot_element.get_child_count()):
		var child = pivot_element.get_child(i)
		if i in selectables:
			if can_apply_turn_over():
				var index = selectables.find(i)
				if child.position.x > -pivot_element.position.x + vanish_distance_pixel:
					child.position.x -= full_round
				if child.position.x < -pivot_element.position.x - (full_round - vanish_distance_pixel):
					child.position.x += full_round
			var element_size = clamp(vanish_distance_pixel - abs(pivot_element.position.x + child.position.x - INITIAL_POSITION.x), 0, vanish_distance_pixel) / vanish_distance_pixel
			child.scale = Vector2(max(0.001,element_size), max(0.001,element_size))
			if !is_disabled(i) or element_size == 0: child.modulate.a = element_size
