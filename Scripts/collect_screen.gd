extends Control

var item_type: Globals.CHEST_ITEMS

func set_item_type(item_type: Globals.CHEST_ITEMS):
	self.item_type = item_type
	$Pivot/Pivot/Snowball.visible = item_type == Globals.CHEST_ITEMS.SNOWBALL
	$Pivot/Pivot/Icicle.visible = item_type == Globals.CHEST_ITEMS.ICICLE
	$Pivot/Pivot/Laser.visible = item_type == Globals.CHEST_ITEMS.LASER
	
	$CollectLabel.text = "Du hast den {0} freigeschaltet!".format([Globals.get_item_type_name(item_type)])


func _on_claim_pressed() -> void:
	Globals.change_scenes(Globals.PLAYING)
	Globals.collect_item(item_type)
	Globals.ui.get_node("Animations").stop()
