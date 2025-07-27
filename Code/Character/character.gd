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
	print("move in direction ", direction)


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
