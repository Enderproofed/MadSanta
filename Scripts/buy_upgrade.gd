@tool extends Button

@export var item_to_upgrade: Globals.CHEST_ITEMS
@export var upgrade_type: Globals.UPGRADE
@export var costs: Globals.COLLECT = Globals.COLLECT.SNOWFLAKE:
	set(value):
		costs = value
		$Icon/Coin.visible = value == Globals.COLLECT.COIN
		$Icon/Snowflake.visible = value == Globals.COLLECT.SNOWFLAKE
@export var cost: int = 1:
	set(value):
		cost = value
		$Cost.text = str(cost)
		if init_size != null:
			custom_minimum_size.x = init_size + $Cost.text.length() * 18
		if get_parent() != null and get_parent() is VBoxContainer:
			get_parent().position.x = -get_parent().size.x/2
@export var upgrade_name: String = "Stärke":
	set(value):
		upgrade_name = value
		text = "  " + upgrade_name + "                "

@onready var init_size = size.x

var upgrade_bought_preload = preload("res://Scenes/upgrage_bought.tscn")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Globals.add_listeners([Globals.LVL_RESET, Globals.LOAD, Globals.COLLECTED, Globals.UPGRADE_BOUGHT], Callable(self, "check_affordable"))
	$Icon/Snowflake/ParticlesSnowflake.queue_free()

func check_affordable():
	update_cost()
	if costs == Globals.COLLECT.COIN:
		disabled = cost > Globals.coins
	elif costs == Globals.COLLECT.SNOWFLAKE:
		disabled = cost > Globals.snowflakes
	
	if Globals.debug_mode: disabled = false

func update_cost():
	cost = Globals.upgrade_cost(item_to_upgrade, upgrade_type)

func _on_pressed() -> void:
	get_parent().get_parent().add_child(upgrade_bought_preload.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED))
	if costs == Globals.COLLECT.COIN:
		Globals.coins -= cost
	elif costs == Globals.COLLECT.SNOWFLAKE:
		Globals.snowflakes -= cost
	
	# for debug (mode) purposes
	Globals.coins = max(0, Globals.coins)
	Globals.snowflakes = max(0, Globals.snowflakes)
	
	Globals.buy_upgrade(item_to_upgrade, upgrade_type)
	update_cost()
