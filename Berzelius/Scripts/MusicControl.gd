extends Node

var Settings = load("res://Scripts/Settings.gd").new()

func _ready():
	set_music()

func set_music():
	var music = Settings.get_settings().music
	$Music.autoplay = music
	$Music.stream_paused = not music
	if music and $Music.get_playback_position() == 0:
		$Music.play()

func button_sound():
	if Settings.get_settings().sound:
		$Button.play()

func checkbutton_sound():
	if Settings.get_settings().sound:
		$Checkbutton.play()

func victory_sound():
	if Settings.get_settings().sound:
		$Victory.play()
