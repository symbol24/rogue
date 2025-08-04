class_name Biome extends Node2D


enum Identity {FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH, EIGHT, NINTH}


@export var biome:Identity
@export var level_count := 5
@export var loot_table:Array[ItemData] = []
@export var item_bonus_count := 1


func _ready() -> void:
	_generate_map()


func _generate_map() -> void:
	Signals.generate_map.emit(MapGenerator.SCREENSIZE)
