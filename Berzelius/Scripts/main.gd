extends Node

var Glass = preload("res://Scenes/Glass.tscn")

func _ready():
	new_level()

func new_level():
	$GlassList.generate_level()

func _on_GlassList_victory():
	$PopupLayer/VictoryPopup.popup_centered()

func _on_NewGame_pressed():
	$PopupLayer/VictoryPopup.hide()
	new_level()
