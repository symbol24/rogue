class_name Biome extends Node2D


enum Identity {FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH, EIGHT, NINTH}


@export var biome:Identity
@export var level_count := 5
@export var loot_table:Array[ItemData] = []
@export var item_bonus_count := 1

var _pause_input:PauseMenuInputProcess


func _ready() -> void:
	_setup_pause_input()
	_generate_map()


func _generate_map() -> void:
	Signals.generate_map.emit(MapGenerator.SCREENSIZE)


func _exit_tree() -> void:
	_pause_input.unregister()
	Signals.toggle_rid_control.emit(&"in_game_ui", false, &"")


func _setup_pause_input() -> void:
	_pause_input = PauseMenuInputProcess.new()
	add_child(_pause_input)
	_pause_input.name = &"pause_input_0"
	if not _pause_input.is_node_ready(): await _pause_input.ready
	_pause_input.register()
