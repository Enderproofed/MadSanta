class_name UI extends Control

const sandbox_level = "res://Scenes/Levels/LevelBaseSandboxTest.tscn"

var text_visible = false
var text_pointer = 0
var texts_to_show = []
var text_switch_blocked = false
var menu = true
var scene_change_ongoing = false

var mouse_offset = Vector2(0,0)
var slide_cam_pos_offset = 0

@onready var title = $TitleFixture/Title

@onready var targets_minigame_load = load("uid://q1nycd58ktwn")
@onready var base_level_load = load("uid://bn5bv5a8wlsae")
@onready var gnome_load = load("uid://gv4layjcwelw")
@onready var elf_load = load("uid://cf5ify7hs515i")
@onready var brick_wall_load = load("uid://boqrpx2ng8sea")
@onready var one_way_load = load("uid://2orvl78ydeks")
@onready var coin_load = load("uid://bawf6rrfoul0i")
@onready var snowflake_load = load("uid://c86r2jrovbcdf")
@onready var ice_shard_load = load("uid://6ydg47mvcxcl")
@onready var fire_shard_load = load("uid://dbiwksccqorqa")

func _ready() -> void:
	$WeaponSelection/Animation.play("hide")
	if Globals.sandbox_test:
		start_sandbox()
	else:
		start_game()

func start_game():
	change_scenes(State.current_state)

func start_sandbox():
	State.set_state(State.PLAYING)
	change_scenes(State.current_state)
	Save.load_sandbox_mode()
	Globals.load_sandbox_mode()
	start_level_scene(load(sandbox_level))

func _process(delta: float) -> void:
	if State.equals(State.TEXT):
		$Text/Label.visible_ratio += delta/3
	if State.is_menu():
		mouse_offset = lerp(mouse_offset, (get_local_mouse_position() - Vector2(0, 550)), 0.2)
		slide_cam_pos_offset += 1
		var actual_slide_cam_y = 0 if mouse_offset.y > 0 else -(mouse_offset.y * mouse_offset.y) / 85
		$Background/SildeCam.position = Vector2((mouse_offset.x / 10) + slide_cam_pos_offset, actual_slide_cam_y)
	

func start_text_sequence(texts):
	if Globals.player != null: Globals.player.stop_laser()
	var text_array = Texts.get_text(texts) if texts is Texts.TEXTS else texts
	change_scenes(State.TEXT)
	text_switch_blocked = false
	texts_to_show = text_array
	text_switch_blocked = true
	change_text(text_array[0])
	text_switch_blocked = false

func _input(event: InputEvent) -> void:
	if State.equals(State.TEXT) and Input.is_action_just_pressed("Text"):
		if $Text/Label.visible_ratio < 1.0:
			$Text/Label.visible_ratio = 1
		else: next_text()
	if (State.is_playing() or State.equals([State.PAUSED, State.FINISH_MENU, State.DEATH_SCREEN])) and Input.is_action_just_pressed("restart"):
		play_again()

func end_text():
	$Text/Animation.play_backwards("show_text")
	#await Globals.timer(0.85)
	change_scenes(State.PLAYING)
	texts_to_show = []
	text_pointer = 0
	text_visible = false
	Globals.level1_played = true
	Save.save_value(["level1_played", "triggered_texts"])
	if Globals.level != null:
		Globals.level.zoom_out()
	Globals.reset_camera()

func next_text():
	if !text_switch_blocked and !texts_to_show.is_empty():
		text_switch_blocked = true
		if text_pointer == texts_to_show.size()-1:
			end_text()
		else:
			text_pointer += 1
			change_text(texts_to_show[text_pointer])
		text_switch_blocked = false

func change_text(text: String):
	if !text_visible:
		text_visible = true
		$Text/Label.text = text
		$Text/Animation.play("show_text")
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.85)
	else:
		$Text/Animation.play("change_text")
		await Globals.timer(0.5)
		$Text/Label.text = text
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.5)

func intro_text():
	start_text_sequence(Texts.INTRO)

func back():
	if State.equals(State.TEXT): next_text()
	elif State.equals(State.LEVEL_EDITOR) and LevelEditor.current.is_edit_menu(): LevelEditor.current.close_edit_menu()
	else: change_scenes(State.back())

func ui_init_or_destroy(container_dict: Dictionary, init: bool, instance_name: String, scene_path: String):
	if init:
		if !container_dict.has(instance_name):
			var instance = load(scene_path).instantiate()
			container_dict[instance_name] = instance
			add_child(instance)
			if instance is Overlay: await instance.ready # may be extended to await all
			return instance
		else: return container_dict[instance_name]
	else:
		var instance = container_dict.get(instance_name)
		if instance != null:
			if instance is Overlay:
				instance.remove()
			else: instance.queue_free()
			container_dict.erase(instance_name)
	return null

var menus: Dictionary = {}
func menu_init_or_destroy(new_state, menu_state, instance_name: String, subfolder: String = "", alt_states = []):
	ui_init_or_destroy(menus, new_state == menu_state or new_state in alt_states, State.to_text(menu_state), str("res://Scenes/UI/Menus/", subfolder, instance_name, ".tscn"))

var overlays: Dictionary = {}
func overlay_init_or_destroy(init: bool, instance_name: String):
	ui_init_or_destroy(overlays, init, instance_name, str("res://Scenes/UI/Overlays/", instance_name, ".tscn"))

func change_scenes(scene, transition_time: float = 0.0, wait_time: float = 0.0) -> void:
	if scene == null:
		printerr("Ehh... null haben wir leider nicht im Angebot")
		return
	if scene_change_ongoing: return
	scene_change_ongoing = true
	
	if wait_time != 0:
		await Globals.timer(wait_time)
	
	if transition_time != 0:
		$Transition/Animation.speed_scale = 1 / transition_time
		$Transition/Animation.play("transition1s")
		await Globals.timer(transition_time / 2)
	
	if Globals.target_minigame_active and !(State.is_ingame_menu(scene) or scene == State.PAUSED_IN_GAME):
		Globals.target_minigame_active = false
	if !Globals.target_minigame_active and Globals.active_minigame != null:
		Globals.active_minigame.queue_free()
		Globals.active_minigame = null
		remove_targets_overlay()
	if scene == State.TARGET_MINIGAME and !Globals.target_minigame_active:
		Globals.target_minigame_active = true
		start_targets_minigame()
	
	var playing = State.is_playing(scene)
	var was_playing = State.is_playing()
	
	if Overlay.current_overlay: Overlay.current_overlay.visible = playing or scene == State.PAUSED_IN_GAME
	
	menu_hub(scene)
	
	if scene in [State.LEVEL_SELECTION, State.MAIN_MENU, State.CREATE_LEVEL_MENU]:
		Globals.current_custom_level = null
		Globals.playing_custom_level = false
	
	$Background/SildeCam.enabled = State.has_background(scene)
	$Background.visible = State.has_background(scene)
	title.visible = State.has_title(scene)
	if title.visible: Localization.translate_node(title, State.to_text(scene))
	if playing: $WeaponSelection/Animation.play("show")
	if was_playing: $WeaponSelection/Animation.play("hide")
	if scene == State.LEVEL_SELECTION and !Globals.level1_played:
		scene_change_ongoing = false
		start_level_scene(Globals.levels.front())
		return
	menu_init_or_destroy(scene, State.LEVEL_SELECTION, "level_selection", "", [State.LEVEL_SELECTION_SPEEDRUN])
	if State.is_paused(scene):
		Globals.set_paused(true)
	if State.is_playing(scene):
		Globals.set_paused(false)
	if scene in [State.MAIN_MENU, State.LEVEL_SELECTION, State.LEVEL_SELECTION_SPEEDRUN, State.LEVEL_EDITOR, State.CREATE_LEVEL_MENU]:
		delete_level()
	
	State.set_state(scene)
	Localization.retranslate_all()
	scene_change_ongoing = false
	SignalBus.state_changed.emit(scene)

func menu_hub(scene):
	menu_init_or_destroy(scene, State.SAVE_MENU, "save_file_menu")
	menu_init_or_destroy(scene, State.MAIN_MENU, "main_menu")
	menu_init_or_destroy(scene, State.CREDITS, "credits")
	menu_init_or_destroy(scene, State.PAUSED, "pause_menu")
	menu_init_or_destroy(scene, State.FINISH_MENU, "finish_menu")
	menu_init_or_destroy(scene, State.COLLECT_MENU, "collect_menu")
	menu_init_or_destroy(scene, State.DEATH_SCREEN, "game_over_menu")
	menu_init_or_destroy(scene, State.SETTINGS, "settings_menu")
	menu_init_or_destroy(scene, State.UPGRADES, "upgrade_menu")
	menu_init_or_destroy(scene, State.MINIGAMES_MENU, "minigame_menu")
	menu_init_or_destroy(scene, State.CREATE_LEVEL_MENU, "create_levels_menu")
	menu_init_or_destroy(scene, State.LEVEL_EDITOR_EXIT, "exit_menu", "LevelEditor/")
	menu_init_or_destroy(scene, State.LEVEL_EDITOR, "level_editor", "LevelEditor/", [State.LEVEL_EDITOR_EXIT, State.LEVEL_EDITOR_EDITING])
	if scene not in [State.LEVEL_EDITOR, State.LEVEL_EDITOR_EXIT]: LevelEditor.current = null

func refresh_level_editor():
	var level_file = Save.load_level(Globals.current_custom_level.get_level_name())
	if level_file.invalid: show_image_alert(E.IMAGE_ALERTS.FAILED_TO_LOAD)
	else:
		ui_init_or_destroy(menus, false, State.to_text(State.LEVEL_EDITOR), "")
		menu_init_or_destroy(State.current_state, State.LEVEL_EDITOR, "level_editor", "LevelEditor/", [State.LEVEL_EDITOR_EXIT])

func add_level_overlay() -> LevelOverlay:
	return overlay_init_or_destroy(true, "level_overlay")
func remove_level_overlay():
	overlay_init_or_destroy(false, "level_overlay")
func add_targets_overlay() -> LevelOverlay:
	return overlay_init_or_destroy(true, "targets_overlay")
func remove_targets_overlay():
	overlay_init_or_destroy(false, "targets_overlay")

func start_targets_minigame():
	Globals.weapon_selection.set_all_disabled_except(E.CHEST_ITEMS.ICICLE)
	var minigame = targets_minigame_load.instantiate()
	get_node("../../WorldLayer/World").add_child(minigame)
	Globals.active_minigame = minigame

func start_custom_level(level_file: LevelFile):
	add_level_overlay()
	
	Globals.playing_custom_level = true
	Globals.current_custom_level = level_file
	var base_level: Level = base_level_load.instantiate()
	base_level.set_ghost_frames(level_file.get_ghost_frames())
	
	var player: Player = base_level.get_node("Player")
	player.position = LevelEditor.static_cell_center(level_file.get_player_pos())
	#player.set_snow_ratio(level_file.get_snow_ratio())
	
	var tilemap: TileMapLayer = base_level.get_node("Level/TileMapLayer")
	tilemap.clear()
	tilemap.set_cells_terrain_connect(level_file.get_tiles(), 0, 0, false)
	tilemap.bake_that_thing()
	
	fill_custom_level_content(level_file, base_level)
	
	var background = level_file.get_background()
	var cam_limits = level_file.get_cam_limits()
	var level_base: LevelBase = base_level.get_node("LevelBase")
	level_base.night = background == E.BACKGROUND_NIGHT or background == E.BACKGROUND_MOON
	level_base.on_moon = background == E.BACKGROUND_MOON
	level_base.border_left = cam_limits.x
	level_base.border_bottom = cam_limits.y
	level_base.finish_position = cam_limits.z
	level_base.border_top = cam_limits.w
	level_base.init()
	
	base_level.snow_ratio = level_file.get_snow_ratio()
	base_level.gravity_scale = 0.2 if background == E.BACKGROUND_MOON else 1.0
	
	start_level(base_level)

func start_level(level: Level, text_sequence = null):
	change_scenes(State.SPEEDRUN_MINIGAME if State.equals(State.LEVEL_SELECTION_SPEEDRUN) else State.PLAYING)
	
	get_node("../../WorldLayer/World").add_child(level)
	Globals.level = level
	Globals.enemies_killed = 0
	var enemies = 0
	for enemy in level.get_node("Enemies").get_children():
		if enemy is Enemy: enemies += 1
		elif enemy is Node2D:
			for e in enemy.get_children():
				if e is Enemy: enemies += 1
	Globals.enemies_in_level = enemies
	Globals.store_on_complete_data()
	if text_sequence != null and (text_sequence != intro_text or (level.level_number == 1 and !Globals.level1_played and !Globals.skip_intro_text)):
		text_sequence.call()
	else:
		await get_tree().physics_frame
		if level != null:
			level.zoom_out()

func start_level_scene(level_scene: PackedScene):
	Globals.playing_custom_level = false
	if Globals.target_minigame_active and Globals.active_minigame != null:
		Globals.active_minigame.queue_free()
		add_targets_overlay()
		start_targets_minigame()
	else:
		add_level_overlay()
		start_level(level_scene.instantiate(), intro_text)

func next_level():
	delete_level()
	Globals.current_level += 1
	if Globals.levels.size() >= Globals.current_level:
		start_level_scene(Globals.levels[Globals.current_level-1])
	else: 
		change_scenes(State.LEVEL_SELECTION)

func play_again():
	delete_level()
	if Globals.sandbox_test: start_sandbox()
	elif Globals.current_custom_level != null: start_custom_level(Globals.current_custom_level)
	else: start_level_scene(Globals.levels[Globals.current_level-1])

func delete_level():
	if Globals.level != null:
		Globals.level.queue_free()
		Globals.level = null
		Globals.revert_stored_on_complete_data()
		remove_level_overlay()

func fill_custom_level_content(level_file: LevelFile, base_level: Level):
	var placed_content: Dictionary = level_file.get_placed_content()
	
	var container: Node2D = base_level.get_node("Level/OneWayPlatforms")
	for content in placed_content[E.PLACE_ONE_WAY]:
		var one_way = one_way_load.instantiate()
		one_way.position = content[LevelEditorPlaceholder.POSITION] - Vector2(LevelEditor.CELL_SIZE, LevelEditor.CELL_SIZE) / 2
		container.add_child(one_way)
	
	container = base_level.get_node("Level/BrickWalls")
	for content in placed_content[E.PLACE_BRICK_WALL]:
		var brick_wall = brick_wall_load.instantiate()
		brick_wall.position = content[LevelEditorPlaceholder.POSITION]
		container.add_child(brick_wall)
	
	container = base_level.get_node("Enemies")
	for content: Dictionary in placed_content[E.PLACE_GNOME]:
		var gnome: Gnome = gnome_load.instantiate()
		set_enemy_name(content, gnome)
		gnome.size = content.get(LevelEditorPlaceholder.SIZE, 1)
		gnome.position = content[LevelEditorPlaceholder.POSITION] - Vector2(0, 3 * gnome.size)
		container.add_child(gnome)
	for content in placed_content[E.PLACE_ELF]:
		var elf = elf_load.instantiate()
		set_enemy_name(content, elf)
		elf.position = content[LevelEditorPlaceholder.POSITION] - Vector2(0, 3)
		container.add_child(elf)
	
	container = base_level.get_node("Collectables/Coins")
	for content in placed_content[E.PLACE_COIN]:
		var coin = coin_load.instantiate()
		coin.position = content[LevelEditorPlaceholder.POSITION]
		container.add_child(coin)
	container = base_level.get_node("Collectables/Snowflakes")
	for content in placed_content[E.PLACE_SNOWFLAKE]:
		var snowflake = snowflake_load.instantiate()
		snowflake.id = -2
		snowflake.position = content[LevelEditorPlaceholder.POSITION]
		container.add_child(snowflake)
	container = base_level.get_node("Collectables/Shards")
	for content in placed_content[E.PLACE_ICE_SHARD]:
		var ice_shard = ice_shard_load.instantiate()
		ice_shard.position = content[LevelEditorPlaceholder.POSITION]
		container.add_child(ice_shard)
	for content in placed_content[E.PLACE_FIRE_SHARD]:
		var fire_shard = fire_shard_load.instantiate()
		fire_shard.position = content[LevelEditorPlaceholder.POSITION]
		container.add_child(fire_shard)

func set_enemy_name(placeholder: Dictionary, enemy: Enemy):
	enemy.has_name = placeholder[LevelEditorPlaceholder.HAS_NAME] if placeholder.has(LevelEditorPlaceholder.HAS_NAME) else false
	enemy.random_name = placeholder[LevelEditorPlaceholder.RANDOM_NAME] if placeholder.has(LevelEditorPlaceholder.RANDOM_NAME) else false
	enemy.enemy_name = placeholder[LevelEditorPlaceholder.NAME] if placeholder.has(LevelEditorPlaceholder.NAME) else ""

func hovering_over_overlay_buttons() -> bool:
	if Overlay.current_overlay:
		var mouse_pos = get_local_mouse_position()
		for action_blocker: Control in Overlay.current_overlay.get_tree().get_nodes_in_group("ActionBlocker"):
			if action_blocker.get_rect().has_point(get_local_mouse_position()):
				return true
	return false

func show_alert(message: String):
	var alert = load("res://Scenes/Alerts/WorldAlert.tscn").instantiate()
	alert.get_node("Label").text = message
	$MessagePos.add_child(alert)
	alert.position = Vector2.ZERO

func show_image_alert(image_alert: E.IMAGE_ALERTS, params = []):
	var alert_key = E.image_alert_to_text(image_alert)
	var alert = load("res://Scenes/Alerts/ImageAlert.tscn").instantiate()
	var translated_alert_text = tr(alert_key)
	for i in params.size():
		translated_alert_text = translated_alert_text.replace(str("{", i, "}"), params[i])
	alert.get_node("MovingPoint/Label").text = translated_alert_text
	alert.get_node("Animation").play("SUCCESS" if E.is_image_alert_positive(image_alert) else "FAIL")
	$ImageAlertPos.add_child(alert)
