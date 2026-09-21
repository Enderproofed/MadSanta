class_name LevelOverlay extends Overlay

static var current: LevelOverlay

@onready var ui: UI = get_parent()

@onready var init_pause_pos = $Buttons/Pause.position
@onready var init_pause_size = $Buttons/Pause.size

@onready var boss_bar_load = load("uid://b68qdjc2fhu0i")

func _ready() -> void:
	current = self
	$LaserBar.pushed_elements.append($Wings)
	$CollectablesDisplay.update_collectables()
	$CollectablesDisplay/Coins.modulate.a = 0 if Globals.total_coins == 0 else 1
	$CollectablesDisplay/Snowflakes.modulate.a = 0 if Globals.total_snowflakes == 0 else 1
	SignalBus.item_collected.connect(_item_collected)
	upgrades_enabled_check()
	$Wings/Wings/Halo.modulate = Color.WHITE
	$Wings.visible = Globals.has_wings()
	
	super._ready()

func remove() -> void:
	if current == self: current = null
	super.remove()

func _item_collected(item: E.CHEST_ITEMS):
	upgrades_enabled_check()
func upgrades_enabled_check():
	var no_items_collected = Globals.collected_items.is_empty()
	$Buttons/Upgrades.disabled = no_items_collected
	if !no_items_collected: mouse_default_cursor_shape = CursorShape.CURSOR_CROSS
	$Buttons/Upgrades.self_modulate = Color(0.3, 0.3, 0.1) if $Buttons/Upgrades.disabled else Color.WHITE
	$LaserBar.visible = Globals.is_collected(E.CHEST_ITEMS.LASER)

func add_bossbar(enemy_name: String, health: float, max_health: float, boss_bar_count: int) -> BossBar:
	var boss_bar: BossBar = boss_bar_load.instantiate()
	boss_bar.set_boss_name(enemy_name)
	boss_bar.set_health(health, max_health)
	boss_bar.set_bar_count(boss_bar_count)
	$BossBarContainer/Spacing.add_child(boss_bar)
	return boss_bar


func _on_pause_button_up() -> void:
	if State.equals(State.PLAYING):
		$Buttons/Pause.text = "▸"
		$Buttons/Pause.add_theme_font_size_override("font_size", 80)
		$Buttons/Pause.position = Vector2(init_pause_pos.x - 4, init_pause_pos.y - 16)
		ui.change_scenes(State.PAUSED_IN_GAME)
		$Buttons/Settings.visible = false
		$Buttons/Upgrades.visible = false
	elif State.equals(State.PAUSED_IN_GAME):
		$Buttons/Pause.text = "||"
		$Buttons/Pause.add_theme_font_size_override("font_size", 30)
		$Buttons/Pause.position = init_pause_pos
		$Buttons/Pause.size = init_pause_size
		ui.back()
		Globals.set_paused(false)
		$Buttons/Settings.visible = true
		$Buttons/Upgrades.visible = true

func _on_upgrades_button_up() -> void:
	ui.change_scenes(State.UPGRADES)

func _on_settings_button_up() -> void:
	ui.change_scenes(State.SETTINGS)
