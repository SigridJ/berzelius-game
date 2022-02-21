class Setting:
	var animation: bool
	var sound : bool
	var music: bool
	
	func _init(dictionary: Dictionary):
		animation = dictionary["Animation"]
		sound = dictionary["Sound"]
		music = dictionary["Music"]
	
	func dictionary():
		return {"Animation": animation, "Sound": sound, "Music": music}

func _ready():
	pass

func get_settings():
	var settingsFile = File.new()
	if not settingsFile.file_exists("user://game.settings"):
		return Setting.new({"Animation": true, "Sound": true, "Music": true})
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

func set_music_setting(m: bool):
	var setting = get_settings()
	setting.music = m
	save(setting)
