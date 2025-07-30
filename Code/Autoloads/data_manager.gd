class_name DataManager extends Node


signal save_complete
signal load_complete


const FOLDER = "user://save/"
const EXTENSION = "tres"
const MAPSIZE := Vector2(320, 180)


var loaded_save_file: SaveData
var all_save_data: Array[SaveData] = []


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	all_save_data = _get_all_saves()


func save(_player_data: Variant) -> void:
	if loaded_save_file == null:
		loaded_save_file = SaveData.new()
		loaded_save_file.id = all_save_data.size()
		loaded_save_file.file_name = str(hash(loaded_save_file.id))

	# TODO: Place whatever information you want in the SaveData
	# or retrieve the data you want and add it to the save

	loaded_save_file.save_time_and_date = Time.get_unix_time_from_system()
	ResourceSaver.save(loaded_save_file, FOLDER + loaded_save_file.file_name + "." + EXTENSION)
	save_complete.emit()


func load_file(id: int) -> void:
	loaded_save_file = _get_save_from_id(id)
	load_complete.emit()
	# With the signal you can then access the information you need to load.


func _get_all_saves() -> Array[SaveData]:
	var saves: Array[SaveData] = []
	var dir: DirAccess = _check_folder()
	if dir != null:
		var files: PackedStringArray = dir.get_files()
		for file in files:
			if file.get_extension() == EXTENSION:
				saves.append(load(FOLDER + file))
	return saves


func _check_folder() -> DirAccess:
	var dir: DirAccess = DirAccess.open(FOLDER)
	if dir == null:
		var result = DirAccess.make_dir_absolute(FOLDER)
		if result != OK:
			print_debug("Error creating save folder: ", result)
			return null
	return dir


func _get_save_from_id(id: int) -> SaveData:
	for each in all_save_data:
		if each.id == id:
			return each
	return null


func _get_last_saved_save() -> SaveData:
	var last: SaveData = null
	for each in all_save_data:
		if last == null:
			last = each
		elif each.save_time_and_date > last.save_time_and_date:
			last = each
	return last
