class_name GameManager extends Node2D


var map_generator:MapGenerator = null:
	get:
		if not is_instance_valid(map_generator): map_generator = get_tree().get_first_node_in_group(&"map_generator")
		return map_generator
var spawn_manager:SpawnManager = null:
	get:
		if not is_instance_valid(spawn_manager): spawn_manager = get_tree().get_first_node_in_group(&"spawn_manager")
		return spawn_manager


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.map_ready.connect(_map_ready)


func _map_ready() -> void:
	Signals.spawn_character.emit()
