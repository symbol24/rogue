class_name SpawnManager extends Node


const DEBUGCHARACTER := preload("uid://cpjhs0lqsgyex")
const DEBUGCHARACTERDATA := preload("uid://bq683wyy7cl23")


var active_character:Character
var map_generator:MapGenerator = null:
	get:
		if map_generator == null: map_generator = get_tree().get_first_node_in_group("map_generator")
		return map_generator


func _ready() -> void:
	Signals.spawn_character.connect(_spawn_character)
	Signals.remove_character.connect(_remove_character)


func _spawn_character() -> void:
	active_character = DEBUGCHARACTER.instantiate()
	add_child(active_character)
	if not active_character.is_node_ready(): await active_character.ready
	active_character.global_position = map_generator.entrance*8
	active_character.setup_character(DEBUGCHARACTERDATA, map_generator.entrance)


func _remove_character() -> void:
	if is_instance_valid(active_character):
		active_character.unregister_input()
		active_character.queue_free()
