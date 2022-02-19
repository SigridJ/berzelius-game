extends PopupPanel

var originalScale
var originalPos

func _ready():
	self.set_pivot_offset(self.rect_size * 0.5)
	originalScale = self.rect_scale
	originalPos = self.rect_position

func _on_VictoryPopup_about_to_show():
	self.rect_position = originalPos
	var tween = get_node("Tween")
	tween.interpolate_property(self, "rect_scale", originalScale * 0.1, originalScale, 1, 6, 1)
	tween.start()

func _on_VictoryPopup_popup_hide():
	self.show()
	var tween = get_node("Tween")
	tween.interpolate_property(self, "rect_position", originalPos, Vector2(-self.rect_size.x, originalPos.y), 1, 6, 2)
	tween.start()
