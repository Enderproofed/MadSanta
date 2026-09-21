class_name CachedAction extends Object

const ELEMENTS = "ELEMENTS"
const IDENTIFIER = "IDENTIFIER" # ID and TYPE build the IDENTIFIER together (no shit sherlock...)
const ID = "ID"
const TYPE = "TYPE"
const MOVE_VECTOR = "MOVE_VECTOR"
const DATA = "DATA"
const DATA_BEFORE = "DATA_BEFORE"
const DATA_AFTER = "DATA_AFTER"

var data: Dictionary
var action: LevelEditor.ACTION

func undo():
	var level_editor: LevelEditor = fetch_editor()
	match action:
		LevelEditor.ACTION.MOVE:
			if data.has(MOVE_VECTOR): level_editor.move_content_cached(-data[MOVE_VECTOR], data[ELEMENTS])
			else: level_editor.move_content_individual_cached(data[ELEMENTS])  # might just throw away that part, when mostly the more complex single one gets executed ...
		LevelEditor.ACTION.PLACE:
			level_editor.erase_by_id(data[ID][TYPE], data[ID][ID])
		LevelEditor.ACTION.ERASE:
			if data.has(ELEMENTS):
				for element: Dictionary in data[ELEMENTS]:
					level_editor.place_placeholder_cached(element[DATA], element[ID][TYPE])
			else: level_editor.place_placeholder_cached(data[DATA], data[ID][TYPE])
		LevelEditor.ACTION.EDIT_PLACEHOLDER:
			level_editor.set_placeholder_data(data[ID][TYPE], data[ID][ID], data[DATA_BEFORE])

func redo(): # GIG! Gekokst ist geil!
	var level_editor: LevelEditor = fetch_editor()
	match action:
		LevelEditor.ACTION.MOVE:
			if data.has(MOVE_VECTOR): level_editor.move_content_cached(data[MOVE_VECTOR], data[ELEMENTS])
			else: level_editor.move_content_individual_cached(data[ELEMENTS], false)
		LevelEditor.ACTION.PLACE:
			level_editor.place_placeholder_cached(data[DATA], data[ID][TYPE])
		LevelEditor.ACTION.ERASE:
			if data.has(ELEMENTS):
				for element: Dictionary in data[ELEMENTS]:
					level_editor.erase_by_id(element[ID][TYPE], element[ID][ID])
			else: level_editor.erase_by_id(data[ID][TYPE], data[ID][ID])
		LevelEditor.ACTION.EDIT_PLACEHOLDER:
			level_editor.set_placeholder_data(data[ID][TYPE], data[ID][ID], data[DATA])

static func fetch_editor() -> LevelEditor:
	return LevelEditor.current

### Constructors ###

static func create_move(elements: Array[LevelEditorPlaceholder], move_vector: Vector2) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.MOVE
	var elements_id_array: Array[Dictionary] = []
	for element in elements:
		elements_id_array.append(get_identifier(element))
	new_action.data = {
		ELEMENTS: elements_id_array,
		MOVE_VECTOR: move_vector
	}
	return new_action

static func create_move_individual(elements: Array[LevelEditorPlaceholder]) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.MOVE
	var data_array = []
	for i in range(elements.size()):
		var element: LevelEditorPlaceholder = elements[i]
		var data = get_identifier(element)
		data[MOVE_VECTOR] = element.position - element.get_meta("MOVE_START")
		data_array.append(data)
	new_action.data = {ELEMENTS: data_array}
	return new_action

static func create_place(element: LevelEditorPlaceholder) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.PLACE
	new_action.data = get_identifier_with_data(element)
	return new_action

static func create_delete(element: LevelEditorPlaceholder) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.ERASE
	new_action.data = get_identifier_with_data(element)
	return new_action

static func create_delete_multi(elements: Array[LevelEditorPlaceholder]) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.ERASE
	var data_array = []
	for element in elements:
		data_array.append(get_identifier_with_data(element))
	new_action.data = {ELEMENTS: data_array}
	return new_action

static func create_edit_placeholder(data_before: Dictionary, element: LevelEditorPlaceholder) -> CachedAction:
	var new_action = new()
	new_action.action = LevelEditor.ACTION.EDIT_PLACEHOLDER
	var data = get_identifier_with_data(element)
	data[DATA_BEFORE] = data_before
	new_action.data = data
	return new_action

### Helpers ###

static func get_identifier(element: LevelEditorPlaceholder) -> Dictionary:
	return {ID: element.get_id(), TYPE: element.place_type}
static func get_identifier_with_data(element: LevelEditorPlaceholder) -> Dictionary:
	return {ID: get_identifier(element), DATA: element.get_data()}
