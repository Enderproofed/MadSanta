extends PivotElementSwitcher

@onready var ui: UI = get_parent()

func _ready() -> void:
	pivot_element = $Pivot/Pivot
	INITIAL_POSITION = Vector2($Pivot/Pivot.position)
	get_ready()
	for type_to_upgrade in $Pivot/Pivot.get_children():
		var upgrades = type_to_upgrade.get_node("Upgrades")
		upgrades.position.x = -upgrades.size.x/2
		upgrades.visible = true
	
	Globals.add_listener(Globals.UPGRADE_BOUGHT, Callable(self, "upgrade_bought"))

func upgrade_bought(item: Globals.CHEST_ITEMS, upgrade: Globals.UPGRADE):
	if item == Globals.CHEST_ITEMS.LASER and upgrade == Globals.UPGRADE.SPREAD:
		var width_curve: Curve = $Pivot/Pivot/Laser/LaserBeam.width_curve
		width_curve.set_point_value(1, 1.0 + Globals.upgrades[item][Globals.get_upgrade_name(upgrade)]/3.0)

func _on_back_button_down() -> void:
	$Back/Animation.play("pressed")
func _on_back_button_up() -> void:
	$Back/Animation.play_backwards("pressed")
	change_index(-1)

func _on_forth_button_down() -> void:
	$Forth/Animation.play("pressed")
func _on_forth_button_up() -> void:
	$Forth/Animation.play_backwards("pressed")
	change_index(1)


func _on_return_button_up() -> void:
	ui.back()
