class Setting:
	var animation: bool
	var sound : bool
	
	func _init(dictionary: Dictionary):
		animation = dictionary["Animation"]
		sound = dictionary["Sound"]
	
	func dictionary():
		return {"Animation": animation, "Sound": sound}

func _ready():
	pass

func get_settings():
	var settingsFile = File.new()
	if not settingsFile.file_exists("user://game.settings"):
		return Setting.new({"Animation": true, "Sound": false})
	settingsFile.open("user://game.settings", File.READ)
	return Setting.new(parse_json(settingsFile.get_line()))

func save(settings: Setting):
	var settingsFile = File.new()
	settingsFile.open("user://game.settings", File.WRITE)
	settingsFile.store_line(to_json(settings.dictionary()))
	settingsFile.close()

func set_animation_setting(anim: bool):
	var setting = get_settings()
	setting.animation = anim
	save(setting)

func set_sound_setting(s: bool):
	var setting = get_settings()
	setting.sound = s
	save(setting)
