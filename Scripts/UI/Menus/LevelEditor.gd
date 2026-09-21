class_name LevelEditor extends Control

static var current: LevelEditor

@export var cam_limit_left: Node2D
@export var cam_limit_finish: Node2D
@export var cam_limit_ground: Node2D
@export var cam_limit_top: Node2D
@export var tilemap: TileMapLayer
@export var grid: Node2D
@export var camera: Camera2D
@export var gridpointer: Node2D
@export var selection_rect: ColorRect
@export var player: Sprite2D
@export var overlay: Control
@export var actions: HBoxContainer
@export var background_button: Button
@export var background_node: ParallaxBackground
@export var snow_slider: HSlider
@export var snow_particles: GPUParticles2D
@export var place_content_selection: TabContainer
@export var selection_actions: Panel
@export var undo_button: Button
@export var redo_button: Button

@export var one_way_container: Node2D
@export var coins_container: Node2D
@export var snowflakes_container: Node2D
@export var ice_shards_container: Node2D
@export var fire_shards_container: Node2D
@export var brick_wall_container: Node2D
@export var doors_container: Node2D
@export var enemies_container: Node2D

@onready var PLACE_TYPE_CONTAINER_MAP: Dictionary = {
	E.PLACE_ONE_WAY: one_way_container,
	E.PLACE_BRICK_WALL: brick_wall_container,
	E.PLACE_GNOME: enemies_container,
	E.PLACE_ELF: enemies_container,
	E.PLACE_COIN: coins_container,
	E.PLACE_SNOWFLAKE: snowflakes_container,
	E.PLACE_ICE_SHARD: ice_shards_container,
	E.PLACE_FIRE_SHARD: fire_shards_container,
}

var placeholder_load = load("uid://coirwop5r7u16")
var edit_menu_load = load("uid://6bbklc4f5k2l")

enum ACTION {
	NONE, #0
	PLACE, #1
	ERASE, #2
	SELECT, #3
	MOVE, #4
	CAM_MOVEMENT, #5 not Ctrl+Z able
	PLAYER_MOVEMENT, #6
	LIMIT_MOVEMENT, #7
	CONTENT_MOVEMENT, #8
	EDIT_PLACEHOLDER, #9
}
const CELL_ACTIONS = [ACTION.PLACE, ACTION.ERASE]
@onready var ACTION_BUTTON_MAP: Dictionary = {
	ACTION.PLACE: actions.get_node("PlaceButton"),
	ACTION.ERASE: actions.get_node("EraseButton"),
	ACTION.SELECT: actions.get_node("SelectButton"),
	ACTION.MOVE: actions.get_node("MoveButton")
}
@onready var ACTION_BUTTON_HOTKEYS: Dictionary = {
	"1": actions.get_node("PlaceButton"),
	"2": actions.get_node("EraseButton"),
	"3": actions.get_node("SelectButton"),
	"4": actions.get_node("MoveButton")
}

@onready var viewport := get_viewport()
@onready var ui: UI = get_parent()

const CELL_SIZE = 48
const BORDER_TOP_CELLS = 150
const BORDER_TOP = -CELL_SIZE * BORDER_TOP_CELLS

const CAM_OVERSHOOT_TOP = 180
const CAM_LIMIT_LEFT = -100
const CAM_LIMIT_BOTTOM = 260
const CAM_LIMIT_TOP = BORDER_TOP

const ZOOM_SPEED = 0.1
const ZOOM_CHANGE_X = 50.0
const ZOOM_IN_MAX = 4.0
const ZOOM_OUT_MAX = 0.1

var current_cell = Vector2i(0, 0)
var last_cell = Vector2i(0, 0)
var cell_out_of_bounds = false
var last_relative = null
var skip_next_relative = false
var edit_menu = null

var current_action: ACTION = ACTION.NONE: set = set_current_action
var performed_action: ACTION = ACTION.NONE: set = set_performed_action
var last_action: ACTION = ACTION.NONE

var cell_action_blocked = false
var any_action_blocked = false
var limit_grabbed = null
var select_start = null
var move_start = null

var cam_modifier = 1.0 # inverted zoom (1 / zoom), as higher zoom means lesss screen  

var level_file: LevelFile = null
var button_group = ButtonGroup.new()
var buttons_in_group: Dictionary = {}
var selected_content: Array[LevelEditorPlaceholder] = []
var content_next_ids: Dictionary = {E.PLACE_ONE_WAY: 1, E.PLACE_BRICK_WALL: 1, E.PLACE_GNOME: 1,
	E.PLACE_ELF: 1, E.PLACE_COIN: 1, E.PLACE_SNOWFLAKE: 1, E.PLACE_ICE_SHARD: 1, E.PLACE_FIRE_SHARD: 1}
var cached_actions: Array[CachedAction] = []
var cached_action_pointer = -1

var grid_2x2 = false: set = set_grid_2x2

### saved ###
var player_pos = Vector2i(5, -3): set = set_player_pos
var background = E.BACKGROUND_NORMAL: set = set_background
var snow_ratio = 0.0: set = set_snow_ratio
var current_place_type = E.PLACE_TILES: set = set_current_place_type
var placed_content: Dictionary = {
	E.PLACE_ONE_WAY: [],
	E.PLACE_BRICK_WALL: [],
	E.PLACE_GNOME: [],
	E.PLACE_ELF: [],
	E.PLACE_COIN: [],
	E.PLACE_SNOWFLAKE: [],
	E.PLACE_ICE_SHARD: [],
	E.PLACE_FIRE_SHARD: [],
}: set = set_placed_content

func _ready() -> void:
	current = self
	if !Globals.funny_mode: $Overlay/PlaceContentSelection/OTHER.modulate = Color.TRANSPARENT
	place_content_selection.deselect_enabled = false
	for child in place_content_selection.get_children():
		if child is Panel:
			fill_place_contentent_selection(child.get_node("Alignment"), child.name)
			child.set_meta("TR_NAME", child.name)
			child.name = tr(child.name)
	button_group.pressed.connect(_on_place_selection_changed)
	place_content_selection.tab_selected.connect(_on_tab_selected)
	
	place_content_selection.set_tab_icon(0, load("uid://da1nbmv2j4xir"))
	place_content_selection.set_tab_icon(1, load("uid://5kdop0kxrr68"))
	place_content_selection.set_tab_icon(2, load("uid://co4dc1fhpwqs7"))
	place_content_selection.set_tab_icon_max_width(0, 25)
	place_content_selection.set_tab_icon_max_width(1, 15)
	
	level_file = Globals.current_custom_level
	viewport.size_changed.connect(adjust_camera_pos)
	grid.limit_top = BORDER_TOP
	cam_limit_left.get_node("Line").points[1].y = BORDER_TOP - 10000
	cam_limit_finish.get_node("Line").points[1].y = BORDER_TOP - 10000
	cam_limit_ground.get_node("Line").points[1].x = 100000
	cam_limit_top.get_node("Line").points[1].x = 100000
	load_from_level_file()
	zoom_update()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		calc_current_cell()
		any_action_blocked = is_any_action_blocked()
		cell_action_blocked = is_cell_action_blocked()
		if performed_action == ACTION.PLAYER_MOVEMENT: player_pos = current_cell
		
		if skip_next_relative: skip_next_relative = false
		else: last_relative = event.relative
		
		if limit_grabbed == cam_limit_left: limit_slide_left()
		elif limit_grabbed == cam_limit_finish: limit_slide_finish()
		elif limit_grabbed == cam_limit_ground: limit_slide_gound()
		elif limit_grabbed == cam_limit_top: limit_slide_top()
	
	if !any_action_blocked:
		move_key_handling()
		zoom_handling()
		if Input.is_action_just_pressed("Delete"):
			delete_selected_content()
		if Input.is_action_just_pressed("SelectAll"):#Input.is_action_just_pressed("A") and Input.is_action_pressed("Ctrl"):
			select_all()
		if Input.is_action_just_pressed("space"):
			unselect_all()
		if Input.is_action_just_pressed("ui_undo"): undo()
		if Input.is_action_just_pressed("ui_redo"): redo()
		if Input.is_action_just_pressed("Play"): play()
	
	if Input.is_action_just_pressed("Save"):
		save_level()
	if Input.is_action_just_pressed("Refresh"):
		if Input.is_action_pressed("Ctrl"): refresh()
		else: queue_refresh()
	
	if Input.is_action_just_released("mouse_left"):
		if performed_action == ACTION.SELECT:
			select()
		elif performed_action == ACTION.LIMIT_MOVEMENT: limit_grabbed = null
		elif performed_action == ACTION.CONTENT_MOVEMENT:
			store_movement_action()
		if !(performed_action == ACTION.CAM_MOVEMENT and Input.is_action_pressed("mouse_middle")):
			performed_action = ACTION.NONE
	if Input.is_action_just_released("mouse_middle") and performed_action == ACTION.CAM_MOVEMENT:
		performed_action = ACTION.NONE
	if Input.is_action_just_released("mouse_right") and performed_action == ACTION.ERASE: performed_action = ACTION.NONE
	
	if Input.is_action_just_pressed("mouse_left"):
		if performed_action == ACTION.NONE and !any_action_blocked:
			if current_action == ACTION.SELECT:
				select_start = tilemap.get_global_mouse_position()
				performed_action = ACTION.SELECT
				selection_rect.show()
			elif current_cell == player_pos: performed_action = ACTION.PLAYER_MOVEMENT
			else:
				for node_name in [cam_limit_left, cam_limit_ground, cam_limit_finish, cam_limit_top]:
					grab_limit(node_name)
				if limit_grabbed == null and !(current_action in CELL_ACTIONS and cell_action_blocked):
					if current_action == ACTION.MOVE: start_move_action()
					else: performed_action = current_action
	
	if performed_action == ACTION.NONE and !any_action_blocked:
		if Input.is_action_just_pressed("mouse_middle") or Input.is_action_just_pressed("mouse_left") and Input.is_action_pressed("Ctrl"):
			performed_action = ACTION.CAM_MOVEMENT
		if Input.is_action_just_pressed("mouse_right"):
			right_click_action()
		for key in ACTION_BUTTON_HOTKEYS.keys(): action_hotkey_switch(key, ACTION_BUTTON_HOTKEYS[key])

func right_click_action():
	var hovered_element = null
	var mouse_pos = tilemap.get_global_mouse_position()
	for element: LevelEditorPlaceholder in get_all_placed_content():
		if element.get_bounds().has_point(mouse_pos):
			hovered_element = element
			break
	if hovered_element != null:
		edit_menu = edit_menu_load.instantiate()
		edit_menu.set_placeholder(hovered_element)
		add_child(edit_menu)
		State.set_state(State.LEVEL_EDITOR_EDITING)
	elif tilemap.get_cell_source_id(current_cell) != -1:
		performed_action = ACTION.ERASE

func action_hotkey_switch(hotkey: String, button: Button):
	if Input.is_action_just_pressed(hotkey) and !button.disabled:
		button.button_pressed = true
		button.pressed.emit()

func _process(delta: float) -> void:
	var player_focus = current_cell == player_pos or performed_action == ACTION.PLAYER_MOVEMENT
	gridpointer.visible = !cell_action_blocked and !player_focus and performed_action != ACTION.SELECT
	var player_mat: ShaderMaterial = player.material
	player_mat.set_shader_parameter("line_thickness", 1 if player_focus else 0)
	if player_focus or performed_action == ACTION.CAM_MOVEMENT or (performed_action == ACTION.NONE and current_action == ACTION.CAM_MOVEMENT): overlay.mouse_default_cursor_shape = CursorShape.CURSOR_MOVE
	else: overlay.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
	action_handling()

func fill_place_contentent_selection(container: HBoxContainer, section_name: String):
	if !E.PLACE_CONTENT_TEXTURES.has(section_name): return
	var place_content_textures = E.PLACE_CONTENT_TEXTURES[section_name]
	for content_type in place_content_textures.keys():
		var place_selection_button = load("uid://4ae5tesf3qvm").instantiate()
		place_selection_button.texture = load(place_content_textures[content_type])
		place_selection_button.content_type = content_type
		place_selection_button.button_group = button_group
		
		if content_type == E.PLACE_ICE_SHARD: place_selection_button.texture_color = Color(0.7, 0.95, 2)
		elif content_type == E.PLACE_FIRE_SHARD: place_selection_button.texture_color = Color(2, 0.75, 0.5)
		
		container.add_child(place_selection_button)
		buttons_in_group.get_or_add(content_type, place_selection_button)

func action_handling():
	if performed_action == ACTION.CAM_MOVEMENT:
		if last_relative:
			mouse_trap()
			adjust_camera_pos(-last_relative)
			last_relative = null
	elif performed_action == ACTION.CONTENT_MOVEMENT:
		move_content_free()
	elif performed_action == ACTION.PLACE:
		place()
	elif performed_action == ACTION.ERASE:
		erase()
	elif performed_action == ACTION.SELECT:
		select_drag()

func zoom_handling():
	var zoomed = false
	if Input.is_action_pressed("mouse_up"):
		if camera.zoom.x < ZOOM_IN_MAX:
			zoomed = true
			var zoom_modifier = calc_zoom_modifier(ZOOM_CHANGE_X)
			set_zoom(Vector2(zoom_modifier, zoom_modifier))
	if Input.is_action_pressed("mouse_down"):
		if camera.zoom.x > ZOOM_OUT_MAX:
			zoomed = true
			var zoom_modifier = calc_zoom_modifier(-ZOOM_CHANGE_X)
			set_zoom(Vector2(zoom_modifier, zoom_modifier))
	if zoomed:
		zoom_update()

func zoom_update():
	background_node.scroll_base_scale.x = camera.zoom.x * 0.2
	cam_modifier = 1 / camera.zoom.x
	var modified = Vector2(cam_modifier, cam_modifier)
	for limit in [cam_limit_left, cam_limit_ground, cam_limit_finish, cam_limit_top]: limit.scale = modified

# shamelessly stolen *yoink*
func set_zoom(delta: Vector2) -> void:
	var mouse_pos = grid.get_global_mouse_position()
	camera.zoom += delta
	var new_mouse_pos = grid.get_global_mouse_position()
	camera.position += mouse_pos - new_mouse_pos
	adjust_camera_pos()

func calc_zoom_modifier(change_x: float):
	var extends_x = default_viewport_size.x * cam_modifier
	#return (1.0 / (1.0 - (change_x / extends_x))) - camera.zoom.x
	return 1.0 - (extends_x / (extends_x + change_x))

func calc_current_cell():
	var mouse_pos = tilemap.get_local_mouse_position()
	var cell = tilemap.local_to_map(mouse_pos if !grid_2x2 else mouse_pos * 0.5)
	cell_out_of_bounds = cell.y >= 0 or cell.x < 0 or cell.y < -BORDER_TOP_CELLS
	if !cell_out_of_bounds:
		if cell != current_cell:
			current_cell = cell
			gridpointer.position = cell_center(cell)

func calc_selection_rect():
	if selected_content.is_empty():
		selection_rect.hide()
		return
	var rect = selected_content[0].get_bounds()
	var min_pos = rect.position
	var max_extends = rect.position + rect.size
	for i in range(1, selected_content.size()):
		rect = selected_content[i].get_bounds()
		min_pos = min_pos.min(rect.position)
		max_extends = max_extends.max(rect.position + rect.size)
	selection_rect.position = min_pos
	selection_rect.size = max_extends - min_pos

func place():
	if current_cell != last_cell or last_action != ACTION.PLACE:
		last_cell = current_cell
		last_action = ACTION.PLACE
		match current_place_type:
			E.PLACE_TILES: tilemap.set_cells_terrain_connect([current_cell], 0, 0, false)
			_: place_placeholder(current_cell)

func place_placeholder(cell):
	var pos = cell_center(cell)
	if !has_container_content_at_pos(pos, PLACE_TYPE_CONTAINER_MAP[current_place_type]):
		var placeholder: LevelEditorPlaceholder = placeholder_load.instantiate()
		placeholder.set_id(get_next_place_type_id(current_place_type))
		placeholder.place_type = current_place_type
		placeholder.position = pos
		add_placeholder(placeholder, true)
		add_cached_action(CachedAction.create_place(placeholder))

func place_placeholder_cached(data, place_type):
	var placeholder: LevelEditorPlaceholder = placeholder_load.instantiate()
	placeholder.set_data(data)
	placeholder.place_type = place_type
	placeholder.selected = true
	add_placeholder(placeholder, true)

func has_container_content_at_pos(pos: Vector2, container: Node2D):
	for child in container.get_children():
		if child.position == pos: return true
	return false

func erase():
	var mouse_pos = tilemap.get_global_mouse_position()
	var all_placed := get_all_placed_content()
	for element: LevelEditorPlaceholder in all_placed:
		if element.get_bounds().has_point(mouse_pos): delete_element(element, true)
	
	if current_cell != last_cell or last_action != ACTION.ERASE:
		erase_terrain_cell(current_cell)
		last_cell = current_cell
		last_action = ACTION.ERASE

# Do not touch! *shigh*
func erase_terrain_cell(cell: Vector2i) -> void:
	var neighboring_cells: Array[Vector2i] = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			neighboring_cells.append(cell + Vector2i(x, y))
	
	tilemap.set_cells_terrain_connect([cell], 0, -1, false)
	tilemap.erase_cell(cell)

	neighboring_cells = neighboring_cells.filter(func(c):
		return tilemap.get_cell_source_id(c) != -1
	)
	if not neighboring_cells.is_empty():
		tilemap.set_cells_terrain_connect(neighboring_cells, 0, 0, false)
	
	# again as a final cleanup, cause of some nasty bugs
	tilemap.set_cells_terrain_connect([cell], 0, -1, false)
	tilemap.erase_cell(cell)
	if not neighboring_cells.is_empty():
		tilemap.set_cells_terrain_connect(neighboring_cells, 0, 0, false)

func erase_by_id(place_type: String, id: int):
	delete_element(get_element_by_id(place_type, id), false)

func select_drag():
	var mouse_pos = tilemap.get_global_mouse_position()
	selection_rect.position = Vector2(min(select_start.x, mouse_pos.x), min(select_start.y, mouse_pos.y))
	selection_rect.size = Vector2(abs(select_start.x - mouse_pos.x), abs(select_start.y - mouse_pos.y))

func select():
	if !(Input.is_action_pressed("shift") or Input.is_action_pressed("Ctrl")): unselect_all()
	var selected_rect := selection_rect.get_global_rect()
	for element: LevelEditorPlaceholder in get_all_placed_content():
		if selected_rect.intersects(element.get_bounds()):
			select_element(element)
	selection_rect.visible = !selected_content.is_empty()
	if !selected_content.is_empty(): calc_selection_rect()

func select_element(element: LevelEditorPlaceholder, calc_rect = false):
	element.selected = true
	if element not in selected_content:
		selected_content.append(element)
	if calc_rect:
		calc_selection_rect()
		selection_rect.show()

func unselect_all():
	for placeholder in selected_content:
		placeholder.selected = false
	selected_content.clear()
	selection_rect.hide()

func select_all():
	var all_placed := get_all_placed_content()
	for element: LevelEditorPlaceholder in all_placed: select_element(element)
	if !all_placed.is_empty():
		selection_rect.show()
		calc_selection_rect()

func delete_selected_content():
	add_cached_action(CachedAction.create_delete_multi(selected_content))
	for placeholder: LevelEditorPlaceholder in selected_content.duplicate(): delete_element(placeholder, false)
	selection_rect.hide()
func delete_element(placeholder: LevelEditorPlaceholder, create_cache):
	if create_cache: add_cached_action(CachedAction.create_delete(placeholder))
	placed_content[placeholder.place_type].erase(placeholder)
	placeholder.queue_free()
	if placeholder in selected_content:
		selected_content.erase(placeholder)
		calc_selection_rect()

const move_dir: Dictionary = {
	"arrow_left": Vector2(-1, 0),
	"arrow_right": Vector2(1, 0),
	"arrow_up": Vector2(0, -1),
	"arrow_down": Vector2(0, 1)
}
func move_key_handling():
	if selected_content.is_empty(): return
	
	var move_amount = MOVE_PIXEL if is_alt_action() else MOVE_WHOLE_TILE
	for key in move_dir.keys():
		if Input.is_action_just_pressed(key):
			move_content(move_amount * move_dir[key])

const MOVE_WHOLE_TILE = 48
const MOVE_PIXEL = 3
const MOVE_SUB = 1
func move_content(move_vector: Vector2, elements = selected_content, create_cache: bool = true):
	for element in elements:
		element.position += move_vector
	selection_rect.position += move_vector
	if create_cache: add_cached_action(CachedAction.create_move(elements, move_vector))
func move_content_cached(move_vector: Vector2, elements_dirs: Array):
	var elements = []
	for element_dir in elements_dirs:
		elements.append(get_element_by_id_dir(element_dir))
	move_content(move_vector, elements, false)

func move_content_free():
	var snap_to_grid := !is_alt_action()
	var delta: Vector2 = (tilemap.get_global_mouse_position() - move_start) if !snap_to_grid\
	else (grid_normalize(tilemap.get_global_mouse_position()) - grid_normalize(move_start))
	for element in selected_content: move_free(element, delta, snap_to_grid)
	#move_free(selection_rect, delta - Vector2(CELL_SIZE, CELL_SIZE) / 2, snap_to_grid)
	calc_selection_rect() # optimizable to only call that upon switching snapping to grid
func move_free(element: LevelEditorPlaceholder, delta: Vector2, snap_to_grid: bool):
	element.position = (element.get_meta("MOVE_START") if !snap_to_grid else grid_normalize(element.get_meta("MOVE_START"), element.place_type in E.PLACE_2x2)) + delta

func store_movement_action():
	if !is_alt_action(): add_cached_action(CachedAction.create_move_individual(selected_content))
	else: add_cached_action(CachedAction.create_move(selected_content.duplicate(), tilemap.get_global_mouse_position() - move_start))

func move_content_individual_cached(elements_dirs: Array, undo = true):
	for element_dir in elements_dirs:
		var element = get_element_by_id_dir(element_dir)
		element.position += element_dir[CachedAction.MOVE_VECTOR] if !undo else -element_dir[CachedAction.MOVE_VECTOR]
	calc_selection_rect()

func adjust_camera_pos(movement = Vector2.ZERO):
	var adjusted_viewport_size = adjusted_viewport_size(viewport)
	var new_pos = camera.position + movement / camera.zoom
	var x = max((CAM_LIMIT_LEFT * cam_modifier) + (adjusted_viewport_size.x / 2) / camera.zoom.x, new_pos.x)
	var y = max(CAM_LIMIT_TOP - CAM_OVERSHOOT_TOP * cam_modifier + (adjusted_viewport_size.y / 2) / camera.zoom.y, min(CAM_LIMIT_BOTTOM  * cam_modifier - (adjusted_viewport_size.y / 2) / camera.zoom.y, new_pos.y))
	camera.position = Vector2(x, y)

func mouse_trap():
	var mouse_pos_bias = get_local_mouse_position() + last_relative
	var viewport_dimensions = adjusted_viewport_size(viewport)
	const SAFE_MOUSE = 1
	if mouse_pos_bias.x >= viewport_dimensions.x:
		skip_next_relative = true
		warp_mouse(Vector2(SAFE_MOUSE, mouse_pos_bias.y))
	elif mouse_pos_bias.x <= 0:
		skip_next_relative = true
		warp_mouse(Vector2(viewport_dimensions.x - SAFE_MOUSE, mouse_pos_bias.y))
	elif mouse_pos_bias.y >= viewport_dimensions.y:
		skip_next_relative = true
		warp_mouse(Vector2(mouse_pos_bias.x, SAFE_MOUSE))
	elif mouse_pos_bias.y <= 0:
		skip_next_relative = true
		warp_mouse(Vector2(mouse_pos_bias.x, viewport_dimensions.y - SAFE_MOUSE))

# called first thing in _process (right after calc_current_cell)
func is_any_action_blocked() -> bool:
	var blocked = limit_grabbed != null or edit_menu != null or !State.equals(State.LEVEL_EDITOR)
	if !blocked:
		# hovering over UI nodes?
		var mouse_pos = get_local_mouse_position()
		for element: Control in get_tree().get_nodes_in_group("ActionBlocker"):
			if element.visible and element.get_rect().has_point(mouse_pos):
				blocked = true
	return blocked
func is_cell_action_blocked() -> bool:
	return any_action_blocked or cell_out_of_bounds or performed_action == ACTION.CAM_MOVEMENT

func limit_slide_left():
	var mouse_pos = tilemap.get_global_mouse_position()
	cam_limit_left.position.x = max(0, mouse_pos.x)
	cam_limit_finish.position.x = max(cam_limit_left.position.x + default_viewport_size.x * 1.7, cam_limit_finish.position.x)
func limit_slide_finish():
	var mouse_pos = tilemap.get_global_mouse_position()
	cam_limit_finish.position.x = max(cam_limit_left.position.x + default_viewport_size.x * 1.7, mouse_pos.x)
func limit_slide_gound():
	var mouse_pos = tilemap.get_global_mouse_position()
	cam_limit_ground.position.y = min(0, mouse_pos.y)
	cam_limit_top.position.y = min(cam_limit_ground.position.y - default_viewport_size.y, cam_limit_top.position.y)
func limit_slide_top():
	var mouse_pos = tilemap.get_global_mouse_position()
	cam_limit_top.position.y = min(cam_limit_ground.position.y - default_viewport_size.y, mouse_pos.y)

func grab_limit(limit: Node2D):
	if current_action != ACTION.CAM_MOVEMENT and limit.get_node("Button").get_global_rect().has_point(tilemap.get_global_mouse_position()):
		limit_grabbed = limit
		performed_action = ACTION.LIMIT_MOVEMENT

func start_move_action():
	var mouse_pos = tilemap.get_global_mouse_position()
	if !selected_content.is_empty() and selection_rect.get_global_rect().has_point(mouse_pos):
		move_start = mouse_pos
		performed_action = ACTION.CONTENT_MOVEMENT
		selection_rect.set_meta("MOVE_START", selection_rect.position)
		for element in selected_content:
			element.set_meta("MOVE_START", element.position)
	else:
		performed_action = ACTION.CAM_MOVEMENT

func cell_center(cell: Vector2i, is_2x2: bool = grid_2x2) -> Vector2:
	return static_cell_center(cell) if !is_2x2 else (static_cell_center(cell) * 2)
const offset_2x2 = Vector2(-CELL_SIZE, CELL_SIZE) / 2
func grid_normalize(pos: Vector2, is_2x2: bool = false) -> Vector2:
	return cell_center(Vector2i((pos - offset_2x2) / CELL_SIZE)) - Vector2(0, CELL_SIZE) + offset_2x2\
	if is_2x2 else cell_center(Vector2i(pos / CELL_SIZE)) - Vector2(0, CELL_SIZE)

func get_all_placed_content() -> Array:
	var result = []
	for key in placed_content.keys():
		result.append_array(placed_content[key])
	return result


func undo():
	if cached_action_pointer < 0: return
	var action_to_undo = cached_actions[cached_action_pointer]
	action_to_undo.undo()
	cached_action_pointer -= 1
	if cached_action_pointer == -1:
		undo_button.disabled = true
	redo_button.disabled = false
	
	ui.show_image_alert(E.IMAGE_ALERTS.UNDONE, [tr(E.enum_to_string(ACTION, action_to_undo.action))])

func redo():
	if cached_action_pointer == cached_actions.size() - 1: return
	var action_to_redo = cached_actions[cached_action_pointer + 1]
	action_to_redo.redo()
	cached_action_pointer += 1
	if cached_action_pointer == cached_actions.size() - 1:
		redo_button.disabled = true
	undo_button.disabled = false
	
	if Globals.funny_mode:
		$Overlay/Middle/Animation.play("RESET")
		$Overlay/Middle/Animation.play("GekokstIstGeil")
	
	ui.show_image_alert(E.IMAGE_ALERTS.REDONE, [tr(E.enum_to_string(ACTION, action_to_redo.action))])

func add_cached_action(action: CachedAction):
	if cached_action_pointer < cached_actions.size() - 1:
		for i in range(cached_actions.size() - cached_action_pointer - 1): cached_actions.pop_back()
	cached_actions.append(action)
	cached_action_pointer = cached_actions.size() - 1
	undo_button.disabled = false
	redo_button.disabled = true

func is_alt_action() -> bool:
	return Input.is_action_pressed("Ctrl") or Input.is_action_pressed("shift")

func is_edit_menu() -> bool: return edit_menu != null
func close_edit_menu(): edit_menu._on_close()

func set_placeholder_data(place_type: String, id: int, data: Dictionary):
	get_element_by_id(place_type, id).set_data(data)

func get_next_place_type_id(place_type: String) -> int:
	var id = content_next_ids[place_type]
	content_next_ids[place_type] = id + 1
	return id

func get_element_by_id(place_type: String, id: int):
	for element: LevelEditorPlaceholder in placed_content[place_type]:
		if element.get_id() == id: return element
func get_element_by_id_dir(dir: Dictionary):
	return get_element_by_id(dir[CachedAction.TYPE], dir[CachedAction.ID])

func add_placeholder(placeholder: LevelEditorPlaceholder, selected = false):
	placed_content[placeholder.place_type].append(placeholder)
	PLACE_TYPE_CONTAINER_MAP[placeholder.place_type].add_child(placeholder)
	if selected:
		unselect_all()
		select_element(placeholder, true)

##### custom setters #####

func set_player_pos(pos: Vector2i):
	player_pos = pos
	player.position = cell_center(pos)

func set_background(new_background):
	background = new_background
	
	if background == E.BACKGROUND_NORMAL: background_button.icon = load("res://Resources/Images/Icons/Background/Sun.png")
	if background == E.BACKGROUND_NIGHT: background_button.icon = load("res://Resources/Images/Icons/Background/Moon.png")
	if background == E.BACKGROUND_MOON: background_button.icon = load("res://Resources/Images/Icons/Background/RealMoonStars.png")
	
	background_node.night = background in [E.BACKGROUND_NIGHT, E.BACKGROUND_MOON]
	background_node.moon_visible = background == E.BACKGROUND_NIGHT
	background_node.on_moon = background == E.BACKGROUND_MOON

func set_snow_ratio(ratio):
	snow_ratio = ratio
	snow_particles.amount_ratio = snow_ratio
	if snow_slider.value != snow_ratio:
		snow_slider.value = snow_ratio

func set_current_place_type(place_type: String):
	if place_type != current_place_type:
		current_place_type = place_type
		grid_2x2 = place_type in E.PLACE_2x2

func set_current_action(new_action: ACTION):
	if new_action != current_action:
		last_action = current_action
		current_action = new_action
		place_content_selection.visible = new_action == ACTION.PLACE
		selection_actions.visible = new_action == ACTION.SELECT
		if selected_content.is_empty(): selection_rect.hide()
		for action: ACTION in ACTION_BUTTON_MAP.keys():
			var label: Label = ACTION_BUTTON_MAP[action].get_node("Label")
			label.add_theme_constant_override("outline_size", 8 if action == new_action else 0)

func set_performed_action(action: ACTION):
	performed_action = action
	var action_button = ACTION_BUTTON_MAP.get(current_action if performed_action == ACTION.NONE else performed_action)
	if action_button != null:
		action_button.button_pressed = true

func set_grid_2x2(is_2x2: bool):
	if grid_2x2 != is_2x2:
		grid_2x2 = is_2x2
		grid.grid_size = 96 if grid_2x2 else 48
		gridpointer.scale = Vector2(2, 2) if grid_2x2 else Vector2.ONE

func set_placed_content(new_content: Dictionary):
	for place_type in PLACE_TYPE_CONTAINER_MAP.keys():
		var container: Node2D = PLACE_TYPE_CONTAINER_MAP[place_type]
		for content: Dictionary in new_content[place_type]:
			var placeholder: LevelEditorPlaceholder = placeholder_load.instantiate()
			placeholder.place_type = place_type
			placeholder.data = content
			var id = placeholder.get_id()
			if id != -1 and content_next_ids[place_type] < id: content_next_ids[place_type] = id + 1
			container.add_child(placeholder)
			placed_content[place_type].append(placeholder)
	
	for placeholder: LevelEditorPlaceholder in get_all_placed_content():
		if placeholder.get_id() == -1: placeholder.set_id(get_next_place_type_id(placeholder.place_type))

##### File Actions #####

func load_from_level_file():
	tilemap.clear()
	tilemap.set_cells_terrain_connect(level_file.get_tiles(), 0, 0, false)
	
	### with custom setters ###
	player_pos = level_file.get_player_pos()
	background = level_file.get_background()
	snow_ratio = level_file.get_snow_ratio()
	current_action = level_file.get_current_action() as ACTION
	placed_content = level_file.get_placed_content()
	
	current_place_type = level_file.get_current_place_type()
	buttons_in_group[current_place_type].select()
	var place_tab_name = E.place_tab_of(current_place_type)
	for child in place_content_selection.get_children():
		if child.get_meta("TR_NAME") == place_tab_name: child.visible = true
	
	var limits: Vector4 = level_file.get_cam_limits()
	cam_limit_left.position.x = limits.x
	cam_limit_ground.position.y = limits.y
	cam_limit_finish.position.x =  max(cam_limit_left.position.x + default_viewport_size.x * 1.7, limits.z)
	cam_limit_top.position.y =  min(cam_limit_ground.position.y - default_viewport_size.y, limits.w)
	
	camera.position = level_file.get_cam_position()
	camera.zoom = level_file.get_cam_zoom()
	adjust_camera_pos()

func save_level() -> bool:
	level_file.set_tiles(tilemap.get_used_cells())
	level_file.set_placed_content(get_placed_content())
	level_file.set_cam_limits(cam_limit_left.position.x, cam_limit_ground.position.y, cam_limit_finish.position.x, cam_limit_top.position.y)
	level_file.set_cam_properties(camera.position, camera.zoom.x)
	level_file.set_snow_ratio(snow_ratio)
	level_file.set_player_pos(player_pos)
	level_file.set_background(background)
	level_file.set_current_action(current_action)
	level_file.set_current_place_type(current_place_type)
	var save_successful = true
	if !cached_actions.is_empty():
		level_file.set_ghost_frames([])
		level_file.set_validated(false)
		save_successful = level_file.save()
		ui.show_image_alert(E.IMAGE_ALERTS.SAVED_SUCCESSFULLY if save_successful else E.IMAGE_ALERTS.SAVE_FAILED)
	if State.current_state != State.LEVEL_EDITOR: ui.change_scenes(State.LEVEL_EDITOR)
	return save_successful

func get_placed_content() -> Dictionary:
	var content = LevelFile.base_level_data["placed_content"].duplicate(true)
	for place_type in placed_content.keys():
		for placeholder: LevelEditorPlaceholder in placed_content[place_type]:
			content[place_type].append(placeholder.get_data())
	return content

### statics ### (here to make signals go right to the bottom and not having to drag them up)

const default_viewport_size = Vector2(1152, 648)
static func adjusted_viewport_size(viewport) -> Vector2:
	if viewport == null: return default_viewport_size
	var x_ratio = viewport.size.x / default_viewport_size.x
	var y_ratio = viewport.size.y / default_viewport_size.y
	if x_ratio > y_ratio:
		return default_viewport_size * Vector2(x_ratio / y_ratio, 1)
	return default_viewport_size

static func static_cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE + Vector2i(CELL_SIZE/2, CELL_SIZE/2))


##### helpers for signals #####

func _connect_exit_menu(exit_menu: Control):
	exit_menu.get_node("Container/Resume").connect("pressed", resume)
	exit_menu.get_node("Container/SaveAndExit").connect("pressed", save_and_exit)
	exit_menu.get_node("Container/Save").connect("pressed", save_level)
	exit_menu.get_node("Container/Exit").connect("pressed", exit)

func resume():
	ui.change_scenes(State.LEVEL_EDITOR)

func save_and_exit():
	save_level()
	ui.change_scenes(State.CREATE_LEVEL_MENU)

func exit():
	if cached_actions.is_empty(): exit_without_save()
	else: Globals.dialog(tr("EXIT_WITHOUT_SAVE"), exit_without_save, self)
func exit_without_save():
	ui.change_scenes(State.CREATE_LEVEL_MENU)

func refresh():
	ui.refresh_level_editor()
func queue_refresh():
	Globals.dialog(tr("REFRESH_EDITOR"), refresh, self)

##### signals #####

func settings() -> void:
	pass # Add menu -> first feature = Upgrades configurable as either User's one, or select / unselect and tweak upgrades for one level

func play() -> void:
	if save_level():
		level_file.play()

func _on_exit_pressed() -> void:
	ui.change_scenes(State.LEVEL_EDITOR_EXIT)

func rotate_background() -> void:
	background = E.BACKGROUND_NORMAL if background == E.BACKGROUND_MOON else background + 1

func _on_snow_slider_value_changed(value: float) -> void:
	snow_ratio = value

var selection_hidden = false
var previous_tab = 0
func _on_tab_selected(tab: int):
	if tab == previous_tab: selection_hidden = !selection_hidden
	else: selection_hidden = false
	place_content_selection.position.y = 472 if !selection_hidden else default_viewport_size.y - 31
	previous_tab = tab

func _on_place_selection_changed(button):
	current_place_type = button.get_parent().content_type

func _on_place_button_pressed() -> void:
	current_action = ACTION.PLACE

func _on_erase_button_pressed() -> void:
	current_action = ACTION.ERASE

func _on_select_button_pressed() -> void:
	current_action = ACTION.SELECT

func _on_move_button_pressed() -> void:
	current_action = ACTION.MOVE
