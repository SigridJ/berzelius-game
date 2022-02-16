extends Node2D

var height = 70
var width = 100
var steps = 20
var color = Color()

func _ready():
	assert(height >= width/2)
	pass

func _draw():
	var radius = width/2
	var polygon = PoolVector2Array([
		Vector2(width, height - radius),
		Vector2(width, 0),
		Vector2(0, 0),
		Vector2(0, height - radius)
	])
	var angles: Array
	var s = PI/steps
	for i in range(1, steps + 1):
		angles.append(PI - i*s)
	for angle in angles:
		polygon.append(Vector2(radius*cos(angle) + radius, radius*sin(angle) + height - radius))
	self.draw_colored_polygon(polygon, color)
