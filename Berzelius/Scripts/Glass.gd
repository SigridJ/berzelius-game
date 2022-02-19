extends Area2D

var BottomWater = preload("res://Scenes/BottomWater.tscn")
var glassBorderWidth = 0
var maxWaterLevel = 4
var index: int
var waterRect: Rect2
var waters: Array
var focus = false
var originalPos: Vector2

signal picked(origin)

class Water:
	var color: String
	var size: int
	var node = null
	
	func _init(col, s):
		color = col
		size = s

func _ready():
	waterRect = getWaterRect($EmptyGlass.get_rect())


# ----------- Water logic ------------

func init(maxlevel: int, col: String, i: int):
	maxWaterLevel = maxlevel
	index = i
	if col != "empty":
		waters.append(Water.new(col, maxlevel))

func water_level():
	var level = 0
	for water in waters:
		level += water["size"]
	return level

func is_empty():
	return water_level() == 0

func is_full():
	return water_level() == maxWaterLevel

func is_one_color():
	return len(waters) == 1

func top():
	if is_empty():
		return Water.new("empty", 0)
	else:
		return waters[-1]

func add(col: String, size: int, animation = true):
	assert(water_level() + size <= maxWaterLevel)
	if col == top().color:
		waters[-1].size += size
	else:
		waters.append(Water.new(col, size))
	draw_water(waters[-1], animation)

func remove(size: int):
	assert(not is_empty() and top().size - size >= 0)
	if top().size == size:
		waters[-1].node.queue_free()
		waters.pop_back()
	else:
		waters[-1].size -= size
		draw_water(waters[-1])

func draw_all():
	var surfacePosition = 0
	var i = 0
	for water in waters:
		surfacePosition += water.size
		draw_water(water, false, surfacePosition, i == 0)
		i += 1

# ----------- Positioning ------------

func getWaterRect(glassRect):
	var width = 2 * glassRect.size.x / 3
	var height = 7 * glassRect.size.y / 8
	var x = glassRect.position.x + (glassRect.size.x - width) / 2
	var y = glassRect.position.y + (glassRect.size.y - height - glassBorderWidth)
	return Rect2(x, y, width, height)

func waterSize():
	return Vector2(waterRect.size.x, waterRect.size.y / maxWaterLevel)

func draw_water(water, animation = false, surfacePosition = 0, first = false):
	assert(water.size > 0)
	var pos = maxWaterLevel - water_level()
	if surfacePosition != 0:
		pos = maxWaterLevel - surfacePosition
	if not is_instance_valid(water.node):
		if is_one_color() or first:
			water.node = BottomWater.instance()
			water.node.width = waterSize().x
			water.node.height = water.size * waterSize().y
		else:
			water.node = Polygon2D.new()
			water.node.polygon = PoolVector2Array([
				Vector2(0,0),
				Vector2(waterSize().x, 0),
				Vector2(waterSize().x, waterSize().y * water.size),
				Vector2(0, waterSize().y * water.size)
			])
		water.node.color = Color(water.color)
		water.node.position = waterRect.position + Vector2(0, waterSize().y * pos)
		add_child(water.node)
		if animation:
			var tween = get_node("Tween")
			tween.interpolate_property(water.node, "scale", Vector2(water.node.scale.x, water.node.scale.y * 0.2), water.node.scale, 1)
			tween.start()
			tween.interpolate_property(water.node, "position", water.node.position + Vector2(0, water.node.height) * 0.8, water.node.position, 1)
			tween.start()
	else:
		if is_one_color() or first:
			water.node.height = water.size * waterSize().y
		else:
			water.node.polygon = PoolVector2Array([
				Vector2(0,0),
				Vector2(waterSize().x, 0),
				Vector2(waterSize().x, waterSize().y * water.size),
				Vector2(0, waterSize().y * water.size)
			])
		water.node.position = waterRect.position + Vector2(0, waterSize().y * pos)
		water.node.update()

func dimentions():
	return $EmptyGlass.get_rect().size

# ------------ Animations ------------

func reFocus():
	focus = true
	var riseTween = get_node("Tween")
	riseTween.interpolate_property(self, "position", null, originalPos + Vector2(0,-50), 0.3, 3, 2)
	riseTween.start()

func unFocus():
	focus = false
	var riseTween = get_node("Tween")
	riseTween.interpolate_property(self, "position", null, originalPos, 0.3, 3, 2)
	riseTween.start()

func _on_Glass_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("picked", self)
