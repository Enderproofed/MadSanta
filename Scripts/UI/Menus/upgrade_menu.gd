extends PivotElementSwitcher

@onready var ui: UI = get_parent()

var upgrade_bought_load = load("uid://dc7oweron7wy3")

func _ready() -> void:
	pivot_element = $Pivot/Pivot
	is_items = true
	INITIAL_POSITION = Vector2($Pivot/Pivot.position)
	get_ready()
	for type_to_upgrade in $Pivot/Pivot.get_children():
		var upgrades = type_to_upgrade.get_node("Upgrades")
		upgrades.position.x = -upgrades.size.x/2
		upgrades.visible = true
		var title_node = type_to_upgrade.get_node("Title")
		title_node.text = get_title(type_to_upgrade)
		title_node.show()
	
	SignalBus.upgrade_bought.connect(upgrade_bought)
	check_upgrades()

func get_title(type_to_upgrade: Node):
	if type_to_upgrade.get_index() <= 3:
		return Globals.get_item_type_name(Globals.id_to_item(type_to_upgrade.get_index()))
	else:
		return ""

func check_upgrades():
	for item in Globals.collected_items:
		for upgrade in Globals.upgrades[item]:
			upgrade_bought(item, Upgrades.upgrade_name_map.find_key(upgrade))

func upgrade_bought(item: E.CHEST_ITEMS, upgrade: Upgrades.Type):
	if item == E.CHEST_ITEMS.LASER and upgrade == Upgrades.Type.SPREAD:
		var width_curve: Curve = $Pivot/Pivot/Laser/Deco/LaserBeam.width_curve
		width_curve.set_point_value(1, 1.0 + Globals.upgrades[item][Upgrades.get_upgrade_name(upgrade)]/3.0)

func _on_back_button_up() -> void:
	change_index(-1)

func _on_forth_button_up() -> void:
	change_index(1)

func reset_upgrages() -> void:
	if Globals.reset_upgrades():
		var downgrade = upgrade_bought_load.instantiate()
		downgrade.amount = 20
		downgrade.position.y -= 150
		$Pivot.add_child(downgrade)
		await get_tree().physics_frame
		downgrade.get_node("Animation").play("Downgrade")
	check_upgrades()
