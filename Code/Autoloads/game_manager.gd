class_name GameManager extends Node2D


var map_generator:MapGenerator = null:
	get:
		if not is_instance_valid(map_generator): map_generator = get_tree().get_first_node_in_group(&"map_generator")
		return map_generator
var spawn_manager:SpawnManager = null:
	get:
		if not is_instance_valid(spawn_manager): spawn_manager = get_tree().get_first_node_in_group(&"spawn_manager")
		return spawn_manager
var run_selected_character:CharacterData


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.map_ready.connect(_map_ready)


func set_active_character_data(new_data:CharacterData) -> void:
	if new_data == null:
		push_error("Game Manager received null character data.")

	run_selected_character = new_data.duplicate(true)


func _map_ready() -> void:
	Signals.spawn_character.emit()
