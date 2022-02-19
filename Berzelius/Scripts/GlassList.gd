extends Node

# ----------- Variables ------------

export (PackedScene) var Glass
export var setupMixNumber: int
var maxWaterLevel = 4
var rows = 2
var fullGlassNumber = 8
var emptyGlassNumber = 2
var colors = ["2fc40e", "ff9b2f", "14cdff", "ff8dd6", "0069ff", "38e9c3", "d7002b", "8f00fc", "e0e040", "0003b4", "aaabff", "ff5812", "ec3ae0"]
var level: int
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

# ---------- Save and load games ----------

func _ready():
	pass

func load_game():
	var saveFile = File.new()
	if not saveFile.file_exists("user://game.save"):
#	if true:
		return false
	saveFile.open("user://game.save", File.READ)
	var save = parse_json(saveFile.get_line())
	level = save["level"] as int
	maxWaterLevel = save["maxWaterLevel"] as int
	rows = save["rows"] as int
	fullGlassNumber = save["fullGlassNumber"] as int
	emptyGlassNumber = save["emptyGlassNumber"] as int
	glassesAtStart = []
	for glass in save["glassesAtStart"]:
		var watersAtStart = []
		for water in glass:
			watersAtStart.append({"color": water["color"], "size": water["size"] as int})
		glassesAtStart.append(watersAtStart)
	
	playHistory = []
	print(save["playHistory"])
	for entry in save["playHistory"]:
		print([entry[0] as int, entry[1] as int, entry[2] as int, entry[3]])
		playHistory.append([entry[0] as int, entry[1] as int, entry[2] as int, entry[3]])
	
	var glassesArray = save["glasses"].duplicate()
	
	clearLevel()
	add_glasses()
	for i in range(glass_number()):
		glasses[i].waters = []
		for water in glassesArray[i]:
			glasses[i].waters.append(glasses[i].Water.new(water["color"], water["size"] as int))
	draw_level()
	return true

func save_game():
	var glassesArray: Array
	for glass in glasses:
		var watersArray = []
		for water in glass.waters:
			watersArray.append({"color": water.color, "size": water.size})
		glassesArray.append(watersArray)
	var save = {
		"level": level,
		"maxWaterLevel": maxWaterLevel,
		"rows": rows,
		"fullGlassNumber": fullGlassNumber,
		"emptyGlassNumber": emptyGlassNumber,
		"glasses": glassesArray,
		"glassesAtStart": glassesAtStart,
		"playHistory": playHistory
	}
	var saveFile = File.new()
	saveFile.open("user://game.save", File.WRITE)
	saveFile.store_line(to_json(save))
	saveFile.close()
	print("saved game")

# ----------- Level Generation ------------

func glass_number():
	return fullGlassNumber + emptyGlassNumber

func get_level():
	if not load_game():
		generate_level(1)
		return 1
	else:
		return level
	

func generate_level(number):
	level = number
	generate_level_numbers()
	print("generate numbers")
	clearLevel()
	print("clear level")
	add_glasses()
	print("add glasses")
	setup_mix()
	print("setup mix")
	copy_level()
	print("copy level")
	draw_level()
	print("draw level")
	save_game()

func generate_level_numbers():
	maxWaterLevel = (randi() % 3) + 3
	var levels = [
		[ 8, 2, 2],
		[ 9, 1, 2],
		[10, 2, 2],
		[11, 1, 2],
		[12, 2, 2],
		[13, 1, 2],
		[13, 2, 3]
#		[14, 1, 3],
#		[15, 3, 3],
#		[16, 2, 3],
#		[17, 1, 3],
#		[18, 3, 3],
#		[19, 2, 3],
#		[20, 1, 3]
	]
	var randIndex = randi() % len(levels)
	fullGlassNumber = levels[randIndex][0]
	emptyGlassNumber = levels[randIndex][1]
	rows = levels[randIndex][2]

func copy_level():
	glassesAtStart = []
	for glass in glasses:
		var watersAtStart = []
		for water in glass.waters:
			watersAtStart.append({"color": water.color, "size": water.size})
		glassesAtStart.append(watersAtStart)

func restart():
	clearLevel()
	playHistory = []
	add_glasses()
	for i in range(glass_number()):
		glasses[i].waters = []
		for water in glassesAtStart[i]:
			glasses[i].waters.append(glasses[i].Water.new(water["color"], water["size"]))
	draw_level()
	save_game()

func clearLevel():
	for glass in glasses:
		glass.queue_free()
	glasses = []
	mixHistory = []
	second = false

func add_glasses():
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
	if history_entry(pour.inv(), pour.color()) in mixHistory:
		return true
	if history_entry(pour, pour.color()) in mixHistory:
		return true
	return false

func get_history_index(glass):
	for i in range(glass_number()):
		var index = mixHistory.find_last([i, glass.index, glass.water_level(), glass.top().color])
		if index != -1:
			return index
	print("no index")
	print(mixHistory)
	print(glass.index)

func correct_empty_glass_pour(pour: Pour):
	if pour.b.index >= fullGlassNumber and pour.b.is_one_color():
			return false
	if pour.a.index >= fullGlassNumber:
		for i in range(glass_number()):
			if not [i, pour.a.index, pour.a.water_level(), pour.a.top().color] in mixHistory:
				return true
		for i in range(get_history_index(pour.a) + 1, len(mixHistory)):
			if pour.b.index == mixHistory[i][0] or pour.b.index == mixHistory[i][1]:
				return true
		return false
	return true

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
				if pour.is_possible_setup() and not in_mix_history(pour) and correct_empty_glass_pour(pour):
					pours.append(pour)
	var pourSizes = []
	for pour in pours:
		pourSizes.append(pour.size)
	var maxPourSize = maximum(pourSizes)
	var maxPours = []
	for pour in pours:
		if pour.size == maxPourSize:
			maxPours.append(pour) 
#	var emptyPours = []
#	for pour in maxPours:
#		if pour.b.index >= fullGlassNumber:
#			emptyPours.append(pour)
#	if len(emptyPours) > 0:
#		return emptyPours
	return maxPours

func do_setup_pour(pour: Pour):
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
			break
		var index = randi() % len(possible)
		for j in range(len(possible)):
			if possible[j].b.index >= fullGlassNumber:
				index = j
				break
		var pour = possible[index]
#		print("from: %d, to: %d, size: %d, color: %s" % [pour.a.index, pour.b.index, pour.size, pour.color()])
		mixHistory.append(history_entry(pour, pour.color()))
		do_setup_pour(pour)
	for i in range(fullGlassNumber, glass_number()):
		for k in range(3):
			if not glasses[i].is_empty():
				for j in range(fullGlassNumber):
					if glasses[j].top().color == glasses[i].top().color and not glasses[j].is_full():
						var size = glasses[i].top().size
						if glasses[j].water_level() + size > maxWaterLevel:
							size = maxWaterLevel - glasses[j].water_level()
						var pour = Pour.new(glasses[i], glasses[j], size)
						mixHistory.append(history_entry(pour, pour.color()))
						do_setup_pour(pour)
						break

func scale_glasses():
	for glass in glasses:
		glass.scale = Vector2(0.8,0.9)
	var glassSize = glasses[0].dimentions()
	return Vector2(glassSize.x * 0.8, glassSize.y * 0.9)

func draw_level():
	var screen_size = Vector2(1080,2340)
	var yMiddle = screen_size.y / 2.0
	var seperation = Vector2(0, 100)
	var glassSize = glasses[0].dimentions()
	print(glassSize)
	if glassSize.x * (glass_number() / rows) > screen_size.x - 2 * 110:
		glassSize = scale_glasses()
	print(glassSize)
	var gameHight = rows * glassSize.y + (rows - 1) * seperation.y
	var yGame = yMiddle - gameHight / 2.0
#	var yGame = yMiddle
	var gameRect = Rect2(Vector2(110, yGame), Vector2(screen_size.x - 2*110, gameHight))
	seperation.x = (gameRect.size.x - glassSize.x) as float / (glass_number() / rows - 1) - glassSize.x
#	seperation.x = 30
	var positions: Array
	for row in range(rows):
		for column in range(glass_number()/rows):
			var x = column * (glassSize.x + seperation.x)
			var y = row * (glassSize.y + seperation.y)
			positions.append(gameRect.position + Vector2(x, y))
	for i in range(glass_number()):
		glasses[i].draw_all()
		glasses[i].position = positions[i]
		glasses[i].originalPos = positions[i]

# ----------- Player Interaction ------------

func do_player_pour(pour: Pour):
	assert(pour.is_possible_pour())
	if pour.b.water_level() + pour.size > maxWaterLevel:
		pour.size = maxWaterLevel - pour.b.water_level()
	playHistory.append(history_entry(pour, pour.color()))
	glasses[pour.b.index].add(pour.color(), pour.size)
	glasses[pour.a.index].remove(pour.size)
	save_game()

func undo():
	print(len(playHistory))
	if len(playHistory) > 0:
		var b = playHistory[-1][0]
		var a = playHistory[-1][1]
		var size = playHistory[-1][2]
		var pour = Pour.new(glasses[a], glasses[b], size)
		glasses[b].add(pour.color(), pour.size, false)
		glasses[a].remove(pour.size)
		playHistory.pop_back()
		save_game()

func is_done():
	for glass in glasses:
		if not (glass.is_full() and glass.is_one_color()) and not glass.is_empty():
			return false
	save_game()
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
