extends Node

signal language_changed(locale: String)

const GROUP := "Translated"
const GROUP_CONTAINER := "TranslatedContainer"

const META_KEY := "tr_key"
const META_PLACEHOLDER_KEY := "tr_placeholder_key"
const META_PARAMS := "tr_params"

func set_language(locale: String) -> void:
	if TranslationServer.get_locale() == locale:
		return

	TranslationServer.set_locale(locale)
	retranslate_all()
	language_changed.emit(locale)
	
	Globals.locale = locale
	Save.save_value("locale")


func retranslate_all() -> void:
	for container in get_tree().get_nodes_in_group(GROUP_CONTAINER):
		for node in container.get_children():
			node.add_to_group(GROUP)
	
	for node in get_tree().get_nodes_in_group(GROUP):
		retranslate_node(node)
	


func retranslate_node(node: Node) -> void:
	if !is_instance_valid(node) or !node.has_meta(META_KEY) or !has_property(node, "text"):
		return

	var translated_text := tr(node.get_meta(META_KEY))

	if node.has_meta(META_PARAMS):
		translated_text = translated_text % node.get_meta(META_PARAMS)

	node.text = translated_text.replace("%n", "\n")


func translate_node(
	node: Node,
	key: String = node.get_meta(META_KEY),
	params: Array = []
) -> void:
	node.set_meta(META_KEY, key)

	if params.is_empty():
		node.remove_meta(META_PARAMS)
	else:
		node.set_meta(META_PARAMS, params)

	if !node.is_in_group(GROUP):
		node.add_to_group(GROUP)

	retranslate_node(node)

func has_property(object: Object, property: StringName) -> bool:
	for p in object.get_property_list():
		if p.name == property:
			return true
	return false

#func _ready() -> void:
	#sign_labels()

# sign all the labels before a translation happens,
# as otherwise after a translation to another language
# it will not be translatable anymore 
#func sign_labels(root_node: Node = get_tree().root):
	#for node: Label in root_node.find_children("*", "Label", true, false):
		#if node.get_meta("signed", false) and translations[LOCALES.DE][node.text] != null:
			#node.set_meta("original_text", node.text)
			#node.set_meta("signed", true)
	#for node: Button in root_node.find_children("*", "Button", true, false):
		#if node.get_meta("signed", false) and translations[LOCALES.DE][node.text] != null:
			#node.set_meta("original_text", node.text)
			#node.set_meta("signed", true)

#func translate_labels(root_node: Node = get_tree().root):
	#for node: Label in root_node.find_children("*", "Label", true, false):
		#var contains_translation = translations[active_locale].find_key(node.text)
		#if contains_translation:
			#node.text = translations[active_locale][node.text]
	#for node: Button in root_node.find_children("*", "Button", true, false):
		#var contains_translation = translations[active_locale].find_key(node.text)
		#if contains_translation:
			#node.text = translations[active_locale][node.text]

#func sign_and_translate_labels(root_node: Node = get_tree().root):
	#sign_labels(root_node)
	#translate_labels(root_node)
