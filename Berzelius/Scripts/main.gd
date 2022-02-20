extends Node

var Glass = preload("res://Scenes/Glass.tscn")
var level = 1

func _ready():
	randomize()
#	seed(2)
	level = $GameLayer/GlassList.get_level()
	set_level_label()

func new_level():
	level += 1
	set_level_label()
	$GameLayer/GlassList.generate_level(level)

func set_level_label():
	$UILayer/PanelContainer/MarginContainer/Level.text = "Level %d" % level

func _on_GlassList_victory():
	$PopupLayer/VictoryPopup/MarginContainer/VBoxContainer/Label.text = "Level %d" % level
	$PopupLayer/VictoryPopup.popup()

func _on_NewGame_pressed():
	$PopupLayer/VictoryPopup.hide()
	new_level()

func _on_InfoButton_pressed():
	$PopupLayer/InfoPopup.popup()

func _on_SettingsButton_pressed():
	$PopupLayer/SettingsPopup.popup()

func darken(time = 0.4, transition = 2, easeType = 1):
	$UILayer/Lock.show()
	var tween = get_node("Tween")
	tween.interpolate_property($UILayer/DarkenLayer, "color", Color(1,1,1,1), Color(0.8,0.8,0.8,1), time, transition, easeType)
	tween.start()
	tween.interpolate_property($GameLayer/DarkenLayer, "color", Color(1,1,1,1), Color(0.8,0.8,0.8,1), time, transition, easeType)
	tween.start()

func lighten(time = 0.5, transition = 0, easeType = 1):
	$UILayer/Lock.hide()
	var tween = get_node("Tween")
	tween.interpolate_property($UILayer/DarkenLayer, "color", null, Color(1,1,1,1), time, transition, easeType)
	tween.start()
	tween.interpolate_property($GameLayer/DarkenLayer, "color", null, Color(1,1,1,1), time, transition, easeType)
	tween.start()

func _on_GlassList_lock_me():
	$UILayer/Lock.show()
