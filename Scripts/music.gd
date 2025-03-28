extends Node

func _process(delta: float) -> void:
	if Globals.isInMenu():
		if !$TitleMelody.playing:
			$TitleMelody.play()
			$LevelMelody.stop()
	elif Globals.state != Globals.FINISH_MENU:
		if !$LevelMelody.playing:
			$LevelMelody.play()
			$TitleMelody.stop()
	else:
		$TitleMelody.stop()
		$LevelMelody.stop()
