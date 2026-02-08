class_name UI extends Control

const titles_map = {
	Globals.SAVE_MENU: "Spielstände",
	Globals.MAIN_MENU: "Mad Santa",
	Globals.DEATH_SCREEN: "Game Over",
	Globals.LEVEL_SELECTION: "Levelauswahl",
	Globals.CREDITS: "Credits",
	Globals.SETTINGS: "Einstellungen",
	Globals.PAUSED: "Pause",
	Globals.SETTINGS_PAUSE: "Einstellungen",
	Globals.FINISH_MENU: "Geschafft!",
	Globals.UPGRADES: "Upgrades"
}
const scenes_without_background = [Globals.PLAYING, Globals.FINISH_MENU, Globals.DEATH_SCREEN]
const paused_scenes = [Globals.PAUSED, Globals.PAUSED_IN_GAME, Globals.TEXT]

var text_visible = false
var text_pointer = 0
var texts_to_show = []
var text_switch_blocked = false
var menu = true
var settings_from = ""
#var a = 0

var mouse_offset = Vector2(0,0)
var slide_cam_pos_offset = 0

@onready var title = $TitleFixture/Title
@onready var overlay_buttons = $LevelOverlay/Buttons

func _ready() -> void:
	change_scenes(Globals.state)
	await Globals.timer(0.01)
	if Globals.state == Globals.PLAYING:
		start_level(preload("res://Scenes/level_1.tscn"))

func _process(delta: float) -> void:
	if Globals.PLAYING:
		$Text/Label.visible_ratio += delta/3
	if Globals.MAIN_MENU:
		mouse_offset = lerp(mouse_offset, (get_local_mouse_position() - Vector2(0, 550)), 0.2)
		slide_cam_pos_offset += 1
		var actual_slide_cam_y = 0 if mouse_offset.y > 0 else -(mouse_offset.y * mouse_offset.y) / 85
		$Background/SildeCam.position = Vector2((mouse_offset.x / 10) + slide_cam_pos_offset, actual_slide_cam_y)

func start_text_sequence(texts):
	var text_array = Texts.get_text(texts) if texts is Texts.TEXTS else texts
	change_scenes(Globals.TEXT)
	text_switch_blocked = false
	texts_to_show = text_array
	text_switch_blocked = true
	change_text(text_array[0])
	text_switch_blocked = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Text"):
		if $Text/Label.visible_ratio < 1.0:
			$Text/Label.visible_ratio = 1
		else: next_text()

func end_text():
	$Text/Animation.play_backwards("show_text")
	#await Globals.timer(0.85)
	change_scenes(Globals.PLAYING)
	texts_to_show = []
	text_pointer = 0
	text_visible = false
	Globals.level1_played = true
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
	match Globals.state:
		Globals.FINISH_MENU:
			change_scenes(Globals.LEVEL_SELECTION)
		Globals.LEVEL_SELECTION:
			change_scenes(Globals.MAIN_MENU)
		Globals.CREDITS:
			change_scenes(Globals.MAIN_MENU)
		Globals.SETTINGS:
			change_scenes(Globals.MAIN_MENU)
		Globals.DEATH_SCREEN:
			change_scenes(Globals.MAIN_MENU)
		Globals.SAVE_MENU:
			get_tree().quit()
		Globals.MAIN_MENU:
			change_scenes(Globals.SAVE_MENU)
		Globals.PAUSED:
			change_scenes(Globals.PLAYING)#get_tree().quit()
		Globals.PLAYING:
			change_scenes(Globals.PAUSED)
		Globals.SETTINGS_PAUSE:
			change_scenes(Globals.PAUSED)
		Globals.SETTINGS_PLAYING:
			change_scenes(Globals.PLAYING)
		Globals.UPGRADES:
			change_scenes(Globals.PLAYING)
		Globals.TEXT:
			next_text()

func change_scenes(sceneName: String) -> void:
	var isSettings = Globals.isSettings(sceneName)
	settings_from = Globals.state if isSettings else ""
	$SettingsMenu.visible = isSettings
	$PauseMenu.visible = sceneName == Globals.PAUSED and Globals.state == Globals.PLAYING or Globals.state == Globals.SETTINGS_PAUSE
	$MainMenu.visible = sceneName == Globals.MAIN_MENU
	$LevelSelection.visible = sceneName == Globals.LEVEL_SELECTION
	$Credits.visible = sceneName == Globals.CREDITS
	$Background/SildeCam.enabled = sceneName not in scenes_without_background
	$Background.visible = sceneName not in scenes_without_background
	title.visible = sceneName in titles_map.keys()
	$WeaponSelection/Animation.play("show" if sceneName == Globals.PLAYING else "hide")
	$gameOverMenu.visible = sceneName == Globals.DEATH_SCREEN
	$LevelOverlay.visible = sceneName == Globals.PLAYING or sceneName == Globals.PAUSED_IN_GAME
	$SaveMenu.visible = sceneName == Globals.SAVE_MENU
	$UpgradeMenu.visible = sceneName == Globals.UPGRADES
	if title.visible: title.text = titles_map[sceneName]
	if sceneName == Globals.SAVE_MENU:
		$SaveMenu.init()
	if sceneName == Globals.LEVEL_SELECTION:
		Globals.update_level_buttons()
	if sceneName in paused_scenes:
		get_tree().paused = true
	if sceneName == Globals.PLAYING:
		get_tree().paused = false
	if sceneName == Globals.FINISH_MENU:
		$Animations.stop()
		$Animations.play("fade_finish_menu")
		$FinishMenu/MarginContainer/VBoxContainer/NextLevel.visible = Globals.levels.size() > Globals.current_level
		$FinishMenu/EnemiesKilled.text = str(Globals.enemies_killed, " / ", Globals.enemies_in_level)
	else:
		$FinishMenu.hide()
		$FinishMenu.modulate.a = 0
		#TODO might need check for current game state
	if sceneName in [Globals.MAIN_MENU, Globals.LEVEL_SELECTION]:
		delete_level()
	
	Globals.state = sceneName
	
	if sceneName == Globals.COLLECT_SCREEN:
		await Globals.timer(0.75)
		$Animations.stop()
		$Animations.play("fade_collect_screen")
	else:
		$CollectScreen.hide()
		$CollectScreen.modulate.a = 0

func start_level(level_scene: PackedScene):
	$LevelOverlay/CollectablesDisplay.update_collectables()
	$LevelOverlay/LaserBar.visible = Globals.is_collected(Globals.CHEST_ITEMS.LASER)
	var level = level_scene.instantiate()
	get_node("../../WorldLayer/World").add_child(level)
	Globals.level = level
	print(level_scene, "  /  ", level)
	Globals.current_level = level.level_number
	Globals.enemies_killed = 0
	var enemies = 0
	for enemy in level.get_node("Enemies").get_children():
		if enemy is Enemy: enemies += 1
		elif enemy is Node2D:
			for e in enemy.get_children():
				if e is Enemy: enemies += 1
	Globals.enemies_in_level = enemies
	Globals.store_on_complete_data()
	change_scenes(Globals.PLAYING)
	if level.level_number == 1 and !Globals.level1_played and !Globals.skip_intro_text:
		intro_text()
	else:
		await Globals.timer(0.017)
		if level != null: level.zoom_out()

func next_level():
	delete_level()
	Globals.current_level += 1
	if Globals.levels.size() >= Globals.current_level:
		start_level(Globals.levels[Globals.current_level-1])
	else: 
		change_scenes(Globals.LEVEL_SELECTION)

func play_again():
	delete_level()
	start_level(Globals.levels[Globals.current_level-1])

func delete_level():
	if Globals.level != null:
		Globals.level.queue_free()
		Globals.level = null
		Globals.revert_stored_on_complete_data()

func hovering_over_overlay_buttons():
	return overlay_buttons.get_rect().has_point(get_local_mouse_position())
