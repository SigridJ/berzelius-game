extends PopupPanel

var Settings = load("res://Scripts/Settings.gd").new()
var originalPos: Vector2

signal musicChanged

func _ready():
	originalPos = self.rect_position
	set_settings()

func set_settings():
	var settings = Settings.get_settings()
	$VBoxContainer/MarginContainer/SettingsList/Animation/CheckButton.set_pressed_no_signal(settings.animation)
	$VBoxContainer/MarginContainer/SettingsList/Sound/CheckButton.set_pressed_no_signal(settings.sound)
	$VBoxContainer/MarginContainer/SettingsList/Music/CheckButton.set_pressed_no_signal(settings.music)
	print("Animation: %s, Sound: %s, Music: %s" % [Settings.get_settings().animation, Settings.get_settings().sound, Settings.get_settings().music])

func _on_Settings_about_to_show():
	var tween = get_node("Tween")
	tween.interpolate_property(self, "rect_position", originalPos - Vector2(0, self.rect_size.y), originalPos, 0.4, 2, 1)
	tween.start()

func _on_Settings_popup_hide():
	self.show()
	var tween = get_node("Tween")
	tween.interpolate_property(self, "rect_position", null, originalPos - Vector2(0, self.rect_size.y), 0.4, 2, 1)
	tween.start()

func _on_GoBack_button_up():
	self.hide()

func _on_animation_toggled(animation):
	Settings.set_animation_setting(animation)
	print("Animation: %s, Sound: %s, Music: %s" % [Settings.get_settings().animation, Settings.get_settings().sound, Settings.get_settings().music])

func _on_sound_toggled(sound):
	Settings.set_sound_setting(sound)
	print("Animation: %s, Sound: %s, Music: %s" % [Settings.get_settings().animation, Settings.get_settings().sound, Settings.get_settings().music])

func _on_music_toggled(music):
	Settings.set_music_setting(music)
	emit_signal("musicChanged")
	print("Animation: %s, Sound: %s, Music: %s" % [Settings.get_settings().animation, Settings.get_settings().sound, Settings.get_settings().music])
