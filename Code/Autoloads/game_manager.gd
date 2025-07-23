class_name GameManager extends Node2D



func _ready() -> void:
	Signals.map_ready.connect(_map_ready)


func _map_ready() -> void:
	Signals.spawn_character.emit()
