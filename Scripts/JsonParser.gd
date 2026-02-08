class_name JsonParser extends Object

const INDENTION = "  "

static func dictionary_to_json(dictionary: Dictionary, beautify = false) -> String:
	var parsed_json: String = JSON.stringify(dictionary)
	if beautify:
		return parsed_json
	var beautiful_json: String = ""
	var current_indention = 0
	var open_array = false
	for i in range(parsed_json.length()):
		var character = parsed_json[i]
		if character == "[": open_array = true
		if character == "]": open_array = false
		if character == "}":
			current_indention -= 1
			beautiful_json += "\n" + indention(current_indention)
		beautiful_json += character
		if not open_array: beautiful_json += indention(current_indention)
		if character == "{":
			current_indention += 1
			beautiful_json += "\n" + indention(current_indention)
	return beautiful_json

static func indention(amount: int) -> String:
	if amount <= 0: return ""
	var result = ""
	for i in range(amount):
		result += INDENTION
	return result
