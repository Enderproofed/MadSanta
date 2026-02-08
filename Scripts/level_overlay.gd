extends Control

@onready var ui: UI = get_parent()

@onready var init_pause_pos = $Buttons/Pause.position
@onready var init_pause_size = $Buttons/Pause.size

func _ready() -> void:
	$CollectablesDisplay/Coins.modulate.a = 0 if Globals.total_coins == 0 else 1
	$CollectablesDisplay/Snowflakes.modulate.a = 0 if Globals.total_snowflakes == 0 else 1
	Globals.add_listeners([Globals.LOAD, Globals.LVL_RESET, Globals.ITEM_COLLECTED], Callable(self, "upgrades_enabled_check"))
	upgrades_enabled_check()

func upgrades_enabled_check():
	$Buttons/Upgrades.disabled = Globals.collected_items.is_empty()
	$Buttons/Upgrades.self_modulate = Color(0.3, 0.3, 0.1) if $Buttons/Upgrades.disabled else Color.WHITE


func _on_pause_button_up() -> void:
	if Globals.state == Globals.PLAYING:
		$Buttons/Pause.text = "▸"
		$Buttons/Pause.add_theme_font_size_override("font_size", 80)
		$Buttons/Pause.position = Vector2(init_pause_pos.x - 4, init_pause_pos.y - 16)
		ui.change_scenes(Globals.PAUSED_IN_GAME)
		$Buttons/Settings.visible = false
		$Buttons/Upgrades.visible = false
	elif Globals.state == Globals.PAUSED_IN_GAME:
		$Buttons/Pause.text = "||"
		$Buttons/Pause.add_theme_font_size_override("font_size", 30)
		$Buttons/Pause.position = init_pause_pos
		$Buttons/Pause.size = init_pause_size
		ui.change_scenes(Globals.PLAYING)
		get_tree().paused = false
		$Buttons/Settings.visible = true
		$Buttons/Upgrades.visible = true
	#if config_active:
		#ui.change_scenes(Globals.PAUSED)

func _on_upgrades_button_up() -> void:
	ui.change_scenes(Globals.UPGRADES)

func _on_settings_button_up() -> void:
	ui.change_scenes(Globals.SETTINGS_PLAYING)
