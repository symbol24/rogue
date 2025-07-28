class_name GameManager extends Node2D


var map_generator:MapGenerator = null:
	get:
		if map_generator == null: map_generator = get_tree().get_first_node_in_group(&"map_generator")
		return map_generator


func _ready() -> void:
	Signals.map_ready.connect(_map_ready)


func _map_ready() -> void:
	Signals.spawn_character.emit()
