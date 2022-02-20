extends Polygon2D

var height: float
var width: float
var oldSize = 0
var remove = false
var tween

signal delete_me(origin)

func _ready():
	pass

func _process(delta):
	if is_instance_valid(tween) and tween.is_active():
		self.update_polygon()
	elif not is_instance_valid(tween) and remove:
		emit_signal("delete_me", self)

func redraw(size, col = color, animation = false):
	color = col
	var waterRect = get_parent().waterRect
	var maxWaterLevel = get_parent().maxWaterLevel
	width = waterRect.size.x
	height = size * (waterRect.size.y as float / maxWaterLevel)
	if animation:
		var oldHeight = oldSize * (waterRect.size.y as float / maxWaterLevel)
		tween = get_node("Tween")
		tween.interpolate_property(self, "height", oldHeight, height, 0.2 * abs(size - oldSize))
		tween.start()
		tween.interpolate_property(self, "position:y", position.y + (height - oldHeight), position.y, 0.2 * abs(size - oldSize))
		tween.start()
	else:
		self.update_polygon()
	oldSize = size

func delete(animation = false):
	if animation:
		remove = true
		position.y += height
		redraw(0, color, animation)
	else:
		emit_signal("delete_me", self)

func update_polygon():
	polygon = PoolVector2Array([
				Vector2(0,0),
				Vector2(width, 0),
				Vector2(width, height),
				Vector2(0, height)
			])
	self.update()
