extends Node2D

var height = 70
var width = 100
var steps = 20
var color = Color()
var oldSize = 0
var remove = false
var tween

signal delete_me(origin)

func _ready():
	pass

func _process(delta):
	if is_instance_valid(tween) and tween.is_active():
		self.update()
	elif not is_instance_valid(tween) and remove:
		emit_signal("delete_me", self)

func redraw(size, col = color, animation = false):
	color = col
	var waterRect = get_parent().waterRect
	var maxWaterLevel = get_parent().maxWaterLevel
	width = waterRect.size.x
	height = size * (waterRect.size.y as float / maxWaterLevel)
	var oldHeight = oldSize * (waterRect.size.y as float / maxWaterLevel)
	if animation:
		tween = get_node("Tween")
		tween.interpolate_property(self, "height", oldHeight, height, 0.2 * abs(size - oldSize))
		tween.start()
		tween.interpolate_property(self, "position:y", position.y + (height - oldHeight), position.y, 0.2 * abs(size - oldSize))
		tween.start()
	else:
		self.update()
	oldSize = size

func delete(animation = false):
	if animation:
		remove = true
		position.y += height
		redraw(0, color, animation)
	else:
		emit_signal("delete_me", self)

func _draw():
	var radius = width/2
	var angles: Array
	var s = PI/steps
	var polygon: PoolVector2Array
	if height >= radius:
		polygon. append_array(PoolVector2Array([
			Vector2(width, height - radius),
			Vector2(width, 0),
			Vector2(0, 0),
			Vector2(0, height - radius)
		]))
		for i in range(1, steps + 1):
			angles.append(PI - i*s)
	else:
		var startAngle = asin(abs(height - radius) as float / radius)
		var angle = PI - startAngle
		while angle > startAngle:
			angles.append(angle)
			angle -= s
		angles.append(startAngle)
	for angle in angles:
		polygon.append(Vector2(radius*cos(angle) + radius, radius*sin(angle) + height - radius))
	self.draw_colored_polygon(polygon, color)
