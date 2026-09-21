extends Node

enum MELODIES {
	NONE,
	TITLE,
	LEVEL
}

@onready var melody_map: Dictionary = {
	MELODIES.TITLE: $TitleMelody,
	MELODIES.LEVEL: $LevelMelody
}

func _ready() -> void:
	SignalBus.state_changed.connect(melody_change_by_state)

func melody_change_by_state(state) -> void:
	if State.is_menu() and !State.equals(State.SAVE_MENU):
		play_melody(MELODIES.TITLE)
	elif State.equals(State.FINISH_MENU):
		play_melody(MELODIES.LEVEL)
	else:
		play_melody(MELODIES.NONE)

func play_melody(melody_to_play: MELODIES):
	for melody in melody_map.keys():
		var melody_player: AudioStreamPlayer = melody_map[melody]
		if melody == melody_to_play:
			if !melody_player.playing: melody_player.play()
		elif melody_player.playing: melody_player.stop()
			
