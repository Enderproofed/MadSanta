@tool extends TileMapLayer

@export var bake_tilemap = false: set = bake_that_thing

func bake_that_thing(value = null):
	for child in get_children():
		child.queue_free()
	var baked_tilemap = StaticBody2D.new()
	baked_tilemap.set_script(load("res://Scripts/Level/tilemap_collision_baker.gd"))
	add_child(baked_tilemap, true)
	if get_tree() != null: baked_tilemap.owner = get_tree().edited_scene_root
	baked_tilemap.position.y = -position.y
	baked_tilemap.bake_tilemaplayer(self)
