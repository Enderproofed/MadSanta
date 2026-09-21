extends Control

var item_type: E.CHEST_ITEMS

func _ready() -> void:
	set_item_type(Globals.just_collected_item)

func set_item_type(item_type: E.CHEST_ITEMS):
	self.item_type = item_type
	$Pivot/Pivot/Snowball.visible = item_type == E.CHEST_ITEMS.SNOWBALL
	$Pivot/Pivot/Icicle.visible = item_type == E.CHEST_ITEMS.ICICLE
	$Pivot/Pivot/Laser.visible = item_type == E.CHEST_ITEMS.LASER
	$Pivot/Pivot/Wings.visible = item_type == E.CHEST_ITEMS.WINGS
	
	var item_name = Globals.get_item_type_name(item_type)
	var artikel = "die" if item_type == E.CHEST_ITEMS.WINGS else "den"
	$CollectLabel.text = "Du hast {0} {1} freigeschaltet!".format([artikel, item_name])
	$Description.text = get_description(item_type).format([item_name])
	$Upgrades.visible = item_type == E.CHEST_ITEMS.SNOWBALL

func _on_claim_pressed() -> void:
	Globals.collect_item(item_type)
	Globals.change_scenes(State.PLAYING)

const descriptions: Dictionary = {
	E.CHEST_ITEMS.SNOWBALL: 
		"Der {0} wird deine erste Waffe gegen die Weihnachtsdystopie sein.\n
		Dieser und folgende Waffen können im Upgrade-Menü         verbessert werden.\n
		Benutze SHIFT + Mausrad, um die Wurfweite einzustellen.",
	E.CHEST_ITEMS.ICICLE:
		"Der {0} trotzt jeglicher Physik und fliegt kerzengerade.\n
		Wenn er trifft, bleibt er sowohl in Gegnern, als auch in Wänden stecken.\n
		idk, mach was draus lol",
	E.CHEST_ITEMS.LASER: 
		"Der {0} hat eine imense Angriffs-Power, braucht allerdings nach Nutzung\n
		seine Zeit bis er sich aufgeladen hat und wieder Einsatzfähig ist.\n
		Um ihn zu verwenden, halte SHIFT gedrückt",
	E.CHEST_ITEMS.WINGS: 
		"Die {0} geben dir die Möglichkeit für 5 Sekunden zu fliegen! (Upgrades möglich)\n
		Drücke dazu 2x hintereinander die Sprung-Taste.\n
		Nach einem Flug benötigen die {0} eine Pause von 30 Sekunden."
}
func get_description(item_type: E.CHEST_ITEMS) -> String:
	return descriptions.get(item_type)
