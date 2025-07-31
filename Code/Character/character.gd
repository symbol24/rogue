class_name Character extends Node2D


var data:CharacterData
var _current_location:Vector2i = Vector2i.ZERO
var _input:InputProcess
var _ready_sent := false


func _ready() -> void:
	Signals.input_focuse_changed.connect(_input_focus_changed)


func setup_character(new_data:CharacterData, coords:Vector2i) -> void:
	data = new_data.duplicate(true)
	data.setup_character_data()
	_current_location = coords
	_setup_input()


func move_character(direction:StringName) -> void:
	var new_pos:Vector2i = _current_location
	match direction:
		&"up":
			new_pos += Vector2i.UP
		&"down":
			new_pos += Vector2i.DOWN
		&"left":
			new_pos += Vector2i.LEFT
		&"right":
			new_pos += Vector2i.RIGHT
		_:
			pass

	if GM.map_generator != null and GM.map_generator.map.has(new_pos) and GM.map_generator.map[new_pos] != MapGenerator.WALL:
		if GM.map_generator.map[new_pos] in [MapGenerator.FLOOR, MapGenerator.DOOR, MapGenerator.ENTRANCE, MapGenerator.EXIT, MapGenerator.HALLWAY, MapGenerator.ITEM]:
			_current_location = new_pos
			global_position = _current_location * 8

			if GM.map_generator.map[_current_location] == MapGenerator.ITEM:
				_pickup_item(_current_location)


func interact() -> void:
	if GM.map_generator != null and GM.map_generator.map.has(_current_location):
		if GM.map_generator.map[_current_location] == MapGenerator.ENTRANCE:
			print("This is the entrance, you cannot go back up!")
		elif GM.map_generator.map[_current_location] == MapGenerator.EXIT:
			data.go_to_next_biome_level()
			Signals.load_scene.emit(Biome.Identity.keys()[data.biome], true, true)


func unregister_input() -> void:
	_input.unregister()


func _setup_input() -> void:
	_input = CharacterInputProcess.new()
	add_child(_input)
	_input.name = &"character_input_0"
	if not _input.is_node_ready(): await _input.ready
	_input.register()


func _input_focus_changed() -> void:
	if _ready_sent: return
	Signals.character_ready.emit(self)
	_ready_sent = true


func _exit_tree() -> void:
	_input.unregister()


func _pickup_item(coords:Vector2i) -> void:
	var new_item:ItemData = GM.spawn_manager.get_item_by_coords(coords)
	if new_item != null:
		data.pickup(new_item)
		Signals.remove_item.emit(new_item)
