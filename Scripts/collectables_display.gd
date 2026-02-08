extends Control

@export var always_visible = false
@export var disable_fake_collect = true

func _ready() -> void:
	$Snowflakes/Snowflake/ParticlesSnowflake.queue_free()
	if disable_fake_collect:
		$Coins/Coin/CollectEasteregg.queue_free()
		$Snowflakes/Snowflake/CollectEasteregg.queue_free()
	Globals.add_listener(Globals.COLLECTED, Callable(self, "_update_collectables"))
	Globals.add_listeners([Globals.LOAD, Globals.LVL_RESET, Globals.UPGRADE_BOUGHT], Callable(self, "update_collectables"))
	update_collectables()

func _update_collectables(collected_type: Globals.COLLECT):
	if collected_type in [Globals.COLLECT.COIN, Globals.COLLECT.SNOWFLAKE]:
		update_collectables()

func update_collectables():
	var coins_changed = $Coins.text != str(Globals.coins)
	var snowflakes_changed = $Snowflakes.text != str(Globals.snowflakes)
	$Coins.text = str(Globals.coins)
	$Snowflakes.text = str(Globals.snowflakes)
	$Snowflakes.position.x = 184 + $Coins.text.length() * 16
	if Globals.total_coins > 0: 
		if coins_changed: $Coins/Animation.play("pop in" if $Coins.modulate.a == 0 else "collect")
	elif !always_visible: $Coins.modulate.a = 0
	if Globals.total_snowflakes > 0: 
		if snowflakes_changed: $Snowflakes/Animation.play("pop in" if $Snowflakes.modulate.a == 0 else "collect")
	elif !always_visible: $Snowflakes.modulate.a = 0
