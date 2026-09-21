@tool extends Button

@export var item_to_upgrade: E.CHEST_ITEMS
@export var upgrade_type: Upgrades.Type
@export var costs: Dictionary = {
	E.COLLECT.SNOWFLAKE: 1
}:
	set(value):
		costs = value
		adjust_sizes()

@export var upgrade_name: String = "Stärke":
	set(value):
		upgrade_name = value
		text = "  " + upgrade_name# + "                "
		adjust_sizes()

@export var update_cost_positions = false: set = cost_positions

const node_name_map: Dictionary = {
	E.COLLECT.COIN: "Coin",
	E.COLLECT.SNOWFLAKE: "Snowflake",
	E.COLLECT.ICE_SHARD: "IceShard",
	E.COLLECT.FIRE_SHARD: "FireShard"
}

var upgrade_bought_load = load("uid://dc7oweron7wy3")

@onready var effect_current_node = $EffectiveValue/Current
@onready var effect_upgraded_node = $EffectiveValue/UpgradedValue
@onready var effect_arrow_node = $EffectiveValue/Arrow
@onready var effect_suffix = Upgrades.upgrade_effect_suffix(item_to_upgrade, upgrade_type)
@onready var variable_name = Upgrades.upgrades_variable_map[item_to_upgrade][upgrade_type]

var maxed = false

var initialized = false
func _ready() -> void:
	if Engine.is_editor_hint(): return
	SignalBus.upgrade_bought.connect(upgrade_bought)
	SignalBus.upgrades_reset.connect(allround_update)
	SignalBus.debug_mode_changed.connect(_debug_mode_changed)
	$Alignment/Snowflake/Pivot/Snowflake/ParticlesSnowflake.queue_free()
	for node_name in node_name_map.values():
		get_node(str("Alignment/", node_name, "/Pivot/", node_name, "/CollectEasteregg")).queue_free()
	initialized = true
	allround_update()

func _debug_mode_changed(active: bool):
	allround_update()

func upgrade_bought(item: E.CHEST_ITEMS, upgrade: Upgrades.Type):
	if item == item_to_upgrade and upgrade == upgrade_type:
		update_cost()
		update_upgrade_effect()
	check_affordable()

func allround_update():
	update_cost()
	update_upgrade_effect()
	check_affordable()

func node(collect: E.COLLECT):
	return $Alignment.get_node(node_name_map[collect])

func adjust_sizes():
	if !initialized: return
	var all_sizes = 0
	for collect in E.COLLECT.values():
		node(collect).visible = costs.keys().has(collect)
	if E.COLLECT.FIRE_SHARD in costs:
		print("Ehh")
	
	if maxed:
		custom_minimum_size.x = text.length() * 18 + 69
	else:
		for collect in costs.keys():
			var node: Control = node(collect)
			var cost: Label = node.get_node("Cost")
			cost.text = ""
			cost.size.x = 0
			cost.text = str(costs[collect])
			cost.size.x += 5
			node.custom_minimum_size.x = cost.size.x + 43
			all_sizes += node.custom_minimum_size.x
		custom_minimum_size.x = text.length() * 18 + all_sizes - 60 + costs.size()*8
	
	if get_parent() != null and get_parent() is VBoxContainer:
		var max_size = 0
		for child in get_parent().get_children():
			max_size = max(max_size, child.custom_minimum_size.x)
		get_parent().size.x = max_size
		get_parent().position.x = -max_size/2
	
	if get_tree() != null:
		await get_tree().create_timer(0.05)
		cost_positions()

func cost_positions(fake_set = null):
	for collect in costs.keys():
		node(collect).get_node("Cost").position.x = 0#-cost.size.x + 12
		if collect == E.COLLECT.FIRE_SHARD:
			print(node(collect).name, " / ", node(collect).get_node("Cost").position.x)

func check_affordable():
	disabled = maxed
	if !disabled:
		for collect in costs.keys():
			if costs.get(collect) > Globals.get(E.collectable_name_map[collect]):
				disabled = true
				break
	
	focus_mode = FOCUS_NONE if disabled else FOCUS_CLICK
	
	if !maxed and Globals.debug_mode: disabled = false

func update_cost():
	maxed = Upgrades.fetch_upgrade_amount(item_to_upgrade, upgrade_type) >= Upgrades.get_max_amount(item_to_upgrade, upgrade_type)
	$MaxedIcon.visible = maxed
	$Alignment.visible = !maxed
	if maxed: adjust_sizes()
	else: costs = Upgrades.upgrade_cost(item_to_upgrade, upgrade_type)

func update_upgrade_effect():
	var upgrade_effect_texts = Upgrades.upgrade_effect_text(item_to_upgrade, upgrade_type, true, effect_suffix, variable_name)
	effect_current_node.text = upgrade_effect_texts[0]
	effect_upgraded_node.text = upgrade_effect_texts[1] + (" (MAX)" if maxed else "")
	effect_current_node.visible = !maxed
	effect_arrow_node.visible = !maxed

func _on_pressed() -> void:
	get_parent().get_parent().add_child(upgrade_bought_load.instantiate())
	
	for collect in costs.keys():
		var variable_name = E.collectable_name_map[collect]
		Globals.set(variable_name, Globals.get(variable_name) - costs.get(collect))

	# for debug (mode) purposes
	for variable_name in E.collectable_name_map.values():
		var value = Globals.get(variable_name)
		Globals.set(variable_name, max(0, value))
	
	Globals.buy_upgrade(item_to_upgrade, upgrade_type)
