extends Node

# ----------- Variables ------------

export (PackedScene) var Glass
export var maxWaterLevel = 4
export var rows = 2
export var fullGlassNumber = 8
export var emptyGlassNumber = 2
export var setupMixNumber = 4
var glasses: Array
var mixNumber: int
var glassesAtStart: Array
var mixHistory: Array
var playHistory: Array
var second = false
var firstGlass

signal victory

# ----------- Pour Class ------------

class Pour:
	var a = null
	var b = null
	var size: int
	
	func _init(from, to, s: int):
		a = from
		b = to
		size = s
	
	func equal_color():
		return a.top().color == b.top().color
	
	func is_possible_setup():
		if size <= 0:
			return false
		if a == b:
			return false
		if a.is_empty():
			return false
		if not a.is_one_color() and a.top().size < 2:
			return false
		if a.is_one_color():
			if size > a.top().size:
				return false
		else:
			if size > a.top().size - 1:
				return false
		if b.water_level() + size > b.maxWaterLevel:
			return false
		if (not b.is_empty()) and (not a.is_full()) and equal_color():
			return false
		return true
	
	func is_possible_pour():
		if b.water_level() == b.maxWaterLevel:
			return false
		if not (b.is_empty() or equal_color()):
			return false
		return true
	
	func color():
		return a.top().color
	
	func inv():
		return Pour.new(b, a, size)

# ----------- Level Generation ------------

func _ready():
	pass

func glass_number():
	return fullGlassNumber + emptyGlassNumber

func generate_level():
	clearLevel()
	add_glasses()
	setup_mix()
	glassesAtStart = glasses.duplicate(true)
	draw_level()

func restart():
	glasses = glassesAtStart.duplicate(true)
	draw_level()

func clearLevel():
	for glass in glasses:
		glass.queue_free()
	glasses = []
	mixNumber = 0
	mixHistory = []
	playHistory = []

func get_colors():
	var colors: Array
	for hue in range(fullGlassNumber):
		print(hue as float / fullGlassNumber)
		var color = Color().from_hsv(hue as float / fullGlassNumber, 0.8, 1)
		colors.append(color.to_html())
	return colors

func add_glasses():
	var colors = get_colors()
	print(colors)
	for i in range(fullGlassNumber):
		var glass = Glass.instance()
		add_child(glass)
		glass.init(maxWaterLevel, colors[i], i)
		glass.connect("picked", self, "_on_glass_picked")
		glasses.append(glass)
	for i in range(fullGlassNumber, glass_number()):
		var glass = Glass.instance()
		add_child(glass)
		glass.init(maxWaterLevel, "empty", i)
		glass.connect("picked", self, "_on_glass_picked")
		glasses.append(glass)

func history_entry(pour: Pour, color):
	return [pour.a.index, pour.b.index, pour.size, color]

func in_mix_history(pour: Pour):
	return history_entry(pour.inv(), pour.color()) in mixHistory

func maximum(A: Array):
	var m = -INF
	for a in A:
		assert(a is int or a is float)
		if a > m:
			m = a
	return m

func get_possible_setup_pours():
	var pours = []
	for a in glasses:
		for b in glasses:
			for size in range(1, maxWaterLevel):
				var pour = Pour.new(a, b, size)
				if pour.is_possible_setup() and not in_mix_history(pour):
					pours.append(pour)
	var pourSizes = []
	for pour in pours:
		pourSizes.append(pour.size)
	var maxPourSize = maximum(pourSizes)
	var maxPours = []
	for pour in pours:
		if pour.size == maxPourSize:
			maxPours.append(pour)
	return maxPours

func do_setup_pour(pour: Pour):
	assert(pour.is_possible_setup())
	if not pour.b.is_empty() and pour.equal_color():
		glasses[pour.b.index].waters[-1].size += pour.size
	else:
		glasses[pour.b.index].waters.append(pour.b.Water.new(pour.a.top().color, pour.size))
	if pour.a.top().size > pour.size:
		glasses[pour.a.index].waters[-1].size -= pour.size
	else:
		glasses[pour.a.index].waters.pop_back()

func setup_mix():
	for i in range(setupMixNumber):
		var possible = get_possible_setup_pours()
		if len(possible) == 0:
			return
		var randIndex = randi() % len(possible)
		var pour = possible[randIndex]
		mixHistory.append(history_entry(pour, pour.color()))
		do_setup_pour(pour)

func draw_level():
	var screen_size = get_viewport().size
	var i = 0
	for posy in range(100, rows * 300, 300):
		for posx in range(0, glass_number()/rows * 100, 100):
			glasses[i].draw_all()
			glasses[i].position = Vector2(posx, posy)
			glasses[i].scale *= 0.4
			i += 1

# ----------- Player Interaction ------------

func do_player_pour(pour: Pour):
	assert(pour.is_possible_pour())
	if pour.b.water_level() + pour.size > maxWaterLevel:
		pour.size = maxWaterLevel - pour.b.water_level()
	playHistory.append(history_entry(pour, pour.color()))
	glasses[pour.b.index].add(pour.color(), pour.size)
	glasses[pour.a.index].remove(pour.size)

func undo():
	var b = playHistory[-1][0]
	var a = playHistory[-1][1]
	var size = playHistory[-1][2]
	var pour = Pour.new(glasses[a], glasses[b], size)
	assert(pour.is_possible_setup())
	playHistory.pop_back()
	do_setup_pour(pour)
	draw_level()

func is_done():
	for glass in glasses:
		if not (glass.is_full() or glass.is_empty()):
			return false
	return true

func _on_glass_picked(glass):
	if not second:
		second = true
		firstGlass = glass
		glass.reFocus()
	else:
		var pour = Pour.new(firstGlass, glass, firstGlass.top().size)
		if pour.is_possible_pour() and firstGlass != glass:
			do_player_pour(pour)
		firstGlass.unFocus()
		second = false
		if is_done():
			emit_signal("victory")
