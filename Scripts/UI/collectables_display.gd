extends Control

@export var always_visible = false
@export var disable_fake_collect = true

# Maps Node-name -> Globals variable name
const collectables_map: Dictionary = {
	"Coins": "coins",
	"Snowflakes": "snowflakes",
	"IceShards": "ice_shards",
	"FireShards": "fire_shards"
}

const FIRST_POS = 65
const DISTANCE = 60
const TEXT_MODIFIER = 16

func _ready() -> void:
	$Snowflakes/Snowflake/ParticlesSnowflake.queue_free()
	$IceShards/IceShard/Collision/Particles.queue_free()
	$FireShards/FireShard/Collision/Particles.queue_free()
	$IceShards/IceShard/HoverAnimation.play("RESET")
	$FireShards/FireShard/HoverAnimation.play("RESET")
	if disable_fake_collect:
		#TODO boilerplate -> mapping
		$Coins/Coin/CollectEasteregg.queue_free()
		$Snowflakes/Snowflake/CollectEasteregg.queue_free()
		$IceShards/IceShard/CollectEasteregg.queue_free()
		$FireShards/FireShard/CollectEasteregg.queue_free()
	SignalBus.collected.connect(_update_collectables)
	#SignalBus.load.connect(update_collectables)
	#SignalBus.level_reset.connect(update_collectables)
	SignalBus.upgrade_bought.connect(_upgrade_bought)
	update_collectables()

func _update_collectables(collected_type: E.COLLECT):
	#if collected_type in [E.COLLECT.COIN, E.COLLECT.SNOWFLAKE]:
		update_collectables()

func _upgrade_bought(item: E.CHEST_ITEMS, upgrade: Upgrades.Type):
	update_collectables()

func update_collectables():
	var i = 0
	var text_mod = 0
	var all_hidden = true
	if get_parent() != null and get_parent().name == "LevelOverlay":
		print("hook")
	for node_name in collectables_map.keys():
		var node: Label = get_node(node_name)
		var variable_name = collectables_map[node_name]
		var variable_value = Globals.get(variable_name)
		var variable_changed = node.text != str(variable_value)
		node.text = str(variable_value)
		var hide = false
		if Globals.get("total_" + variable_name) > 0:
			if variable_changed: node.get_node("Animation").play("pop in" if node.modulate.a == 0 else "collect")
		elif !always_visible: hide = true
		node.position.x = FIRST_POS + text_mod + DISTANCE * i
		if !hide: 
			text_mod += node.text.length() * TEXT_MODIFIER
			i += 1
			all_hidden = false
		else: node.modulate.a = 0
	
	$Background.visible = !all_hidden
	$Background.size.x = FIRST_POS + text_mod + DISTANCE * i - 12
