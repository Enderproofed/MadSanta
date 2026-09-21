extends Control

var name_component_load = load("uid://vjotralgj7h8")
var size_component_load = load("uid://ii2cuojgeqdb")

const NAME_COMPONENT = "NAME_COMPONENT"
const SIZE_COMPONENT = "SIZE_COMPONENT"
var components: Dictionary = {}

var placeholder: LevelEditorPlaceholder
var init_placeholder_data

func set_placeholder(placeholder: LevelEditorPlaceholder):
	self.placeholder = placeholder
	init_placeholder_data = placeholder.get_data()
	$Label.text = tr("EDIT_ELEMENT").replace("{0}", str(tr(placeholder.place_type), " ", placeholder.get_id()))
	add_component(placeholder.place_type in E.PLACE_SELECTION_ENEMIES, name_component_load, NAME_COMPONENT)
	add_component(placeholder.place_type == E.PLACE_GNOME, size_component_load, SIZE_COMPONENT)

func add_component(condition: bool, component_load: PackedScene, key: String):
	if condition:
		var component = component_load.instantiate()
		component.set_placeholder(placeholder)
		$ScrollPanel/Container/Spacing.add_child(component)
		components[key] = component

func _on_close() -> void:
	State.set_state(State.LEVEL_EDITOR)
	if placeholder.is_different_to(init_placeholder_data):
		LevelEditor.current.add_cached_action(CachedAction.create_edit_placeholder(init_placeholder_data, placeholder))
	queue_free()
