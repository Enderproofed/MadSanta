extends Control

var item_type: Globals.CHEST_ITEMS

func set_item_type(item_type: Globals.CHEST_ITEMS):
	self.item_type = item_type
	$Pivot/Snowball.visible = item_type == Globals.CHEST_ITEMS.SNOWBALL
	$Pivot/Icicle.visible = item_type == Globals.CHEST_ITEMS.ICICLE
	if item_type == Globals.CHEST_ITEMS.SNOWBALL:
		$CollectLabel.text = "Du hast den Schneeball freigeschaltet!"
	if item_type == Globals.CHEST_ITEMS.ICICLE:
		$CollectLabel.text = "Du hast den Eiszapfen freigeschaltet!"


func _on_claim_pressed() -> void:
	Globals.change_scenes(Globals.PLAYING)
	Globals.collect_item(item_type)
