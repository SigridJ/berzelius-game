extends PopupPanel

var originalPos: Vector2

func _ready():
	originalPos = self.rect_position

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
