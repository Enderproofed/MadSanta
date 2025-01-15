extends CanvasLayer

var text_visible = false
var text_pointer = 0
var texts_to_show = []
var text_switch_blocked = false

func start_text_sequence(texts):
	Globals.state = Globals.PAUSED
	text_switch_blocked = false
	texts_to_show = texts
	text_switch_blocked = true
	change_text(texts[0])
	text_switch_blocked = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Text"):
		if $Text/Label.visible_ratio < 1.0:
			$Text/Label.visible_ratio = 1
		else: next_text()

func next_text():
	if !text_switch_blocked and !texts_to_show.is_empty():
		text_switch_blocked = true
		if text_pointer == texts_to_show.size()-1:
			$Text/Animation.play_backwards("show_text")
			await Globals.timer(0.85)
			Globals.state = Globals.PLAYING
			texts_to_show = []
			text_visible = false
			$"../Level1".zoom_out()
		else:
			text_pointer += 1
			change_text(texts_to_show[text_pointer])
		text_switch_blocked = false

func change_text(text: String):
	if !text_visible:
		text_visible = true
		$Text/Label.text = text
		$Text/Animation.play("show_text")
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.85)
	else:
		$Text/Animation.play("change_text")
		await Globals.timer(0.5)
		$Text/Label.text = text
		$Text/Label.visible_ratio = 0
		await Globals.timer(0.5)

	

func _process(delta: float) -> void:
	$Text/Label.visible_ratio += delta/3
