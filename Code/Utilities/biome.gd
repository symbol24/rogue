class_name Biome extends Node2D


enum Identity {FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH, EIGHT, NINTH}


@export var biome:Identity
@export var level_count := 5
@export var loot_table:Array[ItemData] = []
@export var item_bonus_count := 1
@export var enemy_table:Array[EnemyData] = []
@export var enemies_spawned_at_start := 2
@export var ticks_between_enemy_spawn := 100

var _pause_input:PauseMenuInputProcess
var _tick_counter := 0


func _ready() -> void:
	Signals.action_tick.connect(_action_tick)
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


func _action_tick() -> void:
	_tick_counter += 1
	if _tick_counter >= ticks_between_enemy_spawn:
		_tick_counter = 0
		Signals.biome_tick_counter_ticked.emit()