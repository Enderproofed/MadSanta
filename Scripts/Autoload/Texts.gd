extends Node

var texts_map = {}

func _ready() -> void:
	for text:String in TEXTS.keys():
		texts_map.get_or_add(TEXTS.keys().find(text), get(text))
	print(texts_map)

func get_text(type: TEXTS):
	return texts_map.values()[type]

enum TEXTS {
	INTRO,
	BIG_GNOME,
	GAP_ROLLING
}

const INTRO = [
		"Du bist ein Schneemann und deine Schneefrau wurde brutal von\n
		Schergen des wild gewordenen Weihnachtsmannes getötet.",
		"Deine Mission ist es den Weihnachtsmann und seine fiesen\n
		Machenschaften zu stoppen und dich an ihm zu rächen.",
		"Doch sei gewarnt. Er hat bereits seine Schergen auf dich\n
		angesetzt. Sei also auf der hut!"
	]

var BIG_GNOME = [
		"Das ist {name}...",
		"Er ist ein Zwerg der zu viele Fruchtzwerge gegessen hat\n
		und dadurch riesig geworden ist.",
		"Mit ihm ist wirklich nicht zu spaßen! \n
		Pass auf, dass er dich nicht in die Ecke drängt!"
	]

const GAP_ROLLING = [
		"Diese Schlucht wirst du auf normalem Weg nicht überwinden können.",
		"Wenn du nach unten drückst, kannst du dich zu einem großen Schneeball\n
		zusammen rollen und dadurch mehr Geschwindigkeit aufbauen.\n
		Somit kannst du mit einem Sprung größere Distanzen überwinden!"
]
